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

- **[P1] 程序化动画/特效调研 - 解决资源不足的方案** #调研 #特效 #动画
  背景：建筑物、未来可能加入的野怪等实体，难以为它们准备丰富的贴图/动画/特效资源。想看看类似"果冻效果"这种**纯代码/shader 驱动的程序化视觉表现**能覆盖多少场景，能不能作为低保真方案解决"动起来不僵硬、有反馈感"的问题。
  现有参考：[jelly_effect.gd](scripts/effects/jelly_effect.gd)（Tween + scale 压扁→弹性回弹，用于建筑受击反馈）。
  调研方向（建议覆盖）：
  - 程序化动画类：squash & stretch、晃动/摇摆、呼吸缩放、晃动入场、随机抽搐等
  - Shader 类：变形（顶点位移）、波纹/扭曲、轮廓发光/受击闪白、溶解/消失、伪 3D 体积感
  - 粒子类：低成本粒子组合（烟雾/光斑/碎片）作为通用反馈
  - 适用场景对照：建筑物（受击/建造中/升级）、野怪（待机/移动/受击/死亡）、技能效果等
  产出：一份"低成本视觉方案清单"，标注每项的实现成本、适用实体、效果强度
  创建: 2026-08-11
  - [x] **建筑活动视觉设计方案** ✅ 设计完成，待实施
    关联: [docs/design/建筑活动视觉设计方案.md](docs/design/建筑活动视觉设计方案.md)
    完成: 2026-08-11

- **[P1] 升本扩展基地范围** #设计 #平衡 #基地
  当前 [building_placer.gd:21](scripts/systems/building_placer.gd) 的 `BUILD_RADIUS := 6*64 = 384px` 是写死的常量，与时代/科技等级完全无关。想做：「升 T2/T3 时主基地建造范围随之扩大」，让玩家有更明显的成长反馈 + 中后期不至于被 6 格挤死。

  **待调研（CLAUDE.md 强制）**：
  - AoE/SC2/C&C 等是如何处理"基地建造区"随时代扩大的？是直接扩半径、还是用"行政中心/哨站"分阶段解锁区块？
  - 与现有"据点光圈拓展区"机制（[building_placer.gd:144-154](scripts/systems/building_placer.gd)）会不会冲突 / 重叠？是不是该合并成同一套"区域源"系统？
  - 扩大半径数值（T1=384 / T2=? / T3=?）配合单位射程、敌方进攻路径的平衡
  - 视觉反馈：BUILD_RADIUS overlay 圈要不要随升级动画放大？是否需要"范围扩张"特效

  **初步思路**（待聊）：
  - 方案 A：直接动态 `BUILD_RADIUS = base + age * step`，最简单
  - 方案 B：每次升本给主基地挂一个"新区块" ring（类似 activated outpost ring），可视化分阶段
  - 方案 C：把"主基地范围 + 据点拓展区"统一抽象成 `BuildRegionSource` 列表，建造范围 = 所有 source 之并集

  关联: [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd) (`BUILD_RADIUS` / `is_in_buildable_area`), [scripts/main.gd](scripts/main.gd) (`_on_age_upgraded` 之类), [docs/active/T1_PR-4_实施计划.md](docs/active/T1_PR-4_实施计划.md)
  创建: 2026-08-11
  后续: 调研 → 决策方案 A/B/C → 配数值

