# 命令与征服：红色警戒系列 - 阵营设计与单位数据

## 文档信息
- **版本**：v1.0（2026-06-17 初版）
- **覆盖范围**：RA1（1996，含Counterstrike/Aftermath资料片） / RA2（2000，含Yuri's Revenge） / RA3（2008，含Uprising起义时刻）
- **数据来源**：Liquipedia C&C（https://liquipedia.net/commandandconquer/）、Fandom wiki（https://cnc.fandom.com/）、社区整理数据
- **重要说明**：本次调研因外部数据源访问受限，数值基于训练知识整理。C&C系列单位在不同版本/资料片/平衡补丁中数值存在差异，本表以官方对战版本（1.006 RA2 / 1.12 RA3）为基准。**使用前请以 Liquipedia / cnc.fandom.com 官方数据二次校对**。
- **数据约定**：
  - `cost_credits` 单位为信用点（credits）
  - `build_time` 单位为秒（游戏内帧/30，C&C 标准速率）
  - `hp` 为游戏内生命值绝对数值
  - `cooldown` 单位为秒
  - `range` 单位为游戏内距离（C&C cell / 像素值，1 cell ≈ 1/10 屏幕宽度）
  - `target`：G=只能对地，A=只能对空，B=地对空两用
  - 缺失字段填 `—`
  - 升级加成写法 `基础值+每级加成`
  - 标签：`轻甲/重甲/生物/机械/建筑/英雄`

---

