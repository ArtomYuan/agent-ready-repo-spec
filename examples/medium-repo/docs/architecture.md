# Architecture — acme/fleet

> 示例文件：真实仓库里这里放**模块边界与数据流**，不放开会记录。

| Package | Owns | May depend on |
|---|---|---|
| packages/core | domain logic, validation | nothing |
| packages/sdk | generated client + thin wrappers | core |
| packages/cli | argument parsing, output formatting | core, sdk |

Dependency direction is one-way, cli → sdk → core. A backwards import breaks consumers who install the SDK alone.