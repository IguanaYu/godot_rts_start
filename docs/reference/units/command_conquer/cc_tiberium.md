# 命令与征服：泰伯利亚系列单位数据

> 数据源: Liquipedia + fandom (采集时网络工具受限，部分数据来自训练知识) / 采集日期: 2026-06-17
> 游戏覆盖: Tiberian Sun (1999) / Tiberium Wars (2007) / Kane's Wrath (2008)
> 注: 部分数值为近似值，参考官方 wiki 数据范围。TW 与 KW 共享同一引擎，单位数据基本一致，KW 在 TW 基础上新增 Epic 单位、子阵营特化单位与若干变体。

---

## 第一部分：阵营设计分析

### 一、GDI（全球防御倡议）

#### 1. 设计哲学
**"科技重装正面碾压"** —— 以质量换数量，用最厚重的装甲、最先进的轨道武器（railgun/sonic）和最强大的战略打击（Ion Cannon）通过正面战场把对手碾碎。GDI 是"慢但不可阻挡"的暴力派。

#### 2. 核心签名机制
- **MCV 建造场系统**：建筑直接在地图上落地展开，不需要建造队列外溢；MCV 可重新打包移动。
- **Ion Cannon（离子炮）**：GDI 专属超级武器，从 Space Command Uplink 发射天基能量束，对单点毁灭打击，是 GDI 后期战略威胁的基石。
- **Railgun（轨道炮）**：T3 阶段武器升级，Zone Trooper、Mammoth Tank（升级后）、Juggernaut 等单位使用，无视常规装甲折减。
- **Sonic 武器**（TW/KW）：Sonic Emitter 防御塔、Shatterer（KW）使用声波，对直线群体目标高效。
- **轨道空投**：TW/KW 中 GDI 可用 Orca 携带、Ox 运输机投放步兵和轻载具，机动突袭。

#### 3. 角色分工矩阵

| Tier | 步兵 | 载具 | 空军 | 超级武器 |
|---|---|---|---|---|
| T1 | Rifleman Squad / Missile Squad | Pitbull / Predator Tank | — | — |
| T1.5 | Engineer / Grenadier | APC / Harvester | — | — |
| T2 | Sniper Team | Juggernaut / Rig | Orca | — |
| T3 | Zone Trooper / Commando | Mammoth Tank | Firehawk | Ion Cannon |
| Epic (KW) | — | MARV | — | — |

#### 4. 科技树节奏
GDI 节奏**稳健但偏慢**：
- T1→T2：Barracks → War Factory → Command Post（500-2000 credits），约 2-3 分钟。
- T2→T3：Tech Center（2000）+ Armory（1000）解锁 Zone Trooper / Mammoth / Firehawk，约 5-6 分钟。
- 超武：Space Command Uplink（3000）需 Tech Center 前置，约 8-10 分钟。
- GDI 的核心问题：T2 之前对 NOD 的快攻骚扰（Attack Bike / Shadow Team）非常脆弱。

#### 5. 核心协同组合
1. **Pitbull + Predator**：T1 标准搭配，Pitbull 侦察/反步兵+AA，Predator 正面输出。
2. **Zone Trooper + Juggernaut**：Zone Trooper 反载具+反步兵，Juggernaut 远程拆家/压制。
3. **Mammoth Tank + Rig**：Rig 展开为修理+防御塔阵地，Mammoth 推线。
4. **Orca + Firehawk**：Orca 反载具/骚扰，Firehawk 切换 AA/AG 模式打击超武或基地。
5. **Sniper Team + Grenadier**：反步兵组合，Sniper 点杀英雄/重步兵，Grenadier 清轻步兵+拆建筑。
6. **Engineer + APC + Ox 空投**：APC 装工程师，配合 Ox 快速投放到敌方基地后方抢建筑。
7. **Ion Cannon + 地面推进**：先 Ion Cannon 摧毁关键防御/超武，然后地面部队一波。

#### 6. 生产机制
- **建造场系统（Construction Yard System）**：MCV 展开为 Construction Yard，可建造各类建筑，建筑在地图上实体放置，受地形限制。
- 每类生产建筑（Barracks / War Factory / Airfield）可独立排队生产，多建同类型建筑可加速生产。
- TW/KW 中保留这套系统，没有引入 RA3 的"双轨制"或"Crawler"系统（那是 C&C4 的事）。

#### 7. 机动哲学
**"重装甲慢速推进 + 精锐快速突袭"** 双轨：
- 主力线（Mammoth / Predator / Juggernaut）机动慢，依赖 Rig 修车与正面阵型。
- 突袭线（Pitbull / Firehawk / Zone Trooper 跳跃包）机动快，用于骚扰经济、打击超武。
- 运输：APC 载步兵，Ox 空投，Carryall（TS）搬运载具。

#### 8. 视野与地图控制
- Pitbull（T1）是核心侦察单位，速度快、视野广、带 AA。
- Command Post 提供雷达，Tech Center 后可升级传感器。
- Watchtower（防御塔）提供基地周边视野。
- 弱点：地图中段视野依赖主动出击，被动防御视野一般。

#### 9. 反制弱点
- **前期慢**：T1/T2 之前缺乏快速反应单位，对 NOD 骚扰（Attack Bike / Shadow Team / Venom）极敏感。
- **造价高**：Mammoth 2000 credits、Zone Trooper 1300、Firehawk 1500，单位经济压力大。
- **怕隐身**：NOD Stealth Tank、Shadow Team、Vertigo 在 GDI 没有足够侦察能力前可造成巨大破坏。
- **怕拆经济**：NOD 的 Tiberium Vapor Bomb、Scrin 的 Buzzers 可快速清掉 GDI 经济线。

#### 10. 强势时间窗
- **T2 中期**（约 4-6 分钟）：Predator + APC + Grenadier 推进，NOD 此时还没到 Avatar/Stealth Tank 成型。
- **T3 初期**（约 7-9 分钟）：Mammoth Tank 刚出时几乎无敌，Zone Trooper + Juggernaut 推进。
- **超武后**：Ion Cannon 打掉对手超武后，GDI 一波终局。

#### 11. 经济模型
- **泰矿采集（Tiberium Harvesting）**：Harvester 从 Tiberium Field 采集，运回 Refinery 提炼为 credits。
- TS：Tiberium 为可见晶体，Harvester 直接采集；Tiberium 会扩散和变异地形。
- TW/KW：Tiberium Field 为固定绿/蓝晶体区域，Harvester 自动采集。蓝泰矿价值更高。
- Refinery 造价 3000 credits（TW/KW），一次性投入大；每 Refinery 配 1 Harvester。
- 经济压力点：GDI 单价高，每损失一个 Mammoth 等于 2000 credits，需要稳定经济流。

---

### 二、NOD（Nod 兄弟会）

#### 1. 设计哲学
**"隐形不对称作战"** —— 用速度、隐身、欺骗和火焰把对手拖入混乱。NOD 永远不会和 GDI 正面硬刚，而是用最小代价制造最大破坏，"打不过就跑，跑完再回来"。

#### 2. 核心签名机制
- **隐身（Stealth）**：Stealth Tank、Shadow Team、Vertigo 可隐身；Disruption Tower 生成基地隐身场。NOD 的核心叙事是"你看不见我"。
- **地下（Subterranean）**（TS + KW 部分单位）：Devil's Tongue、Subterranean APC（TS）、Flame Tank（TW 可钻地）可穿越地形从地下突袭。
- **核武器（Nuclear Missile）**：Temple of Nod 发射战术核弹，是 NOD 的战略威胁。
- **Tiberium 武器**：Tiberium Vapor Bomb（TW）污染区域，Vapor Bomb 对经济和步兵毁灭性。
- **Avatar 拾取升级**（TW/KW）：Avatar Warmech 可从被摧毁的友方载具上拾取武器部件，自定义升级（如加 Stealth Tank 隐身、Beam Cannon 射程、Flame Tank 喷火器）。

#### 3. 角色分工矩阵

| Tier | 步兵 | 载具 | 空军 | 超级武器 |
|---|---|---|---|---|
| T1 | Militant Squad / Militant Rocket Squad | Attack Bike / Scorpion Tank | — | — |
| T1.5 | Saboteur / Fanatic | Raider Buggy / Harvester | — | — |
| T2 | Black Hand / Shadow Team | Flame Tank / Beam Cannon / Stealth Tank | Venom | Vapor Bomb (Air Tower 技能) |
| T3 | Confessor Cabal / Commando | Avatar Warmech | Vertigo | Nuclear Missile |
| Epic (KW) | — | Redeemer / Purifier (Black Hand) | — | — |

#### 4. 科技树节奏
NOD 节奏**前快后稳**：
- T1→T2：Hand of Nod → War Factory → Operations Center（1500），约 2 分钟。Attack Bike 几乎开局就可骚扰。
- T2→T3：Tech Lab（2000）解锁 Avatar / Vertigo / Commando，约 5-6 分钟。
- 超武：Temple of Nod（3000），约 8-10 分钟。
- NOD 的优势：早期骚扰能力极强，可在 GDI/Scrin 经济成型前施压。

