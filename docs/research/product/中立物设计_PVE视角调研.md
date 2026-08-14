# 中立物设计 - PVE 视角调研与机制设计

> 关联 TODO: `[P1] 中立装饰优化 - 聊功能定位` / `[P1] 地形视觉优化 - 多色地形与绘制流程`
> 讨论顺序: **意义 → 定位 → 功能**（用户定的 top-down 流程，先搞清"解决什么问题"再决定"要不要、怎么做"）
> 创建: 2026-08-12
> 状态: 📋 调研完成，机制候选待决策

---

## 一、跨游戏中立物的存在意义（A–G 七类）

> 一句话总览：RTS/MOBA 里的中立物（树/石/中立建筑/资源点），本质上是在回答 **5 个玩法问题**：①为什么出基地 ②走哪条路 ③站哪更强 ④哪看得见 ⑤战场会不会变；外加 ⑥一个纯氛围层。

### A. 解决「为什么走出基地」——战略目标 / 控制点
**意义**：给开放地图制造"必争之地"，破龟缩。没有这些点，RTS 退化成两边各自憋兵一波流。
- **AoE4 圣地（Sacred Site）**：城堡时代派僧侣占领，给金币 + 占齐所有圣地触发 10 分钟胜利倒计时。地图固定 2–3 个。
- **AoE4 贸易站（Trade Post）**：中立市场，商人跑过去交易 +20% 收益。
- **AoE4/AoE2 遗物（Relic）**：僧侣捡回寺院换每分钟 30 金。
- **WC3 中立建筑**（雇佣兵营 / 酒馆 / 地精实验室 / 商店）：必须派单位走过去交互才能买雇佣兵、中立英雄、工兵飞艇、消耗品。**大多由 Creep（中立敌对怪）守卫**——杀 creeps 练级 + 解锁访问权。
- **SC2 萨尔纳加瞭望塔（Xel'Naga Tower）**：单位站上去给一片视野，争的是地图信息权。
> 关键设计技巧：把"出基地的理由"和"敌人也想拿"绑在一起，自然产生冲突。

### B. 解决「走哪条路、好不好过」——路径与节奏开关
**意义**：用"能不能过、好不好过"塑造战斗形状。咽喉点让小兵力挡大兵力、让"在哪打"比"兵多少"更重要。
- **SC2 可破坏岩石（Destructible Rocks）**：早期封路强制绕远、限制扩张；打掉后开捷径。设计师原话：*"The rocks blocking the central ramp lengthen rotations early on but allow for faster rotations between expansions once destroyed."*——动态地形 = 节奏开关：同一块石头在 t=0 和 t=10min 起完全相反的作用。
- **SC2 金矿物堆（Rich Minerals）**：高收益资源点用岩石挡着，前期拿不到 → risk-reward。
- **CoH / C&C 可炸桥**：桥梁可被炸断切断通行，动态改变进攻路线。

### C. 解决「站在哪更强」——掩体 / 驻扎 modifier
**意义**：让"站位"成为战术决策。同一支兵，掩体后 vs 空地强度差几档，给走位和微操以回报。
- **CoH 方向性掩体（directional cover）**：墙、沙袋、灌木、房屋给步兵方向性减伤 buff，朝向决定有效性（红/黄/绿掩体）。CoH 区别于所有传统 RTS 的招牌机制。
- **CoH 驻扎（garrison）**：步兵进建筑获强防御 + 射击窗口，但被喷火器/坦克炮克制 → 剪刀石头布。

### D. 解决「哪里看得见、哪里看不见」——视野 / 信息博弈
**意义**：让"侦察/视野/位置"成为可博弈资源。没视野遮挡，RTS 就是双方全透明比数值；有了遮挡才有伏击、绕后、信息差——战术深度的核心来源之一。
- **Dota 树林**：dense 树丛挡视野 + 弹道，玩家利用树缝"绕树林"（juking）逃跑/反杀，是 Dota 战术灵魂。**关键是树可破坏**（吃树/补刀斧/技能），所以 juke 路径是涌现式的、不可预测的。
- **LoL 草丛（Brush）**：进草对方丢失视野，gank/反 gank 核心。但和 Dota 树相反——位置固定、人人能用，更标准化。
- **SC2 LoS blocker / 高地低地视野差**：藏单位、伏击。
> 两种哲学：**Dota = 涌现式可破坏**（树被打出 unpredictable 路径）vs **LoL = 固定标准化**（草丛位置策划定死）。中立物设计里一个根本性取舍。

