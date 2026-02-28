---
title: AI SDLC（aisdlc）团队培训讲义
status: draft
audience:
  - PM
  - BA
  - UX
  - DEV
  - QA
  - TL
  - SRE
repo: sdlc-dev
markdown-sharing:
  uri: 97db1123-6412-4e1a-9d9a-9362839137df
---

## AI SDLC（aisdlc）团队培训讲义

### 1. 培训目标与边界

#### 1.1 你将掌握什么

- **核心目标**：让团队能在本仓库用 AI SDLC（aisdlc）稳定推进“需求→设计→实现→验证收尾”，并把关键知识沉淀为可维护的 SSOT。
- **关键能力**：
  - **会走流程**：知道每个阶段读什么/写什么/怎么停/怎么验收。
  - **会选技能**：能根据场景选择正确的 `skill`（并按门禁执行）。
  - **会止损**：不脑补、不猜路径、不把 TODO/待确认散落文档，遇阻塞能正确停止并提出取证路径。

#### 1.2 这份讲义不覆盖什么

- 不讲具体业务、也不替代各团队的工程规范（测试策略、发布策略等仍以项目实际为准）。
- 不追求“把所有代码翻译成文档”：项目级只做**地图层 + 权威入口 + 证据链**，不是字段大全。

---

### 2. 核心理念（必须先对齐）

#### 2.1 双层 SSOT（Single Source of Truth）

- **项目级 SSOT（长期资产）**：`.aisdlc/project/`  
  用于长期稳定事实：入口、边界、契约权威入口、证据链、运行入口（ops）、ADR 等。
- **需求级 SSOT（Spec Pack，交付闭环）**：`.aisdlc/specs/{num}-{short-name}/`  
  每个需求一个包，用于该需求从澄清到交付的全过程证据与产物；完成后通过 **Merge-back** 晋升可复用资产回项目级。

#### 2.2 渐进式披露（Progressive Disclosure）

- **先看地图，再按需取证**：先读项目级 `memory/` 与索引（地图层），再进入受影响模块页与 Spec Pack 的最小必要文件。
- **缺失必须显式标注**：项目级输入缺失/读取失败要显式标为 `CONTEXT GAP`，不能静默跳过后继续脑补推进。

#### 2.3 门禁（Gates）与停止机制（Stop）

- **门禁的意义**：让 AI 和人都“不在错误上下文写文件、不在缺 SSOT 时推进、不把未知当已知”。
- **停止不是失败**：停止意味着你识别到缺证据/缺输入/存在阻塞，并把问题转成“可执行的下一步”。

---

### 3. 两条主线

#### 3.1 项目级 Discover（存量项目逆向）

用于“我要让 AI/新人不再猜入口、猜边界、猜契约”，落盘在 `.aisdlc/project/...`，核心是**地图层 + 权威入口 + 证据链**与可持续维护（Delta Discover / stale）。

#### 3.2 需求级 Spec Pack（交付闭环）

用于“我要交付一个需求/变更”，落盘在 `.aisdlc/specs/{id}/...`，核心是**可追溯的交付闭环**。

#### 3.3 推荐落地顺序（团队级：先项目级，再需求级）

在团队规模化使用 aisdlc 前，推荐按以下顺序落地（避免后续每个需求都在“猜入口/猜边界/猜契约”）：

- **先做项目级 Discover（MVP）**：至少把 `.aisdlc/project/memory/*`、`components/index.md` 与 1–3 个 P0 模块页（含契约段落与证据链）做出来。
- **再跑需求级 Spec Pack**：此时 R1/D2/I1 能“先看地图、再按需取证”，影响分析/设计对齐/实现计划会明显更稳定。

---

### 4. 项目级 Discover（存量项目逆向）：流程与技能映射（建议先做）

#### 4.1 Discover 的目标（不是字段大全）

建立 `.aisdlc/project/` 项目级 SSOT，让 AI/新人少猜入口、少猜边界、少猜契约：

