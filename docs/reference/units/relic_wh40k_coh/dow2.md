# 战锤40K：战争黎明2 — 单位数据调研

> **版本信息**
> - 游戏版本：Dawn of War II (2009) + Chaos Rising (2010) + Retribution (2011)
> - 数据来源：Liquipedia DoW / Fandom Wiki / 训练知识综合
> - 调研日期：2026-06-17
> - 注意：DoW2 经历多次平衡补丁，本表以 Retribution 最终版本为基准，部分数值为近似值（标注 ~）
> - 数据来源说明：本次调研因网络工具受限，部分精确数值基于训练知识编写，标注 ~ 的为近似值。核心设计框架和协同关系为准确数据。

---

## DoW2 核心系统概述

DoW2 与传统 RTS 的关键差异：

| 系统 | 说明 |
|---|---|
| **小队制** | 步兵以小队为单位，3-6 人/队，可逐个增援 |
| **英雄 RPG** | 每族 3 位英雄可选，可装备战利品（Wargear）改变技能 |
| **掩体系统** | 绿掩体（伤害减免 50%）、黄掩体（压制抗性）、驻军建筑 |
| **压制** | 重武器（重爆弹/子母弹）可压制小队，使其移速极慢且无法冲锋 |
| **撤退** | 按 X 键撤退至 HQ，2x 移速、受到伤害 -50%、无法攻击 |
| **科技层级** | T1（基础步兵）→ T2（专业步兵/轻型载具）→ T3（重型载具/终末单位）|
| **经济** | Requisition（战略点产出）+ Power（发电站产出）|
| **胜利点模式** | 3 个 VP 点，持有方扣减对手门票（500 → 0）|

### 护甲与伤害类型

| 伤害类型 | 克制 | 被克 |
|---|---|---|
| Normal（普通近战/手枪）| 轻步兵 | 重步兵/载具 |
| Piercing（爆弹枪/穿刺）| 轻步兵 | 重步兵/载具 |
| Plasma（等离子）| 重步兵 | 载具 |
| Anti-Vehicle（反载具）| 载具 | 步兵 |
| Flame（火焰）| 驻军/轻步兵 | 载具 |
| Artillery（炮击）| 驻军/密集步兵 | — |

| 护甲类型 | 典型单位 |
|---|---|
| Infantry（步兵）| 守护者、奴隶小子、虫群 |
| Heavy Infantry（重步兵）| 战术步兵、终结者 |
| Vehicle（载具）| 无畏机甲、掠食者 |
| Building（建筑）| 所有建筑 |
| Commander（指挥官）| 英雄单位 |

---

# 第一部分：种族设计分析

---

## 1. Space Marines（星际战士）

### 1.1 设计哲学
> "少数精英，每一名都是堡垒。" — 高成本、高生存、高弹性，以小队质量碾压数量。

### 1.2 核心签名机制
- **Drop Pod（空降舱）**：从轨道直接投放单位/增援到战场任意位置
- **And They Shall Know No Fear（ATSKNF）**：短时间免疫压制、免疫士气崩溃
- **装甲类型优势**：重步兵护甲，对普通穿刺伤害有天然抗性
- **可塑性武器升级**：战术步兵可切换爆弹枪/喷火器/导弹发射器/等离子枪

### 1.3 角色分工

| 定位 | 单位 | 说明 |
|---|---|---|
| 侦察 | Scout Squad | 隐形、狙击枪、占点 |
| 核心步兵 | Tactical Marine Squad | 全能型，可切换反步兵/反载具 |
| 突击 | Assault Marine Squad | 跳跃近战，侧翼包抄 |
| 火力压制 | Devastator Marine Squad | 重爆弹压制 / 等离子炮 AoE |
| 反载具步行机 | Dreadnought | 近战反载具 + 突击炮 |
| 运输 | Razorback | 运输 + 双联重爆弹 |
| 主战坦克 | Predator | 反步兵/反载具武器配置 |
| 终末步兵 | Terminator Squad | 重甲传送，T3 |
| 终末突击 | Assault Terminator | 闪电爪传送近战 |
| 超重坦克 | Land Raider | 运输 + 双激光，T3 终极 |

### 1.4 科技树节奏

| 层级 | 解锁内容 | 关键升级 |
|---|---|---|
| T1 | Scout / Tactical / Assault / Devastator | 基础步兵战 |
| T1→T2 | Techmarine 建 Tech Lab 或 HQ 升级 | 解锁载具 + 武器升级 |
| T2 | Dreadnought / Razorback / Predator | 载具战阶段 |
| T2→T3 | HQ 终极升级 | 终结者/突击终结者/Land Raider |
| T3 | Terminator / Assault Terminator / Land Raider | 终极单位 |

### 1.5 核心协同组合

1. **Devastator 压制 + Tactical 推进**：重爆弹压制对方步兵，战术步兵利用 ATSKNF 免疫对方压制后推进射击
2. **Drop Pod 突袭**：Force Commander 使用 Battle Cry + 空降舱直接投放 Dreadnought 到敌后
3. **Scout 狙击 + Assault 跳跃收割**：Scout 狙击枪削减对方小队人数，Assault Marine 跳跃收割残队
4. **Razorback 运输 + Tactical 喷火清驻军**：Razorback 载 Tactical 携喷火器，快速接近驻军建筑
5. **Dreadnought + ATSKNF 保护**：Dreadnought 冲锋时 Tactical 使用 ATSKNF 确保不被压制
6. **Terminator 传送 + Assault Terminator 闪电爪**：T3 双终末单位传送突入敌方阵地
7. **Techmarine 炮塔锁点 + Devastator 封路**：防御型封锁地图关键路径

### 1.6 生产机制
- HQ 生产 Scout / Tactical / Assault / Devastator
- Techmarine 可建造炮塔（Turret）和发电站
- 载具从 Tech Lab（Techmarine）或 HQ T2 升级后生产
- Drop Pod 增援：战场上任意位置直接增援小队成员（需升级）
- 终末单位从 HQ T3 生产

### 1.7 机动哲学
- 核心移速偏慢，依赖 Drop Pod 和 Assault Marine 跳跃获取机动性
- Terminator 传送提供突然性
- Razorback 运输提升 Tactical 机动
- 整体偏阵地推进，以火力优势逐步压缩

### 1.8 视野与地图控制
- Scout 隐形侦察 + 狙视
- Devastator 射程远，控制通道
- Techmarine 炮塔锁点控制地图
- T3 之前视野一般，依赖 Scout

### 1.9 反制弱点
- 小队数量少，被围攻时难以多线应对
- 成本高，损失代价大
- T1 反载具能力弱（需 Tactical 导弹升级或 Devastator 激光）
- 面对大规模廉价步兵海（Ork Slugga 海/Tyranid 虫海）时火力不足
- 依赖撤退增援，被堵家门时经济崩溃

### 1.10 强势时间窗
- **T1 中期**：Tactical + Devastator 组成型好，正面碾压
- **T2 初期**：Dreadnought 出场，对方反载具未就绪时极强
- **T3**：终结者传送突袭，终结局面

### 1.11 经济模型
- 战略点 Requisition 产出一般
- Power 需 Techmarine/ HQ 建造发电站
- 单位成本高，每损失一个小队成员需 ~50-80 Requisition 增援
- 经济节奏偏慢，依赖质量取胜
- 胜利点模式中防守能力强，擅长锁点

---

## 2. Chaos（混沌星际战士 — Chaos Rising）

### 2.1 设计哲学
> "腐化万物，以混沌标记重塑战局。" — 变异版 SM，以混沌标记和恶魔召唤提供差异化路线。

### 2.2 核心签名机制
- **Corruption（腐化）**：部分单位/技能施加腐化效果，降低敌方护甲/移速
- **Mark of Chaos（混沌标记）**：英雄可装备 Khorne/Nurgle/Tzeentch 标记，改变技能路线
- **Daemonic Summoning（恶魔召唤）**：Bloodletter / Bloodcrusher 可深空打击到战场
- **腐化抗性**：Chaos 单位对腐化效果免疫

### 2.3 角色分工

| 定位 | 单位 | 说明 |
|---|---|---|
| 炮灰 | Cultist Squad | 廉价肉盾，可贴腐化光环 |
| 核心步兵 | Chaos Space Marines | 对标 Tactical，略弱但可配标记 |
| 恶魔近战 | Bloodletters | 深空打击近战恶魔 |
| 火力压制 | Chaos Havocs | 重爆弹/自动炮压制 |
| 反载具步行机 | Khorne Dreadnought | 血怒近战 walker |
| 运输 | Chaos Rhino | 运输 + 混沌光环 |
| 主战坦克 | Chaos Predator | 与 SM 掠食者类似 |
| 恶魔骑兵 | Bloodcrusher | 骑兵型反载具/反步兵 |
| 终末步兵 | Chaos Terminators | 重甲传送，T3 |

### 2.4 科技树节奏

| 层级 | 解锁内容 | 关键升级 |
|---|---|---|
| T1 | Cultist / CSM / Bloodletters / Havocs | 基础 + 恶魔召唤 |
| T2 | Khorne Dreadnought / Rhino / Bloodcrusher / Predator | 载具 + 恶魔骑兵 |
| T3 | Chaos Terminators | 终末单位 |

### 2.5 核心协同组合

1. **Cultist 腐化 + CSM 射击**：Cultist 贴近降低敌方护甲，CSM 集火
2. **Bloodletter 深空打击 + Chaos Lord Khorne 标记**：突然近战突入
3. **Havoc 压制 + Bloodcrusher 冲锋**：压制锁定后骑兵收割
4. **Rhino 运输 + CSM 喷火**：快速接近驻军清场
5. **Sorcerer Tzeentch 标记 + Doombolt + Chains of Torment**：法术爆发
6. **Plague Champion Nurgle 标记 + 腐化光环 + 毒气**：持续削弱
7. **Chaos Terminator 传送 + Khorne Dreadnought 冲锋**：T3 双线突破

### 2.6 生产机制
- HQ 生产步兵
- 恶魔单位（Bloodletter / Bloodcrusher）可深空打击，不需从建筑走出
- 载具从 T2 解锁后 HQ 生产
- Chaos Lord 的标记选择改变可解锁的升级路线

### 2.7 机动哲学
- Bloodletter / Bloodcrusher 深空打击提供瞬间机动
- Sorcerer 传送法术
- 整体机动性中等，依赖恶魔召唤创造局部优势
- Rhino 运输提升步兵机动

### 2.8 视野与地图控制
- Cultist 可隐形侦察（需升级）
- Chaos 炮塔不如 SM Techmarine 炮塔强
- 依赖 Bloodletter 深空打击获取视野
- 地图控制偏弱，依赖主动出击

### 2.9 反制弱点
- 基础步兵质量略逊 SM（CSM 比 Tactical 略弱）
- T1 反载具依赖 Havoc 升级
- 恶魔单位被反恶魔加成武器克制
- 经济压力大于 SM（恶魔召唤成本高）
- 依赖英雄标记选择，选错路线会陷入被动

### 2.10 强势时间窗
- **T1 中期**：Bloodletter 深空打击 + CSM 推进
- **T2 初期**：Bloodcrusher 出场，反载具/反步兵双能力极强
- **T2 中期**：Khorne Dreadnought + Predator 载具波

### 2.11 经济模型
- Requisition 产出与 SM 类似
- 恶魔召唤需要额外 Power 成本
- Cultist 成本极低（~150 Req），可大量铺
- 整体经济偏紧，需精确投资

---

## 3. Eldar（神灵族）

### 3.1 设计哲学
> "速度即装甲，专精即力量。" — 最高机动性 + 高度专业化单位，每单位只擅长一件事。

