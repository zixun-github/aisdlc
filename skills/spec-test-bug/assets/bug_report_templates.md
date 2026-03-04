# 缺陷报告模板（Bug Report Templates）

> 用于编写清晰、可复现、可执行的缺陷报告。输出内容面向外部缺陷系统（Jira/禅道/Linear/GitHub Issue 等）。
>
> 约束：Spec Pack 内不落盘 bug 文件；外部缺陷创建后把编号/链接回写到 `verification/report-*.md`。

---

## 1) 标准缺陷报告模板（推荐）

```markdown
# BUG-[ID]：[清晰、具体的标题]

**严重程度（Severity）：** 致命 Critical | 高 High | 中 Medium | 低 Low
**优先级（Priority）：** P0 | P1 | P2 | P3
**类型（Type）：** 功能 Functional | UI | 性能 Performance | 安全 Security | 数据 Data | 崩溃 Crash
**状态（Status）：** 新建 Open | 处理中 In Progress | 待评审 In Review | 已修复 Fixed | 已验证 Verified | 已关闭 Closed

---

## 环境信息（Environment）

| 属性 | 值 |
|------|----|
| **操作系统（OS）** | [Windows 11 / macOS 14 / Ubuntu 22.04] |
| **浏览器（Browser）** | [Chrome / Edge / Firefox / Safari + 版本] |
| **设备（Device）** | [桌面 / iPhone / Android / ...] |
| **版本/构建（Build/Version）** | [vX.Y.Z / build id / git sha] |
| **环境（Environment）** | [Dev / Staging / Production] |
| **URL** | [具体页面/入口 URL，如适用] |

---

## 描述（Description）

[用 2-3 句话说明问题是什么，以及带来的影响/风险]

---

## 复现步骤（Steps to Reproduce）

**前置条件（Preconditions）：**
- [复现前需要的准备]
- [测试账号/权限]
- [测试数据/配置开关]

**步骤（Steps）：**
1. [进入具体入口或 URL]
2. [执行具体操作]
3. [输入具体数据（如有）]
4. [点击/提交]
5. [观察到问题]

**复现概率（Reproduction Rate）：** [必现 Always / 偶现 Intermittent / 10 次 8 次]

---

## 期望结果（Expected）

[应该发生什么]

---

## 实际结果（Actual）

[实际发生什么；错误提示请原样贴出]

---

## 证据（Evidence）

 - 截图/录屏： [链接或“已附”】【敏感信息需脱敏】
- 控制台错误（如适用）：
```
[粘贴错误]
```
- 网络请求摘要（如适用）：
```
[失败请求/响应关键信息：URL、状态码、错误码、trace id（脱敏）]
```
- 服务端日志（如适用，脱敏）：
```
[关键片段]
```

---

## 影响评估（Impact）

| 维度 | 说明 |
|------|------|
| 用户影响 | [所有用户/部分用户/特定角色] |
| 频率 | [每次/经常/偶尔/罕见] |
| 数据影响 | [数据丢失/数据错误/无] |
| 业务影响 | [阻断核心流程/影响转化/影响收入/影响体验] |
| 临时绕过 | [无/存在：...] |

---

## 关联项（Links）

- 关联用例：`TC-...`
- 关联需求：`requirements/solution.md#...` 或 `requirements/prd.md#...`
- 相关缺陷：`BUG-...`（如有）
```

---

## 2) 快速缺陷模板（轻微问题/快速记录）

```markdown
# BUG-[ID]：[标题]

**Severity：** 低 Low | 中 Medium
**环境：** [OS / Browser / Build / Env]

## 问题（Issue）
[一段话描述]

## 步骤（Steps）
1. ...
2. ...
3. ...

## 期望（Expected）
...

## 实际（Actual）
...

## 证据（Evidence）
[截图/链接/日志（可选）]

## 关联用例
TC-...
```

---

## 3) UI/视觉缺陷模板（设计偏差）

```markdown
# BUG-[ID]：[组件/页面] 视觉不一致（Visual Mismatch）

**Severity：** 中 Medium
**Type：** UI

## 设计 vs 实现（Design vs Implementation）

**期望（Design）：**
| 属性 | 值 |
|------|----|
| 背景色 | #0066FF |
| 字号 | 16px |
| 字重 | 600 |
| 内边距 | 12px 24px |
| 圆角 | 8px |

**实际（Implementation）：**
| 属性 | 期望 | 实际 | 是否一致 |
|------|------|------|----------|
| 背景色 | #0066FF | #0052CC | 否 |
| 字重 | 600 | 400 | 否 |

## 证据
- 设计稿截图：...
- 实现截图：...
- 并排对比：...

## 关联用例
TC-UI-...
```

---

## 4) 性能缺陷模板（性能退化）

```markdown
# BUG-[ID]：[功能] 性能退化（Performance Degradation）

**Severity：** 高 High
**Type：** 性能 Performance

## 指标（Metrics）
| 指标 | 期望 | 实际 | 偏差 |
|------|------|------|------|
| 页面加载 | < 2s | 8s | +300% |
| API 响应 | < 200ms | 1500ms | +650% |

## 复现
1. ...
2. ...
3. ...

## 证据
- trace：...
- waterfall：...
- profile：...

## 基线
- 上一正常版本：...
- 退化开始版本：...

## 关联用例
TC-PERF-...
```

---

## 5) 安全缺陷模板（机密）

```markdown
# BUG-[ID]：[安全问题标题]

**Severity：** 致命 Critical
**Type：** 安全 Security
**机密（CONFIDENTIAL）：** 请勿公开传播

## 描述
[高层描述问题，不提供可直接利用的攻击代码]

## 影响
- 数据泄露 / 权限提升 / 账号接管 / 服务中断 / ...

## 验证方式
[描述如何验证存在；敏感信息务必脱敏]

## 修复建议
[高层整改建议]

## 关联用例
TC-SEC-...
```

---

## 6) Severity/Priority 参考（可选）

| Severity | 判定标准 | 示例 |
|---|---|---|
| Critical | 系统不可用、数据丢失、安全事故 | 登录不可用、支付失败、数据泄露 |
| High | 核心功能不可用、无替代方案 | 搜索不可用、结算失败 |
| Medium | 功能部分受影响、有替代方案 | 筛选缺少选项、加载偏慢 |
| Low | 外观问题、罕见边界问题 | 拼写错误、轻微对齐 |

