---
title: R5 基于方案生成 PRD — 结构化转写与验收口径设计规范
status: draft
stage: requirements
module: R5
principles_ref: design/aisdlc.md
source_refs:
  - design/aisdlc_spec_product.md
  - design/product/aisdlc_spec_product_clarify.md
  - design/product/aisdlc_spec_product_solutions.md
---

## 0. 目标与定位

本设计文档用于细化 Spec 级需求分析中的 R5「基于方案生成 PRD」：在 R1（澄清）与 R3（最终方案）完成后，将“决策方案”稳定转写为**可评审、可验收、可拆解**的 PRD，并落盘到：

- `{FEATURE_DIR}/requirements/prd.md`

核心目标：

- **结构化转写**：将方案中的机制/流程/规则转为可交付规格（功能、规则、异常、AC）
- **验收可执行**：每个核心场景必须有可测试的 AC
- **范围可控**：In/Out 与里程碑/MVP 对齐，避免范围漂移
- **可追溯**：结论可回溯到 `clarify.md` 与 `solutions.md`

---

## 1. 术语与接口（命令必须遵守）

### 1.1 上下文与路径

- **FEATURE_DIR**：由 `Get-SpecContext` 自动获取，定位到 `.aisdlc/specs/{num}-{short-name}/`
- **必读输入**：
  - `{FEATURE_DIR}/requirements/clarify.md`
  - `{FEATURE_DIR}/requirements/solutions.md`
- **可选输入**：
  - `.aisdlc/project/memory/glossary.md`（术语口径）
  - 既有 `{FEATURE_DIR}/requirements/prd.md`（若存在：用于增量更新/对照）
- **输出**：`{FEATURE_DIR}/requirements/prd.md`

### 1.2 输出产物的职责边界

`prd.md` 的职责是把“最终方案”转为**可交付规格**，必须回答：

- 背景与问题（来自 `clarify.md`）
- 目标与成功指标（可观测/可埋点）
- 范围与里程碑（MVP → 迭代）
- 功能清单与优先级（MoSCoW 或 P0/P1/P2）
- 核心场景与用户故事
- 业务规则/口径与关键异常/边界
- 验收标准（AC）：逐条可测试
- 关键干系人验收口径
- 风险与依赖

> 约束：本模块不重新发散方案；仅在必要处做“最小补齐”，不新增未经依据的功能。

---

## 2. 强制门禁与总流程（关键约束：为避免“跳步/脑补”而设）

### 2.1 强制门禁（MUST）

- **必须存在 `clarify.md` 与 `solutions.md`**。若任一缺失：
  - **不得**输出 `{FEATURE_DIR}/requirements/prd.md` 正文（即使是草稿）
  - 只能提示用户先完成 R1/R3
- **全程使用中文**；不确定信息必须标注为“未知/待确认”，不得脑补。

> 说明：若 `solutions.md` 中缺少关键可验收信息（如成功指标/关键规则/边界），允许继续生成，但必须在 PRD 中标记为“待确认”并说明影响。

### 2.2 总流程（MUST）

1. 获取上下文：`Get-SpecContext` → 得到 `FEATURE_DIR`
2. 读取输入：`clarify.md` + `solutions.md` +（可选）`glossary.md` +（可选）上轮 `prd.md`
3. 结构化转写：将方案机制/流程/规则转为 PRD 结构（功能清单、业务规则、异常与边界、AC）
4. 一致性对齐：校验 In/Out 与方案一致；在 PRD 中明确 MVP/优先级并与资源/约束一致
5. 落盘：输出 `requirements/prd.md`（只输出 Markdown 正文）
6. 自检校验：执行 R5-DoD（见第 6 节）

---

## 3. 结构化转写规则（从“方案”到“可验收规格”）

### 3.1 转写原则（MUST）

- **以 `solutions.md` 为主**：方案中的机制/流程/规则/状态必须转为可实现条目
- **以 `clarify.md` 校验范围**：In/Out 与场景边界不得偏离
- **场景先行**：每个核心场景必须映射到用户故事与 AC
- **规则可测试**：业务规则需写成可验证条件（条件 + 结果）
- **异常与边界明确**：失败、权限、并发、幂等、降级需明确口径
- **不确定不硬编**：缺信息写“未知/待确认”，并标注影响

### 3.2 关键映射关系（建议固定口径）