### 3.2 核心签名机制
- **Fleet of Foot（疾行）**：Eldar 全族被动高移速，Farseer 可激活进一步加速
- **Webway Gate（传诵门）**：建造传诵门网络，单位可跨地图传送
- **高度专精**：每个单位只擅长一种角色（Banshee 只近战、Fire Dragon 只反载具）
- **重力手雷/牵引**：部分单位可减速/定身敌方

### 3.3 角色分工

| 定位 | 单位 | 说明 |
|---|---|---|
| 廉价远程 | Guardian Squad | 5 人廉价射击，可配武器平台 |
| 狙击/侦察 | Ranger Squad | 隐形狙击，破甲 |
| 近战专家 | Howling Banshees | 5 人近战，压制免疫 |
| 传送突击 | Warp Spider Squad | 5 人传送射击，高爆发 |
| 反载具专家 | Fire Dragon Squad | 反载具融化枪 |
| 运输悬浮 | Falcon | 悬浮运输 + 射击 |
| 步行机 | Wraithlord | 近战/射击 walker |
| 悬浮坦克 | Fire Prism | 棱镜炮 AoE |
| 终末单位 | Avatar of Khaine | 超级近战，光环 buff |
| 反载具武器平台 | Brightlance Platform | 固定反载具炮 |

### 3.4 科技树节奏

| 层级 | 解锁内容 | 关键升级 |
|---|---|---|
| T1 | Guardian / Ranger / Banshee / Brightlance | 专精步兵战 |
| T2 | Warp Spider / Fire Dragon / Falcon / Wraithlord | 传送 + 反载具 + walker |
| T3 | Fire Prism / Avatar | 终末单位 |

### 3.5 核心协同组合

1. **Banshee 冲锋 + Guardian 射击**：Banshee 免疫压制冲锋锁定，Guardian 后排射击
2. **Warp Spider 传送 + Fire Dragon 反载具**：传送到载具背后，融化枪爆发
3. **Ranger 狙击 + Fleet of Foot 拉扯**：狙击后利用高移速拉开距离
4. **Webway Gate 传送 + 全族机动**：传诵门网络实现多线突袭
5. **Farseer Guide + Guardian 平台**：Guide 命中率 buff 搭配重武器平台
6. **Wraithlord 前排 + Fire Prism 后排 AoE**：walker 吸引火力，棱镜炮清洗步兵
7. **Avatar + 全族光环**：Avatar 提供生产速度/伤害光环

### 3.6 生产机制
- HQ 生产步兵
- Webway Gate 由 Farseer/Warlock 建造，解锁传送网络
- 载具从 T2 解锁
- 部分单位（Warp Spider）自带传送能力

### 3.7 机动哲学
- 全族最高移速（Fleet of Foot）
- Warp Spider 传送提供垂直机动
- Webway Gate 提供水平机动（跨地图传送）
- 设计核心：打完就跑，绝不久留

### 3.8 视野与地图控制
- Ranger 隐形 + 狙视
- Fleet of Foot 快速占点
- Webway Gate 建在关键路口控制视野
- 地图控制能力强，依赖机动占点

### 3.9 反制弱点
- 单位血量极低，最脆弱的种族
- 专精设计导致缺乏通用性（Banshee 不能射击、Fire Dragon 不能反步兵）
- 载具较少且血量不高
- 被压制/被堵住后机动优势消失
- 对火焰武器极度脆弱（低血量 + 轻甲）

### 3.10 强势时间窗
- **T1 全程**：Banshee + Guardian + Ranger 高机动压制
- **T2 初期**：Warp Spider 传送突袭，对方难以防备
- **T3**：Avatar 光环 + Fire Prism AoE

### 3.11 经济模型
- Requisition 产出依赖快速占点（高移速优势）
- Power 投入集中在武器平台/传诵门
- 单位成本中等偏低
- 损失代价高（血量低，容易全灭）
- 胜利点模式中占点速度最快

---

## 4. Orks（兽人）

### 4.1 设计哲学
> "Waaagh! 数量即质量，吵闹即是力量。" — 廉价海量单位 + Waaagh 暴走机制，以人海和蛮力淹没对手。

### 4.2 核心签名机制
- **Waaagh!**：Warboss 激活或被动触发，全族 Ork 短时间伤害/移速提升
- **Mob Bonus（群体加成）**：Ork 单位周围友军越多，伤害越高
- **堆积感**：Ork 建筑/单位有"越打越大"的视觉特征
- **Stikkbombz**：廉价手雷，海量投掷

### 4.3 角色分工

| 定位 | 单位 | 说明 |
|---|---|---|
| 廉价近战 | Slugga Boyz | 6 人最便宜近战，人海核心 |
| 廉价远程 | Shoota Boyz | 6 人廉价射击，可升级重武器 |
| 跳跃近战 | Stormboyz | 6 人跳跃包近战 |
| 反载具 | Tankbustas | 3 人反载具导弹 |
| 火力压制 | Lootas | 3 人重武器压制 |
| 步行机 | Deff Dread | 近战 walker |
| 运输 | Wartrukk | 运输 + 撞人 |
| 主战坦克 | Looted Tank | 炮击坦克 |
| 精英近战 | Nob Squad | 5 人重甲精英，T3 |
| 重型运输 | Battlewagon | T3 重型运输/碾压 |

### 4.4 科技树节奏

| 层级 | 解锁内容 | 关键升级 |
|---|---|---|
| T1 | Slugga / Shoota / Stormboy / Tankbusta / Loota | 人海基础 |
| T2 | Deff Dread / Wartrukk / Looted Tank | 载具 |
| T3 | Nob Squad / Battlewagon | 精英 + 重型载具 |

### 4.5 核心协同组合

1. **Slugga 人海 + Waaagh!**：Warboss 激活 Waaagh!，Slugga 海集体冲锋
2. **Shoota 重武器 + Slugga 肉盾**：Shoota 升级重爆弹后排输出，Slugga 前排挡
3. **Stormboy 跳跃 + Loota 压制**：Loota 压制锁定，Stormboy 跳跃收割
4. **Tankbusta 埋伏 + Wartrukk 冲锋**：Wartrukk 载 Tankbusta 快速接近载具
5. **Deff Dread + Slugga 围杀**：Deff Dread 吸引反载具火力，Slugga 围杀
6. **Nob Squad + Battlewagon**：T3 终极组合，Battlewagon 运输 Nob 冲入敌阵
7. **Mob Bonus 堆叠**：所有 Ork 单位集中在一片区域，伤害乘数叠加

### 4.6 生产机制
- HQ 生产步兵
- 载具从 T2 解锁
- 单位成本极低，可快速大量生产
- Mob Bonus 鼓励集中生产同类型单位

### 4.7 机动哲学
- 基础移速慢
- Stormboy 跳跃提供机动
- Wartrukk 运输提供速度
- 整体偏"推土机"式推进，不擅长拉扯
- Waaagh! 激活时移速提升，弥补机动不足

### 4.8 视野与地图控制
- 视野一般
- Kommando Nob 隐形侦察
- 依赖人海铺满地图
- 地图控制弱，依赖数量占点

### 4.9 反制弱点
- 单位血量低，容易被 AoE 清洗
- 依赖 Waaagh! 时间窗，非 Waaagh 期间战斗力骤降
- 载具质量差，容易被反载具武器摧毁
- 缺乏精确打击能力（全靠人海）
- 面对火焰/炮击 AoE 时损失极大

### 4.10 强势时间窗
- **T1 全程**：Slugga + Shoota 人海压制
- **Waaagh! 激活期**：全族暴走，正面碾压
- **T3 初期**：Nob Squad + Battlewagon 出场

### 4.11 经济模型
- 单位成本最低（Slugga ~270 Req / 6 人）
- 战略点占点快（人多）
- Power 投入集中（载具/升级）
- 损失代价低（人海可快速补充）
- 胜利点模式中以数量优势锁点

---

## 5. Tyranids（泰伦虫族）

### 5.1 设计哲学
> "吞噬一切，进化即进化。" — 虫海 + 共生体进化 + Synapse 神经网，以生物集群和适应性碾压。

### 5.2 核心签名机制
- **Synapse（突触）**：Tyranid Warriors / Hive Tyrant / Carnifex 提供突触链接，范围内小单位获得 buff（伤害/移速/免疫压制）
- **共生体进化**：部分单位可升级武器/生物形态（Termagant 可换毒素弹、Warrior 可换死亡喷吐器）
- **隧道系统（Ravener Alpha）**：Ravener Alpha 英雄可挖隧道，单位可跨地图通行
- **生物质回收**：部分版本中杀死敌人可回收生物质

### 5.3 角色分工

| 定位 | 单位 | 说明 |
|---|---|---|
| 廉价远程 | Termagants | 6 人廉价射击虫 |
| 廉价近战 | Hormagaunts | 6 人廉价近战虫，跳跃冲锋 |
| 诱饵/干扰 | Ripper Swarms | 3 体虫群，无法增援，吸引火力 |
| 突触核心 | Tyranid Warriors | 3 人突触单位，可升级武器 |
| 隐形近战 | Genestealers | 5 人隐形近战，高爆发 |
| 隐形刺客 | Lictor | 隐形单体，标记目标 |
| 重型 walker | Carnifex | 巨型生物 walker，可配多种武器 |
| 法术反载具 | Zoanthrope | 精神炮反载具 |
| 炮击 | Biovores | 生物炮兵，AoE |

### 5.4 科技树节奏

| 层级 | 解锁内容 | 关键升级 |
|---|---|---|
| T1 | Termagant / Hormagant / Ripper / Warrior | 虫海 + 突触 |
| T2 | Genestealer / Lictor / Carnifex / Zoanthrope / Biovore | 精英 + walker |
| T3 | Carnifex 升级 / 高级形态 | 终极进化 |

### 5.5 核心协同组合

1. **Hormagaunt 虫海 + Warrior 突触**：突触范围内 Hormagaunt 免疫压制、伤害提升
2. **Termagant 射击 + Ravener 隧道侧翼**：隧道传送 Termagant 到侧翼射击
3. **Genestealer 隐形 + Lictor 标记**：Lictor 标记目标，Genestealer 隐形接近爆发
4. **Carnifex 冲锋 + Zoanthrope 反载具**：Carnifex 吸引火力，Zoanthrope 精神炮打载具
5. **Ripper 干扰 + Biovore 炮击**：Ripper 吸引注意力，Biovore 远程炮击
6. **Hive Tyrant + Warrior 双突触**：双突触覆盖大范围虫海
7. **Ravener 隧道 + 全族机动**：隧道网络实现虫海跨地图投放

### 5.6 生产机制
- HQ 生产基础虫群
- Tyranid Warriors 作为突触核心，自身是 T1 单位但提供全族 buff
- 隧道由 Ravener Alpha 英雄挖掘
- 单位成本极低（Termagant/Hormagaunt ~200 Req / 6 人）

### 5.7 机动哲学
- 基础移速中等
- Ravener 隧道提供跨地图机动
- Hormagaunt 冲锋跳跃
- Genestealer 隐形接近
- 整体依赖突触覆盖范围，超出突触范围的虫群会变弱

### 5.8 视野与地图控制
- Lictor 隐形侦察 + 标记
- 隧道口提供视野
- Ripper 快速占点
- 地图控制强（虫海铺满 + 隧道网络）

### 5.9 反制弱点
- **杀突触即破阵**：杀死 Warrior / Hive Tyrant 后虫群失去 buff，战斗力骤降
- 低级虫群血量极低，被 AoE 清洗
- T1 反载具依赖 Zoanthrope（T2），T1 只有 Warrior 升级
- 突触单位本身成本高，被集火秒杀后虫海崩溃
- 面对火焰武器时虫海损失极大

