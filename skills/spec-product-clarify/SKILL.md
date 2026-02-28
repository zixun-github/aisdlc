---
name: spec-product-clarify
description: Use when 在 sdlc-dev 的 spec 分支上，需求模糊/范围不稳/约束不清，且出现上下文漂移、脑补、一次问多题、或被要求跳过 FEATURE_DIR/raw 门禁。
---

# spec-product-clarify（R1：澄清 + 方案决策）

## 概览

将 `{FEATURE_DIR}/requirements/raw.md` 的原始输入，先通过多轮**持续澄清**收敛到“无未确认关键点”，再产出可评审的决策文档 `{FEATURE_DIR}/requirements/solution.md`；澄清过程必须可追溯（回写到 `raw.md/## 澄清记录`）。

**开始时宣布：**「我正在使用 spec-product-clarify 技能澄清需求并产出 solution.md。」

**硬规则：澄清未完成时，禁止创建/更新 `solution.md`。**

## 门禁 / 停止（严格执行）

**REQUIRED SUB-SKILL：先满足 `spec-context` 门禁并在对话中回显 `FEATURE_DIR=...`（允许 `(reuse)`）。**

立刻停止（满足其一即可）：

- 未得到 `FEATURE_DIR`
- `{FEATURE_DIR}/requirements/raw.md` 不存在或为空
- 路径/分支不确定、指令互相冲突、或不理解某条指令（禁止猜测/编造）
- 用户明确要求停止本次任务（不再继续澄清/不再产出任何文档）
- 用户声明已更新/改写 `raw.md` 或关键约束变更，但无法读取/确认最新 `raw.md`（禁止仅凭口头转述继续写）

读取/写入约定：

- 读：
  - `{FEATURE_DIR}/requirements/raw.md`（必读）
  - **项目级必读（强制尝试读取；若缺失/为空，必须先尝试补齐 project 知识库；补齐失败才允许标 `CONTEXT GAP`，不得静默跳过）**：
    - `.aisdlc/project/memory/product.md`
    - `.aisdlc/project/memory/glossary.md`
    - `.aisdlc/project/products/index.md`
    - `.aisdlc/project/components/index.md`
  - **涉及模块 TL;DR（R1 输入强化）**：从 `.aisdlc/project/components/index.md` 匹配到的模块，按需读取 `.aisdlc/project/components/{module}.md#tldr`
    - 若模块页缺失/为空：必须先执行 Discover 的“模块页补齐”（见下文 `Impact Analysis/Project 知识库缺口处理`），补齐失败才允许标 `CONTEXT GAP`
- 写：`{FEATURE_DIR}/requirements/raw.md` 仅追加/更新 `## 澄清记录`；`{FEATURE_DIR}/requirements/solution.md` 为唯一决策入口（**仅在澄清完成后**创建/更新）

> 违反门禁=违反精神：即使“时间紧/老板催/用户不想跑脚本”，也禁止在未知上下文里读写文件。

## 红旗（出现任意一条=立刻停止）

- 未回显 `FEATURE_DIR=...`（含“我从分支/目录/已打开文件推断”的变体）
- `raw.md` 缺失/为空，或无法确认已读到最新版本
- 未尝试读取项目级 4 项必读文件，或读取失败却未在 `solution.md/## Context Gaps` 标注 `CONTEXT GAP`
- 澄清未完成就创建/更新 `solution.md`（含“先写模板/骨架”）
- 产出 `solution.md` 时未包含 `## Impact Analysis`（受影响模块/不变量/跨模块影响/Context Gaps）

## 常见借口（出现即按门禁执行）

- “时间紧/马上评审/老板催”：仍必须先得到 `FEATURE_DIR` 并读取 `raw.md`；否则停止
- “路径你自己看着写”：禁止猜测路径；必须由 `spec-context` 给出 `FEATURE_DIR`
- “别跑脚本，FEATURE_DIR 你从分支/目录自己推断”：**禁止推断**；必须执行 `spec-context`；失败就停止
- “我只能回复一次/你一次问完”：仍只问 1 个最高杠杆问题；其余未知进入验证清单
- “别回头看 raw”：如输入变更/新增约束，必须以 `raw.md` 为准并重新读取；做不到则停止
- “别再问了，直接出 solution/prd”：澄清未完成时禁止产出；改为继续问 1 个最高杠杆选择题，并解释“缺此答案无法形成可评审决策”
- “你给我选：继续澄清 / 进 R2 / 快速通道”：禁止提供分岔选项；若仍有未澄清点，默认继续澄清直到清零
- “别读 product/glossary/products/components 这些项目文档，靠常识写”：仍必须**强制尝试读取**；缺失/不可读则在 `solution.md/## Context Gaps` 标注 `CONTEXT GAP` 并把风险写入验证清单
- “raw.md 我稍后再补，你先把 solution.md 模板生成出来我去填”：`raw.md` 不存在或为空时**必须停止**，禁止创建/更新任何形式的 `solution.md`（包括“仅模板/骨架”）