- `clarify.md` 背景/痛点 → PRD「背景与问题」
- `clarify.md` 目标/价值 → PRD「目标与成功指标」
- `clarify.md` In/Out → PRD「范围」
- `solutions.md` 方案与约束 → PRD「功能清单/优先级 + 里程碑（MVP）」  
  - 说明：**优先级与 MVP 的最终落盘以 PRD 为准**；若 `solutions.md` 已包含明确的优先级口径/阶段建议则在 PRD 中对齐，否则由 PRD 在转写阶段补齐“优先级与里程碑”，并把不确定处标注为“待确认”（说明影响）。
- `solutions.md` 机制/规则/状态 → PRD「业务规则/异常与边界/交互要点」
- `solutions.md` 风险登记与验证 → PRD「风险与依赖」

---

## 4. 信息不足时的最小补齐（可选）

当输入材料存在明显缺口时，允许命令执行最小补齐，但必须遵守：

- **只补齐“验收可执行”的必要信息**，不引入新需求
- **最多 3 个问题**，优先问：成功指标、关键规则、验收口径
- **问题与缺口对应**：明确“缺什么 → 影响哪条 AC/哪段 PRD”
- 用户未回答时，必须在 PRD 中标注“待确认”

---

## 5. `prd.md` 结构规范（建议保持稳定，便于评审与复用）

建议以以下结构输出（与 `design/aisdlc_spec_product.md` 的 R5 口径一致）：

1) 背景与问题  
2) 目标与成功指标  
3) 范围（In/Out）与里程碑（MVP → 迭代）  
4) 功能清单与优先级（MoSCoW / P0-P2）  
5) 核心场景与用户故事（按场景组织）  
6) 业务规则与口径（引用 glossary/数据口径）  
7) 交互要点（原则与约束，细节下沉 R6）  
8) 异常与边界（失败、权限、并发、幂等、降级）  
9) 验收标准（AC）：逐条可测试、可验证  
10) 关键干系人验收口径  
11) 风险与依赖（含缓解）  
12) 追溯链接（clarify/solutions/interaction/prototype）

---

## 6. R5-DoD（完成标准）

- [ ] 每个核心场景都有 AC（可转测试用例）
- [ ] In/Out 与 R1 一致，且与最终方案一致
- [ ] 功能优先级与里程碑一致：MVP 至少覆盖 Must/P0
- [ ] 业务规则与异常边界可测试且口径一致
- [ ] 风险与依赖有明确 Owner 与缓解动作
- [ ] 至少覆盖 1 个高优先级干系人的验收口径

---

## 7. 提示词资产分层（用于约束未来命令文档结构）

为确保“转写可验收”但不“跳步/脑补”，建议提示词按层次组织：

- **提示词 0（入口主提示词）**：检查 `clarify.md` 与 `solutions.md` 是否存在；不满足门禁则拒绝生成 PRD
- **提示词 1（结构化转写）**：把方案转为 PRD 结构；生成场景、功能、规则、异常与 AC
- **提示词 2（输出 prd.md）**：按模板输出 Markdown 正文；不输出解释
- **提示词 3（自检校验）**：输出 R5-DoD 勾选清单 + 未通过项补齐建议

> 设计约束：提示词内容可演进，但其职责边界、门禁规则、输出形态不得破坏本规范。

---

## 8. 下一步命令指引（执行完 `spec-product-prd` 后）

当 R5 命令 `spec-product-prd` 完成、并已落盘 `{FEATURE_DIR}/requirements/prd.md` 后，建议按以下顺序继续（对齐 `design/aisdlc_spec_product.md` 的“命令式工作流”）：

### 8.1 下一步（R6：场景交互方案）

- **下一步命令（R6）**：执行 `spec-product-interaction`  
  - **产物**：`{FEATURE_DIR}/requirements/interaction.md`

### 8.2 然后（R7：原型）

- **后续命令（R7）**：执行 `spec-product-prototype`  
  - **产物**：`{FEATURE_DIR}/requirements/prototype.md`

### 8.3 回流提示（来自交互/原型评审）

若在 R6/R7 发现以下问题，建议优先回流更新 PRD（必要时再上游回流）：

- **AC 不可验收/不可测试**、规则口径不清 → 回流更新 `{FEATURE_DIR}/requirements/prd.md`
- **范围漂移/In-Out 冲突** → 回流 R5（必要时回流 R1/R3 对齐边界与方案）