### 5.10 强势时间窗
- **T1 全程**：Hormagaunt + Warrior 虫海，突触覆盖后极强
- **T2 初期**：Genestealer 隐形突袭 + Carnifex 出场
- **Ravener 隧道建成**：跨地图突袭能力极强

### 5.11 经济模型
- 单位成本最低（与 Ork 相当）
- 战略点占点快（虫海）
- 突触单位需要 Power 投入
- 损失代价低（虫海可快速补充）
- 突触单位损失代价高（Power 成本）

---

## 6. Imperial Guard（帝国卫队 — Retribution）

### 6.1 设计哲学
> "人海 + 钢铁洪流，以壕沟和炮火定义战场。" — 大量廉价步兵 + 最强载具阵容 + 阵地防御。

### 6.2 核心签名机制
- **战壕/阵地防御**：Commissar Lord / Inquisitor 可建造防御工事
- **Execute（枪决）**：Commissar Lord 可枪决己方步兵以 buff 周围部队
- **重型载具阵容**：Leman Russ + Baneblade，全族最强载具
- **步兵增援机制**：Guardsmen 极廉价，可大量增援填补

### 6.3 角色分工

| 定位 | 单位 | 说明 |
|---|---|---|
| 廉价步兵 | Guardsmen Squad | 6 人最廉价射击步兵 |
| 精英步兵 | Catachan Devils | 4 人精锐，喷火/近战 |
| 火力压制 | Heavy Weapon Team | 3 人重爆弹/自动炮 |
| 侦察 walker | Sentinel | 轻型步行机，快速侦察 |
| 重型近战 | Ogryn Squad | 3 人巨兽近战 |
| 主战坦克 | Leman Russ Battle Tank | 全族最强主战坦克 |
| 超重坦克 | Baneblade | 11 管武器超重坦克，T3 |
| 精锐远程 | Kasrkin Squad | 5 人热弹枪精锐射击 |

### 6.4 科技树节奏

| 层级 | 解锁内容 | 关键升级 |
|---|---|---|
| T1 | Guardsmen / Catachan / HWT / Sentinel | 步兵 + 阵地 |
| T2 | Ogryn / Leman Russ / Kasrkin | 载具 + 精锐 |
| T3 | Baneblade | 超重载具 |

### 6.5 核心协同组合

1. **Guardsmen 人海 + Commissar Execute**：Commissar 枪决一个 Guardsmen，周围步兵伤害 buff
2. **HWT 压制 + Leman Russ 炮击**：HWT 压制锁定，Leman Russ 炮击清洗
3. **Catachan 喷火 + Guardsmen 射击**：Catachan 喷火清驻军，Guardsmen 补射
4. **Sentinel 侦察 + Leman Russ 远程**：Sentinel 提供视野，Leman Russ 远程炮击
5. **Ogryn 前排 + Kasrkin 后排**：Ogryn 肉盾近战，Kasrkin 热弹枪后排输出
6. **Baneblade + 全族掩护**：Baneblade 吸引所有反载具火力，步兵掩护
7. **战壕防线 + HWT 封路**：壕沟 + 重武器构建坚不可摧的防线

### 6.6 生产机制
- HQ 生产步兵
- 载具从 T2 解锁后生产
- Guardsmen 成本极低，可大量增援
- Baneblade 需要 T3 + 大量资源

### 6.7 机动哲学
- 步兵移速慢
- Sentinel 提供快速侦察
- Leman Russ 移速一般但火力强
- 整体偏阵地战/推土机推进
- 不擅长拉扯和机动战

### 6.8 视野与地图控制
- Sentinel 快速侦察
- Inquisitor 隐形侦察
- 阵地防御锁点
- 依赖载具提供火力覆盖

### 6.9 反制弱点
- 步兵血量极低（Guardsmen 是全游戏最脆步兵之一）
- T1 反载具依赖 HWT 升级
- 依赖载具，载具被毁后步兵无力
- 机动性差，被侧翼包抄时难以应对
- Baneblade 成本极高，被毁代价巨大

### 6.10 强势时间窗
- **T1 阵地防御**：HWT + Guardsmen 建立防线
- **T2 Leman Russ 出场**：全族最强主战坦克，对方反载具未就绪时极强
- **T3 Baneblade**：超重坦克碾压一切

### 6.11 经济模型
- Guardsmen 成本最低（~200 Req / 6 人）
- 载具成本高（Leman Russ ~450 Req + 80 Power）
- Baneblade 成本极高（~600 Req + 150 Power）
- 步兵损失代价低，载具损失代价高
- 胜利点模式中擅长防守锁点

---

# 第二部分：英雄数据

DoW2 每族 3 位英雄，每位英雄有 4 个技能槽位、可装备战利品（Wargear）、三种升级路线。

---

## Space Marines 英雄

### Force Commander（连长）

| 维度 | 内容 |
|---|---|
| **定位** | 近战坦克 / 前线 buff |
| **HP** | ~1200 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~45（近战）/ ~20（手枪） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Battle Cry | 激活后 10s 内伤害 +30%、免疫压制 |
| 2 | ATSKNF | 目标小队 5s 免疫压制 |
| 3 | Drop Pod | 指定位置投放空降舱，可携带增援 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Assault（突击）** | Jump Pack（跳跃包）、Power Fist（动力拳套）、Thunder Hammer（雷锤） | 高机动近战爆发，跳跃包提供突进能力 |
| **Ranged（射击）** | Plasma Pistol（等离子手枪）、Master-Crafted Bolter（精工爆弹枪） | 中距离射击支援 |
| **Defense（防御）** | Iron Halo（铁光环）、Storm Shield（风暴盾） | 前线坦克，吸收火力 + buff 友军 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Power Sword | 基础 | 近战伤害提升 |
| Jump Pack | Assault | 赋予跳跃能力 |
| Power Fist | Assault | 近战伤害大幅提升，对载具有效 |
| Thunder Hammer | Assault | 近战伤害最高 + 范围击退 |
| Plasma Pistol | Ranged | 远程伤害提升，对重步兵有效 |
| Master-Crafted Bolter | Ranged | 远程射速/伤害提升 |
| Iron Halo | Defense | 伤害减免光环 |
| Storm Shield | Defense | 格挡近战 + 减伤 |

---

### Techmarine（技术军士）

| 维度 | 内容 |
|---|---|
| **定位** | 支援 / 防御建筑 / 维修 |
| **HP** | ~1000 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~30（近战）/ ~15（手枪） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Drop Pod | 空降舱投放 |
| 2 | Bionics | 目标载具/建筑维修 |
| 3 | Build Turret | 建造自动炮塔 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Constructor（建造）** | Techmarine Harness（技术背带）、Turret Upgrade（炮塔升级） | 强化建造能力，炮塔升级为火箭/激光 |
| **Ranged（射击）** | Plasma Cutter（等离子切割器）、Signum（信号仪） | 远程射击 + 标记目标 |
| **Melee（近战）** | Power Axe（动力斧）、Omnissiah Axe（全知之斧） | 近战输出提升 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Bolter | 基础 | 标准远程 |
| Plasma Cutter | Ranged | 等离子伤害 |
| Power Axe | Melee | 近战伤害提升 |
| Omnissiah Axe | Melee | 近战最高 + 反载具 |
| Techmarine Harness | Constructor | 建造速度提升 |
| Signum | Ranged | 标记目标，友军对其伤害 +25% |
| Flamer | Ranged | 喷火清驻军 |

---

### Apothecary（药剂师）

| 维度 | 内容 |
|---|---|
| **定位** | 治疗 / 支援 |
| **HP** | ~900 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~25（近战）/ ~12（手枪） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Heal | 目标小队持续治疗 |
| 2 | Purification | 移除负面效果 + 短时间伤害减免 |
| 3 | Larraman's Blessing | 目标小队短时间内伤害免疫 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Healing（治疗）** | Narthecium Upgrade（医疗器升级）、Apothecary Armor | 强化治疗能力 |
| **Ranged（射击）** | Bolt Pistol（爆弹手枪）、Combi-Flamer（组合喷火） | 远程支援 |
| **Melee（近战）** | Chainsword（链锯剑）、Power Weapon（动力武器） | 近战能力提升 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Narthecium | 基础 | 治疗能力 |
| Chainsword | Melee | 近战伤害提升 |
| Power Weapon | Melee | 近战穿甲 |
| Combi-Flamer | Ranged | 喷火清驻军 |
| Apothecary Armor | Healing | 自身生存提升 |
| Master-Crafted Signal | Healing | 治疗范围/效果提升 |

---

## Chaos 英雄

### Chaos Lord（混沌领主）

| 维度 | 内容 |
|---|---|
| **定位** | 近战坦克 / 混沌标记 buff |
| **HP** | ~1300 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~48（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Doom Pulse | AoE 伤害 + 击退 |
| 2 | Mark Ability | 随标记变化 |
| 3 | Summon Bloodletters | 深空打击恶魔小队 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线（Mark of Chaos）：**

| 路线 | 核心标记 | 风格 |
|---|---|---|
| **Khorne（恐虐）** | Mark of Khorne | 近战伤害 +50%，血怒模式 |
| **Nurgle（纳垢）** | Mark of Nurgle | 生命值 +30%、毒气光环 |
| **Tzeentch（奸奇）** | Mark of Tzeentch | 法术伤害提升、能量回复 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Power Sword | 基础 | 近战伤害提升 |
| Mark of Khorne | Khorne | 近战伤害 +50% |
| Mark of Nurgle | Nurgle | HP +30% + 毒气 |
| Mark of Tzeentch | Tzeentch | 法术强化 |
| Lightning Claw | Khorne | 近战最高伤害 |
| Plague Sword | Nurgle | 近战 + 腐化效果 |
| Warp Staff | Tzeentch | 传送能力 |

---

### Plague Champion（瘟疫勇士）

| 维度 | 内容 |
|---|---|
| **定位** | 支援 / 腐化 / 毒气 |
| **HP** | ~1100 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~35（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Blight Grenade | 毒气手雷，范围减速 + 持续伤害 |
| 2 | Corruption Aura | 被动光环，范围内敌方护甲降低 |
| 3 | Plague Aura | 被动光环，范围内友军生命回复 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Corruption（腐化）** | Plague Sword（瘟疫剑）、Blight Grenade Upgrade | 强化腐化/毒气 |
| **Ranged（射击）** | Blight Launcher（瘟疫发射器） | 远程毒气 |
| **Melee（近战）** | Manreaper（人收割者） | 近战 AoE |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Plague Sword | Corruption | 近战 + 腐化 |
| Manreaper | Melee | 近战 AoE 伤害 |
| Blight Launcher | Ranged | 远程毒气弹 |
| Blight Grenade Upgrade | Corruption | 手雷范围/伤害提升 |
| Nurgle Armor | Corruption | 自身生存提升 |

---

### Sorcerer（术士）

| 维度 | 内容 |
|---|---|
| **定位** | 法术输出 / 传送 / 控制 |
| **HP** | ~900 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~25（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Doombolt | 直线穿透法术 |
| 2 | Chains of Torment | 锁定目标，持续伤害 |
| 3 | Warp Rift | 传送门，可传送单位 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Tzeentch（奸奇）** | Warp Staff（曲速法杖）、Doombolt Upgrade | 法术爆发 |
| **Melee（近战）** | Accursed Crozius（诅咒牧杖） | 近战 + debuff |
| **Support（支援）** | Sigil of Corruption（腐化印记） | 腐化光环 + 友军 buff |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Warp Staff | Tzeentch | 传送能力 |
| Accursed Crozius | Melee | 近战 + debuff 敌方 |
| Sigil of Corruption | Support | 腐化光环 |
| Doombolt Upgrade | Tzeentch | 法术伤害提升 |
| Bolt Pistol | 基础 | 远程补充 |

