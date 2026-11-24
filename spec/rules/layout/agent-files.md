# agent 配置文件的提交纪律规则

> 板块 `layout` · 本页承载 3 条条目：`layout/tool-settings`（L2 · should · 旧 `R024`）·
> `layout/no-personal-overrides`（L2 · must · 旧 `R025`）· `layout/ignore-agent-personal`（L3 · must · 旧 `R036`）
> 讲解与采样依据见 [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md)。
> 通用术语与具体文件名的对应见 [机制对照表](../../mechanism-map.md)（附录，非规范）。

## 一句话

同一个工具专属资产目录里躺着两类文件：**团队共享的必须提交**（共享工具配置文件），
**个人覆盖的必须不提交**（个人覆盖文件）。三条规则是同一件事的三个动作——
建一个共享门禁、确认个人文件没进历史、让它在机制上进不来。
其中 `layout/no-personal-overrides` 是全库 6 条 `must` 里唯一一条 L2 的 `must`，也是唯一一条**否定式**判据。

## 三条各查一件事

| 条目 | 查什么 | 判据形态 | 失效方式 | 级别 |
|---|---|---|---|---|
| `layout/tool-settings` | 共享工具配置文件在不在版本库 | 存在性 | 门禁只存在于某个人机器上，换人换会话就归零 | L2 · `should` |
| `layout/no-personal-overrides` | 个人覆盖文件有没有被提交 | **否定式**：仓库里不该有它 | 本机路径与令牌进历史，**删文件不等于删历史** | L2 · `must` |
| `layout/ignore-agent-personal` | `.gitignore` 有没有写死个人配置 | 机制：下一次也不会进来 | 靠人自觉，迟早漏一次 | L3 · `must` |

**顺序不能反**：先有共享工具配置文件（共享门禁），才谈得上"哪些算个人覆盖"；
先确认没有已提交的个人文件（`no-personal-overrides`），`.gitignore` 那条才真正生效——
因为 `.gitignore` **只作用于未跟踪文件**。

## 为什么"某个文件没被提交"值得升 must

[spec/README.md](../../README.md) 的「三档严重度」把 `must` 定义为"缺了就是硬伤，会在几周内咬人"，
而它举的典型例子就是本页这两条：**"提交了个人覆盖文件、`.gitignore` 没排除个人配置"**。
也就是说这条 `must` 不是本页自己给自己升的——它是严重度定义里的原始样本。

三条理由：

1. **否定式判据在 review 里没有信号。** 正向判据失败时，你看到的是"少了个文件"，目录列表一眼看穿。
   否定式判据失败时，你看到的是**多了一个看起来完全正常的文件**：个人覆盖文件
   长得就像配置，diff 里没有任何东西提示"这个不该在这"。guide/02 §7 的反模式表把成因写得很直白——
   **"把个人覆盖文件当配置模板提交"**：提交的人自认为在做对的事。
2. **不可逆。** 一旦进历史，本机绝对路径、用户名、可能夹带的令牌就永久可查。删掉文件只是删了最新一版；
   要真清掉得改写历史 + force push，而 `main` 通常禁止 force push
   （[分支保护规则](../settings/branch-protection.md) 的 `non_fast_forward`）。
   **修复成本随提交次数单调上升**，唯一划算的策略是事前拦住。
3. **它不在自己的档位上。** L2 解决的是"可追溯"，那一档几乎全是 `should`；这条却是 `must`，
   因为它的失效后果不在本档维度里——泄露的是凭证，爆炸半径见
   [归属与凭证规则](../governance/ownership.md)。**判据的级别跟着后果走，不跟着话题走。**

## 状态判据 vs 机制判据：为什么要两条

`layout/no-personal-overrides` 查**当前状态**（现在有没有），`layout/ignore-agent-personal` 查**机制**
（以后会不会有）。只做前者 = 每个新克隆、每个新工具的个人配置文件都要靠人记得排除——
存根那句"只靠自觉不提交会失败"就是这个意思。只做后者 = 已经跟踪的文件不受 `.gitignore` 影响，
机制看着在、实际没拦住。

本仓库这两条都能当场验（`<个人覆盖文件>` 代指本仓库 `.gitignore` 里逐条列出的那几个路径，具体名单见 [机制对照表](../../mechanism-map.md)）：

```console
$ git check-ignore -v <个人覆盖文件>
.gitignore:3:<个人覆盖文件>	<个人覆盖文件>
.gitignore:4:<个人覆盖文件>	<个人覆盖文件>
.gitignore:5:<个人覆盖文件>	<个人覆盖文件>

$ git ls-files | grep <个人覆盖文件的文件名特征>
（无输出）
```

前一条证明**机制**在（`.gitignore` 开头那段"个人 agent 配置"逐条命中），后一条证明**状态**干净（索引里没有它）。
两条合起来才是这两条判据该有的形态：**能被命令回答，不需要读正文。**

**注意那条排除个人规则文件的模式。** 本仓库 [.gitignore](../../../.gitignore) 连某个工具的**个人规则文件**
一起排除了。判据写的是"个人 agent 配置"，不是某个具体文件名——**换一个工具，这条判据照样要求你把它那份
`*.local.*` 加进去。**

## 为什么共享门禁必须进版本库

`layout/tool-settings` 的"为什么"是"否则每个人的门禁都不一样"。这句话的分量来自一个区分
（原文见 [官方文档摘录](../../../docs/evidence/2026-11-17-claude-code-docs.md)）：

> 1. **Non-deterministic**：你写指令，模型读它……不保证它会照做。
> 2. **Deterministic**：你配置指令，harness **必须**执行……不管模型怎么想，每次都生效。

