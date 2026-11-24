# Examples — 同一条判据的两端

这两份不是"按仓库大小挑一个"的模板，而是同一条判据的两端：**约定需要几层？**

| | [`small-repo/`](small-repo/AGENTS.md) | [`medium-repo/`](medium-repo/AGENTS.md) |
|---|---|---|
| 根 `AGENTS.md` | ~12 行——所有约定都在这一个文件里 | ~65 行——分节 |
| 细则放哪 | 没有细则 | 下沉（子目录文件、`CONTRIBUTING.md`、ADR） |
| 形态 | **路由**：指向真正的细则 + 那条最容易被做错的规则 | **约束 + 命令 + 验证 + 自动化地图** |
| 需要写"为什么"吗 | 写不下 | 部分要写——约束背后的理由决定 agent 会不会绕 |
| 腐烂速度 | 慢 | 快：命令会过期、workflow 会改名 |

两者遵守同一条检验：**它不是完备文档，是 agent 每次会话必须加载的东西。**

## 怎么选

```
1. 所有约定能一屏说清，且不需要"下一步去看某文件"？        → small
2. 有生成物、多个入口、或不止一个 CI job？                → medium
3. 有专人维护 且 只有一个团队？                          → 才考虑"大全型"
```

## 什么时候从 small 搬到 medium

任意一条命中：

- 根文件超过 **200 行**；
- "我记得写过这个"出现两次；
- 新人（或 agent）**同一个问题问了两遍**；
- 你加了第二个 workflow，或出现了第一个生成物。

搬的时候不是重写，而是**切成两段**：每次会话都必须知道的留在根文件，需要去查的变成链接。

## 这些形态是从哪来的

没有一条是我的偏好，每节都标注了真实来源：

| 形态 | 出处 |
|---|---|
| 8 行路由 + 指向真正的说明 | `microsoft/vscode/AGENTS.md` |
| 约束写成"不要手改这个，改用那个" | `kubernetes/kubernetes/AGENTS.md` |
| 把"沟通偏好/语气"当成正式一节 | `kubernetes/kubernetes/AGENTS.md` |
| `Validation` 给可直接粘贴的命令 | `openai/openai-python/AGENTS.md` |
| `Automation map`：一个 workflow 一行，说明它管什么 | `openai/openai-python/AGENTS.md` |
| PR 模板里问"是否使用了 AI" | `kubernetes/kubernetes`（见其 `AGENTS.md`） |

原始样本与完整调研：[`docs/evidence/2026-11-18-agent-docs-sampling.md`](../docs/evidence/2026-11-18-agent-docs-sampling.md)。

## 真实仓库互相矛盾的两处 —— 你自己定

**1. `Co-authored-by` 归属。** 本库清单 `R029` 建议**保留** agent trailer，因为它是审计线索。
`kubernetes/kubernetes` 反过来：禁止 `Co-authored-by`、禁止在 commit 里写 `@mentions` 与 `fixes #...`——
归属改放到 PR 描述和"是否使用了 AI"的声明里。

两种都自洽：保留 trailer，`git log` 里能看出"哪些提交来自模型"；禁止它，历史保持干净，
归属放在 reviewer 真正会读的地方。**`R029` 是 `should` 而不是 `must`，正是因为这一点。**
`medium-repo/README.md` 把两种写法都列出来了。

**2. 文件语言。** 这里的样本全是英文，因为取材的仓库都是英文仓库。
你自己的 agent 指令**应该用你跟 agent 说话的语言**——见
[`templates/prompt-locale.md.tmpl`](../templates/prompt-locale.md.tmpl)。

## 示例刻意不包含

- 没有工具专属指令文件、工具专属资产目录——它们是采用者的选择，不是本库的选择
- 没有 workflow 文件：示例讲的是**怎么描述自动化**，不是你的 CI 该跑什么
- 没有填死的数字（测试数量、覆盖率）：那是最快腐烂的东西
