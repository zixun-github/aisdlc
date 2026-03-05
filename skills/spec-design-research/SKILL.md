---
name: spec-design-research
description: Use when 需要在 Spec 级设计阶段执行 D1 research（产出 `{FEATURE_DIR}/design/research.md`），或面对关键不确定性/高风险点需要先验证而不是直接进入 D2；常见症状包括缺少证据支撑取舍、未知项被写成 TODO/待确认问题、在压力下想猜 FEATURE_DIR 或把调研写成实现细节。
---

# spec-design-research

## 概览

本技能用于执行 Spec 级设计阶段的 **D1 research（可选）**：从 `requirements/solution.md` 的技术背景中**系统提取未知项**，把“NEEDS CLARIFICATION / 依赖 / 集成”转成**可分发的研究任务**并完成调研，在 `design/research.md` 中以 **Decision / Rationale / Alternatives considered** 的结构沉淀结论，使 D2 可以直接引用而无需重复解释。  
本技能既可独立使用（只做 D1），也可在 `using-aisdlc` 的路由判定为“需要 D1”时被调用（本技能不做 D0/D1/D2 分流判断）。

**开始时宣布：**「我正在使用 spec-design-research 技能进行设计调研并落盘 research.md。」

## 何时使用 / 不使用

- **使用时机（命中任一）**
  - 方案正确性依赖未知事实（若 X 不成立，方案会推倒重来）
  - 存在多个可行方向，但缺少证据支撑取舍
  - 对外契约/迁移/安全/性能/一致性等存在高风险点，需要先验证
  - 你发现自己要写“待确认问题清单 / TODO”，但无法给出验证方式与下一步动作
- **不要用在**
  - 需求侧 SSOT 还没落盘（缺 `requirements/solution.md`）：先完成 R1（见 `spec-product-clarify`）
  - 不存在关键不确定性，且 `solution.md` 已经把关键约束与验收口径证据化：可跳过 D1 直接进入 D2

## 快速参考

- **唯一落盘位置**：`{FEATURE_DIR}/design/research.md`
- **最小化模板**：`<本SKILL.md目录>/assets/research-template.md`
- **D1-DoD（缺一不可）**
  - 技术背景中的 **所有** `NEEDS CLARIFICATION` 都有对应研究任务，并在 research.md 内给出结论（以 Decision/Rationale/Alternatives 结构）
  - 对每个 **依赖项** 有对应“最佳实践”任务结论（或明确“不适用”的理由与证据入口）
  - 对每个 **集成点** 有对应“模式/对接方式”任务结论（含关键约束、失败模式与替代方案）
  - 未知项不悬空：要么被研究结论关闭，要么进入“风险与验证清单”（含信号/Owner/截止/动作）
  - 研究结论可追溯，并能被 D2 直接引用（结论短、证据清、可复用）
- **禁止事项**
  - 禁止猜 `FEATURE_DIR` / 手写 `.aisdlc/specs/...` 路径
  - 禁止在 research.md 写实现规格（任务拆分/字段清单/DDL/脚本步骤）
  - 禁止输出“TODO/待确认问题”替代研究任务与结论（未知要么转任务并产出结论，要么进入可执行验证清单）
  - 禁止在 D1 擅自新建契约/ADR/实现规格文件或目录：D1 只产出 `design/research.md`；若需要更新 `project/contracts/` 或 `project/adr/`，在 research 里写“需要更新的入口 + 要点”，把实际落盘留给 D2（或用户明确要求的操作）

## 实施步骤（Agent 行为规范）

### 0) 门禁：定位 `{FEATURE_DIR}`（必须）

**REQUIRED SUB-SKILL：正在执行 `spec-context` 获取上下文，并在对话中回显 `FEATURE_DIR=...`（允许 `(reuse)`）。**


### 1) 读取最小必要输入（缺失则停止）

- **必读**：`{FEATURE_DIR}/requirements/solution.md`
- **按需**：`{FEATURE_DIR}/requirements/prd.md`、`{FEATURE_DIR}/requirements/prototype.md`
- **按需（项目级）**：`project/memory/*`、相关 `project/contracts/`、`project/adr/` 索引

