# 证据 · 分支保护与"直推被拒"实测

- **采集时间**：2026-11-17
- **对象**：`ArtomYuan/agent-ready-repo-spec`
- **方法**：GitHub REST API（`branches/main/protection`、`git/refs`）

## 1. 保护设置（PUT 生效后回读）

```
enforce_admins             = True     ← 管理员（即 agent 用的 token）也不能绕过
required_pr_reviews        = True
approvals_required         = 0        ← 允许自己合并，但必须走 PR
required_status_checks     = True
contexts                   = 引擎自测 | 自己体检自己 | Windows + PowerShell 5.1 兼容 | 提交信息（commitlint）
allow_force_pushes         = False
allow_deletions            = False
conversation_resolution    = True
```

复现：

```powershell
$body = @{
  required_status_checks = @{ strict = $false; contexts = @('引擎自测','自己体检自己','Windows + PowerShell 5.1 兼容','提交信息（commitlint）') }
  enforce_admins = $true
  required_pull_request_reviews = @{ required_approving_review_count = 0; dismiss_stale_reviews = $false; require_code_owner_reviews = $false }
  restrictions = $null; allow_force_pushes = $false; allow_deletions = $false; required_conversation_resolution = $true
} | ConvertTo-Json -Depth 6
Invoke-RestMethod -Method PUT -Uri "https://api.github.com/repos/$owner/$repo/branches/main/protection" `
  -Headers $h -Body ([Text.Encoding]::UTF8.GetBytes($body)) -ContentType 'application/json; charset=utf-8'
```

## 2. 直推被拒（关键验证）

构造一个与 main **内容完全相同**的探针提交（树相同、仅父提交是 main head），然后尝试直接移动 main：

```
PATCH /repos/{owner}/{repo}/git/refs/heads/main  { sha: <probe>, force: false }
```

返回：

```json
HTTP 422
{"message":"Changes must be made through a pull request. 4 of 4 required status checks are expected.",
 "documentation_url":"https://docs.github.com/articles/about-protected-branches","status":"422"}
```

且 main 的 head **未变化**（`9b06a06` 之前之后相同）。

## 3. 从这段实测得出的三条规律

1. **required checks 绑定 head SHA**：分支上再推一个提交，之前的绿灯作废，必须重跑；
2. **`approvals = 0` 不等于"没有闸"**：仍然必须走 PR，只是不需要人批；
3. **改名即锁死**：报错里的 `4 of 4 … are expected` 是**具名 context**。
   把 CI 里某个 job 改名，对应 required check 永远等不到 → 合并被永久卡住。
   这既是保护（防止悄悄删检查），也是运维陷阱：**改 job 名必须同步改保护设置**。