---

## Eldar 英雄

### Farseer（先知）

| 维度 | 内容 |
|---|---|
| **定位** | 法术支援 / buff / debuff |
| **HP** | ~800 |
| **护甲** | Commander |
| **基础移速** | 6（Fleet of Foot） |
| **基础伤害** | ~25（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Guide | 目标小队命中率/伤害 +30% |
| 2 | Doom | 目标小队受到伤害 +30% |
| 3 | Fleet of Foot | 范围内友军移速 +50% |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Support（支援）** | Runes of Fortune（幸运符文）、Runes of Fate（命运符文） | 强化 buff/debuff |
| **Ranged（射击）** | Shuriken Pistol（飞镖手枪）、Singing Spear（歌唱之矛） | 远程伤害 |
| **Melee（近战）** | Witchblade（女巫之刃） | 近战输出提升 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Witchblade | Melee | 近战伤害大幅提升 |
| Singing Spear | Ranged | 远程 + 投掷伤害 |
| Runes of Fortune | Support | Guide 效果提升 |
| Runes of Fate | Support | Doom 效果提升 + Eldritch Storm |
| Shuriken Pistol | Ranged | 远程补充 |
| Spirit Stone | Support | 能量回复提升 |

---

### Warlock（术士）

| 维度 | 内容 |
|---|---|
| **定位** | 近战法术 / buff |
| **HP** | ~900 |
| **护甲** | Commander |
| **基础移速** | 6 |
| **基础伤害** | ~35（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Destructor | 范围能量伤害 |
| 2 | Enhance | 范围内友军伤害/防御提升 |
| 3 | Embolden | 目标小队移速/射速提升 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Melee（近战）** | Witchblade（女巫之刃）、Warp Blade（曲速之刃） | 近战爆发 |
| **Support（支援）** | Enhance Upgrade、Embolden Upgrade | buff 强化 |
| **Caster（法术）** | Destructor Upgrade、Conceal（隐蔽） | 法术伤害/隐蔽 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Witchblade | Melee | 近战伤害提升 |
| Warp Blade | Melee | 近战 + 传送 |
| Destructor Upgrade | Caster | 法术伤害提升 |
| Enhance Upgrade | Support | buff 效果提升 |
| Conceal | Caster | 隐形能力 |
| Embolden Upgrade | Support | 加速效果提升 |

---

### Warp Spider Exarch（曲速蜘蛛队长）

| 维度 | 内容 |
|---|---|
| **定位** | 传送突击 / 深空打击 |
| **HP** | ~850 |
| **护甲** | Commander |
| **基础移速** | 6 |
| **基础伤害** | ~30（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Teleport | 短距离传送 |
| 2 | Warp Trap | 放置曲速陷阱，触发时范围伤害 |
| 3 | Group Teleport | 传送周围友军小队 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Assault（突击）** | Power Blades（动力刀刃）、Death Spinner Upgrade | 近战/射击爆发 |
| **Support（支援）** | Warp Generator（曲速发生器）、Group Teleport Upgrade | 传送强化 |
| **Ranged（射击）** | Twin-Linked Death Spinner（双联死亡纺锤） | 远程伤害 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Power Blades | Assault | 近战双刀 |
| Twin-Linked Death Spinner | Ranged | 远程双联 |
| Warp Generator | Support | 传送范围/冷却提升 |
| Group Teleport Upgrade | Support | 群体传送人数提升 |
| Death Spinner Upgrade | Assault | 射击伤害提升 |

---

## Orks 英雄

### Warboss（战争老大）

| 维度 | 内容 |
|---|---|
| **定位** | 近战坦克 / Waaagh! 激活 |
| **HP** | ~1400 |
| **护甲** | Commander |
| **基础移速** | 5 |
| **基础伤害** | ~50（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Waaagh! | 全族激活：移速 +50%、伤害 +30%、免疫压制 |
| 2 | Use Yer Choppas | 目标小队近战伤害提升 |
| 3 | Grab | 抓取目标单位，定身 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Melee（近战）** | Power Klaw（动力爪）、'Eavy Armor（重甲） | 近战最高输出 |
| **Ranged（射击）** | Kustom Shoota（定制枪）、Big Shoota | 远程火力 |
| **Support（支援）** | Trophy Rack（战利品架）、Waaagh! Banner | buff 强化 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Power Klaw | Melee | 近战最高伤害，对载具有效 |
| 'Eavy Armor | Melee | 自身护甲提升 |
| Kustom Shoota | Ranged | 远程伤害提升 |
| Trophy Rack | Support | 周围友军伤害 buff |
| Waaagh! Banner | Support | Waaagh! 持续时间/效果提升 |
| Big Choppa | 基础 | 近战伤害中等提升 |

---

### Kommando Nob（突击队老大）

| 维度 | 内容 |
|---|---|
| **定位** | 隐形 / 伏击 / 奇袭 |
| **HP** | ~1000 |
| **护甲** | Commander |
| **基础移速** | 5 |
| **基础伤害** | ~35（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Infiltrate | 隐形 |
| 2 | Stun Bomb | 眩晕手雷，范围定身 |
| 3 | Stikkbomb | 范围伤害手雷 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Stealth（潜行）** | Speshul Shoota（特制枪）、Infiltrate Upgrade | 隐形狙击 |
| **Melee（近战）** | Power Klaw（动力爪）、'Uge Choppa（大砍刀） | 伏击近战 |
| **Support（支援）** | Stikkbomb Upgrade、Stun Bomb Upgrade | 手雷强化 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Speshul Shoota | Stealth | 隐形时远程伤害高 |
| Power Klaw | Melee | 近战爆发 |
| 'Uge Choppa | Melee | 近战 AoE |
| Stikkbomb Upgrade | Support | 手雷范围/伤害提升 |
| Stun Bomb Upgrade | Support | 眩晕时间提升 |

---

### Mekboy（技师小子）

| 维度 | 内容 |
|---|---|
| **定位** | 支援 / 建筑 / 科技 |
| **HP** | ~950 |
| **护甲** | Commander |
| **基础移速** | 5 |
| **基础伤害** | ~25（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Deff Dread | 深空打击一个 Deff Dread |
| 2 | Electric Shok | 范围电击伤害 + 减速 |
| 3 | Force Field | 放置力场护盾，阻挡弹道 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Constructor（建造）** | Mega-Rippa（超级撕裂器）、Turret Upgrade | 建造/防御 |
| **Melee（近战）** | Power Klaw（动力爪）、Electric Armor | 近战 + 电击 |
| **Ranged（射击）** | Kustom Mega Blasta（定制超级炮） | 远程爆发 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Mega-Rippa | Constructor | 建造速度提升 |
| Power Klaw | Melee | 近战伤害 |
| Electric Armor | Melee | 近战反伤 |
| Kustom Mega Blasta | Ranged | 远程高伤害 |
| Force Field Generator | Constructor | 力场范围提升 |
| Deff Dread Upgrade | Constructor | Deff Dread 成本/冷却降低 |

---

## Tyranids 英雄

### Hive Tyrant（虫巢暴君）

| 维度 | 内容 |
|---|---|
| **定位** | 近战突触 / 全族 buff |
| **HP** | ~1500 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~55（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Synapse | 提供突触链接，范围内虫群 buff |
| 2 | Psychic Scream | 范围 debuff，敌方伤害/防御降低 |
| 3 | Catalyst | 目标小队攻速 +50% |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Melee（近战）** | Bonesaber（骨剑）、Lash Whip（鞭击鞭） | 近战最高输出 |
| **Ranged（射击）** | Venom Cannon（毒液炮）、Stranglethorn（绞刺炮） | 远程 AoE |
| **Synapse（突触）** | Synapse Upgrade、Adrenal Glands（肾上腺） | 突触 buff 强化 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Bonesaber | Melee | 近战伤害最高 |
| Lash Whip | Melee | 近战 + 减速敌方 |
| Venom Cannon | Ranged | 远程反载具 |
| Stranglethorn | Ranged | 远程 AoE 反步兵 |
| Adrenal Glands | Synapse | 突触范围内攻速提升 |
| Synapse Upgrade | Synapse | 突触范围/效果提升 |
| Toxic Miasma | Synapse | 被动毒气光环 |

---

### Ravener Alpha（掘洞虫 Alpha）

| 维度 | 内容 |
|---|---|
| **定位** | 隧道系统 / 机动 / 侧翼 |
| **HP** | ~1100 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~40（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Burrow | 挖掘隧道入口 |
| 2 | Tunnel | 通过隧道传送单位 |
| 3 | Corrosive Shot | 远程酸液攻击，降低护甲 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Tunnel（隧道）** | Tunnel Upgrade、Burrow Upgrade | 隧道网络强化 |
| **Melee（近战）** | Rending Claws（撕裂爪）、Implant Attack（植入攻击） | 近战爆发 |
| **Ranged（射击）** | Corrosive Devourer（腐蚀吞噬者） | 远程腐蚀 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Rending Claws | Melee | 近战穿甲 |
| Implant Attack | Melee | 近战 + 持续伤害 |
| Corrosive Devourer | Ranged | 远程腐蚀 + 减甲 |
| Tunnel Upgrade | Tunnel | 隧道数量/范围提升 |
| Burrow Upgrade | Tunnel | 挖掘速度提升 |
| Toxin Sacs | Melee | 近战 + 毒素 |

---

### Lictor Alpha（潜伏者 Alpha）

| 维度 | 内容 |
|---|---|
| **定位** | 隐形刺客 / 侦察 / 标记 |
| **HP** | ~1000 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~45（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Infiltrate | 隐形 |
| 2 | Pheromone Trail | 标记目标，友军对其伤害 +50% |
| 3 | Flesh Hooks | 远程钩爪拉拽 + 伤害 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Stealth（潜行）** | Chameleonic Skin（变色皮）、Infiltrate Upgrade | 隐形强化 |
| **Melee（近战）** | Rending Claws（撕裂爪）、Feeder Tendrils（摄食触须） | 近战爆发 |
| **Support（支援）** | Pheromone Trail Upgrade、Flesh Hooks Upgrade | 标记/钩爪强化 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Chameleonic Skin | Stealth | 隐形移动速度提升 |
| Rending Claws | Melee | 近战穿甲 |
| Feeder Tendrils | Melee | 近战 + 回血 |
| Pheromone Trail Upgrade | Support | 标记效果/范围提升 |
| Flesh Hooks Upgrade | Support | 钩爪范围/伤害提升 |
| Toxic Miasma | Stealth | 隐形时被动毒气 |

---

## Imperial Guard 英雄（Retribution）

### Inquisitor（审判官）

| 维度 | 内容 |
|---|---|
| **定位** | 远程支援 / 隐形 / 法术 |
| **HP** | ~850 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~25（远程） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Infiltrate | 隐形 |
| 2 | Psyker Power | 灵能法术（随升级变化） |
| 3 | Pierce | 远程穿甲射击 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Stealth（潜行）** | Inferno Pistol（地狱手枪）、Infiltrate Upgrade | 隐形狙击 |
| **Ranged（射击）** | Boltgun（爆弹枪）、Psycannon（心灵炮） | 远程火力 |
| **Support（支援）** | Null Rod（无效杖）、Mystic Lens | debuff/侦察 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Inferno Pistol | Stealth | 隐形时伤害高 |
| Psycannon | Ranged | 远程穿甲 |
| Boltgun | Ranged | 标准远程 |
| Null Rod | Support | 范围 debuff |
| Mystic Lens | Support | 侦察/视野提升 |
| Power Sword | 基础 | 近战补充 |

