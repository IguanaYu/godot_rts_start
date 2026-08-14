# 项目待办

> 这里只存任务条目和指针。详细内容写到 `docs/` 对应文件里。
> 状态章节：📋 待处理 / 🔧 计划中 / ✅ 已完成 / 💡 灵感
> 多端同步：跟代码一起 git push/pull。手机端用 GitHub Mobile 或 Gitee App 编辑本文件。

---

## 📋 待处理

### 调研后续

- **[P0] T4 阶段定义 - 确定做什么** #设计 #t4 #规划
  T3 四个 PR 已全部完成（解锁调整 / T3 学院 + N 选 1 升级 / 终局机制 / 塔数值），需要进入下一阶段：**定义 T4 要做什么**。

  **待讨论要点**：
  1. **T4 的玩法定位**：T3 已经做了"终局机制"（胜利/失败条件 + 统计），T4 是往哪个方向走？继续加深战斗深度 / 新经济维度 / 新地图机制 / 英雄系统（呼应 RPG 模式灵感）/ 还是别的？
  2. **与现有系统的关系**：T4 是在 T3 终局框架上加内容（新单位/新建筑/新科技），还是要引入全新系统（如英雄、技能树、天气）？
  3. **范围边界**：T4 是一个大版本还是拆成多个子模块（像 T3 那样分 A-I 模块决策稿）？先定大方向再拆模块？
  4. **优先级排序**：现有 TODO 里几条调研后续（RPG 模式 / RTS 核心补全 / 中立装饰 / 地形优化 / 升本扩展基地）哪些应该纳入 T4，哪些独立推进？
  5. **技术约束**：T3 实施中暴露的问题（如箭矢 use-after-free、据点建造前置不直观）要不要在 T4 开工前先清掉？

  **建议产出**：一份 T4 阶段总览文档（类似 [T3技术设计_00_总览.md](docs/active/T3技术设计_00_总览.md)），列出 T4 的核心目标、模块拆分、优先级、与现有 TODO 的关系。
  创建: 2026-08-13
  后续: 先聊大方向（T4 玩什么）→ 再拆模块 → 落地技术设计文档

- **[P1] 游戏引导系统 - 调研** #设计 #引导 #新玩家
  目前游戏没有新手引导/教程，玩家进来直接面对完整 UI，不知道先做什么、怎么造建筑、怎么出兵、怎么赢。需要调研同类 RTS（AoE/SC2/WC3/They Are Billions/Diplomacy is Not an Option）的引导设计，看看哪些模式适合本项目。
  
  **待调研方向**：
  1. **引导形式**：弹出文字提示框 / 高亮按钮 / 箭头指向 / 强制分步操作 / 自由探索+可选提示 / 可跳过
  2. **引导内容**：第一局核心流程（造第一个建筑→造第一个兵→占领第一个据点→升级时代→推掉敌方基地）
  3. **引导时机**：开局一次性 / 触发式（玩家首次做某操作时弹出）/ 持续可查的帮助面板
  4. **复用性**：引导系统能不能做成数据驱动（配置表驱动步骤），方便后续加新引导
  5. **同类游戏参考**：每个游戏的引导模式、优缺点、适合本项目程度的评估
  
  创建: 2026-08-13
  后续: 调研 → 聊引导模式 → 决定要不要做、做哪种

