# 命令与征服：将军 + 绝命时刻 单位参考

> 数据版本: C&C Generals 1.08 + Zero Hour 1.04 / 数据源: cnc.fandom.com + Liquipedia + INI 数据挖掘 / 采集日期: 2026-06-17
> 说明: 将军的经济资源为"补给(Supply)"，电力为"Power"。GLA 不需要电力。数值取自原版 INI 文件，存在小幅版本差异时以 fandom wiki 为准。

---

## 第一部分：阵营设计分析

---

### USA（美国）

#### 1. 设计哲学一句话
**"高科技+空军+精确打击"** — 以无人机、激光武器和空中优势为核心，用精确火力取代人海，用科技弥补数量劣势。

#### 2. 核心签名机制
- **推土机(Dozer)建造系统**：Dozer 移动到目标位置建造建筑，建造期间 Dozer 被占用，建筑可被 Dozer 维修
- **策略中心(Strategy Center)**：三选一全局策略 — Bombardment（炮击+射程）/ Hold the Line（防御+装甲）/ Search and Destroy（索敌+视野），可切换
- **无人机(Drone)系统**：多数车辆可搭载 Scout Drone / Battle Drone / Spy Drone，提供侦察/维修/反步兵能力
- **空军优势**：拥有游戏中最强空军 — Raptor 制空、Comanche 对地、Aurora 超音速轰炸
- **精确打击将军技(Power)**：Level 1=Para Drop / Level 3=A-10 Strike / Level 5=Spectre Gunship / Level 5=Carpet Bomb / Level 8=Fuel Air Bomb(Aurora)

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Crusader | Paladin | — |
| 近战输出 | — | — | Colonel Burton |
| 远程输出 | Humvee(+步兵) | Crusader | Paladin |
| 攻城/远程 | — | Tomahawk | — |
| 防空 | Avenger / Missile Defender | Patriot Battery | Avenger |
| 骚扰 | Humvee+Ranger | Comanche | Aurora |
| 侦察 | Scout Drone | Pathfinder | Spy Drone(SD策略) |
| 运输 | Chinook | — | — |
| 防驻军 | Flashbang Ranger | Microwave Tank | — |
| 经济 | Chinook(采集) | Drop Zone(策略中心) | Hack(无) |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Crusader+Humvee 早期机动 | 缺乏反重甲手段 |
| T2 | 4-8min | 策略中心+Paladin 解锁 | 空军尚未成型 |
| T3 | 8min+ | Aurora+Particle Cannon | 经济压力大 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| **Crusader+Humvee+Missile Defender** | 早期主力 | 坦克前排+车栽步兵输出+反甲 |
| **Paladin+Avenger** | 防空推进 | Paladin 点防御激光拦截导弹+Avenger 防空 |
| **Comanche+A-10 Strike** | 空中突击 | Comanche 持续输出+A-10 将军技爆发 |
| **Aurora+Particle Cannon** | 超级武器 | 粒子炮定点+Aurora 超音速斩首 |
| **Microwave+Ranger(Flashbang)** | 清驻军 | 微波清建筑+闪光弹补刀 |
| **Tomahawk+Spectre Gunship** | 远程攻城 | 战斧导弹远程+幽灵炮艇持续压制 |
| **Pathfinder+Crusader** | 反步兵+坦克 | 狙击手隐身反步+坦克反甲 |

#### 6. 生产机制
- **Dozer 系统**：每个 Dozer $1000，移动到目标位置建造，建造期间 Dozer 被占用。可同时派多个 Dozer 建不同建筑。建筑可被 Dozer 维修。
- **空军生产**：Air Field 有停机位限制（4-8 架），飞机需要停机位才能生产
- **步兵升级**：Barracks 可升级 Flashbang（闪光弹反驻军/反步兵）和 Capture Building
- **策略中心**：建造后解锁 T3 单位（Paladin、Aurora、Tomahawk 等）和全局策略

#### 7. 机动哲学
- **空军主导**：Comanche 可悬停对地，Raptor 可巡逻制空，Aurora 超音速突防无法拦截
- **地面中等**：Crusader/Paladin 速度中等(25-30)，不如 GLA Technical 快
- **Humvee 快速穿插**：速度 40，可载 5 步兵，快速部署步兵到前线
- **Chinook 空投**：运输机可空投步兵到任意位置

#### 8. 视野与地图控制
- **Scout Drone**：车辆搭载的小型无人机，提供额外视野
- **Spy Drone（SD 策略）**：Search and Destroy 策略下可部署隐身侦察无人机
- **Pathfinder**：静止时隐身的狙击手，提供前线视野
- **Spectre Gunship**：将军技能提供大范围视野+火力
- **Patriot Battery**：防御建筑可连接火力网（互相覆盖射程）
- **劣势**：缺乏 GLA 隧道式的瞬间传送，侦察依赖无人机消耗

#### 9. 反制弱点
- **怕人海**：单位造价高，数量少，怕 China 红卫兵/GLA 暴民海
- **怕早期快攻**：T1 阶段反甲能力有限，怕 Scorpion rush
- **空军依赖停机位**：Air Field 被打掉则空军瘫痪
- **电力脆弱**：Cold Fusion Reactor 被摧毁则防御/科技停摆
- **Particle Cannon 充能慢**：超级武器启动慢，需 6 分钟

#### 10. 强势时间窗
- **3-5 分钟**：Crusader+Humvee 机动压制
- **6-8 分钟**：策略中心完成后 Paladin+Comanche 成型
- **10 分钟+**：Aurora+Particle Cannon 超级武器斩首

#### 11. 经济模型
- **补给中心(Supply Center)**：$1500 建造，Chinook $800/架 从补给堆采集
- **Chinook 效率**：每架 Chinook 持续往返搬运，效率高于 GLA Worker
- **Drop Zone**：策略中心可选策略之一可产生额外补给空投
- **无被动收入**：不像 China 的 Hacker 或 GLA 的 Black Market 有持续收入
- **电力**：Cold Fusion Reactor $800 产 5 电力，Control Rods 升级翻倍至 10

---

### China（中国）

#### 1. 设计哲学一句话
**"重装+核能+人海"** — 以重装甲碾压、核动力驱动、红卫兵人海为核心，用数量和重量压垮对手。