#### 5. 核心协同组合
1. **Attack Bike + Scorpion Tank**：T1 标准快攻，Bike 反步兵+AA，Scorpion 正面。
2. **Shadow Team + Beam Cannon**：Shadow Team 隐身侦察+标记，Beam Cannon 远程拆建筑。
3. **Flame Tank + Black Hand**：Flame Tank 拆建筑+清步兵，Black Hand 反步兵+反建筑，"火焰双煞"。
4. **Stealth Tank + Avatar**：Stealth Tank 隐身偷袭经济，Avatar 正面或侧翼输出。
5. **Vertigo + Venom**：Venom 制空+反载具，Vertigo 隐身轰炸关键目标（超武/Tech Center）。
6. **Confessor Cabal + 任意步兵**：Confessor 给附近友军步兵加成 buff。
7. **Nuke + Avatar 推进**：Nuke 清掉防御/超武，Avatar 一波终结。

#### 6. 生产机制
- **建造场系统**：与 GDI 相同的 MCV → Construction Yard 模式。
- 关键差异：NOD 建筑普遍更便宜（Hand of Nod 500 vs Barracks 500 持平，但 War Factory 2000 vs GDI 2000 也持平，真正差异在单位造价）。
- TW/KW 中 NOD 的 Foundry（1500）作为前哨展开点，比 GDI 的 Surveyor 略便宜。
- Disruption Tower 为基地提供隐身场，是 NOD 独有的"基地防御"机制。

#### 7. 机动哲学
**"打了就跑 + 多线骚扰"**：
- Attack Bike（300 credits，速度极快）是骚扰神器，打完 Harvester 立刻跑。
- Shadow Team 可滑翔（glider pack）穿越地形突袭。
- Stealth Tank 隐身机动，绕后打经济。
- Flame Tank 可钻地（TW 中通过技能），从地下冒出拆建筑。
- Vertigo 隐身轰炸机，打击关键目标后消失。
- NOD 永远在"创造局部优势"，而不是"集结主力决战"。

#### 8. 视野与地图控制
- Shadow Team（隐身）是核心侦察单位。
- Attack Bike 速度快可巡逻。
- Disruption Tower 让基地"消失"，对手必须用侦察单位才能定位。
- 弱点：NOD 主动视野范围一般，依赖隐身单位贴脸侦察，风险较高。

#### 9. 反制弱点
- **正面弱**：Scorpion Tank（500 credits，HP 1200）远不如 Predator（1000，HP 2400），更不如 Mammoth。NOD 不能正面拼。
- **怕反隐**：GDI 的 Pitbull 升级传感器、Scrin 的 Buzzers 可暴露 NOD 隐身单位。
- **怕空优**：NOD 空军偏骚扰（Venom）而非制空，面对 GDI Firehawk 或 Scrin Stormrider 群处于劣势。
- **单位脆**：Stealth Tank HP 1200 但装甲薄，Beam Cannon HP 750，一被集火就蒸发。
- **依赖微操**：NOD 玩家需要多线操作，APM 门槛高。

#### 10. 强势时间窗
- **T1 极早期**（1-3 分钟）：Attack Bike 骚扰 Harvester，Scorpion Tank 快攻。
- **T2 中期**（4-6 分钟）：Flame Tank + Shadow Team + Beam Cannon 多线打击，对手疲于奔命。
- **T3 初期**（7-9 分钟）：Vertigo 隐身轰炸关键建筑 + Avatar 成型。
- **超武后**：Nuke 终结。

#### 11. 经济模型
- 同为泰矿采集，但 NOD Harvester 造价略低（TS 中 NOD Harvester 更脆但便宜）。
- NOD 的经济优势在于**骚扰对手经济**：Attack Bike / Stealth Tank / Vapor Bomb 都可用于打掉敌方 Harvester。
- Tiberium Vapor Bomb（TW）可直接污染敌方 Tiberium Field，降低其采集效率。
- NOD 经济压力点：自身单位便宜但脆，损失快，需要持续骚扰才能维持经济平衡。

---

### 三、Scrin（外星入侵者，TW/KW 独有）

#### 1. 设计哲学
**"外星科技 + 虫群 + 空天一体"** —— Scrin 是一支完全异质的阵营，用虫群步兵、悬浮载具、虫群空军和母舰终决战。设计上强调"反直觉"：步兵从 Portal（传送门）生产，载具从 Warp Sphere（扭曲球）"传送"过来，空军从 Gravity Stabilizer（重力稳定器）降落。

#### 2. 核心签名机制
- **Ion Storm（离子风暴）**：Scrin 可通过技能召唤 Ion Storm，在区域内强化 Scrin 空军（Stormrider 回血+伤害加成），同时削弱敌方。
- **MotherShip（母舰）**：Scrin 专属 Epic 单位（实际上 TW 战役中是终极武器），一炮可夷平基地，是 Scrin 的"终决战兵器"。
- **Rift Generator（裂隙发生器）**：Scrin 超级武器，制造时空裂隙吞噬区域内所有单位，是全游戏最具破坏力的超武之一。
- **传送（Teleport）**：Shock Trooper 可传送短距离，Mastermind/Prodigy 可传送整个友军小队，是 Scrin 独有的"瞬移突袭"机制。
- **Tiberium 共生**：Scrin 单位在 Tiberium 中回血，Corrupter 可"创造"Tiberium 场，Harvester 采集效率高。
- **Buzzers**：最便宜的步兵（200 credits），虫群单位，可寄生载具，侦察+反步兵极强。

#### 3. 角色分工矩阵

| Tier | 步兵 | 载具 | 空军 | 超级武器 |
|---|---|---|---|---|
| T1 | Buzzers / Disintegrators | Gun Walker / Seeker | Stormrider | — |
| T1.5 | Assimilator | Harvester | — | — |
| T2 | Shock Trooper | Devourer Tank / Corrupter | — | — |
| T3 | Mastermind / Cultist (KW) | — | Devastator Warship / Planetary Assault Carrier | Rift Generator |
| Epic (KW) | — | Eradicator Hexapod / Reaper Tripod / Reaper-17 Hexapod | MotherShip | — |

#### 4. 科技树节奏
Scrin 节奏**前稳后爆**：
- T1→T2：Portal → Warp Sphere → Nerve Center（1500），约 2-3 分钟。
- T2→T3：Technology Assembler（2000）+ Foundry（1000）解锁 Devastator / PAC / Mastermind，约 6-7 分钟。
- 超武：Signal Transmitter（3000），约 9-10 分钟。
- Scrin 的优势：T2 时 Devourer Tank + Corrupter 组合极为强力，可压制 GDI/NOD 同期。

#### 5. 核心协同组合
1. **Buzzers + Disintegrators**：T1 虫群，Buzzers 反步兵+侦察，Disintegrators 反载具。
2. **Seeker + Stormrider**：Seeker 悬浮坦克地面推，Stormrider 空中支援，Ion Storm 加成后极强。
3. **Shock Trooper + Devourer Tank**：T2 标准组合，Shock Trooper 传送侧袭，Devourer 正面。
4. **Corrupter + 任意部队**：Corrupter 喷 Tiberium 治疗友军+伤害敌军，是 Scrin 的"移动医疗站"。
5. **Devastator Warship + Planetary Assault Carrier**：T3 空中舰队，Devastator 远程轰炸，PAC 舰载机持续输出。
6. **Mastermind + Shock Trooper**：Mastermind 传送 Shock Trooper 小队到敌方基地后方，瞬移突袭。
7. **Rift Generator + 空军推进**：Rift 吞掉敌方主力/防御，Scrin 空军收割残局。

#### 6. 生产机制
- **Drone Ship 系统**：Scrin 的 MCV 等价物是 Drone Ship，展开为 Drone Platform。
- 建筑从 Drone Platform"传送"到地图上，类似 GDI/NOD 的建造场系统但视觉上为外星传送。
- Portal（500）生产步兵，Warp Sphere（2000）生产载具，Gravity Stabilizer（1000）生产空军。
- Explorer（1500）是前哨展开单位，等价于 GDI Surveyor / NOD Foundry。

#### 7. 机动哲学
**"空天一体 + 传送突袭"**：
- 空军是 Scrin 的核心（Stormrider / Devastator / PAC / Mothership），全游戏最强空军体系。
- Seeker、Gun Walker 为悬浮单位，可跨越水面。
- Shock Trooper 传送、Mastermind 群体传送，可实现"瞬移斩首"。
- 弱点：地面机动性一般，Devourer Tank 速度不及 GDI Mammoth 但比 NOD Avatar 快。

#### 8. 视野与地图控制
- Buzzers（200 credits，虫群）是全游戏最便宜侦察单位，可铺满地图。
- Stormrider 空中巡逻视野广。
- Nerve Center 提供雷达。
- Scrin 视野优势：虫群+空军可快速覆盖地图，信息战能力强。

