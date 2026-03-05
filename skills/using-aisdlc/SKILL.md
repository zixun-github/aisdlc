---
name: using-aisdlc
description: Use when 需要在 sdlc-dev 仓库执行 AI SDLC（Spec Pack）流程、选择/串联需求侧（raw/solution/prd/prototype/demo）与实现侧（plan/execute/finishing）技能，并用门禁避免上下文漂移、写错目录或在压力下跳过关键步骤。
---

# using-aisdlc（Spec Pack 流程唯一路由器 / Router）

## 你现在在用什么

这是一个“导航 + 门禁”型技能：在 Spec Pack（分支名 `{num}-{short-name}`）流程里，**只有本技能（Router）有权决定下一步用哪个 skill**；其它技能都是 worker，只负责本阶段门禁 + 落盘 + DoD。

**开始时必须宣布：**「我正在使用 using-aisdlc 技能导航 Spec Pack 流程，正在执行 spec-context 获取上下文。」

## 渐进式展开（按需读取）

你要求的机制是“先读 Router，再按需读细则”，因此：

- 默认只读取本文件 `SKILL.md`
- 只有当 Router 需要判定某条链路时，才再读取对应链路的路由细则（R/D/I/V）

## 路由规则索引（按需阅读）

- **需求链路（R0–R4）**：`router/routing-requirements.md`
- **设计链路（D0–D2）**：`router/routing-design.md`（**R→I 过渡时必读**，见 D0 强制门禁）
- **实现链路（I1–I2 + Finish）**：`router/routing-implementation.md`
- **验证链路（V1–V4）**：`router/routing-verification.md`
 
> 路径约定：本技能内部路径均采用**相对于本技能目录**的写法。

## Router / Worker 职责边界（强约束）

- **Router（using-aisdlc）**：唯一有权决定“下一步做什么/是否跳过/走哪条链路”。
- **Worker skills**（例如 `spec-product-clarify`、`spec-plan` 等）：只负责本阶段门禁 + 产物落盘 + DoD 自检；不得在技能内部自主分流到下一个技能。

## Router 的硬门禁（必须遵守）

只要任务会读写以下路径（或其子路径），必须先执行 `spec-context` 获取上下文，并回显 `FEATURE_DIR=...`。**失败则进入 spec-init**。

**REQUIRED SUB-SKILL：正在执行 `spec-context` 获取上下文，并在对话中回显 `FEATURE_DIR=...`（允许 `(reuse)`）。**

- `{FEATURE_DIR}/requirements/*`
- `{FEATURE_DIR}/design/*`
- `{FEATURE_DIR}/implementation/*`
- `{FEATURE_DIR}/verification/*`

> 命令书写约定：默认面向 PowerShell；同一行多命令请用 `;` 分隔（不要用 `&&`）。

## Auto-Advance（默认自动推进）

- **默认**：未命中“硬中断（Hard stop）”时，Router 应自动推进并立即执行下一步 worker skill。
- **禁止**：输出下一步后以“是否继续/要不要执行”结束回复（除非触发硬中断）。
- **需要最小输入时**：先收集最小输入，收集到后立即执行。

## 硬中断（Hard stop：必须停下交给用户）

满足其一即硬中断（Router 必须停止并输出阻断原因 + 所需最小输入/裁决点）：

- 需要关键外部输入且无法默认推断（例如 R4 找不到 `DEMO_PROJECT_ROOT`）
- 存在重大决策分支且选错代价高（例如：对外契约/权限/口径变更、数据迁移/回滚、引入新基础设施或跨团队依赖）
- 预计实现工作量超过 1 个工作日（以影响面与不确定性为依据给出理由即可）
- 涉及不可逆/高风险操作（例如：废弃 Spec Pack，必须走专用流程）

## 软检查点（Soft checkpoint：不中断，但必须提示“可评审点”）

当生成/更新下列权威输入类产物时，Router 应继续推进，同时在输出里给出“本轮最小评审点”：