- **[P0] T3 阶段实施 - 按 PR 顺序写代码** #设计 #t3 #技术设计
  T3 各模块决策稿已聊完，技术设计文档已落地为 4 个 PR。当前进度：
  - ✅ **PR-1** 解锁调整（僧侣/修道院 T2，长矛兵 T3）— 已完成
  - ✅ **PR-2** T3 学院 + N 选 1 升级 — **代码骨架已提交**（commit `ef53e3e`）。**变体视觉 bug 已修**（commit 待提交）：变体 .tscn 补 unit_type / building.gd 兵营产兵路径补 T3 检测 / t3_unit_replacer.gd 修选中列表死引用。剩余 T3 UI 小 bug 见 Bug 区（变体名称/选中图标等）
  - 📋 **PR-3** 终局机制 — 待开始
  - 📋 **PR-4** 塔数值 — 待开始
  关联:
    - 总览：[T3技术设计_00_总览.md](docs/active/T3技术设计_00_总览.md)
    - PR-1：[T3技术设计_01_PR1解锁调整.md](docs/active/T3技术设计_01_PR1解锁调整.md)
    - PR-2：[T3技术设计_02_PR2_T3学院与升级.md](docs/active/T3技术设计_02_PR2_T3学院与升级.md)
    - PR-3：[T3技术设计_03_PR3_终局机制.md](docs/active/T3技术设计_03_PR3_终局机制.md)
    - PR-4：[T3技术设计_04_PR4塔数值.md](docs/active/T3技术设计_04_PR4塔数值.md)
    - 决策稿原件：[A](docs/active/T3阶段设计_A模块经济推演.md) / [C](docs/active/T3阶段设计_C模块决策稿.md) / [C 候选库](docs/active/T3阶段设计_C模块设计候选库.md) / [E](docs/active/T3阶段设计_E模块决策稿.md) / [F](docs/active/T3阶段设计_F模块决策稿.md) / [G](docs/active/T3阶段设计_G模块决策稿.md) / [H](docs/active/T3阶段设计_H模块决策稿.md) / [I](docs/active/T3阶段设计_I模块决策稿.md)
  创建: 2026-08-11
  后续: PR-2 修完变体视觉 bug → PR-3 → PR-4

### Bug

- **[P1] 占领据点后普通建筑造不出来 + 据点圈用途不直观** #bug #据点 #建造 #需调研
  玩家反馈：「占领据点之后某个建筑造不出来了」。**根因已基本定位**（不需要修，但需要聊扩展方向）：

  **当前行为**（[building_placer.gd:125-141](scripts/systems/building_placer.gd) `is_in_buildable_area`）：
  - 占领中据点圈（`_captured_outpost_rings`）**只允许造 ALTAR_ARCHER**（祭坛），其它建筑在圈内一律拒绝
  - 必须等祭坛建完 → `promote_captured_to_activated()` 把圈升级为「拓展区」（`_activated_outpost_rings`）→ 才能在圈内造任意建筑
  - 玩家大概率是占领后想直接圈里造农场/塔/兵营，结果发现「造不出来」，因为还卡在祭坛前置阶段

  **可聊的扩展方向**（用户原话："感觉可以扩展功能，新增建筑过去了"）：
  1. **占领即可造**：去掉祭坛前置，占领据点圈直接变拓展区（祭坛改成可选增益建筑）
  2. **据点分类型**：不同据点解锁不同建筑（军营据点/资源据点/防御据点），玩家选哪个就拓展哪种建筑权
  3. **祭坛作为加速器/特权**：祭坛建在据点圈里给周围单位 buff 或解锁精英兵，不再是"圈地"前置
  4. **可视化引导**：玩家不知道"先造祭坛再解锁" → 加建造提示/圈颜色变化/施工引导

  **关联系统**：[game_ui.gd:552](scripts/systems/game_ui.gd) `show_outpost_category()` 占领后弹据点 tab、[main.gd:678-694](scripts/main.gd) `_on_outpost_captured`。

  关联: [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd) (`is_in_buildable_area` / `add_captured_outpost_ring` / `promote_captured_to_activated`), [scripts/outpost/outpost_commander.gd](scripts/outpost/outpost_commander.gd), [scripts/main.gd](scripts/main.gd) (`_on_outpost_captured`), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd) (`show_outpost_category`)
  创建: 2026-08-11
  后续: 先调研同类游戏（AoE 哨站/SC2 蟑虫巢/C&C 矿场）据点 → 建造扩展设计 → 再决定扩展方向