- **[P1] 操作优化 - Tab 建造栏与快捷键体验** #设计 #ux #操作
  当前底部 UI 的建造栏（建筑/兵种）切换体验不够直观，经常出现"所见非所得"的问题。

  **现状问题**：
  - 玩家选中建筑后，底部栏常停留在"造建筑"tab，但此时按 Tab 会切换到"造兵"tab，视觉上不直观
  - 理想情况是"不建造时显示框选部队信息"，建造时按 QWERASDF 直接造，但 QWERASDF 和造兵快捷键冲突
  - 建造栏的显示/隐藏逻辑与玩家当前选中状态（建筑/单位/空地）之间的关联不够清晰

  **待决策方向**：
  1. **Tab 行为**：方案 A — 第一按激活当前菜单（直接可造），再按才切换；方案 B — 通过点击或 Esc 解锁 Tab 建造时，自动退回造兵栏
  2. **显示规则**：不建造时底部栏显示什么？框选部队详情 / 建造栏隐藏 / 只显示快捷键提示
  3. **快捷键冲突**：QWERASDF 在"建造模式"和"造兵模式"下复用同一组键，怎么区分？需要明确模式切换机制
  4. **同类 RTS 参考**：AoE2/SC2/WC3/They Are Billions 的建造栏快捷键是怎么处理的？模式切换 vs 直接快捷键

  关联: [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd), [scripts/ui/bottom_ui_bar.gd](scripts/ui/bottom_ui_bar.gd)
  创建: 2026-08-13
  后续: 先调研同类 RTS 的快捷键模式 → 聊决策方案 → 落地

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
  - [x] **程序化动画与特效调研报告** ✅ 调研完成
    覆盖 shader 6 项（顶点位移/Dissolve/轮廓发光/波纹/伪3D/色差）+ 同类游戏案例 + 粒子方案
    关联: [docs/design/程序化动画与特效调研报告.md](docs/design/程序化动画与特效调研报告.md)
    完成: 2026-08-13
  - [x] **程序化特效落地总方案** ✅ 设计完成
    实体×状态→特效对照表（单位/建筑/投射物/技能）+ 基础能力升级前置 + 配置说明
    关联: [docs/design/程序化特效落地总方案.md](docs/design/程序化特效落地总方案.md)
    完成: 2026-08-13

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

- **[P0] T3 阶段实施 - 按 PR 顺序写代码** #设计 #t3 #技术设计 ✅ 4/4 PR 全部完成
  T3 各模块决策稿已聊完，技术设计文档已落地为 4 个 PR。当前进度：
  - ✅ **PR-1** 解锁调整（僧侣/修道院 T2，长矛兵 T3）— 已完成
  - ✅ **PR-2** T3 学院 + N 选 1 升级 — 代码骨架已提交（commit `ef53e3e`），变体视觉 bug 已修（commit `9c4fe2c`）。剩余 T3 UI 小 bug 见 Bug 区（变体名称/选中图标等）
  - ✅ **PR-3** 终局机制 — 已完成（commit `876694b`）：5 项战斗统计埋点 + 胜利/失败面板 + 开局一次性提示 + 目标面板接入 + 修 `ERA_LOCKED` 译项。注：开局提示组件实际命名为 `intro_hint_dialog.gd`，与设计文档的 `opening_hint.gd` 不一致
  - ✅ **PR-4** 塔数值 — 已完成：HP180 / DMG14 / 射程220 / 递增+50 防塔海。修两个文档漏写的致命冲突（tower_standard 才是正常对局真源 / get_by_type 歧义用三卡同写 cost_increment 绕过），顺手清理 cost_override 死字段 + detail_panel 悬停动态价 + building.gd 兜底。详见 [PR-4 文档第六节](docs/active/T3技术设计_04_PR4塔数值.md)
  关联:
    - 总览：[T3技术设计_00_总览.md](docs/active/T3技术设计_00_总览.md)
    - PR-1：[T3技术设计_01_PR1解锁调整.md](docs/active/T3技术设计_01_PR1解锁调整.md)
    - PR-2：[T3技术设计_02_PR2_T3学院与升级.md](docs/active/T3技术设计_02_PR2_T3学院与升级.md)
    - PR-3：[T3技术设计_03_PR3_终局机制.md](docs/active/T3技术设计_03_PR3_终局机制.md)
    - PR-4：[T3技术设计_04_PR4塔数值.md](docs/active/T3技术设计_04_PR4塔数值.md)
    - 决策稿原件：[A](docs/active/T3阶段设计_A模块经济推演.md) / [C](docs/active/T3阶段设计_C模块决策稿.md) / [C 候选库](docs/active/T3阶段设计_C模块设计候选库.md) / [E](docs/active/T3阶段设计_E模块决策稿.md) / [F](docs/active/T3阶段设计_F模块决策稿.md) / [G](docs/active/T3阶段设计_G模块决策稿.md) / [H](docs/active/T3阶段设计_H模块决策稿.md) / [I](docs/active/T3阶段设计_I模块决策稿.md)
  创建: 2026-08-11
  后续: 无（T3 四个 PR 全部完成）

