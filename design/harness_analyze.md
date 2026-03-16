# sdlc-dev × Harness Engineering：现状审计与优化路线图

> 日期：2026-03-16
> 背景：Harness Engineering 是 2026 年最热门的 AI 工程范式。本文档对标该框架，对 sdlc-dev 项目进行成熟度审计，并给出分阶段优化路线图。

---

## 一、Harness Engineering 核心框架

Harness Engineering 的核心命题：**模型不是瓶颈，围绕模型的系统才是**。

- LangChain 仅改 harness（不换模型）就将 Terminal Bench 排名从 Top 30 跳到 Top 5
- OpenAI Codex 团队用 harness 让 AI 写出 100 万行生产代码，零手写

### 四大支柱

| 支柱 | 核心问题 | 手段 |
|------|---------|------|
| **Inform（告知）** | Agent 能看到什么？ | Context engineering、仓库即 SSOT、动态上下文映射 |
| **Constrain（约束）** | Agent 能做什么？ | 架构边界、依赖分层、工具白名单、结构性测试 |
| **Verify（验证）** | Agent 做对了吗？ | 自验证循环、CI 门禁、pre-completion checklist |
| **Correct（纠偏）** | Agent 做错了怎么办？ | 反馈回路、loop detection、自修复、熵管理 |

### 与相邻概念的关系

| 概念 | 范围 | 聚焦 |
|------|------|------|
| Prompt Engineering | 单次交互 | 如何提问 |
| Context Engineering | 模型上下文窗口 | 模型看到什么信息 |
| **Harness Engineering** | **整个 Agent 系统** | **环境、约束、反馈、生命周期** |
| Agent Engineering | Agent 内部架构 | Agent 内部设计与路由 |
| Platform Engineering | 基础设施 | 部署、扩缩、运维 |

---

## 二、本项目现状对标（成熟度审计）

### 2.1 已做得非常好的部分（行业领先）

本项目在 Harness Engineering 的多个维度上**已经走在了前面**：

| 维度 | 本项目现状 | 对标评价 |
|------|-----------|---------|
| **Router/Worker 分离** | `using-aisdlc` 是唯一路由器，Worker 不得自主分流 | 完全对齐"约束"支柱，比大多数框架更严格 |
| **强制上下文门禁** | `spec-context` 必须先跑、回显 `FEATURE_DIR`，失败即停 | 优秀的 Context Engineering 实践 |
| **一次一阶段** | 禁止 PRD+原型+Demo 一次性糅合 | 精准的 blast radius 控制 |
| **SSOT 双层架构** | project 级（长期）+ spec pack 级（需求级） | 比单层 AGENTS.md 先进得多 |
| **模板驱动产出** | 每个阶段有明确模板 | 对齐"Inform"支柱——让 Agent 知道输出什么格式 |
| **ROUTER_SUMMARY 协议** | Worker 结束后输出结构化 YAML 供路由决策 | 对齐 Middleware 模式，是 harness loop 的雏形 |
| **D0 强制门禁** | R→I 过渡必须经过 D0 判定 | 对齐"Manual Review Gate"（CNCF 第一支柱） |
| **子智能体两阶段审查** | 先规格符合性、再代码质量 | 对齐"Verify"支柱 |

**结论：本项目在 Constrain 和 Inform 两个支柱上已达到 Level 2（Team Harness）水平。**

### 2.2 结构性缺口分析

#### 缺口 1：约束执行层——"纸面约束"而非"机械强制"

**现状**：所有门禁/约束（spec-context 必须先跑、禁止猜测 FEATURE_DIR、一次一阶段等）都是通过 **prompt 指令**实施的——本质是"建议"而非"强制"。模型升级、上下文截断、压力下的用户催促都可能绕过。

**Harness Engineering 的要求**：

> "Instead of telling the agent 'write good code,' you mechanically enforce what good code looks like."
> —— 约束不是建议，必须通过结构性测试和 CI 校验来强制执行。