#### 9. 反制弱点
- **T1 弱**：Buzzers 脆（HP 75），Disintegrators 只能反载具，对 GDI/NOD 的步兵群劣势。
- **怕早期快攻**：NOD Attack Bike / GDI Pitbull 可在 Scrin T2 之前压制。
- **地面正面弱**：Devourer Tank（1100，HP 2400）比 Mammoth（2000，HP 5000）弱，不能正面拼。
- **依赖空军**：Scrin 核心战斗力在 T3 空军，若被 GDI Firehawk / NOD Venom 抢制空，Scrin 体系崩溃。
- **MotherShip 极脆**：虽是 Epic 但速度慢、目标大，易被集火。

#### 10. 强势时间窗
- **T2 中期**（5-7 分钟）：Devourer + Corrupter + Shock Trooper 组合成型，可压制 GDI/NOD 同期。
- **T3 初期**（8-10 分钟）：Devastator + PAC 空军舰队，对手若无足够 AA 几乎无法阻挡。
- **超武后**：Rift Generator 吞噬敌方主力，Scrin 一波终局。

#### 11. 经济模型
- 同为泰矿采集，但 Scrin Harvester 在 Tiberium 中回血，生存性更强。
- Corrupter 可"创造"Tiberium 场，理论上可扩展资源点。
- Scrin 经济压力点：T2/T3 单位造价不低（Devourer 1100、Devastator 2000、PAC 2500），需要稳定经济流。
- Buzzers 200 credits 的极低造价让 Scrin 在前期可用虫群骚扰敌方经济，性价比极高。

---

## 第二部分：单位数据表

> 字段说明：
> - cost 单位 credits；build_time 单位秒（近似值，受游戏速度影响）
> - armor_type：Infantry / Vehicle / Aircraft / Structure / Hover（TW/KW 中有更细分类）
> - target：G=对地 A=对空 B=对建筑（C&C 中通常 G 包含 B）
> - 数值标注 ≈ 表示近似值，可能因版本/升级有偏差
> - TS 数据基于 Tiberian Sun + Firestorm 扩展

---

### A. Tiberian Sun（含 Firestorm 扩展）

#### A.1 GDI 单位

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 轻步兵 | Light Infantry | GDI | TS | T1 | Barracks | 100 | 6 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | 15 | Bullet | 30 | 4 | G | No | — | — | — |
| 盘片投手 | Disk Thrower | GDI | TS | T1 | Barracks | 120 | 7 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | 50 | Disc(Explosive) | 60 | 4 | G | Yes | vs Building | — | — |
| 喷气步兵 | Jump Jet Infantry | GDI | TS | T2 | Barracks | 300 | 10 | 0 | 90 | Infantry | — | 5(fly) | Yes | No | 6 | — | 25 | Bullet | 40 | 5 | G/A | No | — | Jump Jet | — |
| 医疗兵 | Medic | GDI | TS | T1 | Barracks | 100 | 6 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | —(heal) | Heal | 30 | 3 | G(ally) | No | — | — | — |
| 工程师 | Engineer | GDI | TS | T1 | Barracks | 200 | 8 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | — | Capture | — | 1 | G | No | — | — | — |
| 幽灵杀手（英雄） | Ghost Stalker | GDI | TS | T3 | Barracks | 1000 | 20 | 0 | 200 | Infantry | — | 4 | No | No | 7 | — | 200 | Railgun | 60 | 5 | G | Yes | vs Infantry/Vehicle | C4(demolish) | — |
| 狼獾 | Wolverine | GDI | TS | T1 | War Factory | 300 | 10 | 0 | 180 | Vehicle | — | 7 | No | No | 6 | — | 25 | Chaingun | 20 | 5 | G | No | vs Infantry | — | — |
| 泰坦 | Titan | GDI | TS | T2 | War Factory | 600 | 15 | 0 | 400 | Vehicle | — | 6 | No | No | 7 | — | 80 | Cannon | 50 | 6 | G | No | vs Vehicle | — | — |
| 猛犸 Mk II | Mammoth Mk II | GDI | TS | T3 | War Factory | 1800 | 45 | 0 | 900 | Vehicle | — | 4 | No | No | 7 | — | 150×2 | Railgun | 80 | 7 | G/A | Yes | vs Vehicle | — | Self-heal |
| 两栖 APC | Amphibious APC | GDI | TS | T1 | War Factory | 400 | 12 | 0 | 200 | Vehicle | — | 6 | No | No | 6 | 5 | 20 | Chaingun | 20 | 5 | G | No | — | — | Amphibious |
| 干扰者 | Disruptor | GDI | TS | T2 | War Factory | 950 | 25 | 0 | 400 | Vehicle | — | 5 | No | No | 6 | — | 120 | Sonic | 70 | 5 | G | Yes(beam) | vs Vehicle/Building | — | — |
| 悬浮 MLRS | Hover MLRS | GDI | TS | T2 | War Factory | 600 | 15 | 0 | 200 | Hover | — | 7 | No | Yes | 7 | — | 40×2 | Missile | 60 | 7 | G/A | Yes | vs Air | — | Hover |
| 巨像（Firestorm） | Juggernaut | GDI | TS | T2 | War Factory | 900 | 22 | 0 | 500 | Vehicle | — | 4 | No | No | 7 | — | 150 | Artillery | 120 | 10 | G | Yes | vs Building | Deploy | — |
| 机动传感器阵列 | Mobile Sensor Array | GDI | TS | T2 | War Factory | 600 | 15 | 0 | 200 | Vehicle | — | 5 | No | No | 10 | — | — | — | — | — | — | No | — | Deploy(Sensor) | — |
| 机动 EMP | Mobile EMP | GDI | TS | T2 | War Factory | 750 | 18 | 0 | 250 | Vehicle | — | 5 | No | No | 6 | — | — | EMP | 90 | 5 | G | Yes | vs Vehicle | EMP Blast | — |
| 修理车 | Repair Vehicle | GDI | TS | T1 | War Factory | 400 | 12 | 0 | 150 | Vehicle | — | 5 | No | No | 5 | — | —(repair) | Repair | — | 3 | G(ally) | No | — | — | — |
| 采矿车 | Harvester | GDI | TS | T1 | War Factory | 1400 | 30 | 0 | 600 | Vehicle | — | 4 | No | No | 4 | — | — | — | — | — | — | No | — | — | — |
| MCV | Mobile Construction Vehicle | GDI | TS | T1 | War Factory | 2000 | 60 | 0 | 1000 | Vehicle | — | 3 | No | No | 4 | — | — | — | — | — | — | No | — | Deploy | — |
| Orca 战机 | Orca Fighter | GDI | TS | T2 | Helipad | 300 | 10 | 0 | 120 | Aircraft | — | 10(fly) | Yes | No | 6 | — | 30 | Missile | 40 | 5 | G | Yes | vs Vehicle | — | — |
| Orca 轰炸机 | Orca Bomber | GDI | TS | T2 | Helipad | 400 | 12 | 0 | 150 | Aircraft | — | 8(fly) | Yes | No | 6 | — | 80×2 | Bomb | 80 | 4 | G | Yes | vs Building | — | — |
| Orca 运输机 | Orca Carryall | GDI | TS | T2 | Helipad | 600 | 15 | 0 | 150 | Aircraft | — | 8(fly) | Yes | No | 6 | — | — | — | — | — | — | No | — | Pickup Vehicle | — |

#### A.2 GDI 建筑

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power_use | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 建造场 | Construction Yard | GDI | TS | — | MCV Deploy | —(MCV) | — | 0 | 1000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 发电厂 | Power Plant | GDI | TS | — | CY | 300 | 4 | +100(output) | 400 | Structure | — | — | No | No | 4 | — | — | — | — | — | — | No | — | — | Power(+100) |
| 泰矿精炼厂 | Tiberium Refinery | GDI | TS | — | CY | 1500 | 20 | -30 | 800 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 兵营 | Barracks | GDI | TS | — | CY | 300 | 5 | -10 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 战车工厂 | War Factory | GDI | TS | — | CY | 1000 | 15 | -20 | 800 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 直升机坪 | Helipad | GDI | TS | — | CY | 300 | 5 | -10 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Produces Orca |
| 组件塔 | Component Tower | GDI | TS | — | CY | 200 | 4 | -5 | 400 | Structure | — | — | No | No | 6 | — | —(upgrades) | — | — | — | — | No | — | Modular Upgrade | — |
| 雷达 | Radar | GDI | TS | — | CY | 500 | 8 | -30 | 500 | Structure | — | — | No | No | 8 | — | — | — | — | — | — | No | — | — | Radar |
| 科技中心 | Tech Center | GDI | TS | — | CY | 1000 | 20 | -30 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Unlocks T3 |
| 升级中心 | Upgrade Center | GDI | TS | — | CY | 500 | 8 | -20 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Drop Pod/Ion Cannon |
| 离子炮 | Ion Cannon Uplink | GDI | TS | SW | Upgrade Center | 1500 | 30 | -150 | 500 | Structure | — | — | No | No | 5 | — | 1500 | Orbital | 360 | Map | G | Yes | vs All | Ion Strike | — |
| 修理厂 | Service Depot | GDI | TS | — | CY | 500 | 8 | -10 | 500 | Structure | — | — | No | No | 5 | — | —(repair) | — | — | — | — | No | — | — | — |
| 铺路 | Pavement | GDI | TS | — | CY | 25 | 1 | 0 | 100 | Structure | — | — | No | No | — | — | — | — | — | — | — | No | — | — | Crush-proof |

