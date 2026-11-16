# 走 PR 流程发布（不需要 git 二进制）
#
# 与 publish-github.ps1 的区别：那个是直推 main，这个是
#   建分支 → 提交 → 开 PR → 等 CI → squash 合并
# 主分支开启保护后，**只有这条路**能进 main。
#
# 用法：
#   ./tools/publish-pr.ps1 -Owner ArtomYuan -Message "docs: 修个错字"
#   ./tools/publish-pr.ps1 -TokenFile C:\path\credentials.md -Message "feat(rules): ..."
#   ./tools/publish-pr.ps1 -Message "..." -NoMerge        # 只开 PR，不自动合并
#
# 退出码：0 已合并 / 1 参数或令牌问题 / 2 API 失败 / 3 PR 已开但检查未通过或超时

[CmdletBinding()]
param(
  [string]$Owner = '',
  [string]$Repo = 'agent-ready-repo-spec',
  [string]$Base = 'main',
  [string]$Branch = '',
  [string]$Title = '',
  [string]$Message = '',
  [string]$Next = '',
  [string]$NotDoing = '',
  [string]$Body = '',
  [string]$Token = '',
  [string]$TokenFile = '',
  [string]$SourceDir = '',
  [string]$MergeMethod = 'squash',
  [int]$TimeoutMinutes = 25,
  [switch]$Draft,
  [switch]$NoMerge,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

if ([string]::IsNullOrEmpty($SourceDir)) { $SourceDir = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath }
$SourceDir = (Resolve-Path -LiteralPath $SourceDir).ProviderPath

if ([string]::IsNullOrEmpty($Message)) { $Message = $Title }
if ([string]::IsNullOrEmpty($Message)) { [Console]::Error.WriteLine('必须给 -Message（同时用作 PR 标题，请写成 Conventional Commits 形式）'); exit 1 }
if ([string]::IsNullOrEmpty($Title)) { $Title = $Message }

# ADR-0005：下一步必填。确实没有后续时显式写 -Next "无"
if ([string]::IsNullOrWhiteSpace($Next)) {
  [Console]::Error.WriteLine(@'
缺少 -Next（下一步 / 本次未完的部分）。
  为什么必填：PR 描述是新会话接手时唯一能读到"下一步做什么"的地方（见 guide/06）。
  确实没有后续时，显式写：-Next "无"
  例：-Next "写 templates/work-item 模板"
'@)
  exit 1
}

if ([string]::IsNullOrEmpty($Branch)) {
  $slug = ($Message -replace '^[a-z]+(\([^)]*\))?!?:\s*', '') -replace '[^\w\u4e00-\u9fa5-]+', '-' -replace '-+', '-'
  if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
  $Branch = 'chore/' + (Get-Date -Format 'MMdd-HHmm') + '-' + $slug.Trim('-')
}

# ---------- 令牌 ----------
function Get-TokenFromText([string]$text) {
  foreach ($p in @('github_pat_[A-Za-z0-9_]{40,}', 'gh[pousr]_[A-Za-z0-9]{36,}')) {
    $m = [regex]::Match($text, $p); if ($m.Success) { return $m.Value }
  }
  return $null
}
$tokenValue = $Token
if ([string]::IsNullOrEmpty($tokenValue) -and -not [string]::IsNullOrEmpty($TokenFile)) {
  if (-not (Test-Path -LiteralPath $TokenFile -PathType Leaf)) { [Console]::Error.WriteLine("凭证文件不存在: $TokenFile"); exit 1 }
  $tokenValue = Get-TokenFromText ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $TokenFile).ProviderPath, [Text.Encoding]::UTF8))
}
if ([string]::IsNullOrEmpty($tokenValue)) { $tokenValue = $env:GITHUB_TOKEN }
if ([string]::IsNullOrEmpty($tokenValue)) { $tokenValue = $env:GH_TOKEN }
if ([string]::IsNullOrEmpty($tokenValue) -and -not $DryRun) { [Console]::Error.WriteLine('缺少令牌'); exit 1 }

# ---------- 文件清单 ----------
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

if ($DryRun) {
  Write-Host '== DRY RUN ==' -ForegroundColor Cyan
  Write-Host "目标: github.com/$Owner/$Repo   base=$Base  branch=$Branch"
  Write-Host "标题: $Title"
  Write-Host "下一步: $Next"
  if (-not [string]::IsNullOrWhiteSpace($NotDoing)) { Write-Host "非目标: $NotDoing" }
  Write-Host "文件: $($files.Count) 个，$([math]::Round((($files | Measure-Object size -Sum).Sum / 1KB), 1)) KB"
  exit 0
}

$base_ = 'https://api.github.com'
$headers = @{
  'Authorization'        = "Bearer $tokenValue"
  'Accept'               = 'application/vnd.github+json'
  'User-Agent'           = 'agent-ready-repo-spec-publisher'
  'X-GitHub-Api-Version' = '2022-11-28'
}

function Invoke-Gh {
  param([string]$Method, [string]$Path, $Body = $null, [switch]$AllowFail)
  $p = @{ Uri = "$base_$Path"; Method = $Method; Headers = $headers; ErrorAction = 'Stop' }
  if ($null -ne $Body) {
    $json = $Body | ConvertTo-Json -Depth 12 -Compress
    $p['Body'] = [Text.Encoding]::UTF8.GetBytes($json)
    $p['ContentType'] = 'application/json; charset=utf-8'
  }
  try { return Invoke-RestMethod @p }
  catch {
    $detail = ''
    try { if ($_.ErrorDetails.Message) { $detail = $_.ErrorDetails.Message } } catch { }
    if ($AllowFail) { return [pscustomobject]@{ __error = $detail; __code = $_.Exception.Response.StatusCode.value__ } }
    [Console]::Error.WriteLine("API 失败 $Method $Path`n$detail"); exit 2
  }
}

