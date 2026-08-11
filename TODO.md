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

- **[P0] 僧侣解锁条件错误** #bug #解锁 #t2
  当前**升完二本（T2）就直接解锁僧侣**，可以凭空造僧侣。但设计意图（见 PR-1 文档）：T2 只解锁**修道院**建筑，**僧侣**必须等修道院造好后由修道院生产。
  正确行为：
  - T2 升级完成 → QW 网格里"修道院"按钮解锁（✅ 当前正常）
  - 修道院建造完成 → 详情面板才有"造僧侣"按钮（❌ 当前没造修道院也能造僧侣）
  根因方向：解锁系统只看 age（科技等级），没有把"对应生产建筑是否存在"作为前置条件。弓兵应该也有同样问题（造完靶场才能造弓兵），需要一起核对。
  关联: [docs/active/T3技术设计_01_PR1解锁调整.md](docs/active/T3技术设计_01_PR1解锁调整.md), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd), [scripts/buildings/building_placer.gd](scripts/buildings/building_placer.gd)
  创建: 2026-08-11

- **[P1] 修道院生产队列不可见** #bug #ui
  选中修道院时，详情面板看不到生产队列（正在造的僧侣 + 排队数量 + 进度）。其他生产建筑（兵营、靶场）的队列显示正常，修道院缺失。
  根因方向：修道院详情面板的构建逻辑可能漏接了 production_queue 渲染部分，或修道院的 building type 没走到通用的队列 UI 分支。
  关联: [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [scripts/buildings/building.gd](scripts/buildings/building.gd), [scenes/buildings/monastery.tscn](scenes/buildings/monastery.tscn)
  创建: 2026-08-11

- **[P1] 长枪兵队列图标显示为步兵** #bug #ui
  在兵营排长枪兵时，详情面板的生产队列里**显示的是基础步兵的图标**，而不是长枪兵。实际造出来是长枪兵（数据正确），只是队列预览图标错了。
  根因方向：队列 UI 取图标时大概率写死了步兵 icon（building.type == BARRACKS 分支默认走步兵 sprite），没根据被造单位 type 切换对应图标。
  关联: [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd)
  创建: 2026-08-11

- **[P1] T3 变体单位选中后名称未替换** #bug #ui #t3
  T3 升级后的变体单位（如 champion_offense、archer_marksman、monk_saint 等）选中后，详情面板标题仍然显示基础兵种名（"步兵"/"弓兵"/"僧侣"），没有换成变体名。
  根因方向：[detail_panel.gd:330](scripts/ui/detail_panel.gd) 的 `_unit_title(utype)` 只 match 基础 `UnitType` 枚举（SOLDIER/ARCHER/LANCER/MONK），完全没读 T3 变体字段（variant_id / t3_variant / upgrade_state 之类）。修复时需要让标题根据"基础类型 + 变体 id"查出变体本地化名（如 `ENTITY_T3_CHAMPION_OFFENSE`）。同类问题可能在多选标题、建筑标题（学院变体）也存在。
  关联: [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd)（`_unit_title` / `_building_title`）, [scripts/upgrade/t3_upgrade_data.gd](scripts/upgrade/t3_upgrade_data.gd), [locales/translations.csv](locales/translations.csv)
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
