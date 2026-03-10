---
name: spec-init
description: Use when 需要在本仓库的 AI SDLC 流程中初始化新的 Spec Pack（创建三位编号分支与 `.aisdlc/specs/{num}-{short-name}` 目录），或在执行 `spec-init` 时不确定输入解析、短名称规则、UTF-8 BOM 文件路径传参、脚本调用方式与输出物。
---

# spec-init

## 概览

`spec-init` 用于在本仓库里创建一个新的需求级 Spec Pack：自动递增三位编号、创建并切换到 `{num}-{short-name}` 分支、生成 `.aisdlc/specs/{num}-{short-name}/` 目录结构，并把原始需求写入 `requirements/raw.md`（UTF-8 with BOM）。

约束：即使仓库包含 `.gitmodules`，`spec-init` 也只初始化**根项目**的 Spec 分支与 Spec Pack；子仓分支不在本阶段批量创建。

## 何时使用 / 不使用

- **使用时机**
  - 用户要开始一个"新需求"的 Spec（还没有 `{num}-{short-name}` 分支与 `.aisdlc/specs/...` 目录）。
  - 用户只给了中文需求文本（不方便先手动建文件），担心参数编码导致乱码。
  - 需要确保分支命名、编号来源、目录结构符合仓库约定。
- **不要用在**
  - 已经在一个合法的 `{num}-{short-name}` spec 分支上，且 `.aisdlc/specs/{num}-{short-name}/` 已存在并结构完整（这时直接进入后续命令）。

## 快速参考

- **分支命名**：`{num}-{short-name}`（`num` 为三位数字；`short-name` 为 kebab-case，小写字母/数字/连字符）
- **统一输出位置**：`.aisdlc/specs/{num}-{short-name}/`
- **必备子目录**：`requirements/`、`design/`、`implementation/`、`verification/`、`release/`
- **初始文件**：`requirements/raw.md`（内容=原始需求；编码=UTF-8 with BOM）
- **脚本位置**：`<本SKILL.md目录>/scripts/`
- **脚本入口（PowerShell）**：`spec-create-branch.ps1` 的 `Main`（需 PowerShell 5.0+）
- **脚本入口（Bash）**：`spec-create-branch.sh`（命令行参数见 `--help`；stdout 输出 JSON）
- **关键副作用**：脚本执行成功后会删除传入的源文件（无论是原始文件还是临时文件）。
- **与子仓的边界**：若后续实现涉及 submodule，原则上由实现计划在 `I1 -> I2` 之间创建并校验与根项目同名的 Spec 分支

## 实施步骤（Agent 行为规范）

### 1) 解析用户输入 → 一律落到文件路径

**强制规则：始终以文件路径方式传入需求内容**（避免中文内容在参数传递/编码上出问题）。

- **输入是文件路径**：直接用该路径作为 `$sourceFilePath`（但要提示"会被删除"）。
- **输入是文本**：用 Agent 的 **Write 工具** 将文本直接写入仓库根目录下的临时文件 `_sdlc-raw-temp.md`，然后用该路径作为 `$sourceFilePath`。
  - **无需担心残留**：脚本执行成功后会自动删除该源文件。

示例（Agent 操作）：

```
1. Write 工具 → 路径: {REPO_ROOT}/_sdlc-raw-temp.md，内容: 用户提供的原始需求文本
2. 将 {REPO_ROOT}/_sdlc-raw-temp.md 作为 $sourceFilePath / --source-file 传入脚本
```

### 2) 生成 `short-name`（2-4 词，kebab-case）

从原始需求提炼 2-4 个词的短名称，优先"动词-名词"，保留常见技术缩写（如 `oauth2`、`jwt`、`api`）：

- 示例：批量导出订单 + 异步任务 → `export-orders-batch` 或 `add-order-export`
- 若不确定，宁可更通用、更短：`export-orders`

### 3) 调用脚本创建分支与 Spec Pack

**按操作系统自动选择脚本实现（不要硬跑"另一种"）。**

- Windows / PowerShell：用 dot sourcing 加载 `spec-create-branch.ps1` 并调用 `Main`
- macOS/Linux / Bash：直接执行 `spec-create-branch.sh`（stdout 输出 JSON）

