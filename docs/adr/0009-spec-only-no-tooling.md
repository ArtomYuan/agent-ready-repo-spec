# ADR-0009：只做规范文档——删掉全部可执行物，不再绑定任何语言或工具

- 状态：Accepted
- 日期：2026-11-17
- 决策者：@ArtomYuan
- 取代：[ADR-0001](0001-rules-as-single-source.md)（规则以 JSON 为唯一事实源 + 检查器）、
  [ADR-0002](0002-checker-is-read-only.md)（检查器只读）、
  [ADR-0006](0006-github-action-distribution.md)（以 GitHub Action 分发）
- 相关：[spec/checklist.md](../../spec/checklist.md) · [guide/README.md](../../guide/README.md)

## 背景

这个库的定位从一开始就是**指导性文档**：用不用、用多少，由采用它的仓库决定。
但在实现过程中加入了一套可执行物：PowerShell 写的检查器与生成器、测试、发布脚本、
GitHub Action、CI，以及本仓库自己的 `.claude/`（settings、hooks、skills、commands）与 `CLAUDE.md`。

这套东西产生了三个与定位冲突的后果：

1. **变相强制运行时。** 检查器用 PowerShell 写，使用者要自查就得装 PowerShell；
   换成 Node 也只是换一种强制。**规范库不该规定读者用什么语言。**
2. **把文档库变成了软件项目。** CI 里出现了"Windows + PowerShell 5.1 兼容"这类 job——
   唯一作用是伺候工具自己。维护成本花在工具上，不是花在内容上。
3. **默认了某个工具。** 仓库自带 `.claude/` 与 `CLAUDE.md`，等于假设读者都用 Claude Code；
   而这份规范的立场恰恰是"工具中立、由你的环境决定用哪个 agent"。

## 选项

1. **保持现状**（规则库 + 检查器）：有能力自动体检，但要求运行时，且必然绑死一门语言。
2. **换成另一门语言**（Node / Python / Go）：解决某一门语言的问题，仍然是"要求使用者运行代码"，
   只是换了个更流行的依赖。
3. **只做规范文档**：删掉全部可执行物，规范以 markdown 表格呈现，人人可读、任何语言都能据此实现工具，
   但本库不提供工具。

## 结论

选 3。

具体：

- **删**：`checker/`、`tests/`、`tools/`、`action.yml`、`.claude/`、`CLAUDE.md`、`.github/workflows/ci.yml`。
- **留**：`guide/`（七章，中英双语）、`spec/`、`templates/`、`docs/adr/`、`CHANGELOG.md`。
- **新增 `spec/checklist.md`**：把 36 条规则连同 `id / 级别 / 是否 must / 为什么 / 怎么改` 写成一张人读的表，
  成为**唯一事实源**（`rules/rules.json` 与 `spec/RULES.md` 同时下线，避免双写）。
- **机器约束只保留平台自带的**：main 必须走 PR、必需检查。那是 GitHub 的能力，不需要仓库里有代码。

## 后果

**正面**

- 任何仓库、任何语言、任何环境都能用：复制模板、读文档、对着清单逐条比对，不需要装任何东西。
- 维护成本从"修工具"回到"写内容"。
- 不再默认读者的 agent 工具；Claude 相关的条目改为**条件式**表述（"若用 Claude Code…"）。

**负面（必须承认）**

- **没有任何命令能告诉你"缺什么"**，只能人工或由 agent 逐条对照。这一条是永久性损失，不是过渡期。
- 以前可以直接喂给程序的 `rules.json` 没了；想做工具的人要自己从 `checklist.md` 解析或另建数据。
- 36 条规则的表述从"机器判据"退化为"人工判据"——`check` 字段里那些精确条件（行数上限、frontmatter 合法性）
  在文档里只能写成"判据说明"，无法保证一致性执行。

## 复审

若将来出现"确实需要自动化"的强烈需求，正确做法不是把工具塞回本库，而是**另建一个独立仓库**消费本库的清单，
并把语言选择权留给那个仓库。

## 相关

- 本决策直接推翻 [ADR-0001](0001-rules-as-single-source.md)、[ADR-0002](0002-checker-is-read-only.md)、
  [ADR-0006](0006-github-action-distribution.md) 的结论，这三份保留作历史记录。