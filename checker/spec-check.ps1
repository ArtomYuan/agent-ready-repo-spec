<#
.SYNOPSIS
  按 agent-ready-repo-spec 对任意仓库做规范体检。

.DESCRIPTION
  读取 rules/rules.json（唯一事实源），逐条检查目标仓库，输出 text / json / md。
  退出码：0 通过；1 有未通过项（按 -FailOn 判定）；2 运行错误（目标不存在、规则无法解析）。

.EXAMPLE
  pwsh ./checker/spec-check.ps1 -Target ../my-repo

.EXAMPLE
  pwsh ./checker/spec-check.ps1 -Target . -Level 2 -Format json -FailOn should
#>
[CmdletBinding()]
param(
  [string]$Target = ".",
  [ValidateRange(0, 3)][int]$Level = 3,
  [ValidateSet('text', 'json', 'md')][string]$Format = 'text',
  [ValidateSet('must', 'should', 'none')][string]$FailOn = 'must',
  [string]$RulesPath = '',
  [switch]$NoColor,
  [switch]$Git
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrEmpty($RulesPath)) {
  $RulesPath = Join-Path $PSScriptRoot '../rules/rules.json'
}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$Utf8 = [System.Text.Encoding]::UTF8
$Rank = @{ 'must' = 3; 'should' = 2; 'may' = 1 }
$Weight = @{ 'must' = 5; 'should' = 2; 'may' = 1 }

function Read-Text([string]$path) {
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
  return [System.IO.File]::ReadAllText([System.IO.Path]::GetFullPath($path), $Utf8)
}

function Get-GitExe {
  $c = Get-Command git -ErrorAction SilentlyContinue
  if ($c) { return $c.Source }
  return $null
}

function Invoke-Git([string]$root, [string[]]$gitArgs) {
  $exe = Get-GitExe
  if (-not $exe) { return $null }
  # 先判 .git，避免在非仓库上白跑一次 git（也避免 PS 5.1 把 native stderr 当终止错误）
  if (-not (Test-Path -LiteralPath (Join-Path $root '.git'))) { return $null }
  $prevEap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $out = & $exe -C $root @gitArgs 2>&1
    if ($LASTEXITCODE -ne 0) { return $null }
    return @($out | Where-Object { $null -ne $_ -and "$_" -ne '' } | ForEach-Object { "$_" })
  }
  catch { return $null }
  finally { $ErrorActionPreference = $prevEap }
}

function Get-Frontmatter([string]$text) {
  $fm = @{}
  if ([string]::IsNullOrEmpty($text)) { return $fm }
  $lines = $text -split "`r?`n"

  # 情况 A：--- 围栏（SKILL.md / Markdown 指令文件）
  if ($lines.Count -ge 3 -and $lines[0].Trim() -eq '---') {
    for ($i = 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i].Trim() -eq '---') { break }
      if ($lines[$i] -match '^([A-Za-z0-9_-]+)\s*:\s*(.*)$') {
        $fm[$Matches[1]] = $Matches[2].Trim()
      }
    }
    return $fm
  }

  # 情况 B：纯 YAML（GitHub issue forms 的 *.yml 没有 --- 围栏）
  foreach ($ln in $lines) {
    if ($ln -match '^([A-Za-z][A-Za-z0-9_-]*)\s*:') {
      $k = $Matches[1]
      if (-not $fm.ContainsKey($k)) { $fm[$k] = '' }
    }
  }
  return $fm
}

function Get-JsonDepth($obj, [string[]]$segments, [int]$i = 0) {
  if ($null -eq $obj) { return $null }
  if ($i -ge $segments.Count) { return $obj }
  $name = $segments[$i]
  $prop = $obj.PSObject.Properties[$name]
  if ($null -eq $prop) { return $null }
  return Get-JsonDepth $prop.Value $segments ($i + 1)
}