#### A.3 NOD 单位

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 轻步兵 | Light Infantry | NOD | TS | T1 | Hand of Nod | 100 | 6 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | 15 | Bullet | 30 | 4 | G | No | — | — | — |
| 火箭步兵 | Rocket Infantry | NOD | TS | T1 | Hand of Nod | 200 | 8 | 0 | 100 | Infantry | — | 3 | No | No | 5 | — | 40 | Missile | 50 | 6 | G/A | Yes | vs Vehicle/Air | — | — |
| 工程师 | Engineer | NOD | TS | T1 | Hand of Nod | 200 | 8 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | — | Capture | — | 1 | G | No | — | — | — |
| 半机械人 | Cyborg | NOD | TS | T2 | Hand of Nod | 500 | 12 | 0 | 200 | Infantry | — | 5 | No | No | 6 | — | 30 | Bullet | 25 | 5 | G | No | — | — | Heal in Tiberium |
| 半机械人突击队（英雄） | Cyborg Commando | NOD | TS | T3 | Hand of Nod | 1500 | 30 | 0 | 300 | Infantry | — | 5 | No | No | 7 | — | 200 | Plasma | 60 | 6 | G | Yes | vs Vehicle/Building | — | Heal in Tiberium |
| 变种劫持者 | Mutant Hijacker | NOD | TS | T2 | Hand of Nod | 500 | 12 | 0 | 100 | Infantry | — | 5 | No | No | 6 | — | — | Hijack | — | 1 | G(Vehicle) | No | — | Hijack Vehicle | — |
| 毒素兵（Firestorm） | Toxin Soldier | NOD | TS | T2 | Hand of Nod | 200 | 8 | 0 | 100 | Infantry | — | 4 | No | No | 5 | — | 40 | Toxin | 30 | 4 | G | No | vs Infantry | — | — |
| 突击车 | Attack Buggy | NOD | TS | T1 | War Factory | 300 | 10 | 0 | 120 | Vehicle | — | 9 | No | No | 6 | — | 20 | Chaingun | 20 | 5 | G | No | vs Infantry | — | — |
| 突击摩托 | Attack Cycle | NOD | TS | T1 | War Factory | 500 | 12 | 0 | 150 | Vehicle | — | 10 | No | No | 6 | — | 40×2 | Missile | 50 | 6 | G/A | Yes | vs Vehicle/Air | — | — |
| 蜱型坦克 | Tick Tank | NOD | TS | T2 | War Factory | 500 | 12 | 0 | 350 | Vehicle | — | 5 | No | No | 6 | — | 70 | Cannon | 50 | 6 | G | No | vs Vehicle | Deploy(Dig-in, +armor) | — |
| 火炮 | Artillery | NOD | TS | T2 | War Factory | 850 | 20 | 0 | 200 | Vehicle | — | 4 | No | No | 7 | — | 150 | Artillery | 120 | 10 | G | Yes | vs Building/Infantry | Deploy | — |
| 地下 APC | Subterranean APC | NOD | TS | T2 | War Factory | 600 | 15 | 0 | 300 | Vehicle | — | 4(dig) | No | No | 6 | 5 | 20 | Chaingun | 20 | 5 | G | No | — | Subterranean(dig) | — |
| 魔舌 | Devil's Tongue | NOD | TS | T2 | War Factory | 700 | 18 | 0 | 300 | Vehicle | — | 4(dig) | No | No | 6 | — | 80 | Flame | 50 | 4 | G | Yes | vs Infantry/Building | Subterranean(dig) | — |
| 隐形坦克 | Stealth Tank | NOD | TS | T2 | War Factory | 660 | 16 | 0 | 150 | Vehicle | — | 7 | No | No | 6 | — | 50×2 | Missile | 50 | 6 | G/A | Yes | vs Vehicle/Air | — | Stealth |
| 采矿车 | Harvester | NOD | TS | T1 | War Factory | 1400 | 30 | 0 | 500 | Vehicle | — | 4 | No | No | 4 | — | — | — | — | — | — | No | — | — | — |
| MCV | Mobile Construction Vehicle | NOD | TS | T1 | War Factory | 2000 | 60 | 0 | 1000 | Vehicle | — | 3 | No | No | 4 | — | — | — | — | — | — | No | — | Deploy | — |
| 机动隐形发生器 | Mobile Stealth Generator | NOD | TS | T2 | War Factory | 1000 | 22 | 0 | 300 | Vehicle | — | 4 | No | No | 6 | — | — | — | — | — | — | No | — | Deploy(Stealth Field) | — |
| 机动修理车 | Mobile Repair Vehicle | NOD | TS | T1 | War Factory | 400 | 12 | 0 | 150 | Vehicle | — | 5 | No | No | 5 | — | —(repair) | Repair | — | 3 | G(ally) | No | — | — | — |
| Harpy | Harpy | NOD | TS | T2 | Helipad | 350 | 10 | 0 | 150 | Aircraft | — | 10(fly) | Yes | No | 6 | — | 25 | Chaingun | 30 | 5 | G/A | No | vs Infantry | — | — |
| 女妖 | Banshee | NOD | TS | T2 | Helipad | 1000 | 20 | 0 | 200 | Aircraft | — | 8(fly) | Yes | No | 6 | — | 80×2 | Plasma | 70 | 6 | G | Yes | vs Vehicle/Building | — | — |

#### A.4 NOD 建筑

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power_use | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 建造场 | Construction Yard | NOD | TS | — | MCV Deploy | —(MCV) | — | 0 | 1000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 发电厂 | Power Plant | NOD | TS | — | CY | 300 | 4 | +100(output) | 400 | Structure | — | — | No | No | 4 | — | — | — | — | — | — | No | — | — | Power(+100) |
| 泰矿精炼厂 | Tiberium Refinery | NOD | TS | — | CY | 1500 | 20 | -30 | 800 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| Nod 之手 | Hand of Nod | NOD | TS | — | CY | 300 | 5 | -10 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 战车工厂 | War Factory | NOD | TS | — | CY | 1000 | 15 | -20 | 800 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 直升机坪 | Helipad | NOD | TS | — | CY | 300 | 5 | -10 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Produces Harpy/Banshee |
| 激光炮塔 | Laser Turret | NOD | TS | — | CY | 200 | 4 | -20 | 300 | Structure | — | — | No | No | 6 | — | 80 | Laser | 40 | 6 | G | No | vs Vehicle/Infantry | — | — |
| SAM 发射台 | SAM Site | NOD | TS | — | CY | 200 | 4 | -20 | 300 | Structure | — | — | No | No | 6 | — | 60 | Missile | 40 | 8 | A | Yes | vs Air | — | — |
| 光明方尖碑 | Obelisk of Light | NOD | TS | — | CY | 1000 | 15 | -150 | 400 | Structure | — | — | No | No | 7 | — | 200 | Laser | 80 | 8 | G | No | vs Vehicle | — | — |
| Nod 神庙 | Temple of Nod | NOD | TS | SW | CY | 1500 | 30 | -150 | 500 | Structure | — | — | No | No | 5 | — | 1500 | Cluster Missile | 360 | Map | G | Yes | vs All | Cluster Missile Strike | — |
| 科技中心 | Tech Center | NOD | TS | — | CY | 1000 | 20 | -30 | 500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Unlocks T3 |
| 隐形发生器 | Stealth Generator | NOD | TS | — | CY | 1000 | 20 | -100 | 400 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Stealth Field(base) |
| 铺路 | Pavement | NOD | TS | — | CY | 25 | 1 | 0 | 100 | Structure | — | — | No | No | — | — | — | — | — | — | — | No | — | — | Crush-proof |

---

### B. Tiberium Wars + Kane's Wrath

> TW 与 KW 共享核心单位数据。KW 新增的单位标注 [KW]，子阵营专属单位在备注中说明。
> 装甲类型在 TW/KW 中细分为：Infantry / Vehicle / Aircraft / Structure / Hover / Air（航空器）
> 升级后的数值（如 Railgun 升级）未单独列出，以基础值为准

