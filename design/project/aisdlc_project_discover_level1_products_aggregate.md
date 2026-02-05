---
title: 项目 Discover（Level-1 / products-aggregate）— 产物生成设计规范
status: draft
stage: project_discover
module: PD3
principles_ref: design/aisdlc.md
source_refs:
  - design/aisdlc_project_discover.md
  - .aisdlc-cli/commands/discover-level1-products-aggregate.md
  - .aisdlc-cli/templates/project/products-index-template.md
---

## 0. 目标与定位

本设计文档用于定义 Project Discover 阶段 PD3「Level-1 / products-aggregate（业务聚合与任务化）」的**框架性规则、硬约束与验收标准**。

PD3 的目标是把“候选业务模块”按业务语义进行聚合与收敛，形成**可治理的业务模块集合（强制 <= 6）**，并将其任务化写入 `.aisdlc/project/products/index.md`，为 PD4（products-detail）逐模块生成明细提供复选框任务输入。

> 边界：PD3 只负责聚合与任务化，不生成 `products/{module}.md` 明细文件。

---

## 1. 术语与接口

### 1.1 无参数约束（MUST）

- 本阶段**不接受任何参数**，`$ARGUMENTS` 必须视为空。

### 1.2 前置条件（MUST）

必须先存在以下文件（缺失则停止并提示先执行 PD1）：

- `.aisdlc/project/products/index.md`（索引骨架）
- `.aisdlc/project/memory/structure.md`
- `.aisdlc/project/memory/tech.md`
- `.aisdlc/project/memory/product.md`
- `.aisdlc/project/memory/glossary.md`（可为空但必须读取）

### 1.3 输入输出

- **输入**：Level-0 四文件 + `products/index.md`（骨架/占位符）
- **输出（固定）**：更新 `.aisdlc/project/products/index.md`：
  - 写入“最终聚合方案选择”（含证据入口与理由）
  - 回填业务模块总览表格
  - 写入“业务模块清单（链接）”复选框任务（默认 `- [ ]`）

---

## 2. 强制门禁与总流程（MUST）

### 2.1 操作约束（MUST）

- **非破坏性**：只读分析；只更新 `.aisdlc/project/products/index.md`；不得修改业务代码。
- **证据优先**：聚合结论尽量回链到 Level-0 或 contracts/data 的证据入口；不确定必须标注 Assumption/TBD。
- **强制颗粒度收敛（关键）**：
  - **Products 数量必须 <= 6**
  - 若无法收敛：必须记录不可收敛原因（合规隔离/组织边界/数据主责分裂/强时延边界等）与治理建议

### 2.2 执行顺序（MUST）

1. 读取 Level-0 约束摘要 → 读取 `products/index.md`（确认结构段落存在）
2. 在对话界面输出 **3 个 Products 聚合方案候选**（必须，且不写入文件）
3. 进行 **一次交互式选择**（只问 1 个问题）：用户选 P1/P2/P3（可附自定义调整）
4. 将“最终聚合方案选择”落盘到 `products/index.md`
5. 基于已选方案，生成并回填：
   - 业务模块总览表格
   - 业务模块清单（链接）复选框任务（默认 `- [ ]`）
6. 执行数量收敛（merge pass），确保 <= 6；若失败则记录原因与治理建议

---

## 3. 结构校验与补齐（MUST）

PD3 必须确保 `products/index.md` 至少包含：

- `## 1. 业务模块总览`
- `### 业务模块清单（链接）`

若骨架缺失上述段落：以 `.aisdlc-cli/templates/project/products-index-template.md` 为准补齐结构（保持地图层短与入口清晰）。

---

## 4. 聚合准则（Products）与候选方案输出

### 4.1 通用聚合准则（按优先级）

- **价值流/核心场景聚合**：能被同一个端到端业务结果解释的一组能力优先同域（证据：`memory/product.md`）
- **业务服务/契约边界聚合**：围绕稳定业务服务承诺形成模块（证据：contracts 入口/说明）
- **数据主责聚合**：同一组核心业务对象的主写与生命周期责任尽量同域（证据：数据契约/Schema）
- **组织/合规隔离拆分**：合规隔离/审计责任/强权限边界/团队边界可拆分，但必须说明原因与证据入口
- **避免按目录一对一**：目录/包只能作为信号，不可直接等价为业务域

### 4.2 方案候选输出规范（必须输出 3 个）

候选方案只输出到对话界面（不写入文件）。每个方案必须包含：

- 视角/原则（以什么边界为优先）
- 可操作的聚合规则（如何从能力/对象/契约线索归并）
- 优点/风险（治理收益与潜在问题）
- 适用条件（什么情况下优先选）
- 证据入口（主要依赖哪些信号）

> 目的：避免“单一答案不适配”，同时将“聚合决策”变成可审计的选择过程。

---

## 5. 交互设计（强制：最多 1 问）

### 5.1 单问选择（MUST）

交互必须满足：

- 只询问 Products 聚合方案选择 1 次
- 用户输入应支持：
  - 选择 P1/P2/P3
  - 追加自定义调整（如合并/拆分/改名/特殊隔离原因）

### 5.2 落盘内容（写入 `products/index.md`，MUST）

必须写入“最终聚合方案选择”段落，至少包含：

- 方案编号（P1/P2/P3）
- 选择理由（1-3 条）
- 关键证据入口（Level-0 / contracts / data / repo 结构等）
- 放弃其他方案原因（简述）
- 自定义调整说明（如有）

---

## 6. 任务化回填规则（MUST）

### 6.1 数量收敛（MUST）

- 初版 products 集合若 > 6：必须执行 merge pass 合并相邻/耦合最强/共享对象最多/共享价值流最多的条目，直到 <= 6
- 若仍 > 6：必须记录不可合并原因 + 治理建议

### 6.2 命名规则（用于 `{module}`）

- 使用业务语义（来自 glossary/product），避免纯技术名（util/common/base）
- 使用稳定名词短语（如 `billing`、`order`、`inventory`），避免流程步骤名（step1/handler）
- 使用 kebab-case

### 6.3 回填位置与格式（MUST）

必须在 `products/index.md` 同时回填：

1. **业务模块总览表格**：每个 `{module}` 一行（保持短 + 可追溯）
2. **业务模块清单（链接）**：每个 `{module}` 一条复选框任务（默认 `- [ ]`），建议包含：
   - 一句话职责
   - 证据入口（若可提供）
   - 假设（Assumption）
   - 待确认（TBD）

复选框语义（与 PD4 对齐）：

- `- [ ]`：未执行（待生成 `products/{module}.md`）
- `- [x]`：已执行（明细已生成并完成索引回填）

---

## 7. 自检校验（PD3-DoD）

- [ ] 已读取 Level-0 文件与 `products/index.md`，并保证结构段落存在
- [ ] 已在对话界面输出 3 个 Products 聚合方案候选（含规则/优缺点/适用条件/证据入口）
- [ ] 已完成一次交互式选择并落盘到 `products/index.md`（包含编号/理由/证据/放弃原因/自定义调整）
- [ ] 已回填业务模块总览表格与业务模块清单（链接）复选框任务（默认 `- [ ]`）
- [ ] Products 数量已收敛到 <= 6；若无法收敛已记录原因与治理建议

