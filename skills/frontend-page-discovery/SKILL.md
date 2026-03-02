---
name: frontend-page-discovery
description: Use when 需要从前端代码证据化产出“页面清单→功能点→业务流程→业务规则”，且项目路由入口不唯一、动态路由/权限/后端菜单复杂、团队容易脑补或遗漏证据链时。
---

# 前端页面清单逆向（证据化）

## 概览

目标：**只基于代码证据**，先产出“页面清单（Page Inventory）”，再从页面反推功能点、业务流程与业务规则，帮助快速理解项目并沉淀为可复核的文档资产（默认落盘到 `docs/`）。

核心原则：**先页面清单，再流程规则；先证据，再结论；缺证据就写 Evidence Gaps，禁止脑补。**

开始时宣布：**「我正在使用 frontend-page-discovery 技能，从前端代码证据化产出页面清单与业务流程/规则。」**

> 重要：本技能是“通用逆向方法论”。如果当前仓库不包含前端工程代码，它仍然可用于分析“目标仓库/目标目录”的前端代码。

## 何时使用 / 何时不使用

**使用时机（触发信号）**
- 你需要从前端代码得出**可追溯**的页面清单，并继续提炼流程/规则
- 项目路由入口复杂：多 SPA/微前端/多框架共存、运行时注入路由、后端下发菜单
- 团队常见问题：漏页、重复页、权限/动态路由无法落盘、规则总结缺证据
- 你希望用并行子代理加速“页面清单”阶段，并在汇总时可去重/可审计

**不使用时机**
- 你只需要写 PRD/原型（这不是代码逆向）
- 你被要求“没代码也要给出你项目的真实页面清单/规则结论”（此时只能交付模板/示例，不能输出事实）

## 本技能的默认交付物（落盘到 docs/）

推荐输出形状（可按目标仓库调整，但必须保持“可追溯与可复核”）：

- `docs/frontend/pages/index.md`
  - 页面清单总表（表格）
  - Route/Menu/Nav 的覆盖与差集审计（漏页/重复的可见化）
  - 证据索引（路由入口、菜单入口、鉴权入口、API client 等）
- `docs/frontend/pages/<page_id>.md`
  - 单页证据包：功能点、用户旅程、业务规则、关键状态、证据与缺口
- `docs/frontend/flows/index.md`
  - 跨页面业务流程索引（引用 page_id 与 rule_id）
- `docs/frontend/conflicts.md`
  - 冲突并存清单（不无证据裁决；给出复核动作）

## 落盘模板（最小可用，可直接复制）

### `docs/frontend/pages/index.md`

```md
# 前端页面清单（Page Inventory）

## 范围与证据入口
- FrontendRoots:
  - <path>（证据：file:lines）
- RouteEntrypoints:
  - <path>（证据：file:lines）
- MenuEntrypoints:
  - <path>（静态/后端下发；证据：file:lines）
- AuthEntrypoints:
  - <path>（guard/middleware；证据：file:lines）
- ApiClientEntrypoints:
  - <path>（axios/fetch/client；证据：file:lines）

## 去重与审计口径
- PageKey: NormalizedPath + EntryFile
- NormalizedPath 规则：:id/[id]/{id} → {param}；[...slug] → {*param}
- 并集：Routes ∪ Menus ∪ NavCalls
- 差集审计：
  - MenuPaths - RoutePaths: ...
  - RoutePaths - MenuPaths: ...
  - NavCalls - (Routes ∪ Menus): ...

## 页面清单（事实表）
| page_id | route_forms | normalized_path | entry_file | reachability | auth | data_deps | evidence_links | evidence_gaps |
|---|---|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... | ... | file:lines | ... |

## Evidence Gaps（全局）
- gap: ...
  candidate_locations: ...
  impact: ...
```

### `docs/frontend/pages/<page_id>.md`

```md
# <page_id>

## Page
- route_forms: ...
- normalized_path: ...
- entry_file: ...
- layout/shell: ...
- reachability: public|guarded|direct-link|internal-only|unknown

## Evidence（最小证据包）
- type: ...
  file: ...
  lines: ...
  how: ...
  excerpt: ...

## 功能点（Feature points）
- FP-001: ...
  evidence: file:lines

## 用户旅程（User journeys）
- J-001: 入口 → 关键步骤 → 出口
  evidence: ...

## 业务规则（Rules）
- rule_id: ...
  statement: ...
  trigger: ...
  condition: ...
  outcome: ...
  evidence:
    - file:lines
  evidence_gaps: []

## 关键状态（如有）
- state_field: ...
  evidence: file:lines

## Evidence Gaps
- gap: ...
  candidate_locations: ...
  impact: ...
```