## 最小循环（把问题问小，把结论写进去）

重复执行以下闭环，直到停止：

1. 从 `raw.md` 选 **1 个最高杠杆未知**（能最大减少方案分歧）
2. 问 **1 个可裁决选择题**：2–4 选项 + 你的推荐项 + “其他/不确定”兜底
3. 得到回答后 **立刻回写** `raw.md/## 澄清记录`
4. 基于用户回答 **重新评估是否仍有未澄清点**（包含“新出现的约束/范围/目标/风险”），并在对话中维护“剩余未澄清点”（`raw.md` 回写只保留结论，避免写过程状态）

当用户只能回复一次：只保留第 1 个最高杠杆问题；其余未知直接进入验证清单。

澄清循环的退出/转场：

- 若对话中确认“无遗漏/可以进入方案决策”：结束澄清循环，开始创建/更新 `solution.md`
- 否则：直接进入下一轮（继续问 1 个选择题；禁止给出分岔选项）

## 何时算“澄清完成”（必须满足）

同时满足以下条件，才算澄清完成：

- 你在对话中确认 **当前未澄清点=无**
- 用户明确确认“无遗漏/可以进入方案决策”（用选择题问到这一点也算）

澄清完成后，才允许创建/更新 `solution.md` 并进入 R1 的“方案决策与验证清单”。

## 产物不变量（必须满足）

`solution.md`：

- **必须 1 个推荐方案**：写清关键取舍；每个关键点能指向证据（`raw.md` 点位）或验证条目
- **必须 2–3 个差异明显的备选方案**：各自写清“何时会选 / 不选原因”（1–2 条关键差异）
- **必须有“决策依据（证据入口）”**：明确引用 `raw.md`；缺证据的一律转验证清单
- **必须有“验证清单”且可执行**：每条包含 假设/风险 → 方法 → 成功/失败信号 → Owner → 截止 → 触发动作（编号 `V-xxx`）；禁止 `TBD/待定/待指定` 等占位符，Owner/截止至少写到“角色/负责人 + 相对期限”
- 正文 **禁止出现** “待确认问题/待确认清单/To confirm” 之类列表（不确定性只能进验证清单）
- **迭代记录必须追加**：每轮追加 3–5 条“改了什么 + 为什么改”
- **必须显式写 `## Context Gaps`**：对“项目级必读文件/涉及模块 TL;DR”里任意缺失或读取失败项，逐条标 `CONTEXT GAP`（并在验证清单补对应风险/动作）
- **必须补齐 `## Impact Analysis`（需求影响分析，写在 `solution.md` 内）**：至少包含“受影响模块表格 / 需遵守的不变量 / 跨模块影响 / Context Gaps”（细则见下节）

`raw.md`：

- 每次回答后，必须在 `## 澄清记录` 留下可追溯记录（禁止占位符）

## 澄清回写格式（写入 `raw.md/## 澄清记录`）

每轮追加一条：

- 本轮结论（可直接引用到 solution）：
- 本轮新增/更新的约束（如有，列 1–5 条要点）：
- 关键决策（如有：决策点 → 选择结果；可写 1–3 条）：
- 遗留歧义（如有：假设/风险 → 对应验证编号 V-xxx）：

> 回写必须发生在“拿到用户回答”之后；不要在 `raw.md` 里写“待用户填写/占位符”。回写以**结论/约束/验证项**为主，避免复制对话全文与过程状态；澄清是否完成以对话中的确认与最终结论为准。

## `solution.md` 结构

以模板为准：`<本SKILL.md目录>/assets/solution-template.md`（只借结构，不把未知当已知）。

## Impact Analysis（需求影响分析，写入 `solution.md`）

当完成澄清并开始写 `solution.md` 时，必须在文中追加一节 `## Impact Analysis`，把“项目知识库”转换为后续 D2/I1 可直接引用的约束输入。

