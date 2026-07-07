# RTS 游戏特效调研报告

> 调研日期：2026-07-05
> 调研目的：为 RTS 项目特效系统设计提供参考，覆盖特效分类、具体特效、作用/功能、参考游戏做法、Godot 实现技术点

---

## 一、特效的核心作用（先讲"为什么"）

RTS 特效的本质职责不是"好看"，而是**信息传达**。玩家在 RTS 中要同时处理数十上百个单位、多线作战、资源调度，认知负荷极高，所以特效必须解决三类问题：

| 作用类型 | 解决的问题 | 典型例子 |
|---|---|---|
| **反馈（Feedback）** | 我刚才的操作发生了什么？ | 命中火花、暴击数字、单位死亡爆裂 |
| **预警（Telegraph）** | 即将发生什么，我该如何反应？ | AOE 范围圈、施法前摇光效、敌方大招指示器 |
| **标识（Identifier）** | 这是什么/这是谁的/状态如何？ | 选中描边、英雄特殊光环、中毒冒紫烟 |
| **氛围（Ambience）** | 强化沉浸感和场景个性 | 雨雪天气、岩浆冒泡、爆炸余烬 |

Riot、Blizzard 等厂商的设计共识是：**功能性 > 美观性**——关键技能的特效要"大、亮、夸张"，常规特效要"收敛、克制"，避免视觉噪音掩盖玩法信息。

---

## 二、特效功能分类（按用途）

这是最实用的分类法，建议项目按这个维度组织资源目录。

### 1. 标识型特效（Identifier VFX）—— 表明"这是什么"

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **选中描边（Selection Outline）** | 当前选中的单位/编队 | SC2 绿色描边、WC3 圆形地贴花 |
| **悬停高亮（Hover Highlight）** | 鼠标悬停时可点击的单位 | SC2 鼠标悬停白色描边 |
| **队伍/敌我颜色** | 区分所属玩家 | 几乎所有 RTS |
| **英雄/Boss 标记** | 突出特殊单位 | WC3 英雄光环底座、SC2 Boss 血条 |
| **任务目标标记** | 主线/支线目标点 | SC2 地图编辑器 Ping、AOE 任务图标 |
| **编队徽章** | 编队归属 | CoH 班组底部圆环 |
| **隐蔽/潜行半透** | 该单位隐身 | SC2 隐刀半透轮廓 |

### 2. 范围/预警型特效（Telegraph VFX）—— 表明"将在这里发生"

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **建筑攻击范围圈** | 防御塔/城堡射程 | AoE2/AoE4 城堡/TC/塔范围圆 |
| **技能 AOE 范围预览** | 释放前显示覆盖范围 | SC2 神族风暴、毒爆虫落地圆 |
| **方向型技能指示** | 直线/扇形技能路径 | MOBA 类技能指示器（RTS 较少用） |
| **预警红圈** | 敌方即将打击的位置 | SC2 坦克架起红圈、毒爆预警 |
| **建造可放置/不可放置** | 绿色/红色 ghost | SC2/AoE 建造预览 |
| **资源点/可采集点** | 可交互位置 | AoE 金矿/树丛轮廓 |
| **技能射程预览** | 主动技能最大距离 | WC3 英雄技能释放距离 |

### 3. 战斗反馈型特效（Combat Feedback）—— 表明"发生了什么"

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **投射物（Missile）** | 远程攻击的弹道 | SC2 枪兵子弹、LC 飞龙弹 |
| **光束（Beam）** | 持续射线攻击 | SC2 虚空辉光舰、SC2 主宰光束 |
| **命中（Impact）** | 击中瞬间火花 | SC2 通用 hit 动画 |
| **爆炸（Explosion）** | AOE 命中爆破 | SC2 毒爆爆裂、坦克炮击 |
| **受击闪烁（Hit Flash）** | 单位受击白闪 | 所有 RTS 通用 |
| **暴击/独特命中** | 暴击反馈 | WC3 暴击红色数字 |
| **招架/盾牌格挡** | 防御成功反馈 | AoE2 招架闪光 |
| **死亡特效** | 单位消失 | SC2 虫族爆浆、人类爆船 |

### 4. 状态型特效（Status VFX）—— 表明"持续处于什么状态"

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **Buff 光环** | 增益状态 | WC3 嗜血红色光环、SC2 强化盾 |
| **Debuff 飘烟** | 减益状态 | SC2 毒物冒紫烟、被寄生绿光 |
| **眩晕星星** | 失控状态 | WC3 眩晕头顶小星星 |
| **燃烧持续** | DOT 伤害 | AoE 火焰兵、C&C 燃烧步兵 |
| **冰冻/减速** | 减速状态 | WC3 冰封冒冰晶 |
| **治疗飘字** | 持续治疗 | WC3 治疗术绿色数字 |
| **隐身/潜行** | 隐身状态 | SC2 隐刀半透 |
| **护盾/能量盾** | 临时护甲 | SC2 神族护盾环、Buff 类 |
| **充能/蓄力** | 大招蓄能 | SC2 母核充能光柱 |