### E. 解决「探索地图的动力」——经济资源点
**意义**：把"地图探索"和"经济扩张"绑定。资源点散在地图上，强迫玩家走出基地、扩张、暴露兵力——RTS 节奏的根本驱动力。
- **AoE 系**：金矿、石矿、浆果丛、树林（木材）——这些"中立物"就是经济基础，控制资源点 = 控制经济。
- **WC3 金矿**：被 creeps 守卫，杀完才能开分矿。
- **C&C 泰矿**：地图矿脉，扩张 = 抢矿。

### F. 解决「战场会不会随战斗演化」——可破坏带来的动态战场
**意义**：让地图不是静态棋盘，而是"会被打穿的棋盘"。持久战里掩体消失、新路径打开，局势随地形改变而改变。**最贵最难做的一类**（物理破坏 + 状态同步 + 视觉表现）。
- **CoH**：几乎一切可破坏——围墙打穿、房屋打塌、地面留弹坑。Relic 设计理念：持久战让原本的掩体优势消失，迫使玩家移动。
- **Dota 树 / SC2 岩石**：破坏 = 开新空间。

### G. 非玩法层：氛围 / 可读性 / 美学
**意义**：让地图"长得像那片地方"，增强场景识别度。**陷阱**：纯装饰如果不明确隔离碰撞/视野/选择，就会变成玩家认知摩擦源（"我以为这棵树挡路结果不挡"）。

---

## 二、PVE 视角下的意义重估（核心：哪些贬值、哪些升值）

### 判断依据：PVE 的两个根本差异
1. **对手是脚本不是人** → 所有依赖"和会思考的对手博弈"的机制贬值——欺骗、juke、信息不对称、心理战，AI 要么全知（开挂感）、要么傻（没意思），两边都做不出乐趣。
2. **龟缩是 PVE 头号敌人** → 所有"驱动玩家出基地"的机制**升值**。PVE 设计师最头疼的就是玩家蹲家里憋塔憋兵，所以"必争之地""必采之矿"是节奏工具，比 PVP 更刚需。

### 🔴 意义大幅削弱（建议砍 / 别投入）

**D. 视野/信息博弈（双向 juke、伏击反伏击）——削弱最严重**
- juke/绕树林：乐趣来自"骗过会思考的人"，对 AI 没意义。
- fog of war 作为"博弈"：PVP 里视野是双方争夺的资源；PVE 里"博弈"层消失，只剩"探索发现"的线性乐趣。
- **该砍**：别做 Dota 那套。**保留一个 PVE 特色子类**——单向"玩家被伏击"（玩家揭迷雾踩到中立怪埋伏，WC3 creeps 的感觉）。

**C. 复杂方向性掩体（CoH 那套）——ROI 低**
- 方向性掩体的乐趣有一半来自"对手也在利用掩体反制你"。AI 用不好，玩家也感受不到对照。
- **该砍**：别做 CoH 级方向掩体系统。
- **可保留简化版**：「驻扎建筑」和「高地/简单站位 modifier」对 PVE 防守关卡依然有用，实现便宜。

**F. 全战场动态破坏——太贵，单局 ROI 不划算**
- CoH 那种"持久战掩体消失"是 PVP 长局体验，PVE 单局通常没长到"战场演化"成为核心。实现成本极高。
- **该砍**：别做全破坏。
- **可保留局部版**：「破坏障碍 = 开新路径」（炸开岩石/砍倒树开门）作为关卡设计工具，少量、可控、有目的。

### 🟢 保留甚至更重要（PVE 核心工具）

**A. 战略目标/控制点 ——升值**
- PVE 龟缩问题比 PVP 严重，"必争之地"是策划手里的节奏控制器。

**E. 经济资源点 ——完全保留**
- "地图探索 = 资源获取"是 PVE 玩家出基地的根本动力。如果经济只来自基地内建筑，玩家没有任何理由离开基地，节奏会塌。

**B. 咽喉点/卡位 ——塔防灵魂，PVE 极重要**
- 塔防/防守关卡的玩法根基就是咽喉点 + 围墙 mazing。PVE 里玩家用中立物/可破坏岩石卡位挡 AI 波次，是核心乐趣，比 PVP 还重要。

**G. 氛围/可读性 ——无差别，PVE 甚至更重要（关卡叙事）**

### 判断框架（评估任何中立物机制用这个）
问两个问题：
1. **"这个机制是在和会思考的对手博弈吗？"** → 是 → PVE 里贬值（砍或简化）
2. **"这个机制是在解决'玩家不出基地'问题吗？"** → 是 → PVE 里升值（保留强化）

典型对照：juke（问题1=是）→ 砍；outpost 资源点（问题2=是）→ 强化。

---

## 三、本项目现状盘点（2026-08-12）

