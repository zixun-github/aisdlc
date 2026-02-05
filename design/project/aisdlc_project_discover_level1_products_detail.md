---
title: 项目 Discover（Level-1 / products-detail）— 产物生成设计规范
status: draft
stage: project_discover
module: PD4
principles_ref: design/aisdlc.md
source_refs:
  - design/aisdlc_project_discover.md
  - .aisdlc-cli/commands/discover-level1-products-detail.md
  - .aisdlc-cli/templates/project/products-module-template.md
  - .aisdlc-cli/templates/project/products-index-template.md
---

## 0. 目标与定位

本设计文档用于定义 Project Discover 阶段 PD4「Level-1 / products-detail（业务模块明细生成 + 索引逐节回填）」的**框架性规则、硬约束与验收标准**。

PD4 的目标是对 `products/index.md` 中所有未执行（`- [ ]`）的业务模块任务逐一闭环：

- 生成 `.aisdlc/project/products/{module}.md`
- 按 `products-index-template.md` 的第 0-8 节规则，对 `products/index.md` 做逐节回填与一致性自检
- 更新复选框任务状态、Assumption/TBD、执行记录与变更记录

> 边界：PD4 只产出项目级业务地图层资产；需求级交付细节必须下沉到 `specs/<DEMAND-ID>/`。

---

## 1. 术语与接口

### 1.1 输入输出

- **输入（固定）**：`.aisdlc/project/products/index.md`（任务清单为权威）
- **输出（生成）**：`.aisdlc/project/products/{module}.md`
- **输出（回填更新，必须）**：`.aisdlc/project/products/index.md`

### 1.2 前置条件（MUST）

- Level-0 四份 memory 已存在（同 PD1 前置条件）
- 已执行 PD1，生成 `products/index.md` 索引骨架
- 已执行 PD3，并回填 `products/index.md` 的“业务模块清单（链接）”复选框任务

### 1.3 User Input（可选）

- `$ARGUMENTS` 若不为空：必须纳入本次执行的关注点
- 执行范围只能通过 `products/index.md` 的复选框控制（`- [ ]` 执行，`- [x]` 跳过）

---

## 2. 强制门禁与总流程（MUST）

### 2.1 操作约束（MUST）

- **非破坏性**：只生成项目级文档并更新索引；不得修改业务代码。
- **证据优先**：索引中的 Fact 必须可回链证据；不确定写 Assumption/TBD 并给验证线索。
- **边界一致性（强制）**：业务模块边界必须与 `memory/structure.md`、`memory/product.md` 一致；冲突处写 TBD。
- **索引只做入口（强制）**：索引层只写“一句话 + 指向权威位置”；详细业务表达以 `products/{module}.md` 为准。
- **最小编辑**：优先追加与补齐；若必须纠正既有结论，必须解释原因并留下证据入口。

### 2.2 执行顺序（MUST）

1. 从 `products/index.md` 的 `### 业务模块清单（链接）` 中筛选任务：仅处理 `- [ ]`
2. 对每个 `{module}`：
   - 生成 `products/{module}.md`
   - 回填更新 `products/index.md`（必须覆盖第 0-8 节）
   - 更新复选框为 `[x]`，更新 Assumption/TBD，追加执行记录（结果 + 日期）
   - 对照索引第 0-8 节做一致性自检

---

## 3. 模板映射与模块文档生成规则

### 3.1 `products/{module}.md` 模板映射（MUST）

- 模板：`.aisdlc-cli/templates/project/products-module-template.md`

### 3.2 填充规则（地图层语义，MUST）

模块文档必须保持“业务架构视角的长期稳定资产”：

- In/Out 边界（引用 Level-0 约束；不得写一次性交付实现步骤）
- 关键入口（API/事件/作业/界面/定时任务）：尽量回链到仓库可验证证据（路径/配置/README/现有文档）
- 关键流程：以图表表达（优先仓库既有约定；否则 PlantUML/Mermaid 二选一统一）
- 与相邻模块边界：引用 `memory/structure.md` 的边界/依赖方向（冲突写 TBD）