#### 2. 核心签名机制
- **推土机(Dozer)系统**：同 USA，Dozer 移动建造
- **黑客(Hacker)经济**：Hacker 可持续产钱（约 $5/秒/个），是后期主要收入来源
- **核能(Nuclear)系统**：Nuclear Reactor 产 10 电力（双倍于 USA）；Nuclear Missile 超级武器；Uranium Shells/Nuclear Tanks 升级
- **红卫兵 Horde Bonus**：红卫兵成群时获得火力加成（+15%），Nationalism 升级提升至 +30%
- **宣传塔(Speaker Tower)**：Troop Crawler/Overlord 可搭载，提供范围回血+士气加成
- **EM Pulse/Cluster Mines/Emergency Repair**：Command Center 将军技 — EMP 瘫痪车辆/集束雷封锁/紧急修理

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Battle Master | Overlord | Overlord(升级) |
| 近战输出 | Red Guard(horde) | — | — |
| 远程输出 | Gatling Tank | Gatling Tank | Overlord(Gatling) |
| 攻城/远程 | Dragon Tank | Inferno Cannon | Nuke Cannon |
| 防空 | Gatling Tank | Gatling Cannon(建筑) | — |
| 骚扰 | Dragon Tank | Mig | Helix |
| 侦察 | Troop Crawler | — | — |
| 运输 | Troop Crawler | — | Helix |
| 功能 | Black Lotus | Hacker | Black Lotus |
| 经济 | Supply Truck | Hacker | Hacker |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Battle Master+Red Guard 数量优势 | 缺乏反甲 |
| T2 | 4-8min | Overlord 解锁，压倒性火力 | 速度慢，怕空军 |
| T3 | 8min+ | Nuke Cannon+核升级 | 经济转型慢 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| **Overlord+Hacker** | 后期主力 | 炎黄碾压+黑客后排产钱+EM 瘫痪 |
| **Overlord(Gatling)+Overlord(Speaker)** | 空地一体 | 加特林防空+宣传塔回血 |
| **Red Guard+Tank Hunter** | 步兵海 | 红卫兵人海+坦克猎手反甲 |
| **Mig+Black Napalm** | 空军 | 米格燃烧弹叠加火海 |
| **Nuke Cannon+Troop Crawler** | 阵地推进 | 核炮远程+运兵车前压视野 |
| **Dragon Tank+Red Guard** | 清驻军 | 火龙坦克烧建筑+步兵占领 |
| **Inferno Cannon+Gatling Tank** | 中期推进 | 火炮洗地+加特林防空防步 |

#### 6. 生产机制
- **Dozer 系统**：同 USA
- **红卫兵成对生产**：每次生产 2 个 Red Guard（$300/2），人海基础
- **Troop Crawler 自带 8 红卫兵**：$1000 含 8 个红卫兵，出厂即满载
- **Overlord 三选一升级**：Gatling Cannon（防空）/ Bunker（驻军5）/ Speaker Tower（回血），建造后不可更换
- **Hacker 持续产钱**：Hacker $200，部署后每秒产 ~$5，可叠多个

#### 7. 机动哲学
- **重型慢速**：Overlord 速度 20（最慢），Battle Master 速度 30
- **Troop Crawler 快速部署**：速度 40，可快速将步兵送到前线
- **Mig 空中突击**：速度 45，燃烧弹对地
- **Helix 重型直升机**（绝命时刻）：速度 30，可载兵/载坦克，可升级加特林/核弹/宣传塔
- **EM Pulse**：范围瘫痪所有车辆，创造推进窗口

#### 8. 视野与地图控制
- **Troop Crawler**：自带 Speaker Tower 提供视野
- **Radar**：Command Center 提供雷达
- **Cluster Mines**：将军技空投地雷封锁路口
- **Helix**：提供空中视野
- **劣势**：地面单位慢，侦察范围有限，缺乏隐身侦察

#### 9. 反制弱点
- **怕空军**：防空依赖 Gatling Tank/Cannon，射程有限
- **速度慢**：Overlord/Nuke Cannon 极慢，容易被风筝
- **怕游击**：GLA 隧道网络可绕后骚扰
- **电力集中**：Nuclear Reactor 被打掉则全停（10 电力一个大目标）
- **核弹发射井目标大**：Nuclear Missile Silo 占地大，易被斩首

#### 10. 强势时间窗
- **2-4 分钟**：Battle Master+Red Guard 一波 rush
- **6-8 分钟**：Overlord 解锁，重装甲碾压
- **10 分钟+**：核升级完成（Uranium Shells+Nuclear Tanks），全队增强

#### 11. 经济模型
- **补给中心+Supply Truck**：$1500 建造，Supply Truck $300/辆
- **Hacker 被动收入**：$200/个，部署后 ~$5/s，后期主力收入（5 个 Hacker = $25/s）
- **电力**：Nuclear Reactor $1000 产 10 电力（效率高于 USA），但单体目标大
- **核弹**：Nuclear Missile $5000，6 分钟充能

---

### GLA（全球解放军）

#### 1. 设计哲学一句话
**"游击+黑市+生化"** — 以低成本单位、隧道网络机动、毒素武器和黑市经济为核心，用不对称战争拖垮高科技对手。

#### 2. 核心签名机制
- **工人(Worker)建造**：Worker $200 建造所有建筑，便宜但脆弱
- **隧道网络(Tunnel Network)**：隧道入口 $800，所有隧道互通，单位进入一个可从任意另一个出来，无限驻军回血
- **黑市(Black Market)**：$2500，持续产钱 + 提供大量升级（AP Rockets、Toxin Shells、Junk Repair 等）
- **拾荒(Salvage)系统**：摧毁敌方车辆掉落残骸，Technical/Combat Cycle 可拾取升级武器/装甲（最多 3 级）
- **毒素(Toxin)**：Toxin Tractor、Toxin Shells 升级、Anthrax 升级，对步兵有持续伤害
- **无需电力**：GLA 所有建筑不需要电力，这是最大经济优势
- **Scud Storm**：超级武器，毒素+爆炸混合伤害

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Scorpion | Marauder | — |
| 近战输出 | Terrorist | Angry Mob | Angry Mob(升级) |
| 远程输出 | Technical | Rocket Buggy | — |
| 攻城/远程 | — | Scud Launcher | — |
| 防空 | Quad Cannon | Stinger Site | Quad Cannon(升级) |
| 骚扰 | Technical+Terrorist | Rocket Buggy | Combat Cycle |
| 侦察 | Worker | Jarmen Kell | — |
| 防驻军 | Toxin Tractor | — | — |
| 运输 | Technical | Tunnel Network | — |
| 经济 | Worker | Black Market | Black Market |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Technical+Terrorist 极速骚扰 | 正面战斗力弱 |
| T2 | 4-8min | Scorpion+Toxin 解锁 | 缺乏重型单位 |
| T3 | 8min+ | Marauder+Scud Storm | 升级依赖黑市 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| **Toxin Tractor+Terrorist** | 毒+爆 | 毒素清步+恐怖分子自爆车辆 |
| **Technical+Terrorist（车栽）** | 游击骚扰 | 皮卡运恐怖分子冲基地自爆 |
| **Scorpion+Rocket Buggy** | 中期主力 | 蝎子坦克前排+火箭车远程 |
| **Tunnel Network+Stinger Site** | 防守体系 | 隧道驻军+毒刺防空=区域拒止 |
| **Quad Cannon+Jarmen Kell** | 反装甲+防空 | 四管炮防空+贾曼狙杀驾驶员 |
| **Angry Mob+Toxin Shells** | 后期人海 | 暴民升级后极强+毒素加持 |
| **Bomb Truck(伪装)+Scud Launcher** | 斩首 | 伪装卡车偷袭+飞毛腿远程 |