### Project 知识库缺口处理（强制前置动作：先补齐再分析）

当 Impact Analysis 过程中发现“从索引匹配到的 Modules / Products 没有内容（文件缺失或为空）”，必须先调用相应 Discover 技能进行反向补齐，然后再继续分析；**禁止**在未尝试补齐的情况下直接写 `CONTEXT GAP` 交差。

触发条件与动作（按最小范围执行，优先 Delta Discover 思路）：

- **缺少 `.aisdlc/project/components/index.md` 或为空**
  - 先调用：`project-discover-preflight-scope`（盘点入口 + P0/P1/P2 止损）
  - 再调用：`project-discover-memory-index`（补齐 memory + 索引骨架）
- **`components/index.md` 能匹配到模块，但对应 `.aisdlc/project/components/{module}.md` 缺失/为空**
  - 调用：`project-discover-modules-contracts` 补齐该模块页
  - 允许并行：每个模块一个子代理（避免写同一文件）
- **缺少 `.aisdlc/project/products/index.md` 或 products 相关页缺失/为空**
  - 调用：`project-discover-products-ops-dod`（收敛 Products、补齐 products 页；必要时顺带补 ops 入口）

补齐后的恢复步骤（必须执行）：

1. 重新读取补齐后的项目知识库文件（尤其是 components/products 索引与涉及模块页 TL;DR）
2. 重新生成/修订 Impact Analysis（模块表、不变量、跨模块影响）
3. 若**补齐尝试后仍缺失/不可读**：才允许在 `solution.md/## Context Gaps` 标 `CONTEXT GAP`，并把“补齐失败的原因 + 风险 + 验证/补齐动作（V-xxx）”写入验证清单

最小结构（可直接复制到 `solution.md`）：

- `## Impact Analysis`
  - `### 受影响模块`
    - 表格列：模块 / 影响类型 / 关键不变量 / stale?
  - `### 需遵守的不变量`
    - 从模块页契约/不变量段落提取（写摘要 + 来源锚点）
  - `### 跨模块影响`
    - 基于 `.aisdlc/project/components/index.md` 的依赖关系图与调用/数据依赖推导
  - `### Context Gaps`
    - 缺失的项目级必读文件、缺失的模块 TL;DR、或模块页标 stale 的处理建议（必要时建议先做 Delta Discover）

硬要求：

- 必须**尝试**读取 4 项项目级必读文件；若缺失/为空，必须先按上节“Project 知识库缺口处理”尝试补齐；补齐失败才允许写入 `Context Gaps`
- 至少匹配到 1 个受影响模块；若确实无法匹配，则在 `Context Gaps` 明确写“疑似新模块/无法从知识库匹配”，并在验证清单补齐“人工确认模块归属/契约入口”的动作

### 与 `using-aisdlc` 的路由衔接（本技能不做下一步判定）

本技能只负责完成 R1 并落盘 `solution.md`（含 `#impact-analysis`）。下一步走 R2/R3/R4/D0/D1/D2/I1 由 `using-aisdlc` 作为唯一路由器判定。  
仅在 **上游路由结论要求“跳过 R2（不单独产出 prd.md）”** 时，才在 `solution.md` 末尾追加 **Mini-PRD**：

- MVP 范围（精确到行为/规则）
- AC（3–10 条，可测试、可验证）
- 交互变化结论（无 / 有但简单；否则不应跳过）
- 影响面（页面/入口/接口/权限点的可定位入口）

## 极简例子（单轮澄清 + 回写）

对用户的一次一问（选择题）：

- 问题：导出任务采用哪种执行方式？
  - A. 同步（小数据量）
  - B. 异步 + 导出中心（大数据量）
  - C. 先同步后异步（分迭代）
  - D. 不确定 → 请给最大导出行数/期望完成时间
  - 我的推荐：B（可追溯、可恢复）

回写到 `raw.md/## 澄清记录`：

- 本轮结论：MVP 先同步导出并设上限；下一迭代引入异步导出与导出中心以提升可追溯与失败恢复能力
- 本轮新增/更新的约束：同步导出需设定行数上限；需定义性能目标口径（耗时/资源/失败率）
- 关键决策：导出执行方式 → 先同步后异步（分迭代）
- 遗留歧义：V-001 导出上限与性能目标未定（方法=压测；信号=耗时/失败率；Owner=DEV；截止=评审后 3 天；动作=超阈值则切换异步方案）