### 5. 施法/技能型特效（Ability VFX）—— 表明"释放了什么"

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **施法前摇（Cast 预热）** | 技能即将释放 | WC3 大法施法手部光球 |
| **释放瞬间（Release）** | 技能发出瞬间 | SC2 闪电术释放闪光 |
| **持续施法（Channel）** | 持续引导技能 | WC3 暴风雪持续冰柱 |
| **飞行轨迹（Travel）** | 投射物飞行 | SC2 巡洋舰导弹轨迹 |
| **爆发（Detonate）** | 命中后爆裂 | SC2 核弹白闪 |
| **残像/余晖（After-image）** | 技能结束余韵 | 各种技能释放后的余光 |

### 6. 环境氛围型特效（Ambience VFX）—— 强化沉浸感

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **天气（雨/雪/雾）** | 氛围 | AoE2 雨雪天、C&C 沙尘暴 |
| **地形破坏痕迹** | 战斗痕迹 | CoH 弹坑、SC2 焦土 |
| **环境粒子（萤火/落叶）** | 地图个性 | WC3 不同地貌粒子 |
| **昼夜光线** | 时间变化 | AoE2 昼夜循环、WC3 月光 |
| **背景动态（瀑布/岩浆）** | 地图生命感 | 几乎所有 RTS |

### 7. UI/HUD 型特效（UI VFX）—— 元层面的反馈

| 特效 | 作用 | 参考游戏 |
|---|---|---|
| **伤害数字（Damage Number）** | 数值反馈 | 所有 RPG 风格 RTS |
| **暴击/特殊数字** | 强调特殊伤害 | 红色暴击数字 |
| **资源飘字** | 资源获得/失去 | AoE2 采集 +5 木 |
| **任务通知** | 任务更新 | SC2 任务侧栏滑入 |
| **小地图脉冲** | 重要事件 | SC2 受袭红点脉冲 |
| **HUD 警告闪烁** | 危险提示 | 主基地受袭红色闪边 |
| **冷却完成提示** | 技能 ready | 图标闪光 |

---

## 三、参考游戏的特效哲学对比

| 游戏 | 特效哲学 | 强项 |
|---|---|---|
| **StarCraft 2** | **极致可读性**——所有特效按"威胁等级"分级，关键技能大且亮，小兵 hit 几乎没有特效 | Actor 系统的解耦设计、单位辨识度 |
| **Warcraft 3** | **英雄中心化**——英雄技能特效极其华丽，小兵相对朴素，对比鲜明 | 英雄标识、技能演出感 |
| **Age of Empires 2/4** | **历史写实**——特效克制不夸张，依赖造型与颜色编码 | 建筑范围圈、风格统一 |
| **Company of Heroes** | **战场沉浸**——弹道/弹坑/烟雾真实感拉满 | 班组底环、战场氛围 |
| **Command & Conquer** | **夸张漫画风**——爆炸大、动画慢、爽感强 | 大招演出、视觉冲击 |

---

## 四、对本 Godot RTS 项目的优先级建议

基于项目方向（合作 PVE、SLOW 战斗节奏、强调玩家主动决策），特效的优先级如下：

### P0（必做，没有就严重影响可玩性）
1. **选中描边 + 编队颜色** —— 多人地图必备
2. **建筑攻击范围圈**（AoE4 做法）—— PVE 防守核心反馈
3. **AOE 技能范围预警**（红圈/绿圈）—— 配合"必须给玩家主动决策点"的设计原则
4. **投射物 + 命中火花** —— 远程单位基本反馈
5. **死亡特效** —— 单位消失的视觉收束
6. **HUD 受袭警告 + 小地图脉冲** —— 多线作战必备

### P1（强烈推荐，能大幅提升手感）
1. **Boss/特殊敌人标记** —— 关卡有 Boss 战，需要醒目标识
2. **状态特效（燃烧/中毒/眩晕）** —— SLOW 节奏下状态效果会更频繁
3. **施法前摇 + 释放瞬间** —— 让技能有"演出感"
4. **伤害数字 + 暴击数字** —— 反馈颗粒度
5. **资源飘字** —— 经济反馈

### P2（表现力提升，等基础完事再做）
1. **天气/环境粒子**
2. **地形破坏痕迹**
3. **冷却完成 UI 闪光**
4. **任务通知动效**

---

## 五、关键技术点（GDScript / Godot 视角）

| 效果类型 | 推荐实现 |
|---|---|
| 选中描边 | Shader（Outline shader）或 Sprite 复制 + 加粗 |
| 范围圈 | `GPUParticles2D` 或纯 `Polygon2D` + Shader 描边 |
| 投射物 | `Node2D` 移动 + Sprite + 拖尾（`Line2D` 或粒子）|
| 命中爆炸 | `AnimatedSprite2D` 帧动画 or GPUParticles2D one_shot |
| 状态光环 | 围绕单位的 `GPUParticles2D`（emission shape = unit）|
| 伤害数字 | `Label` + `Tween` 浮动消失，对象池复用 |
| 小地图脉冲 | `Sprite2D` + `scale tween` 循环 |

