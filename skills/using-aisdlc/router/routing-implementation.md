## using-aisdlc Router：实现链路路由细则（I1–I2 + Finish）

> 本文件只定义“Router 如何判定下一步”的口径，不复制实现侧 SOP 的模板与长文本。

### 实现链路 SSOT 产物（用于路由判定）

以 `{FEATURE_DIR}` 为根：

- I1：`implementation/plan.md`（必做；实现侧唯一执行清单与状态 SSOT）

### 进入 I1（实现计划）的路由口径

当用户意图包含以下任一信号，Router 应进入 I1（`spec-plan`）：

- “出实现计划 / plan.md / 任务拆分 / 开发计划”
- “开始开发 / 改代码 / 开始实现 / 跑通闭环”

I1 的最小输入要求（Router 侧判定用）：

- `{FEATURE_DIR}/requirements/solution.md` 或 `requirements/prd.md` 至少其一存在；且 `solution.md` 建议具备 `#impact-analysis` 作为约束输入。

若输入不足：Router 仍可进入 I1，但必须预期 worker 在 `plan.md` 中标注 `NEEDS CLARIFICATION` 并阻断进入 I2。

### 进入 I2（执行实现）的路由口径

只有当以下条件同时满足时，Router 才进入 I2（`spec-execute`）：

- `{FEATURE_DIR}/implementation/plan.md` 已存在且可执行（无关键缺口阻塞）。
- 用户意图明确包含“开始实现/改代码/交付完成/跑通闭环”等“要进入执行”的信号。
- 若仓库存在 `.gitmodules` 且 `plan.md` 已声明受影响子仓：预期 worker 会在开始前校验这些 `required` 子仓是否已切到与根项目同名的 Spec 分支；若不满足，应在 I2 内阻断并汇报，而不是静默继续。

若用户意图仅为“产出文档/产出计划”，Router 应停在 I1（不进入 I2），且不以“要不要继续”提问结束，而是以“本阶段产物已落盘 + 你下一步如果要进入执行请明确意图”结束。

### 实现链路锁定：`plan.md` 落盘后的候选约束（强约束）

一旦 `{FEATURE_DIR}/implementation/plan.md` 已落盘，Router 应视为进入实现链路：

- 后续默认候选步骤只允许：`spec-execute` → `finishing-development`。
- 不得把 `spec-product-prd` / `spec-product-prototype` / `spec-product-demo` 或 `spec-plan` 再列为“后续可选步骤”。
  - 若存在澄清缺口，应当通过 `plan.md/NEEDS CLARIFICATION` 管理：Router 收集到最小输入后，直接回到 I2 执行。

### Finish（开发收尾确认）的路由口径

当 I2 执行完成（或 worker 回报可进入收尾验证），Router 进入 Finish（`finishing-development`）。