function Test-Rule($rule, [string]$root) {
  $c = $rule.check
  $kind = $c.kind
  $res = @{ ok = $false; detail = ''; skip = $false }

  switch ($kind) {

    'file-exists' {
      $found = @()
      foreach ($rel in $c.any) {
        $p = Join-Path $root $rel
        if (Test-Path -LiteralPath $p -PathType Leaf) {
          if ($c.nonEmpty -and (([System.IO.File]::ReadAllBytes($p)).Length -eq 0)) { continue }
          $found += $rel
        }
      }
      $res.ok = ($found.Count -gt 0)
      $res.detail = if ($res.ok) { "找到: $($found[0])" } else { "缺失: $($c.any -join ' / ')" }
    }

    'file-absent' {
      $bad = @()
      foreach ($rel in $c.any) { if (Test-Path -LiteralPath (Join-Path $root $rel)) { $bad += $rel } }
      $res.ok = ($bad.Count -eq 0)
      $res.detail = if ($res.ok) { '未发现' } else { "不该存在: $($bad -join ', ')" }
    }

    'file-max-lines' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $true; $res.detail = '文件不存在，跳过' }
      else {
        $n = ($t -split "`r?`n").Count
        $res.ok = ($n -le $c.max)
        $res.detail = "$n 行（上限 $($c.max)）"
      }
    }

    'file-limit' {
      # 满足其一即可：命中 regex，或行数 <= max
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $true; $res.detail = '文件不存在，跳过' }
      elseif ($t -match $c.regex) { $res.ok = $true; $res.detail = "命中 $($c.regex)" }
      else {
        $n = ($t -split "`r?`n").Count
        $res.ok = ($n -le $c.max)
        $res.detail = if ($res.ok) { "$n 行" } else { "$n 行且未导入 AGENTS.md（上限 $($c.max)）" }
      }
    }

    'file-contains' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $false; $res.detail = "文件不存在: $($c.file)" }
      else {
        $m = [regex]::IsMatch($t, $c.regex, 'Multiline')
        $res.ok = $m
        $res.detail = if ($m) { "命中 $($c.regex)" } else { "未匹配 $($c.regex)" }
      }
    }

    'file-not-contains' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $true; $res.detail = '文件不存在，跳过' }
      else {
        $m = [regex]::IsMatch($t, $c.regex)
        $res.ok = (-not $m)
        $res.detail = if ($m) { "含占位内容: $($c.regex)" } else { '干净' }
      }
    }

    'dir-min-files' {
      $d = Join-Path $root $c.dir
      if (-not (Test-Path -LiteralPath $d -PathType Container)) {
        $res.ok = $false; $res.detail = "目录不存在: $($c.dir)"
      }
      else {
        $files = @(Get-ChildItem -LiteralPath $d -File -Filter $c.pattern -ErrorAction SilentlyContinue)
        $res.ok = ($files.Count -ge $c.min)
        $res.detail = "$($files.Count) 个匹配（要求 >= $($c.min)）"
      }
    }

    'json-nonempty' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $false; $res.detail = "文件不存在: $($c.file)" }
      else {
        try { $obj = $t | ConvertFrom-Json } catch { $res.ok = $false; $res.detail = 'JSON 解析失败'; break }
        $val = Get-JsonDepth $obj ($c.path -split '\.')
        if ($null -eq $val) { $res.ok = $false; $res.detail = "缺少 $($c.path)" }
        else {
          $cnt = @($val).Count
          $res.ok = ($cnt -gt 0)
          $res.detail = "$($c.path) 有 $cnt 项"
        }
      }
    }

    'json-hook-scripts-exist' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $true; $res.detail = '文件不存在，跳过' }
      else {
        $missing = @()
        $refs = [regex]::Matches($t, '\.claude/hooks/[A-Za-z0-9._\-]+')
        foreach ($m in $refs) {
          $rel = $m.Value
          if (-not (Test-Path -LiteralPath (Join-Path $root $rel) -PathType Leaf)) { $missing += $rel }
        }
        $res.ok = ($missing.Count -eq 0)
        $res.detail = if ($res.ok) { "$($refs.Count) 处引用全部存在" } else { "引用不存在: $($missing -join ', ')" }
      }
    }

    'frontmatter-fields' {
      $d = Join-Path $root $c.dir
      if (-not (Test-Path -LiteralPath $d -PathType Container)) { $res.ok = $true; $res.detail = '目录不存在，跳过'; break }
      $files = @(Get-ChildItem -LiteralPath $d -File -Filter $c.pattern -Recurse -ErrorAction SilentlyContinue)
      if ($c.exclude) { $files = @($files | Where-Object { $c.exclude -notcontains $_.Name }) }
      if ($files.Count -eq 0) { $res.ok = $true; $res.detail = '无匹配文件，跳过'; break }
      $bad = @()
      foreach ($f in $files) {
        $fm = Get-Frontmatter (Read-Text $f.FullName)
        $miss = @()
        foreach ($k in $c.fields) { if (-not $fm.ContainsKey($k)) { $miss += $k } }
        if ($c.fieldsOneOf) {
          foreach ($group in $c.fieldsOneOf) {
            $hit = $false
            foreach ($k in $group) { if ($fm.ContainsKey($k)) { $hit = $true } }
            if (-not $hit) { $miss += ($group -join '|') }
          }
        }
        if ($miss.Count -gt 0) { $bad += "$($f.Name)[$($miss -join ',')]" }
      }
      $res.ok = ($bad.Count -eq 0)
      $res.detail = if ($res.ok) { "$($files.Count) 个文件字段齐全" } else { "缺字段: $($bad -join '; ')" }
    }

    'name-pattern' {
      $d = Join-Path $root $c.dir
      if (-not (Test-Path -LiteralPath $d -PathType Container)) { $res.ok = $true; $res.detail = '目录不存在，跳过'; break }
      $files = @(Get-ChildItem -LiteralPath $d -File -Filter $c.pattern -ErrorAction SilentlyContinue)
      if ($files.Count -eq 0) { $res.ok = $true; $res.detail = '无匹配文件，跳过'; break }
      $bad = @($files | Where-Object { -not [regex]::IsMatch($_.Name, $c.regex) } | ForEach-Object { $_.Name })
      $res.ok = ($bad.Count -eq 0)
      $res.detail = if ($res.ok) { "$($files.Count) 个文件名合规" } else { "不合规: $($bad -join ', ')" }
    }

    'dir-contains' {
      $d = Join-Path $root $c.dir
      if (-not (Test-Path -LiteralPath $d -PathType Container)) { $res.ok = $true; $res.detail = '目录不存在，跳过'; break }
      $files = @(Get-ChildItem -LiteralPath $d -File -Filter $c.pattern -Recurse -ErrorAction SilentlyContinue)
      if ($files.Count -eq 0) { $res.ok = $true; $res.detail = '无匹配文件，跳过'; break }
      $hit = @()
      foreach ($f in $files) { if ([regex]::IsMatch((Read-Text $f.FullName), $c.regex)) { $hit += $f.Name } }
      $res.ok = ($hit.Count -gt 0)
      $res.detail = if ($res.ok) { "命中: $($hit -join ', ')" } else { "$($files.Count) 个文件中均未匹配 $($c.regex)" }
    }

    'md-refs-exist' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.ok = $true; $res.detail = '文件不存在，跳过' }
      else {
        $tokens = @()
        foreach ($m in [regex]::Matches($t, '\]\(([^)]+)\)')) { $tokens += $m.Groups[1].Value }
        foreach ($m in [regex]::Matches($t, '`([^`\r\n]+)`')) { $tokens += $m.Groups[1].Value }
        $missing = @()
        $checked = 0
        $ignore = @()
        if ($c.PSObject.Properties['ignore']) { $ignore = @($c.ignore) }
        foreach ($tk in $tokens) {
          $s = $tk.Trim()
          if ($s -match '^(https?:|mailto:|#)') { continue }
          if ($s -match '[<>*${}|（）\s]') { continue }
          if ($ignore -contains $s) { continue }
          if ($s -match '^\.[A-Za-z0-9]+$') { continue }   # 纯扩展名，如 .ps1
          $s = ($s -split '#')[0]
          if ([string]::IsNullOrWhiteSpace($s)) { continue }
          $looksPath = ($s -match '/') -or ($s -match '\.(md|json|ps1|mjs|js|yml|yaml|toml|sh|txt|cff)$')
          if (-not $looksPath) { continue }
          if ($s.StartsWith('~')) { continue }
          $checked++
          if (-not (Test-Path -LiteralPath (Join-Path $root $s))) { $missing += $s }
        }
        $res.ok = ($missing.Count -eq 0)
        $res.detail = if ($res.ok) { "检查 $checked 处引用，全部存在" } else { "失效引用: $(($missing | Select-Object -Unique) -join ', ')" }
      }
    }

    'json-forbid' {
      $p = Join-Path $root $c.file
      $t = Read-Text $p
      if ($null -eq $t) { $res.skip = $true; $res.detail = '文件不存在，跳过'; break }
      try { $obj = $t | ConvertFrom-Json } catch { $res.skip = $true; $res.detail = 'JSON 解析失败，跳过'; break }
      $bad = @()
      foreach ($chk in $c.checks) {
        $val = Get-JsonDepth $obj ($chk.path -split '\.')
        if ($null -eq $val) { continue }
        foreach ($f in $chk.forbid) {
          if ($val -is [bool]) { if ($val -eq [bool]$f) { $bad += "$($chk.path)=$val" } }
          elseif ("$val" -eq "$f") { $bad += "$($chk.path)='$val'" }
        }
      }
      $res.ok = ($bad.Count -eq 0)
      $res.detail = if ($res.ok) { '归属未被关闭' } else { "被关闭: $($bad -join ', ')" }
    }

    'git-commit-subject' {
      $depth = 50
      if ($c.PSObject.Properties['depth']) { $depth = [int]$c.depth }
      $subjects = Invoke-Git $root @('log', "-n$depth", '--pretty=format:%s')
      if ($null -eq $subjects) { $res.skip = $true; $res.detail = 'git 不可用或不是 git 仓库，跳过'; break }
      if ($subjects.Count -eq 0) { $res.skip = $true; $res.detail = '仓库还没有提交，跳过'; break }
      $maxLen = 72
      if ($c.PSObject.Properties['maxLength']) { $maxLen = [int]$c.maxLength }
      $bad = @()
      foreach ($s in $subjects) {
        if (-not [regex]::IsMatch($s, $c.regex)) { $bad += "格式:$s" }
        elseif ($s.Length -gt $maxLen) { $bad += "太长($($s.Length)):$s" }
      }
      $res.ok = ($bad.Count -eq 0)
      $res.detail = if ($res.ok) { "最近 $($subjects.Count) 条提交全部合规" } else { "不合规 $($bad.Count)/$($subjects.Count) 条，例：$($bad[0])" }
    }

    'git-commit-no-merge' {
      $depth = 50
      if ($c.PSObject.Properties['depth']) { $depth = [int]$c.depth }
      $all = Invoke-Git $root @('log', "-n$depth", '--pretty=format:%s')
      if ($null -eq $all) { $res.skip = $true; $res.detail = 'git 不可用或不是 git 仓库，跳过'; break }
      if ($all.Count -eq 0) { $res.skip = $true; $res.detail = '仓库还没有提交，跳过'; break }
      $merges = Invoke-Git $root @('log', "-n$depth", '--merges', '--pretty=format:%h %s')
      $mc = 0; if ($null -ne $merges) { $mc = $merges.Count }
      $res.ok = ($mc -eq 0)
      $res.detail = if ($res.ok) { "最近 $($all.Count) 条提交无 merge" } else { "发现 $mc 个 merge commit，例：$($merges[0])" }
    }

    default { $res.ok = $false; $res.detail = "未知检查类型: $kind" }
  }

  return $res
}