#### 6. 生产机制
- **Worker 建造**：Worker $200（最便宜建造单位），可建造所有建筑，但极脆弱
- **无需电力**：所有建筑零电力消耗，无需建造发电厂，省下大量经济
- **Arms Dealer**：$2000，相当于 War Factory
- **Palace**：$1500，可驻军 10 人，提供升级（Anthrax、AP Rockets 等）
- **Black Market**：$2500，持续产钱 + 解锁关键升级
- **Angry Mob**：$800，一组暴民（5 人初始），可升级 AK47

#### 7. 机动哲学
- **隧道瞬间传送**：Tunnel Network 是 GLA 核心机动 — 单位进入一个隧道，可从地图任意隧道出口出来
- **Technical 极速**：速度 45，最快地面单位之一
- **Rocket Buggy 风筝**：速度 50，打完就跑
- **Combat Cycle**（绝命时刻）：速度 55，最快单位，可穿越某些地形
- **Bomb Truck 伪装**：可伪装成敌方车辆，偷袭基地
- **Hijacker**：可偷取敌方车辆

#### 8. 视野与地图控制
- **Tunnel Network 遍布地图**：隧道入口提供视野
- **Jarmen Kell**：英雄单位，隐身狙击手，可狙杀车辆驾驶员（车辆变为中立可被占领）
- **Radar Scan**：Command Center 技能，扫描指定区域
- **GPS Scrambler**（绝命时刻将军技）：隐身所有单位
- **劣势**：缺乏持续空中侦察

#### 9. 反制弱点
- **怕重装甲**：Scorpion/Marauder 火力不如 Crusader/Overlord
- **怕空军**：防空依赖 Quad Cannon/Stinger Site，射程有限
- **无空军**：完全没有飞行单位（绝命时刻也仅增加地面单位）
- **建筑脆弱**：无电力意味着防御建筑也弱
- **怕扫荡**：隧道网络被打掉则机动性大减

#### 10. 强势时间窗
- **1-3 分钟**：Technical+Terrorist 极速骚扰
- **4-6 分钟**：Scorpion 海+毒素升级
- **8 分钟+**：Marauder+Scud Storm+Angry Mob 后期

#### 11. 经济模型
- **Supply Stash+Worker**：$1500 建造，Worker $200/个，采集效率低（Worker 慢且少）
- **Black Market 被动收入**：$2500 建造，持续产钱 ~$20/s，可叠多个
- **零电力成本**：无需建造发电厂，省 $800-1600
- **拾残骸升级**：免费从战场获取升级，变相省钱
- **Scud Storm**：$5000，5 分钟充能（比 USA/China 快 1 分钟）

---

## 第二部分：将军变体特色（绝命时刻）

绝命时刻为每个阵营增加 3 个将军变体，每个将军有独特单位和改动。

---

### USA 将军

#### 空军将军 (Air Force General — Malcolm Granger)
- **签名改动**：King Raptor（增强版 Raptor，自带 Countermeasures+点防御激光）、Combat Chinook（武装版 Chinook，可采集+运输+自卫）、Stealth Fighter 无需将军技即可生产
- **特色**：飞机造价降低 ~20%，Air Field 造价降低，所有飞机自带 Countermeasures
- **弱点**：地面单位受限（无 Paladin），步兵科技慢

#### 超级武器将军 (Super Weapon General — Alexis Alexander)
- **签名改动**：EMP Patriot（电磁爱国者，瘫痪车辆而非摧毁）、Alpha Aurora（增强版曙光，更大燃料空气弹）、Particle Cannon 造价降低
- **特色**：防御建筑更强更便宜，超级武器充能更快，可建造额外 Particle Cannon
- **弱点**：地面进攻单位弱（无 Comanche），依赖防守+超级武器

#### 激光将军 (Laser General — Townes)
- **签名改动**：Laser Tank（替代 Crusader，激光武器+需消耗电力）、Laser Turret（替代 Patriot，激光防御塔）、Laser Crusader
- **特色**：所有武器激光化，高精度高伤害，但极度依赖电力
- **弱点**：电力被毁则全瘫，无传统坦克（无 Paladin/Tomahawk），造价高

---

### China 将军

#### 步兵将军 (Infantry General — Shin Fai)
- **签名改动**：Mini-Gunner（替代 Red Guard，加特林步兵对空对地）、Assault Troop Transport（两栖运兵车，替代 Troop Crawler）、Chem Suit（全步兵防毒升级）
- **特色**：步兵更强更便宜，所有步兵有防毒服，Assault Troop Transport 可水陆两用
- **弱点**：坦克受限（无 Overlord），依赖步兵海

#### 坦克将军 (Tank General — Ta Hun Kwai)
- **签名改动**：Emperor Overlord（增强版炎黄，自带 Speaker Tower）、Battle Master 出厂即老兵级别、Tank Drop（将军技空投坦克）
- **特色**：坦克造价降低 ~10%，所有坦克出厂即升级，可空投 Battle Master
- **弱点**：无 Nuke Cannon，无步兵增强，步兵弱

#### 核能将军 (Nuke General — Tsing Shi Tao)
- **签名改动**：Nuclear Battle Master（核动力版主战坦克，更快+核弹攻击）、Nuke Mig（核弹版米格）、Fusion Reactor（增强版核反应堆，更多电力）
- **特色**：所有坦克核动力化（速度+25%），Isotope Stability 升级防辐射自伤，Mig 核弹威力大
- **弱点**：核弹有自伤风险（未升级前），步兵无增强

---

### GLA 将军

#### 毒素将军 (Toxin General — Dr. Thrax)
- **签名改动**：Toxin Rebel（毒素版叛军，出厂即毒素攻击）、Toxin Tunnel Network（毒素隧道，喷射毒素而非子弹）、Anthrax Beta（更强毒素升级，紫色的安萨里-B）
- **特色**：所有单位毒素化，Anthrax 升级更强，毒素对步兵毁灭性
- **弱点**：反装甲能力弱（毒素对车辆伤害低），无 Bomb Truck

#### 爆破将军 (Demolition General — General Juhziz)
- **签名改动**：Demo Rebel（自爆叛军，死亡时爆炸）、Demo Trap（地雷陷阱，可手动引爆）、增强版 Bomb Truck（更大爆炸+毒素）
- **特色**：所有自爆单位威力更大，Terrorist 更强更快，可布设地雷阵
- **弱点**：缺乏正面战斗单位，依赖自杀战术，无 Toxin

#### 匿踪将军 (Stealth General — Prince Kassad)
- **签名改动**：Stealth Rebel（永久隐身叛军）、Hijacker 出厂即隐身且无需 Palace、GPS Scrambler（将军技，全队隐身）
- **特色**：所有步兵隐身，Saboteur（替代 Hijacker，可破坏建筑而非偷车），隧道网络隐身
- **弱点**：无 Quad Cannon（防空弱），无 Scud Launcher，正面火力弱

