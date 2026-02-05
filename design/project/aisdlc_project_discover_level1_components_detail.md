---
title: 项目 Discover（Level-1 / components-detail）— 产物生成设计规范
status: draft
stage: project_discover
module: PD2
principles_ref: design/aisdlc.md
source_refs:
  - design/aisdlc_project_discover.md
  - .aisdlc-cli/commands/discover-level1-components-detail.md
  - .aisdlc-cli/templates/project/components-module-template.md
  - .aisdlc-cli/templates/project/contracts-api-module-template.md
  - .aisdlc-cli/templates/project/contracts-data-module-template.md
  - .aisdlc-cli/templates/project/contracts-index-template.md
  - .aisdlc-cli/templates/project/contracts-api-index-template.md
  - .aisdlc-cli/templates/project/contracts-data-index-template.md
---

## 0. 目标与定位

本设计文档用于定义 Project Discover 阶段 PD2「Level-1 / components-detail（组件明细 + 模块契约 + 多索引回填）」的**框架性规则、硬约束与验收标准**。

PD2 的目标是对 `components/index.md` 中所有未执行（`- [ ]`）的组件任务逐一闭环：

- 生成组件明细：`.aisdlc/project/components/{module}.md`
- 生成模块级契约入口文件（按模块名落盘）：
  - `.aisdlc/project/contracts/api/{module}.md`（API + 事件/消息）
  - `.aisdlc/project/contracts/data/{module}.md`（数据对象/Schema/字典/指标/迁移入口）
- 回填 contracts 三个索引与 components 索引（索引只做导航）
- 更新任务状态与审计信息（复选框、Assumption/TBD、结果与日期）

---

## 1. 术语与接口

### 1.1 输入输出

- **输入（固定）**：`.aisdlc/project/components/index.md`（任务清单为权威）
- **输出（生成）**：
  - `.aisdlc/project/components/{module}.md`
  - `.aisdlc/project/contracts/api/{module}.md`
  - `.aisdlc/project/contracts/data/{module}.md`
- **输出（回填更新，必须）**：
  - `.aisdlc/project/components/index.md`
  - `.aisdlc/project/contracts/index.md`
  - `.aisdlc/project/contracts/api/index.md`
  - `.aisdlc/project/contracts/data/index.md`

### 1.2 前置条件（MUST）

- Level-0 四份 memory 已存在（同 PD1 前置条件）
- 已执行 PD1，生成 Level-1 索引骨架，并回填 `components/index.md` 的组件清单与任务复选框

### 1.3 User Input（可选）

- `$ARGUMENTS` 若不为空：必须纳入本次执行的关注点（例如优先模块、运行形态、先覆盖关键链路等）
- **执行范围不得用参数控制**：范围只能通过 `components/index.md` 的复选框控制

---

## 2. 强制门禁与总流程（MUST）

### 2.1 操作约束（MUST）

- **非破坏性**：仅生成/更新 `.aisdlc/project/` 下文档；不得修改业务代码。
- **证据优先**：任何结论必须回链仓库证据；不确定必须标注 Assumption/TBD 并给验证线索。
- **边界一致性（强制）**：组件边界/依赖方向/禁止事项必须与 `memory/structure.md` 一致；冲突处一律写 TBD。
- **索引只做导航（强制）**：components/contracts 索引只保留入口链接 + 一句话摘要 + 状态/证据；详细条目以模块文件为权威。

### 2.2 执行顺序（MUST）

1. 从 `components/index.md` 筛选任务：仅处理 `- [ ]`（未执行）的模块条目
2. 逐模块迭代闭环（每次只处理一个 `{module}`）：
   - 生成 `components/{module}.md`
   - 生成 `contracts/api/{module}.md` 与 `contracts/data/{module}.md`（若目录不存在先创建）
   - 回填 contracts 索引与 components 索引
   - 更新复选框为 `[x]`，更新 Assumption/TBD，追加执行记录（结果 + 日期）