#### B.1 GDI 单位

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 步枪兵小队 | Rifleman Squad | GDI | TW/KW | T1 | Barracks | 400 | 8 | 0 | 300(6人) | Infantry | — | 5 | No | No | 5 | — | 15×6 | Bullet | 30 | 3 | G | No | — | Dig Foxhole | — |
| 导弹小队 | Missile Squad | GDI | TW/KW | T1 | Barracks | 400 | 8 | 0 | 240(3人) | Infantry | — | 4 | No | No | 5 | — | 50×3 | Missile | 50 | 3.5 | G/A | Yes | vs Vehicle/Air | — | — |
| 工程师 | Engineer | GDI | TW/KW | T1 | Barracks | 500 | 10 | 0 | 100 | Infantry | — | 5 | No | No | 5 | — | — | Capture | — | 1 | G | No | — | — | — |
| 掷弹兵小队 | Grenadier Squad | GDI | TW/KW | T1 | Barracks | 400 | 8 | 0 | 300(4人) | Infantry | — | 5 | No | No | 5 | — | 40×4 | Grenade | 40 | 3 | G | Yes | vs Building/Infantry | — | — |
| 狙击手小队 | Sniper Team | GDI | TW/KW | T2 | Barracks | 600 | 12 | 0 | 100(2人) | Infantry | — | 5 | No | No | 8 | — | 150 | Sniper | 60 | 6 | G | No | vs Infantry | — | — |
| 区域装甲兵 | Zone Trooper | GDI | TW/KW | T3 | Barracks | 1300 | 15 | 0 | 1000(3人) | Infantry | — | 4 | No | No | 6 | — | 200 | Railgun | 50 | 5 | G | Yes | vs Vehicle | Jump Jets | — |
| 突击队员（英雄） | Commando | GDI | TW/KW | T3 | Barracks | 2000 | 20 | 0 | 1000 | Infantry | — | 6 | No | No | 7 | — | 500 | Railgun | 30 | 4 | G | No | vs Infantry/Vehicle | C4(demolish building) | — |
| 区域突袭兵 [KW] | Zone Raider | GDI | KW | T3 | Barracks | 1300 | 15 | 0 | 1000(3人) | Infantry | — | 4 | No | No | 6 | — | 150×3 | Grenade | 40 | 5 | G/A | Yes | vs Air/Building | Jump Jets | — |
| Pitbull | Pitbull | GDI | TW/KW | T1 | War Factory | 600 | 10 | 0 | 240 | Vehicle | — | 9 | No | No | 7 | — | 20×2(MG)+40×2(MSL) | Bullet/Missile | 30/50 | 5/7 | G/A | No | vs Air(MSL) | — | — |
| 掠食者坦克 | Predator Tank | GDI | TW/KW | T1 | War Factory | 1000 | 10 | 0 | 2400 | Vehicle | — | 6 | No | No | 6 | — | 130 | Cannon | 70 | 4 | G | No | vs Vehicle | — | — |
| APC | APC | GDI | TW/KW | T1 | War Factory | 600 | 10 | 0 | 600 | Vehicle | — | 6 | No | No | 6 | 1 | 25(MG)+40(MSL) | Bullet/Missile | 30/50 | 5/7 | G/A | No | vs Air(MSL) | — | — |
| 起重机 | Rig | GDI | TW/KW | T2 | War Factory | 1500 | 15 | 0 | 1000 | Vehicle | — | 5 | No | No | 6 | — | — | — | — | — | — | No | — | Deploy(Repair+Defense) | — |
| 猛犸坦克 | Mammoth Tank | GDI | TW/KW | T3 | War Factory | 2000 | 20 | 0 | 5000 | Vehicle | — | 5 | No | No | 6 | — | 150×2(Cannon)+80(MSL) | Cannon/Missile | 70/60 | 5/7 | G/A | Yes | vs Vehicle/Air | — | Railgun Upgrade |
| 巨像 | Juggernaut | GDI | TW/KW | T2 | War Factory | 1400 | 15 | 0 | 1500 | Vehicle | — | 4 | No | No | 8 | — | 250×3 | Artillery | 120 | 12 | G | Yes | vs Building | Bombard | — |
| 采矿车 | Harvester | GDI | TW/KW | T1 | War Factory | 1400 | 20 | 0 | 1200 | Vehicle | — | 4 | No | No | 4 | — | — | — | — | — | — | No | — | — | — |
| MCV | Mobile Construction Vehicle | GDI | TW/KW | T1 | War Factory | 3500 | 30 | 0 | 5000 | Vehicle | — | 3 | No | No | 4 | — | — | — | — | — | — | No | — | Deploy | — |
| 测量车 | Surveyor | GDI | TW/KW | T1 | War Factory | 1500 | 15 | 0 | 1500 | Vehicle | — | 4 | No | No | 5 | — | — | — | — | — | — | No | — | Deploy(Outpost) | — |
| 弹弓 [KW] | Slingshot | GDI | KW | T2 | War Factory | 600 | 10 | 0 | 240 | Hover | — | 8 | No | Yes | 6 | — | 40×2 | Missile | 30 | 7 | A | Yes | vs Air | — | — |
| 震荡者 [KW] | Shatterer | GDI | KW | T2 | War Factory | 1100 | 12 | 0 | 1200 | Hover | — | 6 | No | Yes | 7 | — | 200 | Sonic | 70 | 7 | G | Yes(beam) | vs Vehicle/Building | — | — |
| 泰坦 [KW Steel Talons] | Titan | GDI | KW | T2 | War Factory | 900 | 12 | 0 | 2000 | Vehicle | — | 6 | No | No | 6 | — | 120 | Cannon | 60 | 5 | G | No | vs Vehicle | — | — |
| 狼獾 [KW Steel Talons] | Wolverine | GDI | KW | T1 | War Factory | 400 | 8 | 0 | 300 | Vehicle | — | 8 | No | No | 6 | — | 20×2 | Chaingun | 20 | 5 | G | No | vs Infantry | — | — |
| MARV [KW Epic ZOCOM] | Mammoth Armed Reclamation Vehicle | GDI | KW | Epic | War Factory | 5000 | 60 | 0 | 30000 | Vehicle | — | 3 | No | No | 8 | 4 | 300×2(Cannon)+Sonic | Cannon/Sonic | 80 | 7 | G | Yes | vs All | — | Harvests Tiberium(generates credits) |
| Mastodon [KW Steel Talons] | Mastodon | GDI | KW | Epic | War Factory | 5000 | 60 | 0 | 25000 | Vehicle | — | 3 | No | No | 8 | — | 250×2 | Railgun | 70 | 8 | G | Yes | vs Vehicle | — | — |
| Orca | Orca | GDI | TW/KW | T2 | Airfield | 1000 | 15 | 0 | 640 | Aircraft | — | 12(fly) | Yes | No | 6 | — | 60×4(Missile) | Missile | 60 | 6 | G/A | Yes | vs Vehicle/Air | — | — |
| Firehawk | Firehawk | GDI | TW/KW | T3 | Airfield | 1500 | 15 | 0 | 390 | Aircraft | — | 14(fly) | Yes | No | 6 | — | 200(AA or AG mode) | Missile/Bomb | 60 | 6 | G/A | Yes | vs Air or Building | Switch AA/AG | — |
| Hammerhead [KW] | Hammerhead | GDI | KW | T2 | Airfield | 1000 | 12 | 0 | 500 | Aircraft | — | 10(fly) | Yes | No | 6 | 1 | 30(MG) | Chaingun | 20 | 5 | G | No | vs Infantry | — | Transport(1 slot) |

#### B.2 GDI 建筑

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power_use | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 建造场 | Construction Yard | GDI | TW/KW | — | MCV Deploy | —(MCV) | — | 0 | 5000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 发电厂 | Power Plant | GDI | TW/KW | — | CY | 800 | 8 | +12(output) | 2000 | Structure | — | — | No | No | 4 | — | — | — | — | — | — | No | — | — | Power(+12) |
| 泰矿精炼厂 | Tiberium Refinery | GDI | TW/KW | — | CY | 3000 | 20 | -10 | 3000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Comes with 1 Harvester |
| 兵营 | Barracks | GDI | TW/KW | — | CY | 500 | 8 | -5 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 战车工厂 | War Factory | GDI | TW/KW | — | CY | 2000 | 15 | -8 | 3000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 机场 | Airfield | GDI | TW/KW | — | CY | 1000 | 10 | -8 | 2000 | Structure | — | — | No | No | 6 | — | — | — | — | — | — | No | — | — | Produces Aircraft(4 slots) |
| 指挥所 | Command Post | GDI | TW/KW | — | CY | 1500 | 12 | -8 | 2000 | Structure | — | — | No | No | 8 | — | — | — | — | — | — | No | — | — | Radar, Unlocks T2 |
| 科技中心 | Tech Center | GDI | TW/KW | — | CY | 2000 | 20 | -10 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Unlocks T3 |
| 军械库 | Armory | GDI | TW/KW | — | CY | 1000 | 10 | -5 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Infantry Upgrades |
| 太空指挥上行链路 | Space Command Uplink | GDI | TW/KW | SW | CY | 3000 | 30 | -10 | 3000 | Structure | — | — | No | No | 5 | — | 1500 | Orbital | 300 | Map | G | Yes | vs All | Ion Cannon Strike | — |
| 修理厂 | War Factory Repair | GDI | TW/KW | — | CY | 500 | 5 | -3 | 1500 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 观察塔 | Watchtower | GDI | TW/KW | — | CY | 600 | 8 | -5 | 2000 | Structure | — | — | No | No | 8 | — | 40×2 | Bullet | 30 | 6 | G | No | vs Infantry | — | — |
| 守卫者炮 | Guardian Cannon | GDI | TW/KW | — | CY | 800 | 10 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 100 | Cannon | 60 | 7 | G | No | vs Vehicle | — | — |
| 防空炮 | AA Battery | GDI | TW/KW | — | CY | 800 | 10 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 80×2 | Missile | 40 | 8 | A | Yes | vs Air | — | — |
| 声波发射器 | Sonic Emitter | GDI | TW/KW | — | CY | 1500 | 15 | -10 | 2000 | Structure | — | — | No | No | 7 | — | 200 | Sonic | 70 | 8 | G | Yes(beam) | vs Vehicle/Building | — | — |

