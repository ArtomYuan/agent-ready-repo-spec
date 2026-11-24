# ADR-0014：规范正文去工具名——通用术语 + 非规范性机制对照表

- 日期：2026-11-24
- 状态：Accepted
- 相关：[ADR-0009](0009-spec-only-no-tooling.md)（删工具，留规范）· [ADR-0013](0013-rules-by-domain.md)（板块重组）· `spec/mechanism-map.md`（本决定新增的附录）

## 背景

2.0.0 之后实测各工具名在活规范文本里的分布（`spec/` + `guide/` + `templates/` + 根文件，不含 `docs/adr/` 与 `docs/evidence/`）：

| 工具 | 提及行数 |
|---|---|
| Claude 系 | 294 |
| Copilot | 32 |
| Cursor | 23 |
| Codex | 4（全是"…等"式列举） |
| Gemini CLI / DeepSeek Harness / 其余 | 0 |

规范骨架本已工具中立（判据全部条件式"若你用 X"、AGENTS.md 是主体、判定表有"不适用"行），
但**提及权重严重失衡**：一个用 Gemini CLI 或 DeepSeek Harness 的读者，会在指令面清单里
找不到自己，而 Claude 的机制被反复点名。条件式措辞解决了"不假设"，没解决"看不见"。

继续给每个流行工具补行是追不上的（工具名单每季度都在变），也违背 ADR-0009 的方向。

## 决定

1. **规范正文零工具名**：`spec/`、`guide/`、`templates/`、根文件（README / SECURITY / CONTRIBUTING / AGENTS.md）
   不再出现任何 agent 工具的品牌名与其专属文件名（`CLAUDE.md`、`.claude/`、`copilot-instructions.md`、
   `GEMINI.md` 等）。判据改用通用术语（下表）。`AGENTS.md` 本身保留——它是文件名，不含工具品牌，
   且是本规范主体的名字。
2. **新增附录 `spec/mechanism-map.md`**：通用术语 ↔ 具体工具机制的对照表。
   它**不是规范**：不承载判据、不参与符合性声明、允许过期、按读者工具群增删。
   工具名只允许出现在这个附录与证据层。
3. **豁免范围**（历史与证据，不改写）：`docs/adr/`、`docs/evidence/`、CHANGELOG 既有版本节。
   与 ADR-0013 对旧叙事的处理同理：历史叙述记录的是当时看到的东西。
   执行中追加三类豁免：**仓库名与专有名词**（如证据表里的 `microsoft/vscode`、示例里的
   `openai/openai-python` 仓库名、"cursor pagination" 这类与工具无关的同词）；
   **`.gitignore` 的忽略模式**（防御性配置，模式必须写具体文件名，已加注释指向附录）。
4. **规则 ID 与承载页路径随术语更新**（旧号 `R0xx` 映射不变，永不复用）：

   | 旧 ID | 新 ID | 理由 |
   |---|---|---|
   | `agent-config/claude-md-thin` | `agent-config/adapter-thin` | 文件名含工具名 |
   | `agent-config/copilot-instructions` | `agent-config/instructions-single` | 同上；判据本义是"细则只放一处" |
   | `agent-config/hook-exit-2` | `agent-config/gate-hook` | exit code 2 是单一工具的机制细节 |
   | `agent-config/hooks-scripts` | `agent-config/hook-scripts` | 随上条统一单数 |
   | `layout/claude-settings` | `layout/tool-settings` | 文件名含工具名 |
   | `layout/no-settings-local` | `layout/no-personal-overrides` | `settings.local.json` 是专属文件名 |

   其余 ID 不含工具名，不动。板块名不变（禁区约定）。
5. **判据句（小节标题）同步改写**，索引「判据」列逐字跟随（三处受控双写）。
   条件式从"若你用某工具"改为"若你的工具存在 X"式：**存在即适用、不存在即不适用**，判定结果不变。

## 通用术语表（唯一依据，改写时逐词使用）

| 通用术语 | 指什么 | 旧写法（仅在此表出现） |
|---|---|---|
| 主体指令文件 | 仓库唯一的细则归属地 | `AGENTS.md`（保留原名，不叫"通用术语"） |
| 工具专属指令文件 | 某工具独立读取的仓库内指令文件 | `CLAUDE.md`、`GEMINI.md` |
| 平台级指令文件 | 代码托管平台为 agent 提供的仓库级指令位 | `.github/copilot-instructions.md` |
| 分主题指令文件 | 按路径生效的分主题指令机制 | `.github/instructions/*.instructions.md` + `applyTo` |
| 工具专属资产目录 | 只服务单一工具的目录 | `.claude/`、`.gemini/`、`.cursor/` |
| 共享工具配置文件 | 进版本库的权限/hook 声明文件 | `.claude/settings.json` |
| 个人覆盖文件 | 含本机路径与令牌、不该提交的覆盖 | `.claude/settings.local.json`、`CLAUDE.local.md` |
| 门禁 hook | 确定性拦截机制（不依赖模型自觉） | Claude hook exit code 2 |
| 权限声明（deny 清单） | 声明式权限拒绝列表 | `permissions.deny` |
| 机器本地记忆 | 工具在本机积累、不随仓库分发的记忆 | auto memory |
| 会话署名 trailer | 提交里标注会话来源的 trailer | `Co-Authored-By: <model>` |
| 分层机制 | 工具自带的按路径/主题拆分指令的能力 | `.claude/rules/*.md` + `paths:` 等 |

## 后果

- **升号**：改 ID、改承载页路径、判据措辞变化 → **major，3.0.0**（`spec/README.md`「版本策略」）。
- 判据的**判定结果不变**：每条改写前后对同一仓库的合格/不合格结论一致（改写验收标准）。
- 可操作性靠附录保住：读者从判据的通用术语跳到 `spec/mechanism-map.md` 找自己工具的对应文件。
- 本库自身受益：规范终于能"指导"用任何 harness 的仓库，而不是让一半读者在清单里找不到自己。

## 怎么回退

`git revert` 本次改写提交即可；旧 ID、旧判据句、旧措辞全部原样回来。
新术语与旧文件名的对应关系在本 ADR 的术语表里，回退不需要额外翻译表。
