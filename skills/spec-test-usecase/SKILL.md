---
name: spec-test-usecase
description: Use when 需要在 Spec Pack 的 verification 阶段生成或更新 `{FEATURE_DIR}/verification/usecase.md`（测试用例），默认以手工执行为准，并要求按统一模板生成且 AC 可追溯。
---

# Spec 测试用例（V2：Usecase）

把 `requirements/solution.md` / `requirements/prd.md` 中的验收口径（AC）转成 **可执行、可判定、可追溯** 的手工测试用例。

---

## 输入与门禁（必须遵守）

**REQUIRED SUB-SKILL：正在执行 `spec-context` 获取上下文，并在对话中回显 `FEATURE_DIR=...`（允许 `(reuse)`）。**

- **必读项目级 memory**：`project/memory/product.md`、`project/memory/tech.md`、`project/memory/glossary.md`；读不到必须写 `CONTEXT GAP`。
- **需求级最小输入**：`{FEATURE_DIR}/requirements/solution.md` 或 `{FEATURE_DIR}/requirements/prd.md` 至少其一必须存在；否则停止并写 `CONTEXT GAP`。
- **强制使用模板**：`usecase.md` 必须直接使用用例模板 `assets/test_usercase_template.md`（不得自创结构、不得改字段名/章节名）。

---

## 输出（落盘）

- `{FEATURE_DIR}/verification/usecase.md`

---

## 强制模板（必须遵守）

- `usecase.md` 必须按模板生成（不得自创结构/字段名/章节名）：
  - `assets/test_usercase_template.md`

## 内容要求

- 每条用例必须按模板填写（至少“标准测试用例模板”部分）
- 每步必须有可观测预期（能判定 Pass/Fail/Blocked）
- 每条用例必须能追溯到 AC（指向 `solution/prd`）

说明：

- 模板中的 **状态/执行历史/缺陷 ID** 字段用于与 V4 `report-*.md` 对齐；执行结果与缺陷引用以 `report-*.md` 为准（不在 Spec Pack 内新增缺陷文件/目录）。

---

## DoD 自检（V2-DoD）

- [ ] P0/P1 用例均“可执行”：前置条件与数据不缺失
- [ ] 每一步都有“预期结果”（可观测、可判定）
- [ ] AC 覆盖关系明确（至少能回答“哪些 AC 被哪些用例覆盖”）
- [ ] 每条用例按 `assets/test_usercase_template.md` 模板填写（字段与章节不缺失）