#### B.3 NOD 单位

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 民兵小队 | Militant Squad | NOD | TW/KW | T1 | Hand of Nod | 300 | 6 | 0 | 300(6人) | Infantry | — | 5 | No | No | 5 | — | 12×6 | Bullet | 30 | 3 | G | No | — | — | — |
| 民兵火箭小队 | Militant Rocket Squad | NOD | TW/KW | T1 | Hand of Nod | 300 | 6 | 0 | 240(3人) | Infantry | — | 4 | No | No | 5 | — | 50×3 | Missile | 50 | 3.5 | G/A | Yes | vs Vehicle/Air | — | — |
| 破坏者 | Saboteur | NOD | TW/KW | T1 | Hand of Nod | 500 | 10 | 0 | 100 | Infantry | — | 5 | No | No | 5 | — | — | Capture | — | 1 | G | No | — | — | — |
| 狂热者 | Fanatic | NOD | TW/KW | T1 | Hand of Nod | 300 | 6 | 0 | 240(5人) | Infantry | — | 6 | No | No | 5 | — | 250(self-destruct) | Explosion | — | 1 | G | Yes | vs Building/Vehicle | Suicide Attack | — |
| 黑手 | Black Hand | NOD | TW/KW | T2 | Hand of Nod | 900 | 12 | 0 | 900(3人) | Infantry | — | 4 | No | No | 6 | — | 80×3 | Flame | 40 | 4 | G | Yes | vs Infantry/Building | — | — |
| 影子小队 | Shadow Team | NOD | TW/KW | T2 | Hand of Nod | 800 | 10 | 0 | 500(4人) | Infantry | — | 5 | No | No | 7 | — | 60×4 | Pistol/Charge | 30 | 4 | G | Yes | vs Infantry/Building | Glider Pack, Detonate Building | Stealth |
| 忏悔者卡巴尔 | Confessor Cabal | NOD | TW/KW | T3 | Hand of Nod | 900 | 12 | 0 | 600(4人) | Infantry | — | 4 | No | No | 6 | — | 50×4 | Bullet/Grenade | 30 | 5 | G | Yes | vs Infantry/Vehicle | — | Buff nearby Militants |
| 突击队员（英雄） | Commando | NOD | TW/KW | T3 | Hand of Nod | 2000 | 20 | 0 | 1000 | Infantry | — | 6 | No | No | 7 | — | 400 | Dual Pistol | 20 | 4 | G | No | vs Infantry | Detonate Building | Stealth |
| 觉醒者 [KW Marked of Kane] | Awakened | NOD | KW | T2 | Hand of Nod | 800 | 10 | 0 | 600(3人) | Infantry | — | 4 | No | No | 6 | — | 80×3 | EMP/Railgun | 50 | 5 | G | No | vs Vehicle | EMP Blast | Cyborg(heal in Tib) |
| 泰伯利亚兵 [KW Marked of Kane] | Tiberium Trooper | NOD | KW | T2 | Hand of Nod | 900 | 12 | 0 | 700(3人) | Infantry | — | 4 | No | No | 6 | — | 60×3 | Liquid Tiberium | 40 | 4 | G | Yes | vs Infantry/Building | — | Cyborg(heal in Tib) |
| 突击摩托 | Attack Bike | NOD | TW/KW | T1 | War Factory | 300 | 6 | 0 | 160 | Vehicle | — | 12 | No | No | 7 | — | 50×2 | Missile | 40 | 6 | G/A | Yes | vs Vehicle/Air | — | Stealth(scout) |
| 突袭车 | Raider Buggy | NOD | TW/KW | T1 | War Factory | 400 | 8 | 0 | 240 | Vehicle | — | 9 | No | No | 6 | — | 20×2(MG) | Chaingun | 20 | 5 | G | No | vs Infantry | EMP Coil(upgrade) | — |
| 蝎子坦克 | Scorpion Tank | NOD | TW/KW | T1 | War Factory | 500 | 8 | 0 | 1200 | Vehicle | — | 7 | No | No | 6 | — | 80 | Cannon | 50 | 4 | G | No | vs Vehicle | Dozer Blade(upgrade, +armor) | — |
| 隐形坦克 | Stealth Tank | NOD | TW/KW | T2 | War Factory | 1000 | 12 | 0 | 1200 | Vehicle | — | 8 | No | No | 6 | — | 70×2 | Missile | 50 | 6 | G/A | Yes | vs Vehicle/Air | — | Stealth |
| 光束炮 | Beam Cannon | NOD | TW/KW | T2 | War Factory | 900 | 12 | 0 | 750 | Vehicle | — | 5 | No | No | 8 | — | 150 | Laser | 60 | 10 | G | No | vs Building/Vehicle | Combine Fire(multiple Beam Cannons) | — |
| 火焰坦克 | Flame Tank | NOD | TW/KW | T2 | War Factory | 1000 | 12 | 0 | 1200 | Vehicle | — | 6 | No | No | 6 | — | 100×2 | Flame | 40 | 4 | G | Yes | vs Infantry/Building | Burrow(stealth approach) | — |
| Avatar 战甲 | Avatar Warmech | NOD | TW/KW | T3 | War Factory | 2200 | 20 | 0 | 3000 | Vehicle | — | 5 | No | No | 7 | — | 300 | Laser | 80 | 6 | G | No | vs Vehicle/Building | Salvage(upgrade from wrecks) | — |
| 采矿车 | Harvester | NOD | TW/KW | T1 | War Factory | 1400 | 20 | 0 | 1200 | Vehicle | — | 4 | No | No | 4 | — | — | — | — | — | — | No | — | — | Stealth(when not harvesting) |
| MCV | Mobile Construction Vehicle | NOD | TW/KW | T1 | War Factory | 3500 | 30 | 0 | 5000 | Vehicle | — | 3 | No | No | 4 | — | — | — | — | — | — | No | — | Deploy | — |
| 铸造厂 | Foundry | NOD | TW/KW | T1 | War Factory | 1500 | 15 | 0 | 1500 | Vehicle | — | 4 | No | No | 5 | — | — | — | — | — | — | No | — | Deploy(Outpost) | — |
| Reckoner [KW] | Reckoner | NOD | KW | T2 | War Factory | 600 | 10 | 0 | 500 | Vehicle | — | 6 | No | No | 6 | 2 | 20(MG) | Chaingun | 20 | 5 | G | No | — | Deploy(hardened bunker) | — |
| Specter [KW] | Specter | NOD | KW | T2 | War Factory | 1100 | 12 | 0 | 1200 | Vehicle | — | 5 | No | No | 8 | — | 250 | Artillery | 120 | 12 | G | Yes | vs Building | — | Stealth |
| 救世主 [KW Epic Marked of Kane] | Redeemer | NOD | KW | Epic | War Factory | 5000 | 60 | 0 | 30000 | Vehicle | — | 3 | No | No | 8 | 1 | 400×2 | Laser | 80 | 7 | G | Yes | vs Vehicle/Building | — | — |
| 净化者 [KW Epic Black Hand] | Purifier | NOD | KW | Epic | War Factory | 5000 | 60 | 0 | 28000 | Vehicle | — | 3 | No | No | 8 | — | 350×2 | Flame/Laser | 80 | 7 | G | Yes | vs Infantry/Building | — | — |
| Venom | Venom | NOD | TW/KW | T2 | Air Tower | 900 | 12 | 0 | 320 | Aircraft | — | 14(fly) | Yes | No | 7 | — | 30(MG)+40(MSL) | Bullet/Missile | 20/50 | 5/6 | G/A | No | vs Air(MSL) | — | — |
| Vertigo | Vertigo | NOD | TW/KW | T3 | Air Tower | 1500 | 15 | 0 | 390 | Aircraft | — | 12(fly) | Yes | No | 6 | — | 500 | Bomb | 90 | 4 | G | Yes | vs Building | — | Stealth |
| Skin [KW] | Skin | NOD | KW | T2 | Air Tower | 1000 | 12 | 0 | 500 | Aircraft | — | 10(fly) | Yes | No | 6 | — | 200 | Laser | 60 | 6 | G | No | vs Vehicle | — | — |

