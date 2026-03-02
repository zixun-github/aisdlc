---
title: Spec 级测试验证阶段 SOP（verification：plan / usecase / suites / report）
status: draft
audience: [PM, BA, DEV, QA]
principles_ref: design/aisdlc.md
---

## 测试验证阶段流程（Verification）

### 1. 背景与目标（对齐 `design/aisdlc.md`）

本文档定义 **Spec Pack（需求级 SSOT）** 的测试验证（verification）阶段 SOP：在“双层 SSOT + Spec as Code + 渐进式披露”的前提下，把“验收口径”转成 **可执行、可追溯、可复用** 的验证资产，并产出结论性测试报告，回答：

- **是否满足验收口径（AC）？**
- **是否具备交付条件（通过 / 不通过 / 有条件通过）？**
- **若不通过，阻断点是什么、风险是什么、下一步动作是什么？**

> 重要边界：
>
> - **“本次需求的执行计划”属于 implementation 阶段（I1）**：`{FEATURE_DIR}/implementation/plan.md`（见 `design/aisdlc_spec_implementation.md`）。
> - 本文档的 verification 阶段只定义 **验证侧的产物与门禁**（文档产物为主），不要求在本阶段实现自动化测试代码。
> - 但 `usecase` 必须为后续生成自动化脚本做好结构化准备（见 5.2）。

---

### 2. 产物落盘与“渐进式披露”的读取顺序

#### 2.1 推荐落盘结构（需求级 Spec Pack）

对齐 `design/aisdlc.md` 的阶段定义，并结合本仓库“一个节点 = 一个产物”的粒度，verification 阶段推荐落盘如下（以 `spec-context` 解析得到的 `{FEATURE_DIR}` 为根）：

```text
.aisdlc/specs/<DEMAND-ID>/
  verification/
    test-plan.md              # V1：测试计划（范围/策略/环境/门禁）
    usecase.md                # V2：测试用例（手工为主；结构可生成自动化脚本）
    suites.md                 # V3：测试套件（Suites：冒烟/回归/定向回归）
    report-{date}-{version}.md # V4：测试报告输出物（执行结果的结论 + 覆盖 + 风险 + 缺陷清单引用）
```

说明：

- `design/aisdlc.md` 中将该产物记为 `verification/plan.md`。本 SOP 采用 `test-plan.md` 作为文件名，避免与 implementation 阶段的 `{FEATURE_DIR}/implementation/plan.md` 混淆；如团队已统一使用 `plan.md`，可保持原命名，但本文档其余口径不变。
- `usecase.md` 如需更强可维护性，可扩展为 `usecases/*.md`（但默认单文件，先跑通最小闭环）。
- **不新增** `verification/bugs/**` 目录。缺陷应由团队既有缺陷系统/Issue/工单承载；在 `report.md` 中用“缺陷清单（编号/链接）”引用即可（见 5.4）。

#### 2.2 Agent 读取顺序（渐进式披露）

- **必读（项目级，强制）**（读取失败或不存在时，必须显式标注 `CONTEXT GAP`，不得静默跳过）：
  - `project/memory/product.md`（业务语义与边界）
  - `project/memory/tech.md`（质量门禁、环境/测试约束、安全等）
  - `project/memory/glossary.md`（术语与口径）
- **按需（需求级，最小必要）**：
  - `{FEATURE_DIR}/requirements/solution.md`（或 `{FEATURE_DIR}/requirements/prd.md`）：验收口径与范围来源（至少其一必须存在）
  - `{FEATURE_DIR}/requirements/solution.md#impact-analysis`：用于识别影响面与回归范围（如存在）
  - `{FEATURE_DIR}/design/*`：当存在对外承诺/契约/关键不变量时，用于校验“验证口径是否覆盖关键不变量”
  - `{FEATURE_DIR}/implementation/plan.md`：仅用于提取“最小验证方式/风险/验证清单”，不将其当作 verification 的 SSOT

#### 2.3 上下文自动识别机制（门禁）

对齐 `design/aisdlc_spec_product.md` 的硬规则：**凡读写 `verification/*`，必须先执行 `spec-context` 获取 `FEATURE_DIR`**。

