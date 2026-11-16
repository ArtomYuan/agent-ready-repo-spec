# tools/

两个发布工具，用途不同。**这个仓库日常发布只用第一个。**

## publish-pr.ps1（默认）

走 **分支 → PR → 等 CI → squash 合并**。main 开启保护后，这是唯一能进 main 的路。

`-Next` 是**必填**（ADR-0005）：PR 描述是新会话接手时唯一能读到"下一步做什么"的地方。
确实没有后续时显式写 `-Next "无"`。

```powershell
# 令牌在环境变量里
$env:GITHUB_TOKEN = 'ghp_xxx'
./tools/publish-pr.ps1 -Owner ArtomYuan -Message "docs: 修个错字" -Next "补 03 章的反例"

# 令牌在凭证文档里（正则在文档中找 gh*_ / github_pat_*）
./tools/publish-pr.ps1 -TokenFile C:\path\to\credentials.md -Message "feat(rules): ..." -Next "下一步"

# 只开 PR 不合并 / 先看计划
./tools/publish-pr.ps1 -Message "..." -Next "..." -NoMerge
./tools/publish-pr.ps1 -Message "..." -Next "..." -DryRun
```

行为：

1. 以 `main` 最新提交为父提交，把整个工作树做成**一个提交**；
2. 建分支 `chore/MMdd-HHmm-<slug>`（`-Branch` 可指定）；
3. 开 PR（标题 = `-Message`，必须是 Conventional Commits 形式，squash 后它就是主分支的提交信息）；
   正文固定四段：改了什么 / **下一步（`-Next`，必填）** / 非目标（`-NotDoing`，可选）/ 怎么验证的；
4. 轮询该提交的 check-runs，**全绿才合并**；任何失败 → 保留 PR 并退出码 3；
5. 默认 squash 合并，保持线性历史。

退出码：`0` 已合并 / `1` 参数或令牌问题 / `2` API 失败 / `3` 检查未过或超时（PR 仍在）。

## publish-github.ps1（仅用于新建仓库或首次引导）

直推 main。**main 开启保护后它会失败**（这正是保护的意义）。保留它是因为：

- 新仓库还没有任何提交时，GitHub 拒绝 git-blob API（409），需要一次引导提交；
- 首次建库、还没有分支保护的时候，一条命令把仓库建起来。

## 令牌权限

| 用途 | 最小权限 |
|---|---|
| 建仓库 | classic: `repo`；fine-grained: *Administration: Read and write* + *Contents: Read and write* |
| 走 PR 发布 | 同上；另需 *Pull requests: Read and write* |

## 安全约定

- 令牌只从 `-Token`、`-TokenFile`、`$env:GITHUB_TOKEN` / `$env:GH_TOKEN` 取，不写进任何文件。
- 脚本不打印令牌；报错只回显 API 的 message。
- 上传前排除：`.git/`、`reports/`、`*.local.json`、`*.spec-report.*`。

## 发布之后仍是手动的部分（检查器看不到）

1. **分支保护**：`Require a pull request`、`Require status checks`、`Do not allow bypassing`。
2. **Actions 权限**：Settings → Actions → Workflow permissions 设为只读。
3. **私密漏洞上报**：Security → Private vulnerability reporting。