#### B.4 NOD 建筑

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power_use | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 建造场 | Construction Yard | NOD | TW/KW | — | MCV Deploy | —(MCV) | — | 0 | 5000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 反应堆 | Reactor | NOD | TW/KW | — | CY | 800 | 8 | +12(output) | 2000 | Structure | — | — | No | No | 4 | — | — | — | — | — | — | No | — | — | Power(+12) |
| 泰矿精炼厂 | Tiberium Refinery | NOD | TW/KW | — | CY | 3000 | 20 | -10 | 3000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Comes with 1 Harvester |
| Nod 之手 | Hand of Nod | NOD | TW/KW | — | CY | 500 | 8 | -5 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 战车工厂 | War Factory | NOD | TW/KW | — | CY | 2000 | 15 | -8 | 3000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 空塔 | Air Tower | NOD | TW/KW | — | CY | 1000 | 10 | -8 | 2000 | Structure | — | — | No | No | 6 | — | — | — | — | — | — | No | — | — | Produces Aircraft(2 slots) |
| 作战中心 | Operations Center | NOD | TW/KW | — | CY | 1500 | 12 | -8 | 2000 | Structure | — | — | No | No | 8 | — | — | — | — | — | — | No | — | — | Radar, Unlocks T2 |
| 科技实验室 | Tech Lab | NOD | TW/KW | — | CY | 2000 | 20 | -10 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Unlocks T3 |
| Nod 神庙 | Temple of Nod | NOD | TW/KW | SW | CY | 3000 | 30 | -10 | 3000 | Structure | — | — | No | No | 5 | — | 1500 | Nuclear | 300 | Map | G | Yes | vs All | Nuclear Missile Strike | — |
| 干扰塔 | Disruption Tower | NOD | TW/KW | — | CY | 1000 | 10 | -8 | 1000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Stealth Field(base) |
| 破碎者炮塔枢纽 | Shredder Turret Hub | NOD | TW/KW | — | CY | 600 | 8 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 30×2 | Bullet | 20 | 5 | G | No | vs Infantry | — | — |
| 激光炮塔枢纽 | Laser Turret Hub | NOD | TW/KW | — | CY | 800 | 10 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 100 | Laser | 50 | 7 | G | No | vs Vehicle | — | — |
| SAM 炮塔枢纽 | SAM Turret Hub | NOD | TW/KW | — | CY | 800 | 10 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 80×2 | Missile | 40 | 8 | A | Yes | vs Air | — | — |
| 光明方尖碑 | Obelisk of Light | NOD | TW/KW | — | CY | 1500 | 15 | -10 | 2000 | Structure | — | — | No | No | 8 | — | 250 | Laser | 80 | 9 | G | No | vs Vehicle | — | — |

#### B.5 Scrin 单位

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 蜂群 | Buzzers | Scrin | TW/KW | T1 | Portal | 200 | 4 | 0 | 75 | Infantry | — | 8 | No | No | 7 | — | 10(swarm) | Melee/Slash | 10 | 1 | G | No | vs Infantry | — | Garrison Vehicle |
| 分解者 | Disintegrators | Scrin | TW/KW | T1 | Portal | 300 | 6 | 0 | 300(4人) | Infantry | — | 5 | No | No | 5 | — | 60×4 | Plasma | 40 | 3.5 | G | No | vs Vehicle | — | — |
| 同化者 | Assimilator | Scrin | TW/KW | T1 | Portal | 500 | 10 | 0 | 100 | Infantry | — | 5 | No | No | 5 | — | — | Capture | — | 1 | G | No | — | — | — |
| 震荡部队 | Shock Trooper | Scrin | TW/KW | T2 | Portal | 800 | 10 | 0 | 600(3人) | Infantry | — | 5 | No | No | 6 | — | 80×3 | Plasma | 40 | 4 | G | No | vs Vehicle | Teleport(short range) | — |
| 狂热者 [KW] | Cultist | Scrin | KW | T2 | Portal | 500 | 8 | 0 | 300(1人) | Infantry | — | 5 | No | No | 6 | — | — | Mind Control | — | 6 | G | No | — | Mind Control(enemy unit) | — |
| 潜行者 [KW] | Stalker | Scrin | KW | T2 | Portal | 800 | 10 | 0 | 600(3人) | Infantry | — | 4 | No | No | 6 | — | 70×3 | Bullet | 30 | 5 | G/A | No | vs Air | — | — |
| 毁灭者 [KW] | Ravager | Scrin | KW | T2 | Portal | 800 | 10 | 0 | 600(3人) | Infantry | — | 5 | No | No | 6 | — | 90×3 | Plasma | 40 | 4 | G | No | vs Vehicle | — | — |
| 主谋（英雄） | Mastermind | Scrin | TW/KW | T3 | Portal | 2500 | 20 | 0 | 1500 | Infantry | — | 5 | No | No | 8 | — | 100 | Plasma | 40 | 5 | G | No | — | Teleport(friendly squad), Mind Control | — |
| 神童 [KW Traveler-59] | Prodigy | Scrin | KW | T3 | Portal | 2500 | 20 | 0 | 1500 | Infantry | — | 6 | No | No | 8 | — | 100 | Plasma | 40 | 5 | G | No | — | Teleport(area), Mind Control(area) | — |
| 枪行者 | Gun Walker | Scrin | TW/KW | T1 | Warp Sphere | 400 | 8 | 0 | 240 | Vehicle | — | 8 | No | No | 7 | — | 30×2 | Plasma | 20 | 5 | G | No | vs Infantry | — | — |
| 搜索者 | Seeker | Scrin | TW/KW | T1 | Warp Sphere | 600 | 8 | 0 | 1200 | Hover | — | 7 | No | Yes | 6 | — | 80 | Plasma | 50 | 5 | G/A | No | vs Vehicle/Air | — | — |
| 吞噬者坦克 | Devourer Tank | Scrin | TW/KW | T2 | Warp Sphere | 1100 | 12 | 0 | 2400 | Vehicle | — | 6 | No | No | 6 | — | 150 | Plasma | 70 | 5 | G | No | vs Vehicle | Charge(use Tiberium, +damage) | — |
| 腐化者 | Corrupter | Scrin | TW/KW | T2 | Warp Sphere | 900 | 12 | 0 | 600 | Vehicle | — | 5 | No | No | 6 | — | 60 | Liquid Tiberium | 40 | 4 | G | Yes | vs Infantry/Building | — | Heal friendly in Tiberium, Create Tiberium |
| 采矿车 | Harvester | Scrin | TW/KW | T1 | Warp Sphere | 1400 | 20 | 0 | 1200 | Vehicle | — | 4 | No | No | 4 | — | — | — | — | — | — | No | — | — | Heal in Tiberium |
| 探索者 | Explorer | Scrin | TW/KW | T1 | Warp Sphere | 1500 | 15 | 0 | 1500 | Vehicle | — | 4 | No | No | 5 | — | — | — | — | — | — | No | — | Deploy(Outpost) | — |
| 无人机船 | Drone Ship | Scrin | TW/KW | T1 | Warp Sphere | 1500 | 20 | 0 | 2000 | Vehicle | — | 3 | No | No | 4 | — | — | — | — | — | — | No | — | Deploy(Drone Platform) | — |
| Eradicator 六足 [KW Epic] | Eradicator Hexapod | Scrin | KW | Epic | Warp Sphere | 5000 | 60 | 0 | 30000 | Vehicle | — | 4 | No | No | 8 | — | 400×2 | Plasma | 80 | 7 | G | Yes | vs Vehicle/Building | — | Salvage(credits from kills) |
| Reaper 三足 [KW Epic Reaper-17] | Reaper Tripod | Scrin | KW | Epic | Warp Sphere | 5000 | 60 | 0 | 28000 | Vehicle | — | 4 | No | No | 8 | — | 350×2 | Plasma | 80 | 7 | G | Yes | vs Vehicle/Building | — | — |
| 风暴骑士 | Stormrider | Scrin | TW/KW | T1 | Gravity Stabilizer | 1000 | 12 | 0 | 640 | Aircraft | — | 14(fly) | Yes | No | 7 | — | 60 | Plasma | 30 | 5 | G/A | No | vs Vehicle/Air | — | Regenerate in Ion Storm |
| 毁灭者战舰 | Devastator Warship | Scrin | TW/KW | T3 | Gravity Stabilizer | 2000 | 20 | 0 | 1500 | Aircraft | — | 10(fly) | Yes | No | 8 | — | 250×2 | Plasma | 120 | 12 | G | Yes | vs Building | — | — |
| 行星突击航母 | Planetary Assault Carrier | Scrin | TW/KW | T3 | Gravity Stabilizer | 2500 | 25 | 0 | 1500 | Aircraft | — | 8(fly) | Yes | No | 8 | — | 30×5(drones) | Drone | 20 | 6 | G/A | No | vs All | Ion Storm(generate) | — |
| 母舰 | Mothership | Scrin | TW/KW | Epic/T3 | Gravity Stabilizer | 5000 | 60 | 0 | 8000 | Aircraft | — | 3(fly) | Yes | No | 10 | — | 5000 | Catalyst Cannon | 120 | 10 | G | Yes(catalyst chain) | vs All(base-killer) | — | — |