- **先定位再读写**：任何读/写 `{FEATURE_DIR}/verification/*.md` 之前，必须先运行 `spec-context` 并回显 `FEATURE_DIR=...`。
- **失败即停止**：`Get-SpecContext` 报错时必须停止，不得继续生成/写文件。
- **路径只从 FEATURE_DIR 构建**：禁止猜路径或使用当前工作目录推断。

---

### 3. 分布式流程总览（模块化流水线）

目标：每一步可单独执行、单独评审、单独替换；步骤之间通过明确的输入/输出对齐，避免漂移。

#### 3.1 模块清单

| 模块 ID | 模块名称 | 主要目标 | 关键输出（落盘） |
|---|---|---|---|
| V1 | 测试计划（Test Plan） | 明确验证目标/范围/策略/环境/准入准出标准 | `{FEATURE_DIR}/verification/test-plan.md` |
| V2 | 测试用例（Usecases） | 把 AC 转成可执行步骤与预期；结构支持后续自动化生成 | `{FEATURE_DIR}/verification/usecase.md` |
| V3 | 测试套件（Suites） | 将用例组织成“可执行集合”（冒烟/回归/定向回归）并定义执行顺序/依赖 | `{FEATURE_DIR}/verification/suites.md`（或用例内套件段落） |
| V4 | 测试执行与报告输出物（Execute + Report） | 执行验证并产出报告输出物：结论、覆盖、风险与缺陷引用 | `{FEATURE_DIR}/verification/report-{date}-{version}.md` |

#### 3.2 最短路径（建议先跑通）

`V1 测试计划 → V2 测试用例 → V4 测试报告`

说明：

- 对简单需求，V3 可并入 V2（在 `usecase.md` 中直接维护“套件定义”小节）。
- 对影响面明确且需控风险的需求，建议补齐 V3（回归范围/冒烟阻断更清晰）。

#### 3.3 通用门禁与收敛规则（V1–V4）

- **门禁**：凡读写 `verification/*`，先执行 `spec-context` 获取 `FEATURE_DIR`；失败即停止（见 2.3）。
- **收敛规则**：verification 产物中不出现“待确认问题清单”。未知统一进入：
  - V1 的“风险与验证清单”（Owner/截止/信号/动作）
  - 或 V4 的“遗留风险/阻断项”（明确对交付的影响与下一步动作）
- **追溯要求**：每个产物必须可追溯到 AC（`solution.md/prd.md`）与影响面（如有 `#impact-analysis`）。

---

### 4. 技能设计（主技能 `spec-test` + 子技能 `spec-test-*`）

本阶段采用“主技能入口 + 子技能分解”的命名约束：

- **主技能**：`spec-test`
- **子技能**（建议最小集合）：
  - `spec-test-plan` → 生成/更新 `verification/test-plan.md`
  - `spec-test-usecase` → 生成/更新 `verification/usecase.md`
  - `spec-test-suites` → 生成/更新 `verification/suites.md`
  - `spec-test-execute` → 执行验证并产出 `verification/report-{date}-{version}.md`

路由权威对齐 `design/aisdlc.md`：

- “下一步做什么/是否跳过/走哪条链路”的决策 **只由** `using-aisdlc` 作为 Router 做出。
- `spec-test` / `spec-test-*` 是 **worker skill**：只负责门禁 + 产物落盘 + DoD 自检；完成后统一回到 `using-aisdlc` 路由下一步。

#### 4.0 模块与子技能对照（建议）

| 模块 | 使用的子技能 | 产物（落盘） | 下一步（由 using-aisdlc 路由） |
|---|---|---|---|
| V1 | `spec-test-plan` | `{FEATURE_DIR}/verification/test-plan.md` | 回到 `using-aisdlc` |
| V2 | `spec-test-usecase` | `{FEATURE_DIR}/verification/usecase.md` | 回到 `using-aisdlc` |
| V3 | `spec-test-suites` | `{FEATURE_DIR}/verification/suites.md` | 回到 `using-aisdlc` |
| V4 | `spec-test-execute` | `{FEATURE_DIR}/verification/report-{date}-{version}.md` | 回到 `using-aisdlc` |

