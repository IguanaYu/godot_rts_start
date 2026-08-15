# 项目待办

> 这里只存任务条目和指针。详细内容写到 `docs/` 对应文件里。
> 状态章节：📋 待处理 / 🔧 计划中 / ✅ 已完成 / 💡 灵感
> 多端同步：跟代码一起 git push/pull。手机端用 GitHub Mobile 或 Gitee App 编辑本文件。

---

## 📋 待处理

### 文档复核

- **[P1] game/ 三篇本体文档复核 - 修正 AI 推断内容** #文档 #game
  文档体系重组时新建的 3 篇游戏本体文档是 AI 从 git log / TODO / 目录扫描提炼的初稿，其中标注 `?` 的内容是推断，需要人工校准。

  **复核点**：
  1. [overview.md](docs/game/overview.md) — 玩法系统清单表格是否齐全；画风描述（像素风 / Pipoya 素材）是否准确；设计基调几条是否符合本意
  2. [architecture.md](docs/game/architecture.md) — 带 `?` 的目录职责推断（`server/` 用途、`resources/` 与 `stats/` 分工、`environment/` 等）；关键机制（统一游戏时间 / 寻路 / ProjectileData 接线现状）是否与当前代码一致
  3. [progress.md](docs/game/progress.md) — 前期时间线（2026 春~夏）与"模式展望"是否符合实际

  顺带浏览一遍 [docs/README.md](docs/README.md) 的索引描述，"何时查它"写得不对的顺手改。
  创建: 2026-08-14
  后续: 改完此条标记完成，文档转为随开发持续维护

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
  - [x] **跨游戏与设计原则调研** ✅ 2026-08-14 完成
    结论：引导的四层目的（缩短 Time to Fun / 建立胜任感 / 管理认知负荷 / 设定预期）+ 原则表（做>读、Prime→Teach→Observe、自适应提示等）；RTS 案例盘点（AoE2 教学战役 / WC3 序章 / 星际2 教程反面对照 / R6S 情境最佳实践 / 亿万僵尸与 DiNO 反面 / Stormgate 观察）；**关键发现：经典 RTS 战役系统性教出"龟缩流"，与本项目进攻向定位直接冲突——第一局必须把"主动进攻"放在教学序列前半段**
    报告: [docs/research/product/游戏引导系统_跨游戏与设计原则调研.md](docs/research/product/游戏引导系统_跨游戏与设计原则调研.md)
  后续: 聊引导模式（重点决策：教学局独立 vs 正常局叠约束 / 引导终点只教操作还是教"进攻心智" / 进不进 T4）→ 决定要不要做、做哪种

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