**缺口评估**：🔴 高优先级。当前所有约束均依赖 LLM 自律，没有代码级拦截。

#### 缺口 2：自验证循环——缺少 Pre-completion Checklist

**现状**：验证集中在最后的 `finishing-development`（测试/lint/build 全绿才行）。但从 R1 到 I2 的中间阶段，**没有自动化的产物一致性检查**。例如：

- `prd.md` 引用的 `solution.md` 章节是否真实存在？
- `plan.md` 任务中引用的文件路径是否有效？
- `design.md` 的 Impact Analysis 是否覆盖了 `solution.md#impact-analysis` 的所有条目？

**Harness Engineering 的要求**：LangChain 的 Pre-completion Checklist Middleware 在每次输出前执行自检，将错误率降低了 13.7 个百分点。

**缺口评估**：🔴 高优先级。中间阶段的产物质量只能靠人工评审发现问题。

#### 缺口 3：反馈回路——无 Loop Detection 与自修复

**现状**：`spec-execute` 的"遇阻塞即停"策略是一个**断路器（Circuit Breaker）**，但不是一个反馈回路。系统缺少：

- **Loop Detection**：Agent 反复编辑同一文件 / 反复失败同一测试时的自动检测
- **经验回流**：过去 Spec Pack 的成功/失败模式没有沉淀为可检索的知识
- **降级策略**：Agent 卡住时除了"停止"以外没有自动降级方案

**Harness Engineering 的要求**：LangChain 的 Loop Detection Middleware 跟踪重复的文件编辑，防止"doom loop"。CNCF 的"Safety Nets"支柱要求自动恢复而非只是停下。

**缺口评估**：🟡 中高优先级。

#### 缺口 4：可观测性——Zero Observability

**现状**：没有任何层面的遥测/度量：

- 每个 skill 的调用频次、耗时、成功率
- Token 消耗分布（哪个阶段消耗最多？）
- 常见阻塞原因的统计分析
- `ROUTER_SUMMARY` 的历史流转记录

**Harness Engineering 的要求**：

> "Knowing an agent 'succeeded' isn't enough. You need to see every tool call, every token spent, every guardrail check — per iteration."

**缺口评估**：🟡 中优先级。当前无法做数据驱动的 harness 优化。

#### 缺口 5：熵管理——无定期清理机制

**现状**：`project-discover` 有 stale 检测，`spec-merge-back` 管理知识晋升。但缺少：

- 跨 skill 的模板一致性检查（模板格式漂移）
- 产物质量衰减检测（早期 Spec Pack 的 solution.md 质量标准是否还适用？）
- 死路径清理（已废弃但未 abandon 的 Spec Pack）
- skill 间命名规范一致性扫描

**Harness Engineering 的要求**：

> "Over time, AI-generated codebases accumulate entropy... Harness engineering addresses this with periodic cleanup agents."

**缺口评估**：🟡 中优先级。当前熵管理是被动的而非主动的。

#### 缺口 6：Golden Path——缺少"开箱即用"配置

**现状**：新项目接入需要手动理解整个 skill 体系、手动配置 `.cursor/rules/`、手动执行 `project-discover`。没有：

- 一键初始化脚本（新项目 → 开箱即用的 harness 配置）
- 预置的"快速闭环" vs "完整流程"配置包
- 团队级的 harness 配置继承机制

**Harness Engineering 的要求**：CNCF 的"Golden Paths"支柱——预审批的配置模板，团队继承而非从零发明。

**缺口评估**：🟡 中优先级。影响推广效率。

---

## 三、优化路线图（三阶段）

### Phase 1：机械强制层（1-2 周）—— "从建议到强制"

**目标**：将核心约束从"prompt 建议"升级为"代码强制"，堵住最大的可靠性风险。