**执行参数（只填参数即可）**

- PowerShell（`Main`）：
  - `-ShortName <kebab-case>`
  - `-SourceFilePath <需求文件路径>`
  - `-Title <可选>`
  - 调用形态：`Main -ShortName <...> -SourceFilePath <...> [-Title <...>]`
- Bash（`spec-create-branch.sh`）：
  - `--short-name <kebab-case>`
  - `--source-file <需求文件路径>`
  - `--title <可选>`
  - 调用形态：`spec-create-branch.sh --short-name <...> --source-file <...> [--title <...>]`

脚本职责边界：

- 若当前目录位于 submodule 内，脚本应先回溯到根项目，再在根项目创建 Spec 分支与 `.aisdlc/specs/...`
- 不在此阶段创建 submodule 分支，也不生成额外的 repo 清单文件

### 4) 验收（DoD）

检查以下事实是否同时成立（缺一不可）：

- 当前分支名（`git branch --show-current`）符合 `{num}-{short-name}`。
- `.aisdlc/specs/<branchName>/` 存在，且包含 5 个必需子目录（`requirements/`、`design/`、`implementation/`、`verification/`、`release/`）。
- `.aisdlc/specs/<branchName>/requirements/raw.md` 存在，内容等于原始需求（注意文件头有 UTF-8 BOM）。
- 传入的源文件已被删除（这不是 bug；若用户需要保留，应在步骤 1 之前自行备份）。
- 若仓库包含 `.gitmodules`：本阶段不要求任何子仓已创建分支；后续应由 I1/I2 门禁处理

### 5) 完成后：立即交回 `using-aisdlc` 继续自动推进

`spec-init` 的 DoD 通过后，本技能不做"下一步分流"判定（避免出现第二个路由源）。统一做法：

- 输出 `ROUTER_SUMMARY`（见下节）
- **立即调用** `using-aisdlc` 路由下一步（Router 默认自动续跑；进入 R1：`spec-product-clarify`）

## 完成后输出与自动路由（必须执行）

Spec Pack 初始化完成后（无论成功或失败），**必须**完成以下动作（按顺序，不可省略）：

1. **输出 ROUTER_SUMMARY**（YAML 形态，供 Router 决策；按实际结果填写）：

**创建成功时：**

```yaml
ROUTER_SUMMARY:
  stage: R0
  artifacts:
    - "{FEATURE_DIR}/requirements/raw.md"
  needs_human_review: false
  blocked: false
  block_reason: ""
  notes: "Spec Pack 已初始化完成；建议 Router 进入 R1（spec-product-clarify）"
```

**任一 DoD 未满足并停止时：**

```yaml
ROUTER_SUMMARY:
  stage: R0
  artifacts: []
  needs_human_review: true
  blocked: true
  block_reason: "<填写失败点与最小修复动作>"
  notes: "未完成初始化，需先修复再继续"
```

2. **立即执行 `using-aisdlc`**：将上述 `ROUTER_SUMMARY` 作为路由输入传递给 using-aisdlc，由 Router 判定下一步并**自动推进**（无需等待用户说「继续」）。  
   - 若 Router 判定可自动续跑：在同一轮对话内继续执行下一步 worker skill（如 R1 等）
   - 若 Router 触发硬中断：停下并输出阻断原因、需要的输入、候选下一步

3. **对话输出**：在调用 using-aisdlc 前，可简短说明「本阶段产物已落盘，正在调用 using-aisdlc 路由下一步。」

## 常见错误（以及怎么避免）

- **自创分支/目录结构**：不要用 `spec/<slug>`、`feature/<slug>`、`features/<slug>`；本仓库规范是 `{num}-{short-name}` + `.aisdlc/specs/...`。
- **把中文需求当作命令行参数直接传递**：一律写入文件，再传路径。
- **误以为脚本不会删源文件**：它会删除 `SourceFilePath` 指向的文件；对用户的原始文件务必先确认是否需要备份。
- **短名称不规范**：避免大写、下划线、中文；避免前后连字符与连续 `--`；尽量 2-4 词。
- **把 submodule 当作 Spec 根目录**：即使从子仓目录触发，也必须回到根项目创建 `.aisdlc/specs/...`
