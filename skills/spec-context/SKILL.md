---
name: spec-context
description: Use when 需要在 sdlc-dev 的 Spec 流程中定位当前 spec pack（FEATURE_DIR）、避免在错误目录读写 requirements/*.md，或出现“看错上下文/写错文件/分支不符合规范”的问题。
---

# Spec 上下文定位（FEATURE_DIR）

## 概览

在任何 Spec 命令/技能里，只要会读写 `requirements/*.md`，就必须先确定 `{FEATURE_DIR}`。本仓库以 **当前 Git 分支名**作为 spec pack 的定位锚点，禁止猜路径。

**开始时宣布：**「我正在使用 spec-context 技能定位当前 Spec Pack（FEATURE_DIR）。」

## 何时使用

- 你将要读/写：`{FEATURE_DIR}/requirements/raw.md | solution.md | prd.md | prototype.md`
- 你不确定当前处于哪个 spec pack（担心读写错目录）
- 你看到“分支名不规范 / 目录结构不完整 / 缺 .aisdlc”之类上下文错误

## 唯一做法（PowerShell / Bash）

在 Windows/PowerShell 环境用 PowerShell 版；在 macOS/Linux 或 Git Bash 环境用 Bash 版（两者校验规则对齐）。

### PowerShell

```powershell
. ".\skills\spec-context\scripts\spec-common.ps1"
$context = Get-SpecContext
$FEATURE_DIR = $context.FEATURE_DIR
Write-Host "FEATURE_DIR=$FEATURE_DIR"
```

### Bash

```bash
source "./skills/spec-context/scripts/spec-common.sh"
get_spec_context
echo "FEATURE_DIR=$FEATURE_DIR"
```

## 会话复用（串联多个技能时允许不重复跑脚本）

当你在**同一个会话**里连续执行多个技能时，理论上第一个技能已经拿到了 `FEATURE_DIR`。为减少重复，你可以在后续技能里**复用**该值，但必须满足以下条件：

- 已在本会话中**成功**回显过一次 `FEATURE_DIR=...`（作为证据）
- 当前 `$FEATURE_DIR` / `${FEATURE_DIR}` **非空**
- `FEATURE_DIR` 指向的目录存在，且至少包含 `requirements/` 子目录（最小防呆校验）

任一条件不满足，就必须回退为“运行脚本定位”的方式。

### PowerShell（复用优先，否则回退脚本）

```powershell
if ($null -ne $FEATURE_DIR -and (Test-Path $FEATURE_DIR) -and (Test-Path (Join-Path $FEATURE_DIR "requirements"))) {
  Write-Host "FEATURE_DIR=$FEATURE_DIR (reuse)"
} else {
  . ".\spec-common.ps1"
  $context = Get-SpecContext
  $FEATURE_DIR = $context.FEATURE_DIR
  Write-Host "FEATURE_DIR=$FEATURE_DIR"
}
```

### Bash（复用优先，否则回退脚本）

```bash
if [[ -n "${FEATURE_DIR:-}" && -d "$FEATURE_DIR" && -d "$FEATURE_DIR/requirements" ]]; then
  echo "FEATURE_DIR=$FEATURE_DIR (reuse)"
else
  source "./spec-common.sh"
  get_spec_context
  echo "FEATURE_DIR=$FEATURE_DIR"
fi
```

## 硬规则（必须遵守）
- **脚本路径**：给定为 **`<本SKILL.md目录>/scripts/`**（即与本 SKILL.md 同级的 `scripts/` 目录）。
- **脚本位置**：`scripts/spec-common.ps1`、`scripts/spec-common.sh`（相对该 scripts 目录）。
- **先定位再读写（两种合规路径）**：任何读/写 `requirements/*.md` 之前，必须先回显 `FEATURE_DIR=...`，且只能通过以下两种方式之一达成：
  - **会话首次/不确定时**：运行上面的脚本定位并回显 `FEATURE_DIR=...`。
  - **同一会话复用时**：允许不运行脚本，但必须满足“会话复用”的全部条件，并以 `FEATURE_DIR=... (reuse)` 的形式回显（作为证据）。
- **失败就停止**：PowerShell 的 `Get-SpecContext` 或 Bash 片段任意一步报错时，必须立刻停止，不得继续生成/写文件内容（否则几乎必然跑偏上下文）。
- **只用 FEATURE_DIR 拼路径**：后续所有路径都必须以 `$FEATURE_DIR`（PowerShell）或 `${FEATURE_DIR}`（Bash）为前缀（禁止用当前工作目录做相对路径猜测）。

## 常见错误

- **在非 spec 分支上执行**：分支名不符合 `{num}-{short-name}`，会导致无法定位 spec pack。
- **手写 `.aisdlc/specs/...` 路径**：人会写错，AI 更容易写错；必须以脚本输出为准。
- **继续执行“生成文档”**：只要上下文失败，就停止并先修复分支/目录结构。

