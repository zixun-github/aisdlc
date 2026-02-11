---
markdown-sharing:
  uri: 7ac73b2a-67cd-46a2-866c-93cc56503720
---

# AI SDLC 项目知识库（项目级 SSOT + 需求执行 Spec Pack + 渐进式披露）方案

本文档定义一个用于 SDLC 全流程的 **AI 项目知识库**：以 **项目级 SSOT** 作为长期、稳定的单一事实源（SSOT），并支持 **AI 渐进式披露（Progressive Disclosure）**，让各阶段 Agent 能"先看地图，再按需取证"。
同时，每个需求拥有独立的 **需求级 Spec Pack（SSOT）**，用于该需求执行过程中的规格沉淀、证据留存与可追溯交付；**需求级 Spec Pack 不作为 AI 知识库渐进披露的信息源**，需求完成后通过 Merge-back 将可复用信息合并回项目级资产，其余内容归档保存以便审计与复盘。

---

## 项目背景

公司正在推动**研发新范式升级**，核心方向是把“知识组织方式”和“研发过程方法论”工程化、标准化，并通过 AI 实现稳定提效与持续演进。本项目是该升级中的重要一环，主要承担两类建设目标：

- **建立 AI SDLC 项目知识库**：围绕项目级 SSOT 与索引体系，形成可持续维护的知识资产，以支持信息的有效组织、检索、引用与追溯，降低信息分散与上下文丢失带来的沟通成本与返工风险。
- **建立各节点 SOP，并在各阶段使用 AI 辅助提效**：将每个阶段“读什么/写什么/如何验收”的流程固化为工作流与模板，并结合 SKILL 等机制把最佳实践沉淀为可复用的工具与自动化能力，使交付质量、效率与一致性可度量、可复制、可迭代。

---

## 核心理念：项目级 SSOT + 需求级 Spec Pack

### SSOT（Single Source of Truth）原则

- **项目级 SSOT（Project Spec Set）**：项目维度的长期事实源，包含产品业务信息、模块信息、代码结构等。通过版本控制、代码审查确保文档与代码同步演进，避免文档过时。
  - **长生命周期、强治理**（以资产与运营为中心）：通过持续更新与版本管理，形成项目的长期知识资产
  - 包含：Roadmap、架构、对外契约、数据口径、运行手册、NFR 预算、风险清单等

- **需求级 SSOT（Spec Pack）**：每个需求有自己的"Spec 包"，覆盖该需求从 PRD 到发布的闭环产物与证据，**仅对该需求的执行过程生效**。
  - **短生命周期、强时效**（以交付为中心）：围绕交付闭环，文档随代码一起演进，避免文档与实现脱节
  - **不作为渐进披露信息源**：不参与跨需求的知识积累；跨需求可复用信息必须通过 Merge-back 合并到项目级
  - 需求完成后，按规则把可复用资产从需求层"晋升"到项目层；其余作为交付证据归档保留，并通过版本控制记录完整演进历史

### Spec as Code 理念

将 Spec 文档当做项目代码一样对待及维护，遵循版本控制、代码审查、持续更新等工程化实践。

### SOP：用“工作流 + 模版”把最佳实践 AI 化

用工作流定义“每一步读什么/写什么/怎么验收”，用模板固化“怎么写”，让最佳实践成为默认路径。

- **工作流（Workflow）**：输入/输出/门禁/证据的步骤编排（可机器读取）
- **模版（Template）**：原子 Spec 的固定骨架（Frontmatter + 正文最小闭环）
- **门禁（Gates）**：DoR/DoD、结构完整、引用/追溯齐全、契约/测试/发布校验

**落地位置（目录约定）**：

- `.aisdlc/workflows/`：工作流定义（YAML/JSON）
- `templates/`：模板（Markdown）

**最小执行闭环**：生成模板 → 补全关键信息 → 自检门禁 → 评审（必要时 ADR）→ 回写入库/merge-back

---

## 目标与原则