---

## 第三部分：单位数据表

> 字段说明: cost_supply = 补给价格($); power_use = 电力消耗(负值=提供电力); build_time = 秒; hp = 生命值; speed = 游戏内速度单位; range = 游戏内距离单位; cooldown = 秒
> GLA 所有建筑 power_use = 0（不需要电力）

---

### USA 单位

#### Dozer（推土机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 推土机 / Construction Dozer |
| | faction / tier | USA / T0 |
| **生产** | built_from | Command Center |
| | cost_supply | $1000 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | 建造建筑、维修建筑/车辆 |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Crusader Tank（十字军坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 十字军坦克 / Crusader Tank |
| | faction / tier | USA / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $900 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 300 |
| | armor_type | Tank |
| | tags | 机械, 坦克, 重甲 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 60 |
| | atk_type | Explosive (对车辆) |
| | cooldown | 1.5s |
| | range | 150 |
| | target | G (地面) |
| | splash | 0 |
| | bonus_vs | — |
| **技能** | active[] | 搭载无人机 |
| | passive[] | — |
| **升级** | upgrades[] | Composite Armor (+HP)、Drone (Scout/Battle/Spy) |

#### Paladin Tank（圣骑士坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 圣骑士坦克 / Paladin Tank |
| | faction / tier | USA / T2 |
| **生产** | built_from | War Factory (需 Strategy Center) |
| | cost_supply | $1100 |
| | build_time | 12s |
| | power_use | 0 |
| **生存** | hp | 400 |
| | armor_type | Tank |
| | tags | 机械, 坦克, 重甲 |
| **机动** | speed | 25 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 80 |
| | atk_type | Explosive |
| | cooldown | 1.8s |
| | range | 150 |
| | target | G |
| | splash | 0 |
| | bonus_vs | — |
| **技能** | active[] | Point Defense Laser (点防御激光，拦截来袭导弹) |
| | passive[] | — |
| **升级** | upgrades[] | Composite Armor (+HP)、Drone |

#### Humvee（悍马车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 悍马 / Humvee |
| | faction / tier | USA / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $600 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 160 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 40 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 20 (机枪) |
| | atk_type | Normal (对步兵) |
| | cooldown | 0.5s |
| | range | 100 |
| | target | G+A |
| | splash | 0 |
| | bonus_vs | — |
| **技能** | active[] | 运输 5 步兵(步兵可对外射击) |
| | passive[] | — |
| **升级** | upgrades[] | TOW Missile (反坦克导弹)、Drone |

#### Tomahawk Launcher（战斧导弹发射车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 战斧导弹车 / Tomahawk Launcher |
| | faction / tier | USA / T2 |
| **生产** | built_from | War Factory (需 Strategy Center) |
| | cost_supply | $1200 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 120 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 180 |
| **攻击** | damage | 200 |
| | atk_type | Explosive |
| | cooldown | 5s |
| | range | 350 |
| | target | G |
| | splash | 20 |
| | bonus_vs | 建筑×1.5 |
| **技能** | active[] | — |
| | passive[] | — |
| **升级** | upgrades[] | Drone、Waypoint Targeting (射程+) |

#### Ambulance（救护车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 救护车 / Ambulance |
| | faction / tier | USA / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $600 |
| | build_time | 8s |
| | power_use | 0 |
| **生存** | hp | 160 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 35 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | 治疗周围步兵、清除毒素/辐射、运输 3 步兵 |
| | passive[] | 自动治疗范围 |
| **升级** | upgrades[] | Drone |

#### Microwave Tank（微波坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 微波坦克 / Microwave Tank |
| | faction / tier | USA / T2 |
| **生产** | built_from | War Factory (需 Strategy Center) |
| | cost_supply | $800 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Tank |
| | tags | 机械, 坦克 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | — (微波清驻军，不直接杀伤) |
| | atk_type | — |
| | range | 100 |
| | target | G |
| **技能** | active[] | 清空驻军建筑中的敌方步兵 |
| | passive[] | — |
| **升级** | upgrades[] | Drone |

#### Avenger（复仇者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 复仇者 / Avenger |
| | faction / tier | USA / T2 |
| **生产** | built_from | War Factory (需 Strategy Center) |
| | cost_supply | $1500 |
| | build_time | 12s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 180 |
| **攻击** | damage | 25 (激光) |
| | atk_type | — |
| | cooldown | 1.0s |
| | range | 200 |
| | target | A (空中) |
| **技能** | active[] | Target Painter (标记目标，友军对其+伤害) |
| | passive[] | 点防御激光 |
| **升级** | upgrades[] | Drone |

#### Ranger（游骑兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 游骑兵 / Ranger |
| | faction / tier | USA / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $225 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 15 |
| | atk_type | Normal |
| | cooldown | 0.5s |
| | range | 100 |
| | target | G+A |
| | splash | 0 |
| **技能** | active[] | Flashbang (闪光弹，清驻军+范围伤害) |
| | passive[] | — |
| **升级** | upgrades[] | Flashbang Grenades、Capture Building |

#### Missile Defender（导弹防御兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 导弹防御兵 / Missile Defender |
| | faction / tier | USA / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $300 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 40 |
| | atk_type | Explosive (反装甲) |
| | cooldown | 1.0s |
| | range | 150 |
| | target | G+A |
| | splash | 0 |
| | bonus_vs | 坦克/车辆×1.5 |
| **技能** | active[] | Laser Lock (激光锁定，持续对单目标射速+) |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Pathfinder（探路者狙击手）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 探路者 / Pathfinder |
| | faction / tier | USA / T2 |
| **生产** | built_from | Barracks (需 Strategy Center) |
| | cost_supply | $600 |
| | build_time | 8s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | 200 |
| | atk_type | Normal |
| | cooldown | 3.0s |
| | range | 250 |
| | target | G |
| | splash | 0 |
| | bonus_vs | 步兵×5 |
| **技能** | active[] | — |
| | passive[] | 静止时隐身 |
| **升级** | upgrades[] | — |

#### Colonel Burton（伯顿上校）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 伯顿上校 / Colonel Burton |
| | faction / tier | USA / T3 (Hero) |
| **生产** | built_from | Barracks (需 Strategy Center) |
| | cost_supply | $1500 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Infantry |
| | tags | 生物, 步兵, 英雄 |
| **机动** | speed | 25 |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | 50 (步枪) / 200 (刀) |
| | atk_type | Normal |
| | cooldown | 0.5s / — |
| | range | 150 (步枪) / 近战 (刀) |
| | target | G |
| **技能** | active[] | 隐身、Knife Kill(无声暗杀)、Demo Charge(放置炸药) |
| | passive[] | 攀爬地形 |
| **升级** | upgrades[] | — |