# ---------- main ----------

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
  [Console]::Error.WriteLine("目标目录不存在: $Target")
  exit 2
}
$root = [System.IO.Path]::GetFullPath($Target)

if (-not (Test-Path -LiteralPath $RulesPath -PathType Leaf)) {
  [Console]::Error.WriteLine("规则文件不存在: $RulesPath")
  exit 2
}
try { $spec = (Read-Text $RulesPath) | ConvertFrom-Json }
catch { [Console]::Error.WriteLine("规则文件解析失败: $($_.Exception.Message)"); exit 2 }

$selected = @($spec.rules | Where-Object { $_.level -le $Level })
$results = @()
foreach ($r in $selected) {
  $skip = $false; $skipReason = ''
  $requires = ''
  if ($r.PSObject.Properties['requires']) { $requires = [string]$r.requires }
  if ($requires -eq 'git') {
    if (-not $Git) { $skip = $true; $skipReason = '需要 -Git（默认不读提交历史）' }
    elseif (-not (Get-GitExe)) { $skip = $true; $skipReason = 'git 不可用' }
  }
  if ($skip) {
    $results += [pscustomobject]@{
      id = $r.id; level = $r.level; severity = $r.severity; title = $r.title
      ok = $false; skipped = $true; detail = $skipReason; fix = $r.fix; rationale = $r.rationale
    }
    continue
  }
  $out = Test-Rule $r $root
  $skippedNow = [bool]$out.skip
  $results += [pscustomobject]@{
    id = $r.id; level = $r.level; severity = $r.severity; title = $r.title
    ok = [bool]$out.ok; skipped = $skippedNow; detail = $out.detail; fix = $r.fix; rationale = $r.rationale
  }
}