- **[P1] 建筑环境动效 - "活着"感与动效锚点调研** #设计 #视觉 #建筑
  背景：建筑目前是一张静态贴图，即使接了受击/生产反馈特效，平时看起来还是"死的"。核心想法：**设计建筑贴图时就预留"动效锚点"**（烟囱、窗户、小场地等结构），后期往锚点上挂轻量动效，传达"有人在里面工作"的生命感（Anno/Settlers 式立体模型 diorama 做法）。

  **原始灵感（按信息量归三类）**：
  1. **纯氛围型**（无功能含义，让画面活起来）：烟囱冒烟、旗帜飘动、风车转动
  2. **状态传达型**（动效 = 建筑工作状态可视化）：
     - 训练场：建筑上开一小块区域，里面有个小人在击剑 → 一眼看出兵营在产兵
     - 窗户亮光/不亮 → 后期表达"工作中/空闲"（或昼夜）
  3. **设计规范型**（最重要的产出）：新建筑美术设计必须带**动效锚点清单**，否则贴图画完再想加烟囱就得重画

  **待调研方向**：
  1. **同类游戏**：Northgard / They Are Billions / Settlers / Anno / Kingdom Two Crowns 的建筑 idle 动画做法、信息量、成本
  2. **技术实现**：GPUParticles 烟雾、贴图分层（烟囱/窗户单独一层 sprite）、shader 局部动画、微型小人（复用现有单位贴图缩小 or 专用贴图）
  3. **与现有系统整合**：并入 BuildingActivityVisual 组件（特效 PR-4）还是独立 AmbientVisual 组件；要不要写进 T4 A.3 美术规范
  4. **成本分级**：每建筑一个专属动效 vs 通用锚点系统（任意建筑配置 `chimney: true` / `window_light: true` 即生效）

  关联: [docs/plans/程序化特效落地总方案.md](docs/plans/程序化特效落地总方案.md), [docs/plans/建筑活动视觉设计方案.md](docs/plans/建筑活动视觉设计方案.md)
  创建: 2026-08-14
  - [x] **跨游戏与技术调研** ✅ 2026-08-14 完成
    结论：四支柱框架（锚点/演员/状态/随机，源自 Anno 官方 devblog）；现有贴图零烟囱但窗户普遍存在 → 窗光/小人/残血燃烧零美术即可做；独立 AmbientVisual 组件不并入 PR-4；成本 L0-L3 分级，L1 零新美术为主力
    报告: [docs/research/product/建筑环境动效_跨游戏与锚点系统调研.md](docs/research/product/建筑环境动效_跨游戏与锚点系统调研.md)
  - [x] **全品类扩展：动效友好美术设计调研 + 设计清单** ✅ 2026-08-14 完成
    把"预留锚点"从建筑扩展到角色/地形/投射物/UI。术语表（idle vs ambient / diegetic / attachment points）+ 五品类案例（含角色特效携带物=魔法壶模式的 Dota 工业验证）+ 规律九条；产出做资产前直接对照的标准文档（含 AI 提示词模板与负面约束）
    调研: [docs/research/product/动效友好美术设计_跨游戏调研.md](docs/research/product/动效友好美术设计_跨游戏调研.md)
    清单: [docs/standards/动效锚点设计清单与生成图指导.md](docs/standards/动效锚点设计清单与生成图指导.md)
  后续: 聊锚点系统设计（AmbientVisual 组件 + 锚点清单进 T4 A.3 美术规范）→ 决定实施排期（建议 PR-4 之后）；下次出图（新建筑/新单位/T3 变体）直接走新清单

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

- **[P0] T4 阶段开发任务 - 最小可玩里程碑** #设计 #t4 #里程碑 ✅ 4 项关键决策已拍板
  T4 不是"加新功能"，而是"**沉淀 + 收口 + 把现有内容打磨到可玩**"。**完成后 = 第一个 playable demo**。当前项目主线最高优先级。

  **4 项关键决策（2026-08-13 拍板）**：
  - D1 单局时长 = **10-15 分钟**（类微信小游戏手感，不是微信小游戏）
  - D2 敌方 AI = **脚本波次 + 据点扩散**（不做真 RTS AI，完善 outpost_commander 制造对手感）
  - D3 节奏分段 = **3 段式**（0-3min 硬约束 / 3-7min timing / 7-15min 人口软约束）
  - D4 梭哈时刻 = **不做**，节奏自然结束

  **子任务清单（16 项）**：

  **P0 必做**（最小可玩核心）：
  - **A. 沉淀与规范**（4 份文档）：A.1 玩法数值 / A.2 UI 规范（✅ 2026-08-15 完成 → [UI设计规范](docs/standards/UI设计规范.md)，7 章 + 17 项 gap 清单 + 音效需求清单交付 C.2；实施动作拆至下方「UI 规范落地实施」条目）/ A.3 美术规范（✅ 主体已完成 → [游戏视觉设计准则](docs/standards/游戏视觉设计准则.md)；待补：全局色板 v1、建筑动效锚点是否并入）/ A.4 文档整理
  - **B. 节奏落地**（T4 灵魂）：B.1 3 段曲线+波次分钟表 / B.2 科技门槛公式（AoE2 比例 1:1.6:2 参考）/ B.3 据点扩散机制
  - **C. 缺口补全**：C.1 新手引导 60 秒上手（当前零存在）/ C.2 音效落地（零代码 纯实施）/ C.3 终局面板加"重开"按钮
  - **D. 反思**：D.1 暂停新功能、多玩多感受

  **P1 建议做**：E.1 科技插槽化 / E.2 自动绘制地图工具（用户强调 3 次）/ E.3 地形装饰 / E.4 特效库 / E.5 新单位评估

  **推后 / 砍除**：中立油田（已砍，据点替代）/ 多胜利条件应用（T5）/ 元进度 Roguelite（T5）/ 多人模式（永不，Empires 教训）

  **切入顺序**：A 沉淀（半天-1天）→ B 节奏 → C 缺口 → E 工具

  关联:
    - 总览（决策 + 子任务清单）：[T4阶段设计_00_总览.md](docs/active/T4阶段设计_00_总览.md)
    - 调研依据（同类游戏 + 代码盘点 + Sources）：[T4阶段设计_调研报告.md](docs/active/T4阶段设计_调研报告.md)
    - 方法论参考：[T3阶段设计_终局与扩展.md](docs/active/T3阶段设计_终局与扩展.md)
  创建: 2026-08-13
  后续: 按子任务 A→B→C→E 推进，每个子任务单独开 PR 时写技术设计文档（参考 T3 模式）

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

