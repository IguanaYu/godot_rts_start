# 项目待办

> 这里只存任务条目和指针。详细内容写到 `docs/` 对应文件里。
> 状态章节：📋 待处理 / 🔧 计划中 / ✅ 已完成 / 💡 灵感
> 多端同步：跟代码一起 git push/pull。手机端用 GitHub Mobile 或 Gitee App 编辑本文件。

---

## 📋 待处理

### 调研后续

- **[P1] 音效系统 - 收集音效素材** #音效 #资源
  调研已完成，方案落地。现在需要自己去收集合适的音效文件（BGM、UI 反馈、单位语音、技能音效等）。
  关联: [docs/research/audio_06_research_summary.md](docs/research/audio_06_research_summary.md), [docs/research/audio_05_sound_inventory.md](docs/research/audio_05_sound_inventory.md), [docs/research/audio_01_free_resources.md](docs/research/audio_01_free_resources.md)
  创建: 2026-08-10

- **[P1] RPG 小型游戏模式 - 接着聊设计** #设计 #rpg
  调研基本完成，单英雄 + AI 群体辅助战的方向已大致确定，但具体机制、关卡节奏、英雄成长曲线等还没详细聊。
  关联: [docs/brainstorming/RPG模式_单英雄辅助战_调研与方案.md](docs/brainstorming/RPG模式_单英雄辅助战_调研与方案.md)
  创建: 2026-08-10
  后续: 接着上次调研结论展开，重点聊机制落地

- **[P1] RTS 核心要素补全 - 接着聊设计** #设计 #rts
  调研已完成，列出了 RTS 缺失的核心要素清单，但优先级、实现顺序、与现有系统的兼容性还没聊。
  关联: [docs/brainstorming/RTS核心要素补全_设计文档.md](docs/brainstorming/RTS核心要素补全_设计文档.md)
  创建: 2026-08-10

- **[P0] T3 阶段设计 - 接着聊设计** #设计 #t3
  T3 终局与扩展的调研已完成（终局框架 + UI 改造决策清单 + 设计定式调研评估）。这是当前主线进展，需要尽快接着聊详细方案。
  关联: [docs/active/T3阶段设计_终局与扩展.md](docs/active/T3阶段设计_终局与扩展.md), [docs/active/T3阶段设计_详细分析.md](docs/active/T3阶段设计_详细分析.md)
  创建: 2026-08-10

### Bug

- **[P0] 跳字提示层级错误** #bug #ui
  一些反馈跳字（如金币不足、无法建造、队列已满、NO_BARRACKS 等）现在显示在底部 UI 条的**下一层**，被底部 UI 遮挡。
  正确层级：除了 ESC 暂停菜单外，跳字提示应该是最高层。

  **现状分析**：
  - `floating_text.gd` 是 `Node2D`（z_index=20），通过 `_main_node.add_child(ft)` 加到主场景世界坐标系
  - 底部 UI 条在 `CanvasLayer(layer=10)` 里（见 [game_ui.gd:206-207](scripts/systems/game_ui.gd)）
  - Godot 中**任何 CanvasLayer 都会盖住普通 Node2D**，无论 z_index 多大 → 这就是被遮挡的原因
  - 暂停菜单在 `CanvasLayer(layer=100)`（见 [game_ui.gd:1146-1147](scripts/systems/game_ui.gd)），是当前最高层

  **修复方向**：
  让 floating_text 挂到一个独立 CanvasLayer，layer 设为 95（高于底部 UI 的 10，低于暂停菜单的 100）。需要同时兼顾"跟随世界坐标"和"高层级渲染"——可以用 CanvasLayer 跟随相机位置，或者把 world_pos 转成屏幕坐标。

  关联: [scripts/effects/floating_text.gd](scripts/effects/floating_text.gd), [scripts/systems/game_spawner.gd](scripts/systems/game_spawner.gd)（L624-628 是 show_floating_text 入口）, [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd)
  创建: 2026-08-10

## 🔧 计划中

_（暂无）_

## ✅ 已完成

_（暂无）_

## 💡 灵感

_（暂无）_

---

## 维护说明

- 完成的任务：把 `-` 改成 `- [x]`，挪到 ✅ 已完成区，补一个 `完成: YYYY-MM-DD`
- 每月或 ✅ 区超过 10 条时：把已完成的挪到 `docs/archived/TODO_archive.md`
- 新增条目时格式：
  ```
  - **[P0/P1/P2] 标题** #标签1 #标签2
    描述。
    关联: [文件名](相对路径)
    创建: YYYY-MM-DD
  ```
- 关联链接用相对路径，VS Code / GitHub / 手机编辑器都能点击跳转