- **[P1] 中立装饰优化 - 聊功能定位** #装饰 #地图 #设计
  树木/草丛/石头等中立装饰现在只是视觉摆放，需要重新讨论它们在玩法中的角色。背景：现有 [scenes/environment/](scenes/environment/) 下有 tree/rock/bush 三个 .tscn，[scenes/terrain/](scenes/terrain/) 下有 terrain_rock/terrain_forest，但功能定义不清晰。

  **待讨论要点**：
  1. **碰撞体积**：哪些装饰挡单位走位（树?石头?草?）、哪些纯视觉可穿过？现有 [terrain_obstacle.gd](scripts/terrain_obstacle.gd) 是否覆盖所有需要碰撞的装饰？
  2. **遮蔽视野**：装饰是否要挡单位选中/点击命中？是否影响 aggro/射程判定？
  3. **视觉层次**：装饰与单位/建筑重叠时的 z_index 规则，单位走到树后面应该被遮挡还是覆盖树？
  4. **对战术的影响**：是否有意用装饰做"天然掩体/卡点位"？还是纯粹美观、不参与玩法？
  5. **性能与批量**：地图上装饰数量上限、是否需要 MultiMesh/instance 化批量绘制
  6. **可破坏性**：装饰能否被单位/技能打掉？打掉后碰撞和视野怎么更新？

  关联: [scenes/environment/](scenes/environment/) (tree/rock/bush.tscn), [scenes/terrain/](scenes/terrain/) (terrain_rock/terrain_forest.tscn), [scripts/terrain_obstacle.gd](scripts/terrain_obstacle.gd), [docs/brainstorming/中立物设计_PVE视角调研.md](docs/brainstorming/中立物设计_PVE视角调研.md)
  创建: 2026-08-12
  后续: 调研已完成（PVE 视角意义重估 + 现状盘点），待勾选机制候选（A 可破坏物 / B 资源点 / C creeps / D 驻扎 / E 草丛）→ 进入功能定位

- **[P1] 地形视觉优化 - 多色地形与绘制流程** #地形 #视觉 #设计
  现状：[terrain_layer.gd](scripts/terrain_layer.gd) 只用 `TILE_TEXTURES[theme_index]` 一张纯色草地铺满全图，但素材里实际有 `Tilemap_color1.png` 到 `Tilemap_color5.png` 五种色调（含深绿），还有 `Water Background color.png`。当前地图整体是单一浅绿色，缺乏层次。

  **待讨论要点**：
  1. **现有素材盘点**：5 张 color 贴图分别是什么色调？atlas 里还有哪些 tile 可用（路径/边缘/过渡 tile）？water 之外有没有沙地/雪地/泥地？
  2. **自动地形算法**：按 biome 分块上色？噪声扰动？按高度/距离水源渐变？是否需要规则驱动的"自动生成地形外观"工具
  3. **手动绘制流程**：是否引入 TileMap 编辑器手绘？地图作者怎么标记"这片是深绿、这片是浅绿"？配置存在哪（map_config / .tscn / .tres）
  4. **信息密度**：颜色要不要承担功能含义（如危险区/资源区/双方出生点用不同底色），还是纯视觉？
  5. **与装饰/建筑搭配**：颜色变化与中立装饰（树/石/草丛）的分布要不要联动（如深绿区多树、浅绿区开阔）？
  6. **过渡效果**：颜色块之间要不要平滑过渡（边缘 tile / shader 混合），还是硬切？

  关联: [scripts/terrain_layer.gd](scripts/terrain_layer.gd) (`TILE_TEXTURES` / `_build_tileset` / `set_cell`), [scripts/map_config.gd](scripts/map_config.gd), [scenes/maps/](scenes/maps/)
  创建: 2026-08-12
  后续: 先盘素材（开 5 张贴图 + atlas 看可用 tile），再聊"自动 vs 手动"方向