- **双层 SSOT**：项目级长期资产 + 需求级交付闭环，确保信息一致性和可追溯性
- **渐进式披露**：Agent 默认只加载**项目级**全局规范与索引（地图）；当任务明确指向某个需求时，才读取该需求的 Spec Pack 中最少必要的原子 Spec 文件（需求级不作为全局披露信息源）
- **可追溯（Traceability）**：Spec ↔ 代码 ↔ 测试 ↔ 发布/运维文档之间通过 ID 与引用互相链接
- **机器可读优先**：Markdown + YAML Frontmatter + Mermaid + OpenAPI/SQL/JSON Schema 等结构化片段，降低歧义

---

## Spec 的 7 阶段（顶层规划：只定义核心输出）

> 说明：
> - 这里的“阶段”指 **需求级 Spec Pack** 的执行闭环阶段（**不包含**项目级长期资产的日常治理）。
> - 每个阶段只定义“**核心输出**”，避免在顶层规划中写成细节 SOP；SOP/门禁由各阶段的专项文档补齐。

| 阶段 | 核心目标 | 核心输出（Spec Pack 产物） |
|---|---|---|
| 1. 产品需求（product） | 明确“做什么/为什么做/成功标准是什么” | `requirements/raw.md`（原始需求）＋ `requirements/prd.md`（PRD：目标/范围/关键流程/验收口径/风险） |
| 2. 重构需求（refactor） | 明确“为什么要重构/基线是什么/不变量与允许变化点” | `refactors/clarify.md`（目标/范围/约束/不变量）＋ `refactors/baseline.md`（现状基线：结构/依赖/指标/痛点） |
| 3. 需求设计（design） | 把需求/重构映射为可评审方案 | `design/solution.md`（概要方案、边界、关键权衡）＋（按需）`design/research.md`、契约/数据模型、ADR 入口 |
| 4. 需求实现（implementation） | 把方案落到可执行的实现计划并完成变更 | `implementation/plan.md`（实现计划）＋ `implementation/tasks.md`（任务分解）＋ 代码变更与追溯链接（Spec ↔ PR/提交） |
| 5. 需求测试（verification） | 验证功能与非功能满足验收口径 | `verification/plan.md`（测试策略/范围）＋ 用例/回归集 ＋ `verification/report.md`（测试报告与结论） |
| 6. 发布（release） | 可控上线、可观测运行、可回滚 | `release/plan.md`（发布计划）＋ `release/runbook.md`（运行手册）＋ `release/monitoring.md`（监控告警）＋ `release/rollback.md`（回滚方案） |
| 7. 回档（merge-back） | 将“可复用资产”晋升回项目级 SSOT，其余归档留证 | `merge_back.md`（清单与证据）：ADR/契约/运维资产/NFR 基线等是否已同步到 `project/`；并更新 Registry 状态 |

---

## 双层 SSOT 目录结构（渐进式披露基于项目级）

核心分层：**项目级 Memory（宪法）→ 项目级索引/地图层（入口）→（按需）需求级 Spec Pack（SSOT）→ 交付物层（代码/测试/运维）**。

### 目录结构（可直接落地）
```text
.aisdlc
  project                          # 项目级 SSOT（长期资产）
    memory                         # 项目级 Memory（链接文件，提供全局上下文）
      product.md                   # 业务信息
      tech.md                      # 技术信息
      structure.md                 # 项目结构
      glossary.md                  # 术语表
    adr                            # 架构决策记录
      index.md
      0001-xxx.md
      ...
    contracts                      # 对外契约
      index.md
      api                          # API 契约
        index.md
        auth.yaml
        user.yaml
        ...
      data                         # 数据契约
        index.md
        schemas
        dictionaries
        ...
    products                       # 业务架构层（Business Architecture，可选）：业务域/业务模块资产（索引 + 模块文件）
      index.md
      a.md
      ...
    components                     # 应用架构层（Application Architecture，可选）：承载业务能力的应用组件资产（索引 + 模块文件）
      index.md
      a.md
      ...
  specs                          # 需求级 SSOT（交付闭环）
    001-demo                      # 需求 ID（格式：{num}-{domain-name}，num 为三位数字编号）
      merge_back.md                # Merge-back 执行时生成
      requirements                 # 产品需求（product）阶段（原始需求/PRD/用例等）
        raw.md                     # 原始需求
        prd.md                     # 产品需求文档
        backlog.md                 # 需求列表、优先级
        usecase.md                 # 用例、用户故事
        ...
      refactors                    # 重构需求阶段（仅重构类需求需要）
        clarify.md                 # 目标/范围/约束/不变量
        baseline.md                # 现状基线（结构/依赖/指标/痛点）
      design                       # 设计阶段
        research.md                # 调研、竞品分析
        solution.md                # 方案设计、ADR
        api.yaml                   # API 设计
        data.md                    # 数据模型
        sequence.md                # 时序图
        ...
      implementation               # 实现阶段
        plan.md                    # 实现计划
        task.md                    # 任务分解
        migration.md               # 迁移方案（如适用）
        ...
      verification                 # 测试验证阶段
        plan.md                    # 测试计划
        usecase.md                 # 测试用例
        report.md                  # 测试报告
        ...
      release                      # 发布运维阶段
        plan.md                    # 发布计划
        runbook.md                 # 运行手册
        monitoring.md              # 监控告警
        rollback.md                # 回滚方案
        postmortem.md              # 复盘报告
        ...
    002-demo
      ...
```