### 3.1 中立物完全是"墙纸"
- `scenes/environment/` 的 tree/rock/bush/sheep 全是纯视觉：无碰撞、无血量、不可破坏、不可选中、点击穿透。
- 每局**随机撒点生成**，位置不固定（`game_spawner.gd:268-330` `spawn_environment()`，由 `map_config.environment` 字典配置数量）。
- **z_index 无深度**：装饰 z=1 一律画在单位/建筑（z=0）之上，没 y_sort，树永远盖单位，没有"走到树北被挡、南边挡树"的伪 3D 感。

### 3.2 `terrain_obstacle.gd` 是死代码（重要复用点）
- 已写好 `ROCK / FOREST / RIVER` 三种带 StaticBody2D 矩形碰撞的地形障碍，按 obstacle_size 自动铺贴图。
- **49 张地图没一张在用**（无任何脚本/场景实例化它们）。`game_spawner` 的 `obstacle_rects` 数组永远为空。
- **可直接复用**作为"挡路 + 可破坏"的骨架。

### 3.3 没有战争迷雾
- 全项目无 fog of war / 单位视野遮蔽。地图对玩家始终全亮。`vision_range`(enemy_ai)/`VISION_RANGE`(ally_ai) 是 AI 仇恨检测半径，不是视野。
- D 类（视野博弈）的底层支撑不存在，要做需从零搭——印证"砍 D"的判断。

### 3.4 经济是"基地内封闭循环"（最大空位）
- 金币来源：**城堡/农场自动产金**（CASTLE 50/10s、FARM 20/10s）+ 一次性奖励（占领/拾取/开局）。
- **完全没有地图中立资源点**（无金矿/采木/creeps 守矿）。资源池只有一个：金币。
- 设计文档自己承认盲区：`docs/RTS_资源转化图分析.md:720` 经济图缺 **T2（地盘）正反馈环**——"占领新地盘 → 更多经济"这条环是断的。
- **这是中立物设计最大的系统价值点**：补这条环 = 解决"玩家无出基地动力"。

### 3.5 OutpostCommander 已是"必争之地"雏形
- 敌方 AI 大脑节点 + 领地圈，清空圈内敌军即占领。
- 占领后圈内可建特殊建筑（目前只有 `ALTAR_ARCHER` 战斗型）。设计稿规划 4 选 1（经济丰收祭坛 / 科技时代圣殿 / 战斗祭坛 / 升级兵营），但只实现了战斗型。
- **是扩展"中立物/中立建筑"最自然的接入点**（领地圈 + 光圈建造区 + 4 选 1 基础设施已部分落地）。
- 注意：项目有**两套"据点"系统**易混——`CapturePoint`（站圈读条 + 一次性奖励 + 可 recapture）vs `OutpostCommander`（清空式占领 + 解锁建造区 + 一次性不可逆）。

### 3.6 美术资源：Tiny Swords 包有现成 Resources 未用
- 素材包 `assets/Tiny Swords (Free Pack)/.../Terrain/Resources/` 下有 **Gold / Meat / Wood** 资源点美术，项目未用于游戏逻辑。
- 这是做"中立资源点"的现成美术，不用外部找图。
- `CollectibleItem`（一次性拾取）和 `CapturePoint`（占领式）是两个现成的机制载体，可复用。

---

## 四、对机制设计的约束

| 维度 | 约束 | 来源 |
|---|---|---|
| 单局时长 | ~10 分钟（T1 0-2 / T2 2-6 / T3 6-10） | `docs/RTS_玩法设计建议.md` |
| 回本速度 | 收益延迟必须 < 60-90s，不能慢热 | SH1 候选 A 丰收祭坛 67s 回本参考 |
| 模式 | 纯 PVE + 合作 PVE，关卡制（20 关），三时代 + 每 2 分钟骚扰波 | 同上 + `wave_manager.gd` |
| 美术 | 必须复用 Tiny Swords 包内素材（Resources/Buildings） | `docs/manual/asset_sources.md` |
| 系统复用 | `terrain_obstacle.gd`（碰撞骨架）/ `CollectibleItem`（拾取）/ `CapturePoint`（占领）/ `OutpostCommander`（领地圈）/ 单位 `HealthComponent`（可破坏）/ 驻军系统（驻扎） | 见 3.2-3.5 |

---

## 五、机制候选菜单（待用户勾选）

> 按 PVE 价值 + 实现成本排序。每个模块独立可选，标注解决哪个问题、复用什么、推荐度。

### 机制 A：可破坏中立物（挡路 + 砍/砸开出路）—— B 类
- **解决**：墙纸无玩法 + 咽喉点卡位
- **PVE 意义**：B 类轻量版。关卡设计师用树/石墙封住捷径，玩家打掉开路；防守关卡玩家可主动伐木造墙卡位挡波次。非全战场破坏，是"局部付费开路"。
- **复用**：`terrain_obstacle.gd`（碰撞骨架）+ 单位 `HealthComponent`（挂到装饰上）+ 进 damage 组
- **美术**：现有 tree/rock 贴图
- **成本**：低-中　**推荐**：⭐⭐⭐（最便宜，先解决墙纸）

