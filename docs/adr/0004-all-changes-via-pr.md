# ADR-0004：所有变更走 PR，主分支加锁

- 状态：Accepted
- 日期：2026-11-17
- 决策者：@ArtomYuan
- 取代：[ADR-0003](0003-why-this-repo-delays-admin-enforcement.md)（暂不开启 admin 强制）
- 相关：[guide/05-Agent参与怎么管理.md](../../guide/05-Agent参与怎么管理.md) · tools（已随 ADR-0009 下线）

## 背景

此前的发布方式是 `tools/publish-github.ps1` **直推 main**，CI 在 push 之后才跑。这带来三个问题：

1. **错误先落地再被发现**：CI 红了的时候，main 上已经是坏的；
2. **不知道改了什么、什么时候改的**：整树覆盖式提交，diff 里看不出一次变更的范围；
3. **agent 与人的改动没有共同闸门**：谁拿到令牌谁就能直接改主分支。

ADR-0003 当时记录的是"暂不开启 admin 强制"，理由是单人维护 + 没有 PR 工具。
现在这两个前提都能解决：先写一个走 PR 的发布器，再开保护。

## 选项

1. **只开 `Require a pull request` + `Required status checks`，不开 admin 强制。**
   管理员仍可绕过——但本项目里"管理员"就是 agent 用的那个令牌，等于没防。
2. **开启 admin 强制，但保留 `publish-github.ps1` 直推。**
   直推会被保护拒绝，发布立刻不可用。
3. **写走 PR 的发布器（`publish-pr.ps1`），然后开全套保护（含 admin 强制）。**

## 结论

选 3。

- 日常发布：`tools/publish-pr.ps1` —— 分支 → PR → 等 checks → squash 合并；
- 保护：`Require a pull request`（审批数 0，允许自己合并）+ `Require status checks`（CI 四个 job）
  + `Do not allow bypassing`（管理员也必须走同一套）；
- 合并方式：只留 **squash**，保持线性历史（对应 `R051`）；
- `publish-github.ps1` 降级为"新仓库首次引导"专用，本文档记录其定位。

## 后果

**正面**

- **CI 先于合并**：main 不再出现"合进去才发现红"的状态；
- 每一次变更都是一个可评审、可 revert 的 PR，标题即提交信息；
- agent 与人走**同一条**闸门，没有"管理员例外"；
- commitlint job 从"永远 skip"变成真实生效。

**负面**

- 单次发布从约 10 秒变成 3–6 分钟（等 CI），摩擦明显上升；
- 需要维护两个发布工具，且 `publish-pr.ps1` 自身也在被它发布的树里（自举）；
- PR 里出现的任何 CI 抖动都会直接卡住发布。

**破窗（break-glass）**

CI 整体不可用时，唯一出路是临时关闭保护（需要 admin 令牌调 API），**每次都必须**在 `docs/incidents/`
记一条：谁、何时、为什么、恢复了什么。**不允许**长期保留 bypass 列表来"顺手绕过"。

**复审**：2027-01-31，或出现第二位维护者时（那时把审批数从 0 调到 1，并让 CODEOWNERS 真正生效）。

## 相关

- `tools/publish-pr.ps1`（新）、`tools/publish-github.ps1`（保留作引导）
- 分支保护（2026-11-17 实测生效）：
  - `required_pull_request_reviews`：启用，**审批数 0**（允许自己合并，但必须走 PR）
  - `required_status_checks`：`引擎自测`、`自己体检自己`、`Windows + PowerShell 5.1 兼容`、`提交信息（commitlint）`
  - `enforce_admins = true`、`allow_force_pushes = false`、`allow_deletions = false`、`required_conversation_resolution = true`
- **验证记录**：开启后用 admin 令牌构造一个内容完全相同的提交，尝试 `PATCH /git/refs/heads/main`，
  返回 `422 Changes must be made through a pull request. 4 of 4 required status checks are expected.`，
  main 的 head 未变——说明"管理员也不能直推"确实成立。
