---
title: Spec 级需求澄清阶段 SOP（原产品需求与重构需求合并）
status: draft
audience: [PM, BA, UX, DEV, QA]
principles_ref: design/aisdlc.md
---
## 需求澄清流程（Clarify）

### 1. 背景与目标（对齐 `design/aisdlc.md`）

本文档定义 **Spec 级**需求澄清流程：在“双层 SSOT + Spec as Code + 渐进式披露”的前提下，用 **可拆分、可独立优化的 AI 对话模块**，把模糊需求（含功能与重构）推进为可评审、可落盘、可追溯的产物：

- **核心方案（Solution）**：明确“不做什么 / 做什么 / 怎么做 / 怎么验收”，包含功能设计或重构基线。
- **PRD（可选）**：当需要更细粒度的交付规格时生成。
- **原型/Demo（可选）**：当涉及复杂交互时生成。

> 说明：对**简单需求**，完成 R1 后可直接进入 design 阶段（跳过单独的 `prd.md`/`prototype.md`）；但必须在 `solution.md` 补齐“最小可交付规格”（含 AC 与交互结论），避免歧义（见 5.8）。  
> 需求分析阶段的主落盘目录为 `requirements/`；如需下沉架构/契约/ADR，再进入 `design/`（见 2.1）。

---

### 2. 产物落盘与“渐进式披露”的读取顺序

#### 2.1. 推荐落盘结构（需求级 Spec Pack）

对齐 `design/aisdlc.md` 中的需求级目录（示例；需求分析主落盘在 `requirements/`）：

```text
.aisdlc/specs/<DEMAND-ID>/
  index.md
  requirements/
    raw.md                    # 原始输入（工单/访谈/截图/会议纪要摘要）
    solution.md               # 最终方案（澄清结论 + 备选方案 + 推荐方案 + 风险/验证 + 对照证据（可选）+ 迭代记录）
    prd.md                    # PRD（可评审版本）
    prototype.md              # 原型说明（交互内容：任务流/页面结构/节点/AC 映射 + 页面清单、线框、交互细节、状态/校验）
  design/
    architecture.md           # 如涉及架构/契约/ADR，再下沉到 design/
```

#### 2.2. Agent 读取顺序（渐进式披露）

- **必读（项目级，强制）**（读取失败或不存在时，必须显式标注为 `CONTEXT GAP`，不得静默跳过）：
  - `project/memory/product.md`（业务边界与术语）
  - `project/memory/glossary.md`（术语表）
  - `project/products/index.md`（业务模块地图，如存在）
  - `project/components/index.md`（应用组件地图 + 跨模块依赖关系图，如存在；用于 R1.5 影响分析）
- **按需（需求级）**：仅在明确处理某个 `<DEMAND-ID>` 时读取该需求的 `requirements/*`，并尽量只读最小必要内容。
- **回写（入库）**：每个模块独立产出一个文件（或一个章节），保持可替换、可优化、可审计。

#### 2.3. 上下文自动识别机制

对齐 `design/aisdlc_spec_init.md` 的“上下文自动识别机制”：所有 spec 级 Skill 执行前先按标准流程获取当前 spec 的上下文信息。

**公共 Skill：`spec-context`（必须使用）**

在任何 Spec 技能/命令里，只要会读写 `requirements/*.md`，就必须先定位 `{FEATURE_DIR}`。本仓库以**当前 Git 分支名**作为 spec pack 的定位锚点，禁止猜路径。

- **Skill 定义**：`skills/spec-context/SKILL.md`
- **唯一做法（PowerShell）**：

```powershell
. (Join-Path (git rev-parse --show-toplevel) "skills\spec-context\scripts\spec-common.ps1")
$context = Get-SpecContext
$FEATURE_DIR = $context.FEATURE_DIR
Write-Host "FEATURE_DIR=$FEATURE_DIR"
```

- **硬规则（必须遵守）**：
  - **先定位再读写**：任何读/写 `requirements/*.md` 之前，必须先运行 `spec-context` 并回显 `FEATURE_DIR=...`。
  - **失败即停止**：`Get-SpecContext` 报错时，必须立刻停止，不得继续生成/写文件。
  - **路径只从 FEATURE_DIR 构建**：禁止用当前工作目录做相对路径猜测。

> 说明：`spec-context` 的底层实现依赖脚本函数 `Get-SpecContext`（位于 `skills/spec-context/scripts/spec-common.ps1`），其职责是读取当前分支并验证 `{num}-{short-name}` 与 spec pack 目录结构的一致性。

**输出字段**：
- **REPO_ROOT**：Git 仓库根目录路径
- **CURRENT_BRANCH**：当前分支名称（格式：`{num}-{short-name}`）
- **FEATURE_DIR**：当前需求的 Spec Pack 根目录路径（`.aisdlc/specs/{CURRENT_BRANCH}/`）
- **SPEC_NUMBER**：分支编号部分（从分支名称提取）
- **SHORT_NAME**：分支短名称部分（从分支名称提取）