- `requirements/solution.md`（尤其 `#impact-analysis`）
- `requirements/prd.md`
- `requirements/prototype.md`
- `design/design.md`
- `implementation/plan.md`

## 候选下一步（仅在硬中断时输出）

当 Router 因硬中断停止时，必须追加“可能的下一步（候选）”并按推荐顺序列 2–5 个技能名称。

**约束（避免误导）**：

- 一旦已进入实现链路（已产出 `{FEATURE_DIR}/implementation/plan.md`），候选列表默认只允许包含 `spec-execute`（以及完成后的 `finishing-development`）。不得把 `R2/R3/R4` 或 `I1` 列为“后续可选步骤”。
- 对澄清缺口，应输出“阻断原因 + 需要的最小输入/回写点（plan.md）”，收集到后直接进入 I2。

## Router 输出协议（worker 必须遵守）

任一 worker skill 完成后，结尾必须输出 `ROUTER_SUMMARY`（建议 YAML 形态，字段固定，避免自由文本），用于 Router 自动路由：

```yaml
ROUTER_SUMMARY:
  stage: CTX | R1 | R2 | R3 | R4 | D1 | D2 | I1 | I2 | V1 | V2 | V3 | V4 | Finish
  artifacts:
    - <path>
  needs_human_review: true|false
  blocked: true|false
  block_reason: ""
  notes: ""
```

## 最小路由算法（不展开细则）

Router 每轮按以下顺序执行（细则按需读取对应 routing 文件）：

1. **入口预检（Preflight）**：若分支不合规或 `raw.md` 缺失 → 进入 R0 `spec-init`（细则见 `routing-requirements.md`）。
2. **门禁**：若下一步会读写 `{FEATURE_DIR}/...` 或写 demo → 先执行 `spec-context` 获取上下文，回显 `FEATURE_DIR=...`，**失败则进入 spec-init**。
3. **读取上一步 `ROUTER_SUMMARY`（如有）**：若 `blocked=true` → 按本文件的硬中断规则停下并给出候选下一步。
4. **D0 强制门禁（R→I 过渡）**：当 `solution.md` 已存在且下一步意图指向 I1 时，**必须**执行以下步骤，**禁止未经 D0 直接进入 I1**：
   - 必须读取 `routing-design.md`
   - 必须执行 D0 判定
   - 根据 D0 结果决定：进入 D1/D2，或“跳过 design 并进入 I1”
   - **禁止**：以“用户要最短闭环/跑通即用”为由跳过 D0；D0 判定必须执行，其“跳过 design”结论才是合法进入 I1 的依据。
5. **基于用户意图 + SSOT 文件存在性路由（按需进行读取）**：
   - 需求链路 R：见 `routing-requirements.md`
   - 设计链路 D：见 `routing-design.md`
   - 实现链路 I：见 `routing-implementation.md`
   - 验证链路 V：见 `routing-verification.md`
6. **Auto-Advance**：未命中硬中断则 Router 必须自动推进并立即执行下一步 worker。

## 最短闭环（仅作为入口提示）

当用户意图是“跑通最短开发闭环”时，Router 的默认路径是：

`spec-init（如需） → spec-context → spec-product-clarify → spec-plan → spec-execute → finishing-development`

> 细则与分流（是否补 PRD/原型/是否跳过 design）全部下沉到 routing 文件；其中 **R→I 过渡必须经 D0 强制门禁**（读取 `routing-design.md` 并执行 D0 判定），不得省略。

## 常见错误（Red Flags）

- **R→I 过渡时未经 D0 直接进入 I1**：`solution.md` 已存在且意图指向 I1 时，必须先读取 `routing-design.md`、执行 D0 判定，再根据结果路由。
- **以“最短闭环/跑通即用”为由跳过 D0**：D0 判定必须执行；只有 D0 的“跳过 design”结论才是合法进入 I1 的依据。