#### Comanche（卡曼奇直升机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 卡曼奇 / Comanche |
| | faction / tier | USA / T2 |
| **生产** | built_from | Air Field |
| | cost_supply | $1200 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Aircraft |
| | tags | 机械, 飞行器 |
| **机动** | speed | 36 |
| | fly / hover | true / true |
| | vision | 200 |
| **攻击** | damage | 20 (机枪) + 30×4 (火箭) |
| | atk_type | Normal / Explosive |
| | cooldown | 0.3s / 3s |
| | range | 150 |
| | target | G |
| | splash | 5 (火箭) |
| **技能** | active[] | Rocket Pods (火箭齐射) |
| | passive[] | 可悬停 |
| **升级** | upgrades[] | Rocket Pods、Countermeasures (闪避导弹) |

#### Raptor（猛禽战斗机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 猛禽 / Raptor |
| | faction / tier | USA / T1 |
| **生产** | built_from | Air Field |
| | cost_supply | $1000 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 150 |
| | armor_type | Aircraft |
| | tags | 机械, 飞行器 |
| **机动** | speed | 45 |
| | fly / hover | true / false |
| | vision | 200 |
| **攻击** | damage | 100×2 (导弹) |
| | atk_type | Explosive |
| | cooldown | 1s (需返航装弹) |
| | range | 150 |
| | target | G+A |
| | splash | 10 |
| **技能** | active[] | — |
| | passive[] | — |
| **升级** | upgrades[] | Countermeasures、Laser Missiles (伤害+) |

#### Aurora Bomber（曙光轰炸机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 曙光轰炸机 / Aurora Bomber |
| | faction / tier | USA / T3 |
| **生产** | built_from | Air Field (需 Strategy Center) |
| | cost_supply | $2000 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 120 |
| | armor_type | Aircraft |
| | tags | 机械, 飞行器 |
| **机动** | speed | 90 (超音速突防) / 30 (投弹后) |
| | fly / hover | true / false |
| | vision | 200 |
| **攻击** | damage | 500 (燃料空气弹) |
| | atk_type | Explosive |
| | cooldown | 1次/架次 |
| | range | — (定点轰炸) |
| | target | G |
| | splash | 80 |
| **技能** | active[] | 超音速突防(突防阶段无法被拦截) |
| | passive[] | — |
| **升级** | upgrades[] | Bunker Buster (反地下目标) |

#### Chinook（支奴干直升机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 支奴干 / Chinook |
| | faction / tier | USA / T0 |
| **生产** | built_from | Supply Center |
| | cost_supply | $800 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Aircraft |
| | tags | 机械, 飞行器, 运输 |
| **机动** | speed | 30 |
| | fly / hover | true / true |
| | vision | 200 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | 采集补给、运输 8 步兵、空投 |
| | passive[] | — |
| **升级** | upgrades[] | — |

---

### China 单位

#### Dozer（推土机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 推土机 / Construction Dozer |
| | faction / tier | China / T0 |
| **生产** | built_from | Command Center |
| | cost_supply | $1000 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | 建造建筑、维修建筑/车辆 |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Battle Master Tank（主战坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 战斗大师 / Battle Master Tank |
| | faction / tier | China / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $800 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 300 |
| | armor_type | Tank |
| | tags | 机械, 坦克, 重甲 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 60 |
| | atk_type | Explosive |
| | cooldown | 1.5s |
| | range | 150 |
| | target | G |
| | splash | 0 |
| **技能** | active[] | — |
| | passive[] | — |
| **升级** | upgrades[] | Uranium Shells (伤害+)、Nuclear Tanks (速度+)、Chain Guns |

#### Overlord Tank（炎黄坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 炎黄坦克 / Overlord Tank |
| | faction / tier | China / T2 |
| **生产** | built_from | War Factory (需 Propaganda Center) |
| | cost_supply | $1600 |
| | build_time | 20s |
| | power_use | 0 |
| **生存** | hp | 600 |
| | armor_type | Tank |
| | tags | 机械, 坦克, 重甲 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 90 |
| | atk_type | Explosive |
| | cooldown | 2.0s |
| | range | 150 |
| | target | G |
| | splash | 10 |
| **技能** | active[] | 可碾压小车辆 |
| | passive[] | — |
| **升级** | upgrades[] | Gatling Cannon(防空加特林) / Bunker(驻军5人) / Speaker Tower(回血光环)，三选一；Uranium Shells、Nuclear Tanks |

#### Dragon Tank（火龙坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 火龙坦克 / Dragon Tank |
| | faction / tier | China / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $600 |
| | build_time | 8s |
| | power_use | 0 |
| **生存** | hp | 250 |
| | armor_type | Tank |
| | tags | 机械, 坦克 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 25/s (火焰持续) |
| | atk_type | — |
| | cooldown | 持续 |
| | range | 80 |
| | target | G |
| | splash | 30 |
| **技能** | active[] | Fire Wall (部署火墙) |
| | passive[] | — |
| **升级** | upgrades[] | Black Napalm (火焰伤害+) |

#### Nuke Cannon（核炮）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 核炮 / Nuke Cannon |
| | faction / tier | China / T3 |
| **生产** | built_from | War Factory (需 Propaganda Center) |
| | cost_supply | $1600 |
| | build_time | 20s |
| | power_use | 0 |
| **生存** | hp | 150 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 15 (最慢) |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | 300 |
| | atk_type | Explosive |
| | cooldown | 6s |
| | range | 400 |
| | target | G |
| | splash | 60 |
| | bonus_vs | 建筑×1.5 |
| **技能** | active[] | 部署/收起(需部署才能射击) |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Gatling Tank（加特林坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 加特林坦克 / Gatling Tank |
| | faction / tier | China / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $700 |
| | build_time | 8s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 35 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 10×8 (加特林连射) |
| | atk_type | Normal |
| | cooldown | 0.1s/发 |
| | range | 120 |
| | target | G+A |
| | splash | 0 |
| **技能** | active[] | — |
| | passive[] | 射速随持续射击提升 |
| **升级** | upgrades[] | Chain Guns (射速+) |

#### Inferno Cannon（炎炮）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 炎炮 / Inferno Cannon |
| | faction / tier | China / T2 |
| **生产** | built_from | War Factory (需 Propaganda Center) |
| | cost_supply | $900 |
| | build_time | 12s |
| | power_use | 0 |
| **生存** | hp | 150 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | 70 |
| | atk_type | — |
| | cooldown | 3s |
| | range | 250 |
| | target | G |
| | splash | 25 |
| **技能** | active[] | — |
| | passive[] | 火焰持续伤害 |
| **升级** | upgrades[] | Black Napalm |

#### Troop Crawler（运兵车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 运兵车 / Troop Crawler |
| | faction / tier | China / T1 |
| **生产** | built_from | War Factory |
| | cost_supply | $1000 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 300 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 运输 |
| **机动** | speed | 40 |
| | fly / hover | false / false |
| | vision | 180 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | 出厂自带 8 红卫兵、Speaker Tower(回血光环) |
| | passive[] | 范围回血 |
| **升级** | upgrades[] | Subliminal Messaging (回血+) |