所有模块（R1-R4）的输入文件路径基于 `FEATURE_DIR` 自动构建，例如：
- `requirements/raw.md` → `{FEATURE_DIR}/requirements/raw.md`
- `requirements/solution.md` → `{FEATURE_DIR}/requirements/solution.md`
- `requirements/prd.md` → `{FEATURE_DIR}/requirements/prd.md`
- `requirements/prototype.md` → `{FEATURE_DIR}/requirements/prototype.md`

---

### 3. 分布式流程总览（模块化流水线）

目标：每一步都能单独执行、单独评审、单独替换；同时步骤之间通过明确的输入/输出对齐，避免重复劳动与漂移。

#### 3.1. 模块清单

| 模块 ID | 模块名称 | 主要目标 | 关键输出 |
|---|---|---|---|
| R0 | Spec 初始化（创建工作分支与 Spec Pack） | 建立“需求上下文”（分支+目录）并落盘原始需求，为后续模块提供稳定的输入路径与自动识别能力 | Spec 分支 `{num}-{short-name}` + `.aisdlc/specs/{num}-{short-name}/` + `requirements/raw.md` |
| R1 | Brainstorming：想法 → 最终方案 | 用“一次一问 + 备选方案对比 + 渐进式验证”的对话，把模糊需求稳定落盘为可评审方案 | `requirements/solution.md` |
| R1.5 | 需求影响分析（Impact Analysis） | 基于 `solution.md` 自动从项目知识库提取受影响模块、需遵守的不变量、相关 ADR，为后续 D2/I1 提供约束输入 | `requirements/solution.md#impact-analysis` |
| R2 | 基于方案生成 PRD（可选） | 把决策转为可交付规格（含 AC）；若为简单需求也可由 R1 的 `solution.md` 承载“最小可交付规格”并直达 design | （可选）`requirements/prd.md` |
| R3 | 原型生成（交互 + 线框，可选） | 把 PRD 的场景转为任务流/页面结构/节点编号/AC 映射，并输出可评审的**线框原型**与状态说明 | （可选）`requirements/prototype.md` |
| R4 | 可交互 Demo 生成（可选） | 基于 `prototype.md` 的页面清单与交互说明，在 Demo 项目中为**当前需求**生成独立可运行的交互 Demo（用于走查/验证/对齐） | Demo 工程（共享工程模式，默认 `{REPO_ROOT}/demo/prototypes/{CURRENT_BRANCH}/`） |

#### 3.2. Skill 工作流（每个节点一个 Skill；下一步统一回到 using-aisdlc 路由）

本流程的**操作粒度**是“一个节点 = 一个 Skill = 一个落盘产物”。建议把 Skill 当作“路标”：执行完一个 Skill，就按路由进入下一步。

> 更新：为避免“每个 Skill 各自决定下一步”导致口径分散，本仓库以 `skills/using-aisdlc/SKILL.md` 作为 Spec Pack 流程的**唯一路由器（Router）**。worker Skill（R0/R1/R2/R3/R4）执行完成后，**统一回到 `using-aisdlc` 重新路由下一步**；本文档只保留端到端总览与落盘约定。

**前置硬要求**：R1–R4 只要会读写 `requirements/*.md`，必须先执行 `spec-context`（回显 `FEATURE_DIR=...`）。上下文失败就停止。

**Skill 与模块对照**（Skill 定义文档是实现约束 SSOT；主文档是端到端流程 SSOT）：

| 模块 | 使用的 Skill（Skill 定义文件） | 产物（落盘） | 下一步（由 using-aisdlc 路由） |
|---|---|---|---|
| R0 | `spec-init`（`skills/spec-init/SKILL.md`） | `requirements/raw.md` | 回到 `using-aisdlc` |
| R1 | `spec-product-clarify`（`skills/spec-product-clarify/SKILL.md`） | `requirements/solution.md`（**必须包含** `#impact-analysis`） | 回到 `using-aisdlc` |
| R1.5 | （无独立 Skill；自动步骤） | `requirements/solution.md#impact-analysis`（若 R1 未包含则在此补齐） | 回到 `using-aisdlc` |
| R2 | `spec-product-prd`（`skills/spec-product-prd/SKILL.md`） | （可选）`requirements/prd.md` | 回到 `using-aisdlc` |
| R3 | `spec-product-prototype`（`skills/spec-product-prototype/SKILL.md`） | （可选）`requirements/prototype.md` | 回到 `using-aisdlc` |
| R4 | `spec-product-demo`（`skills/spec-product-demo/SKILL.md`） | Demo 工程 | 回到 `using-aisdlc` |

> 说明：Skill 的规范定义以 `skills/` 下对应 `SKILL.md` 为准；本文档负责端到端总览与落盘约定。