- **地图层**：索引只导航（不双写细节）
- **权威入口**：模块页单页 SSOT（固定锚点）
- **证据链**：每个关键结论都指向可定位证据或结构化缺口（Evidence Gaps）

#### 4.2 Discover 子技能链路（四段式）

| 你现在要做什么 | 用哪个技能 | 主要输出 |
|---|---|---|
| Step0+1：盘点证据入口 + P0/P1/P2 止损 | `project-discover-preflight-scope` | `.aisdlc/project/components/index.md`（只导航）+ 入口清单落位到后续 memory/ops |
| Step2+3：北极星（memory）+ 索引骨架 | `project-discover-memory-index` | `.aisdlc/project/memory/*` + `components/index.md` + `products/index.md` |
| Step4：模块页 + 契约段落 + 证据链 | `project-discover-modules-contracts` | `.aisdlc/project/components/{module}.md` |
| Step5+6+7+11：Products 收敛 + Ops 入口 + DoD + 增量维护 | `project-discover-products-ops-dod` | `.aisdlc/project/products/*` + `.aisdlc/project/ops/*` + DoD/Delta/stale 规则 |

#### 4.3 Discover 的硬规则（团队必须背下来）

- 禁止 `.aisdlc/project/contracts/**`（API/Data 契约合并到模块页固定段落）。
- 索引只导航：`components/index.md`、`products/index.md` 不写不变量/字段/流程/“待补”。
- P0 模块页必须包含固定标题（锚点稳定）：`## TL;DR`、`## API Contract`、`## Data Contract`、`## Evidence`、`## Evidence Gaps`。
- 缺证据就写 `Evidence Gaps`（结构化：缺口/期望粒度/候选证据位置/影响），禁止“待补/未发现/TODO”散落正文。
- 先 Scope 止损：先把 1–3 个 P0 模块做到可追溯三件套，再扩展。
- Products 默认收敛到 <= 6（否则地图失效；无法收敛要写明原因与治理建议入口）。

#### 4.4 Discover MVP：做到什么程度，才“值得大规模跑 Spec Pack”

建议把以下内容视为“项目级知识库最小可用交付”（达到后，需求侧 Skill 的上下文注入才有稳定输入）：

- **Level-0（北极星）**：`.aisdlc/project/memory/structure.md`、`tech.md`、`product.md`、`glossary.md`（短、可导航、入口可定位；缺口进 Evidence Gaps）
- **Level-1（地图层）**：`.aisdlc/project/components/index.md`（只导航 + 依赖图 + 进度复选框）
- **P0 模块 1–3 个先做深**：`.aisdlc/project/components/{module}.md`（含 `TL;DR` + `API/Data Contract` + `Evidence/Evidence Gaps`）

> 若项目级知识库尚未达到 MVP：需求侧仍可跑 Spec Pack，但必须接受“`CONTEXT GAP` 多、影响分析弱、设计/实现更容易漂移”的现实，并把 Discover MVP 纳入近期优先事项。

---

### 5. 需求级 Spec Pack：端到端流程（R → D → I → Finish）

#### 4.1 总览（一个节点 = 一个技能 = 一个落盘产物）

**需求链路（可选 R0–R4）**：

- R0：`raw.md`（原始输入落盘）
- R1：`solution.md`（澄清完成后产出推荐方案 + 验证清单）
- R2：`prd.md`（可选，冻结交付规格）
- R3：`prototype.md`（可选，ASCII 原型，消除交互歧义）
- R4：Demo（可选，可交互走查）

**设计决策链路（可选 D0–D2，整体可跳过）**：

- D0：分流（判断是否跳过 design；跳过时 `plan.md` 补齐最小决策信息）
- D1：`design/research.md`（可选，调研结论 + 验证清单）
- D2：`design/design.md`（未跳过时必做，决策文档 / RFC）

**开发执行链路（必做 I1–I2 + Finish）**：