**停止条件（不得脑补继续）：**

- 找不到或无法读取 `requirements/solution.md`
- `solution.md` 中的 In/Out、验收口径、关键约束不可追溯/不可测试（需要先回到 R1 补齐）

### 2) D1 是否需要执行（自检；避免“为调研而调研”）

本技能作为 **D1 worker skill**：进入本技能即表示“路由已判定需要 D1”，因此本技能不再做“要不要做 D1”的判断。  
若你在执行中发现：关键不确定性已经被证据化且无需继续 research，则应 **停止并回到 `using-aisdlc`** 重新路由，而不是在本技能内部改写路由结论。

### 3) 从“技术背景”抽取未知项 → 生成研究任务（核心机制）

> **硬规则**：research.md 不出现“待确认问题清单 / TODO”。未知一律转成研究任务并给出结论；无法在本轮关闭的，再进入“验证清单”。

从 `requirements/solution.md` 中（尤其是“技术背景/现状/架构/依赖/集成/约束/风险”相关段落）提取三类条目，并为每条生成研究任务：

- **NEEDS CLARIFICATION → 研究任务**  
  目标：把“未知事实/不确定性”研究成可被 D2 引用的结论（含取舍与替代方案）。
- **依赖项（组件/服务/库/平台/组织依赖） → 最佳实践任务**  
  目标：查明该依赖在本领域的最佳实践/常见坑/约束（并结合本项目约束给出结论）。
- **集成点（对接外部系统/协议/消息/鉴权/回调等） → 模式任务**  
  目标：明确集成模式（同步/异步、幂等/重试、鉴权/签名、数据契约/版本、错误处理与降级）并给出替代方案。

研究任务生成规则（写入 research.md 的“任务清单”并编号）：

```text
对于技术背景中的每个未知项：
  任务："针对 {feature context} 研究 {unknown}"
对于每个技术选择/依赖项：
  任务："查找 {domain} 中 {tech} 的最佳实践"
对于每个集成点：
  任务："梳理 {systemA} ↔ {systemB} 的集成模式与失败处理"
```

> 建议在 research.md 里保留“未知项 → 研究任务编号”的映射表，避免漏项与重复。

### 4) 分发研究 Agent 并行调研（强烈建议）

把第 3 步生成的任务按“可并行、低耦合”原则分发给多个研究 Agent（每个 Agent 对应 1 个任务或 1 组强相关任务），产出可引用的结论要点与证据入口。  
分发时要给足上下文：feature 背景、约束、现状证据入口（solution.md 的段落/链接）、以及需要回答的明确问题清单。

**每个研究任务的最小产出要求：**

- **Decision**：最终选择了什么（或“暂不决策/不适用”的明确结论）
- **Rationale**：为什么这么选（结合项目约束/证据/权衡）
- **Alternatives considered**：还评估了什么、为什么不选
- **Evidence / References**：证据入口（文档、代码、标准、历史事故、压测/PoC 结果等）

### 5) 编写 `{FEATURE_DIR}/design/research.md`（最小结构）

**必须使用最小化模板**生成 research.md（避免结构漂移）：

1) 复制 `<本SKILL.md目录>/assets/research-template.md` 的内容  
2) 粘贴到 `{FEATURE_DIR}/design/research.md`  
3) 按模板把占位符补齐（尤其是“研究任务 → 结论（Decision/Rationale/Alternatives）”必须完整）

写作约束：

- 只保留支撑 D2 决策的最小信息
- 所有 `NEEDS CLARIFICATION` 必须在“研究任务”中出现，并在对应小节被关闭（或进入验证清单并解释原因）
- 每个研究任务小节必须包含 **Decision / Rationale / Alternatives considered**
- 不要新增“待确认问题/TODO”章节

### 6) 把“未关闭项”落到“风险与验证清单”（必要兜底）

对仍无法在本轮关闭的未知项（例如需要 PoC、访问权限、外部确认、压测窗口等），必须转入“风险与验证清单”，并明确：

