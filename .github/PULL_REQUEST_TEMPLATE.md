## 改了什么

<!-- 一句话，然后列 2–5 条要点 -->

## 为什么

<!-- 关联 issue；没有 issue 先开一个。规则类改动说明它覆盖了哪个真实问题 -->

Closes #

## 影响面

- [ ] 规则判定条件变化（→ 必须升 `specVersion` + 更新 `CHANGELOG.md`）
- [ ] 检查器输出/退出码变化（→ 会在下游 CI 生效，需说明兼容性）
- [ ] 新增 `check.kind`（→ 需要 ADR + selftest 用例）
- [ ] 仅文档/模板（→ 无行为变化）

## 怎么验证的

<!-- 贴真实输出，不要写“已测试” -->

```
$ pwsh ./tests/selftest.ps1
...

$ pwsh ./checker/spec-check.ps1 -Target .
...
```

## 自检清单

- [ ] `rules/rules.json` 是唯一改动源，`spec/RULES.md` 由脚本重新生成（未手改）
- [ ] `pwsh ./tests/selftest.ps1` 全绿
- [ ] `pwsh ./checker/spec-check.ps1 -Target .` 达成 L3 且无 FAIL
- [ ] `CHANGELOG.md` 已更新；语义变化已升 `specVersion`
- [ ] 未引入 Node/Python 依赖
- [ ] `.ps1` 保存为 UTF-8 with BOM

## 需要 reviewer 特别看的地方

<!-- 明说“我不确定的部分”。这一节比上面所有节都重要 -->
