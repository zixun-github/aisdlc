---
title: 前端页面清单（Page Inventory）
status: draft
---

## 0) 页面模块目录（按菜单分组）

| module_name | 页面数 | 说明 | 备注/缺口 |
|---|---:|---|---|
| ... | ... | ... | ... |

## 1) 页面清单（产品视角，按模块分节）

### 1.1 模块：<module_name>

| page_id | page_name | 页面目标（一句话） | 核心任务（Top 3） | 入口（从哪来） | 关键规则摘要（Top 5） | 备注/缺口 |
|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... | ... |

### 1.2 模块：未归类（缺少模块归属证据）

| page_id | page_name | 页面目标（一句话） | 核心任务（Top 3） | 入口（从哪来） | 关键规则摘要（Top 5） | 备注/缺口 |
|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... | gap: 缺少菜单映射证据 |

## 附录：证据（最精简，供研发复核）

### A) 页面级最小证据表

| page_id | module_name | page_name | page_name_evidence | entry_file | route_or_path_evidence | gaps |
|---|---|---|---|---|---|---|
| ... | ... | ... | file:lines | ... | file:lines | ... |

### B) 证据入口（索引）

- FrontendRoots:
  - <path>（证据：file:lines）
- RouteEntrypoints:
  - <path>（证据：file:lines）
- MenuEntrypoints:
  - <path>（静态/后端下发；证据：file:lines）
- AuthEntrypoints:
  - <path>（guard/middleware；证据：file:lines）
- ApiClientEntrypoints:
  - <path>（axios/fetch/client；证据：file:lines）

### C) Evidence Gaps（全局）

- gap: ...
  candidate_locations: ...
  impact: ...
