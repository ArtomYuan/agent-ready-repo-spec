# 走 PR 流程发布（不需要 git 二进制）
#
# 与 publish-github.ps1 的区别：那个是直推 main，这个是
#   建分支 → 提交 → 开 PR → 等 CI → squash 合并
# 主分支开启保护后，**只有这条路**能进 main。
#
# 用法（认证一律走 GitHub App）：
#   ./tools/publish-pr.ps1 -Owner <owner> -AppId <id> -InstallationId <id> -PrivateKeyPath <pem> `
#                          -Message "docs: 修个错字" -Next "下一步"
#   ./tools/publish-pr.ps1 ... -NoMerge        # 只开 PR，不自动合并
#   ./tools/publish-pr.ps1 ... -DryRun         # 只看计划
#
# 退出码：0 已合并 / 1 参数或认证问题 / 2 API 失败 / 3 PR 已开但检查未通过、超时或被规则集挡住

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
  # 默认且推荐的认证方式：GitHub App（现场换 installation token，不落盘）
  [string]$PrivateKeyPath = '',
  [string]$AppId = '',
  [string]$InstallationId = '',
  # 临时兜底，不推荐；常规发布用上面三个参数
  [string]$Token = '',
  # 联合署名与 assignee 不写死任何人：留空 = 按仓库所属账号自动推导，写 none = 关闭
  [string]$CoAuthor = '',
  [string]$Assignee = '',
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

# ---------- 令牌：GitHub App 是唯一推荐路径 ----------
# 不再读 -TokenFile / $env:GITHUB_TOKEN：PAT 已废弃，取 token 的路子越多，
# "这次到底用的是谁的身份"就越说不清。要临时兜底就显式给 -Token。
$tokenValue = ''
if (-not [string]::IsNullOrEmpty($PrivateKeyPath) -and -not [string]::IsNullOrEmpty($AppId) -and -not [string]::IsNullOrEmpty($InstallationId)) {
  $minter = Join-Path $PSScriptRoot 'gh-app-token.ps1'
  if (-not (Test-Path -LiteralPath $minter)) { [Console]::Error.WriteLine("找不到 $minter"); exit 1 }
  $minted = & $minter -PrivateKeyPath $PrivateKeyPath -AppId $AppId -InstallationId $InstallationId -Export
  $tokenValue = ([string]$minted).Trim()
  if ([string]::IsNullOrEmpty($tokenValue)) { [Console]::Error.WriteLine('App token 换取失败（看 gh-app-token.ps1 的报错）'); exit 1 }
  Write-Host '认证: GitHub App（现场换 installation token，约 1 小时过期）' -ForegroundColor DarkGray
}
elseif (-not [string]::IsNullOrEmpty($Token)) {
  $tokenValue = $Token
  Write-Host '认证: 显式 -Token（临时用法，常规发布请改用 GitHub App）' -ForegroundColor Yellow
}
if ([string]::IsNullOrEmpty($tokenValue) -and -not $DryRun) {
  [Console]::Error.WriteLine('缺少认证信息。推荐（也是默认做法）：')
  [Console]::Error.WriteLine('  -AppId <appId> -InstallationId <installationId> -PrivateKeyPath <pem>')
  [Console]::Error.WriteLine('临时兜底：-Token <token>')
  exit 1
}

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

# installation token 调不了 /user；这时必须显式给 -Owner
$me = Invoke-Gh GET '/user' -AllowFail
if ($me.__error) {
  if ([string]::IsNullOrEmpty($Owner)) { [Console]::Error.WriteLine('当前是 App installation token，无法自动推断 Owner，请给 -Owner'); exit 1 }
  Write-Host "已认证: App installation token   目标: $Owner/$Repo" -ForegroundColor Green
}
else {
  if ([string]::IsNullOrEmpty($Owner)) { $Owner = $me.login }
  Write-Host "已认证: $($me.login)   目标: $Owner/$Repo" -ForegroundColor Green
}

# ---------- 联合署名与 assignee：从仓库所属账号推导，不写死名字 ----------
# 推导不出（组织账号）就明说，而不是随便填一个人。
$repoInfo = Invoke-Gh GET "/repos/$Owner/$Repo"
$accountLogin = $repoInfo.owner.login
$accountId = $repoInfo.owner.id
$accountType = $repoInfo.owner.type