$me = Invoke-Gh GET '/user'
if ([string]::IsNullOrEmpty($Owner)) { $Owner = $me.login }
Write-Host "已认证: $($me.login)   目标: $Owner/$Repo" -ForegroundColor Green

# ---------- 基准提交 ----------
$baseRef = Invoke-Gh GET "/repos/$Owner/$Repo/git/ref/heads/$Base"
$baseSha = $baseRef.object.sha
Write-Host "base $Base = $($baseSha.Substring(0,7))"

# ---------- blob / tree / commit ----------
$tree = @(); $i = 0
foreach ($f in $files) {
  $i++
  $b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($f.full))
  $blob = Invoke-Gh POST "/repos/$Owner/$Repo/git/blobs" @{ content = $b64; encoding = 'base64' }
  $tree += @{ path = $f.rel; mode = '100644'; type = 'blob'; sha = $blob.sha }
  Write-Progress -Activity '上传文件' -Status $f.rel -PercentComplete ([int](100 * $i / $files.Count))
}
Write-Progress -Activity '上传文件' -Completed

$treeResp = Invoke-Gh POST "/repos/$Owner/$Repo/git/trees" @{ tree = $tree }
$commit = Invoke-Gh POST "/repos/$Owner/$Repo/git/commits" @{
  message = "$Message`n`n下一步：$Next"
  tree    = $treeResp.sha
  parents = @($baseSha)
}
Write-Host "已建提交 $($commit.sha.Substring(0,7))（$($files.Count) 个文件）"

$branchFull = $Branch -replace '^refs/heads/', ''
$newRef = Invoke-Gh POST "/repos/$Owner/$Repo/git/refs" @{ ref = "refs/heads/$branchFull"; sha = $commit.sha } -AllowFail
if ($newRef.__error) {
  # 分支已存在：直接把它移到新提交
  Invoke-Gh PATCH "/repos/$Owner/$Repo/git/refs/heads/$branchFull" @{ sha = $commit.sha; force = $true } | Out-Null
  Write-Host "分支已存在，已更新: $branchFull" -ForegroundColor Yellow
}
else { Write-Host "已建分支: $branchFull" }

# ---------- 开 PR ----------
if ([string]::IsNullOrEmpty($Body)) {
  $notDoing = if ([string]::IsNullOrWhiteSpace($NotDoing)) { '未声明（如无特别排除项可忽略这一节）' } else { $NotDoing }
  $Body = @"
## 改了什么
$Title

## 下一步
$Next

## 非目标
$notDoing

## 怎么验证的
- 本地：``checker/spec-check.ps1`` + ``tests/selftest.ps1``
- 本 PR 的 CI 结果见下方 checks

> 由 ``tools/publish-pr.ps1`` 生成（ADR-0005：下一步为必填项）。
"@
}
$pr = Invoke-Gh POST "/repos/$Owner/$Repo/pulls" @{
  title = $Title; head = $branchFull; base = $Base; body = $Body; draft = [bool]$Draft
}
Write-Host "已开 PR #$($pr.number): $($pr.html_url)" -ForegroundColor Cyan

if ($NoMerge -or $Draft) { Write-Host '按要求不自动合并。' -ForegroundColor Yellow; exit 0 }

# ---------- 等检查 ----------
$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$merged = $false
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Seconds 15
  $runs = Invoke-Gh GET "/repos/$Owner/$Repo/commits/$($commit.sha)/check-runs" -AllowFail
  if ($runs.__error) { continue }
  $all = @($runs.check_runs)
  if ($all.Count -eq 0) { Write-Host '  等待检查启动…'; continue }

  $done = @($all | Where-Object { $_.status -eq 'completed' })
  $bad = @($done | Where-Object { $_.conclusion -notin @('success', 'neutral', 'skipped') })
  $line = ($all | ForEach-Object { "$($_.name)=$($_.status)/$($_.conclusion)" }) -join '  '
  Write-Host "  [$($done.Count)/$($all.Count)] $line"

  if ($bad.Count -gt 0) {
    [Console]::Error.WriteLine("检查未通过：" + (($bad | ForEach-Object { $_.name }) -join ', '))
    [Console]::Error.WriteLine("PR 保持打开：$($pr.html_url)")
    exit 3
  }
  if ($done.Count -eq $all.Count) {
    $m = Invoke-Gh PUT "/repos/$Owner/$Repo/pulls/$($pr.number)/merge" @{
      merge_method  = $MergeMethod
      commit_title  = "$Title (#$($pr.number))"
      commit_message = "下一步：$Next"
    } -AllowFail
    if ($m.__error) {
      [Console]::Error.WriteLine("合并失败（可能被分支保护挡住）: $($m.__error)")
      [Console]::Error.WriteLine("PR 保持打开：$($pr.html_url)")
      exit 3
    }
    Write-Host "已合并 #$($pr.number) → $($m.sha.Substring(0,7))" -ForegroundColor Green
    $merged = $true
    break
  }
}

if (-not $merged) { [Console]::Error.WriteLine("等待超时（$TimeoutMinutes 分钟）。PR 仍在：$($pr.html_url)"); exit 3 }
Write-Host "完成：$($pr.html_url)"
exit 0