- **[P1] 长枪兵队列图标显示为步兵** #bug #ui ✅ 已修复
  在兵营排长枪兵时，生产队列显示的是基础步兵的图标。原记录"实际造出来是长枪兵（数据正确）"**系误判**：4 个基础兵种（SOLDIER/ARCHER/LANCER/MONK_UNIT）都不在 `PLACE_MODE_TO_STATS_ID`，入队存空 stats_id → 队列 icon 兜底成步兵；spawn 也按 `production_unit_type` 兜底，未选 T3 升级时排枪兵**实际产出的也是步兵**（此前观察到"产出正确"是因为恰好选了 T3 升级走了变体分支）。
  修复（commit `8073e49`）：`PLACE_MODE_TO_STATS_ID` + `ENEMY_VARIANT_SCENES` 补 4 个基础兵种条目（icon 与产出一起修好）；detail_panel 队列"在造"由裸 stats_id 改为 display_name；4 个基础 stats .tres 补 display_name（士兵/弓箭手/枪兵/僧侣）。ICON/MONK_UNIT 等其余基础兵种同步受益。
  关联: [scripts/systems/game_data.gd](scripts/systems/game_data.gd) (`PLACE_MODE_TO_STATS_ID`/`ENEMY_VARIANT_SCENES`), [scripts/ui/detail_panel.gd](scripts/ui/detail_panel.gd), [scripts/ui/barracks_queue_indicator.gd](scripts/ui/barracks_queue_indicator.gd), [resources/stats/](resources/stats/)
  创建: 2026-08-11
  完成: 2026-08-15

- **[P1] 科技已解锁但钱不够时仍可点击建造** #bug #ui #科技
  现象：科技解锁了某建筑、但金币不够时，建造栏按钮看起来仍可点击，玩家点了之后兵营区照样能"建造"（应该被拦截）。

  原始疑点已排除：按钮 disabled 逻辑（`btn.disabled = not ok and not era_locked`）本身正确，NO_GOLD 时 disabled=true；根因是 8-12 修复的"初始按钮全亮"bug 同源（affordability 漏刷新，commit `5f55c86` 已修）。

  **残留问题（2026-08-15 修复）**：金币不足时按 QWERASDF 建造快捷键仍进入放置模式（出 ghost），点地落地才报错。修复：`_on_place_mode_requested` 在时代锁定检查后加 `check_build_block` 统一拦截，非 OK 即在鼠标位置飘字（红）并 return，不进放置模式。顺带覆盖 FARM_LIMIT / NEED_FARM 等其他 reason 的提前拦截。UI 按钮路径保持灰显（点击无反馈，用户确认可接受）。
  关联: [scripts/main.gd](scripts/main.gd) (`_on_place_mode_requested`), [scripts/systems/building_placer.gd](scripts/systems/building_placer.gd) (`check_build_block`)
  创建: 2026-08-11
  完成: 2026-08-15

### UI 优化