if ($CoAuthor -eq 'none') { $CoAuthor = '' }
elseif ([string]::IsNullOrWhiteSpace($CoAuthor)) {
  if ($accountType -eq 'User') {
    $CoAuthor = "$accountLogin <$accountId+$accountLogin@users.noreply.github.com>"
  }
  else {
    Write-Host "所属账号是组织（$accountLogin），无法推导联合署名人；用 -CoAuthor 指定，或 -CoAuthor none 关闭" -ForegroundColor Yellow
  }
}
if ($Assignee -eq 'none') { $Assignee = '' }
elseif ([string]::IsNullOrWhiteSpace($Assignee) -and $accountType -eq 'User') { $Assignee = $accountLogin }

if (-not [string]::IsNullOrWhiteSpace($CoAuthor)) { Write-Host "联合署名: $CoAuthor" -ForegroundColor DarkGray }
if (-not [string]::IsNullOrWhiteSpace($Assignee)) { Write-Host "assignee: $Assignee" -ForegroundColor DarkGray }

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
  message = $(if ([string]::IsNullOrWhiteSpace($CoAuthor)) { "$Message`n`n下一步：$Next" } else { "$Message`n`n下一步：$Next`n`nCo-authored-by: $CoAuthor" })
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

$(if ([string]::IsNullOrWhiteSpace($Assignee)) { '' } else { "cc @$Assignee" })

> 由 ``tools/publish-pr.ps1`` 生成（ADR-0005：下一步为必填项）。
"@
}
$assigneeList = @(); if (-not [string]::IsNullOrWhiteSpace($Assignee)) { $assigneeList = @($Assignee) }

# 复用已存在的 PR（同一 head 分支）：失败重发时不该逼人去手动关 PR / 删分支
$headQuery = [uri]::EscapeDataString("$Owner`:$branchFull")
$pr = $null
$existing = Invoke-Gh GET "/repos/$Owner/$Repo/pulls?state=open&head=$headQuery" -AllowFail
if (-not $existing.__error -and @($existing).Count -gt 0) {
  $pr = @($existing)[0]
  Invoke-Gh PATCH "/repos/$Owner/$Repo/pulls/$($pr.number)" @{ title = $Title; body = $Body; assignees = $assigneeList } | Out-Null
  Write-Host "复用已开 PR #$($pr.number)（标题与正文已更新）: $($pr.html_url)" -ForegroundColor Yellow
}
else {
  $allPrs = Invoke-Gh GET "/repos/$Owner/$Repo/pulls?state=all&head=$headQuery" -AllowFail
  $closed = @()
  if (-not $allPrs.__error) { $closed = @($allPrs | Where-Object { $_.state -eq 'closed' -and -not $_.merged_at }) }
  if ($closed.Count -gt 0) {
    $pr = $closed[0]
    Invoke-Gh PATCH "/repos/$Owner/$Repo/pulls/$($pr.number)" @{ state = 'open'; title = $Title; body = $Body; assignees = $assigneeList } | Out-Null
    Write-Host "重开既有 PR #$($pr.number)（标题与正文已更新）: $($pr.html_url)" -ForegroundColor Yellow
  }
  else {
    $pr = Invoke-Gh POST "/repos/$Owner/$Repo/pulls" @{
      title = $Title; head = $branchFull; base = $Base; body = $Body; draft = [bool]$Draft; assignees = $assigneeList
    }
    Write-Host "已开 PR #$($pr.number): $($pr.html_url)" -ForegroundColor Cyan
  }
}

if ($NoMerge -or $Draft) { Write-Host '按要求不自动合并。' -ForegroundColor Yellow; exit 0 }

# assignee：POST /pulls 里的 assignees 字段实测被忽略，这里显式补一次（幂等）
if (-not [string]::IsNullOrWhiteSpace($Assignee)) {
  $as = Invoke-Gh POST "/repos/$Owner/$Repo/issues/$($pr.number)/assignees" @{ assignees = @($Assignee) } -AllowFail
  if ($as.__error) { Write-Host "设 assignee 失败（不影响 PR）: $($as.__error)" -ForegroundColor Yellow }
  else { Write-Host "已设 assignee: $Assignee" -ForegroundColor DarkGray }
}

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