> 关键约束：必须“单模块闭环后立刻回填与更新任务状态”，禁止先生成一堆模块文件再统一回填（会产生不可审计的半完成状态）。

---

## 3. 最小上下文原则（强制）

PD2 在“逐模块迭代”时必须遵循：

- 将当前 `{module}` 视为独立任务：禁止引用/继承其它模块的实现细节与结论来“类比补全”
- 允许使用的上下文仅包含：
  - 通用规则（本设计文档 + `design/aisdlc.md` + `memory/*`）
  - 当前 `{module}` 的任务条目
  - 当前 `{module}` 的证据（路径/片段/命令输出）
- 证据不足时：只能写 Assumption/TBD，并给验证线索（路径/命令/Owner）

---

## 3.1 深目录证据定位（强制，解决“目录太深拿不到真实信息”）

当项目较大、组件目录较深或存在 Monorepo/多入口时，PD2 必须按以下顺序定位并记录证据，确保“深度无关 + 可审计 + 可回跑”。该规则适用于：

- `components/{module}.md` 的 `related_code`（代码入口证据）
- `contracts/api|data/{module}.md` 中每条接口/事件/Schema 的“证据入口”

### 3.1.1 三段式定位（必须按顺序执行）

- **阶段 A：索引锚点优先（MUST）**  
  以 `.aisdlc/project/components/index.md` 中该组件的“主要代码入口”作为**主锚点**（可为目录或入口文件，允许很深）。必须把该锚点写入 `components/{module}.md` 的证据锚点清单。

- **阶段 B：契约/数据 SSOT 回推（MUST）**  
  若阶段 A 无法唯一确定真实入口或关键接口/事件/Schema，必须优先从“权威契约入口”回推归属：OpenAPI/Proto/Schema/迁移脚本/字典等（以 `memory/tech.md` 的 SSOT 约定为准）。在契约文件中记录：**SSOT 文件 → 归属依据 → 代码证据入口**。

- **阶段 C：全局搜索回退（MUST）**  
  若仍无法定位：只能通过“关键词驱动的全局搜索”构造最短证据链，禁止枚举遍历整个深目录树来“碰运气”。关键词来源建议为：模块名/术语同义词、路由前缀、Topic/Event 名、表名/集合名、迁移号等。

### 3.1.2 证据锚点最小集（MUST）

对每个 `{module}`，必须在 `components/{module}.md` 中给出 **3～7 个**“证据锚点（Evidence Anchors）”，且至少满足：

- 1 个 **主锚点**：来自 `components/index.md` 的主要代码入口（目录或入口文件）
- 1 个 **归属证明锚点**：能证明该组件“可运行/可被调用/可被触发”的入口（例如：web 入口、路由/handler、consumer/job/cli 入口、DI/Module 注册点等）
-（可选但推荐）按证据可得补齐：API 入口、消息入口、数据入口（schema/migration/dictionary）

> 若只能找到 1 个锚点：必须将该模块标注为 assumption/TBD，并给出下一步验证线索（路径/命令/Owner）。

### 3.1.3 预算与止损（MUST）

为避免“深目录 + 大仓库”导致上下文超限与长时间扫描，PD2 必须设置止损：

- **单模块证据锚点上限**：最多保留 7 个（其余以“搜索关键词/目录线索”方式写入 TBD）
- **单模块接口/事件/Schema 证据上限**：每类最多保留 Top 10（以“对外接口/核心事件/核心对象”为优先）；超过部分只保留索引入口与搜索线索

---

## 4. 模板映射与字段回填规则（按文件）

### 4.1 `components/{module}.md`（应用组件明细）

- 模板：`.aisdlc-cli/templates/project/components-module-template.md`
- 必须回填最少必要且可证实的信息：
  - `related_code`：模块代码入口证据（必须包含“证据锚点最小集”，见 3.1）
  - `contracts`：必须指向本次生成的模块契约文件入口
  - 边界/依赖/禁止事项：引用 `memory/structure.md` 的规则（证据）