- **[P1] UI 规范落地实施 - 规范附录 A 全部 17 项 gap** #ui #t4 #a2 #规范
  A.2 UI 规范已于 2026-08-15 定稿（[UI设计规范.md](docs/standards/UI设计规范.md)，7 章问答拍板）。规范附录 A 列出 17 项现有代码 gap，本条为统一实施入口。背景：专业审查发现 Godot 4 运行时默认字体是 Open Sans SemiBold（**无中文字形**，中文回退系统字体跨平台不一致）。

  **高优先（影响正确性/一致性）**：
  1. **内嵌思源黑体**（= Noto Sans CJK 同字型双品牌，OFL 免费商用）：下载入 `assets/fonts/`，配 theme default font，禁系统回退；≤3 字重
  2. **tnum 等宽数字**：金币/造价/倒计时 Label 挂 `opentype_features = {"tnum": 1}`；思源黑体 tnum 未实测，抖则数字 fallback Noto Sans Mono
  3. **语义色 token 建库**：error/success/warning/info/locked 深底专用值（收编三档红/两档绿/一档黄为唯一值），禁组件直写色值；XAG 102 验收（4.5:1 正文 / 3:1 图标）
  4. **禁用态双轨制收敛**（规范 4.1）：真禁用 0.4 不可点 / 假禁用压暗可点触发报错——收编 0.6 灰 / 0.4 灰 / alpha 0.5 三套写法
  5. **tooltip 600/800 → 300ms**（规范 4.2）：统一两套实现 + 消失延迟 200ms + 100ms 淡入
  6. **硬编码中文飘字 → translations.csv**（规范 4.4）：main.gd 若干处

  **中优先（体验补强）**：
  7. bottom_ui_bar 220 → 215（旧决策已拍未执行）
  8. 消耗数字闪红 200ms（规范 4.3 报错视觉通道）
  9. 无效放置 ghost 补一行原因（规范 4.3）
  10. QW 当前 tab 选中高亮（规范 4.1，现状待查）
  11. 12px 档多行行高 16 → 20（规范 3.1）
  12. button_factory 0.12 → 0.1s（规范 5.1 motion-fast）
  13. 时代解锁闪 0.5 → 0.4s（规范 5.4）
  14. boss/精英头顶血条新组件（规范 2.3，L1 世界空间）
  15. T3 弹窗运行中模态 Red Routes 热键审计（规范 2.3）

  **低优先 / 绑待定项**：
  16. QW 16+ 按钮溢出 → A4 职能分组，绑 #12 待定项一起做
  17. 飘字系统重设计（规范 5.4 豁免条款届时再审）

  规范使用要求：查阅/应用规范须在对话中提及供验证；调研与创意设计阶段豁免（见规范文档头 ⚠️ 节）。
  关联: [UI设计规范](docs/standards/UI设计规范.md)（附录 A）, [A2_UI规范_章节问答草稿区](docs/plans/A2_UI规范_章节问答草稿区.md), [调研报告](docs/research/product/游戏UI规范_业界标准与交互反馈数值调研.md)
  创建: 2026-08-15
  后续: 可拆 PR 实施（建议 1-3 一个 PR、4-6 一个、7-15 按需）；C.2 音效需求清单已随规范交付（规范 4.5）

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

