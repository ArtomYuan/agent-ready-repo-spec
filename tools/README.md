# tools/

## publish-github.ps1

把整个仓库发布到 GitHub，**不需要 git 命令**（用 Git Data API：blob → tree → commit → ref）。
一个 commit 提交全部文件，适合首次建库，也适合把本地改动整体推上去。

```powershell
# 令牌在环境变量里
$env:GITHUB_TOKEN = 'ghp_xxx'
./tools/publish-github.ps1 -Owner <你的账号>

# 令牌写在一份凭证文档里（脚本会正则在文档里找 gh*_ / github_pat_*，其余文字无影响）
./tools/publish-github.ps1 -TokenFile C:\path\to\credentials.md -Owner <你的账号>

# 先看计划，不联网
./tools/publish-github.ps1 -Owner <你的账号> -DryRun
```

常用参数：`-Repo`（默认 `agent-ready-repo-spec`）、`-Private`、`-Message`、`-SourceDir`。

### 令牌需要什么权限

| 用途 | 最小权限 |
|---|---|
| 在个人账号下建仓库 | classic: `repo`；fine-grained: *Administration: Read and write* + *Contents: Read and write* |

### 安全约定

- 令牌**只从** `-Token`、`-TokenFile`、`$env:GITHUB_TOKEN` / `$env:GH_TOKEN` 取，不写进任何文件。
- 脚本不会打印令牌；报错只回显 API 的 message。
- 上传前排除：`.git/`、`reports/`、`*.local.json`、`*.spec-report.*`。

### 发布之后还得手动做三件事（检查器看不到）

1. **保护 main**：禁止直推、Require review from Code Owners、关闭 force push。
2. **Actions 权限**：Settings → Actions → Workflow permissions 设为只读。
3. **私密漏洞上报**：Security → Private vulnerability reporting 打开（配合 `SECURITY.md`）。
