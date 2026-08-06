# PR-T2-1 实施计划：时代升级机制

- **日期**：2026-08-06
- **阶段**：T2（时代升级 + 科技系统 + UI 改造）
- **状态**：🟡 已做（在另一台机器，待同步到 master）
- **关联**：
  - 总览：[T2_实施路线图.md](T2_实施路线图.md)
  - 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 2.3.2 节（B 模块拍板）

---

## 一、Context

PR-T2-1 是 T2 阶段的第一个 PR，建立"时代升级"机制：玩家花金币 + 时间，把城堡从 T1 升到 T2，解锁 T2 内容（靶场 + 弓兵）。

**已做情况**：用户在另一台机器上完成了本 PR，代码尚未同步到 master。本文档作为**验收 + 同步前核对清单**，代码同步后按本清单跑一遍，确认实现符合设计。

**不依赖**：无前置 PR 依赖。

**后续依赖**：PR-T2-2（T2 内容配置）需要时代升级机制就位才能验证解锁逻辑；PR-T2-5（QW 灰色锁）依赖时代升级状态。

---

## 二、核心交付

### 2.1 时代升级状态机

- 城堡有 `age` 字段（AGE.T1 / T2 / T3）
- 升级流程：T1 → T2 → T3（T3 参数推到 T3 阶段）
- 升级状态：IDLE / UPGRADING / COMPLETED

### 2.2 T1→T2 升级参数（设计 2.3.2 节）

| 项 | 值 |
|---|---|
| 费用 | 500 金 |
| 升级时间 | 15s |
| 完成反还 | 300 金 |
| 升级中城堡状态 | **完全正常**（产金照常、HP 不变）|
| 取消机制 | **可取消全额退款** |
| 失败条件 | 城堡被摧毁 = 游戏失败（沿用现有规则）|

### 2.3 解锁数据层

- 升 T2 后 `available_items` 联动：靶场（ARCHERY_RANGE=8）+ 弓兵（ARCHER=6）加入可建/可造列表
- 升级状态变化的信号（如 `age_changed`）通知 UI / QW 建造栏

### 2.4 城堡头顶进度条

- 升级中的视觉反馈：城堡头顶出现进度条
- 进度条样式：与兵营造兵进度环一致（`production_circle`），或者横向 ProgressBar
- 升级完成 / 取消 → 进度条消失

### 2.5 临时触发（UI 框架未做前）

- 临时键盘快捷键（如 `K` 键）或 debug 按钮触发升级
- 详情面板未做，正式"升级到 T2"按钮留给 PR-T2-3

---

## 三、改动文件清单（推测，待同步核对）

| 文件 | 改动 |
|---|---|
| `scripts/buildings/building.gd` | 加 `age` 字段、`upgrade_state` 字段、升级相关方法 |
| `scripts/buildings/castle.gd`（如存在）或 building.gd 的城堡分支 | 加 `_start_age_upgrade()`、`_cancel_age_upgrade()`、`_complete_age_upgrade()` |
| `scripts/stats/building_stats.gd` | 加 `age_upgrade_cost`、`age_upgrade_time`、`age_upgrade_refund` 字段 |
| `resources/stats/buildings/castle_stats.tres` | T1→T2 升级参数（500/15/300）|
| `scripts/systems/game_data.gd` 或新建 `scripts/systems/age_manager.gd` | 时代升级状态管理 + available_items 联动 |
| `scripts/main.gd` | 升级流程的初始化、信号连接 |
| `scripts/ui/...`（如做了头顶进度条）| 城堡头顶进度条节点 |
| `scripts/units/unit.gd` 或新建 age 字段挂载 | 如果时代影响单位属性，需要相应字段 |

---

## 四、验收点（同步后核对）

### 4.1 升级流程
- [ ] 触发升级 → 扣 500 金，进入 UPGRADING 状态
- [ ] 15s 后升级完成 → 反还 300 金，age=T2
- [ ] 升级中按取消 → 退全款 500 金，状态回 IDLE
- [ ] 升级中再按升级 → 不响应（防重复）

### 4.2 城堡状态
- [ ] 升级中城堡产金照常（每 10s +50 金）
- [ ] 升级中城堡 HP 不变（不因升级而减血）
- [ ] 升级中城堡被攻击 HP 正常下降
- [ ] 升级中城堡被摧毁 → 游戏失败

### 4.3 解锁数据层
- [ ] age=T2 后 available_items 含靶场（type=8）
- [ ] age=T2 后 available_items 含弓兵（type=6）
- [ ] age=T1 时靶场+弓兵不在 available_items
- [ ] 升级状态变化触发信号（具体信号名同步后查代码）

### 4.4 视觉反馈
- [ ] 升级启动 → 城堡头顶出现进度条（位置在城堡上方）
- [ ] 进度条从 0 增长到 100%
- [ ] 升级完成 → 进度条消失，城堡视觉变化（如有，比如颜色/图标）
- [ ] 升级取消 → 进度条立即消失

### 4.5 临时触发
- [ ] 临时快捷键（或 debug 按钮）能触发升级
- [ ] 触发需要满足：金币够 + 城堡是 T1 状态
- [ ] 金币不够 → 提示 "INSUFFICIENT_GOLD" 或类似错误

---

## 五、风险与注意事项

### 5.1 同步前必做
- 在另一机器上跑一遍上述验收点，记录 pass/fail
- 把代码 commit + push 到远程，再在 master 拉取
- 同步后在 master 上再跑一遍验收点（避免合并冲突影响）

### 5.2 已知坑
- **available_items 联动**：现有 `map_config.available_items` 是数组，要确认升级后是修改这个数组还是另起一个 `dynamic_available_items`。建议另起，避免污染地图配置
- **信号命名**：建议 `age_changed(new_age)`、`age_upgrade_started()`、`age_upgrade_completed()`、`age_upgrade_cancelled()`
- **城堡头顶进度条位置**：现有 building.gd 的 `_production_circle` 是给产兵用的，时代升级进度条要区分（不要复用同一个 circle）

### 5.3 后续 PR 衔接
- **PR-T2-3** 会把临时触发改成详情面板的"升级到 T2"按钮
- **PR-T2-5** 会读 age 状态控制 QW 灰色锁
- 信号命名要在 PR-T2-1 阶段定好，避免后续 PR 重命名

---

## 六、关联文档

- 总览：[T2_实施路线图.md](T2_实施路线图.md)
- 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 2.3.2 节
- 后续 PR：[T2_PR-3_实施计划.md](T2_PR-3_实施计划.md)（详情面板接入升级按钮）
