# docs/ 与跨工具资产位置规则

> 板块 `layout` · 本页承载 2 条条目：`layout/docs-index`（L2 · should · 旧 `R022`）·
> `layout/assets-location`（L3 · may · 旧 `R047`）
> 讲解与采样依据见 [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md)。
> 通用术语与具体文件名的对应见 [机制对照表](../../mechanism-map.md)（附录，非规范）。

## 一句话

这一页管两个方向的"放哪"：**文档往下沉到哪一层**（`docs/` 分层 + 一张地图），
**agent 资产往哪边放**（`.github/` 还是工具自己的目录）。
两条判据有个共同点：**判的是位置，不是内容**——所以它们都能靠"看一眼目录"回答，不需要读正文。

## 往下沉：docs/ 的骨架与它的最低要求

[guide/02](../../../guide/02-目录结构.zh-CN.md) §4 的推荐骨架：

```
docs/
├── index.md            # 地图：按下面五类给入口
├── getting-started/    # 教程：从零到跑起来
├── guides/             # 任务导向：怎么做某件事
├── reference/          # 查阅型：API、配置项、错误码
├── architecture/       # 现状说明：模块、数据流
├── adr/                # 决策记录：为什么不是另一种
└── operations/         # 运维：部署、回滚、on-call
```

同章三条写法，按重要性排：

1. **`index.md` 是地图，不是散文。** 读者到这里是为了"点进去"，不是"读一段话"。
2. **一个文件一个主题，文件名即主题。** `docs/adr/0007-cursor-pagination.md` 比 `docs/design2-final.md`
   有用一个数量级——本仓库的实例：
   [examples/medium-repo/docs/adr/0007-cursor-pagination.md](../../../examples/medium-repo/docs/adr/0007-cursor-pagination.md)。
3. **长内容不进 README。** README 只回答"要不要用、怎么跑起来"，其余下沉。

**最低要求只有一条硬的：地图上的路径必须真实存在。** 这是 [AGENTS.md](../../../AGENTS.md) 的硬约定
（"文档里的路径必须真实存在——读者会顺着点"），也是 CI 的**链接检查**唯一能替你抓到的那部分。
上面那六个子目录**一个都不要求存在**：`docs/` 该有什么，取决于这个仓库有没有教程、有没有运维手册。

## 地图长什么样：本仓库实测

[docs/index.md](../../../docs/index.md) 不按"教程/参考/架构"分，而按**读者**分三节——
「我是人，想用这套规范」「我是 agent，要替人管一个库」「我在看设计」（前两节是表，agent 节是正文加引用块），
末尾一节「文档约定」。每行都是"我想做 X → 去哪"，不是文件清单。

这不算偏离判据，反而说明判据落在哪：**地图要回答"我该点哪个"，分类轴可以是类型，也可以是读者。**
本仓库 `docs/` 下只有 `adr/` 与 `evidence/` 两个子目录，没有 `guides/`、`operations/`，
地图也就没有指向它们——**地图不指向不存在的东西，比地图的分类名漂亮更重要。**

地图最值钱的一行，是它把"这里没有 X，且是刻意的"写在门口：本仓库 `docs/index.md` 在 agent 入口那节直接写明
"这套规范**不提供检查器**"，并指到 [ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md)。
这正是 [采用记录规则](../adoption/record.md) 论证过的效果——**写出来的"没有"是一个可被质疑的决定，
没写出来的"没有"会被下一个人当成遗漏顺手补上。**

## 命名不要较真

实测（[十仓采样 §1](../../../docs/evidence/2026-11-17-repo-sampling.md)）：十个样本里 **5 个有文档目录**，
命名三种——`docs/`（`cli/cli`、`vercel/next.js`、`modelcontextprotocol/servers`）、
`Doc/`（`python/cpython`）、`documentation/`（`sindresorhus/got`）；另外 5 个没有独立文档目录
（`microsoft/vscode` 的文档在 wiki/站点——此说出自 [guide/02 §1](../../../guide/02-目录结构.zh-CN.md) 的对照表，采样表该格为空）。

→ **新建用 `docs/`，存量不改名。** 改名让所有外部链接失效，收益远小于成本。
规范因此只判"有没有一张地图"，不判"目录叫什么名"。

## 往两边分：agent 资产的归属判据

一句话判据（同条目「怎么做」）：**只有某个工具用 → 那个工具的目录；可能被多个工具用 → `.github/`。**