---

## 六、参考来源（出处）

### 综合类
- [Visual Effects Summit: WoW VFX Pillars — GDC Vault](https://gdcvault.com/play/1029418/Visual-Effects-Summit-World-of)
- [RTS Game Design Fundamentals — Game Design Skills](https://gamedesignskills.com/game-design/real-time-strategy/)
- [So You Wanna Make Games?? | Episode 7: Game VFX — YouTube](https://www.youtube.com/watch?v=3QKK2o5rWSQ)
- [The Future of RTS — Cocoia Blog](https://blog.cocoia.com/2009/the-future-of-rts/)

### 状态/预警/AoE 类
- [Status Effects in RTS — Wayward Strategy](https://waywardstrategy.com/2024/03/20/mind-control-stun-and-fire-oh-my-a-discussion-about-status-effects-in-real-time-strategy-games/)
- [Status Effects in RTS — TL.net](https://tl.net/blogs/622852-a-discussion-about-status-effects-in-rts)
- [Why don't we see AOE markers in non-MMO games? — Reddit r/gamedesign](https://www.reddit.com/r/gamedesign/comments/pt1rf9/why_dont_we_see_aoe_markers_in_nonmmo_games/)
- [Building range indicators now in game — Age of Empires Forum](https://forums.ageofempires.com/t/building-range-indicators-now-in-game/125001)
- [The FX Artist's Guide to Area of Effect (AoE) — VFX Apprentice](https://www.vfxapprentice.com/blog/area-of-effect-aoe-in-games)
- [Displaying status effects without clutter — Reddit r/gamedev](https://www.reddit.com/r/gamedev/comments/n48tr3/what_are_good_ways_of_displaying_status_effects/)
- [Status Effect Guidelines — Accessible Game Design](https://accessiblegamedesign.com/guidelines/statuseffects.html)

### StarCraft 2 编辑器实现类
- [Actors — StarCraft II Editor Tutorials](https://s2editor-guides.readthedocs.io/New_Tutorials/04_Data_Editor/060_Actors/)
- [Data/Actors/Beam (Simple) — SC2Mapster Wiki](https://sc2mapster.fandom.com/wiki/Data/Actors/Beam_(Simple))
- [Data/Actors/Action — SC2Mapster Wiki](https://sc2mapster.wiki.gg/wiki/Data/Actors/Action)
- [Data Editor – A Vital Guide — SC2 Galaxy Editor Tutorials](https://starcraft-2-galaxy-editor-tutorials.thehelper.net/tutorials.php?view=169172)
- [SC2 Editor: Missile Ability — YouTube](https://www.youtube.com/watch?v=XU1-mOXf1cs)
- [SC2 Editor: Multiple Beam Weapons — YouTube](https://www.youtube.com/watch?v=brO18BmBhM8)

### 单位设计 / 英雄标记类
- [What Makes RTS Games Fun: Super Units — Wayward Strategy](https://waywardstrategy.com/2019/05/06/what-makes-rts-games-fun-super-units/)
- [What Makes RTS Games Fun: Experiential Unit Design — GameCloud](https://gamecloud.net.au/features/opinion/what-makes-rts-games-fun-experiential-unit-design)
- [Inspired Designs in Relic's RTS Games — GameDeveloper](https://www.gamedeveloper.com/design/inspired-designs-in-relic-s-rts-games)
- [RTS Game Tutorial | Unity | Episode 10 - Cursors & Markers — YouTube](https://www.youtube.com/watch?v=kr_SjT1jWkc)
- [First RTS game with Hero Units — Reddit r/RealTimeStrategy](https://www.reddit.com/r/RealTimeStrategy/comments/1fyav33/which_was_the_first_rts_game_that_introduced_hero/)

### 中文资源
- [游戏特效的「设计」理念 — 知乎专栏](https://zhuanlan.zhihu.com/p/1921332241709110764)
- [游戏特效的具体分类及功能 — 火星时代教育](https://wap.hxsd.com/information/18014/)
- [遊戲特效設計人員職能基準 — 台湾劳动部 ICAP](https://icap.wda.gov.tw/File/datum/110022001v2.pdf)

---

## 附：项目内相关文档索引

- 平衡方案：[project_balance_scheme.md](../../../C:/Users/86132/.claude/projects/e--godot-rts-godot-rts-start/memory/project_balance_scheme.md)
- 敌方机制设计偏好：[feedback_mutator_design_preference.md](../../../C:/Users/86132/.claude/projects/e--godot-rts-godot-rts-start/memory/feedback_mutator_design_preference.md)
- 多人地图配置手册：[docs/active/多人地图配置手册.md](../../active/多人地图配置手册.md)
