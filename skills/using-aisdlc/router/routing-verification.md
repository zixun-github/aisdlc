## using-aisdlc Router：验证链路路由细则（V1–V4）

> 本文件只定义“Router 如何判定下一步”的口径，不复制 verification SOP 的模板与长文本。

### verification 链路产物（用于路由判定）

以 `{FEATURE_DIR}` 为根：

- V1：`verification/test-plan.md`（或团队若统一命名为 `verification/plan.md`，Router 需兼容识别）
- V2：`verification/usecase.md`
- V3：`verification/suites.md`（可选）
- V4：`verification/report-{date}-{version}.md`

### 进入 verification 的路由信号

当用户意图包含以下任一信号，Router 进入 verification 链路：

- “出测试计划 / 测试用例 / 测试套件 / 测试报告”
- “进入 QA / 验收 / 验证 / 回归”
- “写缺陷 / 缺陷报告 / bug / 记录缺陷”

并且满足前置：已有需求输入（`requirements/solution.md` 或 `requirements/prd.md` 至少其一）。

### 默认最短路径（Router 默认）

默认顺序：V1 → V2 → V4

- V3（suites）为可选：当影响面较大、需要严格区分冒烟/回归/定向回归集合时，Router 才插入 V3。

### V1：测试计划（`spec-test-plan`）

进入条件：

- `{FEATURE_DIR}` 已确定（通过 `spec-context`）。
- `requirements/solution.md` 或 `requirements/prd.md` 至少其一存在。

下一步：

- 若测试计划已落盘 → V2

### V2：测试用例（`spec-test-usecase`）

进入条件：

- V1 已完成（存在 `verification/test-plan.md` 或 `verification/plan.md`）。

下一步：

- 默认进入 V4
- 如需 suites → 先 V3 再 V4

### V3：测试套件（`spec-test-suites`，可选）

进入条件（建议）：

- 存在影响分析 `requirements/solution.md#impact-analysis`，且需要从影响面生成定向回归集合；或 smoke 阻断规则需要独立维护。

下一步：V4

### V4：测试报告（`spec-test-execute`）

进入条件：

- V1 与 V2 已完成（V3 可选）。

命名兼容策略（Router 侧）：

- 若版本未知：允许 `report-{date}-unknown.md` 并要求在报告中标注 `CONTEXT GAP: version/build unknown`。

### Vx：缺陷报告（`spec-test-bug`，可插入）

当用户意图是“写缺陷/缺陷报告/bug/记录缺陷”时，Router 可在 V1–V4 任意节点**插入** `spec-test-bug`：

- `spec-test-bug` 输出面向外部缺陷系统的“可粘贴缺陷报告正文”，**不在 Spec Pack 内落盘 bug 文件/目录**。
- 外部缺陷创建/更新后，要求将 `BUG-ID/链接/状态/严重程度/关联 TC` 回写到本轮 `verification/report-*.md`（缺陷清单/阻断项）。
