---
name: spec-test-suites
description: Use when 需要在 Spec Pack 的 verification 阶段生成或更新 `{FEATURE_DIR}/verification/suites.md`（测试套件），把用例组织成可执行集合并定义阻断规则与执行顺序。
---

# Spec 测试套件（V3：Suites）

把 `usecase.md` 里的用例编号组织成可执行集合（**smoke / regression / targeted**），并明确 **执行顺序、依赖与阻断口径**。

---

## 输入与门禁（必须遵守）

- **先定位再读写**：必须先通过 `spec-context` 获取 `FEATURE_DIR`；失败即停止，禁止猜路径。
- **必读项目级 memory**：`project/memory/product.md`、`project/memory/tech.md`、`project/memory/glossary.md`；读不到必须写 `CONTEXT GAP`。
- **输入依赖**：`{FEATURE_DIR}/verification/usecase.md` 与 `{FEATURE_DIR}/verification/test-plan.md` 应已存在；缺失时必须写 `CONTEXT GAP` 并停止（避免凭空编排）。
- **套件必须可定位**：套件条目必须指向具体用例编号（禁止“覆盖登录流程”这类模糊描述）。

---

## 输出（落盘）

- `{FEATURE_DIR}/verification/suites.md`

---

## 强制模板（必须遵守）

- `suites.md` 必须按模板生成（不得自创结构/字段名）：
  - `assets/suites_template.md`

## 内容要求（最小结构）

`suites.md` 至少包含：

- Smoke（冒烟）
  - 阻断规则（与 `test-plan.md` 的准出标准一致）
  - 用例清单：`TC-*`
- Regression（回归）
  - 用例清单：`TC-*`（可分组）
- Targeted（定向回归，如适用）
  - 触发条件（impact-analysis / 风险清单 / 变更说明）
  - 用例清单：`TC-*`
- 执行顺序与依赖（例如 smoke → targeted → regression）

---

## DoD 自检（V3-DoD）

- [ ] 套件中的每条目都能定位到具体 `TC-*` 编号
- [ ] smoke 套件有明确“失败即阻断交付”的口径，且与 `test-plan.md` 一致
- [ ] targeted 套件能追溯到影响面/风险来源（如有 `requirements/solution.md#impact-analysis`）

