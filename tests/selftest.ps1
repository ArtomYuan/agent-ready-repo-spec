# 引擎自测：构造临时 fixture，断言检查器的行为
# 用法：pwsh ./tests/selftest.ps1 [-Keep]
# -Keep 保留临时目录，便于排查

[CmdletBinding()]
param([switch]$Keep)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$checker = Join-Path $repo 'checker/spec-check.ps1'
$genDoc = Join-Path $repo 'checker/gen-rules-doc.ps1'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$script:pass = 0
$script:fail = 0

function Assert($name, $cond, $detail = '') {
  if ($cond) { $script:pass++; Write-Host "  [ok]   $name" -ForegroundColor DarkGray }
  else { $script:fail++; Write-Host "  [FAIL] $name  $detail" -ForegroundColor Red }
}

function New-Fixture($base, $name, $files) {
  $dir = Join-Path $base $name
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  foreach ($rel in $files.Keys) {
    $p = Join-Path $dir $rel
    $parent = Split-Path -Parent $p
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    [System.IO.File]::WriteAllText($p, $files[$rel], $utf8NoBom)
  }
  return $dir
}

function Invoke-Spec($path, $failOn = 'must', [switch]$Git) {
  $prm = @{ Target = $path; Level = 3; Format = 'json'; FailOn = $failOn }
  if ($Git) { $prm['Git'] = $true }
  $raw = & $checker @prm 2>$null
  $code = $LASTEXITCODE
  return @{ code = $code; json = (($raw -join "`n") | ConvertFrom-Json) }
}