> 说明：
> - `project/products/` 用于**业务架构层（Business Architecture）**的“业务域/业务模块”资产，表达业务边界、业务能力、价值流/核心场景、参与者/角色、业务流程、业务服务、业务对象与事件、业务规则与口径、业务指标与依赖等（强调业务语义，不写技术实现）。
> - `project/components/` 用于**应用架构层（Application Architecture）**的“应用组件”资产，表达应用组件边界、应用服务/接口、组件协作与数据对象责任等（强调应用层承诺与协作边界，不写具体实现细节）。
> - 技术基础设施/平台能力（Technology Layer，例如缓存、消息队列、网关、中间件）**不建议**混入 `project/components/`；如项目需要，可新建 `project/platform/` 或 `project/tech/` 承载对应资产（按需落地）。

---

注意：上述文件的模版放置在目录 templates 下

## 业务架构：用企业架构知识描述业务领域与模块（项目级长期资产）

> 目标：让“业务模块”的描述方式与“应用组件”同等清晰，从而把需求、方案与实现稳定地锚定在业务语义上（并支持跨需求复用与治理）。

### 业务模块（`project/products/`）应该写什么

用企业架构（业务架构）常见的表达方式，把业务模块写成可治理、可复用的长期资产（建议至少覆盖）：

- **业务边界（In/Out）**：这个模块对业务负责什么、不负责什么，与相邻模块边界如何裁切（冲突如何裁决：契约/ADR/口径）。
- **业务能力（Capability）**：模块承载的能力清单（P0/P1/P2），能力以“输入→处理→输出”的业务表述定义。
- **价值流/核心场景（Value Stream / Scenario）**：从触发到结果的端到端业务价值链路，帮助需求落点对齐业务结果。
- **参与者/角色（Actor/Role）**：谁在业务上触发/消费该模块能力，以及职责边界（可选 RACI）。
- **业务流程（Business Process）**：关键流程及其触发、结果、Owner；优先用图（如 PlantUML）表达。
- **业务服务（Business Service）**：面向角色的稳定业务承诺（输入/输出/前置条件/业务约束）。
- **信息对象与事件（Business Object / Event）**：核心业务对象（生命周期、主键/唯一标识、关键稳定属性）与业务事件语义。
- **政策与业务规则（Policy / Business Rule）**：触发、条件、动作、例外、口径/数据引用与合规来源（实现细节下沉需求级）。
- **业务口径与指标（KPI/度量）**：关键指标的业务定义与口径入口（指向数据契约/字典），用于“业务结果可观测”。
- **业务依赖与集成（上下游）**：业务依赖原因、交互方式、业务风险与缓解措施。

### 业务模块与应用组件的映射关系（推荐）

- **业务模块（Business）→ 应用组件（Application）**：业务模块表达“做什么/为什么做/业务边界”，应用组件表达“如何承载该业务能力的应用层承诺与协作边界”。
- **能力/流程/对象对齐**：建议在 `project/products/*.md` 与 `project/components/*.md` 中用相同的 Capability/Process/Object 编号进行交叉引用，形成稳定追溯（例如 `CAP-001`、`BP-001`、`BO-001`）。

### 需求级 Spec Pack 如何落到业务模块