---

### Lord General（将军领）

| 维度 | 内容 |
|---|---|
| **定位** | 远程指挥 / 炮火支援 |
| **HP** | ~950 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~30（远程） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Strafing Run | 呼叫空中扫射 |
| 2 | Overlap Fire | 范围内友军射速提升 |
| 3 | Artillery Strike | 呼叫炮击 |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Artillery（炮击）** | Artillery Strike Upgrade、Orbital Strike | 炮火支援强化 |
| **Ranged（射击）** | Power Sword（动力剑）、Bolter（爆弹枪） | 远程+近战平衡 |
| **Command（指挥）** | Regiment Banner（军团旗帜）、Overlap Fire Upgrade | buff 强化 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Power Sword | Ranged | 近战补充 |
| Bolter | Ranged | 远程伤害 |
| Regiment Banner | Command | 周围友军 buff |
| Artillery Strike Upgrade | Artillery | 炮击范围/伤害提升 |
| Orbital Strike | Artillery | 终极炮击技能 |
| Overlap Fire Upgrade | Command | buff 效果/范围提升 |

---

### Commissar Lord（政委领主）

| 维度 | 内容 |
|---|---|
| **定位** | 近战 buff / 步兵指挥 |
| **HP** | ~1200 |
| **护甲** | Commander |
| **基础移速** | 5.5 |
| **基础伤害** | ~40（近战） |

**4 个技能槽位：**

| 槽位 | 技能 | 说明 |
|---|---|---|
| 1 | Execute | 枪决一个己方步兵，周围步兵 buff |
| 2 | Inspiring Presence | 范围内友军免疫压制 + 移速提升 |
| 3 | Regiment Standard | 放置军旗，范围 buff |
| 4 | 随路线变化 | 见下文 |

**三种升级路线：**

| 路线 | 核心战利品 | 风格 |
|---|---|---|
| **Melee（近战）** | Power Fist（动力拳套）、Bolt Pistol（爆弹手枪） | 近战输出 |
| **Command（指挥）** | Regiment Banner Upgrade、Execute Upgrade | buff 强化 |
| **Defense（防御）** | Carapace Armor（甲壳甲）、Refractor Field（折射场） | 生存提升 |

**关键战利品清单：**

| 战利品 | 路线 | 效果 |
|---|---|---|
| Power Fist | Melee | 近战最高伤害，反载具 |
| Power Sword | 基础 | 近战穿甲 |
| Bolt Pistol | Melee | 远程补充 |
| Regiment Banner Upgrade | Command | buff 效果提升 |
| Execute Upgrade | Command | 枪决 buff 效果提升 |
| Carapace Armor | Defense | 自身 HP/护甲提升 |
| Refractor Field | Defense | 伤害减免 |

---

# 第三部分：单位数据表

> 字段说明：cost_req = Requisition 需求 / cost_power = Power 需求 / build_time = 秒 / pop_cost = 人口
> HP 为单模型 HP（小队总 HP = HP x squad_size）
> damage 为单模型 DPS / range 为射程 / speed 为移速
> 标注 ~ 的为近似值

---

## Space Marines 单位

### Scout Squad（侦察兵小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 侦察兵小队 / Scout Squad |
| race / tier | Space Marines / T1 |
| built_from | HQ |
| cost_req / cost_power | ~210 / 0 |
| build_time | ~15s |
| pop_cost | ~6 |
| hp | ~300 |
| armor_type | Infantry |
| tags | 隐形 / 侦察 / 占点 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~20 (Bolter) |
| atk_type | Piercing |
| cooldown | ~0.5s |
| range | ~30 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~70 Req |
| weapon_upgrades | Sniper Rifle（狙击枪）/ Shotgun（霰弹枪）/ Flamer（喷火器）|
| active | Infiltrate（隐形）/ Frag Grenade（破片手雷）|
| passive | Infiltration（升级后）|

### Tactical Marine Squad（战术步兵小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 战术步兵小队 / Tactical Marine Squad |
| race / tier | Space Marines / T1 |
| built_from | HQ |
| cost_req / cost_power | ~500 / 0 |
| build_time | ~22s |
| pop_cost | ~10 |
| hp | ~550 |
| armor_type | Heavy Infantry |
| tags | 核心步兵 / 全能 / ATSKNF |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~35 (Bolter) |
| atk_type | Piercing |
| cooldown | ~0.4s |
| range | ~35 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~80 Req |
| weapon_upgrades | Flamer（喷火）/ Missile Launcher（导弹发射器）/ Plasma Gun（等离子枪）|
| active | ATSKNF（免疫压制）/ Frag Grenade |
| passive | And They Shall Know No Fear |

### Assault Marine Squad（突击步兵小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 突击步兵小队 / Assault Marine Squad |
| race / tier | Space Marines / T1 |
| built_from | HQ |
| cost_req / cost_power | ~500 / 15 |
| build_time | ~22s |
| pop_cost | ~10 |
| hp | ~550 |
| armor_type | Heavy Infantry |
| tags | 跳跃 / 近战 / 突击 |
| speed | ~5 |
| jump / fly | Yes (Jump Pack) / No |
| vision | ~35 |
| damage | ~40 (Melee) / ~15 (Pistol) |
| atk_type | Normal (Melee) / Piercing (Pistol) |
| cooldown | ~1s (Melee) |
| range | Melee / ~20 (Pistol) |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~85 Req |
| weapon_upgrades | Power Sword（动力剑）/ Thunder Hammer & Storm Shield（雷锤+风暴盾）|
| active | Jump（跳跃）/ ATSKNF |
| passive | Melta Bomb（升级后反载具炸弹）|

### Devastator Marine Squad（毁灭者步兵小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 毁灭者步兵小队 / Devastator Marine Squad |
| race / tier | Space Marines / T1 |
| built_from | HQ |
| cost_req / cost_power | ~400 / 20 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~500 |
| armor_type | Heavy Infantry |
| tags | 压制 / 重武器 / 固定射击 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~50 (Heavy Bolter) / ~80 (Plasma Cannon) |
| atk_type | Piercing (HB) / Plasma (PC) |
| cooldown | ~0.5s (HB) / ~3s (PC) |
| range | ~45 (HB) / ~40 (PC) |
| target | 地面 |
| splash | No (HB) / Yes (PC, AoE) |
| bonus_vs | Heavy Infantry (Plasma) |
| squad_size | 3 |
| reinforce_cost | ~75 Req |
| weapon_upgrades | Plasma Cannon（等离子炮）/ Lascannon（激光炮，反载具）|
| active | Suppression（压制模式）/ Setup（架设）|
| passive | Suppressive Fire（重爆弹压制目标）|

### Dreadnought（无畏机甲）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 无畏机甲 / Dreadnought |
| race / tier | Space Marines / T2 |
| built_from | HQ (T2) / Tech Lab |
| cost_req / cost_power | ~350 / 60 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~2500 |
| armor_type | Vehicle |
| tags | Walker / 近战 / 反载具 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~80 (Melee) / ~40 (Assault Cannon) |
| atk_type | Normal (Melee) / Piercing (AC) |
| cooldown | ~1.5s (Melee) / ~0.3s (AC) |
| range | Melee / ~30 (AC) |
| target | 地面 + 空中 (AC) |
| splash | No |
| bonus_vs | Vehicle (Melee) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Assault Cannon → Twin-Linked Lascannon / Heavy Flamer |
| active | Walk Over（碾压步兵）|
| passive | Vehicle Armor |

### Razorback（剃刀背运兵车）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 剃刀背运兵车 / Razorback |
| race / tier | Space Marines / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~250 / 30 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~1800 |
| armor_type | Vehicle |
| tags | 运输 / 远程 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~30 (Twin-Linked Heavy Bolter) |
| atk_type | Piercing |
| cooldown | ~0.3s |
| range | ~35 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Twin-Linked Heavy Bolter → Twin-Linked Lascannon |
| active | Transport（搭载 1 个小队）|
| passive | — |

### Predator（掠食者坦克）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 掠食者坦克 / Predator |
| race / tier | Space Marines / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~400 / 75 |
| build_time | ~35s |
| pop_cost | ~18 |
| hp | ~3000 |
| armor_type | Vehicle |
| tags | 主战坦克 / 远程 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~60 (Autocannon) / ~30 (Sponson HB) |
| atk_type | Piercing |
| cooldown | ~1s |
| range | ~40 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Sponson Heavy Bolters → Sponson Lascannons |
| active | — |
| passive | Vehicle Armor |

### Terminator Squad（终结者小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 终结者小队 / Terminator Squad |
| race / tier | Space Marines / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~400 / 100 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~700 |
| armor_type | Heavy Infantry (Terminator) |
| tags | 重甲 / 传送 / T3 |
| speed | ~4 |
| jump / fly | No (Teleport) / No |
| vision | ~35 |
| damage | ~45 (Storm Bolter) / ~50 (Power Fist) |
| atk_type | Piercing (SB) / Normal (PF) |
| cooldown | ~0.3s (SB) / ~1s (PF) |
| range | ~30 (SB) / Melee (PF) |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~100 Req + 25 Power |
| weapon_upgrades | Assault Cannon（突击炮）/ Cyclone Missile Launcher（旋风导弹）|
| active | Teleport（传送）|
| passive | Terminator Armor（极高护甲）|

### Assault Terminator Squad（突击终结者小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 突击终结者小队 / Assault Terminator Squad |
| race / tier | Space Marines / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~400 / 100 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~700 |
| armor_type | Heavy Infantry (Terminator) |
| tags | 重甲 / 传送 / 近战 / T3 |
| speed | ~4 |
| jump / fly | No (Teleport) / No |
| vision | ~35 |
| damage | ~70 (Lightning Claws) |
| atk_type | Normal |
| cooldown | ~0.8s |
| range | Melee |
| target | 地面 |
| splash | Yes (Lightning Claw splash) |
| bonus_vs | Heavy Infantry |
| squad_size | 3 |
| reinforce_cost | ~100 Req + 25 Power |
| weapon_upgrades | — |
| active | Teleport（传送）|
| passive | Terminator Armor / Lightning Claw splash |

### Land Raider（兰德掠袭者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 兰德掠袭者 / Land Raider |
| race / tier | Space Marines / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~500 / 150 |
| build_time | ~45s |
| pop_cost | ~25 |
| hp | ~4000 |
| armor_type | Vehicle (Heavy) |
| tags | 超重坦克 / 运输 / T3 终极 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~45 |
| damage | ~80 (Twin-Linked Lascannon) x2 / ~40 (Heavy Bolter) |
| atk_type | Anti-Vehicle (LC) / Piercing (HB) |
| cooldown | ~1.5s |
| range | ~45 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle (Lascannon) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Transport（搭载 2 个小队）/ Machine Spirit（伤害减免）|
| passive | Heavy Vehicle Armor |

---

## Chaos 单位

### Cultist Squad（邪教徒小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 邪教徒小队 / Cultist Squad |
| race / tier | Chaos / T1 |
| built_from | HQ |
| cost_req / cost_power | ~150 / 0 |
| build_time | ~10s |
| pop_cost | ~5 |
| hp | ~200 |
| armor_type | Infantry |
| tags | 炮灰 / 腐化光环 / 廉价 |
| speed | ~5.5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~12 (Boltgun) |
| atk_type | Piercing |
| cooldown | ~0.5s |
| range | ~25 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 4 |
| reinforce_cost | ~40 Req |
| weapon_upgrades | — |
| active | Corruption Aura（腐化光环，需升级）|
| passive | — |

