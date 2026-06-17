# Company of Heroes 系列（CoH1 / CoH2 / CoH3）单位数据调研

> **版本信息**
> - 调研日期：2026-06-17
> - 数据来源：Liquipedia CoH (https://liquipedia.net/companyofheroes/)、Fandom wiki (https://companyofheroes.fandom.com/)
> - 覆盖游戏：Company of Heroes 1（含 Opposing Fronts）、Company of Heroes 2（含所有 DLC 阵营）、Company of Heroes 3
> - 注意：部分精确数值（HP/装甲/伤害等）基于社区 wiki 与游戏内数据，不同版本可能有差异。标注 `—` 表示数据缺失或版本变动较大。资源消耗以标准 1v1 模式为基准。

---

## 第一部分：游戏机制概述

### 1.1 掩体系统（Cover System）

CoH 系列最核心的步兵战术机制。地图上的各种物体为步兵提供不同等级的掩体保护：

| 掩体类型 | 图标颜色 | 减伤效果 | 来源 | 备注 |
|---|---|---|---|---|
| 重掩体（Heavy Cover） | 绿盾 | 减伤约 50%-75% | 沙袋、石墙、树篱、建筑物 | 最理想的防御位置 |
| 轻掩体（Light Cover） | 黄盾 | 减伤约 25% | 弹坑、栅栏、灌木 | 提供有限保护 |
| 负掩体（Negative Cover） | 红盾 | 受伤增加约 25%-50% | 道路中央、开阔地 | 应避免在此交战 |
| 无掩体（Open） | 无图标 | 无修正 | 开阔地带 | 基础状态 |
| 驻防（Garrison） | 建筑图标 | 大幅减伤 | 建筑物内部 | 可被火焰武器/手雷清除 |

**关键规则：**
- 掩体方向性：掩体只对来自特定方向的火力有效，侧翼包抄可以绕过掩体
- 建筑驻防：步兵进入建筑后获得极强保护，但火焰武器（喷火器、燃烧弹）对驻防单位有额外伤害
- CoH3 新增：灌木丛（Bush）提供隐蔽而非减伤，单位在灌木中可被发现但不易被远程命中

### 1.2 压制与小队撤退（Suppression & Retreat）

**压制系统：**
- 重机枪（HMG）对步兵造成压制值积累
- **被压制（Suppressed）**：移动速度大幅降低，无法冲锋，黄圈图标
- **被钉住（Pinned）**：完全无法移动，只能爬行，红圈图标
- 压制会逐步恢复，离开火力范围后恢复更快

**撤退系统：**
- 按下撤退按钮（热键 T 或 Retreat），小队以加速返回基地/HQ
- 撤退中的单位免疫压制，移动速度提升约 50%
- 撤退是 CoH 的核心生存机制——损失一个小队比撤退一个残血小队代价大得多
- 但撤退路线固定（直线回基地），可能被伏击

### 1.3 资源点系统（Resource Points）

三种核心资源 + 胜利点：

| 资源 | 用途 | 基础收入 | 来源 |
|---|---|---|---|
| 人力（Manpower） | 几乎所有单位的基础资源 | +约 290/分钟（所有玩家相同） | 基础收入 + 领土点 |
| 弹药（Munitions） | 武器升级、技能、地雷 | 基础较低，领土点加成 | 弹药点 |
| 燃料（Fuel） | 车辆、科技升级 | 基础较低，领土点加成 | 燃料点 |

**领土点类型：**
- 战略点（Strategic Point）：连接补给线，提供少量人力
- 弹药点（Munitions Point）：提供弹药
- 燃料点（Fuel Point）：提供燃料
- 胜利点（Victory Point）：控制后累积胜利点数

**切断补给线：** 如果领土点与基地的连接被敌方占领的领土切断，该点不产出资源。这是 CoH 的核心战略机制。

### 1.4 指挥树 / 战斗群系统（Command Tree / Battlegroup）

| 游戏 | 系统名称 | 机制 |
|---|---|---|
| CoH1 | 指挥树（Doctrine） | 选择一个树（如步兵/装甲/空降），逐步解锁技能点 |
| CoH2 | 指挥官（Commander） | 从可用指挥官中选择，提供技能树 |
| CoH3 | 战斗群（Battlegroup） | 对战中实时选择战斗群分支 |

**设计意义：** 每个指挥树/战斗群提供独特的能力和呼叫单位，让同一阵营有不同玩法风格。例如 CoH1 美军可以选择步兵指挥树（强化步兵）、装甲指挥树（重型坦克）或空降指挥树（空中部署）。

### 1.5 装甲朝向系统（Armor Facing）

车辆有前/侧/后三个装甲面，不同方向装甲值不同：

| 装甲面 | 典型装甲值比例 | 战术意义 |
|---|---|---|
| 前装甲（Front） | 100%（最强） | 正面交火，坦克对决的标准姿态 |
| 侧装甲（Side） | 约 50%-70% | 侧翼包抄的目标 |
| 后装甲（Rear） | 约 25%-40% | 最脆弱，步兵反坦克武器的最佳攻击面 |

**穿甲 vs 装甲：**
- 武器有穿甲值（Penetration），车辆有装甲值（Armor）
- 穿甲值 >= 装甲值：穿透，造成全额伤害
- 穿甲值 < 装甲值：可能跳弹（Bounce），造成减少或零伤害
- 穿甲判定通常是概率性的，基于两者差值

**核心战术推论：** 侧翼包抄（Flanking）是 CoH 反坦克的核心战术。正面硬扛重型坦克代价极高，绕到侧面或后方射击效果倍增。

### 1.6 武器拾取系统（Weapon Pickup）

- 步兵小队阵亡后，其专属武器（如反坦克火箭筒、重机枪）会掉落在地上
- 其他步兵小队可以拾取这些武器并装备
- 拾取的武器占用小队的武器槽位（通常每个小队有 2 个槽位）
- 弹药购买的升级武器（如 BAR、Panzerschreck）也可在丢弃后被拾取
- 拾取武器不消耗资源，但需要小队到达掉落位置

**战术意义：** 击杀敌方反坦克小队后拾取其武器，可以临时增强自己的反坦克能力。反之，敌方也可能拾取你掉落的武器。

### 1.7 老练度系统（Veterancy）

| 游戏 | 机制 |
|---|---|
| CoH1 美军 | 通过战斗积累经验，自动升级 1-3 级 veterancy |
| CoH1 国防军 | 通过基地升级购买全局 veterancy（Kampfkraft Centre） |
| CoH2/CoH3 | 所有阵营通过战斗积累经验，自动升级 |

**老练度奖励示例：**
- 等级 1：通常提升精度或减少受击伤害
- 等级 2：通常提升移动速度、装填速度或额外技能
- 等级 3：通常大幅提升战斗力和生存能力

老练度是 CoH 系列的核心设计——保护老兵单位比无脑补充新兵更有价值，撤退保存老练度是关键操作。

### 1.8 建筑与驻防

- 步兵可驻防（Garrison）进入建筑物
- 驻防提供重掩体级别的保护
- 每个建筑有有限的射击孔，模型数量影响火力输出
- 火焰武器、手雷、突击炮等对驻防单位有额外效果
- 喷火工兵/喷火坦克是清除驻防建筑的主要手段
- CoH3 新增：建筑物可被摧毁，变为废墟后仍可提供有限掩体

---

## 第二部分：阵营设计分析

### 11 维度分析框架

每个阵营按以下维度分析：
1. **设计哲学** — 阵营的核心设计理念
2. **签名机制** — 阵营独特的标志性玩法
3. **角色分工** — 单位在阵营内的定位
4. **科技树** — 升级路径特点
5. **核心协同** — 关键的兵种配合
6. **生产机制** — 单位生产方式
7. **机动哲学** — 阵营的机动性特点
8. **视野控制** — 侦察和信息获取能力
9. **反制弱点** — 阵营的弱点
10. **强势时间窗** — 阵营在不同阶段的强度
11. **经济模型** — 资源使用特点

---

### CoH1 阵营

#### 2.1 美军（Americans / US Forces）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 通用性强、灵活机动、合成兵种。美军单位单兵不如国防精锐，但通过武器升级和数量优势取胜 |
| 签名机制 | 武器升级系统——Riflemen 可购买 BAR（自动步枪）和 Sticky Bomb（粘性炸弹）；步兵可拾取武器大幅改变角色 |
| 角色分工 | Riflemen = 核心/多用途；Rangers = 反装甲突击；Airborne = 深入敌后；Sherman = 通用坦克 |
| 科技树 | 供应链升级（Supply Yard）解锁车辆和后勤；武器支援中心/兵营/车辆调配场/坦克调配场四级建筑 |
| 核心协同 | Riflemen + MG 火力压制 → 包抄 → 粘性炸弹缠住坦克 → Sherman/M10 收割 |
| 生产机制 | 从对应建筑生产；空降指挥树可绕过建筑直接空投单位 |
| 机动哲学 | 高机动性——Jeep 侦察、Greyhound 快速突袭、Airborne 空降深入敌后 |
| 视野控制 | Sniper 侦察、Jeep 快速巡视、Airborne 深入侦察 |
| 反制弱点 | 早期缺乏重装甲，对 Tiger/King Tiger 正面交火劣势；装甲薄 |
| 强势时间窗 | 中期（Sherman 到场前后的机动压制）；空降指挥树的全图部署能力 |
| 经济模型 | 人力收入正常，依赖弹药购买武器升级，燃料节奏决定车辆出兵时机 |

#### 2.2 国防军（Wehrmacht）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 精英路线——单位昂贵但强大，以质取胜。强调阵地防御和精准打击 |
| 签名机制 | 全局 Veterancy 升级（Kampfkraft Centre）——花钱为所有同类单位买经验，不同于美军的战斗升级 |
| 角色分工 | Volksgrenadiers = 肉盾/占点；Grenadiers = 精锐步兵；MG42 = 火力核心；Tiger = 终极装甲 |
| 科技树 | 战斗阶段（Battle Phase）升级解锁高级建筑；四阶段科技 |
| 核心协同 | MG42 压制 → 炮击/狙击手点杀 → StuG/Panzer IV 反装甲 → Tiger 终结 |
| 生产机制 | 建筑生产；Tiger/King Tiger 通过指挥树呼叫 |
| 机动哲学 | 低机动性但高火力——重装甲正面推进，不依赖包抄 |
| 视野控制 | Sniper 精锐侦察、摩托车（Kettenkrad）快速巡视 |
| 反制弱点 | 经济效率低——单位昂贵导致数量劣势；被侧翼包抄后装甲优势丧失 |
| 强势时间窗 | 后期（Tiger 到场后的正面碾压）；防御指挥树的阵地战 |
| 经济模型 | 单位成本高，但 Veterancy 投资回报高；依赖燃料快速出重装甲 |

#### 2.3 英军（British Forces）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 阵地战专家——以工事和火力点为核心，缓慢但不可阻挡地推进 |
| 签名机制 | 军官系统——Lieutenant/Captain/Command Tank 为附近单位提供 buff；工事建筑（25磅炮、17磅炮、Bofors） |
| 角色分工 | Infantry Section = 核心步兵（可升级 Bren/PIAT）；Sappers = 工兵/维修；军官 = buff 核心 |
| 科技树 | 通过军官升级解锁——Lieutenant 解锁早期，Captain 解锁中期，Command Tank 解锁晚期 |
| 核心协同 | 军官 buff + Infantry Section 火力 → 工事封锁区域 → Firefly 反装甲 → Churchill 突破 |
| 生产机制 | 从移动的 HQ 卡车生产；卡车可重新部署到前线 |
| 机动哲学 | 低机动性——依赖工事推进，卡车移动缓慢 |
| 视野控制 | 工事提供视野、军官提供侦察 |
| 反制弱点 | 早期机动性差；被火焰武器清除工事后极其脆弱；依赖军官 buff，军官阵亡后战力大降 |
| 强势时间窗 | 中后期（工事网建立后的阵地战）；皇家炮兵指挥树的远程火力 |
| 经济模型 | 人力收入正常，依赖弹药升级武器，燃料用于军官解锁和装甲 |

#### 2.4 装甲精英（Panzer Elite）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 进攻导向的装甲突击——以半履带车和轻型装甲为核心，高速推进 |
| 签名机制 | 半履带车搭载步兵——Sdkfz 251 可运输和 buff 步兵；Panzer Grenadiers 是核心多用途步兵 |
| 角色分工 | Panzer Grenadiers = 核心（可升级多种武器）；Marder III = 反坦克；Hetzer/Jagdpanther = 重型 TD |
| 科技树 | 四个战斗群建筑（Kampfgruppe Kompanie、Logistik Kompanie、Panzer-Support Kommand、Panzer-Jager Kommand） |
| 核心协同 | 半履带车运输 PG → 快速部署 → Marder III 远程反装甲 → Hetzer 前线吸收火力 |
| 生产机制 | 建筑生产；无固定基地（可移动建筑） |
| 机动哲学 | 极高机动性——所有单位都很快，适合快速穿插 |
| 视野控制 | 半履带车和轻型车辆提供视野 |
| 反制弱点 | 缺乏静态防御工事；步兵数量少；面对重装甲正面交火劣势 |
| 强势时间窗 | 早中期（快速装甲突击）；焦土指挥树的区域封锁 |
| 经济模型 | 依赖燃料出装甲；弹药用于 PG 武器升级 |

---

### CoH2 阵营

#### 2.5 苏联（Soviet Union）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 人海战术——以数量压倒质量，廉价单位大规模投入 |
| 签名机制 | 征召兵（Conscript）合并——可将征召兵合并入其他残血小队补充人数；免费武器组 |
| 角色分工 | Conscripts = 肉盾/占点；Shock Troops = 近战突击；Guards = 反装甲/精锐；Sniper = 精确打击 |
| 科技树 | 通过建筑升级解锁——Special Rifle Command → Support Weapon Kampaneya → Mechanized Armor Kampaneya → Tankoviy Battalion Command |
| 核心协同 | Conscripts 吸引火力 → Maxim 压制 → Shock Troops 包抄近战 → T-34/IS-2 装甲收割 |
| 生产机制 | 建筑生产；指挥官可呼叫精英单位 |
| 机动哲学 | 中等机动性——T-34 快速但脆弱，依赖数量 |
| 视野控制 | Sniper 双人组侦察、M3A1 侦察车 |
| 反制弱点 | 单兵质量低；装甲正面薄弱；对德国精锐步兵近战劣势（非 Shock Troops） |
| 强势时间窗 | 早期（Conscript + Maxim 压制）；后期（IS-2/ISU-152 重型单位） |
| 经济模型 | 人力收入正常，单位成本低廉；弹药用于燃烧瓶和升级；燃料节奏决定装甲出兵 |

#### 2.6 国防军东线（Wehrmacht / Ostheer）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 精英高效——单位昂贵但战斗力强，以质取胜 |
| 签名机制 | MG42 压制核心——一个 MG42 可以封锁整条街道；Grenadier 多功能性 |
| 角色分工 | Grenadiers = 核心步兵；Panzergrenadiers = 突击步兵；MG42 = 火力核心；Sniper = 精确打击 |
| 科技树 | 四阶段科技（Battle Phase 1-4），每阶段解锁新建筑和单位 |
| 核心协同 | MG42 压制 → 狙击手点杀 → Pak 40 反装甲 → Panzer IV/Panther 装甲收割 |
| 生产机制 | 建筑生产；指挥官可呼叫 Tiger/Elefant 等重型单位 |
| 机动哲学 | 中等——装甲单位机动性适中，不依赖速度 |
| 视野控制 | Sniper 侦察、Sdkfz 222 侦察车 |
| 反制弱点 | 单位昂贵导致数量劣势；早期面对苏联人海压力大 |
| 强势时间窗 | 中后期（Panther/Tiger 到场后）；MG42 阵地防守 |
| 经济模型 | 单位成本高，效率高；弹药和燃料都需要精打细算 |

#### 2.7 西线最高指挥部（Oberkommando West / OKW）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 高科技精锐——资源有限但单位战斗力极强 |
| 签名机制 | 资源惩罚——OKW 燃料和弹药收入只有正常值的约 66%，但可通过 Salvage 回收资源；卡车基地可前移 |
| 角色分工 | Volksgrenadiers = 核心步兵；Obersoldaten = 终极步兵；Sturmpioneers = 近战工兵/突击 |
| 科技树 | 四个建筑——每个建筑提供不同单位；通过升级解锁高级单位 |
| 核心协同 | Volksgrenadiers + MG34 压制 → Raketenwerfer 反装甲 → Luchs/Puma 快速打击 → Panther/King Tiger 终结 |
| 生产机制 | 建筑生产；基地卡车可重新部署 |
| 机动哲学 | 中高——Luchs 和 Puma 提供快速打击能力 |
| 视野控制 | Kübelwagen 快速侦察 |
| 反制弱点 | 资源收入低导致出兵慢；早期步兵火力不足；被压制后难以恢复 |
| 强势时间窗 | 中后期（高科技单位到场后碾压）；King Tiger/Jagdtiger 的终极装甲 |
| 经济模型 | 资源惩罚是最大制约；Salvage 和领土控制至关重要 |

#### 2.8 美军（US Forces / CoH2 DLC）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 机动合成兵种——与 CoH1 美军类似，强调灵活性和武器升级 |
| 签名机制 | 车辆乘员系统——美军车辆有独立乘员，可以下车维修/占点；上尉/中尉科技路线选择 |
| 角色分工 | Riflemen = 核心步兵；Assault Engineers = 近战突击；Paratroopers = 深入敌后；Jackson = 反坦克 |
| 科技树 | 通过上尉（Captain）或中尉（Lieutenant）选择科技路线——不同路线解锁不同单位 |
| 核心协同 | Riflemen + .50 Cal 压制 → Bazooka 反装甲 → Sherman 支援 → Jackson 远程反装甲 |
| 生产机制 | 建筑生产；空降指挥官可空投单位 |
| 机动哲学 | 高——车辆乘员系统允许快速转移和维修 |
| 视野控制 | Pathfinders 侦察、M20 侦察车 |
| 反制弱点 | 装甲正面不如德国重装甲；早期反装甲能力有限 |
| 强势时间窗 | 中期（Sherman 到场后的机动战）；空降战术的全图部署 |
| 经济模型 | 人力正常，弹药需求高（武器升级），燃料决定车辆节奏 |

#### 2.9 英军（UK Forces / CoH2 DLC）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 阵地推进——与 CoH1 英军类似，但更强调步兵 Section 的升级灵活性 |
| 签名机制 | Infantry Section 升级系统——可根据需求升级为 Bren/PIAT 等角色；工事建筑 |
| 角色分工 | Infantry Section = 核心（可升级多种角色）；Commandos = 精锐突击；Centaur = AA/反步兵 |
| 科技树 | 通过 AEC 和 Anvil 升级解锁不同阶段 |
| 核心协同 | Infantry Section + Vickers 压制 → 工事封锁 → Cromwell/Firefly 装甲 → Comet 终极 |
| 生产机制 | 建筑生产；指挥官可呼叫 Commandos/Churchill |
| 机动哲学 | 中低——阵地推进为主，Comet 提供有限的机动打击 |
| 视野控制 | Universal Carrier 侦察、工事提供视野 |
| 反制弱点 | 早期机动性差；工事被摧毁后战力大降；缺乏快速反装甲手段 |
| 强势时间窗 | 中后期（工事网 + Firefly 反装甲）；Anvil 路线的重装甲推进 |
| 经济模型 | 人力正常，弹药用于 Section 升级，燃料决定装甲节奏 |

---

### CoH3 阵营

#### 2.10 美军（US Forces / CoH3）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 进攻导向的合成兵种——强调前压和机动性，比 CoH2 更具攻击性 |
| 签名机制 | 老兵班长（Veteran Squad Leader）系统——步兵小队可升级班长获得 buff；车辆乘员系统保留 |
| 角色分工 | Riflemen = 核心；Pathfinders = 侦察；Paratroopers = 深入敌后；Sherman = 通用坦克；Hellcat = 反坦克 |
| 科技树 | 通过 Veterancy Sergeant 和车辆调配场升级；更简化的科技路径 |
| 核心协同 | Riflemen + .30 Cal 压制 → Bazooka 反装甲 → Sherman + Hellcat 装甲协同 → 机动包抄 |
| 生产机制 | 建筑生产；战斗群提供额外单位 |
| 机动哲学 | 高——Hellcat 是最快的坦克歼击车之一，Sherman 机动性优秀 |
| 视野控制 | Pathfinders 隐蔽侦察、M16 AA 提供空中视野 |
| 反制弱点 | 正面装甲薄弱；早期反装甲依赖 Bazooka，穿甲不足 |
| 强势时间窗 | 中期（Sherman + Hellcat 机动组合）；空降战斗群的全图部署 |
| 经济模型 | 人力正常，弹药需求高（武器升级），燃料决定装甲节奏 |

#### 2.11 国防军（Wehrmacht / CoH3）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 精锐阵地战——强化的 MG42 核心和阶段性科技推进 |
| 签名机制 | 阶段科技（Phase 1-3）逐步解锁；碉堡系统可升级为医疗站/维修站/机枪巢 |
| 角色分工 | Grenadiers = 核心；Panzergrenadiers = 突击；MG42 = 压制核心；Pak 40 = 反装甲；Tiger = 终极装甲 |
| 科技树 | 三阶段升级，每阶段解锁新建筑和单位 |
| 核心协同 | MG42 压制 → 狙击手点杀 → Pak 40 反装甲 → Panzer IV/Panther 正面碾压 |
| 生产机制 | 建筑生产；战斗群提供额外单位和能力 |
| 机动哲学 | 中等——不追求速度，以火力推进为主 |
| 视野控制 | 狙击手侦察、Sdkfz 234 Puma 快速巡视 |
| 反制弱点 | 单位昂贵；被侧翼包抄后 MG42 压制网失效；早期步兵数量不足 |
| 强势时间窗 | 中后期（Tiger 到场后）；防御战斗群的阵地战 |
| 经济模型 | 单位成本高但效率高；弹药和燃料需要精打细算 |

#### 2.12 英军（British / CoH3）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 方法性推进——步兵 Section 升级 + 炮兵支援 + 重型装甲收割 |
| 签名机制 | Infantry Section 多角色升级（Bren/PIAT/狙击手）；炮兵聚焦（25 磅炮）；印度炮兵战斗群 |
| 角色分工 | Infantry Section = 核心（多角色）；Gurkhas = 近战精锐；Commandos = 深入敌后；Matilda = 重型步兵坦克 |
| 科技树 | 通过 Platoon Command Post 和 Company Command Post 升级 |
| 核心协同 | Infantry Section + Vickers 压制 → 炮兵软化 → Cromwell/Firefly 装甲 → Matilda/Churchill 突破 |
| 生产机制 | 建筑生产；战斗群提供 Gurkhas/Commandos 等特殊单位 |
| 机动哲学 | 中低——以阵地推进为主，Crusader 提供有限机动侦察 |
| 视野控制 | Dingo 侦察车、Universal Carrier |
| 反制弱点 | 早期机动性差；装甲推进慢；被火焰武器清除步兵后战力大降 |
| 强势时间窗 | 中后期（炮兵网 + 重型装甲）；印度炮兵战斗群的远程压制 |
| 经济模型 | 人力正常，弹药用于 Section 升级，燃料决定装甲和炮兵节奏 |

#### 2.13 德意志非洲军团（Deutsches Afrikakorps / DAK）

| 维度 | 分析 |
|---|---|
| 设计哲学 | 机动装甲战——以半履带车和意大利轻装甲为核心，沙漠闪电战风格 |
| 签名机制 | 半履带车搭载系统——Sdkfz 250/251 可运输和 buff 步兵；意大利步兵（Bersaglieri）提供独特战术；移动基地 |
| 角色分工 | Panzergrenadiers = 核心；Bersaglieri = 机动侦察步兵；Panzers III = 通用坦克；Tiger = 终极装甲 |
| 科技树 | 通过半履带车升级和战斗群解锁；强调中低科技单位的升级路径 |
| 核心协同 | 半履带车运输 PG → Bersaglieri 侦察 → Panzer III + 88mm Flak 反装甲 → Tiger 终结 |
| 生产机制 | 建筑生产（可移动）；意大利单位从特殊建筑生产 |
| 机动哲学 | 极高——所有装甲单位都很快，半履带车提供机动步兵运输 |
| 视野控制 | 8-Rad（Puma）快速侦察、Bersaglieri 机动侦察 |
| 反制弱点 | 缺乏重型静态防御；装甲正面不如 Wehrmacht 的 Tiger；步兵质量中等 |
| 强势时间窗 | 早中期（快速装甲突击）；后期 Tiger 到场后的重装甲战 |
| 经济模型 | 依赖燃料出装甲；弹药用于步兵升级和 88mm 炮部署 |

---

## 第三部分：单位数据表

### 数据格式说明

每个单位按以下字段列出。由于 CoH 系列不同版本数值会调整，以下数据为近似值/代表值，仅供参考。

- **cost**: MP（人力）/ MU（弹药）/ FU（燃料）
- **hp**: 车辆为总 HP；步兵为单模型 HP × 小队人数
- **armor**: 车辆前/侧/后装甲值；步兵无此字段
- **penetration**: 穿甲值（车辆武器）
- **vet**: 老练度升级效果简述

---

### 3.1 Company of Heroes 1

#### 3.1.1 美军（Americans）

##### 工兵小队（Engineer Squad）
| 字段 | 值 |
|---|---|
| name_zh | 工兵小队 |
| name_en | Engineer Squad |
| faction | Americans |
| game | CoH1 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 140 |
| cost_munitions | 0 |
| cost_fuel | 0 |
| pop | 3 |
| build_time | 15s |
| hp | 55 × 3 |
| armor_front | — |
| armor_side | — |
| armor_rear | — |
| tags | 步兵/工兵/建造者 |
| speed | 中 |
| acceleration | — |
| turn | — |
| vision | 中 |
| fly | 否 |
| damage | 低 |
| atk_type | 枪械 |
| cooldown | — |
| range | 近-中 |
| target | 步兵 |
| splash | 无 |
| penetration | 无 |
| bonus_vs | — |
| squad_size | 3 |
| weapon_upgrades | 喷火器（50弹药） |
| reinforce_cost | 7人力/模型 |
| active | 建造/维修/布雷/拆雷 |
| passive | — |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 步枪兵小队（Riflemen Squad）
| 字段 | 值 |
|---|---|
| name_zh | 步枪兵小队 |
| name_en | Riflemen Squad |
| faction | Americans |
| game | CoH1 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 270 |
| cost_munitions | 0 |
| cost_fuel | 0 |
| pop | 6 |
| build_time | 30s |
| hp | 55 × 6 |
| tags | 步兵/核心 |
| speed | 中 |
| vision | 中 |
| damage | 中 |
| atk_type | 枪械（M1 Garand） |
| range | 中 |
| target | 步兵 |
| squad_size | 6 |
| weapon_upgrades | BAR（60弹药/2把）、Sticky Bomb |
| reinforce_cost | 27人力/模型 |
| active | 投掷手雷（弹药）、粘性炸弹（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+防御+; Vet3: 伤害+ |

##### 空降兵小队（Airborne Squad）
| 字段 | 值 |
|---|---|
| name_zh | 空降兵小队 |
| name_en | Airborne Squad |
| faction | Americans |
| game | CoH1 |
| tier | 指挥树（Airborne） |
| built_from | 空降（任意可见区域） |
| cost_manpower | 375 |
| pop | 6 |
| build_time | — |
| hp | 70 × 6 |
| tags | 步兵/精锐/空降 |
| speed | 中高 |
| vision | 中高 |
| damage | 中高 |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵/轻装甲 |
| squad_size | 6 |
| weapon_upgrades | Recoilless Rifle（弹药/反坦克） |
| reinforce_cost | 37人力/模型 |
| active | 可在任意可见区域空降；设置炸药包 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 游骑兵小队（Ranger Squad）
| 字段 | 值 |
|---|---|
| name_zh | 游骑兵小队 |
| name_en | Ranger Squad |
| faction | Americans |
| game | CoH1 |
| tier | 指挥树（Infantry） |
| built_from | 呼叫入场 |
| cost_manpower | 400 |
| pop | 6 |
| build_time | — |
| hp | 65 × 6 |
| tags | 步兵/精锐/反坦克 |
| speed | 中 |
| damage | 中（Thompson SMG + Bazooka） |
| atk_type | 枪械/反坦克 |
| range | 近-中 |
| target | 步兵/装甲 |
| squad_size | 6 |
| weapon_upgrades | Thompson SMG（弹药） |
| reinforce_cost | 40人力/模型 |
| active | Fire-Up（突破压制） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### .30 口径机枪组（.30 Cal Machine Gun Team）
| 字段 | 值 |
|---|---|
| name_zh | .30 口径机枪组 |
| name_en | .30 Cal Machine Gun Team |
| faction | Americans |
| game | CoH1 |
| tier | T0（Weapons Support Center） |
| built_from | Weapons Support Center |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 55 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### 81mm 迫击炮组（81mm Mortar Team）
| 字段 | 值 |
|---|---|
| name_zh | 81mm 迫击炮组 |
| name_en | 81mm Mortar Team |
| faction | Americans |
| game | CoH1 |
| tier | T0（Weapons Support Center） |
| built_from | Weapons Support Center |
| cost_manpower | 280 |
| pop | 5 |
| build_time | 25s |
| hp | 55 × 3 |
| tags | 步兵/支援武器/间接火力 |
| damage | 高（溅射） |
| atk_type | 迫击炮 |
| range | 远 |
| target | 步兵/驻防 |
| splash | 有 |
| squad_size | 3 |
| active | 烟雾弹 |
| vet_upgrades | Vet1: 精度+; Vet2: 装填+; Vet3: 伤害+ |

##### 狙击手（Sniper）
| 字段 | 值 |
|---|---|
| name_zh | 狙击手 |
| name_en | Sniper |
| faction | Americans |
| game | CoH1 |
| tier | T0（Weapons Support Center） |
| built_from | Weapons Support Center |
| cost_manpower | 340 |
| pop | 4 |
| build_time | 30s |
| hp | 75 × 1 |
| tags | 步兵/狙击/侦察 |
| damage | 极高（单体秒杀） |
| atk_type | 狙击步枪 |
| range | 远 |
| target | 步兵 |
| squad_size | 1 |
| active | 隐蔽 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装填+ |

##### M3 半履带车（M3 Half-track）
| 字段 | 值 |
|---|---|
| name_zh | M3 半履带车 |
| name_en | M3 Half-track |
| faction | Americans |
| game | CoH1 |
| tier | T1（Motor Pool） |
| built_from | Motor Pool |
| cost_manpower | 220 |
| cost_fuel | 15 |
| pop | 4 |
| build_time | 30s |
| hp | 300 |
| armor_front | 低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/运输/支援 |
| speed | 高 |
| vision | 中 |
| damage | 低 |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| active | 运输步兵；升级四联装 .50（弹药） |
| vet_upgrades | Vet1: HP+; Vet2: 速度+; Vet3: 伤害+ |

##### M8 灰狗装甲车（M8 Greyhound）
| 字段 | 值 |
|---|---|
| name_zh | M8 灰狗装甲车 |
| name_en | M8 Greyhound |
| faction | Americans |
| game | CoH1 |
| tier | T1（Motor Pool） |
| built_from | Motor Pool |
| cost_manpower | 280 |
| cost_fuel | 30 |
| pop | 6 |
| build_time | 35s |
| hp | 400 |
| armor_front | 中低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/侦察/轻装甲 |
| speed | 高 |
| vision | 高 |
| damage | 中（37mm） |
| atk_type | 穿甲弹 |
| range | 中 |
| target | 轻装甲/步兵 |
| penetration | 中低 |
| active | 布雷；升级装甲裙板（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### M10 狼獾坦克歼击车（M10 Wolverine）
| 字段 | 值 |
|---|---|
| name_zh | M10 狼獾坦克歼击车 |
| name_en | M10 Wolverine |
| faction | Americans |
| game | CoH1 |
| tier | T2（Tank Depot） |
| built_from | Tank Depot |
| cost_manpower | 300 |
| cost_fuel | 55 |
| pop | 8 |
| build_time | 45s |
| hp | 400 |
| armor_front | 中 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/坦克歼击车/反装甲 |
| speed | 高 |
| vision | 中 |
| damage | 高（3英寸主炮） |
| atk_type | 穿甲弹 |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### M4 谢尔曼中型坦克（M4 Sherman）
| 字段 | 值 |
|---|---|
| name_zh | M4 谢尔曼中型坦克 |
| name_en | M4 Sherman |
| faction | Americans |
| game | CoH1 |
| tier | T2（Tank Depot） |
| built_from | Tank Depot |
| cost_manpower | 420 |
| cost_fuel | 90 |
| pop | 10 |
| build_time | 45s |
| hp | 636 |
| armor_front | 中（~110） |
| armor_side | 中低（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中高 |
| vision | 中 |
| damage | 中高（75mm） |
| atk_type | HE/AP |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| splash | 有（HE） |
| active | 烟雾弹；升级 .50 机枪（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### M26 潘兴重型坦克（M26 Pershing）
| 字段 | 值 |
|---|---|
| name_zh | M26 潘兴重型坦克 |
| name_en | M26 Pershing |
| faction | Americans |
| game | CoH1 |
| tier | 指挥树（Armor） |
| built_from | 呼叫入场 |
| cost_manpower | 900 |
| pop | 14 |
| build_time | — |
| hp | 990 |
| armor_front | 高（~180） |
| armor_side | 中高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/指挥树 |
| speed | 中 |
| vision | 中 |
| damage | 高（90mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.1.2 国防军（Wehrmacht）

##### 先锋队（Pioneers）
| 字段 | 值 |
|---|---|
| name_zh | 先锋队 |
| name_en | Pioneers |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 220 |
| pop | 4 |
| build_time | 20s |
| hp | 55 × 2 |
| tags | 步兵/工兵/建造者 |
| squad_size | 2 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 国民掷弹兵（Volksgrenadiers）
| 字段 | 值 |
|---|---|
| name_zh | 国民掷弹兵 |
| name_en | Volksgrenadiers |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 55 × 5 |
| tags | 步兵/核心/低成本 |
| squad_size | 5 |
| weapon_upgrades | MP40（弹药/2把） |
| active | 投掷手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 掷弹兵（Grenadiers）
| 字段 | 值 |
|---|---|
| name_zh | 掷弹兵 |
| name_en | Grenadiers |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T1（Krieg Barracks） |
| built_from | Krieg Barracks |
| cost_manpower | 300 |
| cost_munitions | 0 |
| cost_fuel | 0 |
| pop | 6 |
| build_time | 35s |
| hp | 65 × 4 |
| tags | 步兵/精锐/核心 |
| speed | 中 |
| vision | 中 |
| damage | 中高（Kar98k） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | MG42 LMG（弹药/2挺）、Panzerschreck（弹药） |
| reinforce_cost | 37人力/模型 |
| active | 投掷手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 十字骑士持有人（Knights Cross Holders）
| 字段 | 值 |
|---|---|
| name_zh | 十字骑士持有人 |
| name_en | Knights Cross Holders |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T3（Sturm Armory） |
| built_from | Sturm Armory |
| cost_manpower | 425 |
| pop | 6 |
| build_time | 40s |
| hp | 80 × 3 |
| tags | 步兵/终极精锐 |
| speed | 中 |
| damage | 高（STG44 突击步枪） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 3 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### MG42 重机枪组（MG42 Heavy Machine Gun Team）
| 字段 | 值 |
|---|---|
| name_zh | MG42 重机枪组 |
| name_en | MG42 Heavy Machine Gun Team |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 55 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/极高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### 国防军迫击炮组（81mm Mortar Team）
| 字段 | 值 |
|---|---|
| name_zh | 81mm 迫击炮组 |
| name_en | 81mm Mortar Team |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T1（Krieg Barracks） |
| built_from | Krieg Barracks |
| cost_manpower | 280 |
| pop | 5 |
| build_time | 25s |
| hp | 55 × 3 |
| tags | 步兵/支援武器/间接火力 |
| damage | 高（溅射） |
| atk_type | 迫击炮 |
| range | 远 |
| target | 步兵/驻防 |
| splash | 有 |
| squad_size | 3 |
| active | 烟雾弹 |
| vet_upgrades | Vet1: 精度+; Vet2: 装填+; Vet3: 伤害+ |

##### 国防军狙击手（Sniper）
| 字段 | 值 |
|---|---|
| name_zh | 狙击手 |
| name_en | Sniper |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T1（Krieg Barracks） |
| built_from | Krieg Barracks |
| cost_manpower | 340 |
| pop | 4 |
| build_time | 30s |
| hp | 75 × 1 |
| tags | 步兵/狙击/侦察 |
| damage | 极高（单体秒杀） |
| atk_type | 狙击步枪 |
| range | 远 |
| target | 步兵 |
| squad_size | 1 |
| active | 隐蔽 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装填+ |

##### Sdkfz 234 美洲狮（Sdkfz 234 Puma）
| 字段 | 值 |
|---|---|
| name_zh | Sdkfz 234 美洲狮装甲车 |
| name_en | Sdkfz 234 Puma |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T2（Sturm Armory） |
| built_from | Sturm Armory |
| cost_manpower | 320 |
| cost_fuel | 40 |
| pop | 8 |
| build_time | 35s |
| hp | 440 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/侦察/反步兵 |
| speed | 高 |
| vision | 高 |
| damage | 中高（50mm） |
| atk_type | 穿甲弹 |
| range | 中 |
| target | 轻装甲/步兵 |
| penetration | 中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### StuG IV 突击炮（StuG IV）
| 字段 | 值 |
|---|---|
| name_zh | StuG IV 突击炮 |
| name_en | StuG IV |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T2（Sturm Armory） |
| built_from | Sturm Armory |
| cost_manpower | 340 |
| cost_fuel | 65 |
| pop | 8 |
| build_time | 40s |
| hp | 600 |
| armor_front | 高（~160） |
| armor_side | 中（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/突击炮/反装甲 |
| speed | 中 |
| damage | 高（75mm） |
| atk_type | AP |
| range | 中 |
| target | 装甲 |
| penetration | 高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 四号坦克（Panzer IV）
| 字段 | 值 |
|---|---|
| name_zh | 四号中型坦克 |
| name_en | Panzer IV |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T3（Panzer Command） |
| built_from | Panzer Command |
| cost_manpower | 460 |
| cost_fuel | 80 |
| pop | 10 |
| build_time | 50s |
| hp | 600 |
| armor_front | 中高（~140） |
| armor_side | 中（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 豹式坦克（Panther）
| 字段 | 值 |
|---|---|
| name_zh | 豹式中型坦克 |
| name_en | Panther |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T4（Panzer Command） |
| built_from | Panzer Command |
| cost_manpower | 510 |
| cost_fuel | 110 |
| pop | 12 |
| build_time | 60s |
| hp | 760 |
| armor_front | 极高（~200） |
| armor_side | 高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型中型坦克/反装甲 |
| speed | 中高 |
| damage | 高（75mm L/70） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 虎式坦克（Tiger）
| 字段 | 值 |
|---|---|
| name_zh | 虎式重型坦克 |
| name_en | Tiger |
| faction | Wehrmacht |
| game | CoH1 |
| tier | 指挥树（Terror/Blitzkrieg） |
| built_from | 呼叫入场 |
| cost_manpower | 900 |
| pop | 14 |
| build_time | — |
| hp | 1064 |
| armor_front | 极高（~220） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/指挥树 |
| speed | 中低 |
| damage | 极高（88mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 虎王坦克（King Tiger）
| 字段 | 值 |
|---|---|
| name_zh | 虎王重型坦克 |
| name_en | King Tiger |
| faction | Wehrmacht |
| game | CoH1 |
| tier | 指挥树（Terror，一次性呼叫） |
| built_from | 呼叫入场（唯一） |
| cost_manpower | 0（指挥树） |
| pop | 14 |
| build_time | — |
| hp | 1200 |
| armor_front | 极高（~240） |
| armor_side | 极高（~160） |
| armor_rear | 中高（~100） |
| tags | 车辆/超重型坦克/指挥树 |
| speed | 低 |
| damage | 极高（88mm L/71） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 旋风自行高炮（Ostwind）
| 字段 | 值 |
|---|---|
| name_zh | 旋风自行高炮 |
| name_en | Ostwind |
| faction | Wehrmacht |
| game | CoH1 |
| tier | T3（Panzer Command） |
| built_from | Panzer Command |
| cost_manpower | 320 |
| cost_fuel | 65 |
| pop | 8 |
| build_time | 40s |
| hp | 500 |
| armor_front | 中 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/AA/反步兵 |
| speed | 中高 |
| damage | 中高（37mm 旋风炮） |
| atk_type | 榴弹/AA |
| range | 中 |
| target | 步兵/飞机 |
| splash | 有 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.1.3 英军（British Forces）

##### 工兵（Sappers）
| 字段 | 值 |
|---|---|
| name_zh | 工兵 |
| name_en | Sappers |
| faction | British |
| game | CoH1 |
| tier | T0（HQ Truck） |
| built_from | HQ Truck |
| cost_manpower | 140 |
| pop | 3 |
| build_time | 15s |
| hp | 55 × 3 |
| tags | 步兵/工兵/建造者 |
| squad_size | 3 |
| active | 建造/维修/工事 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 步兵班（Infantry Section）
| 字段 | 值 |
|---|---|
| name_zh | 步兵班 |
| name_en | Infantry Section |
| faction | British |
| game | CoH1 |
| tier | T0（HQ Truck） |
| built_from | HQ Truck |
| cost_manpower | 450 |
| pop | 8 |
| build_time | 35s |
| hp | 65 × 5 |
| tags | 步兵/核心 |
| speed | 中（在军官 buff 范围内提升） |
| damage | 中高（Lee-Enfield） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | Bren LMG（弹药）、Rifle Grenade（弹药） |
| reinforce_cost | 45人力/模型 |
| active | 隐蔽在掩体中（ officers 提供 buff） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### PIAT 组（PIAT Team）
| 字段 | 值 |
|---|---|
| name_zh | PIAT 反坦克组 |
| name_en | PIAT Team |
| faction | British |
| game | CoH1 |
| tier | T1 |
| built_from | — |
| cost_manpower | 280 |
| pop | 5 |
| hp | 55 × 3 |
| tags | 步兵/反坦克 |
| damage | 中高（PIAT 破甲弹） |
| atk_type | 反坦克 |
| range | 中 |
| target | 装甲 |
| penetration | 中高 |
| squad_size | 3 |

##### 英军狙击手（Sniper）
| 字段 | 值 |
|---|---|
| name_zh | 狙击手 |
| name_en | Sniper |
| faction | British |
| game | CoH1 |
| tier | T1 |
| built_from | — |
| cost_manpower | 340 |
| pop | 4 |
| hp | 75 × 1 |
| tags | 步兵/狙击/侦察 |
| damage | 极高（单体秒杀） |
| atk_type | 狙击步枪 |
| range | 远 |
| target | 步兵 |
| squad_size | 1 |
| active | 隐蔽 |

##### 少尉（Lieutenant）
| 字段 | 值 |
|---|---|
| name_zh | 少尉 |
| name_en | Lieutenant |
| faction | British |
| game | CoH1 |
| tier | T0（HQ Truck） |
| built_from | HQ Truck |
| cost_manpower | 180 |
| pop | 3 |
| hp | 90 × 1 |
| tags | 步兵/军官/buff |
| active | 为附近步兵提供速度和精度 buff；解锁科技 |
| vet_upgrades | Vet1: buff 范围+; Vet2: HP+; Vet3: buff 效果+ |

##### 上尉（Captain）
| 字段 | 值 |
|---|---|
| name_zh | 上尉 |
| name_en | Captain |
| faction | British |
| game | CoH1 |
| tier | T1 |
| built_from | — |
| cost_manpower | 260 |
| pop | 5 |
| hp | 100 × 1 |
| tags | 步兵/军官/buff |
| active | 为附近步兵提供防御 buff；解锁科技；可设置集结点 |
| vet_upgrades | Vet1: buff 范围+; Vet2: HP+; Vet3: buff 效果+ |

##### 斯图亚特轻型坦克（Stuart Light Tank）
| 字段 | 值 |
|---|---|
| name_zh | 斯图亚特轻型坦克 |
| name_en | Stuart Light Tank |
| faction | British |
| game | CoH1 |
| tier | T1 |
| built_from | — |
| cost_manpower | 280 |
| cost_fuel | 45 |
| pop | 6 |
| build_time | 35s |
| hp | 400 |
| armor_front | 中低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/轻型坦克/侦察 |
| speed | 高 |
| damage | 中（37mm） |
| atk_type | 穿甲弹 |
| range | 中 |
| target | 轻装甲/步兵 |
| active | 霰弹射击（Canister Shot，弹药，反步兵） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 克伦威尔坦克（Cromwell Tank）
| 字段 | 值 |
|---|---|
| name_zh | 克伦威尔巡航坦克 |
| name_en | Cromwell Tank |
| faction | British |
| game | CoH1 |
| tier | T2 |
| built_from | — |
| cost_manpower | 410 |
| cost_fuel | 75 |
| pop | 10 |
| build_time | 45s |
| hp | 585 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/中型坦克/通用 |
| speed | 高 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| active | 速度增强（Flank Speed） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 谢尔曼萤火虫（Sherman Firefly）
| 字段 | 值 |
|---|---|
| name_zh | 谢尔曼萤火虫坦克 |
| name_en | Sherman Firefly |
| faction | British |
| game | CoH1 |
| tier | T2 |
| built_from | — |
| cost_manpower | 420 |
| cost_fuel | 100 |
| pop | 12 |
| build_time | 50s |
| hp | 585 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/中型坦克/反装甲 |
| speed | 中 |
| damage | 高（17磅炮） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 重装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 丘吉尔坦克（Churchill Tank）
| 字段 | 值 |
|---|---|
| name_zh | 丘吉尔重型步兵坦克 |
| name_en | Churchill Tank |
| faction | British |
| game | CoH1 |
| tier | 指挥树（Royal Engineers） |
| built_from | 呼叫入场 |
| cost_manpower | 600 |
| cost_fuel | 0（指挥树） |
| pop | 12 |
| build_time | — |
| hp | 1050 |
| armor_front | 高（~180） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型步兵坦克/指挥树 |
| speed | 低 |
| damage | 中（6磅炮） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装甲+ |

##### 25 磅炮（25 Pounder Howitzer）
| 字段 | 值 |
|---|---|
| name_zh | 25 磅榴弹炮 |
| name_en | 25 Pounder Howitzer |
| faction | British |
| game | CoH1 |
| tier | T1+ |
| built_from | 工兵建造 |
| cost_manpower | 400 |
| cost_fuel | 40 |
| pop | 8 |
| build_time | 60s |
| hp | 400 |
| tags | 建筑/火炮/间接火力 |
| damage | 高（溅射） |
| atk_type | 榴弹炮 |
| range | 极远 |
| target | 步兵/建筑/驻防 |
| splash | 有 |
| active | 超级炮击（命令树）、烟幕 |
| vet_upgrades | — |

##### 17 磅反坦克炮（17 Pounder AT Gun）
| 字段 | 值 |
|---|---|
| name_zh | 17 磅反坦克炮 |
| name_en | 17 Pounder AT Gun |
| faction | British |
| game | CoH1 |
| tier | T1+ |
| built_from | 工兵建造 |
| cost_manpower | 320 |
| cost_fuel | 25 |
| pop | 8 |
| build_time | 50s |
| hp | 400 |
| tags | 建筑/反坦克/静态 |
| damage | 高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | — |

---

#### 3.1.4 装甲精英（Panzer Elite）

##### 装甲掷弹兵（Panzer Grenadiers）
| 字段 | 值 |
|---|---|
| name_zh | 装甲掷弹兵 |
| name_en | Panzer Grenadiers |
| faction | Panzer Elite |
| game | CoH1 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 255 |
| pop | 6 |
| build_time | 30s |
| hp | 65 × 3 |
| tags | 步兵/核心/多用途 |
| speed | 中高 |
| damage | 中高（G43/Kar98k） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 3 |
| weapon_upgrades | MP44（弹药/2把）、Panzerschreck（弹药）、G43（弹药） |
| reinforce_cost | 37人力/模型 |
| active | 投掷手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 伞降猎兵（Fallschirmjäger）
| 字段 | 值 |
|---|---|
| name_zh | 伞降猎兵 |
| name_en | Fallschirmjäger |
| faction | Panzer Elite |
| game | CoH1 |
| tier | 指挥树（Luftwaffe） |
| built_from | 建筑内潜伏部署 |
| cost_manpower | 420 |
| pop | 6 |
| hp | 70 × 4 |
| tags | 步兵/精锐/伏击 |
| damage | 高（FG42） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | Faust（反坦克） |
| active | 隐蔽伏击 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 旋风自行高炮（Wirbelwind）
| 字段 | 值 |
|---|---|
| name_zh | 旋风自行高炮 |
| name_en | Wirbelwind |
| faction | Panzer Elite |
| game | CoH1 |
| tier | T2（Panzer-Support Kommand） |
| built_from | Panzer-Support Kommand |
| cost_manpower | 320 |
| cost_fuel | 50 |
| pop | 8 |
| build_time | 35s |
| hp | 450 |
| armor_front | 中 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/AA/反步兵 |
| speed | 中高 |
| damage | 中高（四联 20mm） |
| atk_type | AA/榴弹 |
| range | 中 |
| target | 步兵/飞机 |
| splash | 有 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 黄鼠狼 III（Marder III）
| 字段 | 值 |
|---|---|
| name_zh | 黄鼠狼 III 坦克歼击车 |
| name_en | Marder III |
| faction | Panzer Elite |
| game | CoH1 |
| tier | T1（Logistik Kompanie） |
| built_from | Logistik Kompanie |
| cost_manpower | 280 |
| cost_fuel | 35 |
| pop | 6 |
| build_time | 30s |
| hp | 350 |
| armor_front | 低 |
| armor_side | 极低 |
| armor_rear | 极低 |
| tags | 车辆/坦克歼击车/反装甲 |
| speed | 高 |
| damage | 高（75mm PaK 40） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 追猎者（Hetzer）
| 字段 | 值 |
|---|---|
| name_zh | 追猎者坦克歼击车 |
| name_en | Hetzer |
| faction | Panzer Elite |
| game | CoH1 |
| tier | 指挥树（Tank Hunter） |
| built_from | 呼叫入场 |
| cost_manpower | 500 |
| cost_fuel | 0（指挥树） |
| pop | 10 |
| build_time | — |
| hp | 700 |
| armor_front | 高（~160） |
| armor_side | 中（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/坦克歼击车/指挥树 |
| speed | 中高 |
| damage | 高（75mm） |
| atk_type | AP |
| range | 中 |
| target | 装甲 |
| penetration | 高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 猎豹（Jagdpanther）
| 字段 | 值 |
|---|---|
| name_zh | 猎豹坦克歼击车 |
| name_en | Jagdpanther |
| faction | Panzer Elite |
| game | CoH1 |
| tier | 指挥树（Tank Hunter，一次性） |
| built_from | 呼叫入场（唯一） |
| cost_manpower | 0（指挥树） |
| pop | 14 |
| build_time | — |
| hp | 1200 |
| armor_front | 极高（~240） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/超重型坦克歼击车/指挥树 |
| speed | 中 |
| damage | 极高（88mm L/71） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

### 3.2 Company of Heroes 2

#### 3.2.1 苏联（Soviet Union）

##### 战斗工兵（Combat Engineers）
| 字段 | 值 |
|---|---|
| name_zh | 战斗工兵 |
| name_en | Combat Engineers |
| faction | Soviet |
| game | CoH2 |
| tier | T0（HQ） |
| built_from | Regimental Headquarters |
| cost_manpower | 170 |
| cost_munitions | 0 |
| cost_fuel | 0 |
| pop | 3 |
| build_time | 15s |
| hp | 48 × 3 |
| tags | 步兵/工兵/建造者 |
| speed | 中 |
| vision | 中 |
| damage | 低 |
| atk_type | 枪械（莫辛纳甘） |
| range | 近-中 |
| target | 步兵 |
| squad_size | 3 |
| weapon_upgrades | 喷火器（弹药） |
| reinforce_cost | 18人力/模型 |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 征召兵（Conscript Squad）
| 字段 | 值 |
|---|---|
| name_zh | 征召兵小队 |
| name_en | Conscript Squad |
| faction | Soviet |
| game | CoH2 |
| tier | T0（Regimental Headquarters） |
| built_from | Regimental Headquarters |
| cost_manpower | 240 |
| pop | 6 |
| build_time | 25s |
| hp | 48 × 6 |
| tags | 步兵/核心/低成本/人海 |
| speed | 中 |
| vision | 中 |
| damage | 低中（莫辛纳甘） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 6 |
| weapon_upgrades | DP-28 LMG（弹药）、PTRS 反坦克步枪（弹药） |
| reinforce_cost | 20人力/模型 |
| active | 合并（Merge）、燃烧瓶（弹药）、AT 手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 惩戒营（Penal Battalion）
| 字段 | 值 |
|---|---|
| name_zh | 惩戒营 |
| name_en | Penal Battalion |
| faction | Soviet |
| game | CoH2 |
| tier | T1（Special Rifle Command） |
| built_from | Special Rifle Command |
| cost_manpower | 300 |
| pop | 6 |
| build_time | 30s |
| hp | 52 × 6 |
| tags | 步兵/突击 |
| speed | 中高 |
| damage | 中（SVT-40） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 6 |
| weapon_upgrades | PTRS（弹药）、喷火器（弹药） |
| active | 燃烧瓶（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 冲击部队（Shock Troops）
| 字段 | 值 |
|---|---|
| name_zh | 冲击部队 |
| name_en | Shock Troops |
| faction | Soviet |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 390 |
| pop | 8 |
| build_time | 35s |
| hp | 72 × 6 |
| tags | 步兵/精锐/近战 |
| speed | 中 |
| damage | 高（PPSh-41） |
| atk_type | 冲锋枪 |
| range | 近 |
| target | 步兵 |
| squad_size | 6 |
| active | 投掷手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 近卫步枪兵（Guards Rifle Infantry）
| 字段 | 值 |
|---|---|
| name_zh | 近卫步枪兵 |
| name_en | Guards Rifle Infantry |
| faction | Soviet |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 360 |
| pop | 7 |
| build_time | 30s |
| hp | 65 × 5 |
| tags | 步兵/精锐/反坦克 |
| speed | 中 |
| damage | 中高（SVT-40 + PTRD） |
| atk_type | 枪械/反坦克 |
| range | 中远 |
| target | 步兵/轻装甲 |
| squad_size | 5 |
| weapon_upgrades | DP-28（弹药） |
| active | AT 手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 苏联狙击手（Sniper）
| 字段 | 值 |
|---|---|
| name_zh | 苏联狙击手组 |
| name_en | Sniper |
| faction | Soviet |
| game | CoH2 |
| tier | T1（Special Rifle Command） |
| built_from | Special Rifle Command |
| cost_manpower | 360 |
| pop | 6 |
| build_time | 35s |
| hp | 48 × 2 |
| tags | 步兵/狙击/侦察 |
| damage | 极高（单体秒杀） |
| atk_type | 狙击步枪 |
| range | 远 |
| target | 步兵 |
| squad_size | 2 |
| active | 隐蔽 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装填+ |

##### 马克沁机枪组（Maxim Heavy Machine Gun）
| 字段 | 值 |
|---|---|
| name_zh | 马克沁重机枪组 |
| name_en | Maxim Heavy Machine Gun |
| faction | Soviet |
| game | CoH2 |
| tier | T1（Support Weapon Kampaneya） |
| built_from | Support Weapon Kampaneya |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### ZiS-3 反坦克炮（ZiS-3 AT Gun）
| 字段 | 值 |
|---|---|
| name_zh | ZiS-3 76mm 反坦克炮 |
| name_en | ZiS-3 AT Gun |
| faction | Soviet |
| game | CoH2 |
| tier | T2（Support Weapon Kampaneya） |
| built_from | Support Weapon Kampaneya |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| active | 直射/间接火力（HE） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### T-34/76 坦克（T-34/76）
| 字段 | 值 |
|---|---|
| name_zh | T-34/76 中型坦克 |
| name_en | T-34/76 |
| faction | Soviet |
| game | CoH2 |
| tier | T3（Tankoviy Battalion Command） |
| built_from | Tankoviy Battalion Command |
| cost_manpower | 280 |
| cost_fuel | 80 |
| pop | 10 |
| build_time | 45s |
| hp | 640 |
| armor_front | 中（~120） |
| armor_side | 中低（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 高 |
| damage | 中高（76mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| active | 撞击（Ram） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### T-34/85 坦克（T-34/85）
| 字段 | 值 |
|---|---|
| name_zh | T-34/85 中型坦克 |
| name_en | T-34/85 |
| faction | Soviet |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 380 |
| cost_fuel | 120 |
| pop | 12 |
| build_time | 45s |
| hp | 720 |
| armor_front | 中高（~140） |
| armor_side | 中（~90） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/指挥官 |
| speed | 高 |
| damage | 高（85mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### KV-1 重型坦克（KV-1）
| 字段 | 值 |
|---|---|
| name_zh | KV-1 重型坦克 |
| name_en | KV-1 |
| faction | Soviet |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 400 |
| cost_fuel | 145 |
| pop | 13 |
| build_time | 50s |
| hp | 1040 |
| armor_front | 高（~180） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/指挥官 |
| speed | 低 |
| damage | 中高（76mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装甲+ |

##### IS-2 重型坦克（IS-2）
| 字段 | 值 |
|---|---|
| name_zh | IS-2 重型坦克 |
| name_en | IS-2 |
| faction | Soviet |
| game | CoH2 |
| tier | T4（Tankoviy Battalion Command） |
| built_from | Tankoviy Battalion Command |
| cost_manpower | 500 |
| cost_fuel | 185 |
| pop | 14 |
| build_time | 60s |
| hp | 1040 |
| armor_front | 极高（~220） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克 |
| speed | 中低 |
| damage | 极高（122mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| splash | 有（HE） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### SU-85 坦克歼击车（SU-85）
| 字段 | 值 |
|---|---|
| name_zh | SU-85 坦克歼击车 |
| name_en | SU-85 |
| faction | Soviet |
| game | CoH2 |
| tier | T3（Tankoviy Battalion Command） |
| built_from | Tankoviy Battalion Command |
| cost_manpower | 360 |
| cost_fuel | 120 |
| pop | 12 |
| build_time | 45s |
| hp | 560 |
| armor_front | 中（~100） |
| armor_side | 低（~70） |
| armor_rear | 极低（~50） |
| tags | 车辆/坦克歼击车/反装甲 |
| speed | 中 |
| damage | 高（85mm） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 装甲 |
| active | 望远镜（视野增加） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### ISU-152 突击炮（ISU-152）
| 字段 | 值 |
|---|---|
| name_zh | ISU-152 突击炮 |
| name_en | ISU-152 |
| faction | Soviet |
| game | CoH2 |
| tier | T4 / 指挥官 |
| built_from | Tankoviy Battalion Command |
| cost_manpower | 540 |
| cost_fuel | 200 |
| pop | 14 |
| build_time | 60s |
| hp | 1000 |
| armor_front | 高（~180） |
| armor_side | 中高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/突击炮/反装甲/反步兵 |
| speed | 中低 |
| damage | 极高（152mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵/建筑 |
| penetration | 高 |
| splash | 有（大面积） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 喀秋莎火箭炮（Katyusha）
| 字段 | 值 |
|---|---|
| name_zh | 喀秋莎火箭炮 |
| name_en | Katyusha |
| faction | Soviet |
| game | CoH2 |
| tier | T3（Tankoviy Battalion Command） |
| built_from | Tankoviy Battalion Command |
| cost_manpower | 280 |
| cost_fuel | 90 |
| pop | 12 |
| build_time | 40s |
| hp | 240 |
| armor_front | 极低 |
| armor_side | 极低 |
| armor_rear | 极低 |
| tags | 车辆/火箭炮/间接火力 |
| speed | 高 |
| damage | 高（大面积溅射） |
| atk_type | 火箭弹 |
| range | 极远 |
| target | 步兵/建筑/驻防 |
| splash | 有 |
| active | 火箭弹齐射 |
| vet_upgrades | Vet1: 装填+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.2.2 国防军东线（Wehrmacht / Ostheer）

##### 先锋队（Pioneers）
| 字段 | 值 |
|---|---|
| name_zh | 先锋队 |
| name_en | Pioneers |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 200 |
| pop | 4 |
| build_time | 15s |
| hp | 48 × 2 |
| tags | 步兵/工兵/建造者 |
| squad_size | 2 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 掷弹兵（Grenadiers）
| 字段 | 值 |
|---|---|
| name_zh | 掷弹兵 |
| name_en | Grenadiers |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T0（Infanterie Kompanie） |
| built_from | Infanterie Kompanie |
| cost_manpower | 240 |
| pop | 6 |
| build_time | 25s |
| hp | 52 × 4 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中高（Kar98k） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | MG42 LMG（弹药）、Panzerschreck（弹药） |
| reinforce_cost | 27人力/模型 |
| active | 步枪手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 装甲掷弹兵（Panzergrenadiers）
| 字段 | 值 |
|---|---|
| name_zh | 装甲掷弹兵 |
| name_en | Panzergrenadiers |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T2（Leichte Mechanized Kompanie） |
| built_from | Leichte Mechanized Kompanie |
| cost_manpower | 340 |
| pop | 7 |
| build_time | 30s |
| hp | 60 × 4 |
| tags | 步兵/精锐/突击 |
| speed | 中高 |
| damage | 高（STG44） |
| atk_type | 突击步枪 |
| range | 中 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | Panzerschreck（弹药） |
| active | 冲锋 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### MG42 重机枪组（MG42 HMG Team）
| 字段 | 值 |
|---|---|
| name_zh | MG42 重机枪组 |
| name_en | MG42 HMG Team |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T1（Support Gruppe Korps） |
| built_from | Support Gruppe Korps |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/极高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药）、焚烧弹（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### Pak 40 反坦克炮（Pak 40 AT Gun）
| 字段 | 值 |
|---|---|
| name_zh | Pak 40 75mm 反坦克炮 |
| name_en | Pak 40 AT Gun |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T2（Support Gruppe Korps） |
| built_from | Support Gruppe Korps |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| active | 隐蔽、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 四号坦克（Panzer IV）
| 字段 | 值 |
|---|---|
| name_zh | 四号中型坦克 |
| name_en | Panzer IV |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T3（Schwere Panzer Korps） |
| built_from | Schwere Panzer Korps |
| cost_manpower | 360 |
| cost_fuel | 110 |
| pop | 10 |
| build_time | 45s |
| hp | 640 |
| armor_front | 中高（~140） |
| armor_side | 中（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 豹式坦克（Panther）
| 字段 | 值 |
|---|---|
| name_zh | 豹式中型坦克 |
| name_en | Panther |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T4（Schwere Panzer Korps） |
| built_from | Schwere Panzer Korps |
| cost_manpower | 460 |
| cost_fuel | 175 |
| pop | 12 |
| build_time | 55s |
| hp | 880 |
| armor_front | 极高（~200） |
| armor_side | 高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型中型坦克/反装甲 |
| speed | 中高 |
| damage | 高（75mm L/70） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 虎式坦克（Tiger）
| 字段 | 值 |
|---|---|
| name_zh | 虎式重型坦克 |
| name_en | Tiger |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 500 |
| cost_fuel | 200 |
| pop | 14 |
| build_time | 55s |
| hp | 1040 |
| armor_front | 极高（~220） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/指挥官 |
| speed | 中低 |
| damage | 极高（88mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 突击虎（Brummbar）
| 字段 | 值 |
|---|---|
| name_zh | 突击虎 |
| name_en | Brummbar |
| faction | Wehrmacht Ostheer |
| game | CoH2 |
| tier | T3（Schwere Panzer Korps） |
| built_from | Schwere Panzer Korps |
| cost_manpower | 400 |
| cost_fuel | 130 |
| pop | 12 |
| build_time | 50s |
| hp | 720 |
| armor_front | 高（~170） |
| armor_side | 中高（~100） |
| armor_rear | 中（~80） |
| tags | 车辆/突击炮/反步兵 |
| speed | 中低 |
| damage | 极高（150mm HE） |
| atk_type | HE |
| range | 中 |
| target | 步兵/建筑/驻防 |
| splash | 有（大面积） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.2.3 西线最高指挥部（Oberkommando West / OKW）

##### 突击工兵（Sturmpioneers）
| 字段 | 值 |
|---|---|
| name_zh | 突击工兵 |
| name_en | Sturmpioneers |
| faction | OKW |
| game | CoH2 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 250 |
| pop | 5 |
| build_time | 20s |
| hp | 60 × 4 |
| tags | 步兵/工兵/建造者/近战 |
| speed | 中 |
| damage | 中高（STG44） |
| atk_type | 突击步枪 |
| range | 中 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 国民掷弹兵（Volksgrenadiers）
| 字段 | 值 |
|---|---|
| name_zh | 国民掷弹兵 |
| name_en | Volksgrenadiers |
| faction | OKW |
| game | CoH2 |
| tier | T0（Battlegroup Headquarters） |
| built_from | Battlegroup Headquarters |
| cost_manpower | 250 |
| pop | 6 |
| build_time | 25s |
| hp | 52 × 5 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中（G43/Kar98k） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | STG44（弹药/2把）、Panzerschreck（弹药） |
| reinforce_cost | 25人力/模型 |
| active | 燃烧手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 上等兵（Obersoldaten）
| 字段 | 值 |
|---|---|
| name_zh | 上等兵 |
| name_en | Obersoldaten |
| faction | OKW |
| game | CoH2 |
| tier | T2（Schwere Panzer Headquarters） |
| built_from | Schwere Panzer Headquarters |
| cost_manpower | 400 |
| pop | 8 |
| build_time | 35s |
| hp | 72 × 4 |
| tags | 步兵/终极精锐 |
| speed | 中 |
| damage | 极高（MG34 LMG） |
| atk_type | 轻机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | MG34 LMG（弹药） |
| active | 隐蔽伏击 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 火箭发射器组（Raketenwerfer）
| 字段 | 值 |
|---|---|
| name_zh | 火箭发射器组 |
| name_en | Raketenwerfer |
| faction | OKW |
| game | CoH2 |
| tier | T1（Mechanized Headquarters） |
| built_from | Mechanized Headquarters |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 高 |
| atk_type | 反坦克火箭 |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| active | 隐蔽 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 猞猁轻型坦克（Luchs）
| 字段 | 值 |
|---|---|
| name_zh | 猞猁轻型坦克 |
| name_en | Luchs |
| faction | OKW |
| game | CoH2 |
| tier | T2（Schwere Panzer Headquarters） |
| built_from | Schwere Panzer Headquarters |
| cost_manpower | 320 |
| cost_fuel | 70 |
| pop | 8 |
| build_time | 35s |
| hp | 400 |
| armor_front | 中低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/轻型坦克/反步兵 |
| speed | 高 |
| damage | 中高（20mm 速射炮） |
| atk_type | 自动炮 |
| range | 中 |
| target | 步兵/轻装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 美洲狮（Puma）
| 字段 | 值 |
|---|---|
| name_zh | 美洲狮装甲车 |
| name_en | Puma |
| faction | OKW |
| game | CoH2 |
| tier | T2（Mechanized Headquarters） |
| built_from | Mechanized Headquarters |
| cost_manpower | 340 |
| cost_fuel | 80 |
| pop | 8 |
| build_time | 40s |
| hp | 480 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/侦察/反装甲 |
| speed | 高 |
| damage | 中高（50mm） |
| atk_type | AP |
| range | 中 |
| target | 轻装甲/步兵 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 豹式坦克（Panther, OKW）
| 字段 | 值 |
|---|---|
| name_zh | 豹式中型坦克 |
| name_en | Panther |
| faction | OKW |
| game | CoH2 |
| tier | T3（Schwere Panzer Headquarters） |
| built_from | Schwere Panzer Headquarters |
| cost_manpower | 460 |
| cost_fuel | 180 |
| pop | 12 |
| build_time | 55s |
| hp | 880 |
| armor_front | 极高（~200） |
| armor_side | 高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型中型坦克/反装甲 |
| speed | 中高 |
| damage | 高（75mm L/70） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 虎王坦克（King Tiger, OKW）
| 字段 | 值 |
|---|---|
| name_zh | 虎王重型坦克 |
| name_en | King Tiger |
| faction | OKW |
| game | CoH2 |
| tier | T4（一次性呼叫） |
| built_from | 呼叫入场（唯一） |
| cost_manpower | 720 |
| pop | 18 |
| build_time | — |
| hp | 1280 |
| armor_front | 极高（~240） |
| armor_side | 极高（~160） |
| armor_rear | 中高（~100） |
| tags | 车辆/超重型坦克 |
| speed | 低 |
| damage | 极高（88mm L/71） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 猎虎坦克歼击车（Jagdtiger）
| 字段 | 值 |
|---|---|
| name_zh | 猎虎坦克歼击车 |
| name_en | Jagdtiger |
| faction | OKW |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 600 |
| cost_fuel | 230 |
| pop | 18 |
| build_time | 60s |
| hp | 1280 |
| armor_front | 极高（~250） |
| armor_side | 极高（~160） |
| armor_rear | 中高（~100） |
| tags | 车辆/超重型坦克歼击车/指挥官 |
| speed | 低 |
| damage | 极高（128mm） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.2.4 美军（US Forces / CoH2 DLC）

##### 后方梯队（Rear Echelon Squad）
| 字段 | 值 |
|---|---|
| name_zh | 后方梯队小队 |
| name_en | Rear Echelon Squad |
| faction | US Forces |
| game | CoH2 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 170 |
| pop | 3 |
| build_time | 15s |
| hp | 48 × 3 |
| tags | 步兵/工兵/建造者 |
| squad_size | 3 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 步枪兵（Riflemen）
| 字段 | 值 |
|---|---|
| name_zh | 步枪兵小队 |
| name_en | Riflemen |
| faction | US Forces |
| game | CoH2 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 25s |
| hp | 52 × 5 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中（M1 Garand） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | BAR（弹药/2把）、Bazooka（弹药） |
| reinforce_cost | 28人力/模型 |
| active | 烟雾弹、手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 空降兵（Paratroopers）
| 字段 | 值 |
|---|---|
| name_zh | 空降兵小队 |
| name_en | Paratroopers |
| faction | US Forces |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 空降 |
| cost_manpower | 380 |
| pop | 8 |
| build_time | 35s |
| hp | 65 × 5 |
| tags | 步兵/精锐/空降 |
| speed | 中高 |
| damage | 中高（M1A1 Carbine） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵/轻装甲 |
| squad_size | 5 |
| weapon_upgrades | LMG（弹药）、Recoilless Rifle（弹药/反坦克） |
| active | 空降部署 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### .50 口径机枪组（.50 Cal Machine Gun）
| 字段 | 值 |
|---|---|
| name_zh | .50 口径机枪组 |
| name_en | .50 Cal Machine Gun |
| faction | US Forces |
| game | CoH2 |
| tier | T1（Weapons Support Center） |
| built_from | Weapons Support Center |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### 57mm 反坦克炮（57mm AT Gun）
| 字段 | 值 |
|---|---|
| name_zh | 57mm 反坦克炮 |
| name_en | 57mm AT Gun |
| faction | US Forces |
| game | CoH2 |
| tier | T1（Weapons Support Center） |
| built_from | Weapons Support Center |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 中高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 中高 |
| active | AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### M4 谢尔曼坦克（M4 Sherman, CoH2）
| 字段 | 值 |
|---|---|
| name_zh | M4 谢尔曼中型坦克 |
| name_en | M4 Sherman |
| faction | US Forces |
| game | CoH2 |
| tier | T2（Captain / Major） |
| built_from | Major |
| cost_manpower | 340 |
| cost_fuel | 110 |
| pop | 10 |
| build_time | 45s |
| hp | 640 |
| armor_front | 中（~110） |
| armor_side | 中低（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中高 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| active | 烟雾弹；车辆乘员可下车 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### M36 杰克逊坦克歼击车（M36 Jackson）
| 字段 | 值 |
|---|---|
| name_zh | M36 杰克逊坦克歼击车 |
| name_en | M36 Jackson |
| faction | US Forces |
| game | CoH2 |
| tier | T3（Major） |
| built_from | Major |
| cost_manpower | 350 |
| cost_fuel | 130 |
| pop | 12 |
| build_time | 45s |
| hp | 480 |
| armor_front | 中低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/坦克歼击车/反装甲 |
| speed | 高 |
| damage | 高（90mm） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### M26 潘兴坦克（M26 Pershing, CoH2）
| 字段 | 值 |
|---|---|
| name_zh | M26 潘兴重型坦克 |
| name_en | M26 Pershing |
| faction | US Forces |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 500 |
| cost_fuel | 200 |
| pop | 14 |
| build_time | 55s |
| hp | 960 |
| armor_front | 高（~180） |
| armor_side | 中高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/指挥官 |
| speed | 中 |
| damage | 高（90mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.2.5 英军（UK Forces / CoH2 DLC）

##### 皇家工兵（Royal Engineers）
| 字段 | 值 |
|---|---|
| name_zh | 皇家工兵 |
| name_en | Royal Engineers |
| faction | UK Forces |
| game | CoH2 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 200 |
| pop | 4 |
| build_time | 15s |
| hp | 48 × 3 |
| tags | 步兵/工兵/建造者 |
| squad_size | 3 |
| active | 建造/维修/工事 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 步兵班（Infantry Section, CoH2）
| 字段 | 值 |
|---|---|
| name_zh | 步兵班 |
| name_en | Infantry Section |
| faction | UK Forces |
| game | CoH2 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 25s |
| hp | 55 × 5 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中高（Lee-Enfield） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | Bren LMG（弹药）、PIAT（弹药）、狙击手（弹药） |
| reinforce_cost | 28人力/模型 |
| active | 隐蔽在掩体中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 突击队（Commandos）
| 字段 | 值 |
|---|---|
| name_zh | 突击队 |
| name_en | Commandos |
| faction | UK Forces |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 空降/呼叫入场 |
| cost_manpower | 400 |
| pop | 8 |
| build_time | 35s |
| hp | 65 × 5 |
| tags | 步兵/精锐/突击 |
| speed | 中高 |
| damage | 高（Sten SMG） |
| atk_type | 冲锋枪 |
| range | 近 |
| target | 步兵 |
| squad_size | 5 |
| active | 隐蔽伏击；手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 维克斯机枪组（Vickers HMG）
| 字段 | 值 |
|---|---|
| name_zh | 维克斯重机枪组 |
| name_en | Vickers HMG |
| faction | UK Forces |
| game | CoH2 |
| tier | T1 |
| built_from | — |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### 6 磅反坦克炮（6-pounder AT Gun）
| 字段 | 值 |
|---|---|
| name_zh | 6 磅反坦克炮 |
| name_en | 6-pounder AT Gun |
| faction | UK Forces |
| game | CoH2 |
| tier | T2 |
| built_from | — |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 中高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 克伦威尔坦克（Cromwell, CoH2）
| 字段 | 值 |
|---|---|
| name_zh | 克伦威尔巡航坦克 |
| name_en | Cromwell |
| faction | UK Forces |
| game | CoH2 |
| tier | T2（Anvil） |
| built_from | — |
| cost_manpower | 340 |
| cost_fuel | 110 |
| pop | 10 |
| build_time | 45s |
| hp | 560 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/中型坦克/通用 |
| speed | 高 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 谢尔曼萤火虫（Sherman Firefly, CoH2）
| 字段 | 值 |
|---|---|
| name_zh | 谢尔曼萤火虫 |
| name_en | Sherman Firefly |
| faction | UK Forces |
| game | CoH2 |
| tier | T2（Anvil） |
| built_from | — |
| cost_manpower | 380 |
| cost_fuel | 140 |
| pop | 12 |
| build_time | 50s |
| hp | 560 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/中型坦克/反装甲 |
| speed | 中 |
| damage | 高（17磅炮） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 重装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 丘吉尔坦克（Churchill, CoH2）
| 字段 | 值 |
|---|---|
| name_zh | 丘吉尔步兵坦克 |
| name_en | Churchill |
| faction | UK Forces |
| game | CoH2 |
| tier | 指挥官 |
| built_from | 呼叫入场 |
| cost_manpower | 450 |
| cost_fuel | 170 |
| pop | 13 |
| build_time | 50s |
| hp | 1000 |
| armor_front | 高（~180） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型步兵坦克/指挥官 |
| speed | 低 |
| damage | 中（6磅炮） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装甲+ |

##### 彗星坦克（Comet）
| 字段 | 值 |
|---|---|
| name_zh | 彗星巡航坦克 |
| name_en | Comet |
| faction | UK Forces |
| game | CoH2 |
| tier | T3（Anvil） |
| built_from | — |
| cost_manpower | 480 |
| cost_fuel | 175 |
| pop | 13 |
| build_time | 55s |
| hp | 800 |
| armor_front | 高（~160） |
| armor_side | 中高（~100） |
| armor_rear | 中（~80） |
| tags | 车辆/重型巡航坦克/通用 |
| speed | 中高 |
| damage | 高（77mm HV） |
| atk_type | AP/HE |
| range | 中远 |
| target | 步兵/装甲 |
| penetration | 高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

### 3.3 Company of Heroes 3

#### 3.3.1 美军（US Forces / CoH3）

##### 工兵（Engineers）
| 字段 | 值 |
|---|---|
| name_zh | 工兵小队 |
| name_en | Engineers |
| faction | US Forces |
| game | CoH3 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 170 |
| pop | 3 |
| build_time | 15s |
| hp | 48 × 3 |
| tags | 步兵/工兵/建造者 |
| squad_size | 3 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 步枪兵（Riflemen, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 步枪兵小队 |
| name_en | Riflemen |
| faction | US Forces |
| game | CoH3 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 25s |
| hp | 52 × 5 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中（M1 Garand） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | BAR（弹药）、Bazooka（弹药） |
| reinforce_cost | 28人力/模型 |
| active | 手雷（弹药）、烟雾弹 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 探路者（Pathfinders）
| 字段 | 值 |
|---|---|
| name_zh | 探路者 |
| name_en | Pathfinders |
| faction | US Forces |
| game | CoH3 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 50 × 3 |
| tags | 步兵/侦察/狙击 |
| speed | 中高 |
| vision | 高 |
| damage | 中高（M1903 Springfield） |
| atk_type | 枪械/狙击 |
| range | 远 |
| target | 步兵 |
| squad_size | 3 |
| active | 隐蔽；标记目标 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 视野+ |

##### 空降兵（Paratroopers, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 空降兵小队 |
| name_en | Paratroopers |
| faction | US Forces |
| game | CoH3 |
| tier | 战斗群（Airborne） |
| built_from | 空降 |
| cost_manpower | 380 |
| pop | 8 |
| build_time | 35s |
| hp | 65 × 5 |
| tags | 步兵/精锐/空降 |
| speed | 中高 |
| damage | 中高 |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵/轻装甲 |
| squad_size | 5 |
| weapon_upgrades | LMG（弹药）、Recoilless Rifle（弹药） |
| active | 空降部署 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### .30 口径机枪组（.30 Cal HMG, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | .30 口径机枪组 |
| name_en | .30 Cal HMG |
| faction | US Forces |
| game | CoH3 |
| tier | T1（Weapons Support Center） |
| built_from | Weapons Support Center |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### M4 谢尔曼坦克（M4 Sherman, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | M4 谢尔曼中型坦克 |
| name_en | M4 Sherman |
| faction | US Forces |
| game | CoH3 |
| tier | T2（Motor Pool） |
| built_from | Motor Pool |
| cost_manpower | 340 |
| cost_fuel | 100 |
| pop | 10 |
| build_time | 45s |
| hp | 640 |
| armor_front | 中（~110） |
| armor_side | 中低（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中高 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| active | 烟雾弹；车辆乘员可下车 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### M18 地狱猫坦克歼击车（M18 Hellcat）
| 字段 | 值 |
|---|---|
| name_zh | M18 地狱猫坦克歼击车 |
| name_en | M18 Hellcat |
| faction | US Forces |
| game | CoH3 |
| tier | T2（Motor Pool） |
| built_from | Motor Pool |
| cost_manpower | 320 |
| cost_fuel | 100 |
| pop | 10 |
| build_time | 40s |
| hp | 400 |
| armor_front | 极低 |
| armor_side | 极低 |
| armor_rear | 极低 |
| tags | 车辆/坦克歼击车/反装甲 |
| speed | 极高 |
| vision | 中 |
| damage | 高（76mm） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 装甲 |
| active | 隐蔽伏击（Ambush）；速度爆发 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### M4A3E8 易八坦克（M4A3E8 Easy Eight）
| 字段 | 值 |
|---|---|
| name_zh | M4A3E8 易八中型坦克 |
| name_en | M4A3E8 Easy Eight |
| faction | US Forces |
| game | CoH3 |
| tier | T3 / 战斗群 |
| built_from | Motor Pool / 战斗群 |
| cost_manpower | 400 |
| cost_fuel | 130 |
| pop | 12 |
| build_time | 50s |
| hp | 720 |
| armor_front | 中高（~130） |
| armor_side | 中（~90） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/升级型 |
| speed | 中高 |
| damage | 高（76mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### M26 潘兴坦克（M26 Pershing, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | M26 潘兴重型坦克 |
| name_en | M26 Pershing |
| faction | US Forces |
| game | CoH3 |
| tier | 战斗群（Armor） |
| built_from | 呼叫入场 |
| cost_manpower | 500 |
| cost_fuel | 200 |
| pop | 14 |
| build_time | 55s |
| hp | 960 |
| armor_front | 高（~180） |
| armor_side | 中高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/战斗群 |
| speed | 中 |
| damage | 高（90mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.3.2 国防军（Wehrmacht / CoH3）

##### 先锋队（Pioneers, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 先锋队 |
| name_en | Pioneers |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 200 |
| pop | 4 |
| build_time | 15s |
| hp | 48 × 2 |
| tags | 步兵/工兵/建造者 |
| squad_size | 2 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 掷弹兵（Grenadiers, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 掷弹兵 |
| name_en | Grenadiers |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 260 |
| pop | 6 |
| build_time | 25s |
| hp | 52 × 4 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中高（Kar98k） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | MG42 LMG（弹药）、Panzerschreck（弹药） |
| reinforce_cost | 27人力/模型 |
| active | 步枪手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 装甲掷弹兵（Panzergrenadiers, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 装甲掷弹兵 |
| name_en | Panzergrenadiers |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T2（Sturm Armory） |
| built_from | Sturm Armory |
| cost_manpower | 340 |
| pop | 7 |
| build_time | 30s |
| hp | 60 × 4 |
| tags | 步兵/精锐/突击 |
| speed | 中高 |
| damage | 高（STG44） |
| atk_type | 突击步枪 |
| range | 中 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | Panzerschreck（弹药） |
| active | 冲锋 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### MG42 重机枪组（MG42 HMG, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | MG42 重机枪组 |
| name_en | MG42 HMG |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T1（Barracks） |
| built_from | Barracks |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/极高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### Pak 40 反坦克炮（Pak 40, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | Pak 40 75mm 反坦克炮 |
| name_en | Pak 40 |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T2（Sturm Armory） |
| built_from | Sturm Armory |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| active | 隐蔽 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 四号坦克（Panzer IV, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 四号中型坦克 |
| name_en | Panzer IV |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T3（Panzer Command） |
| built_from | Panzer Command |
| cost_manpower | 360 |
| cost_fuel | 110 |
| pop | 10 |
| build_time | 45s |
| hp | 640 |
| armor_front | 中高（~140） |
| armor_side | 中（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 豹式坦克（Panther, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 豹式中型坦克 |
| name_en | Panther |
| faction | Wehrmacht |
| game | CoH3 |
| tier | T4（Panzer Command） |
| built_from | Panzer Command |
| cost_manpower | 460 |
| cost_fuel | 175 |
| pop | 12 |
| build_time | 55s |
| hp | 880 |
| armor_front | 极高（~200） |
| armor_side | 高（~120） |
| armor_rear | 中（~80） |
| tags | 车辆/重型中型坦克/反装甲 |
| speed | 中高 |
| damage | 高（75mm L/70） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 虎式坦克（Tiger, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 虎式重型坦克 |
| name_en | Tiger |
| faction | Wehrmacht |
| game | CoH3 |
| tier | 战斗群 |
| built_from | 呼叫入场 |
| cost_manpower | 500 |
| cost_fuel | 200 |
| pop | 14 |
| build_time | 55s |
| hp | 1040 |
| armor_front | 极高（~220） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/战斗群 |
| speed | 中低 |
| damage | 极高（88mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

---

#### 3.3.3 英军（British / CoH3）

##### 皇家工兵（Royal Engineers, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 皇家工兵 |
| name_en | Royal Engineers |
| faction | British |
| game | CoH3 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 200 |
| pop | 4 |
| build_time | 15s |
| hp | 48 × 3 |
| tags | 步兵/工兵/建造者 |
| squad_size | 3 |
| active | 建造/维修/工事 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 步兵班（Infantry Section, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 步兵班 |
| name_en | Infantry Section |
| faction | British |
| game | CoH3 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 25s |
| hp | 55 × 5 |
| tags | 步兵/核心 |
| speed | 中 |
| damage | 中高（Lee-Enfield） |
| atk_type | 枪械 |
| range | 中远 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | Bren LMG（弹药）、PIAT（弹药） |
| reinforce_cost | 28人力/模型 |
| active | 隐蔽在掩体中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 廓尔喀兵（Gurkhas）
| 字段 | 值 |
|---|---|
| name_zh | 廓尔喀兵 |
| name_en | Gurkhas |
| faction | British |
| game | CoH3 |
| tier | 战斗群（Gurkha） |
| built_from | 呼叫入场 |
| cost_manpower | 400 |
| pop | 8 |
| build_time | 35s |
| hp | 70 × 5 |
| tags | 步兵/精锐/近战 |
| speed | 中高 |
| damage | 高（冲锋枪 + Khukri 弯刀） |
| atk_type | 冲锋枪/近战 |
| range | 近 |
| target | 步兵 |
| squad_size | 5 |
| active | 隐蔽伏击；手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 突击队（Commandos, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 突击队 |
| name_en | Commandos |
| faction | British |
| game | CoH3 |
| tier | 战斗群（Commando） |
| built_from | 呼叫入场 |
| cost_manpower | 380 |
| pop | 8 |
| build_time | 35s |
| hp | 65 × 5 |
| tags | 步兵/精锐/突击 |
| speed | 中高 |
| damage | 高（Sten SMG） |
| atk_type | 冲锋枪 |
| range | 近 |
| target | 步兵 |
| squad_size | 5 |
| active | 隐蔽伏击 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 维克斯机枪组（Vickers HMG, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 维克斯重机枪组 |
| name_en | Vickers HMG |
| faction | British |
| game | CoH3 |
| tier | T1 |
| built_from | — |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### 6 磅反坦克炮（6-pounder, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 6 磅反坦克炮 |
| name_en | 6-pounder AT Gun |
| faction | British |
| game | CoH3 |
| tier | T2 |
| built_from | — |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 30s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/反坦克 |
| damage | 中高 |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 斯图亚特轻型坦克（Stuart, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 斯图亚特轻型坦克 |
| name_en | Stuart |
| faction | British |
| game | CoH3 |
| tier | T1 |
| built_from | — |
| cost_manpower | 280 |
| cost_fuel | 45 |
| pop | 6 |
| build_time | 35s |
| hp | 400 |
| armor_front | 中低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/轻型坦克/侦察 |
| speed | 高 |
| damage | 中（37mm） |
| atk_type | 穿甲弹 |
| range | 中 |
| target | 轻装甲/步兵 |
| active | 霰弹射击（Canister Shot，弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 十字军坦克（Crusader）
| 字段 | 值 |
|---|---|
| name_zh | 十字军巡航坦克 |
| name_en | Crusader |
| faction | British |
| game | CoH3 |
| tier | T2 |
| built_from | — |
| cost_manpower | 300 |
| cost_fuel | 70 |
| pop | 8 |
| build_time | 35s |
| hp | 400 |
| armor_front | 中低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/巡航坦克/侦察 |
| speed | 极高 |
| damage | 中（2磅炮） |
| atk_type | AP |
| range | 中 |
| target | 轻装甲/步兵 |
| penetration | 中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 克伦威尔坦克（Cromwell, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 克伦威尔巡航坦克 |
| name_en | Cromwell |
| faction | British |
| game | CoH3 |
| tier | T2 |
| built_from | — |
| cost_manpower | 340 |
| cost_fuel | 100 |
| pop | 10 |
| build_time | 45s |
| hp | 560 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/中型坦克/通用 |
| speed | 高 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 谢尔曼萤火虫（Sherman Firefly, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 谢尔曼萤火虫 |
| name_en | Sherman Firefly |
| faction | British |
| game | CoH3 |
| tier | T3 |
| built_from | — |
| cost_manpower | 380 |
| cost_fuel | 140 |
| pop | 12 |
| build_time | 50s |
| hp | 560 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/中型坦克/反装甲 |
| speed | 中 |
| damage | 高（17磅炮） |
| atk_type | AP |
| range | 中远 |
| target | 装甲 |
| penetration | 高 |
| bonus_vs | 重装甲 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 玛蒂尔达坦克（Matilda）
| 字段 | 值 |
|---|---|
| name_zh | 玛蒂尔达步兵坦克 |
| name_en | Matilda |
| faction | British |
| game | CoH3 |
| tier | T2 / 战斗群 |
| built_from | — |
| cost_manpower | 400 |
| cost_fuel | 120 |
| pop | 12 |
| build_time | 45s |
| hp | 900 |
| armor_front | 高（~180） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型步兵坦克 |
| speed | 低 |
| damage | 中（2磅炮） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装甲+ |

##### 丘吉尔坦克（Churchill, CoH3）
| 字段 | 值 |
|---|---|
| name_zh | 丘吉尔步兵坦克 |
| name_en | Churchill |
| faction | British |
| game | CoH3 |
| tier | 战斗群 / T3 |
| built_from | — |
| cost_manpower | 450 |
| cost_fuel | 170 |
| pop | 13 |
| build_time | 50s |
| hp | 1000 |
| armor_front | 高（~180） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型步兵坦克 |
| speed | 低 |
| damage | 中高（6磅炮/75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 装甲+ |

---

#### 3.3.4 德意志非洲军团（Deutsches Afrikakorps / DAK）

##### 先锋队（Pioneers, DAK）
| 字段 | 值 |
|---|---|
| name_zh | 先锋队 |
| name_en | Pioneers |
| faction | DAK |
| game | CoH3 |
| tier | T0（HQ） |
| built_from | Headquarters |
| cost_manpower | 200 |
| pop | 4 |
| build_time | 15s |
| hp | 48 × 2 |
| tags | 步兵/工兵/建造者 |
| squad_size | 2 |
| weapon_upgrades | 喷火器（弹药） |
| active | 建造/维修/布雷/拆雷 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 装甲掷弹兵（Panzergrenadiers, DAK）
| 字段 | 值 |
|---|---|
| name_zh | 装甲掷弹兵 |
| name_en | Panzergrenadiers |
| faction | DAK |
| game | CoH3 |
| tier | T0（Barracks） |
| built_from | Barracks |
| cost_manpower | 280 |
| pop | 6 |
| build_time | 25s |
| hp | 55 × 4 |
| tags | 步兵/核心 |
| speed | 中高 |
| damage | 中高（Kar98k + G43） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 4 |
| weapon_upgrades | MG34 LMG（弹药）、Panzerschreck（弹药） |
| reinforce_cost | 28人力/模型 |
| active | 步枪手雷（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 贝尔萨格里里（Bersaglieri）
| 字段 | 值 |
|---|---|
| name_zh | 贝尔萨格里里 |
| name_en | Bersaglieri |
| faction | DAK |
| game | CoH3 |
| tier | T1（Barracks） |
| built_from | Barracks |
| cost_manpower | 260 |
| pop | 6 |
| build_time | 25s |
| hp | 50 × 5 |
| tags | 步兵/机动侦察/意大利 |
| speed | 高 |
| vision | 高 |
| damage | 中（Carcano 步枪） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| squad_size | 5 |
| weapon_upgrades | Breda LMG（弹药） |
| active | 速度增强；标记目标 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 突击工兵（Guastatori）
| 字段 | 值 |
|---|---|
| name_zh | 突击工兵 |
| name_en | Guastatori |
| faction | DAK |
| game | CoH3 |
| tier | T1 |
| built_from | — |
| cost_manpower | 300 |
| pop | 6 |
| build_time | 30s |
| hp | 60 × 4 |
| tags | 步兵/突击/意大利/近战 |
| speed | 中高 |
| damage | 高（冲锋枪 + 火焰） |
| atk_type | 冲锋枪/喷火 |
| range | 近 |
| target | 步兵/驻防 |
| squad_size | 4 |
| active | 喷火器；炸药包 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### MG34 重机枪组（MG34 HMG）
| 字段 | 值 |
|---|---|
| name_zh | MG34 重机枪组 |
| name_en | MG34 HMG |
| faction | DAK |
| game | CoH3 |
| tier | T1 |
| built_from | — |
| cost_manpower | 260 |
| pop | 5 |
| build_time | 25s |
| hp | 48 × 3 |
| tags | 步兵/支援武器/压制 |
| damage | 中低单发/高持续 |
| atk_type | 重机枪 |
| range | 中远 |
| target | 步兵 |
| squad_size | 3 |
| active | 压制射击、AP 弹药（弹药） |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 压制+ |

##### 三号坦克（Panzer III）
| 字段 | 值 |
|---|---|
| name_zh | 三号中型坦克 |
| name_en | Panzer III |
| faction | DAK |
| game | CoH3 |
| tier | T2 |
| built_from | — |
| cost_manpower | 320 |
| cost_fuel | 80 |
| pop | 8 |
| build_time | 40s |
| hp | 560 |
| armor_front | 中（~100） |
| armor_side | 中低（~70） |
| armor_rear | 低（~50） |
| tags | 车辆/中型坦克/通用 |
| speed | 中高 |
| damage | 中（50mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/轻装甲 |
| penetration | 中 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### 四号坦克（Panzer IV, DAK）
| 字段 | 值 |
|---|---|
| name_zh | 四号中型坦克 |
| name_en | Panzer IV |
| faction | DAK |
| game | CoH3 |
| tier | T3 |
| built_from | — |
| cost_manpower | 380 |
| cost_fuel | 110 |
| pop | 10 |
| build_time | 45s |
| hp | 640 |
| armor_front | 中高（~140） |
| armor_side | 中（~80） |
| armor_rear | 低（~60） |
| tags | 车辆/中型坦克/通用 |
| speed | 中 |
| damage | 中高（75mm） |
| atk_type | AP/HE |
| range | 中 |
| target | 步兵/装甲 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### 88mm 高射炮（88mm Flak 36）
| 字段 | 值 |
|---|---|
| name_zh | 88mm Flak 36 高射炮 |
| name_en | 88mm Flak 36 |
| faction | DAK |
| game | CoH3 |
| tier | T2+ |
| built_from | 先锋队建造 |
| cost_manpower | 300 |
| cost_fuel | 40 |
| pop | 8 |
| build_time | 50s |
| hp | 400 |
| tags | 建筑/反坦克/AA/静态 |
| damage | 极高 |
| atk_type | AP/AA |
| range | 中远 |
| target | 装甲/飞机 |
| penetration | 极高 |
| vet_upgrades | — |

##### 虎式坦克（Tiger, DAK）
| 字段 | 值 |
|---|---|
| name_zh | 虎式重型坦克 |
| name_en | Tiger |
| faction | DAK |
| game | CoH3 |
| tier | 战斗群 / T4 |
| built_from | 呼叫入场 |
| cost_manpower | 500 |
| cost_fuel | 200 |
| pop | 14 |
| build_time | 55s |
| hp | 1040 |
| armor_front | 极高（~220） |
| armor_side | 高（~140） |
| armor_rear | 中（~80） |
| tags | 车辆/重型坦克/战斗群 |
| speed | 中低 |
| damage | 极高（88mm） |
| atk_type | AP/HE |
| range | 中远 |
| target | 装甲/步兵 |
| penetration | 极高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 伤害+ |

##### Sdkfz 234 美洲狮（8-Rad / Puma, DAK）
| 字段 | 值 |
|---|---|
| name_zh | Sdkfz 234 美洲狮 |
| name_en | 8-Rad / Puma |
| faction | DAK |
| game | CoH3 |
| tier | T2 |
| built_from | — |
| cost_manpower | 320 |
| cost_fuel | 60 |
| pop | 8 |
| build_time | 35s |
| hp | 440 |
| armor_front | 中 |
| armor_side | 中低 |
| armor_rear | 低 |
| tags | 车辆/侦察/反装甲 |
| speed | 极高 |
| vision | 高 |
| damage | 中高（50mm） |
| atk_type | AP |
| range | 中 |
| target | 轻装甲/步兵 |
| penetration | 中高 |
| vet_upgrades | Vet1: 精度+; Vet2: HP+; Vet3: 速度+ |

##### Sdkfz 250 半履带车（Sdkfz 250）
| 字段 | 值 |
|---|---|
| name_zh | Sdkfz 250 半履带车 |
| name_en | Sdkfz 250 |
| faction | DAK |
| game | CoH3 |
| tier | T1 |
| built_from | — |
| cost_manpower | 240 |
| cost_fuel | 30 |
| pop | 6 |
| build_time | 30s |
| hp | 320 |
| armor_front | 低 |
| armor_side | 低 |
| armor_rear | 极低 |
| tags | 车辆/运输/支援/半履带 |
| speed | 高 |
| damage | 低（车载机枪） |
| atk_type | 枪械 |
| range | 中 |
| target | 步兵 |
| active | 运输步兵；提供 buff |
| vet_upgrades | Vet1: HP+; Vet2: 速度+; Vet3: 伤害+ |

---

## 附录：阵营速查表

### CoH1 阵营总览

| 阵营 | 核心特征 | 指挥树 | 终极单位 |
|---|---|---|---|
| Americans | 机动合成兵种 | Infantry / Armor / Airborne | M26 Pershing |
| Wehrmacht | 精锐高效 | Defensive / Blitzkrieg / Terror | Tiger, King Tiger |
| British | 阵地工事 | Royal Artillery / Royal Commandos / Royal Engineers | Churchill, 25-pdr |
| Panzer Elite | 装甲突击 | Scorched Earth / Luftwaffe / Tank Hunter | Jagdpanther |

### CoH2 阵营总览

| 阵营 | 核心特征 | 终极单位 |
|---|---|---|
| Soviet | 人海/合并 | IS-2, ISU-152 |
| Wehrmacht Ostheer | 精锐阵地 | Tiger, Panther |
| OKW | 高科技/资源惩罚 | King Tiger, Jagdtiger |
| US Forces | 机动/车辆乘员 | M26 Pershing, Easy Eight |
| UK Forces | 阵地/Section 升级 | Comet, Churchill |

### CoH3 阵营总览

| 阵营 | 核心特征 | 战斗群 | 终极单位 |
|---|---|---|---|
| US Forces | 进攻机动 | Airborne / Armor / Infantry / Spec Ops | M26 Pershing |
| Wehrmacht | 精锐阵地 | Mechanized / Defense / Breakthrough / Luftwaffe | Tiger |
| British | 方法性推进 | Indian Artillery / Armored / Gurkha / Commando | Churchill, Matilda |
| DAK | 机动装甲战 | Armor / Infantry / Luftwaffe / Mechanized | Tiger, 88mm Flak |

---

## 数据说明

1. **HP 值**：步兵为「单模型 HP × 小队人数」；车辆为总 HP。实际游戏中不同版本可能有微调。
2. **装甲值**：标注为近似值（带 ~ 号），实际游戏中装甲值有浮动区间。步兵无装甲值，但有受击修正。
3. **穿甲值**：武器穿甲值 vs 目标装甲值决定穿透概率，通常为概率判定而非绝对值。
4. **资源消耗**：以标准 1v1 模式为基准，不同模式可能有调整。指挥树/战斗群呼叫的单位可能不需要燃料，只消耗人力。
5. **老练度（Veterancy）**：所有阵营通过战斗获得经验升级（CoH1 国防军可通过基地购买全局 Veterancy）。每级提供不同 buff。
6. **Pop（人口）**：每个单位占用的人口值，总人口上限通常为 100。
7. **缺失数据（—）**：表示该字段在当前版本中不适用、数据不可靠或变动较大。

---

> 本文档基于 CoH 系列 wiki 和社区数据编写，用于 RTS 游戏设计参考。如需精确数值，请参考游戏内数据浏览器或最新版本的社区 wiki。