- “Contracts（入口与摘要）”章节只保留：
  - 入口链接（`contracts/api|data/{module}.md`）
  - 一句话摘要
  - 证据入口
  - 禁止双写具体接口/字段条目（以契约文件为权威）

### 4.2 `contracts/api/{module}.md`（API + 事件/消息契约入口）

- 模板：`.aisdlc-cli/templates/project/contracts-api-module-template.md`
- 必须覆盖两类清单（按证据能定位的范围）：
  - REST/HTTP/gRPC/GraphQL（提供与消费）
  - 事件/消息（生产与消费）
- 权威性规则（强制）：
  - 优先指向 OpenAPI/Proto/Schema 文件
  - 若无独立契约文件，退化为代码入口（类型定义/handler/client）
- 每个接口/事件必须提供“代码证据入口”；无法证实写 Assumption/TBD

### 4.3 `contracts/data/{module}.md`（数据契约入口）

- 模板：`.aisdlc-cli/templates/project/contracts-data-module-template.md`
- 必须覆盖（按证据能定位的范围）：
  - 数据对象与责任边界（Owner/主写/只读）
  - Schema（表/集合、JSON/Avro/Proto 等）
  - 字典与枚举
  - 指标口径（如有）
  - 数据质量规则（如有）
  - 迁移入口（如有）
- 权威性规则同上：优先 Schema/字典文件；退化为代码或迁移脚本入口

---

## 5. 索引回填规则（MUST）

### 5.1 回填 contracts 索引（必须）

对每个 `{module}` 必须回填：

- `project/contracts/index.md`
- `project/contracts/api/index.md`
- `project/contracts/data/index.md`

索引回填只保留：

- 入口链接（指向 `contracts/*/{module}.md` 或权威契约文件）
- 一句话摘要/语义
- 状态（fact/assumption/tbd 或 active/deprecated 等项目约定）
- 证据入口

### 5.2 回填 components 索引（必须）

对 `project/components/index.md` 必须更新：

- 总览表：补齐/更新一句话职责、关键接口/事件、代码入口、Owner、状态（可保留“待回填”的能力/服务）
- 清单（链接）：将对应 `{module}` 的复选框从 `- [ ]` 改为 `- [x]`

---

## 6. 任务状态更新与审计（MUST）

对每个成功闭环的 `{module}`，必须在 `components/index.md` 的任务条目下：

1. 将复选框更新为 `- [x]`
2. 更新 Assumption/TBD：
   - 已确认/已解决的条目必须标记“已确认/已解决”或移除，并写明依据
   - 仍未确认的条目必须更具体，并保留验证线索
3. 追加执行记录（最小字段）：
   - `- 结果：已生成 .aisdlc/project/components/{module}.md`
   - `- 日期：YYYY-MM-DD`

---

## 7. 可分批执行策略（推荐）

为降低上下文超限与失败重跑成本，允许“分批执行”：

- 只保留本批次要处理的模块为 `- [ ]`
- 其余模块先标记为 `- [x]`（表示暂不处理，非真实完成也可，但需在条目中说明原因/批次策略）
- 运行 PD2 时只处理 `- [ ]`

---

## 8. 自检校验（PD2-DoD）

- [ ] 本批次所有 `- [ ]` 的组件均已完成（或明确记录阻塞原因），并将复选框更新为 `- [x]`
- [ ] 对每个已完成组件 `{module}` 均已落盘以下文件：
  - [ ] `.aisdlc/project/components/{module}.md`
  - [ ] `.aisdlc/project/contracts/api/{module}.md`
  - [ ] `.aisdlc/project/contracts/data/{module}.md`
- [ ] contracts 三个索引与 components 索引均已回填，且索引只做导航（入口链接 + 一句话摘要 + 状态/证据）
- [ ] 任务条目下 Assumption/TBD 已按本次验证结果更新，并写入执行记录（结果 + 日期）

