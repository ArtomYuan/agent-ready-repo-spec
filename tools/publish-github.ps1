# 把本规范库发布到 GitHub（不需要 git 二进制）
#
# 用法：
#   # 1) 令牌在环境变量里
#   $env:GITHUB_TOKEN = 'ghp_xxx'; ./tools/publish-github.ps1 -Owner <你的账号>
#
#   # 2) 令牌在一份凭证文档里（脚本会用正则把它抠出来，文档里其他内容不影响）
#   ./tools/publish-github.ps1 -TokenFile C:\path\to\credentials.md -Owner <你的账号>
#
#   # 3) 先看计划，不碰网络
#   ./tools/publish-github.ps1 -Owner <你的账号> -DryRun
#
# 行为：
#   - 仓库不存在则创建；存在则把当前目录内容作为**一次提交**追加到默认分支
#   - 一个 commit 包含全部文件（Git Data API：blob → tree → commit → ref）
#   - 不读取、不上传：.git/、reports/、*.local.json
#
# 退出码：0 成功；1 参数/令牌问题；2 网络或 API 失败

[CmdletBinding()]
param(
  [string]$Owner = '',
  [string]$Repo = 'agent-ready-repo-spec',
  [string]$Token = '',
  [string]$TokenFile = '',
  [string]$SourceDir = '',
  [string]$Description = '一个有 AI agent 参与的 GitHub 仓库该长什么样：31 条规则 + 体检器',
  [string]$Message = 'feat: agent-ready-repo-spec 1.0.0',
  [switch]$Private,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

if ([string]::IsNullOrEmpty($SourceDir)) { $SourceDir = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath }
$SourceDir = (Resolve-Path -LiteralPath $SourceDir).ProviderPath

# ---------- 取令牌 ----------
function Get-TokenFromText([string]$text) {
  $patterns = @(
    'github_pat_[A-Za-z0-9_]{40,}',
    'gh[pousr]_[A-Za-z0-9]{36,}',
    'gh[pousr]_[A-Za-z0-9_]{20,}'
  )
  foreach ($p in $patterns) {
    $m = [regex]::Match($text, $p)
    if ($m.Success) { return $m.Value }
  }
  return $null
}

$tokenValue = $Token
if ([string]::IsNullOrEmpty($tokenValue) -and -not [string]::IsNullOrEmpty($TokenFile)) {
  if (-not (Test-Path -LiteralPath $TokenFile -PathType Leaf)) {
    [Console]::Error.WriteLine("凭证文件不存在: $TokenFile"); exit 1
  }
  $raw = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $TokenFile).ProviderPath, [System.Text.Encoding]::UTF8)
  $tokenValue = Get-TokenFromText $raw
  if (-not $tokenValue) { [Console]::Error.WriteLine("在 $TokenFile 里没找到 GitHub 令牌（形态 gh*_ / github_pat_*）。"); exit 1 }
}
if ([string]::IsNullOrEmpty($tokenValue)) { $tokenValue = $env:GITHUB_TOKEN }
if ([string]::IsNullOrEmpty($tokenValue)) { $tokenValue = $env:GH_TOKEN }

if ([string]::IsNullOrEmpty($tokenValue) -and -not $DryRun) {
  [Console]::Error.WriteLine('缺少令牌：用 -Token、-TokenFile，或设置环境变量 GITHUB_TOKEN。')
  exit 1
}

# ---------- 待上传文件清单 ----------
$excludeDirs = @('.git', 'reports', 'node_modules', '.vs', '.vscode', 'bin', 'obj')
$excludeFiles = @('settings.local.json', '*.spec-report.md', '*.spec-report.json', 'Thumbs.db', 'desktop.ini')

$files = @()
Get-ChildItem -LiteralPath $SourceDir -Recurse -File -Force | ForEach-Object {
  $rel = $_.FullName.Substring($SourceDir.Length).TrimStart('\', '/').Replace('\', '/')
  foreach ($d in $excludeDirs) { if ($rel -eq $d -or $rel.StartsWith("$d/")) { return } }
  foreach ($pat in $excludeFiles) { if ($_.Name -like $pat) { return } }
  $files += [pscustomobject]@{ rel = $rel; full = $_.FullName; size = $_.Length }
}
$files = @($files | Sort-Object rel)

if ($files.Count -eq 0) { [Console]::Error.WriteLine("源目录没有可上传文件: $SourceDir"); exit 1 }

# ---------- 干跑 ----------
if ($DryRun) {
  Write-Host "== DRY RUN ==" -ForegroundColor Cyan
  Write-Host "目标: github.com/$Owner/$Repo  (private=$([bool]$Private))"
  Write-Host "来源: $SourceDir"
  Write-Host "文件: $($files.Count) 个，共 $([math]::Round((($files | Measure-Object size -Sum).Sum / 1KB), 1)) KB"
  foreach ($f in $files) { Write-Host ("  {0,8}  {1}" -f $f.size, $f.rel) }
  exit 0
}

if ([string]::IsNullOrEmpty($Owner)) { [Console]::Error.WriteLine('缺少 -Owner。'); exit 1 }

# ---------- API 封装 ----------
$base = 'https://api.github.com'
$headers = @{
  'Authorization'        = "Bearer $tokenValue"
  'Accept'               = 'application/vnd.github+json'
  'User-Agent'           = 'agent-ready-repo-spec-publisher'
  'X-GitHub-Api-Version' = '2022-11-28'
}

function Invoke-Gh {
  param([string]$Method, [string]$Path, $Body = $null)
  $uri = "$base$Path"
  $p = @{ Uri = $uri; Method = $Method; Headers = $headers; ErrorAction = 'Stop' }
  if ($null -ne $Body) {
    $p['Body'] = ($Body | ConvertTo-Json -Depth 10 -Compress)
    $p['ContentType'] = 'application/json; charset=utf-8'
  }
  try { return Invoke-RestMethod @p }
  catch {
    $detail = ''
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $detail = $_.ErrorDetails.Message }
    elseif ($_.Exception.Response) {
      $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $detail = $sr.ReadToEnd()
    }
    [Console]::Error.WriteLine("API 失败 $Method $Path`n$detail")
    exit 2
  }
}

