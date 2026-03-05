---
name: spec-design
description: Use when 需要为某个 Spec Pack 产出 D2 决策文档（RFC/Decision Doc），且必须强制消费项目知识库与 `{FEATURE_DIR}/requirements/solution.md#impact-analysis`；适用于在时间/权威压力下容易只读索引、跳过受影响模块/ADR 全文、静默忽略缺失输入或不写 `CONTEXT GAP`、以及遗漏“与现有系统对齐”自检的情况。
---

# spec-design

## 概览

本技能是 **D2 worker skill**：只负责产出可评审的 **决策文档（Decision Doc / RFC）** 到 `{FEATURE_DIR}/design/design.md`。  
**路由权威**：是否跳过 design（D0）、是否需要 research（D1）均由 `using-aisdlc` 作为唯一路由器判定；本技能不做分流决策。  
核心原则：**门禁优先（spec-context）→ 强制消费影响分析与项目知识库 → 决策落盘（D2）**。在任何压力下都禁止猜路径、禁止在缺少 SSOT 时脑补推进。

**开始时宣布：**「我正在使用 spec-design 技能产出设计决策文档（design/design.md / RFC）。」

## 何时使用 / 不使用

- **使用时机**
  - 用户要求产出 `design/design.md`（RFC/Decision Doc），或“做设计再进入 implementation”。
  - 你被要求把接口字段/表结构/任务拆分塞进设计文档，担心文档分层被破坏。
- **不要用在**
  - 需求尚未完成 R1（没有 `requirements/solution.md`）：先完成需求澄清与方案决策（见 `spec-product-clarify`）。
  - 用户明确只要 implementation 计划与任务：直接走 implementation

## 快速参考

- **硬门禁（第一优先级）**：任何读写 `{FEATURE_DIR}/design/*.md` 之前，必须先执行 `spec-context` 获取上下文并回显 `FEATURE_DIR=...`（允许 `(reuse)`）；失败立刻停止。
- **D2 强制输入（第二优先级）**：D2 必须读取 `{FEATURE_DIR}/requirements/solution.md#impact-analysis`，并据此强制读取受影响模块组件页全文与相关 ADR 全文；读不到必须显式标注 `CONTEXT GAP`，不得静默跳过。
- **输出位置**
  - D2（必做，未跳过时）：`{FEATURE_DIR}/design/design.md`

- **最小化模板**
  - D2：`<本SKILL.md目录>/assets/design-template.md`（复制到 `{FEATURE_DIR}/design/design.md` 再填写）

> 提醒：出现“是否跳过 design / 是否需要 research”的讨论时，请回到 `using-aisdlc` 做路由判定；本技能只执行 D2。

## 实施步骤（Agent 行为规范）

### 0) 门禁（必须先过，否则停止）

**REQUIRED SUB-SKILL：正在执行 `spec-context` 获取上下文，并回显 `FEATURE_DIR=...`（允许 `(reuse)`）。**

- `spec-context` 失败 → **停止**

若上面报错 → **立刻停止**（不要生成/写任何 `design/*.md` 内容）。

### 1) 读取最小必要输入（缺失则停止）

- **必读（需求侧 SSOT）**：`{FEATURE_DIR}/requirements/solution.md`
- **必读（影响分析 SSOT）**：`{FEATURE_DIR}/requirements/solution.md#impact-analysis`（从中提取：受影响模块清单、需遵守的不变量、相关 ADR、跨模块影响）
- **按需**：`{FEATURE_DIR}/requirements/prd.md`、`{FEATURE_DIR}/requirements/prototype.md`
- **必读（项目级，强制）**：
  - `project/memory/*`（业务/技术/结构/术语）
  - `project/components/index.md`（跨模块依赖关系图/交互方式入口）
  - `project/adr/index.md`（ADR 索引）
  - 从影响分析得到的受影响模块：读取 `project/components/{module}.md` **全文**（包含 `## API Contract` / `## Data Contract` / `## State Machines & Domain Events` 等稳定锚点）
  - 从影响分析得到的相关 ADR：读取 `project/adr/{adr-id}.md` **全文**
