# 缺陷报告模板（Bug Report Templates）

用于编写**清晰、可复现、可执行**的缺陷文档的标准模板集合。

---

## 标准缺陷报告模板

```markdown
# BUG-[ID]：[清晰、具体的标题]

**严重程度（Severity）：** 致命 Critical | 高 High | 中 Medium | 低 Low
**优先级（Priority）：** P0 | P1 | P2 | P3
**类型（Type）：** 功能 Functional | UI | 性能 Performance | 安全 Security | 数据 Data | 崩溃 Crash
**状态（Status）：** 新建 Open | 处理中 In Progress | 待评审 In Review | 已修复 Fixed | 已验证 Verified | 已关闭 Closed
**负责人（Assignee）：** [开发姓名]
**报告人（Reporter）：** [你的姓名]
**报告日期（Reported Date）：** YYYY-MM-DD

---

## 环境信息（Environment）

| 属性 | 值 |
|------|----|
| **操作系统（OS）** | [Windows 11 / macOS 14 / Ubuntu 22.04] |
| **浏览器（Browser）** | [Chrome 120 / Firefox 121 / Safari 17] |
| **设备（Device）** | [桌面 / iPhone 15 / Samsung S23] |
| **版本/构建（Build/Version）** | [v2.5.0 / commit abc123] |
| **环境（Environment）** | [生产 Production / 预发 Staging / 开发 Dev] |
| **URL** | [具体页面 URL] |

---

## 缺陷描述（Description）

[用 2-3 句话说明问题是什么，以及带来的影响/风险]

---

## 复现步骤（Steps to Reproduce）

**前置条件（Preconditions）：**
- [复现前需要的任何准备]
- [测试账号：user@test.com]

**步骤（Steps）：**
1. [进入具体 URL]
2. [执行具体操作]
3. [输入具体数据："example"]
4. [点击具体按钮]
5. [观察到问题]

**复现概率（Reproduction Rate）：** [必现 Always / 10 次 8 次 / 偶现 Intermittent]

---

## 期望结果（Expected Behavior）

[清楚描述“应该发生什么”]

---

## 实际结果（Actual Behavior）

[清楚描述“实际发生了什么”。如有错误提示请原样贴出]

---

## 证据材料（Visual Evidence）

**截图（Screenshots）：**
- [ ] 发生前状态（Before）：[已附]
- [ ] 发生后状态（After）：[已附]
- [ ] 错误提示（Error message）：[已附]

**录屏（Video Recording）：** [如有链接]

**控制台错误（Console Errors）：**
```
[在此粘贴 Console 报错]
```

**网络错误（Network Errors）：**
```
[在此粘贴失败请求/响应摘要]
```

---

## 影响评估（Impact Assessment）

| 维度 | 说明 |
|------|------|
| **影响用户（Users Affected）** | [所有用户 / 部分用户 / 特定角色] |
| **发生频率（Frequency）** | [每次 / 有时 / 很少] |
| **数据影响（Data Impact）** | [数据丢失 / 数据错误 / 无] |
| **业务影响（Business Impact）** | [收入损失 / 影响转化 / 用户投诉 / 影响较小] |
| **临时绕过（Workaround）** | [如存在请描述，否则写“无”] |

---

## 补充信息（Additional Context）

**关联项（Related Items）：**
- 需求/功能： [FEAT-123]
- 测试用例： [TC-456]
- 相似缺陷： [BUG-789]
- 设计稿（UI 类）： [URL]

**回归信息（Regression Information）：**
- 是否回归： [是 Yes / 否 No]
- 最近正常版本： [v2.4.0]
- 首次异常版本： [v2.5.0]

**备注（Notes）：**
[任何有助于定位/修复的上下文，例如边界条件、用户路径、数据特征等]

---

## 开发填写区（Developer Section / To Be Filled）

### 根因（Root Cause）
[开发在排查后补充]

### 修复说明（Fix Description）
[开发描述修复思路/方案]

### 变更文件（Files Changed）
- [file1.js]
- [file2.css]

### 修复 PR（Fix PR）
[链接到 Pull Request]

---

## QA 验证（QA Verification）

- [ ] 在开发环境验证通过
- [ ] 在预发环境验证通过
- [ ] 回归测试通过
- [ ] 相关用例已更新
- [ ] 可发布到生产

**验证人（Verified By）：** [QA 姓名]
**验证日期（Verification Date）：** [日期]
**验证构建（Verification Build）：** [构建号/版本号]
```