#### 3.3. 最短路径（建议先跑通）

`spec-init` → `spec-product-clarify`（含 `solution.md#impact-analysis`）→（简单需求可直达）design 阶段

或（常规路径）

`spec-init` → `spec-product-clarify`（含 `solution.md#impact-analysis`）→ `spec-product-prd` →（按需）`spec-product-prototype` →（按需）`spec-product-demo` → design 阶段

#### 3.4. 通用门禁与收敛规则（R1–R4）

- **门禁**：凡读写 `requirements/*.md`，先执行 `spec-context` 获取 `FEATURE_DIR`；失败即停止（见 2.3）。
- **写作原则**：结论优先（结论 → 依据 → 验证）；只保留支撑决策/实现/验收的最小信息；关键口径可追溯到 `raw.md/solution.md/prd.md`（或进入验证清单）。
- **收敛规则**：`solution.md`/`prd.md`/`prototype.md` 不出现“待确认问题”；未知以“假设 + 验证清单（Owner/截止/信号/动作）”承接。

---

### 4. 模块 R0：Spec 初始化（创建工作分支与 Spec Pack）

#### 4.1. 目标

把“原始需求输入”快速转为**可追溯、可自动识别上下文**的 Spec 工作空间：通过创建 `{num}-{short-name}` 分支与标准化 Spec Pack 目录，为后续 R1-R4 提供稳定的文件路径与一致的执行上下文。

#### 4.2. 输入与触发

- **输入**：原始需求文本或原始需求文件路径（优先文件路径，以降低中文参数传递的编码风险）。
- **触发时机**：当还没有对应的 spec 分支/目录，或需要开启一个全新的需求 Spec Pack 时执行。

#### 4.3. 输出（概要）

- **分支**：创建并切换到 `{num}-{short-name}`（编号自增，命名规范统一）。
- **目录**：创建 `.aisdlc/specs/{num}-{short-name}/` 及标准子目录（`requirements/`、`design/`、`implementation/`、`verification/`、`release/`）。
- **原始需求落盘**：写入 `requirements/raw.md`（作为后续所有分析与设计的“证据入口”）。

#### 4.4. 与“上下文自动识别”的关系

R0 的核心价值之一是把 **Git 分支**作为需求级上下文标识符：后续模块在执行前通过 `Get-SpecContext` 获取 `FEATURE_DIR`，从而无需额外参数即可定位当前需求的 Spec Pack（详见 `design/aisdlc_spec_init.md`）。

#### 4.5. 关键约束（概要）

- **非破坏性**：不覆盖已存在的分支或目录（除非明确确认）。
- **一致性**：分支名与 Spec 目录名一一对应，保证自动识别可靠。
- **编码统一**：中文内容相关文件以 **UTF-8 with BOM** 写入，减少跨环境乱码风险。

#### 4.6. 执行 Skill（R0）

- **Skill**：`spec-init`（见 `skills/spec-init/SKILL.md`）
- **用户输入**：建议优先传入“原始需求文件路径”（降低中文参数传递的编码风险）；也支持直接粘贴文本
- **完成后检查**：
  - 当前分支已切换为 `{num}-{short-name}`
  - `.aisdlc/specs/{num}-{short-name}/requirements/raw.md` 已生成（**UTF-8 with BOM**）

#### 4.7. 下一步（R0 → R1）

执行 R0 后，立即进入 R1 做 Brainstorming（澄清 + 方案）：

- **下一步**：`spec-product-clarify`（生成 `requirements/solution.md`）

---

### 5. 模块 R1：Brainstorming（澄清 + 方案）

#### 5.1. 目标

把输入的原始需求加工为可执行的澄清结论与可评审方案：**明确要做什么、为什么做、对谁有价值、边界是什么，以及推荐怎么做**。

#### 5.2. 输入

**上下文自动获取**：
- 先执行 `spec-context` 获取 `FEATURE_DIR`（失败即停止；见 2.3/3.4）
- 自动定位 `{FEATURE_DIR}/requirements/raw.md`（尽量保留原始措辞、证据链接/截图）

**项目级资源（强制，对齐上下文注入协议）**：
- `project/memory/product.md`（业务边界与核心术语，**必读**）
- `project/memory/glossary.md`（术语与口径，**必读**）
- `project/products/index.md`（业务模块地图，如存在则**必读**；不存在标注 `CONTEXT GAP`）
- 涉及模块的 TL;DR 摘要（从 `components/index.md` 匹配后按需读取 `components/{module}.md#tldr`）

#### 5.3. 输出（落盘到 `requirements/solution.md`）
`solution.md` 是本流程的**单一决策入口**：用于记录最终结论，支持后续评审与继续对话（可追溯、可验证、可迭代）。

通用写作原则与收敛规则见 3.4。

推荐最小结构（可直接作为模板）：

