---
name: spec-test
description: Use when 需要在 Spec Pack 的 verification 阶段生成/更新测试计划、用例、套件或测试报告，并要求严格门禁、可追溯落盘与不越权路由。
---

# Spec Pack 验证（Verification）主技能：spec-test

本技能用于 Spec Pack 的 verification 阶段（V1–V4）：生成/更新测试计划、测试用例、测试套件与测试报告。默认以**手工测试**为准；自动化仅作为可选增强。

---

## 何时使用

- 需要为某个 Spec Pack 产出或更新以下任一文件：
  - `verification/test-plan.md`
  - `verification/usecase.md`
  - `verification/suites.md`
  - `verification/report-{date}-{version}.md`

## 何时不使用

- 你要写自动化测试代码：本技能只负责 verification 文档产物与门禁，不要求在本阶段实现自动化代码。

---

## 输入与门禁（必须遵守）

### FEATURE_DIR

- 读/写任一 `verification/*` 前，必须先通过 `spec-context` 获取 `FEATURE_DIR`。
- `FEATURE_DIR` 未定位时禁止落盘（禁止猜路径/临时写到别处）。

### 必读上下文

- 项目级：
  - `project/memory/product.md`
  - `project/memory/tech.md`
  - `project/memory/glossary.md`
- 需求级（至少其一）：
  - `{FEATURE_DIR}/requirements/solution.md` 或 `{FEATURE_DIR}/requirements/prd.md`

缺失时必须在输出物中显式写 `CONTEXT GAP`，不得静默跳过。

---

## 子技能一览

| 子技能 | 产物（落盘） | 目的 |
|---|---|---|
| `spec-test-plan` | `{FEATURE_DIR}/verification/test-plan.md` | 冻结范围/策略/环境/准入准出/风险清单 |
| `spec-test-usecase` | `{FEATURE_DIR}/verification/usecase.md` | 将 AC 转为可手工执行的用例（强制使用用例模板） |
| `spec-test-suites` | `{FEATURE_DIR}/verification/suites.md` | 组织 smoke/regression/targeted 套件与执行顺序 |
| `spec-test-execute` | `{FEATURE_DIR}/verification/report-{date}-{version}.md` | 记录执行结果并给出结论（覆盖/阻断/缺陷引用/风险建议） |
| `spec-test-bug` | （不落盘 bug 文件） | 生成可直接粘贴到外部缺陷系统的缺陷报告正文，并指导把缺陷引用回写到 `report-*.md` |

---

## 平替能力范围（对齐 qa-test-planner 的核心能力）

在不依赖 `qa-test-planner` 的前提下，本技能组提供以下能力并适配本仓库约束：

- **测试计划（V1）**：范围/策略/环境/准入准出/风险清单；包含回归分层（smoke/targeted/full）与阻断口径。
- **手工测试用例（V2）**：按统一模板生成；每步可判定；AC 可追溯；可为后续自动化生成保留结构信息（但不要求在本阶段写自动化代码）。
- **测试套件（V3）**：smoke/regression/targeted；条目必须可定位到 `TC-*`；执行顺序与阻断口径与 test-plan 对齐。
- **测试报告（V4）**：覆盖统计（套件/优先级）、AC↔TC 覆盖映射、阻断项、缺陷引用清单、结论与下一步动作（可执行）。
- **缺陷报告（Vx）**：输出可直接粘贴到外部缺陷系统的缺陷报告正文；外部缺陷创建/更新后，必须将编号/链接/状态/严重程度与关联 TC 回写到 `report-*.md`。

## 通用约束

- 缺陷不在 Spec Pack 内单独落盘：禁止新增 `verification/bugs/**`；仅在 `report-*.md` 的“缺陷清单”里引用外部缺陷系统（编号/链接/状态/严重程度/关联 TC）。 

