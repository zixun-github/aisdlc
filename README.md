### sdlc-dev（AI SDLC / Spec Pack 技能集）

本仓库提供一套 **Spec 级**需求分析工作流（R0–R4）：把原始需求逐步收敛为可评审方案、可交付规格（可选）、交互原型（可选）与可交互 Demo（可选）。

---

### 安装 / 更新

```powershell
npx skills add https://github.com/zixun-github/aisdlc --skill * --agent claude-code --yes --copy
```
---

### Spec Pack（你最终会落盘什么）

- **分支**：`{num}-{short-name}`
- **目录**：`.aisdlc/specs/{num}-{short-name}/`
- **需求产物（按步骤逐步生成）**
  - `requirements/raw.md`：原始输入（证据入口）
  - `requirements/solution.md`：方案决策（唯一决策入口）
  - `requirements/prd.md`：（可选）交付规格
  - `requirements/prototype.md`：（可选）原型说明（任务流/页面/状态/AC 映射）
  - `demo/prototypes/{CURRENT_BRANCH}/...`：（可选）可交互 Demo（默认共享工程模式）

---

### 步骤速览（用途 & 输出）

- **R0：`spec-init`（初始化新需求）**
  - **用途**：创建新的 Spec 工作空间（分支 + Spec Pack 目录），把原始需求落盘成可追溯输入
  - **输出**：新分支 `{num}-{short-name}` + `.aisdlc/specs/{branch}/...` + `requirements/raw.md`

- **R1：`spec-product-clarify`（澄清 + 方案决策）**
  - **用途**：把 `raw.md` 的模糊需求收敛为可评审的推荐方案，并给出 2–3 个备选与验证清单
  - **输出**：`requirements/solution.md`（含推荐方案/备选方案/决策依据/验证清单）

- **R2：`spec-product-prd`（可选：PRD/交付规格）**
  - **用途**：把 R1 的决策转为可交付、可验收、可测试的规格（范围/场景/AC/风险与依赖）
  - **输出**：`requirements/prd.md`

- **R3：`spec-product-prototype`（可选：原型说明）**
  - **用途**：当存在新增/变更交互或交互不够明确时，用任务流 + 页面结构 + 状态说明消除理解偏差
  - **输出**：`requirements/prototype.md`

- **R4：`spec-product-demo`（可选：可交互 Demo）**
  - **用途**：把 `prototype.md` 的页面清单与交互说明落地成可运行 Demo，用于走查/验证/对齐并支持回流
  - **输出**：Demo 工程目录（默认 `demo/prototypes/{CURRENT_BRANCH}/`）

---

### 参考

- 端到端流程与落盘约定：`design/aisdlc_spec_product.md`
- 不确定下一步怎么选：`skills/using-aisdlc/SKILL.md`