- I1：`implementation/plan.md`（**唯一执行清单与状态 SSOT**）
- I2：按 `plan.md` 分批执行并回写状态/审计信息（状态只写回 `plan.md`）
- Finish：只做验证，生成完成确认报告（全绿才算完成）

#### 4.2 需求级硬门禁：先定位 `FEATURE_DIR`（禁止猜路径）

只要会读写任一 Spec Pack 文件（`requirements/*`、`design/*`、`implementation/*` 或 R4 写 demo），都必须先用 **`spec-context`** 得到并回显：

- `FEATURE_DIR=...`（需求包根目录）
-（R4 还需要）`CURRENT_BRANCH`、`REPO_ROOT`

对应技能：

- `skills/spec-context/SKILL.md`：`spec-context`

#### 4.3 最短闭环（简单需求的推荐路径）

适用：范围单一、风险低、验收口径能在 `solution.md` 写清楚。

- `spec-init` → `spec-context` → `spec-product-clarify` → `spec-implementation-plan` → `spec-implementation-execute` → `finishing-development`

#### 4.4 常规闭环（需要规格/交互对齐时）

- `spec-init` → `spec-context` → R1 `spec-product-clarify`
- 按需执行：R2 `spec-product-prd` → R3 `spec-product-prototype` → R4 `spec-product-demo`
- 按需进入设计：D1 `spec-design-research`（可选）→ D2 `spec-design`
- 必做实现：I1 `spec-implementation-plan` → I2 `spec-implementation-execute` → Finish `finishing-development`

---

### 6. 需求链路（R0–R4）：适用场景与技能

#### 5.1 R0：初始化 Spec Pack（新需求开工）

- **适用场景**：还没有合法 `{num}-{short-name}` 分支与 `.aisdlc/specs/...` 目录。
- **技能**：`spec-init`（`skills/spec-init/SKILL.md`）
- **输出**：`{FEATURE_DIR}/requirements/raw.md`（UTF-8 with BOM）
- **关键注意**：
  - `spec-init` 强制以“文件路径”传入原始需求（避免中文参数编码问题）。
  - 脚本会删除传入的源文件（需要保留要先备份）。

#### 5.2 R1：澄清 + 方案决策（raw → solution）

- **适用场景**：需求模糊、范围不稳、约束不清、易脑补。
- **技能**：`spec-product-clarify`（`skills/spec-product-clarify/SKILL.md`）
- **输出**：`{FEATURE_DIR}/requirements/solution.md`
- **关键纪律**：
  - **澄清未完成，禁止写 `solution.md`**。
  - 每轮只问 **1 个最高杠杆选择题**，并把“问题/推荐/回答/结论/遗留歧义/未澄清点/是否完成”回写到 `raw.md/## 澄清记录`。
  - 不确定性禁止写“待确认问题清单”，统一进入**验证清单**（Owner/截止/信号/动作）。

#### 5.3 R2：PRD（solution → prd，可选）

- **适用场景**：需要冻结交付规格、QA 需要可测试 AC、研发需要可拆任务的规格说明。
- **技能**：`spec-product-prd`（`skills/spec-product-prd/SKILL.md`）
- **输入门禁**：必须存在 `{FEATURE_DIR}/requirements/solution.md`。
- **输出**：`{FEATURE_DIR}/requirements/prd.md`
- **分流**：若是“简单需求”，不一定需要独立 `prd.md`，可在 `solution.md` 追加 Mini-PRD 后进入后续阶段。

#### 5.4 R3：原型（prd → prototype，可选）

- **适用场景**：存在新增/变更交互、或交互不够明确，需要用“文本原型+线框”消除歧义。
- **技能**：`spec-product-prototype`（`skills/spec-product-prototype/SKILL.md`）
- **输入门禁**：必须存在 `{FEATURE_DIR}/requirements/prd.md`。
- **输出**：`{FEATURE_DIR}/requirements/prototype.md`
- **硬要求**：
  - 必须是 **纯 ASCII 线框**。
  - 必须包含：任务流（T-xxx）、页面/弹窗清单（P/D/W-xxx）、逐页说明、AC→节点映射、走查脚本。

