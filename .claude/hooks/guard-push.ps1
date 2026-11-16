# PreToolUse · matcher: Bash
# 唯一值得写脚本的场景：语义判断。声明式规则只能匹配命令前缀，管不了参数中间。
# 拦"force push 到 main"，放行"推 feature 分支"。
#
# 契约：stdin 收 JSON（session_id / tool_name / tool_input），违规时写 stderr 并 exit 2。

$evt = [Console]::In.ReadToEnd() | ConvertFrom-Json
$cmd = $evt.tool_input.command
if ([string]::IsNullOrWhiteSpace($cmd)) { exit 0 }
if ($cmd -notmatch 'git\s+push') { exit 0 }

$isForce = ($cmd -match '--force(-with-lease)?(\s|$)') -or ($cmd -match '(^|\s)-f(\s|$)')
$hitsMain = $cmd -match '(\s|:)(main|master)(\s|$)|HEAD:refs/heads/(main|master)'

if ($isForce -and $hitsMain) {
    [Console]::Error.WriteLine(
        "禁止 force push 到 main/master。`n" +
        "改用新分支 + PR；确需重写历史请联系 owner 手动执行。`n" +
        "依据 AGENTS.md#禁区。")
    exit 2
}

exit 0