$bySeverity = @{}
foreach ($s in 'must', 'should', 'may') {
  $set = @($results | Where-Object { $_.severity -eq $s -and -not $_.skipped })
  $pass = @($set | Where-Object { $_.ok }).Count
  $bySeverity[$s] = @{ total = $set.Count; pass = $pass; fail = ($set.Count - $pass) }
}
$skippedCount = @($results | Where-Object { $_.skipped }).Count
$totalW = 0; $passW = 0
foreach ($r in $results) { if ($r.skipped) { continue }; $w = $Weight[$r.severity]; $totalW += $w; if ($r.ok) { $passW += $w } }
$score = if ($totalW -gt 0) { [int][math]::Round(100 * $passW / $totalW) } else { 100 }

$achieved = -1
for ($l = 0; $l -le $Level; $l++) {
  $blocking = @($results | Where-Object { $_.level -le $l -and $_.severity -ne 'may' -and -not $_.skipped -and -not $_.ok })
  if ($blocking.Count -eq 0) { $achieved = $l } else { break }
}

$threshold = switch ($FailOn) { 'must' { 3 } 'should' { 2 } default { 0 } }
$fails = @($results | Where-Object { -not $_.skipped -and -not $_.ok -and $Rank[$_.severity] -ge $threshold -and $threshold -gt 0 })
$exit = if ($fails.Count -gt 0) { 1 } else { 0 }