function Get-Rule($json, $id) {
  return @($json.results | Where-Object { $_.id -eq $id })[0]
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("spec-selftest-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

try {
  # ---------- fixture 1：合格仓库，L3 应全绿 ----------
  Write-Host 'fixture: good（应达成 L3）' -ForegroundColor Cyan
  $good = New-Fixture $tmp 'good' @{
    'README.md' = "# fixture`n`n一个用于自测的仓库。`n"
    'AGENTS.md' = @'
# AGENTS.md

## 项目是什么

自测用仓库。

## 命令（唯一权威）

| 用途 | 命令 |
|---|---|
| 测试 | `echo ok` |

## 目录地图

- `docs/` — 文档

## 硬约定

- 提交信息用 Conventional Commits

## 禁区

- 不执行删除操作

## 已知的坑

- 无
'@
    '.gitignore' = ".claude/settings.local.json`nCLAUDE.local.md`n.env`n"
    'LICENSE' = "MIT License`n`nCopyright (c) 2026 fixture`n"
    '.editorconfig' = "root = true`n"
    '.gitattributes' = "* text=auto eol=lf`n"
    '.github/workflows/ci.yml' = "name: ci`non: [push]`njobs: {}\n"
    '.github/CODEOWNERS' = "* @org/maintainers`n"
    '.github/PULL_REQUEST_TEMPLATE.md' = "## 自检清单`n`n- [ ] 已测试`n"
    '.github/ISSUE_TEMPLATE/bug.yml' = "name: Bug`ndescription: 报告问题`nbody: []`n"
    'CONTRIBUTING.md' = "# 贡献`n"
    'CHANGELOG.md' = "# Changelog`n`n## [Unreleased]`n"
    'SECURITY.md' = "# 安全`n"
    'CODE_OF_CONDUCT.md' = "# 行为准则`n"
    'docs/index.md' = "# 文档地图`n"
    'docs/adr/0001-use-fixture.md' = "# ADR-0001`n"
    '.claude/settings.json' = '{"permissions":{"deny":["Read(./.env)","Bash(rm *)"],"allow":[]},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -File .claude/hooks/g.ps1"}]}]}}'
    '.claude/hooks/g.ps1' = "# guard`nif (`$true) { exit 2 }`n"
    '.claude/skills/x/SKILL.md' = "---`nname: x`ndescription: 自测 skill`n---`n`n内容`n"
    'commitlint.config.js' = "module.exports = { extends: ['@commitlint/config-conventional'] };`n"
  }
  $r = Invoke-Spec $good
  $bad = @($r.json.results | Where-Object { -not $_.skipped -and -not $_.ok })
  Assert 'good: 无 FAIL' ($bad.Count -eq 0) ("失败项: " + (($bad | ForEach-Object { $_.id }) -join ','))
  Assert 'good: 达成 L3' ($r.json.achievedLevel -eq 3) "实际 $($r.json.achievedLevel)"
  Assert 'good: 退出码 0' ($r.code -eq 0) "实际 $($r.code)"
  Assert 'good: 得分 100' ($r.json.score -eq 100) "实际 $($r.json.score)"

  # ---------- fixture 2：空仓库，应大面积红 ----------
  Write-Host 'fixture: empty（应判红）' -ForegroundColor Cyan
  $empty = New-Fixture $tmp 'empty' @{ 'README.md' = "# 空仓库`n" }
  $r2 = Invoke-Spec $empty
  Assert 'empty: must 至少 4 项失败' ($r2.json.summary.must.fail -ge 4) "实际 $($r2.json.summary.must.fail)"
  Assert 'empty: 未达 L0' ($r2.json.achievedLevel -eq -1) "实际 $($r2.json.achievedLevel)"
  Assert 'empty: 退出码 1' ($r2.code -eq 1) "实际 $($r2.code)"

  # ---------- fixture 3：危险仓库，应精准命中 ----------
  Write-Host 'fixture: risky（应命中典型治理问题）' -ForegroundColor Cyan
  $longAgents = "# AGENTS.md`n`n## 命令`n`n- run`n`n## 禁区`n`n- nope`n"
  for ($i = 0; $i -lt 250; $i++) { $longAgents += "- 填充行 $i`n" }
  $longClaude = "# CLAUDE.md`n`n" + ((1..60 | ForEach-Object { "- 个人偏好 $_`n" }) -join '')

  $risky = New-Fixture $tmp 'risky' @{
    'README.md' = "# 危险仓库`n"
    'AGENTS.md' = $longAgents
    'CLAUDE.md' = $longClaude
    '.gitignore' = "node_modules/`n"
    '.claude/settings.local.json' = '{"permissions":{"allow":["Bash(*)"]}}'
  }
  $r3 = Invoke-Spec $risky
  Assert 'risky: R025 命中（settings.local.json 被提交）' ((Get-Rule $r3.json 'R025').ok -eq $false)
  Assert 'risky: R030 命中（AGENTS.md 超 200 行）' ((Get-Rule $r3.json 'R030').ok -eq $false)
  Assert 'risky: R033 命中（CLAUDE.md 不是薄层）' ((Get-Rule $r3.json 'R033').ok -eq $false)
  Assert 'risky: R036 命中（.gitignore 未排除个人配置）' ((Get-Rule $r3.json 'R036').ok -eq $false)

  # ---------- fixture 4：hook 指向不存在的脚本 ----------
  Write-Host 'fixture: broken-hook（应命中 R034）' -ForegroundColor Cyan
  $bh = New-Fixture $tmp 'broken-hook' @{
    'README.md' = "# x`n"
    '.claude/settings.json' = '{"permissions":{"deny":["Bash(rm *)"]},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh -File .claude/hooks/missing.ps1"}]}]}}'
  }
  $r4 = Invoke-Spec $bh
  Assert 'broken-hook: R034 命中（引用不存在）' ((Get-Rule $r4.json 'R034').ok -eq $false)

  # ---------- fixture 5：提交历史规则默认跳过 ----------
  Write-Host 'commit 规则（默认跳过）' -ForegroundColor Cyan
  Assert 'good: 默认不读历史，R050 跳过' ((Get-Rule $r.json 'R050').skipped -eq $true)
  Assert 'good: 默认不读历史，R051 跳过' ((Get-Rule $r.json 'R051').skipped -eq $true)
  $r5 = Invoke-Spec $good -Git
  Assert 'good + -Git（非 git 目录）：R050 仍跳过' ((Get-Rule $r5.json 'R050').skipped -eq $true)
  Assert 'good + -Git：不因跳过而扣分' ($r5.json.score -eq 100) "实际 $($r5.json.score)"
  Assert 'good + -Git：仍达成 L3' ($r5.json.achievedLevel -eq 3) "实际 $($r5.json.achievedLevel)"

  # ---------- 生成物一致性 ----------
  Write-Host '生成物一致性' -ForegroundColor Cyan
  & $genDoc -Check | Out-Null
  Assert 'RULES.md 与 rules.json 一致' ($LASTEXITCODE -eq 0) '运行 ./checker/gen-rules-doc.ps1 重新生成'
}
finally {
  if ($Keep) { Write-Host "临时目录保留: $tmp" -ForegroundColor Yellow }
  else { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
if ($script:fail -eq 0) {
  Write-Host "selftest 通过：$($script:pass) 项断言" -ForegroundColor Green
  exit 0
}
else {
  Write-Host "selftest 失败：$($script:fail) 项（通过 $($script:pass)）" -ForegroundColor Red
  exit 1
}
