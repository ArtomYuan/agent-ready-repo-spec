# 接进你自己的 CI

## 最快：一行接入（GitHub Action）

```yaml
      - uses: actions/checkout@<PINNED_SHA>
      - uses: ArtomYuan/agent-ready-repo-spec@<PINNED_SHA>   # 试用可直接写 @v1
        with:
          level: '3'
          fail-on: 'must'
```

inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
**`v1` 是移动 tag**，生产环境请固定 commit SHA——与本文件其余示例的规则一致。
理由与取舍见 [ADR-0006](../adr/0006-github-action-distribution.md)。

## 最小可用（自己控制脚本时，推荐先只卡 must）

```yaml
# .github/workflows/spec.yml
name: spec
on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  spec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<PINNED_SHA>
        with:
          persist-credentials: false

      - uses: actions/checkout@<PINNED_SHA>
        with:
          repository: example-org/agent-ready-repo-spec
          path: .spec
          persist-credentials: false

      - name: 规范体检（只卡 must）
        shell: pwsh
        run: ./.spec/checker/spec-check.ps1 -Target . -Level 3 -FailOn must -NoColor
```

`pwsh` 在 GitHub 托管的 ubuntu / windows / macos runner 上都预装，不需要 setup 步骤。

## 分阶段收紧

| 阶段 | 命令 | 说明 |
|---|---|---|
| 接入期（第 1–2 周） | `-FailOn none` | 只出报告不红，先看基线 |
| 常态 | `-FailOn must` | 硬伤必须修 |
| 成熟后 | `-FailOn should` | 连"该有"的也卡住 |
| 强治理仓库 | `-Level 3 -FailOn should` | 本仓库自己用的就是这个 |

**不要**第一天就 `-FailOn should`：一次几十条红色，团队会直接绕过这个 job。

## 把报告变成 PR 评论

```yaml
      - name: 生成 markdown 报告
        if: always()
        shell: pwsh
        run: ./.spec/checker/spec-check.ps1 -Target . -Format md > spec-report.md

      - name: 上传
        if: always()
        uses: actions/upload-artifact@<PINNED_SHA>
        with:
          name: spec-report
          path: spec-report.md
```

## 三个实践要点

1. **`persist-credentials: false`**：agent 参与提交的仓库里，泄露 token 是最常见的真实事故。
2. **固定 commit SHA**：`-Target` 会读取你的仓库，spec 仓库本身也是供应链的一部分。
3. **别把它设成 required check 之前先跑一周**：先出报告、后设门禁，顺序反了会阻塞所有 PR。