$me = Invoke-Gh GET '/user'
Write-Host "已认证: $($me.login)" -ForegroundColor Green
if ([string]::IsNullOrEmpty($Owner)) { $Owner = $me.login }

# ---------- 仓库 ----------
$repoResp = $null
try { $repoResp = Invoke-RestMethod -Uri "$base/repos/$Owner/$Repo" -Headers $headers -Method GET -ErrorAction Stop } catch { $repoResp = $null }

if ($null -eq $repoResp) {
  Write-Host "创建仓库 $Owner/$Repo ..." -ForegroundColor Cyan
  $repoResp = Invoke-Gh POST '/user/repos' @{
    name        = $Repo
    description = $Description
    private     = [bool]$Private
    auto_init   = $false
    has_issues  = $true
  }
  Write-Host "已创建: $($repoResp.html_url)" -ForegroundColor Green
}
else {
  Write-Host "仓库已存在: $($repoResp.html_url)" -ForegroundColor Yellow
}

# ---------- 空仓库引导 ----------
# GitHub 对「还没有任何提交」的仓库拒绝 git-blob API（409 Git Repository is empty），
# 所以先用一个文件把仓库引导起来，再走 Git Data API。
$parent = @()
try {
  $ref = Invoke-RestMethod -Uri "$base/repos/$Owner/$Repo/git/ref/heads/$($repoResp.default_branch)" -Headers $headers -Method GET -ErrorAction Stop
  $parent = @($ref.object.sha)
} catch {
  Write-Host '仓库为空，先做一次引导提交 ...' -ForegroundColor Cyan
  $bootContent = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("bootstrap`n"))
  Invoke-Gh PUT "/repos/$Owner/$Repo/contents/.bootstrap" @{
    message = 'chore: bootstrap repository for API publishing'
    content = $bootContent
  } | Out-Null
  $ref = Invoke-RestMethod -Uri "$base/repos/$Owner/$Repo/git/ref/heads/$($repoResp.default_branch)" -Headers $headers -Method GET -ErrorAction Stop
  $parent = @($ref.object.sha)
}

# ---------- 上传 blob ----------
$tree = @()
$i = 0
foreach ($f in $files) {
  $i++
  $bytes = [System.IO.File]::ReadAllBytes($f.full)
  $b64 = [Convert]::ToBase64String($bytes)
  $blob = Invoke-Gh POST "/repos/$Owner/$Repo/git/blobs" @{ content = $b64; encoding = 'base64' }
  $tree += @{ path = $f.rel; mode = '100644'; type = 'blob'; sha = $blob.sha }
  Write-Progress -Activity '上传文件' -Status $f.rel -PercentComplete ([int](100 * $i / $files.Count))
}
Write-Progress -Activity '上传文件' -Completed

# ---------- tree / commit / ref ----------
$treeResp = Invoke-Gh POST "/repos/$Owner/$Repo/git/trees" @{ tree = $tree }

$commit = Invoke-Gh POST "/repos/$Owner/$Repo/git/commits" @{
  message = $Message
  tree    = $treeResp.sha
  parents = $parent
}

Invoke-Gh PATCH "/repos/$Owner/$Repo/git/refs/heads/$($repoResp.default_branch)" @{ sha = $commit.sha; force = $false } | Out-Null

Write-Host ''
Write-Host "完成：$($repoResp.html_url)" -ForegroundColor Green
Write-Host "commit: $($commit.sha)"
Write-Host "文件:   $($files.Count)"
Write-Host ''
Write-Host '接下来（检查器查不到、必须手动开的）:' -ForegroundColor Yellow
Write-Host '  1. Settings → Branches → 保护 main：禁止直推、Require review from Code Owners、关闭 force push'
Write-Host '  2. Settings → Actions → General：Workflow permissions 选 Read repository contents'
Write-Host '  3. Security → 开启 Private vulnerability reporting（配合 SECURITY.md）'
exit 0
