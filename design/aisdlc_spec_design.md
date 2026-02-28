---
title: Spec 级设计阶段 SOP（决策文档 / RFC；research 可选；整体可跳过）
status: draft
audience: [PM, BA, SA, DEV, QA]
principles_ref: design/aisdlc.md
---
## 设计阶段流程（Design：research 可选 / design 必做；整体可跳过）

### 1. 背景与目标（对齐 `design/aisdlc.md`）

本文档定义 **Spec 级**“设计（design）阶段”的统一 SOP：核心产出是用于人类评审与达成共识的 **决策文档（Decision Doc / RFC）**，回答“为什么这样做/边界怎么裁切/有哪些方案与权衡/对外承诺是什么”，而不是追求实现层面的详细设计。

**结论**：

- **阶段整体可跳过**：当需求边界清晰、风险低、无关键不确定性时，可直接进入 implementation。
- **若不跳过：仅两段**：
  - **research（可选）**：为特定技术/领域做研究与分析，补足上下文，降低 design 的不确定性。
  - **design（必做）**：产出 `design/design.md`（design 阶段 SSOT）。
- **不设“详细设计”子阶段**：契约/数据模型等属于“按需附件/对外承诺落盘”；实现细节归入 implementation 的 `plan.md/tasks.md`。

> **路由权威说明（重要）**：D0（是否跳过 design）、D1（是否需要 research）、D2（是否进入 RFC）等“下一步判断/分流”由 `skills/using-aisdlc/SKILL.md` 作为唯一路由器判定；本 SOP 负责给出口径与 DoD，具体执行时由路由选择相应 worker skill：\n
> - D1：`spec-design-research` → `{FEATURE_DIR}/design/research.md`\n
> - D2：`spec-design` → `{FEATURE_DIR}/design/design.md`\n

---

### 2. 产物落盘与“渐进式披露”的读取顺序

#### 2.1 推荐落盘结构（需求级 Spec Pack）

对齐 `design/aisdlc.md` 中的需求级目录（示例）：

```text
.aisdlc/specs/<DEMAND-ID>/
  index.md
  requirements/
    ...                   # 已完成的需求澄清产物（solution/prd/prototype 等）
  design/
    research.md           # D1：research（可选）：研究/分析结论
    design.md             # D2：design（必做；仅当未跳过）：决策文档（Decision Doc / RFC）
```

#### 2.2 Agent 读取顺序（渐进式披露）

- **必读（项目级，强制，对齐上下文注入协议）**：
  - `project/memory/*`（业务/技术/结构/术语）
  - `project/components/index.md`（应用组件地图 + 跨模块依赖关系图）
  - `project/adr/index.md`（架构决策索引）
  - **受影响模块的完整内容**：从 `specs/{id}/requirements/solution.md#impact-analysis`（R1.5 产出）获取受影响模块清单，读取对应 `project/components/{module}.md` 的**全部内容**（含 TL;DR、API/Data Contract 不变量、状态机/领域事件、Evidence）——D2 必须显式声明与这些模块现有契约的关系
  - **相关 ADR 全文**：从影响分析中获取相关 ADR 编号，读取 `project/adr/{adr-id}.md` 全文——确保设计不违反历史决策
  - 读取失败或不存在时显式标注为 `CONTEXT GAP`（而非静默跳过）
- **按需（需求级）**：仅在明确处理某个 `<DEMAND-ID>` 时读取该需求的最小必要材料：
  - **需求路径**：`requirements/solution.md`、`requirements/prd.md`（可选）、`requirements/prototype.md`（可选）
  - **影响分析**：`specs/{id}/requirements/solution.md#impact-analysis`（R1.5 产出，必读）
  - **设计路径**：`design/design.md`（若已存在）与 `design/research.md`（可选）
- **回写（入库）**：每个模块独立产出一个文件（或一个章节），保持可替换与可审计。

#### 2.3 上下文自动识别机制（门禁）

对齐 `design/aisdlc_spec_init.md` 的“上下文自动识别机制”：**凡会读写 `specs/<DEMAND-ID>/design/*.md`，必须先定位当前 Spec Pack 的 `{FEATURE_DIR}`**，禁止猜路径。