- **结论摘要（必填，3–7 行）**
  - 一句话目标（要解决什么）
  - 范围 In/Out（一句话即可）
  - 推荐方案：名称 + 1 句话机制概述
  - 需要优先验证的 1–3 个点（引用下方“验证清单”条目编号）
- **推荐方案（必填，1 个）**
  - 主流程/关键机制（只写做法，不写大段背景）
  - 关键边界/取舍（最少 3 条）
  - 为什么选它（1–3 条，必须可追溯到证据或约束）
  - **（重构特有）现状基线（As-Is）**：当前架构/指标/依赖
  - **（重构特有）不变量（Invariants）**：接口契约/数据一致性/关键 NFR
  - **（重构特有）回滚策略**：止损信号与回滚步骤
- **备选方案（必填，2–3 个）**
  - 每个备选：适用前提（何时会选它）+ 不选原因（1–2 条关键差异即可）
- **决策依据（必填，证据入口清单）**
  - 引用 `{FEATURE_DIR}/requirements/raw.md` 的具体段落/记录点位（或链接、数据、约束来源）
  - 若缺少证据：必须在“验证清单”中补齐对应验证项
- **验证清单（必填）**
  - 按条列出：要验证的假设/风险 → 验证方式 → 成功/失败信号 → Owner → 截止时间 → 下一步动作
- **迭代记录（必填）**
  - 仅记录“本轮相对上轮改了什么 + 为什么改”（每轮 3–5 条以内）

#### 5.4. R1 对话流程（澄清 → 方案 → 设计呈现）

R1 常见风险是：信息不足、结论只停留在对话、追问无止境、方案与验收脱节。本流程用“**一次一问 + 备选方案对比 + 渐进式验证 + 增量回写 raw.md**”把结论收敛到可评审文件（通用规则见 3.4）。

- **澄清**：每轮只问 1 题（优先选择题），聚焦目标/约束/成功标准与关键未知。
- **对比**：给出 2–3 个机制差异明显的方案，并给出推荐与理由。
- **呈现**：分段输出（建议 200–300 字/段），段末确认后再继续；不清晰就回到澄清。
- **落盘**：每轮问答把“问题 + 推荐选项 + 用户回答 + 一句话结论（+遗留歧义）”追加到 `raw.md/## 澄清记录`；信息足够后生成 `solution.md`。
- **停止**：DoD 达标 / 用户停止 / 边际收益过低；其余关键未知进入验证清单。

#### 5.5. AI 对话提问脚本（核心 3 问）

1. **目标与价值**：请用一句话复述需求目标，并说明为什么要做（用户目标/业务目标，或重构的痛点/收益）。
2. **用户与场景**：谁遇到问题？在什么情况下遇到？期望如何解决？（重构则问：涉及哪些模块？现状是什么？谁在维护？）
3. **边界与约束**：这次明确做什么？不做什么？有哪些硬约束（合规/权限/时效，或重构的不变量/兼容性要求）？

> **按需扩展**：对于复杂需求，可追加干系人优先级、量化证据、验收标准等问题；对于简单需求，上述 3 问足够。

#### 5.6. 质量门槛（R1-DoD）

- 目标与价值清晰（能回答“为什么做”）
- 用户与场景可复述且不歧义
- In/Out 明确（避免范围漂移）
- 约束已列出（未知也显式写“未知”）
- 有证据/引用入口（raw/glossary 等，如适用）
- 有 2–3 个备选方案与推荐方案（体现权衡）
- 不确定性已收敛：`solution.md` 中**不出现“待确认问题”**，只允许以“验证清单”承接（Owner/信号/动作/截止明确）

#### 5.7. 执行 Skill（R1）

- **Skill**：`spec-product-clarify`（见 `skills/spec-product-clarify/SKILL.md`）
- **门禁（必须先过）**：先执行 `spec-context` 获取 `FEATURE_DIR`（见 3.4），然后读取 `{FEATURE_DIR}/requirements/raw.md`；如信息不足，按 5.4 的节奏澄清到满足 DoD 或触发停止机制，再生成 `solution.md`（避免先生成再补问导致漂移）。
  - 对用户 **一次只问 1 题**
  - 每轮回答后必须把“问题 + 推荐选项 + 用户回答 + 一句话结论 + 遗留歧义（如有）”**增量写回** `raw.md/## 澄清记录`
  - 具备停止机制（DoD 达标 / 用户停止 / 边际收益过低；其余关键未知进入 `solution.md` 的“验证清单”）
- **完成后检查**：
  - `requirements/solution.md` 已生成且满足 R1-DoD
  - 若发生澄清问答：`requirements/raw.md` 中存在可追溯的“澄清记录”

---

### 5.5a. 模块 R1.5：需求影响分析（Impact Analysis，R1 完成后自动执行）

#### 5.5a.1. 目标

