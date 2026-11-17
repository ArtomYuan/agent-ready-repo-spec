# tools/

三个脚本：**换 token**（`gh-app-token.ps1`）、**纯 API 发布**（`publish-pr.ps1`）、**仅首次引导**（`publish-github.ps1`）。
**正常发布走 git，不靠脚本**——脚本只解决"没有 git"和"引导空仓库"这两种处境。

## 推荐组合：GitHub App + Git

App 负责"能推"，**git 负责把流程落地**——分支、作者、联合署名、PR 正文，只有走 git/gh 才在历史里看得见。
一份可以直接粘给 agent 的完整规范：[templates/prompt-github-app-git.md.tmpl](../templates/prompt-github-app-git.md.tmpl)。

```powershell
# 1) 换 token（1 小时有效，每个任务换一次）
$env:GH_TOKEN = ./tools/gh-app-token.ps1 -PrivateKeyPath <pem> -AppId <appId> -InstallationId <id> -Export

# 2) 克隆 + 身份（账号开了邮箱隐私保护就必须用 noreply，否则 push 报 GH007）
git clone https://github.com/<owner>/<repo>.git
cd <repo>
git config user.name  "<AppName>[bot]"
git config user.email "<appId>+<AppName>[bot]@users.noreply.github.com"
git config core.autocrlf false

# 3) 分支 → 提交 → 推送（token 不进 remote URL）
git switch -c feat/xxxx origin/main
git add -A
git commit -m "feat(scope): ..." -m "Co-authored-by: <user> <<uid>+<user>@users.noreply.github.com>"
$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("x-access-token:$env:GH_TOKEN"))
git -c "http.extraheader=AUTHORIZATION: basic $basic" push origin HEAD:refs/heads/feat/xxxx

# 4) 开 PR：三个参数缺一不可
gh pr create --title "..." --base main --assignee <user> --body-file .git/PR_BODY.md
```

`--base` 锁目标主干、`--assignee` 强制指派、`--body-file` 避免 shell 吃掉正文里的 `@`。
正文里的 `@<user>` 必须是**纯文本**——不要转义、不要加引号、不要改成链接。

## 认证：GitHub App（唯一推荐路径）

```powershell
./tools/gh-app-token.ps1 -PrivateKeyPath <pem> -AppId <appId> -InstallationId <id> -Export
```

**为什么不保留 PAT 的路子**：取 token 的入口每多一个，"这次用的是谁的身份"就多一处说不清。
`-TokenFile`（正则从凭证文档里抓 `ghp_*`）与 `$env:GITHUB_TOKEN` 自动读取都已移除；
`publish-pr.ps1` 只认 App 三件套（推荐）或显式 `-Token`（临时兜底，会打黄色警告）。

**App token 没有 `/user`**：installation token 调不了 `GET /user`，此时**必须显式给 owner**。

## 没有 git 时：publish-pr.ps1（纯 API 兜底）

用 REST API 完成"分支 → 提交 → PR → 等 CI → 合并"，不需要 git 二进制。
产出与 git 流程等价（分支 + 一个提交 + PR），但**过程不在 `git log` 里留痕**，reviewer 也看不到中间提交。
所以：**有 git 就用 git**；只能在无 git 环境（沙箱、精简容器）里才用它。

```powershell
./tools/publish-pr.ps1 -Owner <owner> -AppId <appId> -InstallationId <id> -PrivateKeyPath <pem> `
  -Message "docs: 修个错字" -Next "补 03 章的反例"