### Chaos Space Marines（混沌星际战士）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 混沌星际战士 / Chaos Space Marines |
| race / tier | Chaos / T1 |
| built_from | HQ |
| cost_req / cost_power | ~500 / 0 |
| build_time | ~22s |
| pop_cost | ~10 |
| hp | ~520 |
| armor_type | Heavy Infantry |
| tags | 核心步兵 / 全能 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~33 (Bolter) |
| atk_type | Piercing |
| cooldown | ~0.4s |
| range | ~35 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~80 Req |
| weapon_upgrades | Flamer / Missile Launcher / Plasma Gun |
| active | — |
| passive | Mark of Chaos（随英雄标记变化）|

### Bloodletters（嗜血者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 嗜血者 / Bloodletters |
| race / tier | Chaos / T1 |
| built_from | HQ / Deep Strike |
| cost_req / cost_power | ~300 / 30 |
| build_time | ~15s |
| pop_cost | ~8 |
| hp | ~400 |
| armor_type | Heavy Infantry (Daemon) |
| tags | 恶魔 / 近战 / 深空打击 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~50 (Hellblade) |
| atk_type | Normal |
| cooldown | ~1s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~70 Req + 10 Power |
| weapon_upgrades | — |
| active | Deep Strike（深空打击）|
| passive | Daemonic Aura |

### Chaos Havocs（混沌重武器小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 混沌重武器小队 / Chaos Havocs |
| race / tier | Chaos / T1 |
| built_from | HQ |
| cost_req / cost_power | ~400 / 20 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~480 |
| armor_type | Heavy Infantry |
| tags | 压制 / 重武器 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~50 (Heavy Bolter) / ~70 (Autocannon) |
| atk_type | Piercing (HB) / Anti-Vehicle (AC) |
| cooldown | ~0.5s (HB) / ~1s (AC) |
| range | ~45 (HB) / ~40 (AC) |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle (Autocannon) |
| squad_size | 3 |
| reinforce_cost | ~75 Req |
| weapon_upgrades | Autocannon（自动炮）/ Missile Launcher |
| active | Suppression（压制模式）/ Setup |
| passive | Suppressive Fire |

### Khorne Dreadnought（恐虐无畏机甲）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 恐虐无畏机甲 / Khorne Dreadnought |
| race / tier | Chaos / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~350 / 60 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~2400 |
| armor_type | Vehicle |
| tags | Walker / 近战 / 恶魔 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~85 (Melee) / ~35 (Dreadnought CCW) |
| atk_type | Normal |
| cooldown | ~1.5s |
| range | Melee / ~25 (Ranged) |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Blood Rage（血怒，攻速提升）|
| passive | Daemonic Blessing |

### Bloodcrusher（嗜血碾碎者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 嗜血碾碎者 / Bloodcrusher |
| race / tier | Chaos / T2 |
| built_from | HQ (T2) / Deep Strike |
| cost_req / cost_power | ~300 / 50 |
| build_time | ~25s |
| pop_cost | ~12 |
| hp | ~2000 |
| armor_type | Vehicle (Daemon) |
| tags | 恶魔骑兵 / 近战 / 反载具 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~70 (Melee) |
| atk_type | Normal |
| cooldown | ~1.2s |
| range | Melee |
| target | 地面 |
| splash | Yes (Trample) |
| bonus_vs | Vehicle / Infantry |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Deep Strike / Charge（冲锋）|
| passive | Trample（碾压步兵）|

### Chaos Predator（混沌掠食者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 混沌掠食者 / Chaos Predator |
| race / tier | Chaos / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~400 / 75 |
| build_time | ~35s |
| pop_cost | ~18 |
| hp | ~2900 |
| armor_type | Vehicle |
| tags | 主战坦克 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~60 (Autocannon) |
| atk_type | Piercing |
| cooldown | ~1s |
| range | ~40 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Sponson Lascannons |
| active | — |
| passive | Vehicle Armor |

### Chaos Terminators（混沌终结者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 混沌终结者 / Chaos Terminators |
| race / tier | Chaos / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~400 / 100 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~680 |
| armor_type | Heavy Infantry (Terminator) |
| tags | 重甲 / 传送 / T3 |
| speed | ~4 |
| jump / fly | No (Teleport) / No |
| vision | ~35 |
| damage | ~42 (Combi-Bolter) / ~50 (Power Weapon) |
| atk_type | Piercing / Normal |
| cooldown | ~0.3s / ~1s |
| range | ~30 / Melee |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~100 Req + 25 Power |
| weapon_upgrades | Reaper Autocannon / Power Fist |
| active | Teleport |
| passive | Terminator Armor |

---

## Eldar 单位

### Guardian Squad（守护者小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 守护者小队 / Guardian Squad |
| race / tier | Eldar / T1 |
| built_from | HQ |
| cost_req / cost_power | ~200 / 0 |
| build_time | ~12s |
| pop_cost | ~6 |
| hp | ~180 |
| armor_type | Infantry |
| tags | 廉价远程 / 占点 |
| speed | ~6 (Fleet of Foot) |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~18 (Shuriken Catapult) |
| atk_type | Piercing |
| cooldown | ~0.4s |
| range | ~30 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 5 |
| reinforce_cost | ~40 Req |
| weapon_upgrades | Shuriken Platform（飞镖武器平台）/ Brightlance Platform（亮矛平台）|
| active | Battle Cry（Fleet of Foot 激活）|
| passive | Fleet of Foot |

### Ranger Squad（游侠小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 游侠小队 / Ranger Squad |
| race / tier | Eldar / T1 |
| built_from | HQ |
| cost_req / cost_power | ~300 / 15 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~200 |
| armor_type | Infantry |
| tags | 隐形 / 狙击 / 侦察 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~45 (Sight) |
| damage | ~80 (Ranger Long Rifle) |
| atk_type | Piercing |
| cooldown | ~3s |
| range | ~50 |
| target | 地面 |
| splash | No |
| bonus_vs | Heavy Infantry |
| squad_size | 3 |
| reinforce_cost | ~80 Req + 5 Power |
| weapon_upgrades | — |
| active | Infiltrate（隐形）|
| passive | Long Range Sight |

### Howling Banshees（嚎叫女妖）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 嚎叫女妖 / Howling Banshees |
| race / tier | Eldar / T1 |
| built_from | HQ |
| cost_req / cost_power | ~350 / 20 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~250 |
| armor_type | Infantry |
| tags | 近战 / 压制免疫 / 冲锋 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~35 (Power Sword) |
| atk_type | Normal |
| cooldown | ~0.8s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | Heavy Infantry |
| squad_size | 5 |
| reinforce_cost | ~60 Req + 5 Power |
| weapon_upgrades | Executioner（处刑者剑）|
| active | Banshee Mask（冲锋时压制免疫）|
| passive | Fleet of Foot / Suppress Immune on Charge |

### Warp Spider Squad（曲速蜘蛛小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 曲速蜘蛛小队 / Warp Spider Squad |
| race / tier | Eldar / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~350 / 40 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~280 |
| armor_type | Infantry |
| tags | 传送 / 高爆发 / 突击 |
| speed | ~6 |
| jump / fly | No (Teleport) / No |
| vision | ~35 |
| damage | ~40 (Death Spinner) |
| atk_type | Piercing |
| cooldown | ~0.3s |
| range | ~25 |
| target | 地面 |
| splash | Yes (Death Spinner AoE) |
| bonus_vs | Heavy Infantry |
| squad_size | 5 |
| reinforce_cost | ~65 Req + 10 Power |
| weapon_upgrades | Twin-Linked Death Spinner（双联死亡纺锤）|
| active | Teleport（短距离传送）/ Retreat Teleport |
| passive | Fleet of Foot |

### Fire Dragon Squad（火龙小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 火龙小队 / Fire Dragon Squad |
| race / tier | Eldar / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~300 / 45 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~250 |
| armor_type | Infantry |
| tags | 反载具 / 融化枪 |
| speed | ~5.5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~60 (Fusion Gun) |
| atk_type | Anti-Vehicle |
| cooldown | ~1s |
| range | ~20 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 3 |
| reinforce_cost | ~70 Req + 15 Power |
| weapon_upgrades | — |
| active | — |
| passive | Fleet of Foot / Melta Bonus vs Vehicle |

### Falcon（猎鹰悬浮运输车）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 猎鹰悬浮运输车 / Falcon |
| race / tier | Eldar / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~300 / 40 |
| build_time | ~25s |
| pop_cost | ~12 |
| hp | ~1600 |
| armor_type | Vehicle (Skimmer) |
| tags | 悬浮 / 运输 / 远程 |
| speed | ~7 |
| jump / fly | No / Yes (Skimmer) |
| vision | ~40 |
| damage | ~35 (Pulse Laser) / ~25 (Shuriken) |
| atk_type | Piercing |
| cooldown | ~0.5s |
| range | ~40 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Scatter Laser（散射激光）|
| active | Transport（搭载 1 个小队）|
| passive | Skimmer |

### Wraithlord（幽魂领主）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 幽魂领主 / Wraithlord |
| race / tier | Eldar / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~400 / 60 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~2200 |
| armor_type | Vehicle |
| tags | Walker / 近战 / 远程 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~60 (Melee) / ~40 (Bright Lance) |
| atk_type | Normal (Melee) / Anti-Vehicle (BL) |
| cooldown | ~1.5s (Melee) / ~1s (BL) |
| range | Melee / ~40 (BL) |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle (Bright Lance) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Bright Lance（亮矛）/ Star Cannon（星炮）/ Missile Launcher |
| active | — |
| passive | Wraithsight（需附近有灵能者提供视野，否则偶尔停滞）|

### Fire Prism（火焰棱镜）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 火焰棱镜 / Fire Prism |
| race / tier | Eldar / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~400 / 90 |
| build_time | ~35s |
| pop_cost | ~18 |
| hp | ~2000 |
| armor_type | Vehicle (Skimmer) |
| tags | 悬浮 / AoE / T3 |
| speed | ~7 |
| jump / fly | No / Yes (Skimmer) |
| vision | ~45 |
| damage | ~90 (Prism Cannon) |
| atk_type | Piercing (AoE) |
| cooldown | ~2s |
| range | ~50 |
| target | 地面 |
| splash | Yes (Large AoE) |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | — |
| passive | Skimmer / Prism Cannon (Reflect mode) |

### Avatar of Khaine（凯恩化身）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 凯恩化身 / Avatar of Khaine |
| race / tier | Eldar / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~500 / 150 |
| build_time | ~45s |
| pop_cost | ~25 |
| hp | ~3500 |
| armor_type | Vehicle (Super) |
| tags | 超级单位 / 近战 / 光环 / T3 终极 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~45 |
| damage | ~120 (Wailing Doom) |
| atk_type | Normal |
| cooldown | ~1.5s |
| range | Melee / ~20 (Ranged) |
| target | 地面 |
| splash | Yes |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | — |
| passive | Avatar Aura（全族生产速度 +50%、伤害 buff）|

### Brightlance Platform（亮矛武器平台）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 亮矛武器平台 / Brightlance Platform |
| race / tier | Eldar / T1 |
| built_from | HQ (Guardian upgrade) |
| cost_req / cost_power | ~150 / 30 |
| build_time | ~15s |
| pop_cost | ~5 |
| hp | ~300 |
| armor_type | Vehicle (Emplacement) |
| tags | 固定 / 反载具 |
| speed | 0 (Fixed) |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~70 (Bright Lance) |
| atk_type | Anti-Vehicle |
| cooldown | ~1.5s |
| range | ~45 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Setup |
| passive | Fixed Emplacement |