- **[P1] 特效展示/配置界面 - 预览画廊辅助决策** #特效 #沙盒 #工具 #视觉
  目标：一个专门**展示和配置特效**的界面，覆盖光环、状态环、粒子、后处理、技能特效等全部特效资产。核心诉求是**预览图级别的浏览体验**——快速看每个特效长什么样、有哪些可调参数（颜色/尺寸/时长/强度），方便决策某个单位/特效的选留与去留。实际给单位接线配置仍由 AI 做，此界面是给玩家（决策者）看的选型工具。

  **理想形态**：
  - 特效目录列表（按类别分组：地面环/粒子/光柱/波纹/全屏后处理/技能组合…），点击即在预览单位上播放
  - 关键参数实时调节（sliders / 取色器），改动立即反映到预览
  - 多特效叠加预览（如光环 + 受击 + 护盾同时挂在一个单位上，看组合效果）
  - 若能导出配置（.tres / json）更好——玩家调完 AI 直接照抄数值落地

  **实现路径候选**（待聊，不限定游戏内）：
  1. **扩展现有沙盒**：[effect_sandbox](scenes/sandbox/effect_sandbox.tscn) 已有 8 技能按钮 + 状态/建筑/后处理调试按钮，加一个"特效画廊"侧栏（目录 + 参数面板）成本最低
  2. **独立预览场景**：脱离游戏主场景的纯展示场景，一屏多卡片（类似技能图鉴/Art Book 界面），每卡片一个小单位在循环播放特效
  3. **批量截图 contact sheet**：工具脚本自动逐个触发特效并截图，拼成一张总览图——最快得到"预览图"，但无实时调参
  4. **游戏外方案**：如 Godot 编辑器插件 / web 预览页（预计成本更高，待评估必要性）

  关联: [scenes/sandbox/effect_sandbox.tscn](scenes/sandbox/effect_sandbox.tscn), [scripts/sandbox/sandbox_controller.gd](scripts/sandbox/sandbox_controller.gd), [scripts/sandbox/sandbox_config.gd](scripts/sandbox/sandbox_config.gd), [scripts/skills/skill_visual_controller.gd](scripts/skills/skill_visual_controller.gd), [scripts/effects/](scripts/effects/)
  创建: 2026-08-16
  后续: 先聊实现路径（1 扩展沙盒 vs 2 独立画廊 vs 3 截图总览），再排期；与 T4 E.4 特效库天然衔接

- **[P1] 近战命中特效改版 - 剑士白点下坠不好看** #特效 #视觉 #需讨论
  现状：剑士（近战通用）命中特效是 [hit_spark.tscn](scenes/effects/particles/hit_spark.tscn)——15 个黄白小点、发射方向朝下（spread 45°）+ 向下重力 200，看起来是"一串白点下坠"，不像砍中人。它是 PR-5 的通用命中粒子，**近战/远程共用**，由被打者在 [unit.gd](scripts/units/unit.gd) `take_damage`（`ParticlePool.spawn("hit_spark", ...)`）触发；且不带方向参数，与攻击方向无关。

  **候选方案（待讨论）**：
  1. **刀光弧线**（slash arc）：攻击方向上的弧形扫过（Line2D/Polygon2D 画弧 + 快速淡出，或代码生成月牙纹理），方向感最强
  2. **定向散落粒子**：保留粒子但按攻击方向斜向喷溅（去掉下坠感，需 ParticlePool.spawn 传 rotation）
  3. **粒子刀光**：1+2 组合——短弧光 + 少量定向火花
  4. 其他：Tiny Swords 素材包 `Particle FX/Particle FX.aseprite` 可能有现成帧动画可用（待查）
  注：远程（弓箭）的命中粒子可以保留 hit_spark 或一并调整，待定。

  **实现要点**：
  - 近战/远程需分流（unit.gd `take_damage` 目前只知道 attacker，可由 attacker.is_ranged 判断或攻击者在 `_perform_attack` 里自己 spawn 方向特效）
  - ParticlePool 已支持 spawn opts 传 rotation（[particle_pool.gd](scripts/effects/particle_pool.gd)），定向粒子改动小
  - 刀光类需新增配方 + 可能新增弧形纹理（ParticleTextures 目前只有 DISC/SPARK/SQUARE）

  关联: [hit_spark.tscn](scenes/effects/particles/hit_spark.tscn), [particle_pool.gd](scripts/effects/particle_pool.gd), [particle_textures.gd](scripts/effects/particle_textures.gd), [unit.gd](scripts/units/unit.gd) (`take_damage`/`_perform_attack`)
  创建: 2026-08-16
  后续: 讨论定方案（1 刀光 / 2 定向粒子 / 3 组合）→ 沙盒验证 → 近战远程分流落地