基于 `solution.md` 的目标/范围/关键流程，自动从项目知识库提取"受影响模块清单 + 需遵守的不变量 + 相关 ADR + 跨模块影响"，为后续 D2/I1 提供约束输入。这是项目知识库最高 ROI 的消费场景：一次分析，后续全程受益。

#### 5.5a.2. 输入

- `{FEATURE_DIR}/requirements/solution.md`（必须；R1 已完成）

- **项目知识库（必读）**：
  - `project/products/index.md`（匹配受影响的业务模块）
  - `project/components/index.md`（匹配受影响的应用组件 + 跨模块依赖关系图）
  - 匹配到的 `project/components/{module}.md`（提取 TL;DR、API/Data 不变量、状态机/领域事件、Evidence Gaps）
  - `project/adr/index.md`（提取可能约束设计方向的历史决策）

#### 5.5a.3. 输出（写入 `{FEATURE_DIR}/requirements/solution.md#impact-analysis`）

```markdown
## Impact Analysis

### 受影响模块

| 模块 | 影响类型 | 关键不变量 | stale? |
|------|----------|-----------|--------|
| <module> | 新增能力/修改契约/读取数据/... | <从模块页提取的关键不变量> | yes/no |

### 需遵守的不变量（从模块页 API/Data Contract 提取）

- [不变量 1]（来源：`components/<module>.md#api-contract`）
- [不变量 2]（来源：`components/<module>.md#data-contract`）

### 相关 ADR

- [ADR-xxx: <标题>]（来源：`adr/xxx.md`）—— 如何约束本需求的设计

### 跨模块影响（从依赖关系图推导）

- 改了 A → 需关注 B（原因：<调用关系/数据依赖>）

### Context Gaps

- <模块 X 被标记为 stale，建议先执行 Delta Discover>
- <项目级 products/index.md 不存在，业务模块匹配受限>
```

#### 5.5a.4. 门禁（R1.5-DoD）

- 至少匹配到 1 个受影响模块（若无匹配，说明需求可能涉及新模块，需在 `Context Gaps` 中标注）
- 所有 `stale` 模块已标注，并建议是否需要先执行 Delta Discover
- 影响分析已写入 `requirements/solution.md#impact-analysis`，后续 D2/I1 可直接引用

#### 5.5a.5. 下一步（R1.5 → R2 / 或直接进入 design）

影响分析完成后，进入 R2 分流判定（同下方 5.8 节）。

#### 5.8. 下一步（R1 → R1.5 → R2 / 或直接进入 design）

完成 R1 后，进入“是否需要单独 PRD（R2）”的分流：

- **默认**：进入 R2（`spec-product-prd`，生成 `requirements/prd.md`），把方案转为可拆解、可测试的交付规格
- **简单需求可跳过 R2（并同时跳过 R3）**：若满足 5.8.1 → **无需单独 PRD/原型，直接进入 design 阶段**

> design 阶段产物与落盘约定见 `design/aisdlc.md`（`specs/<DEMAND-ID>/design/`）。

#### 5.8.1. R2 跳过判定（“简单需求”口径，满足其一即可）

- **纯规则/配置/文案类变更**：不改变任务流与页面结构；AC 可直接从规则描述推导且易测试
- **变更范围极小且无歧义**：涉及页面/接口很少（通常 1–2 处改动），且不存在信息架构/权限分支/状态分支的权衡
- **可直接验收**：在 `solution.md` 中用少量条目即可把验收口径写清楚（见 5.8.2），研发/测试不会因缺少 PRD 产生理解偏差

#### 5.8.2. 跳过 R2（直达 design）时 `solution.md` 的最小补充要求（Mini-PRD）

当决定跳过 R2 时，必须在 `solution.md` 末尾追加一个“小节”补齐最小可交付规格（避免“只有方案，没有验收”）：

- **MVP 范围**：In/Out（精确到行为/规则）
- **验收标准（AC，必填）**：3–10 条即可，逐条可测试、可验证
- **交互变化结论**：无 / 有但简单（1–3 句说明原因）；若存在新增/变更交互且不够明确，则不应跳过 R2/R3
- **影响面**：涉及哪些页面/入口/接口/权限点（可定位的名称/路径/契约入口）；若涉及契约变更，需在 design 阶段补齐 contracts/ADR

---
### 6. 模块 R2：基于方案生成 PRD（可选）

#### 6.1. 目标

把决策方案转为可交付规格：范围清晰、验收可执行、可拆解为研发任务，并能与后续用例/测试/发布追溯。

> 适用性：当需求不满足 5.8.1 的“简单需求”口径，或团队需要把 AC/范围/里程碑以独立文档形式冻结与评审时，执行 R2；否则可按 5.8.2 在 `solution.md` 补齐 Mini-PRD 后直接进入 design 阶段。

#### 6.2. 输入

