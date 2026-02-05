---
title: 项目 Discover（Level-0 / memory）— 产物生成设计规范
status: draft
stage: project_discover
module: PD0
principles_ref: design/aisdlc.md
source_refs:
  - design/aisdlc_project_discover.md
  - .aisdlc-cli/commands/discover-level0-memory.md
  - .aisdlc-cli/templates/project/structure-template.md
  - .aisdlc-cli/templates/project/tech-template.md
  - .aisdlc-cli/templates/project/product-template.md
---

## 0. 目标与定位

本设计文档用于定义 Project Discover 阶段 PD0「Level-0 / memory（北极星）」的**框架性规则、硬约束与验收标准**，用于约束后续命令/模板实现，以及指导人工/AI 产物生成。

PD0 的目标是为“存量项目的逆向工程”建立**项目级 SSOT（Project SSOT）**的最小闭环入口（北极星/根上下文），为后续 Level-1 地图层与需求级 `specs/<DEMAND-ID>/` 的渐进式披露提供稳定锚点：

- **短**：默认必读，避免百科化
- **可定位**：所有关键结论必须给出可定位证据入口（路径/文件/脚本/CI job）
- **可审计**：显式区分 Fact / Evidence / Assumption / TBD
- **可下钻**：提供 Level-1 的“入口路径约定”，但不在 PD0 内强制生成 Level-1 文件

---

## 1. 术语与接口

### 1.1 产物层级

- **Level-0（本阶段）**：`.aisdlc/project/memory/*` 四份北极星（根上下文）
- **Level-1（后续阶段）**：组件/业务模块/契约/ADR 索引与明细（地图层）
- **需求级（Spec Pack）**：`.aisdlc/specs/<DEMAND-ID>/...`（一次性交付细节与证据）

### 1.2 路径与输入输出

- **输出根目录**：`.aisdlc/project/`
- **本阶段输出（固定）**：
  - `.aisdlc/project/memory/structure.md`
  - `.aisdlc/project/memory/tech.md`
  - `.aisdlc/project/memory/product.md`
  - `.aisdlc/project/memory/glossary.md`
- **用户输入（可选）**：`$ARGUMENTS`（用于指定关注模块/语言/关键链路；不得忽略）

### 1.3 证据标注口径（最小集）

为保证“可追溯 + 可审计”，PD0 产物中对关键结论应至少满足：

- **Fact**：可直接从仓库定位证据的结论
- **Evidence**：指向路径/文件/脚本/CI job/命令（可点击/可定位）
- **Assumption**：当前推断但未证实（必须写影响面 + 验证线索）
- **TBD**：必须由用户/Owner 确认（列为问题清单）

---

## 2. 强制门禁与总流程（MUST）

### 2.1 操作约束（MUST）

- **非破坏性**：只读分析；仅生成/更新 `.aisdlc/project/` 文档；**不得修改**业务代码与运行配置。
- **证据优先**：不得臆造事实；无法证实时必须标注 Assumption/TBD，并给出验证线索。
- **图表优先（强）**：流程/关系/时序优先图表表达（遵循仓库既有约定；否则 PlantUML 或 Mermaid 二选一统一）。
- **项目级资产边界**：项目级只写长期稳定资产与入口；实现细节必须下沉到需求级 `specs/<DEMAND-ID>/`。

### 2.2 执行顺序（MUST）

PD0 必须遵循以下顺序生成（保证依赖有向无环）：

1. **预检（定位为主）**：扫描仓库结构与关键配置入口，仅收集线索不下结论
2. **先生成结构北极星**：`structure.md`（提供“去哪找/怎么引用/边界在哪里”）
3. **再生成技术北极星**：`tech.md`（基于结构入口提炼技术事实、门禁、契约 SSOT 入口）
4. **再生成业务北极星**：`product.md`（基于结构 + 技术入口回推业务边界/场景/指标）
5. **最后生成术语北极星**：`glossary.md`（术语必须落点到代码/契约/模块入口）
6. **展示结果 + 保存策略**：若目标文件已存在，必须先输出差异/影响摘要，并让用户选择覆盖/另存（`.new.md`）

---