#### Hacker（黑客）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 黑客 / Hacker |
| | faction / tier | China / T2 |
| **生产** | built_from | Barracks (需 Propaganda Center) |
| | cost_supply | $200 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 15 |
| | fly / hover | false / false |
| | vision | 100 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | Internet Hack (持续产钱 ~$5/s)、Disable Building (瘫痪敌方建筑) |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Red Guard（红卫兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 红卫兵 / Red Guard |
| | faction / tier | China / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $300 (2个) |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 15 |
| | atk_type | Normal |
| | cooldown | 0.5s |
| | range | 100 |
| | target | G+A |
| | splash | 0 |
| **技能** | active[] | Capture Building |
| | passive[] | Horde Bonus (5+人时伤害+15%) |
| **升级** | upgrades[] | Patriotism (Horde Bonus 提升至+30%)、Nationalism (进一步强化) |

#### Tank Hunter（坦克猎手）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 坦克猎手 / Tank Hunter |
| | faction / tier | China / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $300 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 40 |
| | atk_type | Explosive |
| | cooldown | 1.0s |
| | range | 150 |
| | target | G |
| | splash | 0 |
| | bonus_vs | 坦克/车辆×1.5 |
| **技能** | active[] | TNT Charge (放置炸药在车辆/建筑上) |
| | passive[] | Horde Bonus |
| **升级** | upgrades[] | Nationalism |

#### Black Lotus（黑莲花）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 黑莲花 / Black Lotus |
| | faction / tier | China / T2 (Hero) |
| **生产** | built_from | Barracks (需 Propaganda Center) |
| | cost_supply | $1500 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 150 |
| | armor_type | Infantry |
| | tags | 生物, 步兵, 英雄 |
| **机动** | speed | 25 |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | Capture Building(远程占领建筑)、Disable Vehicle(瘫痪车辆)、Cash Hack(偷钱) |
| | passive[] | 隐身(静止时) |
| **升级** | upgrades[] | — |

#### Mig（米格战斗机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 米格 / Mig |
| | faction / tier | China / T2 |
| **生产** | built_from | Air Field |
| | cost_supply | $1000 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 150 |
| | armor_type | Aircraft |
| | tags | 机械, 飞行器 |
| **机动** | speed | 45 |
| | fly / hover | true / false |
| | vision | 200 |
| **攻击** | damage | 60×2 (燃烧弹) |
| | atk_type | Explosive |
| | cooldown | 1s (需返航装弹) |
| | range | 150 |
| | target | G+A |
| | splash | 20 |
| **技能** | active[] | — |
| | passive[] | 多架 Mig 叠加可触发 Fire Storm (火风暴) |
| **升级** | upgrades[] | Black Napalm、Mig Armor |

#### Helix（重型直升机，绝命时刻）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 重型直升机 / Helix |
| | faction / tier | China / T2 |
| **生产** | built_from | Air Field |
| | cost_supply | $1200 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 300 |
| | armor_type | Aircraft |
| | tags | 机械, 飞行器, 运输 |
| **机动** | speed | 30 |
| | fly / hover | true / true |
| | vision | 200 |
| **攻击** | damage | — (基础无武装) |
| | atk_type | — |
| **技能** | active[] | 运输 1 辆车辆或 8 步兵、可空投 |
| | passive[] | — |
| **升级** | upgrades[] | Gatling Cannon(加特林)、Speaker Tower(宣传塔)、Napalm Bomb(凝固汽油弹)、Nuclear Bomb(核弹) |

---

### GLA 单位

#### Worker（工人）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 工人 / Worker |
| | faction / tier | GLA / T0 |
| **生产** | built_from | Supply Stash / Command Center |
| | cost_supply | $200 |
| | build_time | 3s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵, 工人 |
| **机动** | speed | 25 |
| | fly / hover | false / false |
| | vision | 100 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | 建造建筑、采集补给 |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Scorpion Tank（蝎子坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 蝎子坦克 / Scorpion Tank |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Arms Dealer |
| | cost_supply | $600 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 250 |
| | armor_type | Tank |
| | tags | 机械, 坦克 |
| **机动** | speed | 35 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 40 |
| | atk_type | Explosive |
| | cooldown | 1.5s |
| | range | 130 |
| | target | G |
| | splash | 0 |
| **技能** | active[] | — |
| | passive[] | — |
| **升级** | upgrades[] | Toxin Shells(毒素弹)、AP Rockets(反坦克火箭)、Camo Netting(伪装) |

#### Marauder Tank（掠夺者坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 掠夺者 / Marauder Tank |
| | faction / tier | GLA / T2 |
| **生产** | built_from | Arms Dealer (需 Palace) |
| | cost_supply | $900 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 350 |
| | armor_type | Tank |
| | tags | 机械, 坦克, 重甲 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 60 |
| | atk_type | Explosive |
| | cooldown | 1.5s |
| | range | 150 |
| | target | G |
| | splash | 0 |
| **技能** | active[] | 拾取残骸升级（最多3级，每级+伤害/+炮管） |
| | passive[] | — |
| **升级** | upgrades[] | Salvage(拾荒)、AP Rockets、Junk Repair |

#### Technical（武装皮卡）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 武装皮卡 / Technical |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Arms Dealer |
| | cost_supply | $500 |
| | build_time | 3s |
| | power_use | 0 |
| **生存** | hp | 120 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 45 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 15 (机枪) |
| | atk_type | Normal |
| | cooldown | 0.3s |
| | range | 100 |
| | target | G+A |
| | splash | 0 |
| **技能** | active[] | 运输 5 步兵、拾取残骸升级(1级:炮、2级:加特林、3级:火箭) |
| | passive[] | — |
| **升级** | upgrades[] | Salvage |

#### Rocket Buggy（火箭车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 火箭车 / Rocket Buggy |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Arms Dealer |
| | cost_supply | $600 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 50 |
| | fly / hover | false / false |
| | vision | 180 |
| **攻击** | damage | 30×6 (火箭齐射) |
| | atk_type | Explosive |
| | cooldown | 4s |
| | range | 250 |
| | target | G |
| | splash | 10 |
| **技能** | active[] | — |
| | passive[] | — |
| **升级** | upgrades[] | Buggy Ammo(弹药+)、AP Rockets |

#### Scud Launcher（飞毛腿导弹车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 飞毛腿 / Scud Launcher |
| | faction / tier | GLA / T2 |
| **生产** | built_from | Arms Dealer (需 Palace) |
| | cost_supply | $1200 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 120 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | 200 |
| | atk_type | Explosive |
| | cooldown | 8s |
| | range | 350 |
| | target | G |
| | splash | 40 |
| **技能** | active[] | 可选毒素弹头 |
| | passive[] | — |
| **升级** | upgrades[] | Toxin Shells |

