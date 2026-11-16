# 检查器结构

```
spec-check.ps1
├── param()                  Target / Level / Format / FailOn / RulesPath
├── 工具函数
│   ├── Read-Text            统一 UTF-8 读取
│   ├── Get-Frontmatter      解析 --- ... --- 顶部字段
│   └── Get-JsonDepth        按点路径取嵌套属性
├── Test-Rule                分发到 16 种 check.kind
└── main                     过滤 level → 逐条检查 → 汇总 → 输出 → 退出码
```

## 16 种 `check.kind`

| kind | 参数 | 判定 |
|---|---|---|
| `file-exists` | `any[]`, `nonEmpty?` | 任一存在（且非空） |
| `file-absent` | `any[]` | 全部不存在 |
| `file-max-lines` | `file`, `max` | 行数上限 |
| `file-limit` | `file`, `regex`, `max` | 命中 regex **或** 行数不超限 |
| `file-contains` | `file`, `regex` | 至少一处匹配（`Multiline`） |
| `file-not-contains` | `file`, `regex` | 不得匹配（查占位文本） |
| `dir-min-files` | `dir`, `pattern`, `min` | 目录内匹配文件数下限 |
| `json-nonempty` | `file`, `path` | 点路径存在且非空数组/对象 |
| `json-hook-scripts-exist` | `file` | hooks 里引用的 `.claude/hooks/*` 都真实存在 |
| `frontmatter-fields` | `dir`, `pattern`, `fields[]`, `fieldsOneOf[][]`, `exclude[]` | frontmatter 必填字段 |
| `name-pattern` | `dir`, `pattern`, `regex` | 文件名模式（ADR 编号） |
| `dir-contains` | `dir`, `pattern`, `regex` | 目录内至少一个文件命中 |
| `md-refs-exist` | `file`, `ignore[]` | Markdown 里引用的路径存在（防文档腐烂） |
| `json-forbid` | `file`, `checks[{path,forbid[]}]` | JSON 里某路径**不得**等于给定值（如 attribution=false） |
| `git-commit-subject` | `regex`, `maxLength`, `depth` | 最近 N 条提交 subject 匹配格式（需 `-Git`） |
| `git-commit-no-merge` | `depth` | 最近 N 条提交无 merge（需 `-Git`） |

## 提交历史（`-Git`，默认关闭）

规则可以声明 `"requires": "git"`。默认不读取提交历史，因此：

- 未传 `-Git` → 该规则 `skipped`，detail 写“需要 -Git”；
- 传了 `-Git` 但 git 不可用 / 目标不是 git 仓库 → 同样 `skipped`，写原因；
- **`skipped` 不计入分数、不计入达成等级、不触发退出码**，只在报告里显示 `[skip]`。

这样检查器仍然是“纯读文件”的：默认零依赖、可对任意目录跑；想查历史就显式打开，
并且 `git` 缺失时不会假装通过。

## 汇总与退出码

- 权重：`must` 5 / `should` 2 / `may` 1；`score = 通过权重 / 总权重`。
- `achievedLevel`：从 L0 往上，**所有 must+should 都通过**的最高级别（`may` 不阻断）。
- `-FailOn`：`must`（默认）/ `should` / `none`。命中即 `exit 1`。
- 运行错误（目标不存在、`rules.json` 解析失败）→ `exit 2`。

## 三条实现约束

1. **零依赖**：只用 PowerShell 内置能力，Windows PowerShell 5.1 与 PowerShell 7 都要跑得动。
2. **`.ps1` 必须 UTF-8 with BOM**：5.1 会把无 BOM 的 UTF-8 当 ANSI 读，中文引号会撕裂语法。
3. **正则写在 JSON 里**：引擎只做 `[regex]::IsMatch`，不做规则特判——否则规则无法被数据审阅。