- **[P1] 整理文档 - 生成游戏现状描述文档** #文档 #现状
  项目文档已经积累了不少（设计/调研/技术方案/PR 文档），但缺少一份**统一的游戏现状描述文档**，让新读者（或自己隔段时间回来）能快速了解：当前游戏是什么样、有哪些系统、到什么阶段、还有哪些已知问题。
  产出：一份 `docs/active/游戏现状描述.md`，覆盖玩法概述 / 已实现系统清单 / 单位与建筑一览 / 经济与科技树 / 地图与视觉 / 已知问题与限制 / 下一步计划。
  创建: 2026-08-13

### Bug

- **[P1] 箭矢命中已死目标刷 SCRIPT ERROR（arrow.gd:62 use-after-free）** #bug #箭矢 #塔
  箭矢（塔/弓箭手射出）命中目标时，若目标在箭飞行途中死亡被回收，[arrow.gd:62](scripts/effects/arrow.gd) 的 `effect.apply(self, hit_target)` 拿到 freed 对象，刷 `SCRIPT ERROR: ...previously freed...`。根因：L55 的 `take_damage` 有 `is_instance_valid` 守卫，但 L60-62 给目标施加 effects 的循环漏了守卫。
  **与 PR-4 关系**：根因预先存在，但 PR-4 把塔射程 150→220 后箭飞行时间变长，目标途中死亡概率上升，触发更频繁（实测日志刷 2 次）。
  **修复**（极简）：L62 effect 循环前复用 L55 有效性判断，目标无效时跳过施加 effects。
  关联: [scripts/effects/arrow.gd](scripts/effects/arrow.gd) (`_on_hit` L48-62), [scripts/buildings/building.gd](scripts/buildings/building.gd) (`_spawn_arrow` L532)
  创建: 2026-08-13

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

- **[P0] T3 变体替换后视觉不区分** #bug #t3 #视觉 ✅ 已修复
  所有兵种的 T3 升级替换后，场上单位看起来都是"红色近战兵"。根因：10 个变体 .tscn 漏设 `unit_type`，导致 _load_unit_textures 永远走 SOLDIER 分支加载 Warrior 贴图。同时发现兵营队列产兵路径（_spawn_unit_by_stats_id）漏接 T3 检测，玩家后续造兵仍是基础兵；T3 替换 free 旧单位时未通知 combat_controller 清选中列表，导致右键命令在死引用上崩溃。
  修复：10 个 t3_*.tscn 补 unit_type 字段；building.gd 兵营产兵路径加 T3 变体检测（仅玩家方）；t3_unit_replacer.gd 替换前 remove_dead_unit + 转移选中状态 + 继承 faction_color。
  关联: [scripts/systems/t3_unit_replacer.gd](scripts/systems/t3_unit_replacer.gd), [scripts/buildings/building.gd](scripts/buildings/building.gd), [scenes/units/t3_*.tscn](scenes/units/), [PR-2 文档第十三节](docs/active/T3技术设计_02_PR2_T3学院与升级.md)
  创建: 2026-08-11
  完成: 2026-08-11

- **[P1] 长枪兵队列图标显示为步兵** #bug #ui
  在兵营排长枪兵时，详情面板的生产队列里**显示的是基础步兵的图标**，而不是长枪兵。实际造出来是长枪兵（数据正确），只是队列预览图标错了。
  根因方向：队列 UI 取图标时大概率写死了步兵 icon（building.type == BARRACKS 分支默认走步兵 sprite），没根据被造单位 type 切换对应图标。
  关联: [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd)
  创建: 2026-08-11