- **[P1] 部位发光标记 - buff 局部视觉反馈（剑士案例）** #特效 #视觉 #buff #需讨论
  想法：给单位 sprite 标记具体部位（头/手/武器），buff 或技能触发时只在标记部位亮光。例：攻速 buff → 手部亮红光；剑士开"神圣状态" → 剑上的十字亮起。业内调研已完成（2026-08-16，对话内调研），三个通用叫法：
  - **Emissive mask / 自发光遮罩**（Unity 2D Secondary Textures、Spine、Godot ShaderMaterial 传 mask sampler）— mask 贴图与 sprite 同 UV，`color += mask × glow_color`
  - **Palette swap / 调色板替换**（魔兽 2 队伍色 208-223 索引段、Dead Cells gradient map、Dota 特效携带物）— 保留色/索引运行时重映射，零额外贴图
  - **Item transform**（暗黑 2 enchant：武器 sprite 火色调色板 remap + overlay 光照半径，states.txt 的 `colorpri` 列解决多 buff 变色冲突）

  **实现谱系（按精度/成本）**：
  - A. 逐帧 mask sheet（RGBA 四通道打包 4 部位：R=手 G=头 B=剑 A=十字），光逐帧跟剑走，美术量 ×2
  - B. 保留色 keying（十字直接用保留色画进原 sprite，shader 检测替换成呼吸发光色），Dead Cells 路线，像素风最省
  - C. Overlay 粒子/PointLight2D 挂部位，最快但不跟动画、会飘

  **项目现状适配**：无全局 bloom → 用 shader fake（复用 boss_glow 参数化思路）；[unit.gd](scripts/units/unit.gd) `body_sprite` 是 hframes sprite sheet，方案 A 只需 mask 同布局；Tiny Swords 像素小 sprite → 倾向 B 起步。

  **待讨论要点**：
  1. 方案 A（mask sheet）vs B（保留色）：精度 vs 美术零额外量
  2. 多 buff 同部位冲突：要不要学 D2 `colorpri` 优先级
  3. 纯自发光 vs 加 PointLight2D 照亮地面（白天场景收益存疑）
  4. 与 [游戏视觉设计准则](docs/standards/游戏视觉设计准则.md) 响度预算/颜色语义表的衔接（发光色是否走语义色表）

  关联: [scripts/units/unit.gd](scripts/units/unit.gd) (`body_sprite`), [docs/standards/游戏视觉设计准则.md](docs/standards/游戏视觉设计准则.md), [docs/design/程序化动画与特效调研报告.md](docs/design/程序化动画与特效调研报告.md)
  创建: 2026-08-16
  后续: 讨论定方案（A/B/C）→ 可先做方案 B shader 原型在沙盒验证剑士效果；与 T4 E.4 特效库、特效展示界面衔接

### Bug

- **[P1] GPU 粒子 color_ramp 不生效 — 血雾/hit_spark 都显示纯白** #bug #特效 #粒子
  现象：blood_mist 配方 color_ramp 配的是暗红渐变（0.62,0.05,0.05 → 透明淡出），实际渲染却是**纯白色软圆盘颗粒**；hit_spark 同理——渐变配的黄橙暖色（1,0.95,0.6 → 1,0.3,0.1），玩家看到的是"白色光点下坠"。治疗颜色正常（heal_effect 是帧动画 sprite，非 GPU 粒子，不受影响）。

  **根因方向（未验证）**：项目跑 Compatibility (OpenGL) 渲染器，怀疑 `ParticleProcessMaterial.color_ramp` 在该渲染器下被忽略（Godot 4.x 已知类问题）。线索：两个 GPU 粒子配方同时"变白"、都依赖 color_ramp 配色、[particle_textures.gd](scripts/effects/particle_textures.gd) 生成的 DISC/SPARK 纹理本身是纯白——指向渲染管线而非单个配方配置。energy_fog / debris / heal_orb 同样依赖 color_ramp，大概率同病。

  **修复候选**：
  1. RECIPES 加默认 modulate（[particle_pool.gd](scripts/effects/particle_pool.gd) spawn opts 已支持 `"modulate"`，CanvasItem.modulate 全渲染器有效）——改动最小
  2. particle_textures.gd 直接生成带色纹理（颜色烘进纹理，不靠 ramp）
  3. 升级 Forward+ 渲染器（影响面大，需单独评估性能/兼容）

  关联: [blood_mist.tscn](scenes/effects/particles/blood_mist.tscn), [hit_spark.tscn](scenes/effects/particles/hit_spark.tscn), [particle_textures.gd](scripts/effects/particle_textures.gd), [particle_pool.gd](scripts/effects/particle_pool.gd)
  创建: 2026-08-16
  后续: 先小规模验证（方案 1 给 blood_mist 单配方配暗红 modulate，沙盒看是否变红）→ 确认根因再决定是否全配方推广