./tools/publish-pr.ps1 ... -NoMerge    # 只开 PR，不自动合并
./tools/publish-pr.ps1 ... -DryRun     # 只看计划，不碰远端
```

行为：

1. 以目标分支最新提交为父提交，把整个工作树做成**一个提交**；
2. 建分支 `chore/MMdd-HHmm-<slug>`（`-Branch` 可指定；同名分支已存在时移动它）；
3. 提交信息末尾追加 `Co-authored-by`，PR 正文末尾 `cc @<assignee>` 并设 assignee；
   **两者都从仓库所属账号推导**（`GET /repos/{owner}/{repo}` 的 `owner.login` / `owner.id`），工具里不写死任何人的名字：
   - 所属账号是用户 → `<login> <<id>+<login>@users.noreply.github.com>`，assignee = `<login>`
   - 所属账号是组织 → 推导不出来，工具会明说，请你用 `-CoAuthor` / `-Assignee` 指定
   - `-CoAuthor none` / `-Assignee none` 关闭
4. 开 PR（标题 = `-Message`，Conventional Commits 形式，squash 后它就是主分支的提交信息）；
   正文固定四段：改了什么 / **下一步（`-Next`，必填）** / 非目标（`-NotDoing`，可选）/ 怎么验证的；
5. 轮询该提交的 check-runs，**全绿才合并**；任何失败 → 保留 PR 并给出退出码；
6. 默认 squash 合并。**注意**：仓库若启用了"需非最后推送者批准"的 ruleset，第 5 步会返回
   `405 New changes require approval from someone other than the last pusher`——这是治理生效，不是 bug。

退出码：`0` 已合并 / `1` 参数或认证问题 / `2` API 失败 / `3` 检查未过、超时或被规则集挡住（PR 仍在）。

`POST /pulls` 的 `assignees` 字段实测会被静默忽略，所以工具在开完 PR 后再显式
`POST /issues/<n>/assignees` 补一次（幂等）。

## gh-app-token.ps1（换 token）

用 GitHub App 私钥换 installation access token，**不依赖 git / gh / node / openssl**。

```powershell
./tools/gh-app-token.ps1 -PrivateKeyPath <pem> -AppId <appId> -InstallationId <id> -Verify   # 换取并验证身份
./tools/gh-app-token.ps1 -PrivateKeyPath <pem> -AppId <appId> -InstallationId <id> -Export   # 只输出 token
```

做法：PKCS#1 私钥 → 手工包成 PKCS#8 → `CngKey.Import` → `RSACng` 签 RS256 → JWT →
`POST /app/installations/<id>/access_tokens`。参数全必填，脚本里不写死任何本机路径。

**两个坑（都真实踩过）**：

1. **`iss` 必须是纯数字 App ID，不能是 Client ID**。Client ID 用于 OAuth 网页授权，拿来换 installation token 一律 401。
2. **时间戳不能用 `New-TimeSpan -Start ([datetime]'1970-01-01T00:00:00Z')`**：该字面量 `Kind=Local`，
   相减漏掉时区偏移，epoch 整整差 8 小时 → `iat` 落在 8 小时前 → GitHub 返回 `401 Bad credentials`。
   正确写法：`[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()`。
   **推论**：JWT 的"签名对不对"与"时间在不在窗口内"是两件独立的检查，只验签名会漏掉后者。

## publish-github.ps1（仅首次引导）

直推 main，**main 开启保护后它会失败**（这正是保护的意义）。保留它是因为：新仓库还没有任何提交时
GitHub 拒绝 git-blob API（409），需要一次引导提交；首次建库、还没有分支保护时用它把仓库建起来。

## 令牌权限

| 用途 | 最小权限 |
|---|---|
| 建仓库 | *Administration: Read and write* + *Contents: Read and write* |
| 走 PR 发布 | *Contents: Read and write* + *Pull requests: Read and write*（+ *Actions: Read* 读 check-runs） |
| 改仓库设置（自动删分支、分支保护） | 另需 *Administration: Read and write* |

> App token 缺 `administration` 时，`PATCH /repos/{owner}/{repo}` 会被**静默忽略**（返回 200 但值没变）。
> 改设置后必须 `GET` 一次确认生效。

## 安全约定

- 令牌只来自 App 私钥现场换取，或显式 `-Token`；不读环境变量、不读凭证文件、不写进任何文件。
- **不要把 token 拼进 remote URL**（会明文落到 `.git/config`）。用：
  `git -c "http.extraheader=AUTHORIZATION: basic <base64(x-access-token:$GH_TOKEN)>" push ...`
- 脚本不打印令牌；报错只回显 API 的 message。
- 上传前排除：`.git/`、`reports/`、`*.local.json`、`*.spec-report.*`。

## 发布之后仍是手动的部分（检查器看不到）

1. **分支保护 / ruleset**：`Require a pull request`、`Require status checks`、`Do not allow bypassing`。
2. **Actions 权限**：Settings → Actions → Workflow permissions 设为只读。
3. **私密漏洞上报**：Security → Private vulnerability reporting。