### `docs/frontend/flows/index.md`

```md
# 业务流程索引（跨页面）

## Flow 列表
- flow_id: ...
  pages: [<page_id>, <page_id>]
  rules: [<rule_id>, <rule_id>]
  evidence: file:lines
```

### `docs/frontend/conflicts.md`

```md
# 冲突清单（不裁决，只并存）

- page_id: ...
  conflict: entry_file candidates
  candidates:
    - value: ...
      evidence: file:lines
    - value: ...
      evidence: file:lines
  next_actions:
    - 去哪里找更强证据：<path/keyword>
```

## 硬规则（出现任一条：停止并纠正）

1. **禁止脑补**
   - 任何“页面/流程/规则”必须能指向证据（见下方证据格式）；否则写入 `Evidence Gaps`，不得写推测性结论。
2. **事实与示例必须物理隔离**
   - 若用户要求“大胆假设、不用证据”，只能输出 `EXAMPLE（示例）` 区块或模板；不得把示例写成项目事实，也不得与事实表格混排。
3. **页面清单必须可去重与可审计**
   - 必须定义 `PageKey`（去重主键）并做三路并集与差集审计：`Routes ∪ Menus ∪ NavCalls`。
4. **动态路由必须输出参数契约**
   - 对每个参数化页面输出：参数来源（path/query/state）、类型/约束、默认值、非法/缺失时的处理路径（证据化或缺口化）。
5. **并行扫描必须先对齐输出 schema 与汇总规则**
   - 子代理输出必须符合统一字段；汇总必须执行去重/证据合并/冲突并存规则（见“并行子任务”）。

## 证据格式（统一可复核）

每条结论至少附 1 条证据，推荐统一结构（可用 Markdown 列表或 YAML 风格，关键是字段齐全）：

- **type**：`route_decl | file_convention | menu_static | menu_backend | nav_call | guard | api_call | state_machine | form_validation | other`
- **strength（可选，但推荐）**：`strong | medium | weak`
- **file**：相对路径
- **lines**：`start-end`
- **how**：如何命中（路由注册/目录约定/grep 命中/调用链）
- **excerpt**：1–3 行关键摘录（原文）

证据强度建议（用于汇总时更好地处理冲突，不用于“无证据裁决”）：
- **strong**：路由注册点/框架约定页面入口/guard 或 middleware 的可执行逻辑
- **medium**：菜单映射到路由/组件的构建函数、明确的 component 映射表
- **weak**：纯搜索命中但缺调用链（例如只找到字符串路径常量）

缺证据时，必须写：

- **gap**：缺什么证据
- **candidate_locations**：可能在哪里找到（目录/文件类型/关键词）
- **impact**：对结论的影响（例如“无法确认是否存在后端下发菜单导致的隐藏页面”）

## 页面去重主键（PageKey）与规范化（NormalizedPath）

### PageKey（推荐双主键）
- **NormalizedPath**：将动态段统一成占位符
- **EntryFile**：页面入口文件（或路由指向的组件文件）

### NormalizedPath 规范化规则（示例）
- React Router：`/orders/:id` → `/orders/{param}`
- Next.js：`/orders/[id]` → `/orders/{param}`
- catch-all：`/[...slug]` → `/{*param}`

### 合并/拆分策略（必须显式写入 `docs/frontend/pages/index.md`）
- **同 NormalizedPath 不同组件**：保留候选项并进入 `conflicts.md`，必要时按 guard/flag 条件拆分子页面
- **不同路径同组件**：视为别名（alias），以 EntryFile 合并，路径作为别名记录

## 执行流程（从清单到流程与规则）

### Phase 0：定位前端根与路由体系（止损）

目的：确定“证据入口”在哪里，避免在单仓多项目里跑偏。

最低要求（满足其一即可开始）：
- 找到前端工程根（例如包含 `package.json` / `src/` / `app/` / `pages/` 等）
- 或者找到路由入口文件（见 Quick reference 的关键词）