### 机制 B：中立资源点（金矿 / 浆果 / 木材）—— E 类
- **解决**：玩家无出基地动力（经济封闭循环）+ 补 T2 地盘正反馈环
- **PVE 意义**：系统价值最大。地图上撒资源点，占领/采集 → 持续金币或一次性奖励。强制玩家分兵探索 + 暴露在波次风险下。
- **复用**：`CollectibleItem`（一次性）/ `CapturePoint`（占领式持续产出）/ `OutpostCommander` 领地圈（资源点 + 守卫）
- **美术**：Tiny Swords Resources（Gold/Meat/Wood）现成
- **成本**：中　**推荐**：⭐⭐⭐（系统价值最大）

### 机制 C：中立守卫 creeps（守资源点 / 守要道）—— A 类 + 单向伏击
- **解决**：让占领有"成本"，平衡资源点收益；PVE 单向伏击子类
- **PVE 意义**：WC3 creeps 式——资源点/咽喉点被中立敌对怪守着，打掉才能占领/采集。配合机制 B 用。
- **复用**：`enemy_ai`（中立阵营 owner_id=-1）+ 击杀奖励触发器
- **成本**：中　**推荐**：⭐⭐（配合 B 用，单独意义小）

### 机制 D：可驻扎中立建筑（废墟 / 瞭望塔）—— C 类简化
- **解决**：防守关卡的站位深度
- **PVE 意义**：C 类简化——步兵进驻获射程/视野 buff。不做方向掩体，纯"进驻=变强"。
- **复用**：项目已有驻军系统（`docs/manual/驻军系统_配置教程.md`）
- **成本**：低（驻军系统成熟）　**推荐**：⭐⭐（防御关卡有价值）

### 机制 E：草丛隐蔽（AI targeting modifier）—— D 类 PVE 简化
- **解决**：让中立物有玩法差异（草丛 ≠ 树 ≠ 石头）
- **PVE 意义**：D 类单向简化——进草单位暂时"AI 不主动选为目标"，出草恢复。**不做 LoS/迷雾**，只改 `enemy_ai` 目标选择，轻量。
- **复用**：改 `enemy_ai.gd` 目标选择 + 草丛 Area2D（注意和 `stealth_effect` 区分）
- **成本**：中　**推荐**：⭐（PVE 下价值有限，且易和 stealth 混淆）

### 横切问题：z_index / y_sort 修复（视觉，非机制）
- 现状树永远盖单位（z=1 > z=0），无伪 3D 深度感。
- 修法：给 Environment 容器开 `y_sort_enabled` + 调 z_index 规则。
- 是否顺手修，视机制选项定（如果做 A 可破坏物，建议一起修）。

---

## Sources
- [StarCraft II Maps – Liquipedia](https://liquipedia.net/starcraft2/Maps) · [Urban Gustavsson SC2 地图设计](https://www.urbangustavsson.com/starcraft2) · [Blistering Sands](https://starcraft.fandom.com/wiki/Blistering_Sands)
- [WC3 Neutral Buildings – Battle.net 官方](http://classic.battle.net/war3/neutral/buildings.shtml) · [Mercenary Camp Wiki](https://warcraft.wiki.gg/wiki/Mercenary_Camp)
- [CoH 可破坏战场 – Rock Paper Shotgun](https://www.rockpapershotgun.com/how-company-of-heroes-made-a-destructible-battlefield) · [CoH 掩体设计师日记 – GameSpot](https://www.gamespot.com/articles/company-of-heroes-designer-diary-2-using-cover-in-a-world-war-ii-game/1100-6151877/)
- [Dota 2 Fog of War 机制](https://www.youtube.com/watch?v=6y2MnotFmm8) · [LoL Brush Wiki](https://wiki.leagueoflegends.com/en-us/Brush)
- [AoE4 Sacred Site](https://ageofempires.fandom.com/wiki/Sacred_Site) · [AoE4 Relic](https://ageofempires.fandom.com/wiki/Relic_(Age_of_Empires_IV)) · [AoE4 Trade](https://ageofempires.fandom.com/wiki/Trade_(Age_of_Empires_IV))
- [RTS Fundamentals – Game Design Skills](https://gamedesignskills.com/game-design/real-time-strategy/) · [RTS Level Design Layout – Tobias Heussner](https://theussner.wordpress.com/2010/09/13/rts-level-design-the-layout-part-1/)
