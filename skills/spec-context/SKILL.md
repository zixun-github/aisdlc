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

## 做法：复用已有结果，否则执行脚本

**优先复用**：若本会话已成功回显过 `FEATURE_DIR=...`，且该目录存在并含 `requirements/`，则直接复用并回显 `FEATURE_DIR=... (reuse)`。

**否则**：拼接 `<本SKILL.md目录>/scripts/` 下的脚本绝对路径并执行，从输出中读取 `FEATURE_DIR=<path>` 行。

### PowerShell

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<本SKILL.md目录>/scripts/spec-common.ps1" -SkillName "<caller-skill-name>"
```

### Bash

```bash
"<本SKILL.md目录>/scripts/spec-common.sh" "<caller-skill-name>"
```

> **`-SkillName` / 第一参数**：替换为当前执行的技能名（如 `spec-plan`）。
> **`<本SKILL.md目录>`**：替换为本 `SKILL.md` 所在目录的绝对路径。

## 硬规则

- 读写 `requirements/*.md` 前必须先回显 `FEATURE_DIR=...`（复用或脚本二选一）
- 脚本失败则立即停止，不得继续写文件
- 后续路径一律以 `FEATURE_DIR` 值为前缀

## 常见错误与 Red Flags

- 未传 `-SkillName` 或照抄 `<caller-skill-name>` 字面量
- 非 spec 分支（分支名不符合 `{num}-{short-name}`）
- 手写 `.aisdlc/specs/...` 路径；上下文失败后仍继续生成