## 目录
- [第一部分：阵营设计分析](#第一部分阵营设计分析)
  - [RA1 Allies 盟军](#ra1-allies-盟军)
  - [RA1 Soviets 苏军](#ra1-soviets-苏军)
  - [RA2 Allies 盟军](#ra2-allies-盟军)
  - [RA2 Soviets 苏军](#ra2-soviets-苏军)
  - [RA2 Yuri 尤里](#ra2-yuri-尤里)
  - [RA3 Allies 盟军](#ra3-allies-盟军)
  - [RA3 Soviets 苏军](#ra3-soviets-苏军)
  - [RA3 Empire 升阳](#ra3-empire-升阳帝国)
- [第二部分：单位数据表](#第二部分单位数据表)
  - [RA1 Allies](#ra1-allies-单位表)
  - [RA1 Soviets](#ra1-soviets-单位表)
  - [RA2 Allies](#ra2-allies-单位表)
  - [RA2 Soviets](#ra2-soviets-单位表)
  - [RA2 Yuri](#ra2-yuri-单位表)
  - [RA3 Allies（含Uprising）](#ra3-allies-单位表)
  - [RA3 Soviets（含Uprising）](#ra3-soviets-单位表)
  - [RA3 Empire（含Uprising）](#ra3-empire-单位表)

---

## 第一部分：阵营设计分析

### RA1 Allies 盟军

#### 1. 设计哲学一句话
"科技+空军+时间，用机动性、视野欺骗（间隙发生器）与超时空传送弥补重装甲劣势"

#### 2. 核心签名机制
- **超时空传送（Chronosphere）**：将己方车辆瞬移至地图任意位置，传单位过海突袭
- **间隙发生器（Gap Generator）**：在己方基地周围制造黑幕，敌方雷达看不到
- **GPS 卫星**：解锁全图视野（双方最终科技但 Allies 更依赖）
- **轻型快速单位 + 空军**：Light Tank / Artillery / Cruiser 远程轰炸
- **海军优势**：Cruiser 超远程舰炮可轰炸内陆

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Light Tank | Medium Tank | — |
| 远程输出 | Artillery | — | Cruiser |
| 反装甲 | Bazooka | Medium Tank | Chrono Tank |
| 反步兵 | Rifle Infantry | Ranger | — |
| 防空 | AA Gun | Rocket Launcher | — |
| 骚扰 | Ranger | Spy | Chrono Tank |
| 侦察 | Ranger | Spy / GPS | — |
| 海战 | Gunboat | Destroyer | Cruiser |
| 超级武器 | — | — | Chronosphere |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-5min | 步兵+Light Tank 机动 | 反装甲弱 |
| T2 | 5-15min | Medium Tank + Artillery 阵地 | 顶不住 Mammoth |
| T3 | 15min+ | Chronosphere 突袭 + Cruiser 远轰 | 决战爆发力不足 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Light Tank + Artillery | 机动+攻城 | Light Tank 拉扯扛线，Artillery 远程消耗 |
| Cruiser + GPS | 视野+远程 | GPS 全图视野，Cruiser 越海炸内陆 |
| Chrono Tank + Chronosphere | 突袭 | 超时空传送敌方基地后方打电场 |
| Spy + Thief | 经济战 | Spy 麻痹电场，Thief 偷钱 |
| Medium Tank + Mobile Gap Generator | 隐蔽推进 | 间隙车掩护坦克集群 |
| Tanya + APC/Transport | 刺客 | 运输载具投送，炸建筑 |
| Destroyer + Gunboat | 海军协同 | Gunboat 反潜，Destroyer 反舰对地 |

#### 6. 生产机制
- 标准队列式生产：每个生产建筑一次只能列一个单位
- 建筑用 MCV 部署，建筑必须紧邻已建建筑（C&C 通用规则）
- 矿车往返 Ore Refinery 与矿脉
- Allies 矿车速度更快，但载量少

#### 7. 机动哲学
- **高速轻装 + 海空双栖**：Light Tank 速度快，Cruiser 长射程，Nighthawk 空中突袭
- 通过 Chronosphere 实现战略级机动跳跃

#### 8. 视野与地图控制
- 早期：Ranger 侦察
- 中期：Spy 潜入、Mobile Gap Generator 反视野
- 后期：GPS 卫星全图（成本高但永久）

#### 9. 反制弱点
- 反装甲差：Bazooka 是唯一早期反坦克手段
- 决战被 Mammoth Tank 碾压
- Cruiser 命中差，怕近身潜艇
- 怕 Tesla Coil 阵地

#### 10. 强势时间窗
- 早期 Light Tank rush
- 中期 Artillery + Medium Tank 推进
- 后期 Chronosphere + Cruiser 双线

#### 11. 经济模型
- Ore Truck：1 次拉 700 credits（普通矿），20 bails（gems 1000 credits）
- 矿脉：Tiberium/ore 在地图上散布，可耗尽
- Allies 矿车速度 4，载量 20 ore；Soviets 矿车速度 3，载量 40 ore
- 双方共享 Gem 田（高价值，慢再生）

---

### RA1 Soviets 苏军

#### 1. 设计哲学一句话
"重装+特斯拉+磁暴，用绝对的坦克质量、火焰与电流清洗战场"

#### 2. 核心签名机制
- **铁幕（Iron Curtain）**：使己方车辆短时间内无敌
- **Tesla Coil**：远程电击防御塔，秒杀步兵、重创坦克
- **Mammoth Tank**：双管主炮 + 反步兵导弹，游戏最强重型坦克
- **空军强**：MiG 战略轰炸、Hind 武装直升机
- **潜艇隐身**：Submarine 潜伏偷袭

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Heavy Tank | Mammoth Tank | — |
| 远程输出 | V2 Rocket | — | — |
| 反装甲 | Heavy Tank | Mammoth Tank | — |
| 反步兵 | Flamethrower | Flame Tower | — |
| 防空 | SAM Site | — | — |
| 骚扰 | Hind | Submarine | — |
| 侦察 | Attack Dog | MiG | — |
| 海战 | Submarine | — | — |
| 超级武器 | — | — | Iron Curtain |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-5min | Heavy Tank 数量优势 | 机动慢 |
| T2 | 5-15min | Mammoth + Tesla Coil 阵地 | 经济压力大 |
| T3 | 15min+ | Iron Curtain 无敌冲锋 | 怕超时空突袭 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Heavy Tank + V2 Rocket | 重装+远程 | V2 远程消耗，Heavy Tank 冲锋 |
| Mammoth Tank + Tesla Coil | 推进+防御 | Tesla Coil 守家，Mammoth Tank 推进 |
| Iron Curtain + Mammoth Tank | 无敌冲锋 | 铁幕覆盖后直接冲阵 |
| Submarine + Transport | 海军潜突 | 潜艇清场，登陆艇投送 |
| Hind + Flamethrower | 步兵清洗 | 直升机压制，火焰兵清扫 |
| MiG + Paratroopers | 空军+空降 | 轰炸+空降步兵突袭 |
| Attack Dog + Flamethrower | 反间+清扫 | 狗抓 Spy，火焰兵清场 |

#### 6. 生产机制
- 同 Allies，标准队列生产
- 建筑紧邻规则相同
- 矿车载量大但速度慢，单次经济波动大

#### 7. 机动哲学
- **慢但重**：Heavy/Mammoth Tank 速度慢，但血量高火力猛
- 用 Submarine 隐秘海战、Hind 空中机动

#### 8. 视野与地图控制
- 早期：Attack Dog 反间侦察
- 中期：MiG 飞过侦察
- 后期：Paratroopers 投伞视野

#### 9. 反制弱点
- 机动慢，怕 Allies 的 Chrono Tank 突袭
- 怕 Cruiser 远程轰炸内陆
- 缺乏有效反海军远程（Submarine 命中差）
- 经济波动大，一旦矿车被打断影响严重

#### 10. 强势时间窗
- 中期 Mammoth + Tesla Coil 阵地最强
- Iron Curtain 释放瞬间是高潮
- 海军潜艇偷袭窗口

#### 11. 经济模型
- Ore Truck 载量 40 ore，单次 1400 credits，速度 3
- Soviets 矿车效率高于 Allies，但更易被骚扰
- 矿车被毁经济重创

---

### RA2 Allies 盟军

#### 1. 设计哲学一句话
"科技+空军+时间，光棱/幻影/超时空，用高科技兵种与制空权压制苏军重装"

#### 2. 核心签名机制
- **超时空传送（Chronosphere）**：传送坦克集群突袭
- **光棱科技（Prism Technology）**：光棱坦克/光棱塔，光束反射连锁
- **幻影坦克（Mirage Tank）**：静止伪装成树，伏击
- **间隙发生器（Gap Generator）**：制造黑幕
- **空军+夜鹰运输**：Harrier 制空对地、Nighthawk 运输
- **间谍卫星（Spy Plane / Satellite）**：全图视野

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | GI（部署） | Battle Fortress | — |
| 远程输出 | — | Prism Tank | — |
| 反装甲 | Guardian GI | Mirage Tank | — |
| 反步兵 | GI | Sniper（英国特有） | — |
| 防空 | IFV | — | — |
| 骚扰 | Nighthawk+Engineer | Mirage Tank | Chrono Legionnaire |
| 侦察 | Attack Dog | Spy Satellite | — |
| 空军 | Harrier | Black Eagle（韩国） | — |
| 海军 | Dolphin | Aegis Cruiser | Aircraft Carrier |
| 超级武器 | — | — | Chronosphere, Weather Storm |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-5min | GI 部署防守、矿车安全 | 反装甲不足 |
| T2 | 5-12min | Mirage + Prism + IFV 协同 | 怕 Kirov 空袭 |
| T3 | 12min+ | Chrono 突袭 + 航母 + 天气风暴 | 决战被 Apocalypse 碾压 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Mirage Tank + Prism Tank | 伏击+远程 | 幻影伏击，光棱远轰 |
| GI + Guardian GI | 阵地防 | 反步兵+反装甲组合 |
| Battle Fortress + Guardian GI | 移动堡垒 | 装载反装甲步兵，碾压+输出 |
| IFV + Engineer | 机动修车 | IFV 装工程师变维修车 |
| Nighthawk + Tanya | 空投刺客 | 直升机送 Tanya 炸基地 |
| Harrier + Nighthawk | 空军协同 | 战机清防空，运输投送 |
| Chrono Legionnaire + Chronosphere | 突袭擦除 | 传送过去抹除建筑 |
| Aircraft Carrier + Aegis Cruiser | 海军协同 | 航母远轰，巡洋舰防空 |
| Spy + Tanya | 情报+刺客 | Spy 关电，Tanya 进基地 |

#### 6. 生产机制
- 标准队列式生产，每建筑单队列
- 矿车（Chrono Miner）：超时空回矿场，无需走回路
- Chrono Miner 单次 1000 credits，速度等同普通矿车但回程瞬移
- 可用 Spy 偷苏军科技造 Chrono Legionnaire

#### 7. 机动哲学
- **高科技机动**：Chrono Miner 超时空回程、Chrono Legionnaire 传送、Chronosphere 战略传送
- 空军机动：Harrier/Nighthawk
- 海军机动：Dolphin 高速

#### 8. 视野与地图控制
- 早期：Attack Dog + GI 部署
- 中期：Spy Plane、Mirage Tank 伪装前哨
- 后期：Spy Satellite 全图（建造即解锁）

#### 9. 反制弱点
- 反装甲依赖 Guardian GI / Mirage Tank，被 Rhino 数量冲垮
- 怕 Kirov 空袭（需 IFV 防空网）
- 怕 Apocalypse Tank 决战
- 怕 Desolator（伊拉克）反步兵辐射
- 怕 Dreadnought 海上轰炸

#### 10. 强势时间窗
- 中期 Mirage + Prism 推进最强
- 后期 Chrono + 航母多线
- 天气风暴（Weather Storm）配合突袭

#### 11. 经济模型
- Chrono Miner：载量 20 ore，回程超时空，单次 1000 credits
- 矿脉：Ore Field 散布，可耗尽
- Gem 田：高价值 2000 credits/车，慢再生
- Spy 偷钱：可让己方资金翻倍

---

### RA2 Soviets 苏军

#### 1. 设计哲学一句话
"重装+特斯拉+磁暴，绝对坦克质量+电击+核科技碾压盟军"

#### 2. 核心签名机制
- **铁幕（Iron Curtain）**：使车辆短时间无敌
- **特斯拉科技**：Tesla Coil 防御、Tesla Trooper 充电、Tesla Tank
- **磁暴反应堆**：超级反应堆高电力但被毁爆炸
- **Kirov 空艇**：重型轰炸机，重磅炸弹+灯塔威慑
- **Apocalypse Tank**：双管主炮+防空导弹，陆地霸主
- **V3 火箭**：超远程攻城

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Rhino Tank | Apocalypse Tank | — |
| 远程输出 | V3 Rocket | Siege Chopper | Dreadnought |
| 反装甲 | Rhino Tank | Apocalypse Tank | — |
| 反步兵 | Tesla Trooper | Desolator（伊拉克） | — |
| 防空 | Flak Trooper | Flak Track / Sea Scorpion | — |
| 骚扰 | Terror Drone | Crazy Ivan | Kirov |
| 侦察 | Attack Dog | Spy Plane | — |
| 空军 | — | Siege Chopper | Kirov |
| 海军 | Typhoon Sub | Sea Scorpion | Dreadnought, Squid |
| 超级武器 | — | — | Iron Curtain, Nuclear Missile |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-5min | Rhino Tank 早期压制 | 怕幻影伏击 |
| T2 | 5-12min | Tesla Coil + Flak 防空网 | 怕光棱远轰 |
| T3 | 12min+ | Apocalypse + Kirov + Iron Curtain | 怕超时空突袭 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Rhino + Flak Track | 通用推进 | 坦克推进，防空车护航 |
| Apocalypse + Tesla Trooper | 重装+充电 | Tesla Trooper 给 Tesla Coil 充电，坦克推进 |
| Kirov + Flak | 轰炸+护航 | Kirov 缓慢推进，Flak 防空 |
| V3 + Rhino | 远程+前排 | V3 远程消耗，Rhino 顶线 |
| Terror Drone + Crazy Ivan | 骚扰 | 无人机拆车，伊万炸弹 |
| Siege Chopper + Kirov | 双空 | 攻城直升机骚扰，基洛夫轰炸 |
| Iron Curtain + Apocalypse | 无敌冲锋 | 铁幕覆盖坦克直冲基地 |
| Dreadnought + Typhoon Sub | 海军 | 战列舰远轰，潜艇反舰 |
| Desolator + Tesla Coil | 阵地防御 | 辐射兵坐地+电塔 |

#### 6. 生产机制
- 标准队列生产
- War Miner：传统矿车，载量 40 ore，单次 1400 credits，速度慢
- 磁暴反应堆：500 电力但爆炸范围大

#### 7. 机动哲学
- **慢但重**：Apocalypse 速度慢但碾压一切
- **空中威慑**：Kirov 慢但威胁巨大，迫使对方造防空
- **海军潜艇隐身**

#### 8. 视野与地图控制
- 早期：Attack Dog
- 中期：Spy Plane（雷达解锁）
- 后期：Radartower

#### 9. 反制弱点
- 怕超时空突袭（Chronosphere）
- 怕光棱坦克远程消耗
- 怕幻影坦克伏击
- Kirov 速度太慢易被防空击落
- 怕天气风暴配合突袭

#### 10. 强势时间窗
- 早期 Rhino Tank rush
- 中期 Tesla Coil 阵地 + V3 推进
- 后期 Apocalypse + Iron Curtain + Kirov 多线

#### 11. 经济模型
- War Miner：载量 40 ore，单次 1400 credits，速度 3
- 矿车效率高但慢，易被打
- Nuclear Reactor 高电力易爆

---

### RA2 Yuri 尤里

#### 1. 设计哲学一句话
"心灵控制+变异+磁场，用操纵敌人单位和奇葩机制颠覆常规战争"

#### 2. 核心签名机制
- **心灵控制（Mind Control）**：Yuri Clone / Mastermind 永久控制敌方单位
- **磁暴骑兵（Magnetron）**：磁力抬起车辆单位至身边
- **Floating Disc**：悬浮碟，可吸电场/吸矿场
- **Boomer Submarine**：潜艇发射导弹，攻城+反舰
- **Initiate**：心灵火焰，反步兵+反建筑
- **Slave Miner**：奴隶矿车，移动矿场

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Brute | — | — |
| 远程输出 | Lasher Tank | Magnetron | Floating Disc |
| 反装甲 | Lasher Tank | Magnetron | Mastermind |
| 反步兵 | Initiate | Gatling Tank | — |
| 防空 | Gatling Tank | Gatling Cruiser（海上） | Floating Disc |
| 骚扰 | Yuri Clone | Floating Disc | Mastermind |
| 侦察 | — | Flying Disc | — |
| 空军 | — | Floating Disc | — |
| 海军 | — | Boomer | — |
| 超级武器 | — | — | Genetic Mutator, Psychic Dominator |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-5min | Initiate 火焰强力 | 反装甲弱 |
| T2 | 5-12min | Magnetron + Gatling | 怕远程压制 |
| T3 | 12min+ | Mastermind + Floating Disc | 怕群攻压制 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Lasher + Gatling Tank | 通用推进 | 坦克+防空 |
| Magnetron + Yuri Clone | 抬+控 | 磁暴抬起后心灵控制 |
| Mastermind + Brute | 控制+肉盾 | 主脑控制，蛮人顶线 |
| Floating Disc + Boomer | 空海协同 | 碟吸电，潜艇炸基地 |
| Initiate + Brute | 步兵+肉盾 | 火焰兵清扫，蛮人扛线 |
| Virus + Gatling | 远程+防空 | 病毒狙击，加特林防空 |
| Genetic Mutator + Slave | 经济+突袭 | 奴隶变蛮人突袭 |

#### 6. 生产机制
- **Slave Miner**：移动矿场，部署后奴隶自动采矿，无需回矿场
- 奴隶被杀可重新购买，矿车被毁可重新部署
- 兵营/工厂标准队列

#### 7. 机动哲学
- **奇怪机动**：Magnetron 抬起车辆、Floating Disc 悬浮、Boomer 潜水
- 没有传统快速单位，靠机制打乱对手节奏

#### 8. 视野与地图控制
- Floating Disc 飞行侦察
- 矿场自身移动可作为前哨

#### 9. 反制弱点
- 反装甲弱，怕 Allied/Soviet 重坦克冲锋
- 怕 Guardian GI / Tesla Trooper 反心灵控制（不被控）
- 怕远距离打击（V3 / Dreadnought）
- Mastermind 控制过多会过载受损

#### 10. 强势时间窗
- 中期 Magnetron + Yuri Clone 体系成型
- 后期 Genetic Mutator 奴隶突袭
- Floating Disc 吸电瘫痪对手

#### 11. 经济模型
- Slave Miner：1400 credits，自带 5 个奴隶
- 奴隶采集速度类似普通矿车，但矿场可移动
- 被摧毁奴隶变为蛮人（敌方单位）

---

### RA3 Allies 盟军

#### 1. 设计哲学一句话
"科技+空军+时间，冰冻+超时空+光谱，用高科技机制颠覆传统火力对抗"

#### 2. 核心签名机制
- **冰冻科技（Cryo）**：Cryocopter 冰冻单位，冰冻后一击秒杀
- **超时空传送（Chronosphere）**：传送坦克集群
- **光谱科技（Spectrum）**：Mirage Tank 光谱炮，Athena 频谱武器
- **IFV 多模式**：Multigunner IFV 装载不同步兵切换武器
- **Century Bomber**：轰炸+空投
- **间隙发生器**：基地黑幕
- **Tanya 时间腰带**：短时间回溯

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Peacekeeper（盾） | Guardian Tank | Assault Destroyer |
| 远程输出 | Javelin | Athena Cannon | — |
| 反装甲 | Javelin | Guardian Tank | Tanya |
| 反步兵 | Peacekeeper | — | — |
| 防空 | Javelin | Multigunner IFV | Apollo Fighter |
| 骚扰 | Spy | Cryocopter | Tanya |
| 侦察 | Attack Dog | Spy | — |
| 空军 | Vindicator | Apollo Fighter | Century Bomber, Harbinger |
| 海军 | Riptide ACV | Hydrofoil | Aircraft Carrier, Assault Destroyer |
| 超级武器 | — | — | Chronosphere, Proton Collider |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Peacekeeper 盾防 + 狗反间 | 反装甲不足 |
| T2 | 4-10min | IFV + Guardian + Athena 协同 | 怕 Hammer Tank 数量 |
| T3 | 10min+ | Tanya + Cryo + Century + Chrono | 决战爆发力不足 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Peacekeeper + Javelin | 步兵阵地 | 盾防+反装甲 |
| Multigunner IFV + Engineer | 维修机动 | IFV 装工程师变维修车 |
| Guardian Tank + Athena Cannon | 推进+攻城 | 守卫者顶线，雅典娜远轰 |
| Mirage Tank + Cryocopter | 伏击+冰冻 | 幻影伏击，冷冻秒杀 |
| Vindicator + Apollo Fighter | 空军协同 | 轰炸机+战斗机护航 |
| Century Bomber + Tanya | 空投刺客 | 轰炸机送 Tanya |
| Hydrofoil + Assault Destroyer | 海军协同 | 水翼防空，突击驱逐舰顶线 |
| Cryocopter + Spectrum | 冰冻+爆破 | 冰冻后光谱秒杀 |
| Tanya + Chronosphere | 超时空刺杀 | 传送谭雅炸基地 |

#### 6. 生产机制
- 标准队列生产
- Prospector 矿车可展开为前哨扩张
- **没有 RA3 Empire 的纳米核心即时建造**

#### 7. 机动哲学
- **高科技机动**：Chronosphere 战略传送、Tanya 时间腰带、Cryocopter 冰冻减速
- 空军机动：Century/Vindicator/Apollo
- 海陆空多栖：Riptide ACV 两栖

#### 8. 视野与地图控制
- Attack Dog 反间侦察
- Spy 潜入
- 间隙发生器黑幕基地
- Aerostat（侦察气球，Uprising）

#### 9. 反制弱点
- 反装甲依赖 Javelin/Guardian Tank
- 怕 Hammer Tank + Tesla Trooper
- 怕 Empire 的天狗海
- 怕 Akula Sub 偷袭
- 决战被 Apocalypse 碾压

#### 10. 强势时间窗
- 中期 IFV + Guardian 推进
- 后期 Tanya + Cryocopter + Century
- Chrono + 超时空突袭

#### 11. 经济模型
- Prospector：500 credits，可展开为 Outpost 解锁建造范围
- 矿脉：Ore Node 固定矿点，需矿车采集
- 海上矿点：需 Hover 矿车或 Prospector 水陆两用

---

### RA3 Soviets 苏军

#### 1. 设计哲学一句话
"重装+特斯拉+磁暴，绝对坦克+电击+磁力起重机，用 brute force 碾压高科技"

#### 2. 核心签名机制
- **磁力起重机（Crusher Crane）**：回收残骸换钱
- **Tesla Trooper 充电**：给 Tesla Coil 充电增强
- **Apocalypse Tank 磁力拖拽**：主炮+磁力 harpoon 拉敌单位
- **Hammer Tank 吸武器**：Leech Beam 吸取被击毁单位的主炮装到自己上
- **Natasha 狙击**：远程狙击+呼叫空袭
- **Terror Drone 拆车**：跳上坦克拆解
- **Bullfrog 人气炮**：Man-Cannon 将步兵弹射空降
- **Super Reactor**：高电力但爆炸巨大

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Conscript（数量） | Hammer Tank | Apocalypse Tank |
| 远程输出 | — | V4 Rocket | Dreadnought |
| 反装甲 | Flak Trooper | Hammer Tank | Apocalypse Tank |
| 反步兵 | Conscript | War Bear | Natasha |
| 防空 | Flak Trooper | Bullfrog | MiG |
| 骚扰 | Terror Drone | Sickle | Natasha |
| 侦察 | War Bear | Spy Plane | — |
| 空军 | — | Twinblade | MiG, Kirov |
| 海军 | Stingray | Bullfrog | Akula, Dreadnought |
| 超级武器 | — | — | Iron Curtain, Vacuum Imploder |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Conscript 海 + Flak | 反装甲弱 |
| T2 | 4-10min | Hammer + Sickle + Twinblade | 怕 Cryocopter |
| T3 | 10min+ | Apocalypse + Natasha + Kirov | 机动差 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Conscript + Flak Trooper | 数量+反甲 | 步兵海+反装甲 |
| Hammer Tank + Sickle | 推进+反步兵 | 坦克顶线，镰刀清扫 |
| Hammer Tank + Tesla Trooper | 坦克+充电 | 电击兵给 Tesla Coil 充电 |
| Apocalypse + Twinblade | 重装+空中 | 双刃直升机护航 |
| V4 + Bullfrog | 远程+防空 | V4 远轰，牛蛙防空 |
| Natasha + Twinblade | 空投刺客 | 直升机送 Natasha |
| Kirov + MiG | 轰炸+护航 | 基洛夫慢推，米格护航 |
| Akula + Stingray | 海军协同 | 潜艇鱼雷，电鳐电击 |
| Terror Drone + Sickle | 骚扰 | 无人机拆车，镰刀清扫 |
| Bullfrog + Tesla Trooper | 空投 | 人气炮弹射步兵 |

#### 6. 生产机制
- 标准队列生产
- 矿车：Soviet Ore Truck
- Super Reactor：500 电力但爆炸范围巨大
- 磁力起重机回收残骸

#### 7. 机动哲学
- **慢但重**：Apocalypse 极慢但碾压
- **空中投送**：Twinblade 运输、Bullfrog 人气炮
- **海军潜艇**：Akula 隐身

#### 8. 视野与地图控制
- War Bear 反间侦察
- Spy Plane（雷达）
- Terror Drone 潜入

#### 9. 反制弱点
- 机动慢，怕超时空/冰冻
- 怕 Cryocopter 冰冻秒杀
- 怕 Tanya 时间腰带刺杀
- Super Reactor 被毁爆炸连锁
- 怕 Empire 的海翼/天狗机动

#### 10. 强势时间窗
- 中期 Hammer + Sickle 推进
- 后期 Apocalypse + Kirov + Natasha
- Iron Curtain 无敌冲锋瞬间

#### 11. 经济模型
- Soviet Ore Truck：标准矿车
- Super Reactor 高电力但风险高
- Crusher Crane 回收残骸补充经济

---

### RA3 Empire 升阳

#### 1. 设计哲学一句话
"变形机甲+纳米科技+武士道，用纳米核心即时建造与变形机甲颠覆传统生产节奏"

#### 2. 核心签名机制
- **纳米核心（Nano-Cores）**：所有建筑都是纳米核心从建造厂生产后移动到目标地点即时展开，无需建造时间
- **变形机甲**：Tengu（空地变形）、Sea-Wing/Sky-Wing（海空变形）、VX/Chopper（防空对地变形）
- **Wave-Force 武器**：Wave-Force Artillery 蓄力光束，King Oni 波浪拳
- **Yuriko Omega**：超能力英雄，心灵控制+念力
- **King Oni**：巨型机甲，激光眼+冲拳
- **Shogun Battleship**：海上霸主，主炮射程远
- **没有传统空军基地**：所有飞行器都是地面变形而来

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Imperial Warrior | Tsunami Tank | King Oni |
| 远程输出 | Tankbuster | Wave-Force Artillery | Shogun Battleship |
| 反装甲 | Tankbuster | Striker-VX | Steel Ronin（Uprising） |
| 反步兵 | Imperial Warrior | Mecha Tengu | — |
| 防空 | — | Striker-VX→Sky-Wing | Rocket Angel |
| 骚扰 | Shinobi | Sudden Transport | Yuriko |
| 侦察 | Burst Drone | — | — |
| 空军 | Mecha Tengu→Jet Tengu | Chopper-VX | Giga Fortress（Uprising） |
| 海军 | Yari Mini Sub | Sea-Wing | Shogun, Naginata |
| 超级武器 | — | — | Psionic Decimator, Nanoswarm Hive |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | 纳米核心快速扩张 + Tengu 机动 | 反装甲不足 |
| T2 | 4-10min | Tengu 海 + VX + Tsunami | 怕 Cryocopter |
| T3 | 10min+ | King Oni + Wave-Force + Yuriko | 决战怕 Hammer 海 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Mecha Tengu + Tankbuster | 通用+反甲 | 天狗变形对地/对空，坦克杀手反装甲 |
| Striker-VX + Sea-Wing | 防空+海空 | VX 防空/海翼防空海变形 |
| Tsunami Tank + Wave-Force | 推进+攻城 | 海啸坦克顶线，波力远轰 |
| King Oni + Rocket Angel | 重装+空袭 | 鬼王扛线，火箭天使骚扰 |
| Shinobi + Sudden Transport | 刺客突袭 | 伪装运输送忍者 |
| Yuriko + King Oni | 英雄+重装 | Yuriko 心控+念力，鬼王扛线 |
| Shogun Battleship + Naginata | 海军协同 | 战列舰远轰，长枪鱼雷 |
| Giga Fortress + Jet Tengu | 终极+护航 | 海空要塞轰炸，天狗护航 |

#### 6. 生产机制
- **纳米核心即时建造**：所有建筑都是核心，从 Construction Yard 生产后移动到目标地点即时展开
- 不需要建造时间，但核心移动需要时间
- 兵营/工厂仍是核心，但展开后即时启用
- 单位生产仍是队列式
- **优势**：可前线展开生产建筑、快速扩张、抢点

#### 7. 机动哲学
- **变形机动**：Tengu（地空）、Sea-Wing/Sky-Wing（海空）、VX/Chopper（防空对地）
- **快速扩张**：纳米核心移动展开
- **多栖作战**：海陆空单位多

#### 8. 视野与地图控制
- Burst Drone 飞行侦察
- Sudden Transport 伪装侦察
- 纳米核心前哨视野

#### 9. 反制弱点
- 反装甲依赖 Tankbuster/VX
- 怕 Cryocopter 冰冻
- 怕 Natasha 狙击
- 纳米核心移动时脆弱（被打断无法展开）
- 怕超时空传送突袭

#### 10. 强势时间窗
- 早期纳米核心快速扩张
- 中期 Tengu + VX 海陆空协同
- 后期 Yuriko + King Oni + Shogun

#### 11. 经济模型
- Imperial Ore Collector：标准矿车
- 矿脉：Ore Node 固定矿点
- 纳米核心快速扩张多矿场
- 没有传统电场，每个建筑自给电力

---

## 第二部分：单位数据表

### 数据说明
- 字段顺序：name_zh / name_en / faction / game / tier / built_from / cost_credits / build_time / power_use / hp / armor_type / shields / tags / speed / fly / hover / amphibious / vision / damage / atk_type / cooldown / range / target / splash / bonus_vs / active / passive / special_ability
- 缺失填 `—`
- C&C 系列装甲类型常用：`None/Wood/Light/Heavy/Concrete`（RA1/RA2）；RA3 简化为 `Light/Medium/Heavy/Air/Naval/Structure`
- C&C 攻击类型：`SA(Small Arms)/HE(High Explosive)/AP(Armor Piercing)/HEAT/Fire/Tesla/Chrono/Sniper`等

---

### RA1 Allies 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 步枪兵 | Rifle Infantry | Allies | RA1 | 1 | Barracks | 100 | 5s | 0 | 50 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | 15 | SA | 0.5s | 4 | G | 0 | — | — | — | — |
| 火箭筒兵 | Bazooka | Allies | RA1 | 1 | Barracks | 300 | 7s | 0 | 45 | None | 0 | 生物,轻甲 | 3 | 否 | 否 | 否 | 4 | 75 | HEAT | 2s | 5 | G,A | 1 | — | — | — | — |
| 医疗兵 | Medic | Allies | RA1 | 2 | Barracks | 200 | 6s | 0 | 60 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Heal(治疗附近步兵) | — | — |
| 工程师 | Engineer | Allies | RA1 | 1 | Barracks | 500 | 5s | 0 | 80 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Capture(占领建筑), Repair(修复) | — | — |
| 间谍 | Spy | Allies | RA1 | 2 | Barracks | 1500 | 8s | 0 | 50 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 6 | — | — | — | — | — | 0 | — | Infiltrate(伪装潜入) | Disguise(伪装敌方步兵) | — |
| 小偷 | Thief | Allies | RA1 | 2 | Barracks | 500 | 8s | 0 | 50 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Steal(偷钱) | — | — |
| 谭雅 | Tanya | Allies | RA1 | 3 | Barracks | 1200 | 8s | 0 | 100 | None | 0 | 生物,英雄 | 5 | 否 | 否 | 否 | 6 | 60 | SA | 0.3s | 4 | G | 0 |步兵×2 | — | — | C4(炸建筑) |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 移动建造车 | MCV | Allies | RA1 | 3 | War Factory | 2500 | 60s | 0 | 1000 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Deploy(展开为建造场) | — | — |
| 矿车 | Ore Truck | Allies | RA1 | 1 | War Factory | 1400 | 20s | 0 | 300 | Heavy | 0 | 机械,重甲 | 4 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Harvest(采矿) | — | — |
| 游骑兵吉普 | Ranger | Allies | RA1 | 1 | War Factory | 600 | 10s | 0 | 150 | Light | 0 | 机械,轻甲 | 8 | 否 | 否 | 否 | 6 | 25 | SA | 0.5s | 4 | G | 0 | — | — | — | — |
| 轻型坦克 | Light Tank | Allies | RA1 | 1 | War Factory | 700 | 15s | 0 | 300 | Heavy | 0 | 机械,重甲 | 7 | 否 | 否 | 否 | 5 | 60 | AP | 1s | 4 | G | 0 | — | — | — | — |
| 中型坦克 | Medium Tank | Allies | RA1 | 2 | War Factory | 950 | 20s | 0 | 400 | Heavy | 0 | 机械,重甲 | 6 | 否 | 否 | 否 | 5 | 80 | AP | 1.2s | 4 | G | 0 | — | — | — | — |
| 自行火炮 | Artillery | Allies | RA1 | 2 | War Factory | 800 | 20s | 0 | 150 | Light | 0 | 机械,轻甲 | 4 | 否 | 否 | 否 | 5 | 150 | HE | 3s | 7 | G | 1.5 | — | — | — | — |
| 移动间隙发生器 | Mobile Gap Generator | Allies | RA1 | 3 | War Factory | 1500 | 30s | -100 | 200 | Light | 0 | 机械,轻甲 | 5 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Generate Gap(产生黑幕) | — | — |
| 超时空坦克 | Chrono Tank | Allies | RA1 | 3 | War Factory | 1800 | 30s | 0 | 350 | Heavy | 0 | 机械,重甲 | 5 | 否 | 否 | 否 | 5 | 75 | HEAT | 2s | 5 | G,A | 1 | — | Chrono Shift(短距离传送) | — | — |
| 布雷车 | Mine Layer | Allies | RA1 | 2 | War Factory | 800 | 15s | 0 | 200 | Heavy | 0 | 机械,重甲 | 6 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Lay Mines(布雷) | — | — |
| 相位运输车 | Phase Transport | Allies | RA1 | 3 | War Factory | 1500 | 25s | 0 | 250 | Heavy | 0 | 机械,重甲 | 6 | 否 | 否 | 否 | 5 | 80 | AP | 1.5s | 5 | G | 0 | — | Cloak(隐身) | — | — |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 炮艇 | Gunboat | Allies | RA1 | 1 | Naval Shipyard | 500 | 15s | 0 | 300 | Heavy | 0 | 机械,海军 | 6 | 否 | 否 | 否 | 6 | 50 | AP | 1.5s | 5 | G | 0 | — | Depth Charge(反潜) | — | — |
| 驱逐舰 | Destroyer | Allies | RA1 | 2 | Naval Shipyard | 1000 | 30s | 0 | 500 | Heavy | 0 | 机械,海军 | 5 | 否 | 否 | 否 | 7 | 100 | AP | 2s | 6 | G | 0 | — | — | — | — |
| 巡洋舰 | Cruiser | Allies | RA1 | 3 | Naval Shipyard | 2000 | 40s | 0 | 800 | Heavy | 0 | 机械,海军 | 3 | 否 | 否 | 否 | 8 | 300 | HE | 4s | 12 | G | 3 | — | — | — | — |
| 登陆艇 | Transport | Allies | RA1 | 1 | Naval Shipyard | 600 | 15s | 0 | 400 | Heavy | 0 | 机械,海军 | 4 | 否 | 否 | 否 | 5 | — | — | — | — | — | 0 | — | Load/Unload(运输步兵) | — | — |

#### 空军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 长弓直升机 | Nighthawk/Longbow | Allies | RA1 | 2 | Helipad | 1200 | 15s | 0 | 150 | Light | 0 | 机械,空军 | 7 | 是 | 否 | 否 | 6 | 80 | HEAT | 2s | 5 | G | 0 | — | — | — | — |

---

### RA1 Soviets 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 步枪兵 | Rifle Infantry | Soviets | RA1 | 1 | Barracks | 100 | 5s | 0 | 50 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | 15 | SA | 0.5s | 4 | G | 0 | — | — | — | — |
| 掷弹兵 | Grenadier | Soviets | RA1 | 1 | Barracks | 200 | 5s | 0 | 50 | None | 0 | 生物,轻甲 | 5 | 否 | 否 | 否 | 4 | 75 | HE | 2s | 4 | G | 1 | — | — | — | — |
| 火焰兵 | Flamethrower | Soviets | RA1 | 2 | Barracks | 300 | 8s | 0 | 60 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | 100 | Fire | 1.5s | 3 | G | 1 |步兵×2 | — | — | — |
| 电击兵 | Shock Trooper | Soviets | RA1 | 2 | Barracks | 400 | 8s | 0 | 70 | None | 0 | 生物,轻甲 | 3 | 否 | 否 | 否 | 4 | 100 | Tesla | 2s | 5 | G | 0 | — | — | — | — |
| 攻击犬 | Attack Dog | Soviets | RA1 | 1 | Barracks | 200 | 3s | 0 | 30 | None | 0 | 生物,轻甲 | 8 | 否 | 否 | 否 | 5 | 50 | SA | 0.3s | 2 | G | 0 |步兵×5 | — | — | 反间侦察 |
| 工程师 | Engineer | Soviets | RA1 | 1 | Barracks | 500 | 5s | 0 | 80 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Capture, Repair | — | — |
| 谭雅 | Tanya | Soviets | RA1 | 3 | Barracks | 1200 | 8s | 0 | 100 | None | 0 | 生物,英雄 | 5 | 否 | 否 | 否 | 6 | 60 | SA | 0.3s | 4 | G | 0 | 步兵×2 | — | — | C4 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 移动建造车 | MCV | Soviets | RA1 | 3 | War Factory | 2500 | 60s | 0 | 1000 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Deploy | — | — |
| 矿车 | Ore Truck | Soviets | RA1 | 1 | War Factory | 1400 | 20s | 0 | 300 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Harvest | — | — |
| 重型坦克 | Heavy Tank | Soviets | RA1 | 2 | War Factory | 1100 | 20s | 0 | 500 | Heavy | 0 | 机械,重甲 | 5 | 否 | 否 | 否 | 5 | 100 | AP | 1.5s | 4 | G | 0 | — | — | — | — |
| 猛犸坦克 | Mammoth Tank | Soviets | RA1 | 3 | War Factory | 1800 | 30s | 0 | 600 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 5 | 200 | AP | 2s | 5 | G | 0 | — | Mammoth Tusk(防空导弹) | 自我修复(至50% HP) | — |
| V2 火箭 | V2 Rocket | Soviets | RA1 | 2 | War Factory | 900 | 25s | 0 | 150 | Light | 0 | 机械,轻甲 | 4 | 否 | 否 | 否 | 5 | 200 | HE | 5s | 10 | G | 2 | — | — | — | — |
| 自行火炮 | Artillery | Soviets | RA1 | 2 | War Factory | 800 | 20s | 0 | 150 | Light | 0 | 机械,轻甲 | 4 | 否 | 否 | 否 | 5 | 150 | HE | 3s | 7 | G | 1.5 | — | — | — | — |
| 特斯拉坦克 | Tesla Tank | Soviets | RA1 | 3 | War Factory | 1500 | 25s | 0 | 300 | Heavy | 0 | 机械,重甲 | 5 | 否 | 否 | 否 | 5 | 150 | Tesla | 2s | 5 | G | 0 | — | — | — | — |
| 布雷车 | Mine Layer | Soviets | RA1 | 2 | War Factory | 800 | 15s | 0 | 200 | Heavy | 0 | 机械,重甲 | 6 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Lay Mines | — | — |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 潜艇 | Submarine | Soviets | RA1 | 2 | Sub Pen | 950 | 30s | 0 | 400 | Heavy | 0 | 机械,海军 | 4 | 否 | 否 | 否 | 5 | 100 | AP | 3s | 5 | G | 0 | — | Submerge(下潜) | 隐身(潜水中) | — |
| 登陆艇 | Transport | Soviets | RA1 | 1 | Sub Pen | 600 | 15s | 0 | 400 | Heavy | 0 | 机械,海军 | 4 | 否 | 否 | 否 | 5 | — | — | — | — | — | 0 | — | Load/Unload | — | — |

#### 空军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 米格战机 | MiG | Soviets | RA1 | 3 | Airfield | 1200 | 15s | 0 | 100 | Light | 0 | 机械,空军 | 10 | 是 | 否 | 否 | 7 | 200 | HE | 3s | 4 | G | 1 | — | — | — | — |
| 雅克战机 | Yak | Soviets | RA1 | 2 | Airfield | 800 | 12s | 0 | 80 | Light | 0 | 机械,空军 | 9 | 是 | 否 | 否 | 6 | 50 | SA | 0.3s | 4 | G | 0 | — | — | — | — |
| 雌鹿直升机 | Hind | Soviets | RA1 | 2 | Helipad | 1200 | 15s | 0 | 200 | Light | 0 | 机械,空军 | 6 | 是 | 否 | 否 | 6 | 60 | SA | 0.5s | 5 | G | 0 | — | — | — | — |

---

### RA2 Allies 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 大兵 | GI | Allies | RA2 | 1 | Barracks | 200 | 5s | 0 | 125 | Flak | 0 | 生物,轻甲 | 3 | 否 | 否 | 否 | 5 | 15 | SA | 0.4s | 4 | G | 0 | — | Deploy(部署为沙袋) | — | 部署后射程+伤害提升 |
| 守护大兵 | Guardian GI | Allies | RA2 | 2 | Barracks | 400 | 7s | 0 | 100 | Flak | 0 | 生物,轻甲 | 3 | 否 | 否 | 否 | 5 | 50 | HEAT | 2s | 5 | G,A | 0 | 重甲×2 | Deploy(部署) | — | 部署后对空 |
| 攻击犬 | Attack Dog | Allies | RA2 | 1 | Barracks | 200 | 3s | 0 | 100 | None | 0 | 生物,轻甲 | 8 | 否 | 否 | 否 | 6 | 100 | SA | 0.3s | 2 | G | 0 | 步兵×3 | — | — | 反间 |
| 工程师 | Engineer | Allies | RA2 | 1 | Barracks | 500 | 5s | 0 | 75 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 5 | — | — | — | — | — | 0 | — | Capture, Repair | — | — |
| 间谍 | Spy | Allies | RA2 | 2 | Barracks | 1000 | 8s | 0 | 100 | None | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 7 | — | — | — | — | — | 0 | — | Infiltrate | Disguise | 可关电场/偷科技/看视野 |
| 狙击手 | Sniper | Allies(UK) | RA2 | 2 | Barracks | 600 | 6s | 0 | 100 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 8 | 125 | Sniper | 3s | 9 | G | 0 | 步兵×2 | — | — | 英国特有 |
| 谭雅 | Tanya | Allies | RA2 | 3 | Barracks | 1000 | 1s | 0 | 200 | Flak | 0 | 生物,英雄 | 5 | 否 | 否 | 否 | 6 | 125 | SA | 0.2s | 6 | G | 0 | 步兵×3 | C4(炸建筑/坦克) | — | 可游过水面 |
| 超时空军团兵 | Chrono Legionnaire | Allies | RA2 | 3 | Barracks | 1500 | 10s | 0 | 100 | Flak | 0 | 生物,英雄 | — | 否 | 否 | 否 | 8 | 30/s | Chrono | 1s | 7 | G | 0 | — | Chrono Erase(擦除目标) | — | 超时空移动，目标被擦除彻底消失 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 超时空矿车 | Chrono Miner | Allies | RA2 | 1 | War Factory | 1400 | 20s | 0 | 600 | Heavy | 0 | 机械,重甲 | 4 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Harvest | 超时空回程 | — |
| 灰熊坦克 | Grizzly Tank | Allies | RA2 | 1 | War Factory | 700 | 12s | 0 | 300 | Heavy | 0 | 机械,重甲 | 7 | 否 | 否 | 否 | 5 | 65 | AP | 1.2s | 5 | G | 0 | — | — | — | — |
| 幻影坦克 | Mirage Tank | Allies | RA2 | 2 | War Factory | 1000 | 15s | 0 | 200 | Heavy | 0 | 机械,重甲 | 7 | 否 | 否 | 否 | 5 | 100 | HE | 1.5s | 5 | G | 0 | — | — | 伪装成树(静止时) | — |
| 光棱坦克 | Prism Tank | Allies | RA2 | 3 | War Factory | 1200 | 18s | 0 | 120 | Light | 0 | 机械,轻甲 | 5 | 否 | 否 | 否 | 7 | 150 | Prism | 3s | 8 | G | 1 | — | — | 光束反射 | — |
| 多功能步兵车 | IFV | Allies | RA2 | 1 | War Factory | 600 | 10s | 0 | 200 | Light | 0 | 机械,轻甲 | 10 | 否 | 否 | 否 | 6 | 40 | HEAT | 1s | 5 | G,A | 0 | — | — | 武器随装载步兵改变 | 装工程师变维修车 |
| 机器人坦克 | Robot Tank | Allies | RA2 | 2 | War Factory | 600 | 8s | 0 | 180 | Heavy | 0 | 机械,重甲 | 9 | 否 | 否 | 是 | 5 | 30 | AP | 0.8s | 5 | G,A | 0 | — | — | 免疫心灵控制 | 两栖 |
| 战斗要塞 | Battle Fortress | Allies | RA2 | 3 | War Factory | 2000 | 25s | 0 | 600 | Heavy | 0 | 机械,重甲 | 4 | 否 | 否 | 否 | 6 | 60 | AP | 1.5s | 6 | G | 0 | — | Load(载5步兵) | 碾压车辆 | YR资料片 |
| 移动建造车 | MCV | Allies | RA2 | 3 | War Factory | 3000 | 60s | 0 | 1000 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Deploy | — | — |
| 夜鹰运输直升机 | Nighthawk Transport | Allies | RA2 | 2 | War Factory | 1000 | 15s | 0 | 200 | Light | 0 | 机械,空军 | 9 | 是 | 否 | 否 | 6 | — | — | — | — | — | 0 | — | Load(运5步兵) | 隐形(雷达) | — |

#### 空军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 鹞式战机 | Harrier | Allies | RA2 | 2 | Airforce Command | 1200 | 12s | 0 | 200 | Light | 0 | 机械,空军 | 12 | 是 | 否 | 否 | 7 | 100 | HE | 2s | 5 | G | 0.5 | — | — | — | — |
| 黑鹰战机 | Black Eagle | Allies(Korea) | RA2 | 2 | Airforce Command | 1500 | 12s | 0 | 250 | Light | 0 | 机械,空军 | 12 | 是 | 否 | 否 | 7 | 150 | HE | 2s | 5 | G | 1 | — | — | — | 韩国特有 |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 海豚 | Dolphin | Allies | RA2 | 2 | Naval Shipyard | 500 | 8s | 0 | 200 | None | 0 | 生物,海军 | 8 | 否 | 否 | 否 | 6 | 60 | Sonic | 1.5s | 4 | G | 0 | — | Sonar Pulse(反隐) | — | — |
| 神盾巡洋舰 | Aegis Cruiser | Allies | RA2 | 2 | Naval Shipyard | 900 | 18s | 0 | 400 | Heavy | 0 | 机械,海军 | 6 | 否 | 否 | 否 | 7 | 50 | HEAT | 1s | 8 | A | 0 | 空军×2 | — | — | — |
| 驱逐舰 | Destroyer | Allies | RA2 | 1 | Naval Shipyard | 1000 | 20s | 0 | 600 | Heavy | 0 | 机械,海军 | 6 | 否 | 否 | 否 | 7 | 60 | AP | 1s | 6 | G | 0 | — | Osprey(舰载反潜机) | — | — |
| 航空母舰 | Aircraft Carrier | Allies | RA2 | 3 | Naval Shipyard | 2000 | 30s | 0 | 800 | Heavy | 0 | 机械,海军 | 4 | 否 | 否 | 否 | 7 | 100 | HE | 3s | 7 | G | 1 | — | Launch Hornets(放飞攻击机) | — | — |

---

### RA2 Soviets 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 动员兵 | Conscript | Soviets | RA2 | 1 | Barracks | 100 | 4s | 0 | 125 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 5 | 15 | SA | 0.5s | 4 | G | 0 | — | — | — | — |
| 防空兵 | Flak Trooper | Soviets | RA2 | 1 | Barracks | 300 | 6s | 0 | 100 | Flak | 0 | 生物,轻甲 | 3 | 否 | 否 | 否 | 5 | 50 | HEAT | 2s | 6 | G,A | 0 | — | — | — | — |
| 特斯拉兵 | Tesla Trooper | Soviets | RA2 | 2 | Barracks | 500 | 8s | 0 | 130 | Plate | 0 | 生物,重甲 | 4 | 否 | 否 | 否 | 5 | 75 | Tesla | 2s | 4 | G | 0 | — | Charge Coil(给Tesla Coil充电) | — | 免疫碾压 |
| 疯狂伊万 | Crazy Ivan | Soviets | RA2 | 2 | Barracks | 600 | 8s | 0 | 125 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 6 | 200 | HE | 3s | 4 | G | 1 | — | Attach Bomb(安炸弹) | — | — |
| 恐怖分子 | Terrorist | Soviets(Libya) | RA2 | 1 | Barracks | 200 | 4s | 0 | 100 | Flak | 0 | 生物,轻甲 | 6 | 否 | 否 | 否 | 5 | 250 | HE | — | 1 | G | 2 | — | Self-Destruct(自爆) | — | 利比亚特有 |
| 辐射兵 | Desolator | Soviets(Iraq) | RA2 | 2 | Barracks | 600 | 8s | 0 | 150 | Plate | 0 | 生物,重甲 | 4 | 否 | 否 | 否 | 6 | 100 | Rad | 1.5s | 5 | G | 1 |步兵×3 | Deploy(辐射地面) | — | 伊拉克特有 |
| 尤里 | Yuri | Soviets | RA2 | 2 | Barracks | 1000 | 10s | 0 | 100 | Flak | 0 | 生物,英雄 | 4 | 否 | 否 | 否 | 8 | — | — | — | — | — | 0 | — | Mind Control(心灵控制) | — | 原版，YR资料片中改为 Yuri 阵营 |
| 攻击犬 | Attack Dog | Soviets | RA2 | 1 | Barracks | 200 | 3s | 0 | 100 | None | 0 | 生物,轻甲 | 8 | 否 | 否 | 否 | 6 | 100 | SA | 0.3s | 2 | G | 0 | 步兵×3 | — | — | 反间 |
| 工程师 | Engineer | Soviets | RA2 | 1 | Barracks | 500 | 5s | 0 | 75 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 5 | — | — | — | — | — | 0 | — | Capture, Repair | — | — |
| 娜塔莎 | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | （RA2 无 Natasha，RA3 才有） |
| 鲍里斯 | Boris | Soviets | RA2 | 3 | Barracks | 1500 | 10s | 0 | 200 | Plate | 0 | 生物,英雄 | 5 | 否 | 否 | 否 | 7 | 80 | SA | 0.3s | 7 | G | 0 | 步兵×3 | Call MiG(呼叫米格轰炸) | — | YR资料片苏联英雄 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 武装矿车 | War Miner | Soviets | RA2 | 1 | War Factory | 1400 | 20s | 0 | 1000 | Heavy | 0 | 机械,重甲 | 4 | 否 | 否 | 否 | 4 | 30 | AP | 1s | 5 | G | 0 | — | Harvest | 装备机枪 | — |
| 犀牛坦克 | Rhino Heavy Tank | Soviets | RA2 | 1 | War Factory | 900 | 15s | 0 | 400 | Heavy | 0 | 机械,重甲 | 6 | 否 | 否 | 否 | 5 | 90 | AP | 1.2s | 5 | G | 0 | — | — | — | — |
| 天启坦克 | Apocalypse Tank | Soviets | RA2 | 3 | War Factory | 1750 | 25s | 0 | 800 | Heavy | 0 | 机械,重甲 | 4 | 否 | 否 | 否 | 5 | 100 | AP | 1.5s | 6 | G,A | 0 | — | — | 自我修复 | 双管+防空导弹 |
| V3 火箭 | V3 Rocket | Soviets | RA2 | 2 | War Factory | 800 | 18s | 0 | 200 | Light | 0 | 机械,轻甲 | 4 | 否 | 否 | 否 | 5 | 250 | HE | 6s | 12 | G | 2 | — | — | — | — |
| 恐怖机器人 | Terror Drone | Soviets | RA2 | 1 | War Factory | 500 | 6s | 0 | 100 | None | 0 | 机械,轻甲 | 10 | 否 | 否 | 否 | 5 | 50 | Drone | 0.5s | 1 | G | 0 | 车辆×5 | Jump(跳上车拆解) | — | — |
| 防空履带车 | Flak Track | Soviets | RA2 | 1 | War Factory | 500 | 10s | 0 | 180 | Heavy | 0 | 机械,重甲 | 7 | 否 | 否 | 否 | 6 | 50 | HEAT | 1.5s | 6 | G,A | 0 | — | Load(运5步兵) | — | — |
| 攻城直升机 | Siege Chopper | Soviets | RA2 | 2 | War Factory | 1000 | 15s | 0 | 220 | Light | 0 | 机械,空军 | 9 | 是 | 否 | 否 | 7 | 80 | HE | 2s | 8 | G | 1 | — | Deploy(架设攻城炮) | — | YR资料片 |
| 基洛夫空艇 | Kirov Airship | Soviets | RA2 | 3 | War Factory | 2000 | 30s | 0 | 2000 | Light | 0 | 机械,空军 | 3 | 是 | 否 | 否 | 5 | 250 | HE | 4s | 3 | G | 2 | — | — | — | — |
| 移动建造车 | MCV | Soviets | RA2 | 3 | War Factory | 3000 | 60s | 0 | 1000 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 4 | — | — | — | — | — | 0 | — | Deploy | — | — |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 台风潜艇 | Typhoon Attack Sub | Soviets | RA2 | 1 | Naval Shipyard | 1000 | 20s | 0 | 600 | Heavy | 0 | 机械,海军 | 5 | 否 | 否 | 否 | 5 | 100 | AP | 2s | 5 | G | 0 | — | Submerge | 隐身(潜水中) | — |
| 海蝎 | Sea Scorpion | Soviets | RA2 | 1 | Naval Shipyard | 500 | 12s | 0 | 300 | Heavy | 0 | 机械,海军 | 7 | 否 | 否 | 否 | 6 | 50 | HEAT | 1.5s | 6 | G,A | 0 | — | — | — | — |
| 无畏舰 | Dreadnought | Soviets | RA2 | 3 | Naval Shipyard | 2000 | 30s | 0 | 800 | Heavy | 0 | 机械,海军 | 4 | 否 | 否 | 否 | 7 | 250 | HE | 4s | 15 | G | 2 | — | Launch Missiles | — | — |
| 巨型乌贼 | Giant Squid | Soviets | RA2 | 2 | Naval Shipyard | 1000 | 16s | 0 | 200 | None | 0 | 生物,海军 | 8 | 否 | 否 | 否 | 6 | — | — | — | — | — | 0 | — | Grab(缠住舰船) | — | — |

---

### RA2 Yuri 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 心灵学徒 | Initiate | Yuri | RA2 | 1 | Barracks | 200 | 5s | 0 | 125 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 5 | 30 | Psi | 1s | 4 | G | 0.5 | — | — | — | 心灵火焰 |
| 蛮人 | Brute | Yuri | RA2 | 1 | Barracks | 500 | 8s | 0 | 200 | Plate | 0 | 生物,重甲 | 5 | 否 | 否 | 否 | 5 | 60 | SA | 1s | 1 | G | 0 | — | — | — | 近战肉盾 |
| 尤里克隆 | Yuri Clone | Yuri | RA2 | 2 | Barracks | 400 | 8s | 0 | 100 | Flak | 0 | 生物,灵能 | 4 | 否 | 否 | 否 | 8 | — | — | — | — | — | 0 | — | Mind Control | — | 控制敌方单位 |
| 病毒狙击手 | Virus | Yuri | RA2 | 2 | Barracks | 600 | 8s | 0 | 100 | Flak | 0 | 生物,轻甲 | 4 | 否 | 否 | 否 | 9 | 150 | Sniper | 3s | 9 | G | 0 | 步兵×2 | — | — | 死后留毒云 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 奴隶矿车 | Slave Miner | Yuri | RA2 | 1 | War Factory | 1400 | 20s | 0 | 1500 | Heavy | 0 | 机械,重甲 | 3 | 否 | 否 | 否 | 5 | — | — | — | — | — | 0 | — | Deploy(展开为矿场) | 自带5奴隶 | 移动矿场 |
| 鞭打坦克 | Lasher Tank | Yuri | RA2 | 1 | War Factory | 700 | 12s | 0 | 300 | Heavy | 0 | 机械,重甲 | 7 | 否 | 否 | 否 | 5 | 70 | AP | 1.2s | 5 | G | 0 | — | — | — | — |
| 加特林坦克 | Gatling Tank | Yuri | RA2 | 1 | War Factory | 600 | 10s | 0 | 200 | Heavy | 0 | 机械,重甲 | 7 | 否 | 否 | 否 | 6 | 25 | SA | 0.2s | 5 | G,A | 0 | 越打越快 | — | — | 双管加特林 |
| 磁暴骑兵 | Magnetron | Yuri | RA2 | 2 | War Factory | 1000 | 15s | 0 | 150 | Light | 0 | 机械,轻甲 | 5 | 否 | 否 | 否 | 6 | 50 | Magnet | 2s | 8 | G | 0 | 建筑×2 | Magnetic Lift(抬起车辆) | — | — |
| 漂浮碟 | Floating Disc | Yuri | RA2 | 3 | War Factory | 1750 | 25s | 0 | 300 | Light | 0 | 机械,空军 | 6 | 是 | 是 | 否 | 8 | 50 | Laser | 1s | 6 | G,A | 0.5 | — | Drain Power(吸电场)/Drain Refinery(吸矿场) | — | — |
| 主脑 | Mastermind | Yuri | RA2 | 3 | War Factory | 1750 | 25s | 0 | 250 | Heavy | 0 | 机械,灵能 | 4 | 否 | 否 | 否 | 9 | — | — | — | — | — | 0 | — | Mind Control(群体控制) | — | 控制过多会过载受损 |
| 加特林巡航舰 | Gatling Cruiser | Yuri | RA2 | 2 | Naval Shipyard | 900 | 18s | 0 | 350 | Heavy | 0 | 机械,海军 | 6 | 否 | 否 | 否 | 7 | 30 | SA | 0.2s | 7 | A | 0 | 越打越快 | — | — | 海上防空 |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 弹道潜艇 | Boomer | Yuri | RA2 | 2 | Naval Shipyard | 1500 | 25s | 0 | 800 | Heavy | 0 | 机械,海军 | 4 | 否 | 否 | 否 | 6 | 250 | HE | 4s | 12 | G | 2 | — | Launch Missiles | 隐身(潜水中) | 反舰+攻城 |

---

### RA3 Allies 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 攻击犬 | Attack Dog | Allies | RA3 | 1 | Barracks | 200 | 3s | 0 | 75 | None | 0 | 生物,轻甲 | 100 | 否 | 否 | 否 | 200 | 20 | SA(即时) | 0.5s | 5 | G | 0 | 步兵×5 | Bark(停止射击) | — | 反间 |
| 维和步兵 | Peacekeeper | Allies | RA3 | 1 | Barracks | 200 | 5s | 0 | 150 | Infantry | 0 | 生物,轻甲 | 60 | 否 | 否 | 否 | 150 | 30 | SA | 1s | 6 | G | 0 | — | Riot Shield(举盾减伤) | — | 举盾后伤害大减但抗性大增 |
| 标枪兵 | Javelin Soldier | Allies | RA3 | 1 | Barracks | 300 | 5s | 0 | 100 | Infantry | 0 | 生物,轻甲 | 50 | 否 | 否 | 否 | 175 | 30 | HEAT | 1.5s | 6 | G,A | 0 | 重甲×3 | Javelin Lock(蓄力) | — | 蓄力后高速火箭 |
| 工程师 | Engineer | Allies | RA3 | 1 | Barracks | 500 | 5s | 0 | 75 | Infantry | 0 | 生物,轻甲 | 50 | 否 | 否 | 否 | 150 | — | — | — | — | — | 0 | — | Capture, Repair, Swim | — | 两栖 |
| 间谍 | Spy | Allies | RA3 | 2 | Barracks | 1000 | 10s | 0 | 100 | Infantry | 0 | 生物,轻甲 | 60 | 否 | 否 | 否 | 175 | — | — | — | — | — | 0 | — | Bribe(贿赂敌方单位) | Disguise | 可变身为敌方步兵 |
| 谭雅 | Tanya | Allies | RA3 | 3 | Barracks | 2000 | 1s | 0 | 300 | Infantry | 0 | 生物,英雄 | 90 | 否 | 否 | 是 | 200 | 60 | SA | 0.3s | 5 | G | 0 | 步兵×2 | C4 / Time Belt(回溯) | — | 时间腰带可回到几秒前的位置 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 勘探者 | Prospector | Allies | RA3 | 1 | War Factory | 500 | 10s | 0 | 500 | Light | 0 | 机械,轻甲 | 60 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Harvest / Deploy(展开为Outpost) | — | 矿车+前哨 |
| 里普泰德ACV | Riptide ACV | Allies | RA3 | 1 | War Factory | 750 | 10s | 0 | 350 | Light | 0 | 机械,轻甲 | 75 | 否 | 否 | 是 | 200 | 20 | SA | 1s | 5 | G | 0 | — | Load(运5步兵) | — | 水上用鱼雷 |
| 多功能步兵战车 | Multigunner IFV | Allies | RA3 | 2 | War Factory | 800 | 10s | 0 | 240 | Light | 0 | 机械,轻甲 | 80 | 否 | 否 | 否 | 175 | 30 | HEAT | 1s | 6 | G,A | 0 | — | Load(随步兵切换武器) | — | — |
| 守卫者坦克 | Guardian Tank | Allies | RA3 | 2 | War Factory | 900 | 12s | 0 | 450 | Medium | 0 | 机械,中甲 | 70 | 否 | 否 | 否 | 200 | 35 | AP | 1.5s | 6 | G | 0 | — | Target Painter(标记+伤害) | — | — |
| 幻影坦克 | Mirage Tank | Allies | RA3 | 3 | War Factory | 1400 | 15s | 0 | 350 | Medium | 0 | 机械,中甲 | 80 | 否 | 否 | 否 | 200 | 100 | Spectrum | 2s | 6 | G | 0 | — | Spectrum(光束反射) | 伪装(静止) | — |
| 雅典娜加农炮 | Athena Cannon | Allies | RA3 | 3 | War Factory | 1100 | 15s | 0 | 350 | Light | 0 | 机械,轻甲 | 60 | 否 | 否 | 否 | 200 | 80 | Spectrum | 3s | 7 | G | 1 | — | Aegis Shield(护盾) | — | — |
| 未来坦克 X-1 | Future Tank X-1 | Allies | RA3(Uprising) | 3 | War Factory | 3000 | 25s | 0 | 750 | Heavy | 0 | 机械,重甲 | 60 | 否 | 否 | 否 | 200 | 75 | Spectrum | 2s | 6 | G | 1.5 | — | Riot Beam(光束横扫) | — | Uprising |
| 和平保卫者 | Pacifier FAV | Allies | RA3(Uprising) | 2 | War Factory | 2000 | 20s | 0 | 500 | Medium | 0 | 机械,中甲 | 50 | 否 | 否 | 否 | 200 | 150 | HE | 3s | 10 | G | 2 | — | Deploy(架设为远程炮) | — | Uprising |
| 移动建造车 | MCV | Allies | RA3 | 3 | War Factory | 5000 | 30s | 0 | 2000 | Heavy | 0 | 机械,重甲 | 50 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Deploy | — | 两栖 |

#### 空军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 维indicators轰炸机 | Vindicator | Allies | RA3 | 2 | Airbase | 1200 | 10s | 0 | 250 | Light | 0 | 机械,空军 | 100 | 是 | 否 | 否 | 200 | 100 | HE | 2s | 5 | G | 1 | — | Return(投弹后回程) | — | — |
| 阿波罗战机 | Apollo Fighter | Allies | RA3 | 2 | Airbase | 1000 | 10s | 0 | 200 | Light | 0 | 机械,空军 | 125 | 是 | 否 | 否 | 200 | 30 | SA | 0.5s | 6 | A | 0 | — | — | — | — |
| 世纪轰炸机 | Century Bomber | Allies | RA3 | 3 | Airbase | 1600 | 15s | 0 | 500 | Medium | 0 | 机械,空军 | 90 | 是 | 否 | 否 | 200 | 150 | HE | 3s | 6 | G | 2 | — | Load(运5步兵投送) | — | — |
| 冰冻直升机 | Cryocopter | Allies | RA3 | 2 | Airbase | 1600 | 15s | 0 | 400 | Light | 0 | 机械,空军 | 80 | 是 | 是 | 否 | 200 | — | — | — | — | — | 0 | — | Freeze Beam(冰冻) / Shrink Beam(缩小) | — | — |
| 先锋炮艇机 | Harbinger Gunship | Allies | RA3(Uprising) | 3 | Airbase | 3600 | 30s | 0 | 650 | Medium | 0 | 机械,空军 | 80 | 是 | 是 | 否 | 250 | 100 | AP | 1s | 7 | G | 1 | — | Switch Cannon/Gun | — | Uprising |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 海豚 | Dolphin | Allies | RA3 | 2 | Seaport | 750 | 12s | 0 | 300 | Naval | 0 | 生物,海军 | 90 | 否 | 否 | 否 | 200 | 40 | Sonic | 1.5s | 5 | G | 0 | — | Sonar Pulse(反隐) | — | — |
| 水翼快艇 | Hydrofoil | Allies | RA3 | 2 | Seaport | 900 | 12s | 0 | 350 | Naval | 0 | 机械,海军 | 100 | 否 | 否 | 否 | 200 | 30 | HEAT | 1s | 6 | A | 0 | — | Weapon Jammer(封锁敌方武器) | — | — |
| 突击驱逐舰 | Assault Destroyer | Allies | RA3 | 3 | Seaport | 1800 | 18s | 0 | 1000 | Heavy | 0 | 机械,海军 | 60 | 否 | 否 | 是 | 200 | 60 | AP | 1.5s | 5 | G | 0 | — | Black Hole Armor(吸引火力) | — | 两栖上岸 |
| 航空母舰 | Aircraft Carrier | Allies | RA3 | 3 | Seaport | 2500 | 20s | 0 | 1500 | Heavy | 0 | 机械,海军 | 50 | 否 | 否 | 否 | 200 | 100 | HE | 3s | 7 | G | 1 | — | Launch Drones(放攻击机) | — | — |

---

### RA3 Soviets 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 战熊 | War Bear | Soviets | RA3 | 1 | Barracks | 225 | 4s | 0 | 200 | Infantry | 0 | 生物,轻甲 | 90 | 否 | 否 | 是 | 200 | 50 | SA(即时) | 0.5s | 5 | G | 0 | 步兵×3 | Roar(吼叫眩晕步兵) | — | 反间,两栖 |
| 动员兵 | Conscript | Soviets | RA3 | 1 | Barracks | 100 | 4s | 0 | 100 | Infantry | 0 | 生物,轻甲 | 50 | 否 | 否 | 否 | 150 | 25 | SA | 1s | 5 | G | 0 | — | Molotov(投燃烧瓶) | — | 反建筑/步兵 |
| 防空兵 | Flak Trooper | Soviets | RA3 | 1 | Barracks | 300 | 5s | 0 | 100 | Infantry | 0 | 生物,轻甲 | 50 | 否 | 否 | 否 | 175 | 25 | HEAT | 1.5s | 6 | G,A | 0 | — | Magnetic Mine(磁雷) | — | — |
| 特斯拉兵 | Tesla Trooper | Soviets | RA3 | 2 | Barracks | 750 | 10s | 0 | 200 | Infantry | 0 | 生物,重甲 | 60 | 否 | 否 | 否 | 150 | 60 | Tesla | 2s | 5 | G | 0 | — | Charge Coil(给Tesla Coil充电) | 免疫碾压 | — |
| 战斗工程师 | Combat Engineer | Soviets | RA3 | 1 | Barracks | 500 | 5s | 0 | 100 | Infantry | 0 | 生物,轻甲 | 60 | 否 | 否 | 否 | 150 | 30 | SA | 1s | 5 | G | 0 | — | Capture, Repair | — | — |
| 娜塔莎 | Natasha | Soviets | RA3 | 3 | Barracks | 2000 | 1s | 0 | 300 | Infantry | 0 | 生物,英雄 | 75 | 否 | 否 | 否 | 200 | 200 | Sniper | 3s | 8 | G | 0 | 步兵/车辆×2 | Call Airstrike(狙车) | — | 远程狙击+呼叫空袭 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 恐怖机器人 | Terror Drone | Soviets | RA3 | 1 | War Factory | 600 | 8s | 0 | 150 | Light | 0 | 机械,轻甲 | 110 | 否 | 否 | 是 | 200 | 30 | Drone | 1s | 1 | G | 0 | 车辆×5 | Jump(跳上车) / Stasis Ray(停滞射线) | — | 两栖 |
| 镰刀机甲 | Sickle | Soviets | RA3 | 1 | War Factory | 800 | 10s | 0 | 350 | Medium | 0 | 机械,中甲 | 90 | 否 | 否 | 否 | 200 | 25 | SA | 0.5s | 5 | G,A | 0 | — | Flea Jump(跳越障碍/步兵) | — | 三管机枪 |
| 牛蛙运兵车 | Bullfrog | Soviets | RA3 | 1 | War Factory | 900 | 10s | 0 | 320 | Light | 0 | 机械,轻甲 | 90 | 否 | 否 | 是 | 200 | 25 | HEAT | 1s | 6 | G,A | 0 | — | Man-Cannon(人气炮弹射步兵) | — | 两栖防空 |
| 锤式坦克 | Hammer Tank | Soviets | RA3 | 2 | War Factory | 1000 | 12s | 0 | 550 | Medium | 0 | 机械,中甲 | 70 | 否 | 否 | 否 | 200 | 55 | AP | 1.5s | 5 | G | 0 | — | Leech Beam(吸武器) | — | 击毁敌方坦克后获得其主炮 |
| 天启坦克 | Apocalypse Tank | Soviets | RA3 | 3 | War Factory | 2000 | 20s | 0 | 1200 | Heavy | 0 | 机械,重甲 | 50 | 否 | 否 | 否 | 200 | 100 | AP | 2s | 6 | G | 0 | — | Magnetic Harpoon(磁力拖拽) | 自我修复(50%) | 双管 |
| V4 火箭 | V4 Rocket Launcher | Soviets | RA3 | 3 | War Factory | 1200 | 15s | 0 | 400 | Light | 0 | 机械,轻甲 | 60 | 否 | 否 | 否 | 200 | 150 | HE | 4s | 8 | G | 2 | — | Switch: Single/Barrage(多弹头) | — | — |
| 收割者 | Reaper | Soviets | RA3(Uprising) | 3 | War Factory | 2400 | 25s | 0 | 1200 | Heavy | 0 | 机械,重甲 | 50 | 否 | 否 | 是 | 200 | 100 | AP | 2s | 6 | G | 1 | — | Switch: Walk/Leap | — | Uprising, 两栖 |
| 粉碎者 | Grinder | Soviets | RA3(Uprising) | 2 | War Factory | 1500 | 15s | 0 | 750 | Heavy | 0 | 机械,重甲 | 75 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Switch: Grind(碾压) | — | Uprising, 两栖 |
| 迫击摩托 | Mortar Cycle | Soviets | RA3(Uprising) | 1 | War Factory | 600 | 8s | 0 | 200 | Light | 0 | 机械,轻甲 | 120 | 否 | 否 | 否 | 200 | 80 | HE | 2s | 7 | G | 1 | — | Switch: Mortar/Machine Gun | — | Uprising |
| 净化者 | Desolator | Soviets | RA3(Uprising) | 2 | War Factory | 1500 | 15s | 0 | 600 | Heavy | 0 | 机械,重甲 | 60 | 否 | 否 | 否 | 200 | 60 | Rad | 2s | 5 | G | 1 | 步兵×3 | Switch: Cannon/Splash | — | Uprising |
| 移动建造车 | MCV | Soviets | RA3 | 3 | War Factory | 5000 | 30s | 0 | 2000 | Heavy | 0 | 机械,重甲 | 50 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Deploy | — | — |

#### 空军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 双刃直升机 | Twinblade | Soviets | RA3 | 2 | Airbase | 1200 | 15s | 0 | 350 | Light | 0 | 机械,空军 | 90 | 是 | 否 | 否 | 200 | 50 | HEAT | 1s | 6 | G | 0 | — | Load(运5步兵) | — | 反坦克火箭+机炮 |
| 米格战机 | MiG Fighter | Soviets | RA3 | 2 | Airbase | 1000 | 10s | 0 | 200 | Light | 0 | 机械,空军 | 130 | 是 | 否 | 否 | 200 | 30 | HEAT | 0.5s | 6 | A | 0 | — | Return to Base(紧急回程) | — | — |
| 基洛夫空艇 | Kirov Airship | Soviets | RA3 | 3 | Airbase | 2500 | 25s | 0 | 2500 | Heavy | 0 | 机械,空军 | 40 | 是 | 否 | 否 | 200 | 250 | HE | 4s | 3 | G | 2 | — | — | — | 经典威慑 |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 黄貂鱼 | Stingray | Soviets | RA3 | 2 | Naval Yard | 1200 | 15s | 0 | 450 | Heavy | 0 | 机械,海军 | 75 | 否 | 否 | 否 | 200 | 50 | Tesla | 1.5s | 5 | G | 0 | — | Switch: Surf/Submerge | — | 电击可链锁 |
| 阿库拉潜艇 | Akula Sub | Soviets | RA3 | 3 | Naval Yard | 1800 | 20s | 0 | 800 | Heavy | 0 | 机械,海军 | 60 | 否 | 否 | 否 | 200 | 150 | AP | 3s | 7 | G | 0 | — | Switch: RU-7(普通雷)/RU-3(高速雷) | 隐身(潜水中) | — |
| 无畏舰 | Dreadnought | Soviets | RA3 | 3 | Naval Yard | 2000 | 20s | 0 | 1500 | Heavy | 0 | 机械,海军 | 50 | 否 | 否 | 否 | 200 | 150 | HE | 4s | 12 | G | 2 | — | Switch: Single/Salvo | — | — |

---

### RA3 Empire 单位表

#### 步兵

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击无人机 | Burst Drone | Empire | RA3 | 1 | Dojo | 300 | 5s | 0 | 100 | Light | 0 | 机械,轻甲 | 100 | 否 | 否 | 是 | 200 | 5 | SA(即时) | 0.5s | 1 | G | 0 | — | Self-Destruct(自爆) | — | 侦察 |
| 帝国武士 | Imperial Warrior | Empire | RA3 | 1 | Dojo | 150 | 4s | 0 | 150 | Infantry | 0 | 生物,轻甲 | 60 | 否 | 否 | 否 | 150 | 30 | SA | 1s | 5 | G | 0 | — | Banzai Charge(万岁冲锋) | — | 切换为近战 |
| 坦克杀手 | Tankbuster | Empire | RA3 | 1 | Dojo | 300 | 5s | 0 | 100 | Infantry | 0 | 生物,轻甲 | 50 | 否 | 否 | 否 | 150 | 50 | HEAT | 2s | 5 | G | 0 | 重甲×3 | Submerge(钻地) | — | 钻地后隐形 |
| 工程师 | Engineer | Empire | RA3 | 1 | Dojo | 500 | 5s | 0 | 75 | Infantry | 0 | 生物,轻甲 | 50 | 否 | 否 | 否 | 150 | — | — | — | — | — | 0 | — | Capture, Repair, Swim | — | 两栖 |
| 忍者 | Shinobi | Empire | RA3 | 2 | Dojo | 1000 | 8s | 0 | 200 | Infantry | 0 | 生物,轻甲 | 75 | 否 | 否 | 否 | 175 | 60 | SA | 1s | 4 | G | 0 | — | Smoke Bomb(烟雾弹) | 隐身(静止) | — |
| 百合子 | Yuriko Omega | Empire | RA3 | 3 | Dojo | 2000 | 1s | 0 | 400 | Infantry | 0 | 生物,英雄,灵能 | 75 | 否 | 否 | 否 | 200 | 40 | Psi | 1s | 6 | G,A | 0 | — | Mind Control / Psychic Slam | — | 心灵控制+念力冲击 |

#### 车辆

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 帝国矿车 | Imperial Ore Collector | Empire | RA3 | 1 | Mecha Bay | 500 | 10s | 0 | 500 | Light | 0 | 机械,轻甲 | 60 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Harvest / Switch(盾/速) | — | 两栖 |
| 突然运输 | Sudden Transport | Empire | RA3 | 1 | Mecha Bay | 500 | 8s | 0 | 200 | Light | 0 | 机械,轻甲 | 90 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Disguise(伪装) / Load | — | 伪装成敌方车辆 |
| 机甲天狗 | Mecha Tengu | Empire | RA3 | 1 | Mecha Bay | 800 | 10s | 0 | 300 | Light | 0 | 机械,轻甲 | 90 | 否 | 否 | 否 | 175 | 25 | SA | 0.5s | 5 | G | 0 | — | Switch: Mecha/Jet(变形) | — | 变形为喷气战机 |
| 海啸坦克 | Tsunami Tank | Empire | RA3 | 2 | Mecha Bay | 1000 | 12s | 0 | 350 | Medium | 0 | 机械,中甲 | 80 | 否 | 否 | 是 | 175 | 50 | AP | 1.5s | 5 | G | 0 | — | Switch(盾/速) | — | 两栖,可开护盾 |
| 海翼/天翼 | Striker-VX / Sky-Wing | Empire | RA3 | 2 | Mecha Bay | 1000 | 12s | 0 | 300 | Medium | 0 | 机械,中甲 | 70 | 否 | 否 | 否 | 175 | 30 | HEAT | 1.5s | 6 | A | 0 | — | Switch: Striker(防空对地)/Sky(空地) | — | VX对空变形为海翼对地 |
| 波力炮 | Wave-Force Artillery | Empire | RA3 | 3 | Mecha Bay | 1200 | 15s | 0 | 300 | Light | 0 | 机械,轻甲 | 60 | 否 | 否 | 否 | 200 | 200 | Spectrum(蓄力) | 5s | 8 | G | 1 | — | Switch: Hold Fire/Release(蓄力/释放) | — | 蓄力光束 |
| 鬼王 | King Oni | Empire | RA3 | 3 | Mecha Bay | 1500 | 20s | 0 | 1500 | Heavy | 0 | 机械,重甲 | 60 | 否 | 否 | 否 | 200 | 80 | Laser | 2s | 5 | G | 0 | — | Bullrush(冲拳) | — | 激光眼+冲撞 |
| 钢铁浪人 | Steel Ronin | Empire | RA3(Uprising) | 3 | Mecha Bay | 1800 | 18s | 0 | 750 | Heavy | 0 | 机械,重甲 | 75 | 否 | 否 | 否 | 200 | 100 | AP | 2s | 4 | G | 0 | — | Spear Charge(长枪冲锋) | — | Uprising, 近战机甲 |
| 火箭天使 | Rocket Angel | Empire | RA3(Uprising) | 2 | Mecha Bay | 800 | 10s | 0 | 200 | Light | 0 | 机械,空军 | 100 | 是 | 是 | 否 | 175 | 40 | HEAT | 1s | 6 | G,A | 0 | — | Switch: Rockets/Paralysis Whip | — | Uprising, 飞行 |
| 移动建造车 | MCV | Empire | RA3 | 3 | Mecha Bay | 5000 | 30s | 0 | 2000 | Heavy | 0 | 机械,重甲 | 50 | 否 | 否 | 是 | 200 | — | — | — | — | — | 0 | — | Deploy | — | 两栖 |

#### 海军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 矛式微型潜艇 | Yari Mini Sub | Empire | RA3 | 1 | Naval Yard | 800 | 10s | 0 | 300 | Light | 0 | 机械,海军 | 100 | 否 | 否 | 否 | 200 | 50 | AP | 1.5s | 4 | G | 0 | — | Switch: Torpedo/Kamikaze(神风自爆) | 隐身(潜水中) | — |
| 长枪巡洋舰 | Naginata Cruiser | Empire | RA3 | 2 | Naval Yard | 1500 | 15s | 0 | 600 | Heavy | 0 | 机械,海军 | 75 | 否 | 否 | 否 | 200 | 80 | AP | 2s | 6 | G | 0 | — | Switch: Single/Spread(扇形雷) | 隐身(潜水中) | — |
| 将军战列舰 | Shogun Battleship | Empire | RA3 | 3 | Naval Yard | 2200 | 20s | 0 | 2000 | Heavy | 0 | 机械,海军 | 50 | 否 | 否 | 否 | 200 | 150 | HE | 3s | 10 | G | 2 | — | Switch: Ramming Speed(冲撞) | — | 远程主炮 |
| 海翼 | Sea-Wing | Empire | RA3 | 2 | Naval Yard | 1000 | 12s | 0 | 300 | Medium | 0 | 机械,海军 | 75 | 否 | 否 | 否 | 175 | 30 | HEAT | 1.5s | 6 | A | 0 | — | Switch: Sea(对空)/Sky(对地) | 隐身(潜水中) | 变形为天翼对地 |
| 超要塞 | Giga Fortress | Empire | RA3(Uprising) | 3 | Naval Yard | 3000 | 30s | 0 | 3000 | Heavy | 0 | 机械,海军 | 30 | 是 | 是 | 否 | 250 | 200 | Spectrum | 4s | 9 | G | 2 | — | Switch: Sea/Air(海空变形) | — | Uprising |

#### 空军

| name_zh | name_en | faction | game | tier | built_from | cost_credits | build_time | power_use | hp | armor_type | shields | tags | speed | fly | hover | amphibious | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special_ability |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 喷气天狗 | Jet Tengu | Empire | RA3 | 1 | Mecha Bay(变形) | (800) | — | 0 | 300 | Light | 0 | 机械,空军 | 120 | 是 | 否 | 否 | 175 | 25 | SA | 0.5s | 5 | A | 0 | — | Switch: Mecha(地对地)/Jet(空对空) | — | Mecha Tengu 变形 |
| 天翼 | Sky-Wing | Empire | RA3 | 2 | (变形) | (1000) | — | 0 | 300 | Light | 0 | 机械,空军 | 110 | 是 | 否 | 否 | 175 | 30 | HEAT | 1.5s | 6 | G | 0 | — | Switch: Sea-Wing(对空)/Sky-Wing(对地) | — | Sea-Wing 变形 |
| 直升机VX | Chopper-VX | Empire | RA3 | 2 | Mecha Bay | 1000 | 12s | 0 | 300 | Medium | 0 | 机械,空军 | 80 | 是 | 否 | 否 | 175 | 30 | HEAT | 1.5s | 6 | G | 0 | — | Switch: Chopper(对地)/VX(对空) | — | 变形为 Striker-VX |

---

## 附录：游戏版本与资料片

| 游戏 | 发布年份 | 资料片 | 新增阵营 | 备注 |
|---|---|---|---|---|
| Red Alert 1 | 1996 | Counterstrike / Aftermath | — | Aftermath 加入 Tesla Tank / Chrono Tank / Phase Transport / Shock Trooper |
| Red Alert 2 | 2000 | — | — | 标准版 Allies vs Soviets |
| Red Alert 2: Yuri's Revenge | 2001 | Yuri's Revenge | Yuri | 新增 Yuri 阵营 + Boris / Battle Fortress / Siege Chopper / Boomer |
| Red Alert 3 | 2008 | — | Empire of the Rising Sun | 纳米核心即时建造机制 |
| Red Alert 3: Uprising | 2009 | Uprising | — | 新增单位: Harbinger / Future Tank / Pacifier / Reaper / Grinder / Mortar Cycle / Desolator / Steel Ronin / Giga Fortress / Yuriko 战役 |

## 附录：阵营子分支（RA2 国家特有）

| 阵营 | 国家 | 特有单位 |
|---|---|---|
| Allies | USA | — |
| Allies | Korea | Black Eagle（黑鹰战机） |
| Allies | France | Grand Cannon（巨炮，防御建筑） |
| Allies | Germany | Tank Destroyer（反坦克坦克） |
| Allies | UK | Sniper（狙击手） |
| Soviets | Russia | — |
| Soviets | Libya | Terrorist（恐怖分子自爆兵） |
| Soviets | Iraq | Desolator（辐射兵） |
| Soviets | Cuba | — (实际 Cuba 无特有单位) |

## 数据来源声明

本表数据基于训练知识整理（截至 2024 年初），参考来源：
- Liquipedia C&C：https://liquipedia.net/commandandconquer/
- Fandom wiki：https://cnc.fandom.com/
- 官方单位说明文档（README/Manual）
- ModDB/社区整理的 INI 数据（RA2 rulesmd.ini / RA3 .xml）

**数值精度注意事项**：
1. C&C 系列不同游戏数值单位不统一（HP/damage 在 RA1 用绝对数，RA2/RA3 不同）
2. 速度单位：RA1 用 cells/second，RA2 用 WWP（World Builder），RA3 用 game units
3. cooldown 单位为秒，但实际帧数可能因游戏帧率（RA1 60fps, RA2/RA3 30fps）影响
4. 升级加成（Veterancy/Promotion）未在表中体现，通常为 +HP/+伤害/+护甲
5. Uprising 单位为单人战役/遭遇战限定，非标准对战
6. 部分单位（如 RA2 的 Yuri）在原版与 YR 资料片中数据不同
7. **使用前请务必以 Liquipedia / cnc.fandom.com 二次校对**

## 调研限制说明

本次调研在搜索阶段遇到以下限制：
- Tavily API 超出配额限制
- WebFetch 工具权限被拒绝
- WebSearch 返回空结果

因此文档完全基于训练数据知识构建，数值可能与最新版本/社区共识存在偏差。建议后续通过以下方式补全：
1. 直接抓取 cnc.fandom.com 各单位页面
2. 参考 RA2 rulesmd.ini / RA3 unit XML 原始数据
3. 对照 Liquipedia 单位条目（通常包含完整 statbox）