- **[P1] 底部 UI 遮挡地图下方 + 摄像头限位卡死** #bug #ui #摄像头
  玩家反馈：「底部 UI 条挡住了地图下方一块区域，但摄像头被锁住了，无法下滚看到那块区域」。

  **根因**：[game_camera.gd:88-107](scripts/systems/game_camera.gd) 的 `clamp_camera()` 完全按地图边界算 `max_y = map_bounds.end.y - half_h`，**没把 215px 底部 UI 条的遮挡算进去**。结果：摄像头能下移到地图边界，但屏幕下方 215px 区域被 UI 覆盖，玩家看到的世界坐标被 UI 吃掉一块。

  **修复思路**（待调研同类游戏 + 选方案）：
  1. **限位偏移法**（最简单）：`max_y -= bottom_ui_height / zoom`，把 UI 高度按当前 zoom 换算成世界坐标，从 max_y 里扣掉。UI 是 CanvasLayer 不动，所以一行 clamp 公式即可。
  2. **UI 透传法**：让底部 UI 条半透明 + 鼠标点击透传到地图（F4 Pick 已有，但视觉遮挡还在）
  3. **UI 收纳法**：摄像头下移到下方时自动隐藏/折叠底部 UI 条（动画过渡）
  4. **设计上避开**：地图设计时刻意把下方 215px 留作"非关键内容"（如水/边缘装饰），玩家不需要看

  **待调研**：SC2/AoE2/C&C 等带固定底部 UI 条的 RTS 怎么处理摄像头/地图关系？是 UI 缩进、地图留白、还是限位偏移？

  **已知数据**：
  - 底部 UI 条高度 215px（[bottom_ui_bar.gd:14-19](scripts/ui/bottom_ui_bar.gd)）
  - 摄像头限位 [game_camera.gd:88-107](scripts/systems/game_camera.gd) `clamp_camera()`
  - 地图边界 `map_bounds` 来自 main.gd

  关联: [scripts/systems/game_camera.gd](scripts/systems/game_camera.gd) (`clamp_camera`), [scripts/ui/bottom_ui_bar.gd](scripts/ui/bottom_ui_bar.gd), [scripts/main.gd](scripts/main.gd)
  创建: 2026-08-11
  后续: 调研同类游戏做法 → 选方案 → 修 clamp 公式或改 UI 布局

- **[P0] T3 变体替换后视觉不区分** #bug #t3 #视觉 ✅ 已修复
  所有兵种的 T3 升级替换后，场上单位看起来都是"红色近战兵"。根因：10 个变体 .tscn 漏设 `unit_type`，导致 _load_unit_textures 永远走 SOLDIER 分支加载 Warrior 贴图。同时发现兵营队列产兵路径（_spawn_unit_by_stats_id）漏接 T3 检测，玩家后续造兵仍是基础兵；T3 替换 free 旧单位时未通知 combat_controller 清选中列表，导致右键命令在死引用上崩溃。
  修复：10 个 t3_*.tscn 补 unit_type 字段；building.gd 兵营产兵路径加 T3 变体检测（仅玩家方）；t3_unit_replacer.gd 替换前 remove_dead_unit + 转移选中状态 + 继承 faction_color。
  关联: [scripts/systems/t3_unit_replacer.gd](scripts/systems/t3_unit_replacer.gd), [scripts/buildings/building.gd](scripts/buildings/building.gd), [scenes/units/t3_*.tscn](scenes/units/), [PR-2 文档第十三节](docs/active/T3技术设计_02_PR2_T3学院与升级.md)
  创建: 2026-08-11
  完成: 2026-08-11

- **[P1] Q/W 生产栏图标溢出** #bug #ui
  建筑生产栏（Q/W/E/R... 快捷键）单位种类超过 5 个时，后面的图标在 UI 上排不下、显示不全。需要做自适应布局（横向滚动 / 多行 / 折叠）或者重新设计这个栏的容量。
  关联: [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd)
  创建: 2026-08-11

- **[P1] 长枪兵队列图标显示为步兵** #bug #ui
  在兵营排长枪兵时，详情面板的生产队列里**显示的是基础步兵的图标**，而不是长枪兵。实际造出来是长枪兵（数据正确），只是队列预览图标错了。
  根因方向：队列 UI 取图标时大概率写死了步兵 icon（building.type == BARRACKS 分支默认走步兵 sprite），没根据被造单位 type 切换对应图标。
  关联: [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd)
  创建: 2026-08-11

### UI 优化

