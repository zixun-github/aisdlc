---
title: 项目 Discover（Level-1 / index-scan）— 产物生成设计规范
status: draft
stage: project_discover
module: PD1
principles_ref: design/aisdlc.md
source_refs:
  - design/aisdlc_project_discover.md
  - .aisdlc-cli/commands/discover-level1-index-scan.md
  - .aisdlc-cli/templates/project/components-index-template.md
  - .aisdlc-cli/templates/project/products-index-template.md
  - .aisdlc-cli/templates/project/contracts-index-template.md
  - .aisdlc-cli/templates/project/contracts-api-index-template.md
  - .aisdlc-cli/templates/project/contracts-data-index-template.md
---

## 0. 目标与定位

本设计文档用于定义 Project Discover 阶段 PD1「Level-1 / index-scan（索引骨架 + 组件扫描回填）」的**框架性规则、硬约束与验收标准**。

PD1 的核心目标是：

- 先用模板生成 Level-1 的**地图层索引骨架**（入口约定/命名规则/待回填位置），避免“空索引、伪完整”
- 在读取 Level-0 约束后，对仓库进行扫描，识别**应用组件候选**并回填到 `components/index.md`

> 重要边界：PD1 只回填组件索引的“基本信息与任务清单”。组件明细与模块契约文件由 PD2（components-detail）完成；Products 的聚合与明细分别由 PD3/PD4 完成。

---

## 1. 术语与接口

### 1.1 无参数约束（MUST）

- 本阶段**不接受任何参数**，`$ARGUMENTS` 必须视为空。

### 1.2 前置条件（MUST）

必须先存在 Level-0 四份北极星（缺失则停止，并提示先执行 PD0）：

- `.aisdlc/project/memory/structure.md`
- `.aisdlc/project/memory/tech.md`
- `.aisdlc/project/memory/product.md`
- `.aisdlc/project/memory/glossary.md`（可为空但必须读取）

### 1.3 输入输出

- **输入**：Level-0 四文件 + 仓库文件系统/配置/脚本线索（用于扫描）
- **输出（生成）**：Level-1 索引骨架（5 个固定文件）
  - `.aisdlc/project/components/index.md`
  - `.aisdlc/project/products/index.md`
  - `.aisdlc/project/contracts/index.md`
  - `.aisdlc/project/contracts/api/index.md`
  - `.aisdlc/project/contracts/data/index.md`
- **输出（回填更新）**：
  - `.aisdlc/project/components/index.md`（组件总览表格 + 复选框任务清单）

---

## 2. 强制门禁与总流程（MUST）

### 2.1 操作约束（MUST）

- **非破坏性**：只读分析；可生成 `.aisdlc/project/` 下文档；**不得修改**业务代码。
- **证据优先**：扫描结论必须附证据入口；不确定必须标注“待确认”并给验证线索。
- **索引骨架优先**：本阶段只固化“入口/约定/候选/待回填”，不产出具体明细条目（组件列表是唯一例外）。

### 2.2 执行顺序（MUST）

1. **生成 Level-1 索引骨架**（严格用模板生成结构框架，不依赖 Level-0 提炼）
2. **读取并提炼 Level-0 为“可执行约束清单”**
3. **扫描仓库识别应用组件候选**
4. **回填 `components/index.md`**：组件总览表格 + 组件清单（链接）复选框任务

---

## 3. 模板映射与“骨架”定义

### 3.1 模板映射（MUST）

- `components/index.md`：`.aisdlc-cli/templates/project/components-index-template.md`
- `products/index.md`：`.aisdlc-cli/templates/project/products-index-template.md`
- `contracts/index.md`：`.aisdlc-cli/templates/project/contracts-index-template.md`
- `contracts/api/index.md`：`.aisdlc-cli/templates/project/contracts-api-index-template.md`
- `contracts/data/index.md`：`.aisdlc-cli/templates/project/contracts-data-index-template.md`