输出：`docs/frontend/pages/index.md` 的“证据入口索引”骨架（先写入口，不写结论）。

### Phase 1：构建 3 个证据索引（并集 + 差集审计）

**1) Route Evidence Index（最强）**
- 路由注册点、路由表、重定向、嵌套路由、路由 meta（title/roles/hidden）

**2) Menu/Nav Evidence Index（次强）**
- 静态菜单配置（sidebar/nav）
- 后端下发菜单接口 + 消费点（`getMenu()`、`buildRoutesFromMenu()`、`componentMap[...]`）

**3) Navigation Calls Index（补漏）**
- 命令式导航：`navigate(` / `router.push` / `Link to=` / `href=`
- 深链/通知跳转 handler

> 差集审计（必做）：
> - `MenuPaths - RoutePaths`：可能是运行时注入/缺实现/环境裁剪
> - `RoutePaths - MenuPaths`：可能是隐藏页/直链页/系统页
> - `NavCalls - (Routes ∪ Menus)`：可能是拼接路径/废弃入口/动态生成

### 特殊场景处理（命中就必须落盘，不允许略过）

**1) 后端下发菜单 / 运行时注册路由**
- 必须证据化：
  - 菜单接口（endpoint 或 client 函数）
  - 消费与映射函数（例如 `buildRoutesFromMenu()` / `componentMap[...]`）
  - “菜单项字段 → 路由/组件”的映射规则
- 输出要求：
  - `MenuPaths - RoutePaths` 的差集必须有解释：运行时注入 / 缺实现 / 环境裁剪 / 仅后端保留
  - 无法解析到组件时：进入 Evidence Gaps（写清楚缺哪个映射表/动态 import 逻辑）

**2) 权限不可达页面（guarded / internal-only）**
- 必须输出 `reachability`，并给出“可达条件”证据（guard/middleware/meta.roles/permission check）。
- 菜单隐藏不是强证据：只能作为弱证据附注，不能单独决定 reachability。

**3) 多前端根/微前端/多框架共存**
- Phase 0 必须列出多个 FrontendRoots，并在 `pages/index.md` 写清楚“每个 root 的路由体系与证据入口”。
- 不允许把多个 root 的页面混成一张表却不标注来源，否则去重与差集审计会失真。

**4) 动态路由参数矩阵**
- 对 `/{param}` 或 `/{*param}` 类页面族，必须在单页文档里输出参数契约与枚举证据（常量表/schema/后端返回）。

### Phase 2：生成页面清单总表（Page Inventory）

将三路证据并集归并成表格（建议列）：
- **page_id**：稳定 ID（建议 `NormalizedPath` 派生，必要时加 guard/flag 后缀）
- **route_forms**：原始路由形式集合（`/x/:id`、`/x/[id]`…）
- **normalized_path**
- **entry_file**：入口组件/页面文件
- **reachability**：`public | guarded | direct-link | internal-only | unknown`
- **auth**：访问条件摘要（仅在证据足够时）
- **data_deps**：关键 API/query（仅在证据足够时）
- **evidence_links**：证据列表（指向文件/行号）
- **evidence_gaps**：缺口列表（结构化）

### Phase 3：从页面反推流程与规则（先 Top N，再铺开）

对每个 `docs/frontend/pages/<page_id>.md`，按证据提炼：

**1) 功能点（Feature points）**
- 以 UI 事件（按钮/表单/向导步骤）为锚，绑定到调用链（mutation/API/dispatch）

**2) 业务流程（User journeys / Flows）**
- 入口（从哪进入）→ 关键步骤（事件/接口/状态变化）→ 出口（成功/失败/取消）
- 允许用 Mermaid 画流程，但每条边必须能回指证据或缺口

**3) 业务规则（Rules）**
规则来源优先级（强→弱）：
- 状态机/枚举分支（`switch(status)`、`allowedActions(status)`）
- 表单校验 schema（Yup/Zod/JSONSchema/AntD rules）
- 权限守卫（middleware/guard/meta.roles/permission check）
- 错误码分支（`if (code === ...)`）

规则模板（建议统一编号便于引用）：
- **rule_id**：例如 `Orders.Detail.Action.Edit.Allowed`
- **statement**：可验收陈述
- **trigger**：触发点（UI 事件/页面进入/API 响应）
- **condition**：条件（状态/角色/字段组合）
- **outcome**：结果（允许/禁止/跳转/提示/提交 payload 变化）
- **evidence**：证据列表
- **evidence_gaps**：缺口（如有）