#### B.6 Scrin 建筑

| name_zh | name_en | faction | game | tier | built_from | cost | build_time | power_use | hp | armor | shields | speed | fly | hover | vision | transport_slots | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 无人机平台 | Drone Platform | Scrin | TW/KW | — | Drone Ship Deploy | —(Drone Ship) | — | 0 | 5000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 反应堆 | Reactor | Scrin | TW/KW | — | DP | 800 | 8 | +12(output) | 2000 | Structure | — | — | No | No | 4 | — | — | — | — | — | — | No | — | — | Power(+12) |
| 提取器 | Extractor | Scrin | TW/KW | — | DP | 3000 | 20 | -10 | 3000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Comes with 1 Harvester |
| 传送门 | Portal | Scrin | TW/KW | — | DP | 500 | 8 | -5 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 扭曲球 | Warp Sphere | Scrin | TW/KW | — | DP | 2000 | 15 | -8 | 3000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | — |
| 重力稳定器 | Gravity Stabilizer | Scrin | TW/KW | — | DP | 1000 | 10 | -8 | 2000 | Structure | — | — | No | No | 6 | — | — | — | — | — | — | No | — | — | Produces Aircraft |
| 神经中枢 | Nerve Center | Scrin | TW/KW | — | DP | 1500 | 12 | -8 | 2000 | Structure | — | — | No | No | 8 | — | — | — | — | — | — | No | — | — | Radar, Unlocks T2 |
| 科技组装器 | Technology Assembler | Scrin | TW/KW | — | DP | 2000 | 20 | -10 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Unlocks T3 |
| 铸造厂 | Foundry | Scrin | TW/KW | — | DP | 1000 | 10 | -5 | 2000 | Structure | — | — | No | No | 5 | — | — | — | — | — | — | No | — | — | Unit Upgrades |
| 信号发射器 | Signal Transmitter | Scrin | TW/KW | SW | DP | 3000 | 30 | -10 | 3000 | Structure | — | — | No | No | 5 | — | 1500 | Rift | 300 | Map | G | Yes(removes all units in area) | vs All | Rift Generator Strike | — |
| 蜂巢 | Buzzer Hive | Scrin | TW/KW | — | DP | 600 | 8 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 10×swarm | Buzzer | 10 | 5 | G | No | vs Infantry | — | — |
| 等离子导弹炮台 | Plasma Missile Battery | Scrin | TW/KW | — | DP | 800 | 10 | -5 | 2000 | Structure | — | — | No | No | 7 | — | 80×2 | Missile | 40 | 8 | A | Yes | vs Air | — | — |
| 闪电尖塔 | Lightning Spike | Scrin | TW/KW | — | DP | 1500 | 15 | -10 | 2000 | Structure | — | — | No | No | 8 | — | 200 | Lightning | 70 | 8 | G | No | vs Vehicle | — | — |

---

### C. Kane's Wrath 子阵营特化单位说明

KW 引入 6 个子阵营，每个子阵营有独特的单位替换和 Epic 单位：

| 子阵营 | 阵营 | Epic 单位 | 核心特化 | 特有/替换单位 |
|---|---|---|---|---|
| ZOCOM | GDI | MARV | 声波武器+泰矿回收 | Zone Raider(替换 Zone Trooper), Shatterer, Slingshot, MARV(采集泰矿生钱) |
| Steel Talons | GDI | Mastodon | 重装甲+轨道炮 | Titan(替换 Predator), Wolverine(替换 Pitbull 改为载具), Mastodon(轨道炮 Epic) |
| Black Hand | NOD | Purifier | 火焰+无空军 | Purifier(火焰 Epic), Mantis(替换 Attack Bike), Black Hand 步兵强化, 无 Venom/Vertigo |
| Marked of Kane | NOD | Redeemer | 半机械人+EMP | Awakened, Tiberium Trooper, Redeemer(EMP Epic), 改进型 Cyborg 体系 |
| Reaper-17 | Scrin | Reaper Tripod | 地面突击+护盾 | Shard Walker(替换 Gun Walker, 强化), Shielded Seeker, Reaper Tripod(Epic) |
| Traveler-59 | Scrin | Eradicator Hexapod | 速度+心灵控制 | Cultist(心灵控制), Prodigy(区域心灵控制), 更快的单位, Stalker |

---

### D. 超级武器对比

| 超级武器 | 阵营 | 游戏 | 建筑 | 冷却(秒) | 伤害 | 特殊效果 |
|---|---|---|---|---|---|---|
| Ion Cannon | GDI | TS/TW/KW | Upgrade Center(Ion Cannon Uplink) / Space Command Uplink | 360(TS) / 300(TW) | 1500(单点) | 精确打击，无持续效果 |
| Cluster Missile | NOD | TS | Temple of Nod | 360 | 1500 | 簇弹分散打击，污染区域 |
| Nuclear Missile | NOD | TW/KW | Temple of Nod | 300 | 1500 | 大范围爆炸+辐射残留 |
| Rift Generator | Scrin | TW/KW | Signal Transmitter | 300 | 1500+(吸收) | 制造时空裂隙，吞噬区域内所有单位(不分敌我)，持续数秒 |
| Tiberium Vapor Bomb | NOD | TW/KW | Air Tower(技能) | 180 | 800 | 污染泰矿场，降低敌方采集效率 |
| Catalyst Cannon | Scrin | TW/KW | Mothership | — | 5000(连锁) | 母舰主炮，击中后连锁爆炸，可夷平整个基地 |

---

### E. 通用机制说明

#### 1. 建造场系统（Construction Yard System）
- C&C 系列核心建筑机制。MCV/Drone Ship 展开为 Construction Yard/Drone Platform。
- 玩家从 CY 队列中选建筑，直接在地图上实体放置（受 Fog of War 限制需有视野）。
- 每个生产建筑（Barracks/War Factory/Airfield 等）有独立的生产队列。
- 建造多个同类生产建筑可加速生产（TW/KW 中允许排队加速）。

#### 2. 科技树解锁
- T1：Barracks/Hand of Nod/Portal（步兵）+ War Factory/Warp Sphere（载具）解锁基础单位。
- T2：Command Post/Operations Center/Nerve Center（雷达建筑）解锁 T2 单位+升级。
- T3：Tech Center/Tech Lab/Technology Assembler 解锁 T3 单位+高级升级。
- 超级武器：需 T3 前置，造价 3000 credits，冷却 300-360 秒。

#### 3. 装甲类型（TW/KW 细化）
- Infantry：步兵，弱点为火焰、狙击、声波
- Vehicle：载具，弱点为反坦克武器（Cannon/Railgun/Plasma）
- Aircraft：航空器，弱点为 AA 导弹/激光
- Structure：建筑，弱点为火炮/轰炸
- Hover：悬浮单位（如 Hover MLRS/Seeker），受 EMP 影响

#### 4. 泰伯利亚（Tiberium）机制
- 绿泰矿（Green Tiberium）：基础资源，100% 价值
- 蓝泰矿（Blue Tiberium）：高价值资源，150-200% 价值，但有毒，伤害步兵
- 泰矿会扩散（TS 中会变异地形，TW/KW 中为固定区域）
- Scrin 单位在泰矿中回血，GDI/NOD 步兵在泰矿中掉血（TS 中尤其明显）

---

## 附：数据可靠性与已知偏差

1. **数值精度**：本表中的 cost / hp / damage 数值为近似值，基于训练知识中的游戏数据。不同版本（1.0/1.01/1.09 patch）可能有 ±5-15% 偏差。
2. **TS vs TW/KW 数值体系**：TS 使用较旧的数值体系（HP 普遍更低），TW/KW 重新平衡了数值。两者不可直接跨游戏比较。
3. **升级未单独列出**：如 GDI Railgun Upgrade、NOD Dozer Blade、Scrin Tiberium Infusion 等升级会改变基础数值，本表以未升级基础值为准。
4. **KW 子阵营替换**：KW 子阵营会替换或移除某些基础单位（如 Black Hand 无空军、Steel Talons 用 Titan 替换 Predator），上表中 TW/KW 通用单位列出的是基础阵营（GDI/NOD/Scrin 主阵营）数据。
5. **建议核对**：如需精确数值用于游戏平衡设计，建议对照 Liquipedia 或 fandom wiki 的具体单位页面进行校验。

---

*文档结束*
