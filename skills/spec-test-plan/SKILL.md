---
name: spec-test-plan
description: Use when 需要在 Spec Pack 的 verification 阶段生成或更新 `{FEATURE_DIR}/verification/test-plan.md`（测试计划），并要求严格门禁与可追溯。
---

# Spec 测试计划（V1：Test Plan）

为当前 Spec Pack 生成/更新测试计划：冻结 **范围、策略、环境、准入/准出标准、风险与验证清单**，并与 `requirements/*` 的验收口径保持可追溯一致。

---

## 输入与门禁（必须遵守）

- **先定位再读写**：必须先通过 `spec-context` 获取 `FEATURE_DIR`；失败即停止，禁止猜路径。
- **必读项目级 memory**：`project/memory/product.md`、`project/memory/tech.md`、`project/memory/glossary.md`；读不到必须写 `CONTEXT GAP`。
- **需求级最小输入**：`{FEATURE_DIR}/requirements/solution.md` 或 `{FEATURE_DIR}/requirements/prd.md` **至少其一必须存在**；否则停止并写 `CONTEXT GAP`。

---

## 输出（落盘）

- `{FEATURE_DIR}/verification/test-plan.md`

---

## 强制模板（必须遵守）

- `test-plan.md` 必须按模板生成（不得自创结构/字段名）：
  - `assets/test_plan_template.md`

## 内容要求（最小结构）

`test-plan.md` 至少包含：

- 执行摘要（待测能力/版本/目标/关键风险）
- 测试范围（In/Out）
- 测试策略（类型：功能/UI/集成/回归/安全…；方法：正向/反向/边界）
- 环境与数据（环境、账号/权限、数据准备方式）
- 准入标准（Entry Criteria）
- 准出标准（Exit Criteria，必须含“阻断交付”的口径）
- 风险与验证清单（Owner/截止/信号/动作）
- 追溯链接（指向 `solution/prd` 的 AC/范围来源；如有 `#impact-analysis` 也要链接）
- CONTEXT GAP（如有：缺失输入导致的影响）

---

## DoD 自检（V1-DoD）

- [ ] 范围 In/Out 明确，且与 `requirements/*` 一致
- [ ] 有准入/准出标准，并能明确“什么情况下阻断交付”
- [ ] 风险不是清单摆设：每条风险都有最小验证动作（Owner/信号/动作）
- [ ] 有追溯入口：至少能回答“本计划依据哪份 AC/范围定义”

