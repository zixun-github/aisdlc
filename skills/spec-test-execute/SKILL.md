---
name: spec-test-execute
description: Use when 需要在 Spec Pack 的 verification 阶段产出 `{FEATURE_DIR}/verification/report-{date}-{version}.md`（测试报告），给出可交付结论并可追溯到用例与缺陷引用。
---

# Spec 测试执行与报告（V4：Execute + Report）

本技能产出“结论性测试报告”：回答 **是否满足 AC、是否可交付、阻断点是什么、下一步动作是什么**。

---

## 输入与门禁（必须遵守）

**REQUIRED SUB-SKILL：正在执行 `spec-context` 获取上下文，并在对话中回显 `FEATURE_DIR=...`（允许 `(reuse)`）。**

- **先定位再读写**：必须先通过 `spec-context` 获取 `FEATURE_DIR`；失败即停止，禁止猜路径。
- **必读项目级 memory**：`project/memory/product.md`、`project/memory/tech.md`、`project/memory/glossary.md`；读不到必须写 `CONTEXT GAP`。
- **输入依赖**：`verification/test-plan.md` 与 `verification/usecase.md` 必须存在；`verification/suites.md` 若存在则纳入覆盖统计。
- **缺陷不在 Spec Pack 落盘**：禁止新建 `verification/bugs/**`；报告只做“缺陷编号/链接/状态/严重程度”的引用清单。
- **缺陷回写（强制）**：当缺陷在外部系统创建/更新后，必须回写到本轮 `report-*.md` 的“缺陷清单”，并关联到对应 `TC-*`。

---

## 输出（落盘）

- `{FEATURE_DIR}/verification/report-{date}-{version}.md`

命名规则：

- `date`：`YYYY-MM-DD`
- `version`：构建/发布可追溯标识（版本号、build id、git sha）；未知则用 `unknown` 且在报告中写 `CONTEXT GAP: version/build unknown`

---

## 强制模板（必须遵守）

- `report-*.md` 必须按模板生成（不得自创结构/字段名）：
  - `assets/report_template.md`

## 内容要求（最小结构）

`report-*.md` 至少包含：

- 测试摘要
  - 结论：通过 / 不通过 / 有条件通过
  - 版本/构建/环境（未知必须写 `CONTEXT GAP`）
- 覆盖统计
  - 按套件/优先级：总数、执行数、通过、失败、阻塞、未执行
- AC↔TC 覆盖映射
  - 至少能回答“哪些 AC 被哪些 TC 覆盖；哪些 AC 仍缺口（Gap）”
- 关键失败与阻断项
  - **必须可追溯到用例编号（TC-...）**
- 缺陷清单（仅引用）
  - 缺陷系统/Issue 编号 + 链接 + 状态 + 严重程度
  - **必须关联到对应 `TC-*`**；若尚未提缺陷，必须写明阻断原因与下一步动作（不得悬空）
- 遗留风险与建议
  - 下一步动作必须可执行（返工/补测/灰度/加监控/回滚建议）
- 追溯链接
  - `requirements/*`、`verification/test-plan.md`、`verification/usecase.md`、（可选）`verification/suites.md`
- CONTEXT GAP（如有）

---

## DoD 自检（V4-DoD）

- [ ] 报告有明确结论（不是“已测完”）
- [ ] 所有失败/阻断项都能定位到 `TC-*` 与外部缺陷编号（如有）
- [ ] 风险与建议可执行（下一步动作明确）

