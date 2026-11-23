# CI 规则

> 板块 `settings` · 本页承载 2 条条目：`settings/ci-exists`（L0 · should · 旧 `R005`）·
> `settings/workflow-permissions`（L2 · should · 旧 `R061`）
> 讲解与依据见 [guide/07 §4](../../../guide/07-该开哪些设置.zh-CN.md)。

## 一句话

**没有 CI，agent 的改动就没有可拒绝的依据。** 而 CI 本身是攻击面——它的默认权限比需要的宽。

## 为什么 CI 是 L0

`settings/ci-exists` 是唯一一条 L0 的 `should`。位置不是随便给的：

L0 的五条里，四条（README、AGENTS.md、`.gitignore`、LICENSE）解决的是"这个仓库能不能被读懂"，
只有 CI 解决的是"**这个仓库的改动能不能被拦下来**"。一个 agent 参与的仓库如果连 CI 都没有，
那么所有写在文档里的规矩都只有靠自觉这一种执行方式。

判据很低：**存在一个 workflow，至少跑 lint + test**。不要求覆盖率、不要求多平台矩阵、
不要求发布流水线。一条 `push` 触发的 `npm test` 就够 L0——它建立的是"有东西会红"这个事实。

本库按字面判是**偏离**的：唯一 workflow `docs.yml` 没有 lint 也没有 test，两个 job 是链接检查与
双语配对——它建立的仍是"有东西会红"，但照字面"跑 lint + test"没做到。按 `release/self-noncompliance`
的精神在这里自曝，而不是把它读成达标。

## CI 是门禁的执行端

[分支保护规则](branch-protection.md) 里的 `required_status_checks` 存的是**检查名**，
而检查名要靠 workflow 去上报。两边是一体两面：

| 边 | 归谁 | 配错的后果 |
|---|---|---|
| ruleset 里的检查名 | `settings/required-check-names` | 名字没人上报 → `main` 永久不可合并 |
| workflow 里的 job 名 | 本页 | job 改名等于删掉一个必需检查 |

所以改 workflow 的 job 名，是一次**门禁变更**，不是内部重构。顺序见
[branch-protection.md](branch-protection.md) 的三条规矩。

## workflow 自己的两条收紧

CI 会执行仓库里的代码，而 agent 提的 PR 会带着 workflow 的权限跑起来。两件事必须做：

**1. 显式声明 `permissions`。** 默认 `GITHUB_TOKEN` 的权限常常比需要的宽。
每个 workflow 顶部写最窄的：

```yaml
permissions:
  contents: read
```

按 job 再单独放大，不要在全局放大。

**2. 第三方 Action 固定到 40 位 commit SHA，注释里标对应 tag。**

```yaml
- uses: actions/checkout@3d3c42e5…   # v7
- uses: lycheeverse/lychee-action@e7477775…   # v2
```

理由只有一句：**tag 可以被移动、SHA 不能。** 固定到 tag 等于把供应链交给一个可改写的指针——
和本库 [release/moving-tags](../release/artifact.md) 反对的是同一类东西，只是发生在构建侧。

`pull_request_target` 若必须用（比如需要 secrets 的 fork 构建），单独写一条 ADR 说明为什么——
它是把 fork 的代码放进有权限的环境里跑，默认拒绝。

## 条目

### 有 CI 工作流

`settings/ci-exists` · L0 · should · 旧 `R005`

**为什么。** 没有 CI，agent 的改动就没有可拒绝的依据。

**怎么做。** 加 `.github/workflows/ci.yml`，至少跑 lint + test。

### workflow 显式声明 `permissions`，第三方 Action 固定到 commit SHA

`settings/workflow-permissions` · L2 · should · 旧 `R061`

**为什么。** 默认 `GITHUB_TOKEN` 的权限常常比需要的宽，而 agent 提的 PR 会带着这些权限跑起来。
tag 可以被移动、SHA 不能——固定到 tag 等于把供应链交给一个可改写的指针。
本库的 `.github/workflows/docs.yml` 两个 Action 都固定到 SHA，注释里写了理由，
但**此前没有任何条目要求别人也这么做**：实践与规则脱节。

**怎么做。** 每个 workflow 顶部写 `permissions: contents: read`，按 job 再单独放大；
`uses:` 一律写 40 位 SHA 并在注释里标对应 tag；`pull_request_target` 若必须用，
单独写一条 ADR 说明为什么。官方依据：
[Assigning permissions to jobs](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs)。

## 相关

- [分支保护规则](branch-protection.md) — 必需检查名、线性历史、`main` 闸门
- [采用记录规则](../adoption/record.md) — Actions 默认权限也要写进采用记录的「设置」节
- [guide/07 §4](../../../guide/07-该开哪些设置.zh-CN.md) — Actions 权限的开关清单
- [release/moving-tags](../release/artifact.md) — "指针可改写"在发布侧的同一件事