- **公共 Skill**：`spec-context`（定义见 `skills/spec-context/SKILL.md`）
- **硬规则（必须遵守）**：
  - **先定位再读写**：任何读/写 `design/*.md` 前，必须先获取 `FEATURE_DIR=...`
  - **失败就停止**：上下文定位失败必须立刻停止，不得继续生成/写文件内容
  - **只用 FEATURE_DIR 拼路径**：后续路径以 `FEATURE_DIR` 为前缀（例如 `{FEATURE_DIR}/design/design.md`）

---

### 3. 分布式流程总览（模块化流水线）

目标：每一步都可单独执行、单独评审、单独替换；步骤之间通过明确的输入/输出对齐，避免重复劳动与上下文漂移。

#### 3.1 模块清单

| 模块 ID | 模块名称 | 主要目标 | 关键输出（落盘） |
|---|---|---|---|
| D0 | 分流：是否跳过 design 阶段 | 用清晰口径判断“直接进入 implementation”还是“进入 research/design”，并在跳过时声明 implementation 必补齐项 | （路由结论由 using-aisdlc 输出；不强制落盘） |
| D1 | research（可选） | 为关键不确定性补足上下文：现状、约束、风险、未知项与研究结论 | `design/research.md`（由 `spec-design-research` 落盘） |
| D2 | design（必做；仅当未跳过） | 产出可评审的决策文档（RFC），冻结边界与关键决策，并为 implementation 提供权威输入 | `design/design.md`（由 `spec-design` 落盘） |

#### 3.2 最短路径（建议先跑通）

- **跳过路径**：D0（判定跳过）→ 进入 implementation（并在 `plan.md` 补齐最小决策信息）
- **常规路径**：D0（不跳过）→（可选）D1 → D2 → implementation

#### 3.3 通用门禁与收敛规则（D0–D2）

- **门禁**：凡读写 `design/*.md`，先执行 `spec-context` 获取 `FEATURE_DIR`；失败即停止（见 2.3）。
- **写作原则**：结论优先（结论 → 依据 → 验证）；只保留支撑决策/实现/验收的最小信息；关键口径可追溯到 `requirements/solution.md`（或 `prd.md/prototype.md`）。
- **收敛规则**：`design.md/research.md` 不出现“待确认问题清单”；未知以“假设 + 验证清单（Owner/截止/信号/动作）”承接。

---

### 4. 模块 D0：分流——是否跳过 design 阶段（关键分流）

#### 4.1 目标

明确本需求是否需要进入 design 阶段；如果跳过，也要明确“为什么跳过”以及 implementation 阶段必须补齐的最小信息，避免把关键决策隐含在实现里。

#### 4.2 输入

- `{FEATURE_DIR}/requirements/solution.md`（必需）
- （可选）`{FEATURE_DIR}/requirements/prd.md`、`{FEATURE_DIR}/requirements/prototype.md`
- 项目级 `project/memory/*`、`project/components/index.md`、`project/adr/` 索引（按需）

#### 4.3 输出

- **跳过或不跳过的结论**：理由（3–7 条以内）+ 关键依据（可追溯到约束/证据入口）
- **跳过时的补齐清单**：implementation 的 `plan.md` 必须补齐的“最小决策信息”（见 4.5）

#### 4.4 跳过判定口径（满足其一即可跳过）

- **范围单一、边界清晰**：几乎不涉及跨模块协作与系统性风险
- **无对外承诺变化**：无新增/变更对外契约（API/事件/权限/数据口径），且无数据迁移
- **无关键技术不确定性**：不需要先 research 验证
- **验收口径已足够**：验收在 `solution.md`（或 `prd.md`）中已经清晰、可测试、可追溯

#### 4.5 跳过时 implementation 必补齐项（最小决策信息）

> 约束提醒：design 阶段一旦跳过，implementation 的 `plan.md` 必须补齐最小决策信息（目标、范围与边界、关键约束、验收口径、验证清单），不得脑补；该规则以 `design/aisdlc.md` 的 Layer1 约束为准。

