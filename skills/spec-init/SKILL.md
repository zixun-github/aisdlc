---
name: spec-init
description: Use when 需要在本仓库的 AI SDLC 流程中初始化新的 Spec Pack（创建三位编号分支与 `.aisdlc/specs/{num}-{short-name}` 目录），或在执行 `spec-init` 时不确定输入解析、短名称规则、UTF-8 BOM 文件路径传参、脚本调用方式与输出物。
---

# spec-init

## 概览

`spec-init` 用于在本仓库里创建一个新的需求级 Spec Pack：自动递增三位编号、创建并切换到 `{num}-{short-name}` 分支、生成 `.aisdlc/specs/{num}-{short-name}/` 目录结构，并把原始需求写入 `requirements/raw.md`（UTF-8 with BOM）。

**开始时宣布：**「我正在使用 spec-init 技能初始化新的 Spec Pack（创建分支与 requirements/raw.md）。」

## 何时使用 / 不使用

- **使用时机**
  - 用户要开始一个“新需求”的 Spec（还没有 `{num}-{short-name}` 分支与 `.aisdlc/specs/...` 目录）。
  - 用户只给了中文需求文本（不方便先手动建文件），担心参数编码导致乱码。
  - 需要确保分支命名、编号来源、目录结构与后续命令（如 `spec-product-clarify`）一致。
- **不要用在**
  - 已经在一个合法的 `{num}-{short-name}` spec 分支上，且 `.aisdlc/specs/{num}-{short-name}/` 已存在并结构完整（这时直接进入后续命令）。

## 快速参考

- **分支命名**：`{num}-{short-name}`（`num` 为三位数字；`short-name` 为 kebab-case，小写字母/数字/连字符）
- **统一输出位置**：`.aisdlc/specs/{num}-{short-name}/`
- **必备子目录**：`requirements/`、`design/`、`implementation/`、`verification/`、`release/`
- **初始文件**：`requirements/raw.md`（内容=原始需求；编码=UTF-8 with BOM）
- **脚本位置**：`<本SKILL.md目录>/scripts/`
- **脚本入口（PowerShell）**：`spec-create-branch.ps1` 的 `Main`（需 PowerShell 7+）
- **脚本入口（Bash）**：`spec-create-branch.sh`（命令行参数见 `--help`）
- **自动选择规则**：在 Windows/PowerShell 环境优先使用 PowerShell；在 macOS/Linux 的 bash 环境使用 Bash 版本（两者行为对齐，差别仅在调用方式与返回值形态）。
- **脚本参数（PowerShell）**
  - `-ShortName`（必需）
  - `-SourceFilePath`（必需，必须是文件路径）
  - `-Title`（可选）
- **参数拷贝红旗**：不要直接复制下文 `Main ... -SourceFilePath $sourceFilePath` 就运行；`$sourceFilePath` 必须先按“步骤 1”准备成**已存在的文件路径**。
- **脚本参数（Bash）**
  - `--short-name`（必需）
  - `--source-file`（必需，必须是文件路径）
  - `--title`（可选）
- **关键副作用**：脚本执行成功后会删除传入的源文件（PowerShell：`SourceFilePath`；Bash：`--source-file`；无论是原始文件还是临时文件）。

## 实施步骤（Agent 行为规范）

### 0) 预检（不要跳过）

- 确认当前工作目录在目标 Git 仓库内（**在仓库任意子目录都可以**；只要 `git rev-parse --show-toplevel` 能成功）。
- **PowerShell 路径**：确认 PowerShell 版本满足脚本要求（脚本声明 `#Requires -Version 7.0`）。
- **Bash 路径**：确认 `bash` 可用，且有 `git`、`head`、`tail`、`mktemp`（脚本用于 BOM 处理与临时文件）。
- 如果用户提供的是“文件路径”，提醒：该文件会被脚本删除；如需保留，先复制一份再传入。

### 1) 解析用户输入 → 一律落到文件路径

**强制规则：始终以文件路径方式传入需求内容**（避免中文内容在参数传递/编码上出问题）。

- **输入是文件路径**：直接用该路径作为 `$sourceFilePath`（但要提示“会被删除”）。
- **输入是文本**：创建临时文件并用 **UTF-8 with BOM** 写入，然后把临时文件路径作为 `$sourceFilePath`。

PowerShell 模板（文本 → BOM 临时文件）：

```powershell
$raw = @"
为现有后台系统新增‘批量导出订单’功能：支持按时间范围/状态筛选、CSV 与 XLSX 两种格式、导出任务异步执行并在导出中心可下载，权限仅管理员可见。
"@

$utf8Bom = [System.Text.UTF8Encoding]::new($true)
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("sdlc-raw-{0}.md" -f ([guid]::NewGuid().ToString("N")))
[System.IO.File]::WriteAllText($tmp, $raw, $utf8Bom)
$sourceFilePath = $tmp
```

Bash 模板（文本 → BOM 临时文件）：

```bash
raw_file="$(mktemp)"
{
  printf '\xEF\xBB\xBF'
  cat <<'EOF'
为现有后台系统新增‘批量导出订单’功能：支持按时间范围/状态筛选、CSV 与 XLSX 两种格式、导出任务异步执行并在导出中心可下载，权限仅管理员可见。
EOF
} >"$raw_file"
source_file_path="$raw_file"
```

### 2) 生成 `short-name`（2-4 词，kebab-case）

从原始需求提炼 2-4 个词的短名称，优先“动词-名词”，保留常见技术缩写（如 `oauth2`、`jwt`、`api`）：

- 示例：批量导出订单 + 异步任务 → `export-orders-batch` 或 `add-order-export`
- 若不确定，宁可更通用、更短：`export-orders`

### 3) 调用脚本创建分支与 Spec Pack

**按操作系统自动选择脚本实现（不要硬跑“另一种”）。**

- Windows / PowerShell：用 dot sourcing 加载 `spec-create-branch.ps1` 并调用 `Main`
- macOS/Linux / Bash：直接执行 `spec-create-branch.sh`（输出 JSON）

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

### 4) 验收（DoD）

检查以下事实是否同时成立（缺一不可）：

- 当前分支名（`git branch --show-current`）符合 `{num}-{short-name}`。
- `.aisdlc/specs/<branchName>/` 存在，且包含 5 个必需子目录（`requirements/`、`design/`、`implementation/`、`verification/`、`release/`）。
- `.aisdlc/specs/<branchName>/requirements/raw.md` 存在，内容等于原始需求（注意文件头有 UTF-8 BOM）。
- 传入的源文件已被删除（这不是 bug；若用户需要保留，应在步骤 1 之前自行备份）。

### 5) 完成后：回到 `using-aisdlc` 路由下一步

`spec-init` 的 DoD 通过后，本技能不再“自动衔接”到任何下游技能；请回到 `using-aisdlc` 作为**唯一路由器**决定下一步（通常先 `spec-context`，再路由到 R1：`spec-product-clarify`）。


## 常见错误（以及怎么避免）

- **自创分支/目录结构**：不要用 `spec/<slug>`、`feature/<slug>`、`features/<slug>`；本仓库规范是 `{num}-{short-name}` + `.aisdlc/specs/...`。
- **把中文需求当作命令行参数直接传递**：一律写入 UTF-8 BOM 文件，再传路径。
- **误以为脚本不会删源文件**：它会删除 `SourceFilePath` 指向的文件；对用户的原始文件务必先确认是否需要备份。
- **短名称不规范**：避免大写、下划线、中文；避免前后连字符与连续 `--`；尽量 2-4 词。
