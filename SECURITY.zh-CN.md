# 安全策略

[English](SECURITY.md) · [简体中文](SECURITY.zh-CN.md)

## 支持版本

只对最新 `specVersion` 提供修复。旧版本请先升级。

| 版本 | 支持 |
|---|---|
| 1.x | ✅ |

## 报告漏洞

**不要开公开 issue。** 用 GitHub 的私密上报入口：仓库页 → Security → *Report a vulnerability*。

请在报告里包含：

- 受影响的 `specVersion`，以及具体的文件与小节；
- 最小复现：哪一条规则、哪一行模板、哪一句结论不成立，对照的是什么（一个仓库结构、一次可观测的平台行为、一份官方文档链接）。**不要贴真实密钥**；
- 影响类型——选一个，它决定我们下一步做什么：
  - **判据错了** —— 这条规则把好仓库判红，或把坏仓库判绿；
  - **模板有害** —— 照抄某一行模板反而**削弱**仓库（过宽的 `permissions`、一个永远不触发的闸门）；
  - **引用失效** —— 这里写的路径、命令或平台行为已经不再成立；
  - **指令注入** —— 本库里的某段内容，被读到它的 agent 当成指令执行了；
- 你的期望结果。

我们会在 **3 个工作日**内确认收到，**10 个工作日**内给出评估结论。

## 本仓库自身的风险面

这里没有可执行代码（[ADR-0009](docs/adr/0009-spec-only-no-tooling.md)），所以没有可被利用的代码。
真正**可执行的是文本**：一个采用这套规范的仓库，会把它当作指令喂给 agent。三条真实攻击面：

1. **文档是被当作指令执行的。** [spec/agent-playbook.md](spec/agent-playbook.md)、[spec/rules/README.md](spec/rules/README.md)
   和 [AGENTS.md](AGENTS.md) 都用祈使句写（"按下面的顺序做，不要跳步"）。那里一句过期或写错的句子不是笔误，
   而是每一个下游 agent 都会照做的坏指令。这就是规则只保留一份事实源的原因，也是 ADR-0009 选择删掉检查器、
   而不是让同一条规则存在两份描述的原因。
2. **模板照抄会削弱仓库。** [templates/settings.json.tmpl](templates/settings.json.tmpl) 与
   [templates/CODEOWNERS.tmpl](templates/CODEOWNERS.tmpl) 定的是权限基线和评审闸门。占位符没填、
   或 `deny` 清单和目标仓库的目录结构对不上，得到的就是一个"看着开着、其实没生效"的闸门。
   把每份模板当成一段要 review 的 diff，而不是一个直接落地的文件。
3. **外部行为会漂移。** 规则引用了 GitHub 与 agent 工具的行为——加载顺序、trailer 格式、必需检查的语义。
   它们改了不会通知你，所以一条写下来时为真的规则可能悄悄变成假指令。
   [docs/evidence/](docs/evidence/) 里的证据一律按采集日期存档，就是为了这件事：**没有日期的结论无法复核。**

## 已知的非问题

- 这里没有任何东西在你机器上运行：没有脚本、没有依赖清单、没有安装步骤。
- 这里没有任何东西联网回传。唯一的自动化是 [`.github/workflows/docs.yml`](.github/workflows/docs.yml)：
  它跑在 GitHub 的 runner 上，只检查本仓库自己的 markdown（链接、双语配对），不持有任何密钥
  （`permissions: contents: read`）。
