# tools/

三个脚本：**发布**（`publish-pr.ps1`）、**换 token**（`gh-app-token.ps1`）、**仅首次引导**（`publish-github.ps1`）。
日常发布只用第一个。

## 认证：GitHub App（唯一推荐路径）

```powershell
./tools/publish-pr.ps1 -Owner ArtomYuan `
  -AppId <appId> -InstallationId <installationId> -PrivateKeyPath <pem> `
  -Message "docs: 修个错字" -Next "补 03 章的反例"
```

**为什么不保留 PAT 的路子**：取 token 的入口每多一个，"这次用的是谁的身份"就多一处说不清。
工具现在只认两种来源：App 三件套（推荐），或显式 `-Token`（临时兜底，会打印黄色提示）。
`-TokenFile` 与 `$env:GITHUB_TOKEN` 自动读取已移除。

**App token 没有 `/user`**：installation token 调不了 `GET /user`，此时**必须显式给 `-Owner`**，
工具会打印 `已认证: App installation token` 以示区别。

## publish-pr.ps1（默认）

走 **分支 → PR → 等 CI → squash 合并**。main 开启保护后，这是唯一能进 main 的路。

`-Next` 是**必填**（ADR-0005）：PR 描述是新会话接手时唯一能读到"下一步做什么"的地方。
确实没有后续时显式写 `-Next "无"`。

```powershell
./tools/publish-pr.ps1 ... -NoMerge    # 只开 PR，不自动合并
./tools/publish-pr.ps1 ... -DryRun     # 只看计划，不碰远端
```

行为：

1. 以 `main` 最新提交为父提交，把整个工作树做成**一个提交**；
2. 建分支 `chore/MMdd-HHmm-<slug>`（`-Branch` 可指定；同名分支已存在时移动它）；
3. 提交信息末尾追加 `Co-authored-by`，PR 正文末尾 `cc @<assignee>` 并设 assignee；
   **两者都从仓库所属账号推导**（`GET /repos/{owner}/{repo}` 的 `owner.login` / `owner.id`），工具里不写死任何人的名字：
   - 所属账号是用户 → 署名 `<login> <<id>+<login>@users.noreply.github.com>`，assignee = `<login>`
   - 所属账号是组织 → 无法推导，工具会明说，请你用 `-CoAuthor` / `-Assignee` 显式指定
   - `-CoAuthor none` / `-Assignee none` 关闭
4. 开 PR（标题 = `-Message`，Conventional Commits 形式，squash 后它就是主分支的提交信息）；
   正文固定四段：改了什么 / **下一步（`-Next`，必填）** / 非目标（`-NotDoing`，可选）/ 怎么验证的；
5. 轮询该提交的 check-runs，**全绿才合并**；任何失败 → 保留 PR 并退出码 3；
6. 默认 squash 合并，保持线性历史（仓库已开启 *合并后自动删 head 分支*）。

`POST /pulls` 的 `assignees` 字段实测会被静默忽略，所以工具在开完 PR 后再显式 `POST /issues/<n>/assignees` 补一次（幂等）。

退出码：`0` 已合并 / `1` 参数或令牌问题 / `2` API 失败 / `3` 检查未过或超时（PR 仍在）。

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
| 改仓库设置（如自动删分支、分支保护） | 另需 *Administration: Read and write* |

> App token 缺 `administration` 时，`PATCH /repos/{owner}/{repo}` 会被**静默忽略**（返回 200 但值没变）。
> 改设置前先 GET 一次确认生效。

## 安全约定

- 令牌只来自 App 私钥现场换取，或显式 `-Token`；不读环境变量、不读凭证文件、不写进任何文件。
- **不要把 token 拼进 remote URL**（会明文落到 `.git/config`）。用 git 时：
  `git -c "http.extraheader=AUTHORIZATION: basic <base64(x-access-token:TOKEN)>" push ...`
- 脚本不打印令牌；报错只回显 API 的 message。
- 上传前排除：`.git/`、`reports/`、`*.local.json`、`*.spec-report.*`。

## 发布之后仍是手动的部分（检查器看不到）

1. **分支保护**：`Require a pull request`、`Require status checks`、`Do not allow bypassing`。
2. **Actions 权限**：Settings → Actions → Workflow permissions 设为只读。
3. **私密漏洞上报**：Security → Private vulnerability reporting。