- 需求的 `specs/<DEMAND-ID>/requirements/` 与 `design/` 应**引用**对应业务模块（`project/products/*.md`）中的能力/流程/规则/对象编号，避免在需求级重复定义长期稳定的业务语义。
- 当某需求引入“新的长期业务能力/规则/口径”，应在 Merge-back 阶段晋升更新到 `project/products/`，并记录变更原因与关联 ADR/Spec。

---

## 应用架构：用企业架构知识描述应用组件与应用服务（项目级长期资产）

> 目标：把“应用组件”写成可治理、可复用的长期资产，清晰表达应用层对业务的稳定承诺、组件协作边界、对外接口与数据对象责任；同时严格避免把一次性实现细节（类/函数/代码结构）混入项目级资产。

### 应用组件（`project/components/`）应该写什么

按企业架构（应用架构，ArchiMate Application Layer）常见表达方式，建议至少覆盖：

- **组件定位（In/Out + 边界）**：组件提供什么应用能力/承诺、明确不负责什么；与相邻组件边界如何裁切（以契约/ADR 为裁决依据）。
- **承载业务映射**：该组件承载哪些业务模块（`project/products/*.md`）、哪些业务能力/流程/对象（CAP/BP/BO 编号），以及面向哪些消费者（人/系统/其他组件）。
- **应用服务目录（Application Service Catalog）**：稳定的“应用层服务承诺”，描述输入/输出、前置条件/约束（业务/合规）、SLA/SLO/NFR 要点（不写实现）。
- **应用接口与契约入口（Application Interface）**：
  - API：权威入口指向 `project/contracts/api/*.yaml`
  - 事件/消息：topic/event 的业务语义与契约入口（如适用）
  - UI/Batch：入口与约束（如适用）
- **关键协作关系（Interaction / Collaboration）**：挑 1-2 个代表性场景，说明跨组件调用链/协作关系与关键边界（详细时序下沉需求级）。
- **数据对象与责任边界（Data Object & Ownership）**：组件负责哪些数据对象（Owner/主写/只读）、主键/唯一标识与生命周期摘要；权威定义指向 `project/contracts/data/`。
- **非功能需求分摊（NFR Allocation）**：性能、可用性、安全合规、成本等“护栏/预算”在组件层的分摊与边界；运行操作细节指向 `project/ops/`。
- **集成与依赖（上下游清单）**：依赖原因、交互方式、风险与缓解措施（技术实现细节不写在这里）。
- **运行入口（轻量）**：监控/告警、Runbook、回滚等入口链接（不重复操作步骤）。

### 应用架构与业务架构/技术架构的边界（建议）

- **业务架构（Business）**：回答“做什么/为什么做/业务边界与语义”（能力、流程、对象、规则、口径、KPI）。
- **应用架构（Application）**：回答“由哪些应用组件承载业务能力，以及对外提供哪些稳定的应用服务/接口与协作边界”（组件、服务、接口、数据对象责任、协作关系、NFR 分摊）。
- **技术架构（Technology/Platform）**：回答“用哪些基础设施/平台能力支撑应用运行”（网关、消息、缓存、可观测、安全、发布等），原则上不混入 `project/components/`。

### 需求级 Spec Pack 如何落到应用组件

- 需求的 `specs/<DEMAND-ID>/design/` 应**引用**对应应用组件（`project/components/*.md`）中的应用服务/接口/数据对象编号与契约入口，避免在需求级重复定义长期稳定的应用层承诺。
- 需求级应承载“为交付而生”的细节：详细时序、错误码、字段级约束、迁移脚本、具体实现方案等；其中可复用的接口/数据契约与关键 ADR 必须 Merge-back 回 `project/contracts/` 与 `project/adr/`。
- 当需求引入“新的长期应用服务/接口契约/数据对象责任边界”，应在 Merge-back 阶段晋升更新到 `project/components/`，并记录变更原因与关联 ADR/Spec。

### 多级结构说明

**项目级 Memory（`project/memory/`）**：
- 项目快照，包含产品业务信息、模块信息、代码结构等
- 链接到项目级 SSOT 的稳定资产（`project/adr/`、`project/contracts/` 等）
- 每次 Agent 执行任务时都应优先加载，提供全局上下文

**需求级 Memory（`specs/<DEMAND-ID>/index.md`）**：
- 当前需求的上下文摘要和相关引用
- 按需加载，仅在处理特定需求时使用
- 包含该需求相关的项目级资产引用，避免重复加载
 - 不进入项目级知识库的渐进披露信息源（如需沉淀为通用知识，必须 Merge-back 到 `project/`）