#### 5.5 R4：可交互 Demo（prototype → demo，可选）

- **适用场景**：需要更高保真走查（可用性验证/干系人对齐/研发与测试理解一致性校验）。
- **技能**：`spec-product-demo`（`skills/spec-product-demo/SKILL.md`）
- **输入门禁**：必须存在 `{FEATURE_DIR}/requirements/prototype.md`。
- **输出**：默认 `{REPO_ROOT}/demo/prototypes/{CURRENT_BRANCH}/`
- **硬禁止**：
  - 找不到可运行 Demo 工程根目录时，**禁止**自行初始化新前端工程污染仓库；必须停止并要求 `DEMO_PROJECT_ROOT`。
  - **禁止自创页面**：页面清单只能来自 `prototype.md`。

---

### 7. 设计链路（D0–D2）：适用场景与技能

#### 6.1 D0 分流：是否可以跳过设计

在本仓库的设计链路中，“跳过设计”不是偷懒，而是一个明确决策：  
若跳过，必须在 `implementation/plan.md` 补齐最小决策信息，并保持可追溯与可验证。

#### 6.2 D1：Research（可选调研）

- **适用场景**：关键不确定性/高风险点需要先验证；多方案缺证据支撑取舍。
- **技能**：`spec-design-research`（`skills/spec-design-research/SKILL.md`）
- **输出**：`{FEATURE_DIR}/design/research.md`
- **关键约束**：
  - 研究产物不写实现规格（任务/字段/DDL/脚本），只写可被 D2 引用的结论与验证清单。
  - 禁止 TODO/待确认清单，未知统一进入验证清单（Owner/截止/信号/动作）。

#### 6.3 D2：Decision Doc / RFC（设计决策文档）

- **适用场景**：涉及对外契约/权限/数据口径变化；跨系统影响大；需要评审共识与冻结口径。
- **技能**：`spec-design`（`skills/spec-design/SKILL.md`）
- **输出**：`{FEATURE_DIR}/design/design.md`
- **写作边界**：写“决策与对外承诺要点 + 追溯链接”，不写实现步骤与任务拆分。

---

### 8. 实现链路（I1–I2）：适用场景与技能

#### 7.1 I1：实现计划（plan.md = 唯一 SSOT）

- **适用场景**：任何要进入开发执行的需求（必做）。
- **技能**：`spec-implementation-plan`（`skills/spec-implementation-plan/SKILL.md`）
- **输出**：`{FEATURE_DIR}/implementation/plan.md`
- **关键要求**：
  - `plan.md` 内必须有可勾选任务（`- [ ]/- [x]`），且每个任务包含：精确文件路径、可执行步骤、最小验证命令与期望信号、提交点与审计信息。
  - 不确定性统一写到 `plan.md/NEEDS CLARIFICATION`，并**阻断进入 I2**。
  - **Commit message 必须中文**（计划里也要体现）。

#### 7.2 I2：按计划分批执行并回写

- **适用场景**：已有可执行的 `plan.md`，要按批次实现并做检查点汇报。
- **技能**：`spec-implementation-execute`（`skills/spec-implementation-execute/SKILL.md`）
- **输出**：
  - 代码与配置变更
  - **唯一状态回写**：只回写到 `{FEATURE_DIR}/implementation/plan.md`（checkbox + commit/pr/changed_files + 验证结果摘要）
- **关键纪律**：
  - 默认每批执行前 3 个未完成任务，批次之间只汇报并等待反馈。
  - 遇阻塞/澄清项立即停止（寻求澄清，不猜测推进）。
  - 执行中若出现 ADR/契约变化：只在 `{FEATURE_DIR}` 内草拟，并在 `plan.md` 记录 Merge-back 待办；I2 不直接改 `project/*`。