同一个文件里另一条摘录更直接：**工具专属指令文件里的内容是 context，不是 enforced configuration。**

所以"把规矩写进 `AGENTS.md` / 工具专属指令文件"和"写进共享工具配置文件"不是同一件事的两种写法，
而是两种强度：前者可被忽略，后者由工具执行。团队共享的执行层不进版本库，就等于**门禁只存在于某个人的机器上**——
换人、换机、agent 换会话，门禁归零。

`permissions.deny` 该写哪些条目、hooks 引用的脚本怎么保证存在，**不在本页判**：
判据在 [agent-config 板块的权限页](../agent-config/permissions.md) 与
[hooks 与 skills 页](../agent-config/hooks-skills.md)。本页只判"这个文件在不在版本库里"。

**为什么是 `should`、而且是条件式（"若你的工具有共享工具配置文件"）**：[AGENTS.md](../../../AGENTS.md) 的禁区规定
不默认读者的 agent 工具，提到某类机制要写成条件式。本仓库自己就是"条件不成立"的合法例子——
它按 [ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md) 删掉了自带的工具专属资产目录与工具专属指令文件，
并在 [guide/00 §6](../../../guide/00-接入决策.zh-CN.md) 把"agent 权限基线（共享工具配置文件）"
明确列为**未采用项**。**你的工具没有这一层不等于违反本条；有共享工具配置文件而不提交它才是。**
要抄一份起点，用 [templates/settings.json.tmpl](../../../templates/settings.json.tmpl)。

## 与 root-files.md 的分工

`.gitignore` 这一个文件在本板块承担两条判据，**职责不同，判据不重复**：

| 判据 | 问的是 | 归属 |
|---|---|---|
| `layout/gitignore` | 有没有 `.gitignore`，它有没有覆盖依赖目录、构建产物、`.env*` | [根目录规则](root-files.md) |
| `layout/ignore-agent-personal` | 它有没有**写死个人 agent 配置** | 本页 |

本仓库 [.gitignore](../../../.gitignore) 正好把两半分开：开头几行是"个人 agent 配置（含本机路径/令牌，绝不提交）"，
其余（体检产物、编辑器与系统、临时文件）是通用忽略。**读一个文件，判两条规则。**

## 常见误判

| 说法 | 为什么是误判 | 怎么办 |
|---|---|---|
| "个人配置我本地改，反正不会提交" | 只靠自觉不提交会失败（本页存根原话）；一次 `git add -A` 就带进来 | `.gitignore` 写死，`git check-ignore -v` 验命中 |
| "把个人覆盖文件改个名当模板提交" | 内容还是本机路径与令牌，只是换了个文件名 | 只提交共享工具配置文件；要模板就用 `templates/` 里的占位符版本 |
| "已经加了 `.gitignore`，那个文件自然没了" | `.gitignore` 不作用于已跟踪文件 | `git rm --cached <个人覆盖文件路径>` |
| "规矩写进工具专属指令文件就够了" | 工具专属指令文件是 context，不是 enforced configuration | 执行层写进共享工具配置文件，见 [permissions 页](../agent-config/permissions.md) |
| "`deny` 空着也算有文件" | 本页判存在性；`permissions.deny` 非空是另一条判据 | 见 [agent-config 板块的权限页](../agent-config/permissions.md) |
| "个人文件里不会有令牌吧" | 个人覆盖的典型内容就是本机绝对路径与临时塞进去的 token | 泄露面与爆炸半径见 [归属与凭证规则](../governance/ownership.md) |

## 条目

### 若你的工具有共享工具配置文件：它已进版本库

`layout/tool-settings` · L2 · should · 旧 `R024`

**为什么。** 团队共享的权限与 hooks 必须进版本库，否则每个人的门禁都不一样。

**怎么做。** 加共享工具配置文件（具体路径见 [机制对照表](../../mechanism-map.md)）：permissions.deny 优先，hooks 只放声明式表达不了的事。

### 个人覆盖文件未被提交

`layout/no-personal-overrides` · L2 · must · 旧 `R025`

**为什么。** 个人覆盖含本机路径与令牌，提交即泄露。

**怎么做。** 从索引移除：git rm --cached <个人覆盖文件路径>，并写进 .gitignore。

### .gitignore 排除个人 agent 配置

`layout/ignore-agent-personal` · L3 · must · 旧 `R036`

**为什么。** 只靠自觉不提交会失败；必须在 .gitignore 里写死。

**怎么做。** 在 .gitignore 写死个人覆盖文件的模式（具体文件名见 [机制对照表](../../mechanism-map.md)）。

## 相关

- [根目录规则](root-files.md) — `.gitignore` 的第一种职责：通用忽略
- [docs/ 与跨工具资产位置](docs-tree.md) — 同一份 agent 资产该放 `.github/` 还是工具专属资产目录
- [agent-config 板块的权限页](../agent-config/permissions.md) — `permissions.deny` 该有什么
- [hooks 与 skills 页](../agent-config/hooks-skills.md) — hooks 引用的脚本必须存在
- [归属与凭证规则](../governance/ownership.md) — 为什么 agent 手里的凭证就是爆炸半径
- [分支保护规则](../settings/branch-protection.md) — `non_fast_forward` 为什么让泄露无法事后清除
- [机制对照表](../../mechanism-map.md) — 通用术语 ↔ 具体文件名（附录，非规范）
- [templates/settings.json.tmpl](../../../templates/settings.json.tmpl) — 共享门禁的起点
- [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md) — 工具专属资产目录与 `.github/` 的分工表