#### Bomb Truck（炸弹卡车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 炸弹卡车 / Bomb Truck |
| | faction / tier | GLA / T2 |
| **生产** | built_from | Arms Dealer |
| | cost_supply | $1200 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 40 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 500 (自爆) |
| | atk_type | Explosive |
| | cooldown | 1次 |
| | range | 0 (自爆) |
| | target | G |
| | splash | 80 |
| **技能** | active[] | 伪装成敌方车辆、可选毒素/高爆装药 |
| | passive[] | — |
| **升级** | upgrades[] | Toxin Shells、High Explosive Bombs |

#### Quad Cannon（四管炮）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 四管炮 / Quad Cannon |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Arms Dealer |
| | cost_supply | $500 |
| | build_time | 5s |
| | power_use | 0 |
| **生存** | hp | 150 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 35 |
| | fly / hover | false / false |
| | vision | 180 |
| **攻击** | damage | 10×4 (加特林) |
| | atk_type | Normal |
| | cooldown | 0.2s/发 |
| | range | 150 |
| | target | A+G |
| | splash | 0 |
| | bonus_vs | 飞行器×1.5 |
| **技能** | active[] | 拾取残骸升级(射速+) |
| | passive[] | — |
| **升级** | upgrades[] | Salvage、AP Shells |

#### Toxin Tractor（毒气拖拉机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 毒气拖拉机 / Toxin Tractor |
| | faction / tier | GLA / T2 |
| **生产** | built_from | Arms Dealer (需 Palace) |
| | cost_supply | $600 |
| | build_time | 8s |
| | power_use | 0 |
| **生存** | hp | 200 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆 |
| **机动** | speed | 30 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 20/s (毒素持续) |
| | atk_type | — |
| | cooldown | 持续 |
| | range | 80 |
| | target | G |
| | splash | 30 |
| | bonus_vs | 步兵×3 |
| **技能** | active[] | Contaminate(污染区域)、清驻军 |
| | passive[] | — |
| **升级** | upgrades[] | Anthrax Gamma(毒素伤害+) |

#### Combat Cycle（战斗摩托，绝命时刻）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 战斗摩托 / Combat Cycle |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Arms Dealer (需 Black Market) |
| | cost_supply | $500 |
| | build_time | 3s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Vehicle |
| | tags | 机械, 车辆, 轻甲 |
| **机动** | speed | 55 (最快) |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 骑手武器(取决于搭载步兵类型) |
| | atk_type | — |
| | cooldown | — |
| | range | 120 |
| | target | G+A |
| **技能** | active[] | 可搭载不同步兵改变武器(Rebel=RPG、Terrorist=自爆、Hijacker=偷车)、拾取残骸升级 |
| | passive[] | 可穿越部分地形 |
| **升级** | upgrades[] | Salvage |

#### Rebel（叛军）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 叛军 / Rebel |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $150 |
| | build_time | 3s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 15 |
| | atk_type | Normal |
| | cooldown | 0.5s |
| | range | 100 |
| | target | G+A |
| | splash | 0 |
| **技能** | active[] | Capture Building |
| | passive[] | — |
| **升级** | upgrades[] | Toxin Shells(毒素弹)、Camo Netting(伪装) |

#### RPG Trooper（RPG火箭兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | RPG火箭兵 / RPG Trooper |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $300 |
| | build_time | 3s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 40 |
| | atk_type | Explosive |
| | cooldown | 1.0s |
| | range | 150 |
| | target | G+A |
| | splash | 0 |
| | bonus_vs | 坦克/车辆×1.5 |
| **技能** | active[] | — |
| | passive[] | — |
| **升级** | upgrades[] | AP Rockets |

#### Terrorist（恐怖分子）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 恐怖分子 / Terrorist |
| | faction / tier | GLA / T1 |
| **生产** | built_from | Barracks |
| | cost_supply | $200 |
| | build_time | 3s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 25 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 200 (自爆) |
| | atk_type | Explosive |
| | cooldown | 1次 |
| | range | 0 (近身自爆) |
| | target | G |
| | splash | 40 |
| **技能** | active[] | 可附身车辆(Technical/Combat Cycle)变为车载炸弹 |
| | passive[] | — |
| **升级** | upgrades[] | — |

#### Hijacker（劫持者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 劫持者 / Hijacker |
| | faction / tier | GLA / T2 |
| **生产** | built_from | Barracks (需 Palace) |
| | cost_supply | $500 |
| | build_time | 8s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 20 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | — |
| | atk_type | — |
| **技能** | active[] | Hijack Vehicle (偷取敌方车辆) |
| | passive[] | 隐身(移动时) |
| **升级** | upgrades[] | — |

#### Jarmen Kell（贾曼·凯尔）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 贾曼·凯尔 / Jarmen Kell |
| | faction / tier | GLA / T2 (Hero) |
| **生产** | built_from | Barracks (需 Palace) |
| | cost_supply | $1500 |
| | build_time | 15s |
| | power_use | 0 |
| **生存** | hp | 100 |
| | armor_type | Infantry |
| | tags | 生物, 步兵, 英雄 |
| **机动** | speed | 25 |
| | fly / hover | false / false |
| | vision | 200 |
| **攻击** | damage | 200 (狙击步枪) |
| | atk_type | Normal |
| | cooldown | 3s |
| | range | 250 |
| | target | G |
| | splash | 0 |
| **技能** | active[] | Snipe Vehicle Driver (狙杀驾驶员，车辆变为中立可占领) |
| | passive[] | 隐身(静止时) |
| **升级** | upgrades[] | — |

#### Angry Mob（愤怒暴民）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 愤怒暴民 / Angry Mob |
| | faction / tier | GLA / T2 |
| **生产** | built_from | Barracks (需 Palace) |
| | cost_supply | $800 |
| | build_time | 10s |
| | power_use | 0 |
| **生存** | hp | 100/人 (初始5人，最多增至10人) |
| | armor_type | Infantry |
| | tags | 生物, 步兵 |
| **机动** | speed | 22 |
| | fly / hover | false / false |
| | vision | 150 |
| **攻击** | damage | 20/人 (投石) → 40/人 (AK47升级后) |
| | atk_type | Normal |
| | cooldown | 1.0s |
| | range | 80 (投石) → 120 (AK47) |
| | target | G+A (AK47) / G (投石) |
| | splash | 0 |
| **技能** | active[] | — |
| | passive[] | 自动补充人数(免费回人)、人数越多伤害越高 |
| **升级** | upgrades[] | Arm the Mob(AK47升级) |

---

### 建筑数据速查

#### USA 建筑

