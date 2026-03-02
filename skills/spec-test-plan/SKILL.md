---
name: spec-test-plan
description: Use when 需要在 Spec Pack 的 verification 阶段生成或更新 `{FEATURE_DIR}/verification/test-plan.md`（测试计划），并要求严格门禁与可追溯。
---

# Spec 测试计划（V1：Test Plan）

为当前 Spec Pack 生成/更新测试计划：冻结 **范围、策略、环境、准入/准出标准、风险与验证清单**，并与 `requirements/*` 的验收口径保持可追溯一致。

**权威口径：** `design/aisdlc_spec_verification.md`

---

## 硬门禁（必须遵守）

- **先定位再读写**：必须先运行 `spec-context` 得到并回显 `FEATURE_DIR=...`；失败即停止，禁止猜路径。
- **必读项目级 memory**：`project/memory/product.md`、`project/memory/tech.md`、`project/memory/glossary.md`；读不到必须写 `CONTEXT GAP`。
- **需求级最小输入**：`{FEATURE_DIR}/requirements/solution.md` 或 `{FEATURE_DIR}/requirements/prd.md` **至少其一必须存在**；否则停止并写 `CONTEXT GAP`。
- **禁止越权路由**：完成后只输出 `ROUTER_SUMMARY`，下一步由 `using-aisdlc` 决策。

---

## 红旗清单（出现任一条就停止）

- 没有回显 `FEATURE_DIR=...` 就准备写文件
- 想把文件先写到 `./verification/` 或任何非 `{FEATURE_DIR}` 的路径
- 想用 `TBD/待补` 代替“范围来源/准出标准/风险动作/追溯链接”

---

## 唯一做法（PowerShell）

### 1) 获取 `FEATURE_DIR`

```powershell
. ".\skills\spec-context\scripts\spec-common.ps1"
$context = Get-SpecContext
$FEATURE_DIR = $context.FEATURE_DIR
Write-Host "FEATURE_DIR=$FEATURE_DIR"
```

### 2) 校验最小输入存在

```powershell
$solution = Join-Path $FEATURE_DIR "requirements/solution.md"
$prd = Join-Path $FEATURE_DIR "requirements/prd.md"
if (-not (Test-Path $solution) -and -not (Test-Path $prd)) {
  throw "CONTEXT GAP: missing requirements/solution.md and requirements/prd.md"
}
```

### 3) 目标输出路径

```powershell
$out = Join-Path $FEATURE_DIR "verification/test-plan.md"
Write-Host "OUTPUT=$out"
```

---

## 输出物模板（最小骨架）

写入 `{FEATURE_DIR}/verification/test-plan.md`，至少包含：

- 执行摘要（待测能力/版本/目标/关键风险）
- 测试范围（In/Out）
- 测试策略（类型：功能/UI/集成/回归/安全…；方法：正向/反向/边界）
- 环境与数据（环境、账号/权限、数据准备方式）
- 准入标准（Entry Criteria）
- 准出标准（Exit Criteria，必须含“阻断交付”的口径）
- 风险与验证清单（Owner/截止/信号/动作）
- 追溯链接（指向 `solution/prd` 的 AC/范围来源；如有 `#impact-analysis` 也要链接）

---

## DoD 自检（V1-DoD）

- [ ] 范围 In/Out 明确，且与 `requirements/*` 一致
- [ ] 有准入/准出标准，并能明确“什么情况下阻断交付”
- [ ] 风险不是清单摆设：每条风险都有最小验证动作（Owner/信号/动作）
- [ ] 有追溯入口：至少能回答“本计划依据哪份 AC/范围定义”

---

## 输出约定（交还 Router）

```text
ROUTER_SUMMARY
- feature_dir: <FEATURE_DIR>
- outputs:
  - verification/test-plan.md
- context_gaps:
  - <CONTEXT GAP...> (if any)
- dod:
  - pass: <yes/no> (and why)
  - next_risks: <short list>
```

---
name: spec-test-plan
description: Use when 需要在 sdlc-dev 的 Spec Pack 中生成/更新 verification 阶段 V1 测试计划（verification/test-plan.md），并且必须遵守 spec-context 的 FEATURE_DIR 门禁与 AC 追溯要求。
---

# Spec 测试计划（V1：verification/test-plan.md）

## 概览

本技能是 **verification 阶段 worker skill**，只负责：

- 门禁校验（先定位 `{FEATURE_DIR}`，再读必要输入）
- 生成/更新 `{FEATURE_DIR}/verification/test-plan.md`
- 按 V1-DoD 自检
- 输出 `ROUTER_SUMMARY` 后回到 `using-aisdlc`

本技能 **不** 决定下一步做什么（由 `using-aisdlc` 路由）。

## 硬门禁（不得绕过）

### 1) 先定位 FEATURE_DIR（禁止猜路径）

```powershell
. ".\skills\spec-context\scripts\spec-common.ps1"
$context = Get-SpecContext
$FEATURE_DIR = $context.FEATURE_DIR
Write-Host "FEATURE_DIR=$FEATURE_DIR"
```

失败即停止。

### 2) 必读项目级 Memory（缺失写 CONTEXT GAP）

- `.aisdlc/project/memory/product.md`
- `.aisdlc/project/memory/tech.md`
- `.aisdlc/project/memory/glossary.md`

任一缺失：在 `test-plan.md` 中显式写 `CONTEXT GAP`（不要静默跳过）。

### 3) AC 来源至少其一存在

必须读取其一作为验收口径来源：

- `{FEATURE_DIR}/requirements/solution.md` 或
- `{FEATURE_DIR}/requirements/prd.md`

两者都不存在：停止并回到 `using-aisdlc`。

## 输出（落盘）

- `{FEATURE_DIR}/verification/test-plan.md`

## `test-plan.md` 最小结构（必须包含）

- 执行摘要（待测能力/版本/目标/关键风险）
- 测试范围（In / Out）
- 测试策略（类型 + 方法：正向/反向/边界）
- 环境与数据（环境/账号/数据准备）
- 准入标准 / 准出标准（含阻断交付口径）
- 风险与验证清单（Owner/截止/信号/动作；禁止 `TBD` 悬空）
- 追溯链接（AC 来源、`#impact-analysis` 如存在）
- CONTEXT GAP（如有：缺失 memory/输入导致的影响）

## V1-DoD 自检

- [ ] In/Out 与 `requirements/*` 一致且无歧义
- [ ] 有准入/准出标准，且具备“阻断交付”的明确口径
- [ ] 风险不悬空（Owner/截止/信号/动作齐全）
- [ ] 回归/定向回归范围来源可追溯（如有 `#impact-analysis`）

## 红旗 STOP

- 未回显 `FEATURE_DIR=...` 就开始写 `verification/*`
- `solution.md/prd.md` 都不存在却继续写测试范围/AC
- 用 `TBD/待确认` 充当风险与验证动作

## 输出约定（给 Router）

```text
ROUTER_SUMMARY
- FEATURE_DIR=...
- artifacts_written:
  - verification/test-plan.md
- context_gaps: [...]
- open_risks: [...]
- blocked_by: [...]
- router_hints: ["回到 using-aisdlc 继续路由"]
```