---

## Orks 单位

### Slugga Boyz（劈砍小子）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 劈砍小子 / Slugga Boyz |
| race / tier | Orks / T1 |
| built_from | HQ |
| cost_req / cost_power | ~270 / 0 |
| build_time | ~12s |
| pop_cost | ~8 |
| hp | ~250 |
| armor_type | Infantry |
| tags | 廉价 / 近战 / 人海 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~25 (Slugga Melee) / ~10 (Pistol) |
| atk_type | Normal |
| cooldown | ~0.8s |
| range | Melee / ~15 (Pistol) |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 6 |
| reinforce_cost | ~35 Req |
| weapon_upgrades | Burna（喷火）/ Big Choppa（大砍刀）|
| active | Waaagh!（被动激活时 buff）|
| passive | Mob Bonus（周围友军越多伤害越高）|

### Shoota Boyz（射击小子）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 射击小子 / Shoota Boyz |
| race / tier | Orks / T1 |
| built_from | HQ |
| cost_req / cost_power | ~270 / 0 |
| build_time | ~12s |
| pop_cost | ~8 |
| hp | ~250 |
| armor_type | Infantry |
| tags | 廉价 / 远程 / 人海 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~20 (Shoota) |
| atk_type | Piercing |
| cooldown | ~0.4s |
| range | ~30 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 6 |
| reinforce_cost | ~35 Req |
| weapon_upgrades | Big Shoota（大枪）/ Rokkit Launcha（火箭发射器）|
| active | Waaagh! |
| passive | Mob Bonus |

### Stormboyz（暴风小子）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 暴风小子 / Stormboyz |
| race / tier | Orks / T1 |
| built_from | HQ |
| cost_req / cost_power | ~350 / 20 |
| build_time | ~18s |
| pop_cost | ~10 |
| hp | ~250 |
| armor_type | Infantry |
| tags | 跳跃 / 近战 |
| speed | ~5 |
| jump / fly | Yes (Jump Pack) / No |
| vision | ~30 |
| damage | ~25 (Melee) |
| atk_type | Normal |
| cooldown | ~0.8s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 6 |
| reinforce_cost | ~45 Req + 5 Power |
| weapon_upgrades | — |
| active | Jump |
| passive | Mob Bonus |

### Tankbustas（反坦克小子）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 反坦克小子 / Tankbustas |
| race / tier | Orks / T1 |
| built_from | HQ |
| cost_req / cost_power | ~300 / 25 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~260 |
| armor_type | Infantry |
| tags | 反载具 / 导弹 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~50 (Rokkit Launcha) |
| atk_type | Anti-Vehicle |
| cooldown | ~1.5s |
| range | ~35 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 3 |
| reinforce_cost | ~70 Req + 10 Power |
| weapon_upgrades | — |
| active | Tankbusta Bomb（反载具炸弹）|
| passive | Mob Bonus |

### Lootas（掠夺者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 掠夺者 / Lootas |
| race / tier | Orks / T1 |
| built_from | HQ |
| cost_req / cost_power | ~350 / 20 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~260 |
| armor_type | Infantry |
| tags | 压制 / 重武器 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~45 (Deffgun) |
| atk_type | Piercing |
| cooldown | ~0.5s |
| range | ~45 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~75 Req + 5 Power |
| weapon_upgrades | Beam Deffgun / Cannon Deffgun |
| active | Suppression |
| passive | Suppressive Fire |

### Deff Dread（死亡无畏）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 死亡无畏 / Deff Dread |
| race / tier | Orks / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~350 / 60 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~2300 |
| armor_type | Vehicle |
| tags | Walker / 近战 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~70 (Melee) / ~30 (Big Shoota) |
| atk_type | Normal / Piercing |
| cooldown | ~1.5s / ~0.5s |
| range | Melee / ~25 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Twin-Linked Big Shoota / Rokkit Launcha / Skorcha |
| active | — |
| passive | Vehicle Armor |

### Looted Tank（掠夺坦克）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 掠夺坦克 / Looted Tank |
| race / tier | Orks / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~400 / 75 |
| build_time | ~35s |
| pop_cost | ~18 |
| hp | ~2800 |
| armor_type | Vehicle |
| tags | 主战坦克 / 炮击 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~70 (Battle Cannon) |
| atk_type | Artillery |
| cooldown | ~2s |
| range | ~45 |
| target | 地面 |
| splash | Yes |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Bombard（炮击模式）|
| passive | Vehicle Armor |

### Nob Squad（贵族小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 贵族小队 / Nob Squad |
| race / tier | Orks / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~400 / 100 |
| build_time | ~30s |
| pop_cost | ~15 |
| hp | ~600 |
| armor_type | Heavy Infantry |
| tags | 精英 / 近战 / T3 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~60 (Power Klaw) |
| atk_type | Normal |
| cooldown | ~1s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 5 |
| reinforce_cost | ~90 Req + 20 Power |
| weapon_upgrades | Power Klaw / Big Choppa |
| active | Waaagh! |
| passive | Mob Bonus / Heavy Armor |

### Battlewagon（战斗货车）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 战斗货车 / Battlewagon |
| race / tier | Orks / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~450 / 120 |
| build_time | ~40s |
| pop_cost | ~20 |
| hp | ~3500 |
| armor_type | Vehicle (Heavy) |
| tags | 重型运输 / 碾压 / T3 |
| speed | ~5.5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~50 (Kannon) / ~30 (Big Shoota) |
| atk_type | Artillery / Piercing |
| cooldown | ~2s / ~0.5s |
| range | ~40 / ~30 |
| target | 地面 |
| splash | Yes (Kannon) |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Zzzap Gun / Lobba |
| active | Transport（搭载 2 个小队）/ Trample（碾压步兵）|
| passive | Heavy Vehicle Armor |

---

## Tyranids 单位

### Termagants（射击虫）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 射击虫 / Termagants |
| race / tier | Tyranids / T1 |
| built_from | HQ |
| cost_req / cost_power | ~200 / 0 |
| build_time | ~10s |
| pop_cost | ~6 |
| hp | ~150 |
| armor_type | Infantry |
| tags | 廉价 / 远程 / 虫海 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~12 (Fleshborer) |
| atk_type | Piercing |
| cooldown | ~0.5s |
| range | ~25 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 6 |
| reinforce_cost | ~30 Req |
| weapon_upgrades | Spike Rifle（尖刺步枪）/ Devourer（吞噬者）|
| active | — |
| passive | Synapse Buff（突触范围内 buff）|

### Hormagaunts（近战虫）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 近战虫 / Hormagaunts |
| race / tier | Tyranids / T1 |
| built_from | HQ |
| cost_req / cost_power | ~200 / 0 |
| build_time | ~10s |
| pop_cost | ~6 |
| hp | ~150 |
| armor_type | Infantry |
| tags | 廉价 / 近战 / 跳跃冲锋 / 虫海 |
| speed | ~6 |
| jump / fly | Yes (Leap) / No |
| vision | ~30 |
| damage | ~18 (Scything Talons) |
| atk_type | Normal |
| cooldown | ~0.6s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 6 |
| reinforce_cost | ~30 Req |
| weapon_upgrades | Adrenal Glands（肾上腺）/ Toxin Sacs（毒素囊）|
| active | Leap（跳跃冲锋）|
| passive | Synapse Buff |

### Ripper Swarms（撕裂虫群）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 撕裂虫群 / Ripper Swarms |
| race / tier | Tyranids / T1 |
| built_from | HQ |
| cost_req / cost_power | ~210 / 0 |
| build_time | ~10s |
| pop_cost | ~5 |
| hp | ~400 |
| armor_type | Infantry |
| tags | 诱饵 / 干扰 / 无法增援 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~25 |
| damage | ~10 (Melee) |
| atk_type | Normal |
| cooldown | ~0.5s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | — (无法增援) |
| weapon_upgrades | — |
| active | — |
| passive | Synapse Buff / Distraction |

### Tyranid Warriors（泰伦战士）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 泰伦战士 / Tyranid Warriors |
| race / tier | Tyranids / T1 |
| built_from | HQ |
| cost_req / cost_power | ~300 / 30 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~450 |
| armor_type | Heavy Infantry |
| tags | 突触核心 / 中型步兵 / 可升级武器 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~30 (Deathspitter) / ~35 (Scything Talons) |
| atk_type | Piercing / Normal |
| cooldown | ~0.5s / ~0.8s |
| range | ~30 / Melee |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~70 Req + 10 Power |
| weapon_upgrades | Barbed Strangler（倒刺绞杀者）/ Venom Cannon（毒液炮）/ Deathspitter（死亡喷吐器）|
| active | Synapse（提供突触链接）|
| passive | Synapse Aura（范围内虫群 buff）|

### Genestealers（基因窃取者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 基因窃取者 / Genestealers |
| race / tier | Tyranids / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~350 / 40 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~280 |
| armor_type | Infantry |
| tags | 隐形 / 近战 / 高爆发 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~45 (Rending Claws) |
| atk_type | Normal |
| cooldown | ~0.7s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | Heavy Infantry |
| squad_size | 5 |
| reinforce_cost | ~65 Req + 10 Power |
| weapon_upgrades | Toxin Sacs / Flesh Hooks |
| active | Infiltrate（隐形）|
| passive | Synapse Buff / Rending (穿甲) |

### Lictor（潜伏者）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 潜伏者 / Lictor |
| race / tier | Tyranids / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~300 / 50 |
| build_time | ~25s |
| pop_cost | ~12 |
| hp | ~800 |
| armor_type | Heavy Infantry |
| tags | 隐形 / 刺客 / 单体 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~60 (Rending Claws) |
| atk_type | Normal |
| cooldown | ~1s |
| range | Melee |
| target | 地面 |
| splash | No |
| bonus_vs | Commander (对英雄加成) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Infiltrate / Flesh Hooks（钩爪）|
| passive | Feeder Tendrils（击杀回血）|

### Carnifex（活体坦克）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 活体坦克 / Carnifex |
| race / tier | Tyranids / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~500 / 80 |
| build_time | ~35s |
| pop_cost | ~18 |
| hp | ~3000 |
| armor_type | Vehicle |
| tags | Walker / 重型 / 多武器配置 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~80 (Melee) / ~60 (Venom Cannon) / ~50 (Barbed Strangler) |
| atk_type | Normal / Anti-Vehicle / Piercing |
| cooldown | ~1.5s / ~1.5s / ~2s |
| range | Melee / ~40 / ~35 |
| target | 地面 |
| splash | Yes (Barbed Strangler) |
| bonus_vs | Vehicle (Venom Cannon) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Venom Cannon / Barbed Strangler / Spine Fists / Crushing Claws |
| active | — |
| passive | Synapse Buff / Living Battering Ram |

### Zoanthrope（精神虫）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 精神虫 / Zoanthrope |
| race / tier | Tyranids / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~300 / 50 |
| build_time | ~25s |
| pop_cost | ~10 |
| hp | ~600 |
| armor_type | Vehicle (Bio) |
| tags | 法术 / 反载具 / 精神炮 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~90 (Warp Lance) |
| atk_type | Anti-Vehicle |
| cooldown | ~3s |
| range | ~45 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Warp Lance（精神炮）/ Synapse |
| passive | Synapse Aura / Warp Field（护盾）|

