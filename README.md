---
markdown-sharing:
  uri: 9ad9e4f3-f0ac-40f2-ad7d-e4676a39dafe
---


# sdlc-dev

本仓库提供一套 **Spec 级**工作流与技能集，围绕 **双层 SSOT（项目级 SSOT + 需求级 Spec Pack）**、**Spec as Code**、**渐进式披露**，把一个需求从“原始输入”推进到“可评审的决策（可选）”与“可直接执行的实现计划 + 分批执行”。

---

### 安装 / 更新

```

# powershell
npx skills add https://github.com/zixun-github/aisdlc --skill * --agent claude-code cursor --yes --copy --global

# bash
npx skills add https://github.com/zixun-github/aisdlc --skill '*' --agent claude-code cursor --yes --copy --global

```

### 最短的使用方式

```
# 开始新的需求或BUG修复(会自动创建开发分支)
/spec-init 输入新的需求内容...
# 创建执行计划
/spec-implementation-plan 
# 执行计划
/spec-implementation-execute
```

---
### 小需求（轻量）Spec Pack：最短闭环步骤（推荐）

适用于 **范围小、影响面可控、无明显交互不确定性** 的需求（例如：小修复、小增强、脚本/配置调整、一次性迁移）。目标是 **最小落盘 + 可追溯 + 可执行**，避免把小需求做成“重流程”。

- **步骤清单（从零到完成）**
  - **R0：初始化**：`spec-init` → 生成分支与 Spec Pack，并落盘 `raw.md`
  - **R1：最小澄清**：`spec-product-clarify` → 产出精简 `solution.md`（写清边界与验收）
    - 若需求已经清楚：也建议用极简方式补齐 `solution.md`，保证后续评审与回溯有锚点
  - **I1：实现计划**：`spec-implementation-plan` → 产出 `implementation/plan.md`
  - **I2：分批执行**：`spec-implementation-execute` → 按 `plan.md` 分批实现与最小验证，并回写审计信息
---

### 步骤速览（用途 & 输出）

> 下列步骤按“最短路径优先、按需扩展”组织：R0–R4 用于澄清与产品侧产物；D0–D2 为设计阶段（可整体跳过）；I1–I2 为实现阶段（必做）。

- **R0：`spec-init`（初始化新需求）**
  - **用途**：创建 Spec 工作空间（分支 + Spec Pack 目录），并把原始需求落盘为可追溯输入
  - **输出**：新分支 `{num}-{short-name}` + `.aisdlc/specs/{branch}/...` + `requirements/raw.md`

- **R1：`spec-product-clarify`（澄清 + 方案决策）**
  - **用途**：把 `raw.md` 的模糊需求收敛为可评审的推荐方案，并给出 2–3 个备选与验证清单
  - **输出**：`requirements/solution.md`

- **R2：`spec-product-prd`（可选：PRD/交付规格）**
  - **用途**：把 R1 的决策转为可交付、可验收、可测试的规格（范围/场景/AC/风险与依赖）
  - **输出**：`requirements/prd.md`

- **R3：`spec-product-prototype`（可选：原型说明）**
  - **用途**：当存在新增/变更交互或交互不够明确时，用任务流 + 页面结构 + 状态说明消除理解偏差
  - **输出**：`requirements/prototype.md`

- **R4：`spec-product-demo`（可选：可交互 Demo）**
  - **用途**：把 `prototype.md` 的页面清单与交互说明落地成可运行 Demo，用于走查/验证/对齐并支持回流
  - **输出**：Demo 工程目录（默认 `demo/prototypes/{CURRENT_BRANCH}/`）

- **D0–D2：设计阶段（整体可跳过）**
  - **D0（分流）**：判断是否跳过 design；若跳过，implementation 的 `plan.md` 必须补齐最小决策信息（目标/边界/约束/验收/验证清单）
  - **D1：`spec-design-research`（可选 research）**
    - **输出**：`design/research.md`
  - **D2：`spec-design`（RFC/Decision Doc；未跳过时必做）**
    - **输出**：`design/design.md`

- **I1–I2：实现阶段（必做）**
  - **I1：`spec-implementation-plan`（实现计划 / SSOT）**
    - **输出**：`implementation/plan.md`（唯一执行清单与状态 SSOT）
  - **I2：`spec-implementation-execute`（分批执行 + 回写审计）**
    - **输出**：代码与配置变更；并将任务状态/审计信息**只回写**到 `implementation/plan.md`

- **快捷方式**
  - 不确定下一步怎么选：using-aisdlc
  - 在 Cursor 中：本仓库内置规则 `.cursor/rules/using-aisdlc-first.mdc`，会在 Spec Pack 相关对话中强制优先使用 `using-aisdlc` 作为路由器，并要求先通过 `spec-context` 门禁再读写落盘文件。

---

### Spec Pack（你最终会落盘什么）

- **分支（上下文锚点）**：`{num}-{short-name}`
- **根目录（需求级 SSOT）**：`.aisdlc/specs/{num}-{short-name}/`
- **常用产物（按阶段渐进生成）**
  - **Clarify / requirements/**
    - `requirements/raw.md`：原始输入（证据入口）
    - `requirements/solution.md`：澄清 + 方案决策（需求侧 SSOT）
    - `requirements/prd.md`：（可选）交付规格（更细 AC/范围/依赖）
    - `requirements/prototype.md`：（可选）原型说明（任务流/页面/状态/AC 映射）
  - **Design / design/**（整体可跳过；未跳过时 `design.md` 为 SSOT）
    - `design/research.md`：（可选）调研结论（风险/假设 → 验证清单）
    - `design/design.md`：（可选）决策文档 / RFC（design 阶段 SSOT，写决策不写实现）
  - **Implementation / implementation/**
    - `implementation/plan.md`：实现计划（I1 必做；**唯一执行清单与状态 SSOT**，含任务 checkbox、步骤、最小验证、提交点与审计信息）
  - **Demo（可选）**
    - `demo/prototypes/{CURRENT_BRANCH}/...`：（可选）可交互 Demo（默认共享工程模式）

---

