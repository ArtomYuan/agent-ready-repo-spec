# agent-ready-repo-spec

一套**指导性规范**：当 agent 参与一个 GitHub 仓库的开发时，这个仓库该长什么样——需要哪些文档、怎么布局、
每份文件怎么写、agent 该怎么用、以及 agent 提交换多时该怎么管。

- **只有文档，没有规则引擎。** 没有检查器、没有生成器、没有依赖清单；唯一的自动化是 [`.github/workflows/docs.yml`](.github/workflows/docs.yml) 里的两个必需检查（链接检查 / 双语配对），它们只校验**文档自身**的一致性，不校验规则——见 [ADR-0009](docs/adr/0009-spec-only-no-tooling.md)。
- **不要求任何语言、工具或运行时。** 你读它、复制模板、对着清单逐条比对就行。
- **中英平权**（[ADR-0008](docs/adr/0008-bilingual-equal-status.md)）：两版地位相同，同一 PR 内同步维护。
  英文版：[README.md](README.md)

## 怎么用

1. **读你要的那几章** —— 从 [guide/README.zh-CN.md](guide/README.zh-CN.md) 开始。
2. **对着 [spec/checklist.md](spec/checklist.md) 过一遍** —— 37 条，按 L0–L3 分组。每条只问两件事：
   *我们有吗 / 没有的话理由是什么*。**理由比勾选更重要。**
3. **挑能用的模板复制过去** —— [templates/](templates/)：`AGENTS.md`、PR 模板、CODEOWNERS、ADR、采用记录。

整个流程就这些。**没有命令要跑，这是刻意的。**

## 里面有什么

| 路径 | 内容 |
|---|---|
| [guide/](guide/README.zh-CN.md) | 八章：接入决策 · 该有什么文档 · 目录结构 · 每份文档怎么写 · agent 怎么用 · agent 参与怎么管理 · 信息该放哪 · 该开哪些设置 |
| [spec/](spec/README.md) | 怎么读这套规范：成熟度级别、严重度、版本策略 · **[checklist.md](spec/checklist.md)** · agent 的阅读顺序 |
| [templates/](templates/) | 复制到你自己仓库的文件，含 `{{PLACEHOLDER}}` |
| [docs/](docs/index.md) | ADR（每条决策为什么这么定）、按日期存档的两批实测证据（10 个仓库的文件面 + 12 个仓库的 agent 指令面）、文档地图 |

## 一条贯穿全篇的判据

> **文档的每一行，都要能回答"读者读完这一行，下一步做什么"。**

回答不了的句子，删掉。

## 贡献、安全、许可

- [CONTRIBUTING.md](CONTRIBUTING.md) —— 什么样的贡献有价值，以及流程
- [安全策略](SECURITY.zh-CN.md) —— 私密上报，不要开公开 issue（[English](SECURITY.md)）
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- MIT，见 [LICENSE](LICENSE)