if ($Format -eq 'json') {
  $payload = [pscustomobject]@{
    specVersion = $spec.specVersion
    target = $root
    level = $Level
    score = $score
    achievedLevel = $achieved
    skipped = $skippedCount
    summary = $bySeverity
    results = $results
  }
  $payload | ConvertTo-Json -Depth 8
  exit $exit
}

if ($Format -eq 'md') {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine("# 规范体检报告")
  [void]$sb.AppendLine('')
  [void]$sb.AppendLine("- 目标：``$root``")
  [void]$sb.AppendLine("- 规范版本：$($spec.specVersion) · 检查到 L$Level")
  [void]$sb.AppendLine("- 得分：**$score / 100** · 达成等级：**$(if ($achieved -lt 0) { '未达 L0' } else { "L$achieved" })**")
  foreach ($s in 'must', 'should', 'may') {
    $x = $bySeverity[$s]
    [void]$sb.AppendLine("- $s：$($x.pass)/$($x.total) 通过")
  }
  [void]$sb.AppendLine('')
  [void]$sb.AppendLine('| 规则 | 级别 | 严重度 | 结果 | 说明 |')
  [void]$sb.AppendLine('|---|---|---|---|---|')
  foreach ($r in $results) {
    $mark = if ($r.skipped) { 'SKIP' } elseif ($r.ok) { 'PASS' } else { 'FAIL' }
    [void]$sb.AppendLine("| $($r.id) $($r.title) | L$($r.level) | $($r.severity) | $mark | $($r.detail) |")
  }
  $bad = @($results | Where-Object { -not $_.ok })
  if ($bad.Count -gt 0) {
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('## 修复建议')
    foreach ($r in $bad) { [void]$sb.AppendLine("- **$($r.id)**：$($r.fix)") }
  }
  $sb.ToString()
  exit $exit
}

# text
$useColor = -not $NoColor
function Write-Line([string]$text, [string]$color = '') {
  if ($useColor -and $color) { Write-Host $text -ForegroundColor $color } else { Write-Host $text }
}
Write-Line "spec-check $($spec.specVersion)  target: $root  (检查到 L$Level)" 'Cyan'
Write-Line ''
foreach ($l in 0..$Level) {
  $group = @($results | Where-Object { $_.level -eq $l })
  if ($group.Count -eq 0) { continue }
  Write-Line "L$l — $($spec.levels.($l.ToString()))" 'DarkGray'
  foreach ($r in $group) {
    if ($r.skipped) {
      Write-Line ("  [skip] {0,-5} {1}  ({2})" -f $r.id, $r.title, $r.detail) 'DarkGray'
    }
    elseif ($r.ok) {
      Write-Line ("  [ok]   {0,-5} {1}" -f $r.id, $r.title) 'DarkGray'
    }
    else {
      Write-Line ("  [FAIL] {0,-5} {1}  ({2})" -f $r.id, $r.title, $r.severity) 'Red'
      Write-Line ("         > {0}" -f $r.detail) 'Red'
      Write-Line ("         fix: {0}" -f $r.fix) 'Yellow'
    }
  }
  Write-Line ''
}
$fb = if ($achieved -lt 0) { '未达 L0' } else { "L$achieved" }
Write-Line ("must {0}/{1}   should {2}/{3}   may {4}/{5}   skipped {6}   score {7}/100   达成 {8}" -f `
    $bySeverity['must'].pass, $bySeverity['must'].total,
    $bySeverity['should'].pass, $bySeverity['should'].total,
    $bySeverity['may'].pass, $bySeverity['may'].total,
    $skippedCount,
    $score, $fb) 'Cyan'
if ($skippedCount -gt 0) { Write-Line "（skipped 项需要 -Git 且目标为 git 仓库；不计入分数与达成等级）" 'DarkGray' }
if ($exit -ne 0) { Write-Line "未通过（fail-on: $FailOn）" 'Red' } else { Write-Line "通过（fail-on: $FailOn）" 'Green' }
exit $exit