- **[P1] T3 精英兵种三选一弹窗 - UI 优化** #ui #t3 #视觉
  T3 三本后弹出的精英兵种 N 选 1 升级弹窗当前太简陋，配不上"终局精英升级"的仪式感，需要重做视觉。

  **现状**（[t3_choice_dialog.gd](scripts/ui/t3_choice_dialog.gd)）：
  - 纯代码拼 PanelContainer（500×400）+ 50% 黑色遮罩
  - 选项卡片 = 40×40 染色色块 + 名字 Label + 描述小字 Label + "确认（X 金）" Button
  - 没有图标 / 数值对比 / hover 反馈 / 快捷键 / 选中态

  **问题**：
  - 视觉扁平，色块看不出兵种特色，玩家无法直观区分三个变体
  - 缺少数值预览，玩家无法对比 HP/DMG/CD/定位差异就做决策
  - 与项目 Tiny Swords 桌游风整体美学脱节
  - 模板未来要复用（其他 N 选 1 场景），值得一次性做好

  **优化方向（待调研展开）**：
  - 加变体立绘/icon（BodySprite 已有资源可复用）
  - 关键数值对比卡片（HP/DMG/CD/移动速度/定位标签）
  - hover 高亮 + 键盘 1/2/3 快捷键 + 选中态确认
  - 参考 Tiny Swords / 种田类 N 选 1 弹窗的视觉范式

  关联: [scripts/ui/t3_choice_dialog.gd](scripts/ui/t3_choice_dialog.gd), [scripts/upgrade/t3_upgrade_data.gd](scripts/upgrade/t3_upgrade_data.gd), [PR-2 文档](docs/active/T3技术设计_02_PR2_T3学院与升级.md)
  创建: 2026-08-11

- **[P1] 兵种测试沙盒场景 - 调研 + 设计 + 实现** #测试 #沙盒 #兵种 #调研
  做一个**交互式兵种验证场景**，专门用来快速测试兵种数值、技能、对位关系。背景：现在好多兵种有问题（视觉 bug / 数值偏差 / 技能异常），缺一个能让人快速摆场景、肉眼验证的沙盒，目前只能开正式关卡试，反馈太慢。

  **核心需求**：
  - **选兵栏**：UI 里选兵种 + 数量 + 阵营（玩家/敌方/中立）+ 升级等级（T1/T2/T3 + 变体）
  - **木桩**：放静态敌人木桩（不同 HP/护甲/类型），测伤害数值、攻击间隔、技能效果
  - **环境控制**：重置 / 清空 / 切换地图 / 暂停-慢放-快进 / 显示伤害飘字 / 显示攻击范围
  - **数值面板**：选中单位显示当前 HP / DMG / CD / 攻击范围 / 移动速度 / 状态
  - **快捷开关**：无限金币 / 无冷却 / 无敌 / 显示 aggro / 显示寻路

  **现有可复用 / 可参考资源**：
  - [stress_test_spawner.gd](scripts/systems/stress_test_spawner.gd) — 已有批量 spawn + 配置驱动逻辑
  - [stress_test.tscn](scenes/maps/stress_test.tscn) — 性能测试场景（自动跑，方向不同）
  - `mass-battle-test` skill — 大规模战斗测试，性能向，流程可借鉴
  - [floating_text.gd](scripts/effects/floating_text.gd) — 伤害飘字（注意层级 bug，见 #bug #ui 区）

  **执行步骤**：
  1. **调研**（CLAUDE.md 强制）：
     - 其他 RTS 的兵种沙盒/调试场景怎么做（SC2 编辑器测试图、AOE 场景编辑器、CoH 单位测试、C&C 工程师沙盒、WC3 训练图）
     - 单位测试夹具结构（auto attack / 技能 / 对位矩阵）
     - 同类游戏的"伤害木桩"标准做法
  2. **设计**：UI 布局（选兵栏放哪、命令栏怎么改造）、配置数据结构、场景切换流程
  3. **实现**：场景 + 脚本 + UI 接入 main.gd 启动入口

  关联: [scripts/systems/stress_test_spawner.gd](scripts/systems/stress_test_spawner.gd), [scenes/maps/stress_test.tscn](scenes/maps/stress_test.tscn), [docs/reference/ui_specs.md](docs/reference/ui_specs.md)
  创建: 2026-08-11
  后续: 先调研（参考 [feedback_design_research_format.md] 四段式 + [feedback_research_methodology_case_first.md] 案例优先）