> **需求编号命名规则**：`<DEMAND-ID>` 格式为 `{num}-{domain-name}`，其中 `num` 为三位数字编号（如 `001`、`002`），`domain-name` 为需求领域名称（如 `demo`、`user-auth`）。示例：`001-demo`、`002-user-auth`。

### 信息分层的读取顺序（Agent 的默认策略）

1. **必读（项目级全局上下文）**：
   - `project/memory/product.md`（业务信息）
   - `project/memory/tech.md`（技术信息）
   - `project/memory/structure.md`（项目结构）
   - `project/memory/glossary.md`（术语表）
   - `project/index.md`（Spec Registry，了解项目全局状态）

2. **入口（地图层）**：
   - `project/index.md`（Spec Registry，需求列表与状态）
   - `project/products/index.md`（业务架构索引：业务域/业务模块地图，可选）
   - `project/components/index.md`（应用架构索引：应用组件地图，可选）
   - `project/contracts/index.md`（契约索引）
   - `project/adr/index.md`（架构决策索引）

3. **按需（需求级 Spec Pack）**：
   - 仅当任务明确指向某个需求时，读取对应需求的 `specs/<DEMAND-ID>/index.md`
   - 再按需读取该需求 Spec Pack 中的具体文档（requirements/、design/、implementation/、verification/、release/ 等）
   - 不将其它需求的 `specs/` 内容当作通用知识源；需要跨需求复用的内容必须 Merge-back 到 `project/`

4. **回写（产出入库）**：
   - 需求级输出：写入对应需求的 `specs/<DEMAND-ID>/` 目录
   - 项目级更新：通过 Merge-back 机制，将可复用资产晋升到 `project/` 目录

---

## 需求 Spec Pack 生命周期与 Merge-back

### 需求生命周期状态流转

每个需求（Spec Pack）从创建到归档的完整生命周期：

- **Draft**：创建需求目录结构，初始化 `index.md`
- **In Review**：需求评审阶段，完善 `requirements/prd.md`
- **Approved(DoR)**：设计评审完成，达到 DoR（范围冻结、验收可执行、依赖可用、风险可控）
- **In Dev**：开发实现阶段，代码与 Spec 文档同步更新
- **In QA**：测试验证阶段，执行测试并生成报告
- **Released**：发布上线，按灰度策略逐步放量
- **Merged & Archived**：执行 Merge-back，将可复用资产晋升到项目层

### Merge-back：把短期交付变成长期资产

需求完成后，不应把所有文档"全拷贝"到项目层，而是按资产类型**筛选晋升**：

#### 必须合并回项目层的内容（默认）

- **ADR**：任何关键决策必须进入 `project/adr/` 并在 `project/adr/index.md` 汇总
- **对外契约**：
  - API：若有变更，更新 `project/contracts/api/`（或链接到 Schema 文件），并更新弃用策略
  - Data：若有变化，更新 `project/contracts/data/`（字典/口径/质量规则）与迁移结论
  - UX：关键流程/信息架构变更，更新 `project/contracts/ux/`（如适用）
- **运行资产**：上线相关 Runbook/监控告警/回滚策略，更新 `project/ops/`
- **NFR 预算与基线**：若对性能/稳定性/成本有影响，更新 `project/nfr.md`（预算、现状、目标）

#### Merge-back 的执行方式

在每个需求 `specs/<DEMAND-ID>/merge_back.md` 里维护清单（Done/Not Done）：
- ADR 是否已归档到 `project/adr/`
- API/Data/UX 是否已更新到 `project/contracts/` 对应目录
- Runbook/监控是否已更新到 `project/ops/`
- NFR 预算是否更新到 `project/nfr.md`
- Registry 是否更新需求状态为 Released / Merged（更新 `project/index.md`）

> Merge-back 是"需求真正完成"的一部分，建议纳入 DoD。

---

## 原子 Spec 的规范（让 AI "读得准、写得对"）

### 文件头元数据（YAML Frontmatter，建议强制）

每个原子 Spec 文件建议以如下元数据开头，用于索引、依赖与披露策略：