#### 7.3 Finish：开发收尾确认（只验证）

- **适用场景**：实现已完成，需要证明“全绿”并生成可复现的完成确认报告。
- **技能**：`finishing-development`（`skills/finishing-development/SKILL.md`）
- **产出**：完成确认报告（含实际运行的命令与结果）。

---

---

### 9. 场景 → 技能选择速查

#### 9.1 我现在在做“需求”还是“项目知识库”？

- **交付一个需求**：走 `using-aisdlc` 导航 Spec Pack（R/D/I/Finish）。
  - 技能：`using-aisdlc`（`skills/using-aisdlc/SKILL.md`）
- **让 AI/新人不再猜入口**：走 `project-discover` 总控（Discover）。
  - 技能：`project-discover`（`skills/project-discover/SKILL.md`）

#### 9.2 典型场景表

| 典型场景 | 推荐技能链路 | 你要得到的核心产物 |
|---|---|---|
| 新需求刚来，没有分支/目录 | `spec-init` → `spec-context` | `requirements/raw.md` + 可定位 `FEATURE_DIR` |
| 需求模糊、争议大、容易脑补 | `spec-context` → `spec-product-clarify` | `solution.md`（含验证清单）+ `raw.md/澄清记录` |
| 需要冻结规格供评审/研发拆解/QA用例 | `spec-context` → `spec-product-prd` | `prd.md`（场景+AC 可测试） |
| 交互有歧义，需要文本原型对齐 | `spec-context` → `spec-product-prototype` | `prototype.md`（ASCII 线框 + AC 映射 + 走查脚本） |
| 干系人需要可点可跑走查 | `spec-context` → `spec-product-demo` | Demo（严格按 prototype 页面清单） |
| 需要 RFC 决策文档/涉及对外承诺变更 | `spec-context` → `spec-design`（按需先 `spec-design-research`） | `design/design.md`（决策与验证清单） |
| 要进入开发执行，但没有可执行计划 | `spec-context` → `spec-implementation-plan` | `implementation/plan.md`（唯一 SSOT） |
| 按计划落地实现，并要求审计与检查点 | `spec-context` → `spec-implementation-execute` | 代码变更 + `plan.md` 回写（唯一状态来源） |
| 开发已完成，需要“全绿”证明 | `finishing-development` | 完成确认报告（命令+结果可复现） |
| 存量项目：入口/边界/契约总在猜 | `project-discover`（按子技能分段） | `.aisdlc/project/*`（memory+index+模块页+ops+DoD） |

---

### 10. 培训演练（建议两小时可跑通）

#### 10.1 演练 A：存量项目 Discover（最小可用交付，建议先做）

目标：先交付“可消费的项目级知识库 MVP”：memory + components index + 1–3 个 P0 模块页（含契约段落与证据链）。

- `project-discover-preflight-scope`
- `project-discover-memory-index`
- `project-discover-modules-contracts`（选 1–3 个 P0 模块）
- `project-discover-products-ops-dod`（只做必要收敛与 DoD）

#### 10.2 演练 B：最短闭环（简单需求）

目标：让学员体验“一个节点一个产物”的节奏，以及 `plan.md` 作为唯一 SSOT 的执行方式。

- R0：`spec-init` 生成 `raw.md`
- 门禁：`spec-context` 回显 `FEATURE_DIR=...`
- R1：`spec-product-clarify`（要求：澄清记录回写 + 产出 `solution.md`）
- I1：`spec-implementation-plan`（任务清单可执行、含最小验证命令）
- I2：`spec-implementation-execute`（分批执行、回写审计到 `plan.md`）
- Finish：`finishing-development`（输出完成确认报告）

#### 10.3 演练 C：复杂交互需求（R2+R3+R4）

目标：体验“PRD（可测）→ 原型（可走查）→ Demo（可点可跑）”的闭环与回流机制。