---

## 快速缺陷报告模板

用于轻微问题或快速记录。

```markdown
# BUG-[ID]：[标题]

**严重程度（Severity）：** 低 Low | 中 Medium
**环境（Environment）：** [浏览器、OS、Build]

## 问题（Issue）
[一段话描述]

## 步骤（Steps）
1. [步骤 1]
2. [步骤 2]
3. [步骤 3]

## 期望（Expected）
[应该发生什么]

## 实际（Actual）
[实际发生什么]

## 截图（Screenshot）
[已附]
```

---

## UI/视觉缺陷模板

用于设计偏差（Design discrepancy）类问题。

```markdown
# BUG-[ID]：[组件] 视觉不一致（Visual Mismatch）

**严重程度（Severity）：** 中 Medium
**类型（Type）：** UI
**Figma 设计稿（Figma Design）：** [指向具体组件/页面的 URL]

## 设计 vs 实现（Design vs Implementation）

### 期望（Figma）
| 属性 | 值 |
|------|----|
| 背景色（Background） | #0066FF |
| 字号（Font Size） | 16px |
| 字重（Font Weight） | 600 |
| 内边距（Padding） | 12px 24px |
| 圆角（Border Radius） | 8px |

### 实际（Implementation）
| 属性 | 期望 | 实际 | 是否一致 |
|------|------|------|----------|
| 背景色 | #0066FF | #0052CC | 否 |
| 字号 | 16px | 16px | 是 |
| 字重 | 600 | 400 | 否 |
| 内边距 | 12px 24px | 12px 24px | 是 |
| 圆角 | 8px | 8px | 是 |

## 截图（Screenshots）

**Figma：**
[设计稿截图]

**当前实现：**
[实现截图]

**对比图：**
[并排对比图片]

## 影响（Impact）
用户看到的品牌/样式不一致，组件与已审批设计不一致。
```

---

## 性能缺陷模板

用于速度、内存或资源占用等问题。

```markdown
# BUG-[ID]：[功能] 性能退化（Performance Degradation）

**严重程度（Severity）：** 高 High
**类型（Type）：** 性能 Performance

## 性能问题（Performance Issue）

**影响范围（Affected Area）：** [页面/功能/API]
**用户影响（User Impact）：** [加载慢 / 卡死 / 无响应 / 资源占用高]

## 指标（Metrics）

| 指标 | 期望 | 实际 | 偏差 |
|------|------|------|------|
| 页面加载（Page Load Time） | < 2s | 8s | +300% |
| API 响应（API Response） | < 200ms | 1500ms | +650% |
| 内存占用（Memory Usage） | < 100MB | 450MB | +350% |
| CPU 占用（CPU Usage） | < 30% | 95% | +217% |

## 环境（Environment）
- 数据量： [记录数]
- 网络： [连接类型]
- 设备规格： [RAM、CPU]

## 复现（Reproduction）
1. [加载包含 X 条记录的页面]
2. [执行操作]
3. [观察到慢响应/卡顿]

## 证据（Evidence）
- 性能追踪（trace）： [链接]
- 网络瀑布图： [截图]
- 内存剖析： [截图]

## 基线（Baseline）
- 上一版本： [v2.4.0]
- 上一指标： [例如 2s 加载]
- 退化开始版本： [v2.5.0]
```

---

## 安全缺陷模板

用于安全漏洞与安全隐患报告。