| 建筑 | cost_supply | power_use | hp | 说明 |
|---|---|---|---|---|
| Command Center | $2000 | -5 | 1000 | 产 Dozer、雷达、将军技(Emergency Repair/Cluster Mines/Spectre) |
| Cold Fusion Reactor | $800 | -5 | 500 | Control Rods 升级后产 10 电力 |
| Supply Center | $1500 | -1 | 800 | 产 Chinook |
| Barracks | $600 | -1 | 500 | 步兵生产 |
| War Factory | $2000 | -2 | 1000 | 车辆生产 |
| Air Field | $1000 | -1 | 600 | 飞机生产(4-8停机位) |
| Strategy Center | $2000 | -2 | 1000 | T3解锁+策略切换(Bombardment/Hold/SD) |
| Particle Cannon | $5000 | -10 | 1000 | 超级武器，6分钟充能 |
| Patriot Battery | $1000 | -2 | 400 | 防御塔，AA+AG，可连接火力网 |

#### China 建筑

| 建筑 | cost_supply | power_use | hp | 说明 |
|---|---|---|---|---|
| Command Center | $2000 | -5 | 1000 | 产 Dozer、雷达、将军技(EM Pulse/Cluster Mines/Emergency Repair) |
| Nuclear Reactor | $1000 | -10 | 500 | 产 10 电力，单体大 |
| Supply Center | $1500 | -1 | 800 | 产 Supply Truck |
| Barracks | $600 | -1 | 500 | 步兵生产 |
| War Factory | $2000 | -2 | 1000 | 车辆生产 |
| Air Field | $1000 | -1 | 600 | 飞机生产 |
| Propaganda Center | $2000 | -2 | 800 | T3解锁+宣传升级 |
| Nuclear Missile Silo | $5000 | -10 | 1000 | 超级武器，6分钟充能 |
| Bunker | $500 | -1 | 500 | 驻军10人，防御建筑 |
| Gatling Cannon | $1000 | -2 | 500 | 防御塔，AA+AG |

#### GLA 建筑

| 建筑 | cost_supply | power_use | hp | 说明 |
|---|---|---|---|---|
| Command Center | $2000 | 0 | 1000 | 产 Worker、雷达、将军技(Radar Scan/Scud Launch) |
| Supply Stash | $1500 | 0 | 800 | 产 Worker |
| Barracks | $600 | 0 | 500 | 步兵生产 |
| Arms Dealer | $2000 | 0 | 1000 | 车辆生产 |
| Palace | $1500 | 0 | 1000 | T2/T3解锁+驻军10+升级 |
| Black Market | $2500 | 0 | 800 | 被动产钱(~$20/s)+升级 |
| Scud Storm | $5000 | 0 | 1000 | 超级武器，5分钟充能(最快) |
| Tunnel Network | $800 | 0 | 500 | 隧道入口，驻军+回血，所有隧道互通 |
| Stinger Site | $1000 | 0 | 500 | 防御塔，AA+AG，驻军3人 |

---

### 关键升级速查

#### USA 升级

| 升级 | 来源 | cost_supply | 效果 |
|---|---|---|---|
| Composite Armor | War Factory | $1000 | Crusader/Paladin +HP |
| TOW Missiles | War Factory | $1000 | Humvee 获得反坦克导弹 |
| Flashbang Grenades | Barracks | $1000 | Ranger 获得闪光弹(反驻军) |
| Capture Building | Barracks | $1000 | Ranger 可占领建筑 |
| Drone Upgrades | Strategy Center | $500-$1000 | Scout/Battle/Spy Drone |
| Countermeasures | Air Field | $1000 | 飞机闪避导弹 |
| Laser Missiles | Air Field | $1000 | Raptor 伤害+ |
| Rocket Pods | Air Field | $1000 | Comanche 获得火箭齐射 |
| Sentry Gun | Strategy Center | $500 | Patriot 升级加特林 |
| Control Rods | Reactor | $500 | Reactor 电力翻倍 |
| Full Spectrum Sensors | Strategy Center | $1000 | 视野+ |

#### China 升级

| 升级 | 来源 | cost_supply | 效果 |
|---|---|---|---|
| Uranium Shells | Propaganda Center | $2000 | 坦克伤害+ |
| Nuclear Tanks | Propaganda Center | $2000 | 坦克速度+ |
| Black Napalm | War Factory | $2000 | 火焰伤害+(Dragon Tank/Inferno/Mig) |
| Chain Guns | War Factory | $1500 | 加特林射速+ |
| Nationalism | Propaganda Center | $2000 | Horde Bonus 从+15%升至+30% |
| Subliminal Messaging | Propaganda Center | $1000 | Speaker Tower 回血+ |
| Patriotism | Barracks | $1000 | Red Guard Horde Bonus+ |
| MIG Armor | Air Field | $1000 | Mig HP+ |

#### GLA 升级

| 升级 | 来源 | cost_supply | 效果 |
|---|---|---|---|
| Toxin Shells | Palace | $1000 | 坦克/车辆获得毒素弹 |
| Anthrax Gamma | Palace | $2000 | 毒素伤害大幅+ |
| AP Rockets | Black Market | $1500 | 火箭伤害+(RPG/Scorpion/Buggy) |
| AP Shells | Black Market | $1500 | 四管炮伤害+ |
| Junk Repair | Black Market | $1500 | 车辆自动回血 |
| Buggy Ammo | Black Market | $1500 | Rocket Buggy 弹药+ |
| Camo Netting | Black Market | $2000 | 单位伪装(静止隐身) |
| Arm the Mob | Palace | $1500 | Angry Mob 获得AK47 |

---

## 附录：三阵营对比速查

### 超级武器对比

| 阵营 | 超级武器 | 造价 | 充能时间 | 特点 |
|---|---|---|---|---|
| USA | Particle Cannon | $5000 | 6min | 持续激光束，可移动扫射，伤害适中 |
| China | Nuclear Missile | $5000 | 6min | 核弹，大范围+辐射残留 |
| GLA | Scud Storm | $5000 | 5min | 多发毒素导弹，最快，毒素残留 |

### 经济对比

| 维度 | USA | China | GLA |
|---|---|---|---|
| 采集单位 | Chinook $800 (飞行) | Supply Truck $300 | Worker $200 |
| 采集效率 | 高(飞行直达) | 中 | 低(地面慢) |
| 被动收入 | 无 | Hacker ~$5/s | Black Market ~$20/s |
| 电力需求 | 需要(5/反应堆) | 需要(10/反应堆) | 不需要 |
| 电力建筑 | $800 (5电力) | $1000 (10电力) | — |

### 生产对比

| 维度 | USA | China | GLA |
|---|---|---|---|
| 建造单位 | Dozer $1000 | Dozer $1000 | Worker $200 |
| 建造方式 | Dozer移动建造 | Dozer移动建造 | Worker移动建造 |
| T1坦克 | Crusader $900 | Battle Master $800 | Scorpion $600 |
| T2坦克 | Paladin $1100 | Overlord $1600 | Marauder $900 |
| 防空 | Avenger $1500 | Gatling Tank $700 | Quad Cannon $500 |
| 攻城 | Tomahawk $1200 | Nuke Cannon $1600 | Scud Launcher $1200 |
| 英雄 | Colonel Burton $1500 | Black Lotus $1500 | Jarmen Kell $1500 |