| 编号 | 优化项 | 具体方案 | 产出 |
|------|--------|---------|------|
| P1-1 | **Artifact Validator 脚本** | 新增 `scripts/validate-artifact.ps1`，对每个阶段的产物执行结构校验：必填章节是否存在、交叉引用是否有效（如 prd.md 引用的 solution.md 锚点是否存在）、模板必填字段是否留空。skill 落盘后自动调用。 | `scripts/validate-artifact.ps1` |
| P1-2 | **Pre-completion Checklist Skill** | 新增 `skills/spec-precheck/`，每个 Worker 落盘后、输出 ROUTER_SUMMARY 前自动执行。检查项：产物存在性、模板符合度、交叉引用完整性、ROUTER_SUMMARY 字段完整性。 | `skills/spec-precheck/SKILL.md` |
| P1-3 | **Loop Detection 机制** | 在 `spec-execute` 中增加"Doom Loop Guard"：跟踪单文件编辑次数（>3 次同文件）和测试重试次数（>2 次同测试失败），触发时自动停止并输出诊断信息。 | `spec-execute/SKILL.md` 更新 |
| P1-4 | **ROUTER_SUMMARY Schema 校验** | 新增 JSON Schema 定义 ROUTER_SUMMARY 的合法值域，Router 收到不合规 SUMMARY 时拒绝路由。 | `skills/using-aisdlc/assets/router-summary-schema.yaml` |

### Phase 2：可观测性与反馈回路（2-4 周）—— "从黑盒到透明"

**目标**：建立迭代级的可观测性，使 harness 优化可以数据驱动。

| 编号 | 优化项 | 具体方案 | 产出 |
|------|--------|---------|------|
| P2-1 | **Spec Pack 执行日志** | 每个 Spec Pack 目录下新增 `_harness/trace.jsonl`，记录每次 skill 调用的时间戳、阶段、产物路径、阻塞原因（如有）。由 Router 在每次路由决策后自动追加。 | `_harness/trace.jsonl` 协议定义 |
| P2-2 | **阻塞原因分类体系** | 定义标准化的 `block_reason` 分类编码（如 `CTX_MISSING`、`ARTIFACT_INVALID`、`TEST_FAIL`、`NEEDS_HUMAN`），替代当前的自由文本。 | `block_reason` 枚举定义 |
| P2-3 | **Spec Pack 回顾报告** | 新增 `skills/spec-retrospective/`，在 Spec Pack 合并后自动生成回顾报告：总耗时、各阶段耗时、阻塞次数、返工次数、澄清轮数。沉淀到 `.aisdlc/project/retrospectives/`。 | `skills/spec-retrospective/SKILL.md` |
| P2-4 | **经验知识库** | 基于回顾报告，累积"常见坑"与"最佳实践"到 `.aisdlc/project/memory/lessons.md`，供后续 Spec Pack 的 spec-plan 和 spec-design 主动消费。 | `memory/lessons.md` 协议 |

### Phase 3：Golden Path 与熵管理（4-8 周）—— "从工具到平台"

**目标**：降低接入门槛，建立自治的熵管理体系，使 harness 可自演进。

| 编号 | 优化项 | 具体方案 | 产出 |
|------|--------|---------|------|
| P3-1 | **项目初始化 Golden Path** | 新增 `scripts/harness-init.ps1`，一键为新项目生成：`.cursor/rules/`、`.aisdlc/project/memory/` 骨架、pre-commit hooks、README 中的 harness 说明。支持 `minimal` 与 `full` 两种配置档位。 | `scripts/harness-init.ps1` |
| P3-2 | **定期熵扫描 Skill** | 新增 `skills/harness-entropy-scan/`，检查：模板格式漂移（模板 hash 与产物结构对比）、死 Spec Pack（超过 N 天未推进）、skill 间命名不一致、project SSOT 过期条目。可手动触发或建议定期执行。 | `skills/harness-entropy-scan/SKILL.md` |
| P3-3 | **Harness 配置版本化** | 将 harness 的关键参数（批次大小、loop detection 阈值、自动推进策略等）抽取到 `.aisdlc/harness-config.yaml`，支持 A/B 测试不同配置。 | `harness-config.yaml` Schema |
| P3-4 | **Reasoning Sandwich 模式** | 在 Router 层引入"推理三明治"策略：规划/验证阶段建议使用高推理模型，实现阶段允许使用快速模型。在 `using-aisdlc` 的路由规则中增加模型选择建议。 | Router 路由规则更新 |
| P3-5 | **Rippable Harness 审查** | 定期审查哪些 harness 组件可以因模型能力提升而移除（如模型原生支持更好的上下文管理时，spec-context 的某些检查可简化）。 | 季度审查清单模板 |

