# Skills 目录规范

本仓库的 Skills 遵循统一目录结构，支持以下可选子目录。

## 目录结构

```
skill-name/
├── SKILL.md              # 必需 - 主指令与元数据
├── scripts/              # 可选 - Agents 可运行的可执行代码
├── references/           # 可选 - 按需加载的附加文档
└── assets/               # 可选 - 模板、图片或数据文件等静态资源
```

## 可选目录说明

| 目录 | 用途 | 示例 |
|------|------|------|
| **scripts/** | Agents 可执行脚本（.ps1、.sh、.py 等） | 上下文定位、分支创建、校验工具 |
| **references/** | 按需加载的参考文档（API 说明、prompt 模板等） | 子智能体 prompt、详细规范 |
| **assets/** | 静态资源：模板、图片、数据文件 | design-template.md、prd-template.md |

## 路径约定

- 引用脚本：`skills/{skill-name}/scripts/{script-name}`
- 引用参考：`skills/{skill-name}/references/{doc-name}`
- 引用资产：`skills/{skill-name}/assets/{asset-name}`

## 渐进式披露

- **SKILL.md**：保持精简（建议 <500 行），仅含核心指令与门禁
- **references/**：详细文档按需读取，避免一次性加载
- **assets/**：模板类内容，复制到目标位置再填写