> 建议输出约定：任一 `spec-test-*` 完成后，结尾输出 `ROUTER_SUMMARY`（参考 `skills/using-aisdlc/SKILL.md` 的约定），便于 Router 自动推进，但子技能本身不得在内部决定“下一步路由”。

#### 4.1 与 `qa-test-planner` 的关系（仅基线）

本仓库不会直接把 `qa-test-planner` 作为 `spec-test` 的组成部分。verification 阶段只在设计上**借鉴其交付物结构、校验清单与反模式**，后续可选择：

- **复用**：将其结构迁移/裁剪为 `spec-test-*` 的实现；
- **重写**：按本仓库门禁、路径与追溯要求重新实现。

无论复用或重写，均以本 SOP（本文档）作为“verification 阶段产物/门禁/DoD”的权威口径。

---

### 5. 模块细化（输入 / 输出 / DoD）

> 统一输入前置：任何模块开始前必须通过 `spec-context` 获取 `FEATURE_DIR`。

#### 5.1 V1：测试计划（`verification/test-plan.md`）

**目标**：冻结本次验证的“范围、策略、环境、准入/准出标准、风险与优先级”，为用例与套件提供边界与门槛。

**输入（最小）**：

- `{FEATURE_DIR}/requirements/solution.md` 或 `{FEATURE_DIR}/requirements/prd.md`（至少其一）
- `{FEATURE_DIR}/requirements/solution.md#impact-analysis`（如存在：用于界定回归范围）

**输出（落盘）**：`{FEATURE_DIR}/verification/test-plan.md`

**建议最小结构（模板骨架）**：

- 执行摘要（待测能力/版本/目标/关键风险）
- 测试范围（In/Out）
- 测试策略（类型：功能/UI/集成/回归/安全等；方法：正向/反向/边界）
- 环境与数据（操作系统/浏览器/后端环境/测试账号/数据准备）
- 准入标准（例如：需求与验收口径已冻结、环境可用、关键依赖可用）
- 准出标准（例如：P0 用例全通过、无阻断缺陷、回归套件通过）
- 风险与验证清单（Owner/截止/信号/动作）
- 追溯链接（solution/prd、impact-analysis、实现验证点引用）

**质量门槛（V1-DoD）**：

- 范围与 `requirements/*` 一致（In/Out 明确）
- 有准入/准出标准，且具备“阻断交付”的明确口径
- 风险已识别且有最小验证动作（不悬空）
- 明确后续用例/套件应覆盖的“关键路径”与“影响面”

---

#### 5.2 V2：测试用例（`verification/usecase.md`）

**目标**：把 AC 转成可执行步骤与预期结果；用例结构必须可被机器提取，以支持后续生成自动化脚本（不绑定框架）。

**输入（最小）**：

- `{FEATURE_DIR}/requirements/solution.md` 或 `{FEATURE_DIR}/requirements/prd.md`（至少其一，作为 AC 来源）
- `{FEATURE_DIR}/verification/test-plan.md`（用于约束范围/环境/优先级）

**输出（落盘）**：`{FEATURE_DIR}/verification/usecase.md`

**用例结构要求（自动化友好，强制）**：

- **稳定编号**：`TC-<DOMAIN>-<NNN>`（例如 `TC-AUTH-001`）；编号一旦发布给协作方，不随意改动
- **类型与标签**：`type`（UI/API/集成/回归）+ `tags`（影响面/模块/风险）
- **前置条件**：可执行、可准备（含账号/权限/环境/开关）
- **测试数据**：给出示例值或生成方式（避免“自行准备”）
- **步骤**：逐步编号；**每步必须包含预期结果**（可观测信号/断言点）
- **后置条件/清理**：如会污染数据或影响后续用例，必须明确清理动作
- **追溯**：至少链接到 1 条 AC（来自 `solution/prd`），并标注覆盖套件（smoke/regression 等）

**建议最小模板**（单条用例）：

```markdown
## TC-XXX-001: [标题]

**优先级：** P0 | P1 | P2
**类型：** UI | API | 集成 | 回归
**标签：** [tag1, tag2]
**追溯：** AC-001（`requirements/prd.md#...`）
**套件：** smoke, regression