### 3.2 “骨架要求”（MUST）

骨架必须满足：

- 只包含：使用说明、命名规则、验证线索、位置约定、待确认/待回填提示
- **不得**填充具体条目（如 API endpoint 列表、事件列表、Schema 列表等）
- **例外**：`components/index.md` 的组件总览表格与任务清单必须在扫描后回填

---

## 4. Level-0 提炼：约束清单（用于扫描与回填）

PD1 必须将 Level-0 提炼成可执行约束（不落盘或作为内部过程输出均可），至少包括：

- 从 `memory/structure.md`：模块边界、依赖方向、入口/出口约定、命名约定、禁止事项
- 从 `memory/tech.md`：技术栈事实、契约 SSOT 位置约定、DoD/门禁、运行与配置约定
- 从 `memory/product.md`：产品范围、模块候选、核心场景与关键流程线索
- 从 `memory/glossary.md`：关键术语/同义词/缩写（用于组件命名与消歧）

> 约束清单只用于“避免扫描误判与名词漂移”，不得反向生成未经证实的组件结论。

---

## 5. 扫描与组件识别：规则与信号

### 5.1 组件识别信号（按优先级）

1. **契约信号（优先）**：API/事件/消息/topic、批处理作业入口；结合 `tech.md` 的契约 SSOT 入口回推归属
2. **数据主责信号**：数据对象 owner、主写边界、schema/migration/dictionary 归属入口
3. **代码结构信号**：目录/包/命名空间、入口文件、依赖关系、运行时入口（web/worker/job/cli）
4. **业务语义信号**：术语（glossary）、核心场景（product）、角色与流程线索

### 5.2 组件候选最小记录字段（MUST）

对每个组件候选必须记录：

- 组件名称（建议 kebab-case，基于业务语义）
- 主要代码入口（路径）
- 关键接口/事件（若能定位）
- 证据入口（路径/命令/Owner）
- 假设/待确认项（如有）

---

## 6. 回填 `components/index.md`：强制格式

### 6.1 “应用组件总览”表格回填（MUST）

为每个识别到的组件添加一行，至少填充：

- 应用组件名称（kebab-case）
- 一句话职责（基于扫描结果；不确定需标注待确认）
- 关键接口/事件（若能定位）
- 主要代码入口
- Owner（无法确定则待确认）
- 状态（默认 `active`；明确废弃才 `deprecated`）

> “承载业务能力 Top3 / 应用服务 Top3”允许先写“待回填”，由 PD2 在生成组件明细时补齐。

### 6.2 “应用组件清单（链接）”任务化（MUST）

为每个组件增加一条链接任务，必须：

- 链接指向 `./{module}.md`
- 复选框默认 `- [ ]`
- 复选框语义：`[ ]` 未执行（待 PD2）；`[x]` 已执行（组件明细 + 契约已落盘并回填）

---

## 7. 幂等性与可回跑

- 可通过编辑 `components/index.md` 的复选框控制 PD2 执行范围：`- [ ]` 会被执行、`- [x]` 会被跳过。
- PD1 重跑时应保持“骨架稳定 + 组件清单可更新”，但不得在索引中写入组件明细内容。

---

## 8. 自检校验（PD1-DoD）

- [ ] 已生成 Level-1 索引骨架（components/products/contracts 三套 index），且：
  - [ ] 包含使用说明/命名规则/验证线索/位置约定/待回填提示
  - [ ] 不包含具体条目（API/事件/Schema 等）
  - [ ] 明确说明“具体条目由 PD2/PD3/PD4 回填”
- [ ] 已扫描仓库并识别组件候选，且：
  - [ ] `components/index.md` 的总览表格已回填基本信息（名称/入口/接口/Owner/状态）
  - [ ] `components/index.md` 的清单（链接）已生成复选框任务（默认 `- [ ]`）
  - [ ] 不确定信息已标注待确认并提供验证线索

