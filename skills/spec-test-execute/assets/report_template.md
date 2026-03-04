# 测试报告模板（verification/report-{date}-{version}.md）

> 本模板用于产出“结论性测试报告”：是否满足 AC、是否可交付、阻断点与下一步动作是什么。
>
> 约束：缺陷不在 Spec Pack 内单独落盘，报告只做外部缺陷系统的编号/链接引用，并关联到 `TC-*`。

---

## 1. 基本信息

- **日期**：`YYYY-MM-DD`
- **版本/构建**：`<version-or-build-id>`（未知：`unknown`，并在 CONTEXT GAP 说明）
- **环境**：`Dev | Staging | Prod | <other>`
- **测试人员**：`<name>`
- **Spec / Feature**：`{FEATURE_DIR}`

---

## 2. 测试摘要（必须给出结论）

- **结论**：`通过 | 不通过 | 有条件通过`
- **阻断交付**：`是 | 否`
- **一句话说明**：`<为什么是这个结论>`

---

## 3. 覆盖统计（必须）

### 3.1 按套件统计

| Suite | Total | Executed | Pass | Fail | Blocked | NotRun | PassRate |
|---|---:|---:|---:|---:|---:|---:|---:|
| Smoke |  |  |  |  |  |  |  |
| Targeted |  |  |  |  |  |  |  |
| Regression |  |  |  |  |  |  |  |
| **TOTAL** |  |  |  |  |  |  |  |

### 3.2 按优先级统计（从用例提取或手工汇总）

| Priority | Total | Executed | Pass | Fail | Blocked | NotRun |
|---|---:|---:|---:|---:|---:|---:|
| P0 |  |  |  |  |  |  |
| P1 |  |  |  |  |  |  |
| P2 |  |  |  |  |  |  |
| P3 |  |  |  |  |  |  |

---

## 4. AC↔TC 覆盖映射（必须）

> 至少要回答：哪些 AC 被哪些 TC 覆盖；哪些 AC 仍缺口（Gap）。

| AC | 来源链接 | 覆盖用例（TC-...） | 覆盖状态（完整/部分/缺口） | 备注 |
|---|---|---|---|---|
| AC-001 | `requirements/...#...` | `TC-...` |  |  |

---

## 5. 关键失败与阻断项（必须可追溯到 TC）

### 5.1 阻断项清单

| TC | 现象摘要 | 外部缺陷（ID/链接） | 严重程度 | 状态 | 是否阻断交付 | 下一步动作 |
|---|---|---|---|---|---|---|
| `TC-...` |  | `BUG-...` | Critical/P0/P1 | Open/InProgress/... | 是/否 |  |

### 5.2 失败明细（可选：按套件/模块分组）

- `TC-...`：<失败原因>（证据：<截图/日志/录屏/定位信息>）

---

## 6. 缺陷清单（仅引用，必须关联 TC）

> 不在 Spec Pack 内新增缺陷文件；此处记录外部缺陷系统引用信息，并关联到用例编号。

| BUG | 链接 | 标题 | Severity | Priority | 状态 | 关联用例（TC-...） | 备注 |
|---|---|---|---|---|---|---|---|
| `BUG-...` | `<url>` |  |  |  |  | `TC-...` |  |

---

## 7. 遗留风险与建议（必须可执行）

- **遗留风险**：
  - `...`
- **建议**：
  - `返工/补测/灰度/加监控/回滚建议`（必须写明范围与入口）

---

## 8. 追溯链接

- `verification/test-plan.md`：`<link>`
- `verification/usecase.md`：`<link>`
- `verification/suites.md`（如有）：`<link>`
- `requirements/solution.md` / `requirements/prd.md`：`<link>`

---

## 9. CONTEXT GAP（如有）

- `...`