- R2：`spec-product-prd`（AC 可测试）
- R3：`spec-product-prototype`（ASCII 线框 + AC→节点映射 + 走查脚本）
- R4：`spec-product-demo`（严格按 prototype 页面清单生成）
- 发现问题：按规则回流更新 `solution/prd/prototype`（而不是在 demo 里自由发挥）

---

### 11. 常见红旗（出现任一条：当场纠偏）

#### 11.1 Discover 常见红旗

- 在索引里写细节（不变量/字段/流程/待补），导致双写与漂移。
- 出现 `.aisdlc/project/contracts/**`（违反硬规则）。
- 模块页正文用“待补/未发现”占位而不是写到 `Evidence Gaps`。
- P0 模块在索引被打勾，但模块页不达标（缺固定标题、缺权威入口/不变量/证据入口、缺 frontmatter 元数据）。

#### 11.2 Spec Pack 常见红旗

- 没跑 `spec-context` 就开始读写 `requirements/*` / `design/*` / `implementation/*`。
- 用户口头给了路径/分支，你就跳过门禁“信了并继续写”。
- R1 澄清未完成就写 `solution.md`。
- 用“待确认问题/Open Questions/TODO”清单承接不确定性（应该改为验证清单：Owner/截止/信号/动作）。
- 没有 `implementation/plan.md`（或 plan 不可执行）就直接开始写代码。
- 执行状态写到聊天/issue/另一个文件，而不是回写 `plan.md`（破坏 SSOT）。

---

### 12. 附录：技能清单（按流程排序）

#### 12.1 Discover（项目级知识库）

- `project-discover`：Discover 总控（硬规则：无 `contracts/**`、索引只导航、模块页单页 SSOT、Evidence Gaps）。
- `project-discover-preflight-scope`：证据入口盘点 + P0/P1/P2 止损。
- `project-discover-memory-index`：memory 北极星 + 索引骨架（地图层）。
- `project-discover-modules-contracts`：模块页 + 契约段落 + 证据链。
- `project-discover-products-ops-dod`：Products 收敛 + Ops 入口 + DoD 门禁 + Delta Discover/stale。

#### 12.2 Spec Pack 导航与门禁

- `using-aisdlc`：流程导航 + 门禁总控（R0–R4 与 I1–Finish 的“下一步选技能”）。
- `spec-context`：唯一上下文定位（`FEATURE_DIR`），失败即停止。
- `spec-init`：创建新 Spec Pack（分支+目录+`raw.md`，UTF-8 with BOM）。

#### 12.3 需求侧（R1–R4）

- `spec-product-clarify`：澄清循环 + `solution.md`（澄清未完成禁止写 `solution.md`）。
- `spec-product-prd`：`solution.md` → `prd.md`（可交付/可验收/可测试）。
- `spec-product-prototype`：`prd.md` → `prototype.md`（ASCII 原型 + AC 映射 + 走查脚本）。
- `spec-product-demo`：`prototype.md` → Demo（必须找到可运行 Demo 根目录；禁止自创页面/工程）。

#### 12.4 设计侧（D1–D2）

- `spec-design-research`：可选调研，产出 `design/research.md`（结论 + 验证清单）。
- `spec-design`：产出 `design/design.md`（决策文档/RFC，写决策不写实现）。

#### 12.5 实现侧（I1–I2）与收尾

- `spec-implementation-plan`：产出 `implementation/plan.md`（唯一执行清单与状态 SSOT）。
- `spec-implementation-execute`：按 `plan.md` 分批执行并回写审计（状态只写回 `plan.md`）。
- `finishing-development`：收尾确认（只验证，全绿才算完成）。

#### 12.6 并行与协作（可选加餐）

- `dispatching-parallel-agents`：2+ 独立问题域并行处理的派发方法。
- `subagent-driven-development`：按 `plan.md` 每任务派发子智能体并两阶段审查。
- `spec-requesting-code-review` / `spec-receiving-code-review`：代码审查请求与接收（强调技术验证，避免表演性同意）。

