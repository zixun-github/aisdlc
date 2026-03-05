---
name: spec-context
description: Use when 需要在 sdlc-dev 的 Spec 流程中定位当前 spec pack（FEATURE_DIR）、避免在错误目录读写 requirements/*.md，或出现"看错上下文/写错文件/分支不符合规范"的问题。
---

# Spec 上下文定位（FEATURE_DIR）

## 概览

读写 `requirements/*.md` 前必须先确定 `{FEATURE_DIR}`。以**当前 Git 分支名**为锚点，禁止猜路径。

**开始时宣布：**「我正在使用 spec-context 技能定位当前 Spec Pack（FEATURE_DIR）。」

## 何时使用

- 将读/写 `{FEATURE_DIR}/requirements/*.md`
- 不确定当前 spec pack 或出现分支/目录/`.aisdlc` 相关上下文错误

## 做法：复用 $FEATURE_DIR，否则执行脚本

**优先复用**：若本会话已成功回显过 `FEATURE_DIR=...`，且 `$FEATURE_DIR` 非空、目录存在且含 `requirements/`，则直接复用并回显 `FEATURE_DIR=... (reuse)`。

**否则**：执行脚本定位并回显 `FEATURE_DIR=...`。

**脚本目录处理**：

- **脚本位置**：`<本SKILL.md目录>/scripts/`
- **执行方式**：按操作系统选择脚本实现（Windows/PowerShell 用 `spec-common.ps1`；macOS/Linux/Bash 用 `spec-common.sh`）
- **路径约束**：不要依赖当前工作目录（cwd）；优先通过 `$SKILL_DIR` / `SKILL_DIR` 组装脚本绝对路径再加载

### PowerShell

```powershell
$SKILL_DIR = "<本SKILL.md目录>"
if ($null -ne $FEATURE_DIR -and (Test-Path $FEATURE_DIR) -and (Test-Path (Join-Path $FEATURE_DIR "requirements"))) {
  Write-Host "FEATURE_DIR=$FEATURE_DIR (reuse)"
} else {
  . (Join-Path $SKILL_DIR "scripts/spec-common.ps1")
  $context = Get-SpecContext -SkillName "<caller-skill-name>"
  $FEATURE_DIR = $context.FEATURE_DIR
  Write-Host "FEATURE_DIR=$FEATURE_DIR"
}
```

### Bash

```bash
SKILL_DIR="<本SKILL.md目录>"
if [[ -n "${FEATURE_DIR:-}" && -d "$FEATURE_DIR" && -d "$FEATURE_DIR/requirements" ]]; then
  echo "FEATURE_DIR=$FEATURE_DIR (reuse)"
else
  source "$SKILL_DIR/scripts/spec-common.sh"
  get_spec_context
  echo "FEATURE_DIR=$FEATURE_DIR"
fi
```

> **`-SkillName`**：将 `<caller-skill-name>` 替换为当前执行的技能名（如 `spec-plan`）。  
> **`$SKILL_DIR` / `SKILL_DIR`**：表示“当前 `SKILL.md` 所在目录”，用于稳定定位 `scripts/`，避免因 cwd 漂移导致脚本加载失败。

## 硬规则

- 读写 `requirements/*.md` 前必须先回显 `FEATURE_DIR=...`（复用或脚本二选一）
- 脚本失败则立即停止，不得继续写文件
- 后续路径一律以 `$FEATURE_DIR` / `${FEATURE_DIR}` 为前缀

## 常见错误与 Red Flags

- 未传 `-SkillName` 或照抄 `<caller-skill-name>` 字面量
- 非 spec 分支（分支名不符合 `{num}-{short-name}`）
- 手写 `.aisdlc/specs/...` 路径；上下文失败后仍继续生成