#### 4.6 下一步（D0 → D1/D2 或直接 implementation）

- **跳过**：进入 implementation（并按 4.5 补齐 `plan.md`）
- **不跳过**：按需进入 D1（research）→ D2（design）

---

### 5. 模块 D1：research（研究，可选）

#### 5.1 目标

为当前需求在特定技术/领域做研究与分析，补足 design 决策所需的上下文：现状、约束、风险、未知项与研究结论。

#### 5.2 输入

- **门禁**：先执行 `spec-context` 获取 `FEATURE_DIR`（失败即停止；见 2.3/3.3）
- **需求路径**：`{FEATURE_DIR}/requirements/solution.md`（必需）与（可选）`prd.md/prototype.md`
- **项目级资源**：`project/memory/*`、相关 `components/{module}.md`、`adr/` 索引（契约入口位于组件页的 `## API Contract / ## Data Contract`）

#### 5.3 输出（落盘到 `design/research.md`，可选）

推荐最小结构（研究结论必须可复用、可被 D2 直接引用）：

- **结论摘要（TL;DR，3–7 行）**：现状 + 最大风险 + 推荐方向
- **现状与问题域**：关键现状、痛点与影响
- **范围边界与不变量**：In/Out 与不变量
- **关键约束**：合规/性能/依赖/组织
- **风险与验证清单（必填）**：风险/假设 → 验证方式 → 成功/失败信号 → Owner → 截止 → 下一步动作
- **备选与权衡（可选）**：若研究已形成倾向性结论，给出 2–3 个备选与关键差异

#### 5.4 质量门槛（D1-DoD）

- 未知项不以“待确认问题”形式悬空，统一进入“风险与验证清单”
- 研究结论可追溯，并能为 D2 的决策文档提供可用输入（能被引用而不需要重复解释）

#### 5.5 下一步（D1 → D2）

进入 D2 产出 `design/design.md`（决策文档 / RFC）。

---

### 6. 模块 D2：design（决策文档 / RFC，必做；仅当未跳过）

#### 6.1 目标

将需求/重构映射为可评审的决策文档：边界、核心方案、关键决策与权衡、对外承诺（契约/数据）要点，并为 implementation 的 `plan.md/tasks.md` 提供权威输入。

#### 6.2 输入

- **门禁**：先执行 `spec-context` 获取 `FEATURE_DIR`（失败即停止；见 2.3/3.3）
- **需求路径**：`{FEATURE_DIR}/requirements/solution.md`（必需）与（可选）`prd.md/prototype.md`
- **影响分析（必读）**：`{FEATURE_DIR}/requirements/solution.md#impact-analysis`（R1.5 产出），获取受影响模块清单与需遵守的不变量
- （可选）`{FEATURE_DIR}/design/research.md`
- **项目级（强制，对齐上下文注入协议）**：
  - `project/memory/*`（业务/技术/结构/术语）
  - 受影响模块的 `project/components/{module}.md` **完整内容**（含 API/Data Contract 不变量、状态机/领域事件）
  - 相关 ADR 全文（从影响分析中获取编号）
  - 读取失败时标注 `CONTEXT GAP`

#### 6.3 输出（落盘到 `design/design.md`）

`design/design.md` 是 design 阶段的 **单一决策入口（SSOT）**：写清楚“做什么/不做什么/为什么/怎么验证/对外怎么承诺”，不写实现细节与任务拆分。

建议最小结构（可直接作为模板）。其中“推荐方案”必须用 **C4 的前三个层次**描述，作为评审的统一基线（只到 Component，不进入 Code 级细节）：