```yaml
---
id: 001-user-auth                   # 全局唯一 ID（格式：{num}-{domain-name}）
demand_id: 001-user-auth             # 所属需求 ID（格式：{num}-{domain-name}）
stage: requirements                  # product/backlog/requirements/solution/...
title: 用户登录（短信验证码）
status: draft                        # draft/review/approved/deprecated
owners: [PM, BA, DEV, QA]
depends_on:
  - project/memory/product.md
  - project/contracts/api/auth.yaml
  - specs/001-user-auth/requirements/prd.md
policy_refs:
  - project/memory/tech.md#质量门禁
  - project/memory/product.md#安全
related_code:
  - src/auth/*
related_tests:
  - tests/e2e/auth-login.spec.ts
---
```

### 推荐正文结构（最小闭环）

- **背景与目标**：为什么做、要达成什么
- **范围**：In/Out
- **流程**：Mermaid（强制优先于纯文本）
- **规则与边界**：异常、幂等、并发、权限、审计
- **数据与接口契约**：OpenAPI/Schema/SQL 片段
- **验收标准（AC）**：可直接转测试用例的、可验证的条件
- **追溯链接**：相关 ADR、相关代码、相关测试、相关发布项

---

## 各阶段输出如何入库（写入位置约定）

### 项目级输出（长期资产）

- **架构演进**：`project/memory/`（product.md、tech.md、structure.md、glossary.md）
- **架构决策**：`project/adr/`（架构决策记录）
- **契约更新**：`project/contracts/`（api/、data/、ux/）
- **运行资产**：`project/ops/`（runbook.md、release.md、monitoring.md）
- **NFR 预算**：`project/nfr.md`
- **项目总览**：`project/index.md`（Spec Registry）

### 需求级输出（交付闭环）

- **产品需求（product）**：`specs/<DEMAND-ID>/requirements/raw.md`、`requirements/prd.md`（目标/范围/关键流程/验收口径）
- **重构需求（refactor）**：`specs/<DEMAND-ID>/refactors/clarify.md`、`refactors/baseline.md`（仅重构类需求需要）
- **需求设计（design）**：`specs/<DEMAND-ID>/design/`（`solution.md` 为核心；按需包含 research/契约/数据/时序等）
- **需求实现（implementation）**：`specs/<DEMAND-ID>/implementation/`（计划、任务分解、迁移与验证记录；并在代码/PR中回链追溯）
- **需求测试（verification）**：`specs/<DEMAND-ID>/verification/`（测试计划、用例/回归集、报告）
- **发布（release）**：`specs/<DEMAND-ID>/release/`（发布计划、Runbook、监控告警、回滚、复盘）
- **回档（merge-back）**：`specs/<DEMAND-ID>/merge_back.md`（晋升清单与证据：同步到 `project/` 的 ADR/契约/运维/NFR 等）

---

## 最小落地清单（建议从这里开始）

1. **建立项目级结构**：
   - 创建 `.aisdlc/project/` 目录结构
   - 创建 `project/memory/` 目录，补齐 `product.md`、`tech.md`、`structure.md`、`glossary.md`
   - 创建 `project/index.md`（Spec Registry）
   - 创建 `project/adr/` 目录（架构决策记录）
   - 创建 `project/contracts/`、`project/ops/`、`project/nfr.md` 基础结构

2. **建立项目级 Memory**：
   - Memory 文件（`product.md`、`tech.md`、`structure.md`、`glossary.md`）已位于 `project/memory/` 目录
   - 这些文件链接到项目级 SSOT 的稳定资产（`project/adr/`、`project/contracts/` 等）

3. **创建需求级结构示例**：
   - 选一个真实需求，创建 `specs/001-demo/` 目录结构（需求编号格式：`{num}-{domain-name}`）
   - 创建 `specs/001-demo/index.md`，初始化需求元信息
   - 按元数据规范写 1 份 `specs/001-demo/requirements/prd.md`

4. **完善需求级 Spec Pack**：
   - 为该需求补齐 `design/`（solution.md、API+数据+ADR）与 `verification/`（用例+报告模板）

5. **建立 Merge-back 机制**：
   - 创建 `specs/001-demo/merge_back.md` 清单
   - 需求完成后，执行 Merge-back，将可复用资产晋升到项目层
