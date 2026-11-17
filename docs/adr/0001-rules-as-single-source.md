# ADR-0001：规则用 JSON 做唯一事实源，Markdown 由它生成

- 状态：Superseded by [ADR-0009](0009-spec-only-no-tooling.md)（2026-11-17）：规则改为以 `spec/checklist.md` 为唯一事实源，JSON 与检查器已下线
- 日期：2026-11-16
- 决策者：@example-org/spec-owners、agent（claude-code，提案）

## 背景

规范天然有两种读者：人（要读得懂、能讨论）和工具（要能精确判定）。早期版本把规则写成散文，
结果是三种漂移：

1. 文档写“建议有 SECURITY.md”，检查器却按 `must` 判——同一个项目两套标准。
2. 加规则要改两处（说明 + 代码），总有一处忘。
3. agent 无法从散文里可靠地推导“这条要不要修、修成什么样”。

## 选项

1. **只写 Markdown**，检查器从文档里解析。散文解析不可靠，改个措辞就可能静默改变判定。
2. **只写代码**，判定散落在 `if` 里。人能读到行为，读不到“为什么”，也无法审阅规则变更。
3. **JSON 作事实源 + 生成 Markdown + 生成 `-Check` 校验**。
4. **YAML 作事实源**。比 JSON 好写，但需要解析器；本项目坚持零依赖。

## 结论

选 3。

- `rules/rules.json` 是唯一事实源，每条规则必须带 `rationale`（为什么）与 `fix`（怎么改）。
- `spec/RULES.md` 由 `checker/gen-rules-doc.ps1` 生成，文件头写“勿手改”。
- CI 跑 `gen-rules-doc.ps1 -Check`，生成物与源不一致即失败。

## 后果

**正面**

- 一条规则只有一处定义，人读生成物、机器读 JSON，不可能漂移。
- 规则的增删改在 diff 里一目了然，评审对象是数据而不是代码。
- agent 可以把 `results[].fix` 直接当作修复指令消费。

**负面**

- 判定逻辑仍要写在引擎里，JSON 只声明“用哪个 kind + 什么参数”。表达能力受 13 种 kind 限制。
- 生成物进版本库会多一次提交流程；用 `-Check` 在 CI 里兜住。
- 正则写在 JSON 里需转义（`\\.`），对不熟 JSON 的贡献者略不友好。

**缓解**

- `spec/RULES.md` 在 `.gitattributes` 里标 `linguist-generated`，PR 里默认折叠。
- 新增 kind 必须配 fixture 与 ADR，避免 kind 数量无序膨胀。
