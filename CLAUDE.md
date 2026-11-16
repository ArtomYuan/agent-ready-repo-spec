@AGENTS.md

## Claude Code 专属

- 改 `rules/rules.json` 前先读 [spec/agent-playbook.md](spec/agent-playbook.md) 的“改规则的流程”一节。
- 体检输出用 `-Format json` 再解析，不要靠肉眼读 text 输出做批量判断。
- 本仓库 `.ps1` 必须是 UTF-8 with BOM；用 Write 工具写完脚本后确认这一点。
- 长任务（改多条规则 + 重生成 + 自测）适合放 subagent，避免主上下文被大段 JSON 占满。