实测支撑（[guide/02 §1、§3](../../../guide/02-目录结构.zh-CN.md) 与 [十仓采样 §3](../../../docs/evidence/2026-11-17-repo-sampling.md)，下表按行合并两处来源）：

| 仓库 | `.github/` 里的 agent 资产 |
|---|---|
| `cli/cli` | `agents/`、`skills/`、`actions/`、`mcp.json`（外加 CODEOWNERS、ISSUE_TEMPLATE 等平台文件） |
| `microsoft/vscode` | `agents/`、`skills/`、`instructions/`、`hooks/`、`commands/`、平台级指令文件 |
| `vercel/next.js` | `AGENTS.md`（根目录也有一份） |

只服务单一工具的那套则在自己的目录里：共享工具配置文件、分层机制的规则文件、skill 目录、
agent 定义目录、命令目录，加上项目根的 `.mcp.json`（具体路径见 [机制对照表](../../mechanism-map.md)）。

**双事实源的失效方式是"生效哪个看运气"**：同一份 skill 在 `.github/skills/` 和工具专属资产目录里各存一份，
改了一份、另一份还在，两个工具读到不同的规则——**而且没有任何报错**。
所以判据的后半句"且只有一处事实源"才是重点：**另一处只放指针**，一句话指过去，不复制内容。

**为什么只到 L3 `may`**：这个失效面只在"同一仓库同时被多个工具使用"时才存在。
单工具仓库根本没有"两边各一份"这个选项，缺它也不咬人；而本板块两条 `must`
（见 [agent 配置文件的提交纪律](agent-files.md)）失效即泄露、且不可逆。**级别差就是这么来的。**

## 常见误判

| 说法 | 为什么是误判 | 怎么办 |
|---|---|---|
| "有 `docs/` 就算有地图" | 判据是 `docs/index.md` 存在且能导航；目录在、但没人知道先点哪个，等于没有 | 建一张"我想 X → 去哪"的表，见本页实测 |
| "地图就是文件清单" | 清单不回答"我该点哪个"；读者要的是入口，不是目录树 | 每行写"我想做什么"，不写"这里有什么" |
| "`Doc/` 不合规，改名成 `docs/`" | 外部链接全断，收益远小于成本 | 新建用 `docs/`，存量不动 |
| "agent 规则在 `.github/` 和工具专属资产目录各放一份保险" | 双事实源，改一份另一份还在，静默漂移 | 按"谁用"选一处，另一处只放指针 |
| "把 `AGENTS.md` 的细则复制进 README" | 工具读不到，人看着是噪音（guide/02 §7 反模式） | 细则归 `AGENTS.md`，README 只留入口 |
| "`docs/` 里放一份构建产物方便看" | 仓库膨胀 + diff 噪音（guide/02 §7） | `.gitignore` 掉，见 [root-files.md](root-files.md) |

## 条目

### 存在 docs/index.md 文档地图

`layout/docs-index` · L2 · should · 旧 `R022`

**为什么。** 没有地图，人和 agent 都靠猜；猜的成本最终落在 review 上。

**怎么做。** 建 docs/index.md，按 教程/参考/架构/ADR/运维 五类给出入口。

### 跨工具 agent 资产放 `.github/`，工具独占的放工具目录，且只有一处事实源

`layout/assets-location` · L3 · may · 旧 `R047`

**为什么。** `cli/cli` 与 `microsoft/vscode` 把 agents / skills 放 `.github/`，只服务单一工具的那套放工具专属资产目录。两边各存一份就是两个事实源，生效哪个看运气。

**怎么做。** 一句话判据：**只有某个工具用 → 那个工具的目录；可能被多个工具用 → `.github/`**；另一处只放指针。详见 [guide/02 §5](../../../guide/02-目录结构.zh-CN.md)。

## 相关

- [根目录规则](root-files.md) — 什么留在根、什么下沉；生成物 `.gitignore` 掉
- [agent 配置文件的提交纪律](agent-files.md) — 工具专属资产目录里哪些必须提交、哪些必须不提交
- [ADR 存放位置与命名](../writing/adr.md) — `docs/adr/` 那一格该由谁填
- [采用记录规则](../adoption/record.md) — 把"没有 X，且是刻意的"写成一份落在仓库里的文件
- [机制对照表](../../mechanism-map.md) — 通用术语 ↔ 具体目录与文件名（附录，非规范）
- [规则索引](../README.md) · [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md)
- [十仓形态采样](../../../docs/evidence/2026-11-17-repo-sampling.md) — 文档目录命名与 `.github/` 内容的出处