### Biovores（生体炮虫）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 生体炮虫 / Biovores |
| race / tier | Tyranids / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~300 / 50 |
| build_time | ~25s |
| pop_cost | ~10 |
| hp | ~400 |
| armor_type | Heavy Infantry |
| tags | 炮击 / AoE / 远程 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~70 (Spore Mine) |
| atk_type | Artillery |
| cooldown | ~4s |
| range | ~50 |
| target | 地面 |
| splash | Yes (Large AoE) |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | Spore Mine Launch（发射孢子雷）|
| passive | Synapse Buff |

---

## Imperial Guard 单位（Retribution）

### Guardsmen Squad（卫兵小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 卫兵小队 / Guardsmen Squad |
| race / tier | Imperial Guard / T1 |
| built_from | HQ |
| cost_req / cost_power | ~200 / 0 |
| build_time | ~10s |
| pop_cost | ~6 |
| hp | ~160 |
| armor_type | Infantry |
| tags | 廉价 / 远程 / 人海 / 最脆 |
| speed | ~5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~12 (Lasgun) |
| atk_type | Piercing |
| cooldown | ~0.4s |
| range | ~30 |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 6 |
| reinforce_cost | ~25 Req |
| weapon_upgrades | Flamer / Grenade Launcher / Plasma Gun |
| active | — |
| passive | — |

### Catachan Devils（卡塔昌恶魔）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 卡塔昌恶魔 / Catachan Devils |
| race / tier | Imperial Guard / T1 |
| built_from | HQ |
| cost_req / cost_power | ~300 / 20 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~300 |
| armor_type | Infantry |
| tags | 精锐 / 近战 / 喷火 |
| speed | ~5.5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~30 (Melee) / ~25 (Flamer) |
| atk_type | Normal / Flame |
| cooldown | ~0.8s / ~0.5s |
| range | Melee / ~20 (Flamer) |
| target | 地面 |
| splash | Yes (Flamer) |
| bonus_vs | Garrisoned (Flamer) |
| squad_size | 4 |
| reinforce_cost | ~60 Req + 5 Power |
| weapon_upgrades | — |
| active | Frag Grenade / Demolition Charge |
| passive | Jungle Fighters (移动中射击) |

### Heavy Weapon Team（重武器小组）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 重武器小组 / Heavy Weapon Team |
| race / tier | Imperial Guard / T1 |
| built_from | HQ |
| cost_req / cost_power | ~300 / 25 |
| build_time | ~18s |
| pop_cost | ~8 |
| hp | ~280 |
| armor_type | Infantry |
| tags | 压制 / 重武器 / 固定 |
| speed | ~3 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~45 (Heavy Bolter) / ~70 (Autocannon) / ~80 (Lascannon) |
| atk_type | Piercing / Anti-Vehicle |
| cooldown | ~0.5s / ~1s / ~2s |
| range | ~45 / ~40 / ~45 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle (Lascannon) |
| squad_size | 3 |
| reinforce_cost | ~65 Req + 10 Power |
| weapon_upgrades | Autocannon / Lascannon / Missile Launcher |
| active | Suppression / Setup |
| passive | Suppressive Fire |

### Sentinel（哨兵机甲）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 哨兵机甲 / Sentinel |
| race / tier | Imperial Guard / T1 |
| built_from | HQ |
| cost_req / cost_power | ~250 / 20 |
| build_time | ~15s |
| pop_cost | ~8 |
| hp | ~800 |
| armor_type | Vehicle |
| tags | 轻型 Walker / 侦察 / 快速 |
| speed | ~6 |
| jump / fly | No / No |
| vision | ~45 |
| damage | ~35 (Multi-Laser) / ~50 (Lascannon) |
| atk_type | Piercing / Anti-Vehicle |
| cooldown | ~0.5s / ~2s |
| range | ~35 / ~40 |
| target | 地面 |
| splash | No |
| bonus_vs | Vehicle (Lascannon) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Lascannon / Heavy Flamer / Missile Launcher |
| active | Scout (高视野) |
| passive | Walker / Flanking |

### Ogryn Squad（巨兽小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 巨兽小队 / Ogryn Squad |
| race / tier | Imperial Guard / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~350 / 50 |
| build_time | ~22s |
| pop_cost | ~10 |
| hp | ~600 |
| armor_type | Heavy Infantry |
| tags | 重型近战 / 肉盾 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~30 |
| damage | ~55 (Ripper Gun Melee) |
| atk_type | Normal |
| cooldown | ~1s |
| range | Melee / ~15 (Ripper Gun) |
| target | 地面 |
| splash | No |
| bonus_vs | — |
| squad_size | 3 |
| reinforce_cost | ~85 Req + 15 Power |
| weapon_upgrades | — |
| active | — |
| passive | Bone'ead (队长 buff) |

### Kasrkin Squad（卡斯金小队）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 卡斯金小队 / Kasrkin Squad |
| race / tier | Imperial Guard / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~350 / 40 |
| build_time | ~20s |
| pop_cost | ~10 |
| hp | ~350 |
| armor_type | Heavy Infantry |
| tags | 精锐 / 远程 / 热弹枪 |
| speed | ~5.5 |
| jump / fly | No / No |
| vision | ~35 |
| damage | ~35 (Hot-Shot Lasgun) |
| atk_type | Plasma |
| cooldown | ~0.4s |
| range | ~35 |
| target | 地面 |
| splash | No |
| bonus_vs | Heavy Infantry |
| squad_size | 5 |
| reinforce_cost | ~65 Req + 10 Power |
| weapon_upgrades | Melta Gun / Plasma Gun |
| active | Krak Grenade |
| passive | Carapace Armor |

### Leman Russ Battle Tank（莱曼罗斯主战坦克）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 莱曼罗斯主战坦克 / Leman Russ Battle Tank |
| race / tier | Imperial Guard / T2 |
| built_from | HQ (T2) |
| cost_req / cost_power | ~450 / 80 |
| build_time | ~35s |
| pop_cost | ~18 |
| hp | ~3200 |
| armor_type | Vehicle (Heavy) |
| tags | 主战坦克 / 最强载具之一 / 炮击 |
| speed | ~4.5 |
| jump / fly | No / No |
| vision | ~40 |
| damage | ~80 (Battle Cannon) / ~30 (Heavy Bolter) x2 |
| atk_type | Artillery / Piercing |
| cooldown | ~2s / ~0.5s |
| range | ~45 / ~30 |
| target | 地面 |
| splash | Yes (Battle Cannon) |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | Sponson Heavy Bolters → Sponson Plasma Cannons / Lascannon Hull |
| active | — |
| passive | Heavy Vehicle Armor / Lumbering Behemoth (移速低但碾压) |

### Baneblade（刃暴之剑超重坦克）

| 字段 | 值 |
|---|---|
| name_zh / name_en | 刃暴之剑超重坦克 / Baneblade |
| race / tier | Imperial Guard / T3 |
| built_from | HQ (T3) |
| cost_req / cost_power | ~600 / 150 |
| build_time | ~50s |
| pop_cost | ~30 |
| hp | ~5000 |
| armor_type | Vehicle (Super Heavy) |
| tags | 超重坦克 / 11 管武器 / T3 终极 / 碾压 |
| speed | ~4 |
| jump / fly | No / No |
| vision | ~45 |
| damage | ~100 (Battle Cannon) / ~80 (Twin-Linked Lascannon) / ~30 (Heavy Bolter) x3 / ~60 (Demolisher Cannon) |
| atk_type | Artillery / Anti-Vehicle / Piercing |
| cooldown | ~2s / ~1.5s / ~0.5s / ~3s |
| range | ~50 / ~45 / ~30 / ~35 |
| target | 地面 |
| splash | Yes (Battle Cannon, Demolisher) |
| bonus_vs | Vehicle (Lascannon) / Infantry (Demolisher) |
| squad_size | 1 |
| reinforce_cost | — |
| weapon_upgrades | — |
| active | — |
| passive | Super Heavy Armor / 11-Weapon Platform |

---

## 附录：种族对比总表

| 维度 | SM | Chaos | Eldar | Orks | Tyranids | IG |
|---|---|---|---|---|---|---|
| **设计核心** | 精英质量 | 变异+恶魔 | 速度+专精 | 人海+Waaagh | 虫海+突触 | 人海+载具 |
| **单位成本** | 高 | 高 | 中 | 低 | 低 | 极低(步兵)/高(载具) |
| **单位血量** | 高 | 高 | 低 | 低 | 极低(虫) | 极低(兵)/高(载具) |
| **机动性** | 中(Drop Pod) | 中(深空) | 最高(Fleet) | 低(Waaagh提速) | 中(隧道) | 低 |
| **载具质量** | 高 | 高 | 中 | 中 | 中(生物) | 最高 |
| **T1 强度** | 中高 | 中高 | 高 | 高 | 高 | 中 |
| **T3 强度** | 高 | 高 | 高 | 中 | 中 | 最高 |
| **反载具(T1)** | 弱(需升级) | 弱(需升级) | 弱(Brightlance) | 中(Tankbusta) | 弱(需Warrior) | 中(HWT升级) |
| **压制能力** | 强(Devastator) | 强(Havoc) | 弱 | 强(Loota) | 弱 | 强(HWT) |
| **多线能力** | 弱 | 弱 | 强 | 弱 | 中(隧道) | 弱 |
| **防守能力** | 强(Techmarine) | 中 | 中 | 弱 | 中 | 强(战壕) |

---

## 附录：英雄对比总表

| 英雄 | 种族 | 定位 | HP | 核心能力 |
|---|---|---|---|---|
| Force Commander | SM | 近战坦克 | ~1200 | Battle Cry + Drop Pod |
| Techmarine | SM | 支援/建筑 | ~1000 | 炮塔 + 维修 + Drop Pod |
| Apothecary | SM | 治疗 | ~900 | Heal + Purification |
| Chaos Lord | Chaos | 近战/标记 | ~1300 | Doom Pulse + Mark of Chaos |
| Plague Champion | Chaos | 腐化/支援 | ~1100 | Blight Grenade + Corruption |
| Sorcerer | Chaos | 法术 | ~900 | Doombolt + Chains + Warp Rift |
| Farseer | Eldar | 法术/buff | ~800 | Guide + Doom + Fleet |
| Warlock | Eldar | 近战法术 | ~900 | Destructor + Enhance |
| Warp Spider Exarch | Eldar | 传送突击 | ~850 | Teleport + Group Teleport |
| Warboss | Orks | 近战/Waaagh | ~1400 | Waaagh! + Use Yer Choppas |
| Kommando Nob | Orks | 隐形/伏击 | ~1000 | Infiltrate + Stun Bomb |
| Mekboy | Orks | 支援/建筑 | ~950 | Deff Dread + Force Field |
| Hive Tyrant | Tyranids | 近战/突触 | ~1500 | Synapse + Psychic Scream |
| Ravener Alpha | Tyranids | 隧道/机动 | ~1100 | Burrow + Tunnel |
| Lictor Alpha | Tyranids | 隐形/刺客 | ~1000 | Infiltrate + Pheromone Trail |
| Inquisitor | IG | 远程/隐形 | ~850 | Infiltrate + Psyker Power |
| Lord General | IG | 远程/炮火 | ~950 | Strafing Run + Artillery Strike |
| Commissar Lord | IG | 近战/buff | ~1200 | Execute + Inspiring Presence |

---

> **数据声明**
> - 本文档基于 DoW2 + Chaos Rising + Retribution 最终版本编写
> - 标注 ~ 的数值为近似值（DoW2 经历多次平衡补丁，精确数值因版本而异）
> - 英雄战利品/技能名称以英文社区 wiki 为准
> - 部分单位在 Chaos Rising / Retribution 中有调整，本表以最终版本为准
> - 数据来源：Liquipedia DoW / Fandom Wiki / 训练知识综合
