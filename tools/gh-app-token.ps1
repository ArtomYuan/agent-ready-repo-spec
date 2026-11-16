# 用 GitHub App 私钥换取 installation access token（不依赖 git / gh / node / openssl）
#
# 本机没有 node、git、gh、openssl；PowerShell 5.1 也没有 ImportPkcs8PrivateKey。
# 已验证可行的路径：PKCS#1 私钥 → 手工包成 PKCS#8 → CngKey.Import → RSACng 做 RS256 签名 → JWT。
#
# 用法：
#   ./tools/gh-app-token.ps1 -Verify     # 换取后调 API 验证身份（不打印 token）
#   ./tools/gh-app-token.ps1 -Export     # 只输出 token 字符串，便于 $env:GH_TOKEN = (./tools/gh-app-token.ps1 -Export)
#   ./tools/gh-app-token.ps1             # 打印 token（调试用）
#
# token 有效期 1 小时；脚本不落盘、不缓存。

[CmdletBinding()]
param(
  [string]$PrivateKeyPath = '',   # 必填：指向 App 的 .pem（不把本机路径写进仓库）
  [string]$AppId = '',            # 必填：纯数字 App ID（不是 Client ID）
  [string]$InstallationId = '',     # 必填
  [switch]$Export,
  [switch]$Verify
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

function ConvertTo-Base64Url([byte[]]$bytes) {
  return ([Convert]::ToBase64String($bytes)).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function Enc-DerLength([int]$n) {
  if ($n -lt 0x80) { return [byte[]]@([byte]$n) }
  if ($n -le 0xFF) { return [byte[]]@(0x81, [byte]$n) }
  return [byte[]]@(0x82, [byte](($n -shr 8) -band 0xFF), [byte]($n -band 0xFF))
}

# ---------- 1. PKCS#1 → PKCS#8 ----------
if (-not $PrivateKeyPath) { [Console]::Error.WriteLine('必须提供 -PrivateKeyPath <App 的 .pem>'); exit 1 }
if (-not $AppId) { [Console]::Error.WriteLine('必须提供 -AppId（纯数字 App ID，不是 Client ID）'); exit 1 }
if (-not $InstallationId) { [Console]::Error.WriteLine('必须提供 -InstallationId'); exit 1 }
if (-not (Test-Path -LiteralPath $PrivateKeyPath)) {
  [Console]::Error.WriteLine("私钥不存在: $PrivateKeyPath"); exit 1
}
$pem = [System.IO.File]::ReadAllText($PrivateKeyPath)
if ($pem -notmatch 'BEGIN RSA PRIVATE KEY') {
  [Console]::Error.WriteLine('只支持 PKCS#1（-----BEGIN RSA PRIVATE KEY-----）。'); exit 1
}
$pkcs1 = [Convert]::FromBase64String((($pem -replace '-----[^-]+-----', '') -replace '\s', ''))

# PKCS#8 = SEQUENCE { INTEGER 0, SEQUENCE { OID rsaEncryption, NULL }, OCTET STRING <pkcs1> }
$algId = [byte[]]@(0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00)
$body = [byte[]](@(0x02, 0x01, 0x00) + $algId + @(0x04) + (Enc-DerLength $pkcs1.Length) + $pkcs1)
$pkcs8 = [byte[]](@(0x30) + (Enc-DerLength $body.Length) + $body)

$cng = [System.Security.Cryptography.CngKey]::Import($pkcs8, [System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
$rsa = New-Object System.Security.Cryptography.RSACng($cng)

# ---------- 2. JWT（RS256） ----------
# 注意：不能用 New-TimeSpan -Start ([datetime]'1970-01-01T00:00:00Z')——那个字面量 Kind=Local，
# 相减会把 +08:00 的偏移漏掉，算出的 epoch 整整差 8 小时，JWT 的 iat 落在 8 小时前 → GitHub 返回 401。
$now = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$headerJson = '{"alg":"RS256","typ":"JWT"}'
$payloadJson = '{"iat":' + ($now - 60) + ',"exp":' + ($now + 540) + ',"iss":' + $AppId + '}'
$h64 = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($headerJson))
$p64 = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($payloadJson))
$signingInput = "$h64.$p64"
$sig = $rsa.SignData(
  [Text.Encoding]::ASCII.GetBytes($signingInput),
  [System.Security.Cryptography.HashAlgorithmName]::SHA256,
  [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
)
$jwt = "$signingInput.$(ConvertTo-Base64Url $sig)"
$rsa.Dispose(); $cng.Dispose()

# ---------- 3. 换取 installation token ----------
$appHeaders = @{
  Authorization          = "Bearer $jwt"
  Accept                 = 'application/vnd.github+json'
  'User-Agent'           = 'kujira-agent-bootstrap'
  'X-GitHub-Api-Version' = '2022-11-28'
}
try {
  $resp = Invoke-RestMethod -Method POST -Uri "https://api.github.com/app/installations/$InstallationId/access_tokens" -Headers $appHeaders -ErrorAction Stop
}
catch {
  $detail = ''
  if ($_.ErrorDetails) { $detail = $_.ErrorDetails.Message }
  [Console]::Error.WriteLine("换取 token 失败: $detail")
  exit 2
}

if ($Verify) {
  $th = @{
    Authorization          = "Bearer $($resp.token)"
    Accept                 = 'application/vnd.github+json'
    'User-Agent'           = 'kujira-agent-bootstrap'
    'X-GitHub-Api-Version' = '2022-11-28'
  }
  try {
    $repos = Invoke-RestMethod -Uri 'https://api.github.com/installation/repositories?per_page=100' -Headers $th -ErrorAction Stop
    Write-Host "OK  过期: $($resp.expires_at)  可访问仓库: $($repos.total_count)" -ForegroundColor Green
    foreach ($r in $repos.repositories) {
      Write-Host ("    - {0}  (private={1})" -f $r.full_name, $r.private)
    }
  }
  catch {
    [Console]::Error.WriteLine("token 已获取，但验证失败: $($_.ErrorDetails.Message)")
    exit 3
  }
  exit 0
}

if ($Export) { Write-Output $resp.token; exit 0 }

Write-Host "token: $($resp.token)" -ForegroundColor Yellow
Write-Host "过期:  $($resp.expires_at)" -ForegroundColor DarkGray
exit 0
