---
title: D2 Design（模板）
status: draft
---

目的：产出可评审的**决策文档（RFC/Decision Doc）**，作为 implementation 的权威输入。不写“待确认问题/TODO”；未知统一进入第 5 节风险与验证清单。

落盘位置：`{FEATURE_DIR}/design/design.md`

## 0. 基本信息

- 需求标识（分支 / ID）：
- 标题（需求名 / RFC 名）：
- 作者：
- 评审人：
- 状态：draft / reviewing / approved
- 最后更新：YYYY-MM-DD
- 关联链接（讨论、资料、工单）：

## 1. 结论摘要（3–7 行）

- 一句话目标（要解决什么）：
- In / Out 边界（对齐 `requirements/solution.md`）：
- 推荐方案（一句话机制概述）：
- 关键取舍（1–2 句，指向“关键决策”）：
- 优先验证点（引用第 5 节编号，1–3 个）：

## 2. 范围与边界

- 系统边界（画边界，别画实现）：
- 影响面（上下游/数据口径/运维）：
- 明确不做什么（Out；对齐 `requirements/solution.md`）：
- 不变量（不会改变的语义/口径/安全边界）：

## 3. 推荐方案（1 个；按 C4 L1–L3）

### 3.1 C4-L1：System Context（系统上下文）

- 用户/角色：……
- 外部系统：……
- 系统边界：……
- 关键交互与主要输入输出：……
- 关键约束与不变量：……
- （可选）图：Mermaid / 等价结构

### 3.2 C4-L2：Container（容器/部署单元）

- 容器清单（服务/作业/数据库/缓存/队列等）：……
- 每个容器职责与主要技术选型：……
- 关键数据流：……
- 对外契约入口（contracts/事件/API）：……

### 3.3 C4-L3：Component（组件）

- 关键容器的组件拆分（职责/接口/依赖）：……
- 关键数据模型与状态流转（到“组件与接口”层级即可）：……
- 错误处理与幂等/一致性策略（原则与机制）：……

### 3.4 关键决策与取舍（≥3 条）

| # | 决策点 | 选择 | 取舍理由（为什么选它） | 若不满足前提的降级/替代 |
|---|---|---|---|---|
| D1 |  |  |  |  |
| D2 |  |  |  |  |
| D3 |  |  |  |  |

### 3.5 对外承诺要点

只写“要点 + 追溯链接”。字段/DDL/迁移脚本细节不写在本文件。

- 契约（API/事件）：变更要点 + `project/contracts/` 入口
- 契约（API/事件）：变更要点 + 组件页契约锚点（优先：`project/components/{module}.md#api-contract` / `#data-contract`；如项目另有 `project/contracts/` 目录则同时给入口）
- 权限：变更要点 + 追溯入口
- 数据口径：变更要点 + 追溯入口
- 兼容性：版本/废弃策略要点 + 追溯入口
- 迁移与回滚：承诺要点 + `project/adr/` 入口（如适用）

## 4. 与现有系统的对齐（必填；基于 `{FEATURE_DIR}/requirements/solution.md#impact-analysis`）

### 4.1 契约兼容性声明（逐模块）

对每个受影响模块，显式声明与现有契约的关系（兼容/扩展/破坏性变更），并引用组件页中的具体不变量：

- 模块：
  - API Contract：引用 `project/components/{module}.md#api-contract` 的不变量（逐条）
  - Data Contract：引用 `project/components/{module}.md#data-contract` 的不变量（逐条）
  - 兼容性结论：兼容 / 扩展 / 破坏性变更（说明原因与缓解）

### 4.2 ADR 合规声明（逐 ADR）

- ADR：
  - 是否遵守：是 / 否
  - 若否：需要新增 ADR / 修改 ADR / 调整方案（写清楚动作）

### 4.3 状态机 / 领域事件影响

引用 `project/components/{module}.md` 的 `## State Machines & Domain Events`，说明：

- 是否新增状态/事件：
- 是否改变状态迁移规则：
- 是否影响幂等/一致性/重试语义：

### 4.4 跨模块影响确认

基于 `project/components/index.md` 的依赖关系图，逐项确认受影响上下游已被考虑：

- 上游：
- 下游：
- 交互方式（API/事件/数据共享等）：

## 5. 影响分析

- 上下游系统影响：……
- 数据口径影响：……
- 运行与运维影响（监控/容量/告警/权限/审计）：……
- 迁移/回滚要点（机制级）：……

## 6. 风险与验证清单（可执行；所有不确定性仅写在此处）

| # | 风险/假设 | 验证方式 | 成功信号 | 失败信号 | Owner | 截止 | 下一步动作 |
|---|---|---|---|---|---|---|---|
| R1 |  |  |  |  |  |  |  |
| R2 |  |  |  |  |  |  |  |

## 7. 追溯链接

- `{FEATURE_DIR}/requirements/solution.md`（段落/条目/链接；必读#impact-analysis,提取受影响模块/不变量/ADR/跨模块影响）
- `{FEATURE_DIR}/requirements/prd.md`（如适用）
- `{FEATURE_DIR}/requirements/prototype.md`（如适用）
- `{FEATURE_DIR}/design/research.md`（如适用）
- `project/components/index.md`（依赖关系图）：
- 受影响模块 `project/components/{module}.md`（全文；契约/状态机/证据入口）：
- 相关 `project/contracts/` 入口（如适用）
- 相关 `project/adr/` 入口（如适用）

## 8. 迭代记录（追加，不覆盖）

- YYYY-MM-DD：本轮变更摘要（相对上一轮改了什么、为什么）

