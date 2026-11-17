# 证据 · GitHub App 新权限不会自动生效（installation 才是闸）

- **采集时间**：2026-11-18
- **对象**：GitHub App `kujiraagent`（App ID `5791552`）· installation `182732500`（account `ArtomYuan`，repos=all）
  · 仓库 `ArtomYuan/agent-ready-repo-spec`
- **方法**：App 私钥签 RS256 JWT → `GET /app`、`GET /app/installations/{id}`、`POST /app/installations/{id}/access_tokens`
  → 用 installation token 执行 `PATCH /repos/{owner}/{repo}`
- **结论先行**：**在 App 的设置里勾了新权限 ≠ 这个权限已经能用。** 决定 token 能力的是 **installation 批准过的权限集**，
  不是 App 当前申请的权限集。

## 1. 三处回读，缺口只出现在后两处

`GET /app`（App 自己**申请**的权限）：

```
actions=read  administration=write  contents=write  deployments=read  discussions=read
environments=read  issues=write  metadata=read  pull_requests=write  repository_advisories=read
repository_creation=write  secret_scanning_alerts=read  security_events=read  statuses=read
vulnerability_alerts=read  workflows=write
```

`GET /app/installations/182732500`（installation **实际批准**的权限）：

```
issues=write  actions=read  contents=write  metadata=read  statuses=read  workflows=write
deployments=read  discussions=read  environments=read  pull_requests=write  security_events=read
repository_creation=write  vulnerability_alerts=read  repository_advisories=read  secret_scanning_alerts=read
```

→ **`administration` 这个 key 根本不存在**，不是 `read`，不是 `none`，是没有这一项。

`POST /app/installations/182732500/access_tokens` 返回的 `permissions` 与 installation 完全一致，
同样没有 `administration`。

## 2. 实际报错

```
PATCH /repos/ArtomYuan/agent-ready-repo-spec   { description: "...", topics: [...] }
```

```json
HTTP 403
{"message":"Resource not accessible by integration",
 "documentation_url":"https://docs.github.com/rest/repos/repos#update-a-repository",
 "status":"403"}
```

顺带：`GET /repos` 用这个 token 回读，`permissions.admin = false`、`permissions.push = false`——
installation 没批 `administration` 时，连"这个 token 在仓库里算不算管理员"都回答 false。

## 3. 从这段实测得出的四条规律

1. **判断 token 有没有某项权限，只看 `token.permissions` 里有没有那个 key。**
   去 App 的设置页看勾选状态会被骗——那里显示的是"申请"，不是"生效"。
2. **改仓库元数据（描述 / topics / 可见性）需要 `administration`，不是 `metadata`。**
   `metadata=read` 是只读仓库信息的权限，任何 App 装完都自带，它撑不起 `PATCH /repos`。
3. **报错形态**：权限没批 → `403 Resource not accessible by integration`；
   权限够但值不合法 → `422`。两者成因完全不同，别混。
4. **批准之前重签 token 没有用**：新 token 仍按 installation 的旧权限集签发（本次实测在改完 App 设置后
   重新签了三次，`administration` 始终缺席）。

## 4. 恢复路径（需要人类做一次，无 API 可替代）

1. `https://github.com/settings/installations` → **KujiraAgent** → **Configure**；
   页面会列出"新申请的权限"，确认授予。
2. 看不到申请项就**撤销安装再重装**（重装是最可靠的清零方式）。
3. 批准后**重新签 token**，再回读 `token.permissions` 确认 `administration=write` 出现了，才动手改。

**已验证闭环（同日）**：在 `settings/installations → KujiraAgent → Configure` 批准扩权之后重新签 token，
`installation.permissions` 与 `token.permissions` 两处**都出现了 `administration = write`**，
`PATCH /repos` 改描述随即成功。所以本文件的结论是完整的：卡住的是**批准**，不是申请。

## 5. 另一条静默失败：`PATCH /repos` 不认 `topics`

同一次操作里踩到的，与权限无关：

```
PATCH /repos/{owner}/{repo}   { description: "...", topics: [ ... ] }
→ 200 OK
→ description 生效
→ topics 一个都没变，也没有任何报错
```

改 topics 的正路是**另一个端点**，字段名也不同：

```
PUT /repos/{owner}/{repo}/topics   { "names": ["agent-governance", "..."] }
→ 200，返回体里直接带 names
```

**规律**：GitHub 的写接口回 2xx 只说明"这个请求合法"，**不说明你传的字段都被接受了**。
改完必须回读。同一类已知行为：`POST /pulls` 的 `assignees` 字段会被静默忽略，
必须事后补 `POST /issues/{n}/assignees`。

## 6. 纠正本库自己写错的一句

`CHANGELOG.md` 的 1.5.0 节原来写着：

> **待人工执行**：GitHub App 没有 Repository metadata 权限，`PATCH /repos` 返回 422，这一步改不了。

三处都不对：权限名是 `administration` 不是 `metadata`（后者一直是 `read`）；报错是 `403` 不是 `422`；
"改不了"的真正原因是 **installation 没批准新权限**，而不是 App 没申请。已在同一批改动里修正。