- **若存在**：`{FEATURE_DIR}/design/research.md`、`{FEATURE_DIR}/design/design.md`

**停止条件（不得脑补继续）：**

- 找不到或无法读取 `requirements/solution.md`。
- 需求的 In/Out、验收口径、关键约束无法从输入追溯。

**硬要求（不得降级为“只读索引/只读一部分”）：**

- 受影响模块的组件页与相关 ADR **要么全文读取成功，要么在 `design/design.md` 中显式标注为 `CONTEXT GAP`**。
- **禁止**用“impact-analysis 的摘要/索引页”替代全文阅读，并宣称“已对齐/已合规”。
- 如果压力导致无法完成全文读取：必须在 D2 输出中把 DoD 标为未满足，并明确阻塞项（而不是“先勾选通过，后续再补”）。

### 2) D2：design（决策文档 / RFC）

#### 2.1 D2 的定位（写“决策”，不写“实现”）

- **只写**：为什么这样做、边界怎么裁切、方案与权衡、对外承诺要点、怎么验证、影响与迁移/回滚要点。
- **不写**：实现步骤、任务拆分、代码级细节、接口字段逐一罗列、DDL 细节。
  - 若必须对外承诺字段/兼容性：在本文写“要点 + 追溯链接”，细节下沉到 `project/contracts/` 或 ADR。
  - 若项目以组件页作为契约 SSOT：优先把细节下沉到对应 `project/components/{module}.md#api-contract/#data-contract`（与本仓库的 Discover 模块页结构对齐）。

#### 2.2 `design/design.md` 建议最小结构（模板）

**必须使用最小化模板**生成 design.md（避免结构漂移）：

1) 复制 `<本SKILL.md目录>/assets/design-template.md` 的内容  
2) 粘贴到 `{FEATURE_DIR}/design/design.md`  
3) 按模板把占位符补齐（尤其是 C4 L1–L3、备选方案、风险与验证清单、追溯链接）

> 写作约束：只保留支撑决策/验收/演进的最小信息；不要新增“待确认问题/TODO”章节；不要写实现细节/任务拆分/字段清单/DDL。

#### 2.3 D2-DoD（缺一不可）

- In/Out 明确，且能追溯到 `solution.md`
- 推荐方案用 C4 **L1+L2+L3** 说清楚，层次可追溯
- 关键决策说明“为什么选它/备选为何不选”
- **与现有系统的对齐已完成**（基于 `solution.md#impact-analysis`）：
  - 每个受影响模块：完成**契约兼容性声明**（兼容/扩展/破坏性变更），并引用对应组件页 `#api-contract` / `#data-contract` 的具体不变量
  - 每个相关 ADR：完成**ADR 合规声明**（遵守/需新增/需修改）
  - 对涉及的状态机/领域事件：完成**影响说明**（引用组件页 `## State Machines & Domain Events`）
  - 基于依赖关系图：完成**跨模块影响确认**
- 不确定性已收敛：未知全部进入“假设 + 验证清单”（Owner/截止/动作明确）

**DoD 判定规则（防止“拿 CONTEXT GAP 当完成”）：**

- 若任何受影响模块组件页或相关 ADR 出现 `CONTEXT GAP`，则“与现有系统的对齐已完成”这一项**不得勾选通过**；必须在 D2 中明确这是阻塞/风险，并给出补齐路径（读到全文/补齐知识库/新增 ADR）。

## 红旗（出现任一即停止并纠偏）

- 没有先拿到 `FEATURE_DIR=...` 就开始写 `design/*.md`
- 找不到 `requirements/solution.md` 还继续写设计（=脑补）
- 用“待确认问题清单 / TODO”悬空未知（应改为“假设 + 验证清单”）
- 把 D2 写成实现规格：任务拆分、实现步骤、字段/DDL 细节
- 缺少备选方案或缺少验证清单（导致无法评审/无法落地）
- 只读 `project/adr/index.md` / `project/components/index.md` 就宣称“已对齐现有系统”
- 只读部分受影响模块或只读部分 ADR，就宣称“已对齐/已合规”
- 用 impact-analysis 摘要替代组件页/ADR 全文，但未标注 `CONTEXT GAP`
- 把 `CONTEXT GAP` 当作“对齐已完成”的理由（这是 DoD 失败信号，不是通过信号）