**上下文自动获取**：
- 先执行 `spec-context` 获取 `FEATURE_DIR`（失败即停止；见 3.4）
- 自动定位 `{FEATURE_DIR}/requirements/solution.md`（含推荐方案、备选方案、决策依据、验证清单）

**项目级资源**：
- 项目级术语/约束/契约索引（如涉及）

#### 6.3. 输出（落盘到 `requirements/prd.md`）

`prd.md` 用于把 R1 的决策转为**可拆解、可验收、可测试**的交付规格；写作上以“可验证”优先，避免堆背景与讨论过程。

通用写作原则与收敛规则见 3.4。

建议最小结构（可直接作为模板）：

- **结论摘要（必填，3–7 行）**：目标 + In/Out + MVP 边界 + 推荐方案引用（指向 `solution.md`）
- **范围与里程碑（必填）**：MVP 做什么 / 不做什么；迭代方向（1–3 条即可）
- **核心场景与用户故事（必填）**：按场景组织（优先 3 个以内），每个场景给出成功标准
- **功能清单与优先级（必填）**：P0/P1/P2（或 MoSCoW），并与里程碑对齐（MVP 覆盖 P0/Must）
- **业务规则与口径（必填）**：引用 glossary/数据口径；没有来源则进入验证清单
- **验收标准 AC（必填）**：逐条可测试、可验证（建议按场景归类）
- **异常与边界（必填）**：只覆盖会影响 AC 的关键异常（权限/失败/幂等/并发/降级等）
- **风险/依赖与验证清单（必填）**：风险/依赖 → 缓解/验证方式 → 信号 → Owner → 截止 → 下一步动作
- **追溯链接（必填）**：`solution.md`、`raw.md`（证据入口）、后续 `prototype.md`

#### 6.4. 质量门槛（R2-DoD）

- 每个核心场景都有 AC（可直接转测试用例，且具备可执行的验证方式）
- In/Out 与 R1 一致，且与最终方案一致
- 风险与依赖有明确 Owner 与动作，并能落到验证清单
- PRD 的范围/里程碑与功能优先级一致：MVP 至少覆盖 Must/P0，并且 Won't/Out 有明确口径
- 至少覆盖 1 个高优先级干系人的验收口径（能写成可执行的检查项或验收清单）
- 不确定性已收敛：不出现“待确认问题”，只允许以“假设 + 验证清单”承接（Owner/截止/动作明确）

#### 6.5. 执行 Skill（R2）

- **Skill**：`spec-product-prd`（见 `skills/spec-product-prd/SKILL.md`）
- **门禁（必须先过）**：先执行 `spec-context` 获取 `FEATURE_DIR`（见 3.4），且必须存在 `{FEATURE_DIR}/requirements/solution.md`；缺失不得生成 `prd.md`
- **完成后检查**：
  - 每个核心场景都有 AC（可测试、可验证）
  - In/Out 与 R1 一致，且与最终方案一致
  - 功能优先级与里程碑一致（MVP 覆盖 Must/P0）
  - `prd.md` 中不出现“待确认问题”，未知以“假设 + 验证清单”承接

#### 6.6. 下一步（R2 → R3 / 或直接进入 design）

完成 PRD 后，进入“是否需要原型（R3）”的分流：

- **默认**：若存在新增/变更交互，或交互不够明确 → 进入 R3（`spec-product-prototype`，生成 `requirements/prototype.md`）
- **可跳过 R3**：若需求**没有交互变化**，或交互**简单且明确**（见 6.6.1）→ **无需 R3，直接进入 design 阶段**

> design 阶段产物与落盘约定见 `design/aisdlc.md`（`specs/<DEMAND-ID>/design/`）。本流程文档定义到 PRD/（可选）线框原型/（可选）可交互 Demo 为止。

#### 6.6.1. R3 跳过判定（满足其一即可）

- **无交互变化**：完全复用现有页面/流程/交互模式，仅涉及规则、后端能力、数据口径、权限、文案等变化；且 PRD 的 AC 已能无歧义指导实现与测试
- **交互简单且明确**：不新增页面（或新增页面但结构/控件非常明确、无需信息架构权衡），状态与分支很少（常规成功/失败/加载/无权限足够），不需要通过线框来消除理解偏差

#### 6.6.2. 跳过 R3 时的最小补充要求（写在 `prd.md`）

为避免“跳过原型导致交付歧义”，当决定跳过 R3 时，`prd.md` 至少补齐以下信息（可用一个小节承载）：

- **交互变化结论**：无 / 有但简单（用 1–3 句说明原因）
- **页面与入口**：复用哪些现有页面/入口（给出可定位的名称/链接/路径），是否新增页面（若新增且存在信息架构权衡，建议不要跳过 R3）
- **关键控件/字段与校验**：只写会影响 AC 的变更点（含错误提示要点）

---

### 7. 模块 R3：基于 PRD 生成原型（交互 + 线框，可选）