- **[P1] 科技已解锁但钱不够时仍可点击建造** #bug #ui #科技
  现象：科技解锁了某建筑、但金币不够时，建造栏按钮看起来仍可点击，玩家点了之后兵营区照样能"建造"（应该被拦截）。

  **疑点**：[game_ui.gd:1117-1118](scripts/systems/game_ui.gd) 写的是 `btn.disabled = not ok and not era_locked`——设计本意是让 ERA_LOCKED 状态保持 enable（这样点击能触发"需 T2 时代"飘字），但当 `reason == NO_GOLD` 时 `era_locked=false`、`ok=false`，公式算出来 disabled=true，**应该 disable**。所以现象的成因可能是：
  1. 按钮 affordability 没及时刷新（跟上一条 bug ② 同根）
  2. 或者点击穿透到 `_quick_produce_unit` / `_do_place`，而那里的拦截顺序不对
  3. 或者建造区按钮的 click handler 没读 disabled 状态

  **期望行为**：点击钱不够的建筑按钮 → 立即在鼠标位置/城堡头顶飘字"金币不足"，**不进入放置模式**。
  关联: [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd) (`_update_button_affordability`), [scripts/main.gd](scripts/main.gd) (`_on_place_mode_requested` / `_quick_produce_unit`), [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd) (`check_build_block`)
  创建: 2026-08-11

### UI 优化

- **[P2] 底部装饰水带视觉美化** #ui #视觉 #地形 #摄像头
  现状：为修"底部 UI 遮挡地图下方"（见 ✅ 已完成的摄像头限位修复），在地图正下方加了一条 64 世界单位（≈1 tile）高的装饰水带（`BOTTOM_SKIRT_H`，由 `_replace_ground_with_terrain` 往 `water_areas` 追加一条底部 Rect2 实现）。功能上生效了——相机滚到底时地图底落在 UI 条上方、单位不贴 UI——但**水带目前就是一条平铺的纯水 tile，很突兀、很丑**（玩家原话："水带好丑"），跟上方草地硬切，没有过渡。

  **可聊的美化方向**：
  1. **岸边过渡 tile**：草地→水之间用沙滩/浅滩边缘 tile 做渐变（需要 atlas 里有过渡 tile，或程序化混合）
  2. **深浅渐变**：水带本身用 shader/顶点色做近岸浅→远岸深的渐变，避免纯色平铺
  3. **波纹/反光细节**：低成本粒子或 shader 动画（水面微微流动/光斑），呼应 [程序化动画/特效调研](docs/...) 的低成本视觉方案
  4. **换装饰类型**：水带是不是最佳选择？也可以是"沼泽/碎石/暗色不可走区"，或干脆用 vignette/暗角让边缘自然淡出，不用具体 tile
  5. **厚度自适应**：当前固定 64，矮图（如 map1 600 高）占比 ~10% 明显；可按地图高度比例或按 zoom 动态调

  **已知数据**：
  - 水带高度常量 [D.BOTTOM_SKIRT_H = 64.0](scripts/systems/game_data.gd)（=1 tile）
  - 生成位置 [main.gd `_replace_ground_with_terrain`](scripts/main.gd)（追加底部 Rect2 到 water_areas）
  - 铺水逻辑 [terrain_layer.gd](scripts/terrain_layer.gd)（`water_areas` 循环 set_cell，现仅纯色水 tile）
  - 不影响寻路：`nav_bounds` 未扩，单位仍锁原可玩区，水带纯视觉

  关联: [scripts/systems/game_data.gd](scripts/systems/game_data.gd) (`BOTTOM_SKIRT_H`), [scripts/main.gd](scripts/main.gd) (`_replace_ground_with_terrain`), [scripts/terrain_layer.gd](scripts/terrain_layer.gd)
  创建: 2026-08-13
  后续: 先聊方向（过渡 tile vs shader 渐变 vs 换装饰类型），再决定要不要动 terrain_layer 核心铺水逻辑