### 目标
[一句话说明验证什么]

### 前置条件
- ...

### 测试数据
- ...

### 测试步骤
1. ...
   **预期：** ...
2. ...
   **预期：** ...

### 后置条件/清理
- ...
```

**质量门槛（V2-DoD）**：

- 每个 P0/P1 用例均可执行（前置条件与数据不缺失）
- 每步都有预期结果（可观测、可判定）
- AC 覆盖关系明确（至少能回答“哪些 AC 被哪些用例覆盖”）
- 用例结构满足“后续自动化生成”的最小信息要求（编号/类型/步骤/断言点）

---

#### 5.3 V3：测试套件（Suites：`verification/suites.md`）

**目标**：将 V2 的用例组织成“可执行集合”，并定义执行顺序/依赖，形成验证侧的最小执行编排入口。

**输入（最小）**：

- `{FEATURE_DIR}/verification/usecase.md`
- `{FEATURE_DIR}/verification/test-plan.md`
- `{FEATURE_DIR}/requirements/solution.md#impact-analysis`（如存在：用来界定“定向回归”范围）

**输出（落盘）**：`{FEATURE_DIR}/verification/suites.md`（或在 `usecase.md` 内维护“套件定义”段落）

**建议最小结构**：

- 冒烟套件（smoke）：阻断发布的关键路径（定义预计执行时长与阻断规则）
- 回归套件（regression）：覆盖主要功能与高风险路径（可按模块/影响面拆分）
- 定向回归（targeted）：基于 impact-analysis 的受影响模块与风险清单生成（明确触发条件）
- 执行顺序与依赖：例如先 smoke，再 targeted，再 regression

**质量门槛（V3-DoD）**：

- 套件中的每个条目都能定位到具体用例编号（避免模糊描述）
- smoke 套件具备明确的“阻断交付”口径（与 V1 的准出标准一致）
- targeted 套件与 impact-analysis/风险清单可追溯（如存在）

---

#### 5.4 V4：测试执行与报告输出物（`verification/report-{date}-{version}.md`）

**目标**：产出结论性报告：覆盖、结果、风险与缺陷清单引用，并给出是否可交付建议。

**输入（最小）**：

- `{FEATURE_DIR}/verification/test-plan.md`
- `{FEATURE_DIR}/verification/usecase.md`
- `{FEATURE_DIR}/verification/suites.md`（如存在）

**输出（落盘）**：`{FEATURE_DIR}/verification/report-{date}-{version}.md`

**命名规则（强制）**：

- `date`：`YYYY-MM-DD`
- `version`：构建/发布版本号或可追溯标识（例如版本号、build id、git sha）
- 若版本未知：使用 `report-{date}-unknown.md`，并在报告中写明 `CONTEXT GAP: version/build unknown`

**建议最小结构**：

- 测试摘要（结论：通过/不通过/有条件通过；版本/构建/环境）
- 覆盖统计（按套件/优先级：总数、执行数、通过、失败、阻塞）
- 关键失败与阻断项（必须可追溯到用例编号）
- 缺陷清单（仅引用：缺陷系统/Issue 编号 + 链接 + 状态 + 严重程度；不在 Spec Pack 内落盘 BUG 文件）
- 遗留风险与建议（是否可交付、是否需要返工、是否需要补测）
- 追溯链接（requirements/design/implementation/关键变更）

**质量门槛（V4-DoD）**：

- 报告给出明确结论（不是“已测完”）
- 所有失败/阻断项均可定位到用例编号与外部缺陷编号
- 风险与建议可执行（下一步动作明确）

---

### 6. 追溯与归档（Merge-back 提示）

- verification 产物的追溯入口必须稳定可查：`test-plan.md` 与 `report.md` 必须回链到 `requirements/solution.md`/`prd.md` 的 AC。
- 当某些“套件划分规则/质量门禁口径”被多个需求反复复用时，建议在需求完成后的 Merge-back 阶段将其晋升为项目级资产（例如质量门禁、通用回归套件策略等），避免长期散落在单个 Spec Pack 中。