## 🔧 计划中

_（暂无）_

## ✅ 已完成

- [x] **僧侣解锁条件错误** #bug #解锁 #t2
  升完 T2 直接解锁僧侣/弓兵可凭空造。修复：T2 升级只解锁生产建筑（靶场、修道院），单位（弓兵、僧侣）改由 `building_placer._on_building_construction_finished` 事件触发解锁——玩家方对应生产建筑造好瞬间 append 进 `unlocked_items`，并刷新按钮 affordability。
  关联: [scripts/main.gd](scripts/main.gd) (`_unlock_age_items`), [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd) (`_on_building_construction_finished`), [docs/active/T3技术设计_01_PR1解锁调整.md](docs/active/T3技术设计_01_PR1解锁调整.md)
  创建: 2026-08-11
  完成: 2026-08-11

- [x] **修道院生产队列不可见** #bug #ui
  选中修道院详情面板没有任何生产按钮/队列 UI。根因：[detail_panel.gd](scripts/ui/detail_panel.gd) 的 `match btype` 缺 `MONASTERY` 分支。修复：补上分支调用 `_add_production_progress` + `_add_produce_button(D.PlaceMode.MONK_UNIT)`。
  关联: [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [scenes/buildings/monastery.tscn](scenes/buildings/monastery.tscn)
  创建: 2026-08-11
  完成: 2026-08-11

- [x] **T3 变体单位选中后名称未替换** #bug #ui #t3
  T3 升级后的变体单位选中时，详情面板标题仍显示基础兵种名。修复：`UnitStats` 加 `display_name` 字段，10 个变体 .tres 填入中文名（狂战士/盾卫/神射手/近战杀手/减速射手/精英长矛兵/Boss 杀手/圣光医者/祝福者/烈焰僧侣）；`detail_panel._unit_title` 改签名接 unit 实例，优先返回 `stats_data.display_name`，fallback 基础枚举名。多选分组同步按 `stats_data.id` 区分变体。
  关联: [scripts/stats/unit_stats.gd](scripts/stats/unit_stats.gd), [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [resources/stats/t3_*_stats.tres](resources/stats/)
  创建: 2026-08-11
  完成: 2026-08-11

- [x] **跳字提示层级错误** #bug #ui
  反馈跳字（金币不足、无法建造、队列已满、NO_BARRACKS 等）原本是 Node2D(z_index=20) 挂在世界坐标系，被 CanvasLayer(layer=10) 的底部 UI 条整个遮挡。
  **修复**：新建 `CanvasLayer(layer=15)`，跳字挂进去；为保留"跟随建筑头顶"体验，floating_text 每帧用相机把 world_pos 投影成屏幕坐标（含 zoom），Tween 上浮改为改 _world_pos.y。show_floating_text API 签名零改动，60+ 处调用方不动。
  关联: [scripts/effects/floating_text.gd](scripts/effects/floating_text.gd), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd), [scripts/systems/game_spawner.gd](scripts/systems/game_spawner.gd), [scripts/main.gd](scripts/main.gd)
  创建: 2026-08-10
  完成: 2026-08-11

- [x] **Debug 快捷键 - 测试用加金币** #debug #测试
  按 **F3** 给玩家 +1000 金币，附带鼠标位置黄色跳字反馈。
  关联: [scripts/main.gd](scripts/main.gd) (`_input` 的 `KEY_F3` 分支)
  创建: 2026-08-11
  完成: 2026-08-11

- [x] **T3 阶段设计 - 接着聊设计** #设计 #t3
  T3 终局与扩展的调研（终局框架 + UI 改造决策清单 + 设计定式调研评估），已拆解成 A/C/E/F/G/H/I 多个模块决策稿。
  关联: [T3阶段设计_终局与扩展.md](docs/active/T3阶段设计_终局与扩展.md), [T3阶段设计_详细分析.md](docs/active/T3阶段设计_详细分析.md)
  创建: 2026-08-10
  完成: 2026-08-11

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