- **结论摘要（必填，3–7 行）**：目标 + In/Out + 推荐方案一句话机制概述 + 需要优先验证的 1–3 个点（引用下方验证清单编号）
- **范围与边界（必填）**：系统边界、影响面、明确不做什么（与 `requirements/solution.md` 对齐）
- **推荐方案（必填，1 个；按 C4 L1–L3 描述）**
  - **C4-L1：System Context（系统上下文）**：用户/角色、外部系统、系统边界、关键交互与主要输入输出；明确不变量与约束（必要时配 Mermaid 图）
  - **C4-L2：Container（容器/部署单元）**：应用/服务/函数/作业、数据库/缓存/队列等容器划分；每个容器的职责、主要技术选型、关键数据流与对外契约入口（组件页契约段落/事件/接口）
  - **C4-L3：Component（组件）**：关键容器内部的组件拆分（职责/接口/依赖）；关键数据模型与状态流转；错误处理与幂等/一致性策略（描述到“组件与接口”，不落实现细节）
  - **关键决策与取舍（必填，≥3 条）**：性能/成本/一致性/复杂度/演进等维度的权衡，说明为什么选它
  - **对外承诺要点（必填）**：契约/权限/数据口径/兼容性/迁移与回滚承诺；必要时更新对应 `project/components/{module}.md` 的契约段落或新增 ADR
- **备选方案（必填，2–3 个）**：各备选的适用前提（何时会选它）+ 不选原因（1–2 条关键差异即可）
- **与现有系统的对齐（必填，基于 R1.5 影响分析）**：
  - **契约兼容性声明**：对每个受影响模块，显式声明本设计与现有 API/Data 契约的关系（兼容/扩展/破坏性变更），引用 `components/{module}.md#api-contract` / `#data-contract` 中的具体不变量
  - **ADR 合规声明**：对每个相关 ADR，显式声明本设计是否遵守、是否需要新增/修改 ADR
  - **状态机/事件影响**：对涉及的状态机与领域事件，说明是否新增状态/事件、是否改变转移规则（引用模块页的 `## State Machines & Domain Events`）
  - **跨模块影响确认**：基于依赖关系图，确认所有受影响的上下游模块已被考虑
- **影响分析（必填）**：上下游系统、数据口径、运行与运维影响、迁移/回滚要点（按需）
- **风险与验证清单（必填）**：风险/假设 → 验证方式 → 成功/失败信号 → Owner → 截止 → 下一步动作
- **追溯链接（必填）**：`requirements/solution.md`（以及 `prd.md/prototype.md` 如适用）、`requirements/solution.md#impact-analysis`（R1.5 产出）、相关组件页契约段落/ADR 入口

#### 6.4 质量门槛（D2-DoD）

- 方案覆盖需求的目标、范围与关键约束，且 In/Out 明确
- 推荐方案以 C4 的 **L1（Context）+ L2（Container）+ L3（Component）** 三层次描述清楚（图或等价结构均可），且层次之间可追溯
- 关键决策可追溯（至少能指出“为什么选它”与“备选为何不选”）
- **与现有系统的对齐已完成**：每个受影响模块的契约兼容性已声明、相关 ADR 合规性已确认、状态机/事件影响已说明
- 不确定性已收敛：未知以“假设 + 验证清单”承接（Owner/截止/动作明确）

#### 6.5 下一步（D2 → implementation）

进入 implementation 阶段：以 `design/design.md` 作为输入，生成实现计划与任务拆分（`plan.md/tasks.md`），并将验证清单映射到测试/发布/回滚策略中。

---

### 7. 需求与重构的统一处理

- **统一输入**：无论功能需求还是重构需求，均以 `requirements/solution.md` 作为需求侧 SSOT。
- **差异处理**：
  - **功能需求**：重点描述业务目标、流程变化与验收口径对齐（引用 `solution.md/prd.md` 的 AC）。
  - **重构需求**：重点描述现状基线、重构目标、不变量、迁移/回滚与回归验证策略。
- **验证策略**：重构需求必须覆盖回归与对照验证，并在 `design/design.md` 的“风险与验证清单”中可追溯。

---

### 8. 追溯与 Merge-back 提示

- 设计阶段新增的关键决策应落盘到 `project/adr/`（或在 `design/design.md` 中提供 ADR 入口与摘要）。
- 接口或数据契约的变更应更新对应 `project/components/{module}.md` 的 `## API Contract / ## Data Contract` 段落，并确保 `project/components/index.md` 可稳定跳转到锚点。
- 可复用的长期资产在需求完成后通过 Merge-back 晋升到项目级（避免知识资产散落在单个 Spec Pack 内）。