#### 7.1. 目标

把 PRD 的核心场景/规则/AC 加工为可评审的原型资产（交互 + 线框），即使不使用 Figma 也能让研发/测试准确理解任务流、页面结构与状态。

> 适用性：当需求**没有交互变化**或交互**简单且明确**时，可以按 6.6.1/6.6.2 跳过 R3，直接进入 design 阶段；R3 不是强制步骤。

#### 7.2. 输入

**上下文自动获取**：
- 先执行 `spec-context` 获取 `FEATURE_DIR`（失败即停止；见 3.4）
- 自动定位 `{FEATURE_DIR}/requirements/prd.md`（核心场景、规则、AC）

#### 7.3. 输出（落盘到 `requirements/prototype.md`）

`prototype.md` 用于把 PRD 的场景/规则/AC 变成**可走查、可评审、可验证**的交互与 ASCII 线框说明；重点是让研发/测试能据此实现与验收，而不是写“设计过程”。

通用写作原则与收敛规则见 3.4。

推荐最小结构：

- **场景清单（必填）**：与 PRD 对齐（建议 ≤ 3 个核心场景）
- **端到端任务流（必填）**：Mermaid 流程图；节点编号（T-001…）
- **页面/弹窗清单（必填）**：页面编号（P-001…）并标注覆盖哪些任务流节点
- **页面说明（必填，逐页）**
  - 入口与目的
  - 主要信息/控件（字段、按钮、默认值、禁用条件）
  - 关键状态（正常/加载/空/错误/无权限）与提示文案要点
  - 关键校验与错误处理（只写会影响 AC 的部分）
  - 跳转与交互（提交/返回/取消/二次确认）
- **AC → 交互节点映射（必填）**：能回答“哪条 AC 在哪个页面/状态被验证”
- **走查/验证脚本（必填）**
  - 覆盖哪些假设/风险/关键体验点（引用 `solution.md/prd.md` 的验证清单条目）
  - 任务脚本：任务目标 → 成功标准 → 观察点/记录项
  - 回流规则：发现问题回流更新 R1/R2/R3 的触发条件

> 若团队使用 Figma：`prototype.md` 仍建议保留页面清单、状态说明、关键规则，并在顶部附上 Figma 链接作为入口，避免原型与规则漂移。

#### 7.4. 质量门槛（R3-DoD）

- 交互内容与 PRD 的场景/规则/AC 一一对应
- 任务流、节点清单与页面清单一致（可追溯、可定位）
- 每个页面至少包含：入口、主要控件、状态、跳转
- 与 PRD 的 AC 可追溯（能指出“哪个页面/哪个状态支持哪条 AC”）
- 至少包含一份“走查/验证脚本”（含任务脚本与回流指引），确保原型验证能形成闭环而非一次性产物

#### 7.5. 执行 Skill（R3）

- **Skill**：`spec-product-prototype`（见 `skills/spec-product-prototype/SKILL.md`）
- **门禁（必须先过）**：先执行 `spec-context` 获取 `FEATURE_DIR`（见 3.4），且必须存在 `{FEATURE_DIR}/requirements/prd.md`；缺失不得生成 `prototype.md`
- **完成后检查**：
  - `prototype.md` 中不出现“待确认问题”，未知以“假设 + 验证清单”承接，并在走查脚本中体现

#### 7.6. 下一步（R3 → 评审验证 → 回流闭环）

R3 结束不是终点，建议立刻做一次最小评审闭环：

- **下一步（评审/验证）**：基于 `prototype.md` 组织原型评审与最小可用性验证
- **可选下一步（需要更高保真验证时）**：进入 R4，基于 `prototype.md` 生成可交互 Demo 工程并运行走查
- **发现问题如何回流**（按影响优先）：
  - 口径/边界/场景/方案变化 → 回流 R1（`solution.md`）
  - AC 不可验收/范围冲突 → 回流 R2（`prd.md`）
  - 线框页面结构/内容缺失 → 回流 R3（`prototype.md`）
---

### 8. 模块 R4：基于 prototype.md 生成可交互 Demo（可选）

#### 8.1. 目标

把 `prototype.md` 的页面清单/交互说明落地为**可运行、可交互**的 Demo 工程，用于更高保真的走查与验证（可用性验证、干系人对齐、研发/测试理解一致性校验）。R4 的核心价值是“把线框变成可点可跑”，而不是替代设计稿。

#### 8.2. 输入

**上下文自动获取**：

- 先执行 `spec-context` 获取 `FEATURE_DIR`（失败即停止；见 3.4）
- 自动定位 `{FEATURE_DIR}/requirements/prototype.md`

**可选输入**：

- Demo 项目根目录 `DEMO_PROJECT_ROOT`：需要覆盖默认位置时传入；不传则默认采用共享工程模式，并按 8.4 使用 `{REPO_ROOT}/demo/`