- **验证信号**：看到什么算成立/不成立
- **方法**：怎么验证（调研/访谈/实验/压测/PoC/演练/数据回放）
- **Owner / 截止**：谁负责，什么时候前必须拿到信号
- **触发动作**：成立/不成立分别怎么做（分支动作）

### 7) D1 输出后的衔接（给 D2 可直接引用的输入）

在 research.md 里确保以下内容可被 D2 直接引用：

- TL;DR 中的推荐方向是“机制级一句话”，而非实现步骤
 - 每个关键结论都能追溯到：`solution.md`、contracts/ADR 索引、研究任务编号或验证清单条目编号
 - 研究任务结论可直接映射到 D2 的决策章节（Decision/Rationale/Alternatives 结构可复用）
 - 验证清单可直接映射到 D2 的“风险与验证清单”（Owner/截止/动作不丢失）

完成后：**立即调用** `using-aisdlc` 路由下一步（通常进入 D2：`spec-design`）。

## 完成后输出与自动路由（必须执行）

`research.md` 落盘后，**必须**完成以下动作（按顺序，不可省略）：

1. **输出 ROUTER_SUMMARY**（YAML 形态，供 Router 决策）：
```yaml
ROUTER_SUMMARY:
  stage: D1
  artifacts:
    - "{FEATURE_DIR}/design/research.md"
  needs_human_review: true
  blocked: false
  block_reason: ""
  notes: "research 结论建议评审；通常下一步进入 D2（spec-design）"
```

2. **立即执行 `using-aisdlc`**：将上述 `ROUTER_SUMMARY` 作为路由输入传递给 using-aisdlc，由 Router 判定下一步并**自动推进**（无需等待用户说「继续」）。  
   - 若 Router 判定可自动续跑：在同一轮对话内继续执行下一步 worker skill（如 D2 等）
   - 若 Router 触发硬中断：停下并输出阻断原因、需要的输入、候选下一步

3. **对话输出**：在调用 using-aisdlc 前，可简短说明「本阶段产物已落盘，正在调用 using-aisdlc 路由下一步。」

## 红旗（出现任一即停止并纠偏）

- 没有 `FEATURE_DIR=...` 就开始写/改 `design/research.md`
- 缺 `requirements/solution.md` 仍继续写 research（=脑补）
- 出现“待确认问题清单 / TODO”，但没有研究任务与 Decision/Rationale/Alternatives（或没有验证方式/Owner/截止/动作）
- research.md 变成实现文档：字段/DDL/迁移脚本/任务拆分
- TL;DR 超过 7 行或全是背景，没有“最大风险 + 推荐方向”

## 压力下的反合理化（常见借口 → 对应动作）

| 常见借口 | 对应规则 / 动作 |
|---|---|
| “先写到仓库根目录，回头再挪到 spec 里” | 禁止猜路径：先 `spec-context` 拿到 `FEATURE_DIR`，否则停止 |
| “没有 solution.md 也能先 research，缺的后补” | 禁止脑补：缺 `solution.md` 直接停止，先回到 R1 补齐 SSOT |
| “来不及写验证清单，先列 TODO” | TODO 违规：把每条 TODO 改写为验证清单（含 Owner/截止/信号/动作） |
| “PM 要求写细（字段/DDL/脚本）给开发” | 拒绝混层：research 只写结论/证据/验证；在 research 里写“需要更新的 `project/contracts/` / `project/adr/` 入口 + 要点”，不在 D1 写字段/DDL/脚本 |
| “我已经写了很多实现草稿，不想浪费” | 沉没成本无效：把草稿迁出 research；research 正文只保留可引用结论与取舍依据 |

## 常见错误（以及修复）

- **错误**：research 写成百科背景，缺少可执行验证。  
  **修复**：压缩背景到“决策所需最小信息”，把未知全部转为验证清单。
- **错误**：把未知留成“待确认问题清单”。  
  **修复**：用“风险/假设 → 验证方式 → 信号 → Owner/截止 → 动作”改写，并编号。
- **错误**：把接口字段/表结构写进 research，导致 D2 难以维护。  
  **修复**：research 仅写“对外承诺要点 + 追溯链接（`project/contracts/` / `project/adr/` 入口）”，字段/DDL/脚本留给 D2 或 implementation。