## 压力下的反合理化（常见借口 → 对应动作）

| 常见借口 | 对应规则 / 动作 |
|---|---|
| “先随便写到 `design/design.md`，回头再挪” | **禁止猜路径**：先 `spec-context` 拿到 `FEATURE_DIR`；否则停止 |
| “信息不全也能先出初稿，后面再补” | **禁止脑补**：缺 `solution.md` 或不可追溯就停止；把未知改写为“假设 + 验证清单” |
| “主管/PM 说不要门禁/不要查文档” | 门禁是硬规则：`Get-SpecContext` 失败就停止；不因权威压力破例 |
| “为了开发快，把任务/DDL/字段都写进设计” | **拒绝混层**：D2 只写决策与对外承诺要点 + 追溯链接；细节进 contracts/ADR/implementation |
| “没时间做备选/验证清单” | 备选与验证是 D2-DoD：缺失会导致无法评审/返工；宁可缩短正文也不删 DoD 项 |
| “模块页/ADR 太长，先别看；用 impact-analysis 摘要就够了” | **禁止用摘要冒充对齐**：组件页与 ADR 要么全文读取，要么标注 `CONTEXT GAP`；且 DoD 的“与现有系统的对齐已完成”不得通过 |
| “受影响模块太多，只读前两个，其余以后再补” | **禁止部分对齐**：影响分析列出的受影响模块与 ADR 是强制输入；要么读全、要么把 DoD 标为未满足并明确阻塞（优先收敛需求/影响面，而不是偷读） |
| “我已经写了一半推荐方案了，现在再回头读会拖慢交付” | **沉没成本无效**：先补齐强制输入再写「与现有系统的对齐」；否则 RFC 不可评审、后续返工更大 |

## 常见错误（以及修复）

- **错误**：在压力下“先写了再说”，先生成文档再补输入。  
  **修复**：先执行 `spec-context` 获取上下文，并满足 `solution.md` 门禁；缺失就停止，写清楚阻塞项。
- **错误**：把 research 当成“查资料”，写了很多背景但没有验证清单。  
  **修复**：把未知全部转成“风险/假设 → 验证方式 → 信号 → Owner/截止/动作”。
- **错误**：PM 要求把任务/接口/表结构写进设计，于是混层。  
  **修复**：设计文档只保留“对外承诺要点 + 追溯链接”；实现细节移入 implementation 或 contracts/ADR。
- **错误**：只读索引（`components/index.md`、`adr/index.md` 或 impact-analysis 摘要），就写“已对齐/已合规”。  
  **修复**：对每个受影响模块与 ADR：必须全文读取并引用具体不变量/条款；读不到就写 `CONTEXT GAP`，且 DoD 不得通过。 

## 完成后输出与自动路由（必须执行）

`design.md` 落盘后，**必须**完成以下动作（按顺序，不可省略）：

1. **输出 ROUTER_SUMMARY**（YAML 形态，供 Router 决策）：
```yaml
ROUTER_SUMMARY:
  stage: D2
  artifacts:
    - "{FEATURE_DIR}/design/design.md"
  needs_human_review: true
  blocked: false
  block_reason: ""
  notes: "RFC 建议评审通过后再进入 I1（spec-plan）"
```

2. **立即执行 `using-aisdlc`**：将上述 `ROUTER_SUMMARY` 作为路由输入传递给 using-aisdlc，由 Router 判定下一步并**自动推进**（无需等待用户说「继续」）。  
   - 若 Router 判定可自动续跑：在同一轮对话内继续执行下一步 worker skill（如 I1 等）
   - 若 Router 触发硬中断：停下并输出阻断原因、需要的输入、候选下一步

3. **对话输出**：在调用 using-aisdlc 前，可简短说明「本阶段产物已落盘，正在调用 using-aisdlc 路由下一步。」