---

## 四、优先级矩阵

```
影响力 ↑
高 │  P1-1 ●  P1-2 ●           P2-3 ●
   │                    P2-1 ●
   │  P1-3 ●  P1-4 ●   P2-4 ●     P3-1 ●
   │                    P2-2 ●
低 │                              P3-2 ● P3-3 ● P3-4 ● P3-5 ●
   └──────────────────────────────────────────→ 实施难度
     低                                     高
```

**建议启动顺序**：P1-1 → P1-2 → P1-3 → P1-4 → P2-1 → P2-3 → P3-1

---

## 五、本项目的独特优势与差异化定位

值得强调的是，sdlc-dev 并非从零开始——相比行业现状，有几个**独特的结构性优势**值得保持和强化：

1. **双层 SSOT 架构**：比 OpenAI/Stripe 的单层 AGENTS.md 更先进，天然支持"项目级知识"与"需求级上下文"的隔离和组合
2. **阶段性门禁链**：R0→R1→R2→...→Finish 的有序推进比"给 Agent 一个大任务让它自由发挥"可靠得多
3. **Router/Worker 分离**：这正是 LangChain Middleware 架构的更高级形式——不仅是中间件，而是完整的控制面
4. **Spec as Code**：把需求管理当代码管理，天然获得版本控制、diff、回滚能力

**定位建议**：本项目应定位为 **"AI SDLC 领域的 Harness Engineering 参考实现"**——不仅是一个工具集，而是一个证明"结构化 harness 可以让 AI Agent 可靠地走完完整 SDLC"的活体案例。

---

## 六、成熟度总览

| 维度 | 当前成熟度 | 目标成熟度 | 核心差距 |
|------|-----------|-----------|---------|
| **Inform（告知）** | Level 2 | Level 3 | 缺少动态上下文映射、经验知识库 |
| **Constrain（约束）** | Level 2（prompt 级） | Level 3（代码级） | 约束未机械化强制 |
| **Verify（验证）** | Level 1.5 | Level 3 | 缺少中间阶段自验证、产物一致性检查 |
| **Correct（纠偏）** | Level 1 | Level 2.5 | 缺少 loop detection、自修复、经验回流 |
| **Observe（观测）** | Level 0 | Level 2 | 零遥测，无法数据驱动优化 |
| **Entropy（熵管理）** | Level 1 | Level 2 | 被动清理，缺少主动扫描 |

---

## 七、参考资料

- [Harness Engineering: The Complete Guide (NxCode, 2026-03)](https://www.nxcode.io/resources/news/harness-engineering-complete-guide-ai-agent-codex-2026)
- [Agent Harnesses: Why 2026 Isn't About More Agents (htek.dev)](https://htek.dev/articles/agent-harnesses-controlling-ai-agents-2026/)
- [Harness Engineering 官方站点](https://harness-engineering.ai/)
- [Beyond Prompts and Context: Harness Engineering for AI Agents (MadPlay)](https://madplay.github.io/en/post/harness-engineering)
- [CNCF 2026 Forecast: The Four Pillars of Platform Control](https://www.cncf.io/blog/2026/01/23/the-autonomous-enterprise-and-the-four-pillars-of-platform-control-2026-forecast)
