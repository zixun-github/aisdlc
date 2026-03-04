# 测试套件模板（verification/suites.md）

> 本模板用于把 `verification/usecase.md` 中的用例编号组织成可执行集合（smoke / targeted / regression），并明确执行顺序、依赖与阻断口径。

---

## 1. 基本信息

- **Spec / Feature**：`{FEATURE_DIR}`
- **版本/构建**：`<version-or-build-id>`
- **环境**：`Dev | Staging | Prod | <other>`
- **维护人**：`<name>`
- **更新日期**：`YYYY-MM-DD`

---

## 2. 执行顺序（推荐）

1. **Smoke**
2. **P0 Critical**（如在用例中以 P0 标注）
3. **Targeted**
4. **Regression**
5. **探索性测试（可选）**

> 规则：smoke 失败即停止后续执行，并在 `report-*.md` 中判定为“不可交付/阻断交付”。

---

## 3. Smoke（15–30 分钟）

### 3.1 目的

- 快速确认构建可用、关键路径可跑通、关键依赖健康。

### 3.2 阻断规则（必须与 test-plan 的 Exit Criteria 一致）

- 任一 smoke 用例失败 → **阻断交付**（Fail / No-Go）
- 任一 smoke 用例阻塞（Blocked）且无法在本轮解决 → 记录阻塞原因并阻断后续执行

### 3.3 用例清单（必须可定位到 TC 编号）

- `TC-...`
- `TC-...`

---

## 4. Targeted（30–60 分钟）

### 4.1 触发条件（必须填写）

- 变更点：`<summary>`
- 影响面来源：`requirements/solution.md#impact-analysis`（如有）/ 风险清单 / 变更说明

### 4.2 用例清单

- `TC-...`
- `TC-...`

---

## 5. Regression / Full（2–4 小时，视规模）

### 5.1 目的

- 发布前或周期性全面验证，确保既有功能未被破坏。

### 5.2 分组（可选）

按模块/领域分组，便于维护与执行：

- Authentication & Authorization
  - `TC-...`
- Payment / Order（示例）
  - `TC-...`

### 5.3 用例清单

- `TC-...`

---

## 6. Pass/Fail/Conditional 判定口径（简版）

- **PASS / Go**：smoke 全通过；P0 全通过；无阻断缺陷
- **FAIL / No-Go**：任一 P0 失败；或存在阻断缺陷；或 smoke 失败
- **CONDITIONAL PASS**：存在 P1 失败但有变通方案与明确修复/回归计划（需在 `report-*.md` 说明）

---

## 7. 维护规则（建议）

- 每次发布后：
  - 将“本次发现的缺陷”对应的用例补入 targeted 或 regression
  - 删除/更新已废弃的用例
  - 确保 smoke 仍可在 15–30 分钟内完成

