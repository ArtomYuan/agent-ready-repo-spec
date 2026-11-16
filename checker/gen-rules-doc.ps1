# 从 rules/rules.json 生成 spec/RULES.md
# 用法：
#   pwsh ./checker/gen-rules-doc.ps1          写入 spec/RULES.md
#   pwsh ./checker/gen-rules-doc.ps1 -Check   只校验是否最新（不一致则 exit 1）

[CmdletBinding()]
param(
  [string]$RulesPath = '',
  [string]$OutPath = '',
  [switch]$Check
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrEmpty($RulesPath)) { $RulesPath = Join-Path $PSScriptRoot '../rules/rules.json' }
if ([string]::IsNullOrEmpty($OutPath))   { $OutPath   = Join-Path $PSScriptRoot '../spec/RULES.md' }

$Utf8 = [System.Text.Encoding]::UTF8
$spec = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $RulesPath).ProviderPath, $Utf8) | ConvertFrom-Json

function Format-Check($c) {
  $parts = @("kind: ``$($c.kind)``")
  foreach ($p in $c.PSObject.Properties) {
    if ($p.Name -eq 'kind') { continue }
    $v = $p.Value
    if ($v -is [array]) {
      if ($v.Count -gt 0 -and $v[0] -is [array]) {
        $v = ($v | ForEach-Object { '(' + ($_ -join '|') + ')' }) -join ' '
      }
      else { $v = ($v -join ', ') }
    }
    $parts += "$($p.Name)=$v"
  }
  return ($parts -join ' · ')
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('# 规则表')
[void]$sb.AppendLine('')
[void]$sb.AppendLine("> 由 ``rules/rules.json`` 自动生成，**请勿手改**。规范版本 ``$($spec.specVersion)``。")
[void]$sb.AppendLine('> 重新生成：`pwsh ./checker/gen-rules-doc.ps1`')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('共 **' + $spec.rules.Count + '** 条规则。严重度 `must` / `should` / `may`；`may` 不阻断达成等级。')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('| 级别 | 含义 | 规则数 |')
[void]$sb.AppendLine('|---|---|---|')
foreach ($l in 0..3) {
  $n = @($spec.rules | Where-Object { $_.level -eq $l }).Count
  [void]$sb.AppendLine("| L$l | $($spec.levels.($l.ToString())) | $n |")
}
[void]$sb.AppendLine('')

foreach ($l in 0..3) {
  $group = @($spec.rules | Where-Object { $_.level -eq $l } | Sort-Object id)
  if ($group.Count -eq 0) { continue }
  [void]$sb.AppendLine("## L$l · $($spec.levels.($l.ToString()))")
  [void]$sb.AppendLine('')
  [void]$sb.AppendLine('| ID | 严重度 | 要求 | 判定 |')
  [void]$sb.AppendLine('|---|---|---|---|')
  foreach ($r in $group) {
    $title = $r.title -replace '\|', '\|'
    [void]$sb.AppendLine("| ``$($r.id)`` | $($r.severity) | $title | $(Format-Check $r.check) |")
  }
  [void]$sb.AppendLine('')
  [void]$sb.AppendLine('<details><summary>为什么 / 怎么改</summary>')
  [void]$sb.AppendLine('')
  foreach ($r in $group) {
    [void]$sb.AppendLine("- **$($r.id)** " + $r.rationale)
    [void]$sb.AppendLine("  - 修复：$($r.fix)")
  }
  [void]$sb.AppendLine('')
  [void]$sb.AppendLine('</details>')
  [void]$sb.AppendLine('')
}

$text = $sb.ToString().Replace("`r`n", "`n")   # 统一 LF：Windows 生成、Linux CI 校验，必须字节一致
$noBom = New-Object System.Text.UTF8Encoding($false)

if ($Check) {
  if (-not (Test-Path -LiteralPath $OutPath -PathType Leaf)) {
    [Console]::Error.WriteLine("生成物不存在: $OutPath")
    exit 1
  }
  $existing = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $OutPath).ProviderPath, $Utf8)
  if ($existing -ne $text) {
    [Console]::Error.WriteLine("spec/RULES.md 与 rules.json 不一致，请运行 ./checker/gen-rules-doc.ps1 后提交。")
    exit 1
  }
  Write-Host "生成物已是最新（$($spec.rules.Count) 条规则）。"
  exit 0
}

[System.IO.File]::WriteAllText($OutPath, $text, $noBom)
Write-Host "已写入 $OutPath（$($spec.rules.Count) 条规则）。"
exit 0