## 并行子任务（页面清单阶段，参考 dispatching-parallel-agents）

当你面对 2+ 个相互独立的证据域时，允许并建议并行扫描。并行前必须先完成：
- **统一输出 schema（PageRecord）**
- **统一证据格式**
- **统一合并与冲突规则**

### PageRecord（子代理统一输出字段）
- `page_id`
- `route_path`（可空，但必须解释为什么）
- `entry_evidence[]`
- `component` / `entry_file`
- `component_evidence[]`
- `auth`（可选）+ `auth_evidence[]`
- `data_deps[]`（可选）+ `data_evidence[]`
- `notes`（只允许证据化备注）
- `conflicts[]`（候选项并存 + 证据）
- `unknowns[]`（缺什么证据 + 候选位置 + 影响）

### 并行拆分的独立域（推荐 6 域）
- **RouteSurface**：路由注册/路径集合/重定向/动态段模式
- **PageImpl**：页面入口文件与布局壳（反链到路由或约定）
- **AuthZ**：鉴权/权限守卫/401-403
- **DataDeps**：API/Query/Mutation/Server actions 的页面绑定
- **Errors**：404/500/ErrorBoundary/fallback/maintenance
- **NonRouteEntrypoints**：模态“伪页面”、向导、deeplink、通知跳转、feature flag 变体

### 汇总合并规则（Coordinator 必须执行）
- **去重（Dedup）**：以 `PageKey = NormalizedPath + EntryFile` 为主；`route_path` 不足时以组件证据补齐
- **证据合并（Evidence merge）**：同字段证据去重并保留强弱标签（路由注册强于 grep 命中）
- **冲突处理（Conflict）**：不无证据裁决；进入 `docs/frontend/conflicts.md`，并给出“下一步复核动作”

### 子代理提示模板（可直接复制）

> 注意：子代理只做“发现 + 证据化输出”，不得输出项目事实性的推断结论；缺证据写 unknowns/gaps。

#### 模板：RouteSurface 扫描器

你是“RouteSurface 扫描器”。目标：找出所有路由注册点与可达路径集合，并把“路径 -> 目标组件/handler”证据化。

约束：
- 禁止脑补；每条 route/path 必须有证据（file+lines+excerpt）。
- 不深入页面内部；只输出页面入口映射与路由层信息。

输出：
- PageRecord[]（page_id 优先用 `[METHOD] [PATH]`，method 不明可空）
- conflicts[]：同一路径指向多个组件或条件路由
- unknowns[]：发现动态生成路由但找不到生成源

#### 模板：PageImpl 扫描器

你是“PageImpl 扫描器”。目标：识别页面入口文件（pages/views/screens/app/**/page.* 等），并找到其被路由/入口引用的证据。

约束：
- “看起来像页面”不算页面；必须有入口证据（路由注册/文件约定/导航指向）。
- 复用组件/组件库不要输出，除非它被证据化为页面入口。

输出：
- PageRecord[]（route_path 可空，但 component_evidence 必须强）
- unknowns[]：找到页面文件但找不到入口引用（列出缺的证据点）

#### 模板：AuthZ 扫描器

你是“AuthZ 扫描器”。目标：为页面补齐访问条件（登录/角色/权限码/feature flag），仅在证据充分时写入。

约束：
- 只能在能定位到 page_id（route_path 或 entry_file）时写 auth。
- 优先采用可执行逻辑证据（middleware/guard/meta.roles/permission check）；菜单隐藏只能当弱证据附注。

输出：
- PageRecord[]（填 auth/auth_evidence）
- conflicts[]：同页多处 auth 规则不一致或覆盖关系不清
- unknowns[]：鉴权框架存在但无法映射到页面（缺映射点）

#### 模板：DataDeps 扫描器

你是“DataDeps 扫描器”。目标：输出页面级关键数据依赖（首屏查询/提交 mutation/导出等），并证据化绑定到页面。

约束：
- 必须给出“页面 -> 调用点 -> API client/endpoint”的证据链；缺一不可。
- 不要泛滥列出工具函数调用；只列页面级关键依赖。