- **[P1] 建造预览视觉优化 - 半透明贴图 + 着色方块** #ui #视觉 #建造
  现状：建造模式鼠标跟随预览只有绿色/红色方块（ColorRect），看不出将来造出来的建筑长什么样。期望：半透明建筑贴图 + 颜色方块叠加（valid=绿、invalid=红），让玩家在落点前就能预览建成效果。

  **现状调研**（待实施前补全）：
  - 预览节点生成在 [building_placer.gd](scripts/systems/building_placer.gd) 的 preview/ghost 相关代码（需读完整文件确认是 ColorRect 还是 Polygon2D）
  - 建筑贴图来源：[D.ICON_TEXTURES](scripts/systems/game_data.gd) 是 spritesheet 切帧，但那是 icon 用的；建筑本体的落地贴图需要另找（scenes/buildings/*.tscn 里的 BodySprite 引用）

  **设计要点**（待聊）：
  1. **半透明度**：贴图 alpha 建议 0.5-0.6，既能看清建成效果又不喧宾夺主
  2. **颜色叠加方式**：贴图下面垫 ColorRect（绿/红）还是用 sprite 的 modulate 染色？前者贴图原色保真，后者实现更简单但会让贴图偏色
  3. **范围圈同步**：当前预览是否带建造范围圈（BUILD_RADIUS）？要不要在预览期间也显示该建筑自身的攻击范围/产出范围？
  4. **invalid 反馈**：超出建造范围时除了变红，要不要加震动/叉号/禁止图标？
  5. **贴图缩放**：预览贴图必须跟实际建造出来的 scale 完全一致（含 sprite_scale 三重乘积规则，见 [feedback_unit_scene_setup.md]）

  **待调研**：同类 RTS（AoE2/SC2/C&C/BD）的建造预览怎么做的？是 ghost 贴图、线框、还是颜色块？valid/invalid 着色惯例？
  关联: [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd), [scenes/buildings/](scenes/buildings/), [scripts/systems/game_data.gd](scripts/systems/game_data.gd) (`ICON_TEXTURES`)
  创建: 2026-08-11

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

### 程序化特效落地（按 ROADMAP 推进）

- **[P1] 程序化特效落地 - 7 个 PR 按基础优先顺序推进** #特效 #实施
  设计已完成（[落地总方案](docs/design/程序化特效落地总方案.md)），ROADMAP 拆为 7 个 PR + 测试沙盒。每个 PR 在沙盒里独立验证。

  **PR 列表**：
  - 📋 **PR-0** 测试沙盒场景（极简版）— spawn 单位/木桩 + 时间控制 + 详情面板
  - 📋 **PR-1** Shader 接入 + Dissolve — 5 个 uniform 接入 + 单位死亡消散
  - 📋 **PR-2** 粒子对象池 + 配方库 — ParticlePool Autoload + 6 种基础配方
  - 📋 **PR-3** UnitVisualFeedback 组件 — 受击/攻击冲量/护盾环/持续状态
  - 📋 **PR-4** BuildingActivityVisual 组件 — 9 种建筑活动反馈
  - 📋 **PR-5** 命中粒子 + 屏幕后处理 — hit_spark + 冲击波/色差
  - 📋 **PR-6** 指挥官技能视觉升级 — 8 个技能释放瞬间 + 持续效果
  - ⏸ **PR-7** T3 变体专属视觉（可延后）— 等玩家真解锁 T3 再说

  关联: [docs/active/程序化特效落地_ROADMAP.md](docs/active/程序化特效落地_ROADMAP.md)
  创建: 2026-08-13
  后续: 从 PR-0 开始，按顺序推进

## ✅ 已完成

- [x] **Q/W 生产栏图标溢出** #bug #ui
  建筑生产栏（Q/W/E/R... 快捷键）单位种类超过 5 个时，后面的图标在 UI 上排不下、显示不全。修复：自适应横向滚动。
  关联: [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd)
  创建: 2026-08-11
  完成: 2026-08-13

- [x] **科技前置解锁提示显示英文 key** #bug #ui #翻译 #科技
  点击未解锁科技的建筑按钮时，飘字提示显示英文翻译 key（如 "ERA_LOCKED"）。根因：translations.csv 缺 `ERA_LOCKED` / `ERA_LOCKED_HINT` 译项，Godot tr() 回退成 key 本身。修复：translations.csv 补两行译项。
  关联: [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd) (`reason_to_translation_key`), [scripts/main.gd](scripts/main.gd) (`_show_era_locked_hint` / `_quick_produce_unit` / `_do_place`), [locales/translations.csv](locales/translations.csv)
  创建: 2026-08-11
  完成: 2026-08-13

- [x] **底部 UI 遮挡地图下方 + 摄像头限位卡死** #bug #ui #摄像头
  底部 215px UI 条遮住地图下方，`clamp_camera()` 没把 UI 高度算进限位，玩家滚不到被遮区。
  **方案 A+B**：A 限位偏移（`max_y = end.y - half_h + BOTTOM_UI_PX/zoom`）+ B 底部装饰水带（`map_bounds` 向下扩 64 单位铺水，`nav_bounds` 不变 → 单位仍锁原区，水带软化地图底边）。
  **⚠️ 符号纠正**：原 TODO/初版调研写的是 `max_y -= bottom_ui_height/zoom`（减号），**错的**。推导验证（窗高 1000/zoom 1/地图底 y 1000）：当前 max_y=500 时屏幕底=地图底，但 UI 遮 [785,1000]，玩家只见 [0,785]；正解是相机往下多滚到 715（`1000-500+215`）让地图底抬到 UI 顶——**符号是 +**。减号会让相机滚得更少、遮更多。
  另顺带修：① 边缘滚动豁免矩形有两个都坏（228 块因时序 camera_module 为 null 从未生效；132 块高度错且无消费者）→ 统一为 `D.BOTTOM_UI_PX` 矩形在 Step 4 注入；② 215/228/132 三个魔法数统一到 `game_data.gd` 的 `BOTTOM_UI_PX`/`BOTTOM_SKIRT_H`；③ 兜底分支（地图比视图矮）改为居中到【可见区】而非视口几何中心，避免居中后底仍被遮。
  关联: [scripts/systems/game_camera.gd](scripts/systems/game_camera.gd) (`clamp_camera`), [scripts/systems/game_data.gd](scripts/systems/game_data.gd) (`BOTTOM_UI_PX`/`BOTTOM_SKIRT_H`), [scripts/main.gd](scripts/main.gd) (`_load_from_config`/`_replace_ground_with_terrain`/豁免矩形), [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd) (删 panel_rect), [scripts/ui/bottom_ui_bar.gd](scripts/ui/bottom_ui_bar.gd)
  创建: 2026-08-11
  完成: 2026-08-13

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

- [x] **进游戏初始时所有建筑按钮都显示为可点亮** #bug #ui #科技
  刚进游戏（T1 时代，金币有限）时，建造栏所有建筑按钮看起来都是"亮"的，但科技未解锁或金币不够，应该灰显。
  根因：[game_ui.gd](scripts/systems/game_ui.gd) `_update_button_affordability` 只在金币变化/解锁事件时被调用，进游戏初始化路径漏调一次，首屏按钮全是默认状态（亮）。
  修复：[main.gd](scripts/main.gd) `_run_init_steps` Step 10 末尾补一次 `update_gold_display(gold)`，确保所有系统就绪后按钮首次刷新灰显/锁图标/价格颜色（commit `5f55c86`）。
  关联: [scripts/systems/game_ui.gd](scripts/systems/game_ui.gd) (`_update_button_affordability`), [scripts/main.gd](scripts/main.gd) (`_run_init_steps`), [scripts/ui/bottom_ui_bar.gd](scripts/ui/bottom_ui_bar.gd)
  创建: 2026-08-11
  完成: 2026-08-12

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