## 🔧 计划中

### 程序化特效落地（按 ROADMAP 推进）

- **[P1] 程序化特效落地 - 7 个 PR 按基础优先顺序推进** #特效 #实施
  设计已完成（[落地总方案](docs/design/程序化特效落地总方案.md)），ROADMAP 拆为 7 个 PR + 测试沙盒。每个 PR 在沙盒里独立验证。

  **PR 列表**：
  - ✅ **PR-0** 测试沙盒场景（极简版）— spawn 单位/木桩 + 阵营切换 + 框选/attack-move + 时间控制 + 详情面板 + 弹道（2026-08-15 完成）
  - ✅ **PR-1** Shader 接入 + Dissolve — 受击白闪（0.12s，护盾全吸收/闪避不闪）+ Boss 紫光（`category=="boss"` 数据驱动）+ 骷髅死亡 dissolve 消散（`dissolve_on_death` 字段）；hit_flash 移到状态染色之后（受击优先）；沙盒新增 Boss 按钮 + stats 覆盖机制（2026-08-15 完成）
  - ✅ **PR-2** 粒子对象池 + 配方库 — ParticlePool Autoload（自动预热 + finished/超时双路回收）+ 9 种配方（dust/explosion/hit_spark/debris/energy_fog/heal_orb/blood_mist/dust_gpu），迁移 game_spawner/building/building_garrison 高频 instantiate（2026-08-15 完成）；2026-08-16 收尾：blood_mist 接入全单位死亡路径（die() 在 dissolve/scale-to-zero 分支前统一 spawn）、heal_effect 迁池（新增 "heal" 配方）、清理 game_data.gd 死常量 DustEffectScene
  - ✅ **PR-3** UnitVisualFeedback 组件 — 攻击前探/后坐冲量 + 受击位移 + 护盾/中毒/减速地面环；零 Tween（_process 插值 + 冲量曲线）；沙盒新增 7 个状态调试按钮（2026-08-15 完成）
  - ✅ **PR-4** BuildingActivityVisual 组件 — 生产脉冲/施工尘土/升级转动金环 + 入队下沉/完成回弹/产金金环/升级双环/受击震动红闪；状态优先级仲裁（constructing > age_upgrading > producing > idle）；箭塔 JellyEffect 替换（消除 tween 争写 scale）；die 加 debris；沙盒加建筑面板（7 建筑 + 64px 占格）+ 6 个建筑调试按钮（2026-08-15 完成，commit `fe3dccf`）
  - ✅ **PR-5** 命中粒子 + 屏幕后处理 — PostProcessController Autoload（layer=5 CanvasLayer + 全屏 ColorRect shader）：screen shake 走 Camera2D.offset（不碰 position，clamp/平滑不受影响，game_camera.gd 零改动）、色差（SCREEN_TEXTURE 径向 RGB 分裂）、冲击波扩散环（≤4 并发，世界坐标自动转 UV）；hit_spark 命中粒子按伤害量分级 scale（<20/≤50/>50 → 0.8/1.1/1.4），>60 伤害加 shake；Boss 死亡 big_impact 三件套（shake10+色差+冲击波）；建筑爆炸 shake8 + 尺寸缩放冲击波（无色差）；沙盒加 4 个后处理调试按钮（冲击波为两段式：点按钮武装→点地图触发）；顺手修 PR-2 潜伏 bug：ParticlePool float scale 走 `Vector2.ONE * x`（原 `Vector2(float)` 非法构造会崩 spawn）（2026-08-15 完成）
  - ✅ **PR-6** 指挥官技能视觉升级 — 新增 SkillVisualController（Node2D + static instance，main/沙盒各挂一份，不走 Autoload）：play_release_ripple 波纹环 / play_light_pillar 光柱（pillar+cross）/ play_charging_circle 蓄力进度环 / play_screen_impact 转发 PR-5 shake。8 技能逐个接入：嘲讽（红波纹 + 被嘲讽目标 aggro_line 自动加粗亮红，`_taunt_expire_timer` 驱动）、闪现（起点 dissolve 消散 + 双端紫波纹 + 紫色 life_leech 光迹，unit.gd 新增 `play_dissolve_in/out`）、隐身（进入/退出瞬间紫波纹，状态沿检测）、劝化（金色 beam 跟随双方 + 目标金色蓄力环 + blessed tint 渐变，shader 新增 `blessed_amount` uniform；完成/中断均回收视觉）、护盾（目标蓝白波纹，持续环复用 PR-3 轮询）、召唤（施法者紫波纹 + minion 紫色光柱（spawn_effect 新增 `custom_tint`）+ 出生 dissolve）、治疗（金十字光柱 + heal_orb 粒子）、驱散（白波纹 + 白闪 + energy_fog + 停 slow/poison/enraged/blessed 视觉）。beam_effect 新增 `color_override` + `follow_source/follow_target`。沙盒左面板新增"技能"区 8 按钮（选中友军为施法者，绕过蓝耗/冷却；stealth 按钮点一次=切显形再自动回隐身，方便看双向波纹）（2026-08-16 完成，commit `711bf44`）
  - ⏸ **PR-7** T3 变体专属视觉（可延后）— 等玩家真解锁 T3 再说

  关联: [docs/active/程序化特效落地_ROADMAP.md](docs/active/程序化特效落地_ROADMAP.md)
  创建: 2026-08-13
  后续: PR-0~PR-6 已完成，PR-7 可延后。沙盒 F6 运行 `scenes/sandbox/effect_sandbox.tscn`；加单位/建筑改 [scripts/sandbox/sandbox_config.gd](scripts/sandbox/sandbox_config.gd) 一行即可（单位支持 `"stats"` 键覆盖，建筑走 `SPAWNABLE_BUILDINGS`）。沙盒建筑调试按钮：选中建筑后顶栏 入队/产金/受击/施工/升级/摧毁；技能按钮：先选友军单位再点左面板"技能"区。已知坑：地面环类特效 z_index 必须 >0（否则被 Ground 盖住）；`addons/ui_safety` 是 submodule，worktree 需 `git submodule update --init` 否则 UID 解析失败；ParticlePool 的 scale opts 传 float 或 Vector2 均可；worktree 首跑前必须 `--headless --import` 刷新 class_name 缓存否则场景脚本解析失败白屏。

