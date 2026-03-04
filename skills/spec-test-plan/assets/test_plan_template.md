# 测试计划模板（verification/test-plan.md）

> 本模板用于在 Spec Pack 的 verification 阶段冻结：范围、策略、环境、准入/准出标准、风险与验证清单，并为用例/套件/报告提供口径。

---

## 1. 基本信息

- **Spec / Feature**：`{FEATURE_DIR}`（来自 `spec-context`）
- **版本/构建**：`<version-or-build-id>`
- **环境**：`Dev | Staging | Prod | <other>`
- **测试负责人**：`<name>`
- **计划日期**：`YYYY-MM-DD`

---

## 2. 执行摘要

- **待测能力**：`<一句话概述本次需求/变更>`
- **目标**：`<要验证的关键结果/AC 口径>`
- **关键风险**：`<3-5 条高风险点>`
- **结论门槛（预告）**：见“准出标准”

---

## 3. 测试范围

### 3.1 范围内（In Scope）

- `...`

### 3.2 范围外（Out of Scope）

- `...`

---

## 4. 测试策略

### 4.1 测试类型

- [ ] 功能（Functional）
- [ ] UI/交互（UI）
- [ ] 集成（Integration）
- [ ] 回归（Regression）
- [ ] 安全（Security）
- [ ] 性能/稳定性（Performance/Stability）

### 4.2 方法与设计原则

- 正向 / 反向 / 边界值 / 等价类
- 覆盖关键路径优先：先阻断点，后长尾
- 每一步必须有可观测预期（可判定 Pass/Fail/Blocked）

---

## 5. 回归策略（必须填写）

> 回归套件分层：smoke / targeted / full。执行顺序建议：smoke → P0 → targeted → full → 探索。

### 5.1 Smoke（15–30 分钟）

- **目的**：快速确认构建可用、关键路径可跑通
- **阻断规则**：任一 smoke 用例失败即阻断后续回归并判定“不具备交付条件”
- **覆盖**：关键路径 + 系统健康检查

### 5.2 Targeted（30–60 分钟）

- **触发条件**：基于 `impact-analysis` / 风险清单 / 变更点
- **覆盖**：受影响模块、集成点、依赖路径

### 5.3 Full（2–4 小时 / 视规模）

- **目的**：发布前/周更前全面验证
- **覆盖**：主要功能面 + 高风险集成 + 数据完整性

---

## 6. 环境与数据

### 6.1 环境矩阵

| 维度 | 值 |
|---|---|
| OS | Windows / macOS / Linux / ... |
| 浏览器 | Chrome / Edge / Firefox / ... |
| 设备 | Desktop / Mobile / ... |
| 后端环境 | Dev / Staging / ... |

### 6.2 账号与权限

- **测试账号**：`<username>`
- **角色/权限**：`<role>`
- **开关/配置**：`<feature flags / configs>`

### 6.3 测试数据准备

- 数据集来源：`<seed / mock / 生产脱敏 / 手工准备>`
- 重置方式：`<how to reset>`
- 清理要求：`<what to cleanup>`

---

## 7. 准入标准（Entry Criteria）

- [ ] 需求口径已冻结（`requirements/solution.md` 或 `requirements/prd.md` 可追溯）
- [ ] 测试环境可用且关键依赖可用
- [ ] 测试账号/权限/数据准备完成
- [ ] 构建已部署且版本可追溯（版本未知需记录为 `CONTEXT GAP`）

---

## 8. 准出标准（Exit Criteria，必须含阻断口径）

### 8.1 通过（Pass / Go）

- [ ] 所有 P0 用例通过
- [ ] smoke 套件通过
- [ ] 无阻断缺陷（Critical/P0）
- [ ] 关键风险验证动作完成且无未闭环阻断项

### 8.2 不通过（Fail / No-Go）

- [ ] 任一 P0 用例失败
- [ ] smoke 套件失败
- [ ] 存在阻断缺陷（Critical/P0），且无可接受变通方案
- [ ] 发现数据丢失/安全事故/不可逆风险

### 8.3 有条件通过（Conditional Pass）

- [ ] 存在 P1 失败但有明确变通方案与修复计划
- [ ] 遗留风险已记录且已获干系人接受（需在 `report-*.md` 中明确）

---

## 9. 风险与验证清单（必须可执行）

| 风险 | 概率 | 影响 | 验证动作（最小） | Owner | 截止 | 信号/证据 |
|---|---|---|---|---|---|---|
| `...` | 高/中/低 | 高/中/低 | `...` | `...` | `YYYY-MM-DD` | `...` |

---

## 10. 追溯链接（必须）

- `requirements/solution.md`：`<link>`
- `requirements/prd.md`（如有）：`<link>`
- `requirements/solution.md#impact-analysis`（如有）：`<link>`
- `verification/usecase.md`：`<link>`（生成后补）
- `verification/suites.md`：`<link>`（如有）

---

## 11. CONTEXT GAP（如有）

- `...`