```markdown
# BUG-[ID]：[安全问题标题]

**严重程度（Severity）：** 致命 Critical
**类型（Type）：** 安全 Security
**OWASP 分类（OWASP Category）：** [A01-A10]
**机密（CONFIDENTIAL）- 请勿公开传播**

## 漏洞信息（Vulnerability）

**类型（Type）：** [XSS / SQL 注入 / 权限绕过 / 等]
**风险等级（Risk Level）：** 致命 Critical | 高 High | 中 Medium | 低 Low
**可利用性（Exploitability）：** [容易 Easy / 中等 Moderate / 困难 Difficult]

## 描述（Description）
[描述漏洞本身，不要提供可直接利用的攻击代码]

## 影响（Impact）
- [ ] 数据泄露（Data exposure）
- [ ] 权限提升（Privilege escalation）
- [ ] 账号接管（Account takeover）
- [ ] 服务中断（Service disruption）
- [ ] 其他（Other）：[说明]

**受影响数据（Affected Data）：** [用户 PII / 支付信息 / 等]

## 验证方式（Proof of Concept）
[描述如何验证问题存在；敏感信息务必脱敏]

## 修复建议（Recommended Fix）
[高层级整改建议/防护思路]

## 参考（References）
- [如适用：CVE]
- [OWASP 参考链接]

## 披露（Disclosure）
- 内部报告日期： [日期]
- 预计修复日期： [日期]
- 公告披露： [不适用 / 日期（如适用）]
```

---

## 崩溃/错误缺陷模板

用于应用崩溃与未处理异常。

```markdown
# BUG-[ID]：[崩溃/错误描述]

**严重程度（Severity）：** 致命 Critical
**类型（Type）：** 崩溃 Crash

## 错误详情（Error Details）

**错误类型（Error Type）：** [崩溃 Crash / 异常 Exception / 卡死 Hang / 白屏 White Screen]
**错误信息（Error Message）：**
```
[原样粘贴错误信息]
```

**堆栈（Stack Trace）：**
```
[完整堆栈]
```

## 复现（Reproduction）

**发生频率（Frequency）：** [必现 Always / 偶现 Intermittent]

1. [触发步骤]
2. [步骤 2]
3. [应用崩溃 / 展示错误]

## 环境（Environment）
- OS： [版本]
- App 版本： [Build]
- 可用内存： [如相关]
- 设备： [型号]

## 日志（Logs）
```
[崩溃前相关日志片段]
```

## 影响（Impact）
- 用户数据丢失： [是/否]
- 会话终止： [是/否]
- 是否可恢复： [是/否]
```

---

## 严重程度定义（Severity Definitions）

| 级别 | 判定标准 | 响应时间 | 示例 |
|------|----------|----------|------|
| **致命（Critical）** | 系统不可用、数据丢失、安全事故 | < 4 小时 | 登录不可用、支付失败、数据泄露 |
| **高（High）** | 核心功能不可用、无替代方案 | < 24 小时 | 搜索不可用、结算失败 |
| **中（Medium）** | 功能部分受影响、有替代方案 | < 1 周 | 筛选缺少选项、加载偏慢 |
| **低（Low）** | 外观问题、罕见边界问题 | 下个版本 | 拼写错误、轻微对齐、罕见崩溃 |

---

## 优先级 vs 严重程度矩阵（Priority vs Severity Matrix）

|  | 低影响 | 中影响 | 高影响 | 致命影响 |
|--|--------|--------|--------|----------|
| **很少（Rare）** | P3 | P3 | P2 | P1 |
| **偶尔（Sometimes）** | P3 | P2 | P1 | P0 |
| **经常（Often）** | P2 | P1 | P0 | P0 |
| **必现（Always）** | P2 | P1 | P0 | P0 |

---

## 标题最佳实践（Bug Title Best Practices）

**好标题（Good Titles）：**
- "[登录] 对有效邮箱不发送密码重置邮件"
- "[结算] 折扣码重复应用两次后，购物车总价显示为 $0"
- "[看板] 加载超过 1000 条记录时页面崩溃"

**差标题（Bad Titles）：**
- "登录有 bug"（太模糊）
- "不行了"（没有上下文）
- "请立刻修！！！"（情绪化、无信息）
- "小问题"（不清楚具体是什么问题）

---

## 缺陷提交流程清单（Bug Report Checklist）

提交前确认：
- [ ] 标题具体、描述性强
- [ ] 复现步骤可由他人复现
- [ ] 期望 vs 实际表述清楚
- [ ] 环境信息完整
- [ ] 证据材料（截图/录屏/日志）已附
- [ ] 已标注严重程度/优先级
- [ ] 已检查重复缺陷
- [ ] 已关联相关项（需求/用例/设计/相似缺陷）