> 原则：先从“可观察入口（API/事件/作业/界面）”回推业务边界，再用代码/配置证据验证。

---

## 4. 索引回填：逐节更新规则（必须覆盖 0-8 节）

> 索引结构以 `.aisdlc-cli/templates/project/products-index-template.md` 为准。PD4 必须对第 0-8 节逐项回填（或明确标注 `暂无/TBD`），避免只更新复选框造成索引失真。

对每个成功生成的 `{module}`，按节回填：

### 0. 使用说明

- 仅当“阅读策略/命名规则/边界原则”需要更正或补充时更新；否则保持短且不动。

### 1. 业务模块总览 + 清单（链接）

- 在总览表中补齐/更新：一句话职责、Top3 能力（若可归纳）、主要代码入口（可选）、Owner、状态
- 在清单（链接）条目下补齐：
  - 一句话职责
  - 状态（fact/assumption/tbd，可拆分子项）
  - 关键入口（仅列入口名称 + 链接/路径）
  - 关键协作/依赖（指向第 6 节或模块文档段落）
  - 执行记录：结果 + 日期

### 2. 业务能力地图入口（Capability）

- 若能识别 CAP 编号或稳定能力关键词：补齐“能力 → 承载模块（含 `{module}`）”映射
- 否则写 `TBD/暂无` 并给验证线索

### 3. 价值流/客户旅程入口（Value Stream）

- 若能识别 VS 编号或稳定阶段/步骤：补齐“阶段/步骤 → 相关模块（含 `{module}`）”
- 否则 `TBD/暂无`

### 4. 业务服务目录（Business Service）

- 若能识别 BS 或可归纳对外服务：补齐“服务 → 提供模块（含 `{module}`）→ 关联流程/面向对象”
- 否则 `TBD/暂无`

### 5. 业务流程目录（Process）

- 若能识别 BP 或可归纳关键流程：补齐“流程 → 归属模块（含 `{module}`）→ 触发/结果/Owner”
- 否则 `TBD/暂无`

### 6. 跨业务模块协作与依赖

- 若识别到 `{module}` 与其它模块依赖：在“关键业务依赖关系（高层）”表追加一行，并指向证据或模块文档段落
- 否则 `暂无/无`

### 7. 常用检索（快速导航）

- 将本次新增/确认的信息按入口补齐：关键词/需求/服务/流程/对象/事件/KPI/规则 → 模块
- 无法确认的映射必须标注 `TBD`

### 8. 变更记录

- 追加一条记录：日期、变更、影响模块（含 `{module}`）、关联 ADR/Spec（无则 `无/TBD`）

---

## 5. 任务状态更新与审计（MUST）

对每个成功完成的 `{module}`，必须在 `products/index.md` 中：

1. 将清单条目复选框从 `- [ ]` 更新为 `- [x]`
2. 更新 Assumption/TBD：
   - 已确认/已解决项必须标记或移除，并写明依据/解决方案
   - 仍待确认项需更具体，并保留验证线索
3. 追加执行记录（最小字段）：
   - `- 结果：已生成 .aisdlc/project/products/{module}.md`
   - `- 日期：YYYY-MM-DD`
4. 执行一致性自检：
   - 第 1 节必须包含 `{module}` 入口
   - 第 2-7 节与 `{module}` 相关映射已补齐或明确 `暂无/TBD`
   - 第 8 节已追加变更记录

---

## 6. 自检校验（PD4-DoD）

- [ ] 所有未执行（`- [ ]`）的 product 任务均已执行并生成 `products/{module}.md`（或明确记录阻塞原因），且复选框已更新为 `- [x]`
- [ ] 每个已完成模块的条目下，Assumption/TBD 已按验证结果更新（已确认/已解决项已标记）
- [ ] 每个已完成模块在文档与索引中对关键入口/边界给出可验证证据；无法确认项已标注 Assumption/TBD 并给验证线索
- [ ] `products/index.md` 已按模板第 0-8 节完成回填更新（或明确标注 `暂无/TBD`），保持“短 + 入口清晰 + 可追溯”