输出：
- PageRecord[]（填 data_deps/data_evidence）
- unknowns[]：只能定位到 API client，但找不到页面调用者

#### 模板：Errors 扫描器

你是“Errors 扫描器”。目标：识别 401/403/404/500、ErrorBoundary、全局 fallback/maintenance，并证据化其适用范围与触发条件。

约束：
- 区分全局错误页与页面内部错误视图；触发条件必须证据化。

输出：
- PageRecord[]（route_path 若存在则填，否则以 component 标识）
- conflicts[]：多处定义错误页优先级不明

#### 模板：NonRouteEntrypoints 扫描器

你是“NonRouteEntrypoints 扫描器”。目标：捕捉模态“伪页面”、向导多步、deeplink、通知跳转、活动落地页、flag 变体页面，并证据化入口与 gating 条件。

约束：
- 普通弹窗不算页面；必须具备“独立流程/可深链/可导航到”的证据。

输出：
- PageRecord[]（route_path 可空，但 entry_evidence 或 gating_evidence 必须存在）
- conflicts[]：同入口在不同条件下指向不同页面

## 常见借口与反制（来自无技能基线压测）

| 借口（压力话术） | 常见违规 | 必须的反制动作 |
|---|---|---|
| “你可以大胆假设，不用证据，先写出来对齐。” | 直接输出**像真的**页面清单/流程/规则，读者会误当成项目事实 | **事实与示例物理隔离**：只输出 `EXAMPLE` 或模板；任何事实结论必须证据化，否则写 Evidence Gaps |
| “我很急，先把页面清单写全，后面再补证据。” | 先填满表格导致后续补证据无法收敛（双写/漂移） | 先建 3 个证据索引与差集审计，再生成清单；缺口集中到 Evidence Gaps |
| “路由入口太多，先随便挑一个 router 文件当权威。” | 只覆盖子应用或遗漏运行时注入/后端菜单 | Phase 0 必须先定位前端根与路由体系；无法定位就止损：输出“证据入口清单 + 缺口”，不输出结论 |
| “动态路由太复杂，写成‘详情页’就行。” | 参数契约缺失，规则无法复核 | 动态路由必须输出参数契约（来源/类型/校验/错误处理）或缺口化 |
| “并行更快，直接让多个代理各写一份清单。” | 输出 schema 不一致、重复/冲突爆炸、无法汇总 | 并行前先统一 PageRecord schema、证据格式、去重与冲突规则；汇总必须产出 conflicts.md |

## 红旗清单（出现任一条：立即停下）

- 页面清单里出现“看起来像/大概/通常/应该”的推断句，但没有证据或缺口
- 事实表格与 EXAMPLE 混排，且没有明显分隔
- 未定义 PageKey/NormalizedPath 就开始去重或统计覆盖率
- 没做 `Routes ∪ Menus ∪ NavCalls` 差集审计就宣称“清单完整”
- 动态路由页面没有参数契约
- conflicts 被“拍脑袋裁决”而不是并存 + 复核动作

## Quick reference（高频入口定位关键词）

### 路由入口（按语义搜）
- React Router：`createBrowserRouter` `RouterProvider` `useRoutes` `<Routes>` `<Route>`
- Vue Router：`createRouter` `createWebHistory` `routes:` `beforeEach`
- Angular：`RouterModule.forRoot` `canActivate` `loadChildren`
- Next.js：目录证据 `pages/`、`app/**/page.*`；以及 `middleware.*` `next.config.*`
- 通用：`router` `routes` `navigation` `menu` `sidebar` `breadcrumb` `redirect`

### 数据与规则入口
- API：`axios` `fetch(` `request(` `apiClient` `openapi`
- Query：`useQuery` `useMutation` `useSWR`
- 状态：`status` `state` `enum` `switch(` `createMachine`
- 表单校验：`yup` `zod` `joi` `schema` `rules:`
- 权限：`permission` `roles` `guard` `RequireAuth` `ProtectedRoute` `401` `403`

## 常见错误

- 把“菜单可见”当成“路由可达”（菜单只是一个视角，必须做差集审计）
- 只从文件约定列页面，不追踪路由注册与导航调用（容易漏“隐藏页/直链页/注入页”）
- 只写流程图不写规则证据（流程可视化必须回指证据/缺口）
- 把“组件库里的弹窗”当页面（没有独立入口证据就不算页面条目）