## 3. 模板映射与输出结构

### 3.1 模板映射（MUST）

- `structure.md` 使用 `.aisdlc-cli/templates/project/structure-template.md`
- `tech.md` 使用 `.aisdlc-cli/templates/project/tech-template.md`
- `product.md` 使用 `.aisdlc-cli/templates/project/product-template.md`
- `glossary.md`：由命令按约定生成最小结构（本仓库未提供模板文件时，仍需保持“短 + 可定位”）

### 3.2 输出控制（MUST）

- **只写入口，不写展开**：Level-1 的索引/明细在 PD0 中只写“入口路径约定”，不得生成看似完整但不可验证的细节。
- **入口必须稳定**：若 Level-1 尚未生成，入口仍应写成固定路径（例如 `project/components/index.md`），作为后续阶段的唯一目标位置。

---

## 4. 分文件详细规则（按产物分解）

### 4.1 `memory/structure.md`（先行）

目标：提供一切信息的“定位与引用”能力。

必须覆盖：

- 高层目录树（只保留关键目录/边界，避免文件级）
- 模块边界与依赖方向、禁止事项、公共 API 出口约定、Owner 标注方式
- 入口点定位：应用入口、路由/控制器、作业/定时任务、消息消费入口（如适用）
- 契约与集成入口：只列入口与指向 `project/contracts/*` 的权威位置
- 文档入口：memory + Level-1 地图层入口路径

### 4.2 `memory/tech.md`（依赖 structure）

目标：在结构之上总结技术事实、运行与配置约定、质量门禁与权威入口。

必须覆盖：

- 技术栈事实（语言/框架/存储/消息/测试/CI/CD/可观测等）
- 不可妥协原则 + DoD 最小门禁（以仓库脚本/CI 为证据，不得脑补）
- 运行与配置最低口径（环境/配置管理/特性开关与回滚口径）
- 渐进式披露入口：components/contracts/adr/ops（只给入口路径）

### 4.3 `memory/product.md`（依赖 structure + tech）

目标：基于可观察入口（契约/API/事件/作业入口）回推业务边界与场景，并提供 Level-1 产品地图入口。

必须覆盖：

- 一句话定义、目标用户、核心价值
- In/Out 边界（Out 至少 1 条）
- Top 场景（每条必须包含“成功的可观测结果”）
- 成功指标（NSM + 护栏）
- 不可妥协约束（合规/交付窗口/运营协作）
- 渐进式披露入口：`project/products/index.md` 与 `glossary.md`

### 4.4 `memory/glossary.md`（最后）

目标：让术语可检索、可消歧、可落点，避免空泛定义。

每个术语条目至少包含：

- 术语（中英文/缩写）
- 定义（一句话 + 必要消歧）
- 落点（至少一种）：
  - 代码入口（路径）
  - 契约入口（`project/contracts/...`）
  - 模块入口（`project/products/{module}.md` / `project/components/{module}.md`）
- 别名/同义词（可选）
- 备注（口径/边界/非目标，可选）

---

## 5. 覆盖策略与幂等性（MUST）

- **覆盖前必须提示差异/影响**：当目标文件已存在时，必须先输出差异摘要（新增/删除/改动的关键入口与约束）。
- **两种写入模式**：
  - **覆盖**：更新同名文件（适用于“纠错/补证据/补入口”）
  - **另存**：写入 `*.new.md`（适用于“首次探索 + 用户希望对比评审”）
- **可重跑**：重复执行时应优先“补齐入口与证据”，避免无意义重写（除非用户选择覆盖）。

---

## 6. 自检校验（PD0-DoD）

- [ ] `structure.md` 已生成，且包含关键入口点与边界规则（引用可定位）
- [ ] `tech.md` 已生成，且技术栈/门禁/运行口径均有证据或明确标注 Assumption/TBD
- [ ] `product.md` 已生成，且 In/Out/场景/指标不空泛（必要时列待确认问题）
- [ ] `glossary.md` 已生成，且术语均能落点到代码/契约/模块入口
- [ ] 文档保持“短 + 入口清晰 + 可追溯”，不把一次性交付细节写进项目级资产