#### 8.3. 产出（工程侧）

Demo 工程（共享工程模式；每个需求一个独立目录）：

- `{REPO_ROOT}/demo/prototypes/{CURRENT_BRANCH}/`（在共享工程内为当前需求创建独立命名空间/目录）

#### 8.4. Demo 项目根目录定位规则（必须遵守）

1. **优先使用输入**：若用户显式提供 `DEMO_PROJECT_ROOT`，则以其为准（必须是可运行的 Demo 工程根目录，例如存在 `package.json` 且包含可启动脚本）。
2. **未提供则自动查找**（从高到低优先级）：
   - `{REPO_ROOT}/demo/`（共享工程模式默认位置）
   - `{REPO_ROOT}/prototype/` 或 `{REPO_ROOT}/prototypes/`
   - `{REPO_ROOT}/apps/demo/`、`{REPO_ROOT}/packages/demo/`
3. **查找失败就停止**：若以上路径均不存在或不满足“可运行工程根目录”的判定，则必须停止 R4，并要求用户提供 `DEMO_PROJECT_ROOT`（禁止猜测或在未知位置初始化大型工程，以免污染仓库）。

#### 8.5. 由 `prototype.md` 页面清单生成“待执行任务”的规则（不落盘）

R4 必须以 `prototype.md/页面/弹窗清单（P-001…）` 作为唯一页面来源（禁止自创页面）。任务拆分建议遵循：

- **先搭骨架再补细节**：先把所有页面/弹窗的路由、导航入口与跳转链路跑通；再按优先级补齐字段、校验、状态与错误处理。
- **一页一任务（可再细分）**：每个 `P-xxx` 至少生成 1 个任务条目，包含：
  - 页面路由/入口、页面目标
  - 主要控件/字段与默认值
  - 关键状态（正常/加载/空/错误/无权限）与提示文案要点
  - 与任务流节点（T-xxx）及 AC 的映射（引用 `prototype.md` 中对应章节）
- **数据依赖可用 Mock 承接**：若后端/数据口径未就绪，以 Mock 数据/Mock API 先让交互可跑；但必须在任务清单中标注“真实数据接入”作为后续替换点（避免把 Mock 当最终实现）。

#### 8.6. 执行 Skill（R4）

- **Skill**：`spec-product-demo`（见 `skills/spec-product-demo/SKILL.md`）
- **门禁（必须先过）**：先执行 `spec-context` 获取 `FEATURE_DIR`（见 3.4），且必须存在 `{FEATURE_DIR}/requirements/prototype.md`；缺失不得执行 R4
- **完成后检查**：
  - Demo 工程可启动、可导航、关键链路可走通（至少覆盖 `prototype.md` 的核心任务流）

#### 8.7. 下一步（R4 → 运行走查 → 回流闭环）

- **下一步（验证）**：运行可交互 Demo，按 `prototype.md` 的“走查/验证脚本”执行并记录问题
- **发现问题如何回流**：
  - 口径/边界/场景/方案变化 → 回流 R1（`solution.md`）
  - AC 不可验收/范围冲突 → 回流 R2（`prd.md`）
  - 线框与交互说明缺失/矛盾 → 回流 R3（`prototype.md`）
  - Demo 实现偏差/缺页 → 回流 R4（Demo 工程）

---

### 9. 端到端“最小可用”的执行方式（建议）

为了让流程可分布、可迭代，建议采用下面节奏：

- **先做 R1**：产出可评审的 `solution.md`（含 2–3 个备选、推荐决策与验证清单）
- **R2（可选）产 PRD**：若需求不够简单/需要冻结交付规格，则先产 MVP 版本 PRD（可评审），再迭代补齐细节；若为简单需求，可在 `solution.md` 补齐 5.8.2 的 Mini-PRD 后直接进入 design 阶段
- **R3（可选）**：仅在需要消除交互歧义/涉及新增或变更交互时，围绕核心场景先出关键链路交互与线框原型；有重大问题则回流更新 R1/R2/R3，再继续扩展边缘场景；若无交互变化/交互简单明确则可跳过，直接进入 design 阶段
- **R4（可选）**：当需要更高保真验证时，基于 `prototype.md` 的页面清单生成可交互 Demo 工程；验证中发现问题按 8.7 回流闭环

---

### 10. 附：每个模块的“可优化点”（便于后续迭代）
- **R1**：问题库模板化（按业务域复用）、把指标/证据采集变成清单
- **R1（方案）**：方案评分维度标准化（项目级），引入风险登记表与验证闭环
- **R2**：PRD 自动校验（AC 是否可测、In/Out 是否冲突、术语是否一致）
- **R3**：交互状态与文案规范沉淀为项目级 `UX contract`（如适用）
- **R4**：从 `prototype.md` 生成可执行任务树（含依赖关系与最小可跑定义），并对 Demo 工程做自动回归（关键链路冒烟）