## ✅ 已完成

- [x] **游戏视觉设计准则 - 深度调研 + 准则落盘** #视觉 #标准 #t4
  背景：后续做新地图/贴图/单位/特效/UI 时缺少统一的视觉判断标准，只有零散感觉（树细节太抢戏 / 单位不显眼 / 地面太亮太花 / 特效太花 / 单位与世界观违和）。
  产出：[游戏视觉设计准则](docs/standards/游戏视觉设计准则.md)。核心框架：视觉能量六维（明度对比/饱和度/细节密度/运动/尺寸/色相稀有度），能量排序=信息优先级排序；注意力三层 L1玩法/L2状态/L3氛围；可读性=图底分离+剪影；颜色语义表全游戏唯一；响度预算；Art Bible 六维 + 混源素材统一手段；分资产验收清单 + 6 个自检测试（灰度测试/0.5秒测试等）。
  即 T4 A.3 美术规范的主体。遗留待办：全局色板 v1（截图取样填表）、Art Bible 六维表人工确认。
  依据：Valve Dota 2 角色美术指南 / TF2-Overwatch 可读性分析 / 暴雪 Gameplay First 特效哲学 / SC2 地图美术最佳实践（来源见准则文末）。
  创建: 2026-08-14
  完成: 2026-08-14

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
