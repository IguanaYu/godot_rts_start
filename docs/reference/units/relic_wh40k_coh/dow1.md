# Warhammer 40K: Dawn of War 1 — 单位数据调研

> **版本信息**
> - 游戏版本：Dawn of War 1 (2004) + Winter Assault + Dark Crusade + Soulstorm (2008, v1.51 final patch)
> - 数据来源：Dawn of War Wiki (dawnofwar.fandom.com) / Liquipedia / 游戏内属性文件
> - 数据采集日期：2026-06-17
> - 注意：DoW1 经历了从 v1.0 到 v1.51 多次平衡性改动，本表以 Soulstorm v1.51 为基准；部分数值为近似值（标注 ~），具体数值可能因补丁而异
> - 数值约定：HP/伤害为游戏内绝对值，冷却为秒，射程为游戏内距离单位，费用为 Requisition/Power

---

## DoW1 核心机制概览

### 护甲类型系统
DoW1 使用**护甲穿透百分比**模型：每种武器对每种护甲类型有一个穿透率（1%-100%），实际伤害 = 武器伤害 × 穿透率。

| 护甲类型 | 缩写 | 典型单位 |
|---|---|---|
| infantry | inf | 轻步兵（Guardian, Cultist, Guardsman） |
| infantry_heavy_med | ihm | 重步兵中甲（Space Marine, Fire Warrior） |
| infantry_heavy_high | ihh | 重步兵高甲（Terminator, Obliterator） |
| commander | cmd | 英雄/指挥官 |
| monster_med | mm | 中型怪兽（Krootox, Talos） |
| monster_high | mh | 大型怪兽（Squiggoth, Avatar, Bloodthirster） |
| vehicle_low | vl | 轻载具（Wartrakk, Sentinel, Land Speeder） |
| vehicle_med | vm | 中型载具（Dreadnought, Defiler, Wraithlord） |
| vehicle_high | vh | 重型载具（Predator, Leman Russ, Land Raider） |
| daemon_low | dl | 低级恶魔（Horror, Possessed） |
| daemon_high | dh | 高级恶魔（Bloodthirster） |
| building_low | bl | 轻型建筑（Listening Post, Banner） |
| building_med | bm | 中型建筑（生产建筑） |
| building_high | bh | 大型建筑（HQ, Monolith） |

### 士气系统
- 每个小队有最大士气值（通常 100-400）
- 武器造成士气伤害，士气降至 0 时小队**崩溃（Broken）**
- 崩溃效果：准确率降至 ~30%，移动速度降低，无法使用技能
- 士气在非战斗时自动恢复，恢复速率因单位而异
- 关键士气武器：Sniper Rifle、Flamer、Artillery

### 经济系统
| 资源 | 来源 | 说明 |
|---|---|---|
| Requisition（需求点） | Strategic Points / Critical Locations / Relics | 需派步兵占领，建造 Listening Post 提升 |
| Power（能量） | Power Generators / Thermo Plasma Generators | 在热能点建造效率更高 |
| Relic（圣物） | 特殊占领点 | 解锁 T4 终极单位 |
| Ork Pop（兽人人口） | Waaagh! Banners | 每个 Banner 提供人口上限 |
| Soul Essence（灵魂精华） | 击杀敌方单位（仅 Dark Eldar） | 用于施放特殊技能 |
| Pop Cap | Infantry Cap / Vehicle Cap | 默认步兵 20/载具 10，可通过升级增加 |

### 科技等级
| 等级 | 解锁方式 | 内容 |
|---|---|---|
| T1 | 游戏开始 | 基础步兵、工人、英雄 |
| T2 | HQ 升级 Tier 2 | 重武器、精英步兵、中型载具 |
| T3 | HQ 升级 Tier 3 | 高级单位、重载具、终极步兵 |
| T4 | Relic + T3 建筑 | 超级单位（Land Raider / Baneblade / Monolith 等） |

### 小队系统
- 步兵以**小队（Squad）**形式生产，购买小队后可花钱**增援（Reinforce）**补充成员
- 小队可配备**重武器（Heavy Weapons）**，有专用武器槽位
- 增援在战斗中可进行但速度较慢，且增援费用通常高于初始人均费用
- 小队被全灭则彻底消失（不像 CoH 可以重建）

---

# 第一部分：种族设计分析

---

## 1. Space Marines（星际战士）

### 1.1 设计哲学一句话
> 精英少而精：以高士气、高单体战力、多功能重武器和空降机动性弥补数量劣势。

### 1.2 核心签名机制
- **士气稳定性**：SM 单位基础士气高（300+），Apothecary 可恢复士气，几乎不崩溃
- **Drop Pod（空降舱）**：Force Commander / Terminators 可从轨道空降，绕过地图阻碍直接投放
- **重武器灵活性**：Tactical Marine 小队可装备 4 种重武器（Missile Launcher / Plasma Gun / Flamer / Heavy Bolter），按需切换反甲/反步/士气
- **Deep Strike**：多单位可通过空降舱/传送到场，无需行军

### 1.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Space Marine Squad | Tactical Marine (w/ upgrades) | Terminator |
| 近战输出 | Assault Marine | Force Commander | Assault Terminator |
| 远程输出 | Scout (Sniper) | Tactical Marine (Heavy Bolter) | Terminator (Assault Cannon) |
| 反甲 | — | Tactical Marine (Missile Launcher) | Dreadnought (LC) |
| 攻城 | — | Whirlwind | — |
| 骚扰 | Scout, Assault Marine | Land Speeder | Deep Strike |
| 侦察 | Scout | Skull Probe | — |
| 防空 | — | Missile Launcher | Predator (LC sponsons) |
| 运输 | — | Rhino | — |
| 英雄 | Force Commander | Chaplain, Librarian, Apothecary | — |

### 1.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Tactical Marine 战力扎实，Scout Sniper 破士气 | 数量少，怕速攻 |
| T2 | 4-8min | 重武器全面解锁，Dreadnought 压制载具 | 载具反制弱、机动差 |
| T3 | 8min+ | Terminator + Predator + Land Raider 终极组合 | 造价高昂，运营压力 |

### 1.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Tactical Marine + Apothecary | 续航+士气 | Apothecary 治疗+恢复士气，Tactical 持续输出 |
| Scout Sniper + Tactical Flamer | 士气摧毁 | Sniper 远程打士气 + Flamer 近距离烧士气，快速崩溃敌军 |
| Assault Marine + Tactical Missile | 近战粘人+反甲 | Assault 跳入粘住载具，Tactical Missile 拆甲 |
| Dreadnought + Missile Tactical | 前排肉盾+后排反甲 | Dreadnought 吸引火力，Missile 打载具 |
| Force Commander + Chaplain + Librarian | 三英雄叠加 | FC 坦+输出，Chaplain 光环+士气回复，Librarian Smite AOE |
| Drop Pod Terminator | 空降突袭 | 绕过防线直接投送终极步兵 |
| Land Raider + Terminator | 终极推进 | Land Raider 运输 Terminator + 本身重火力 |

### 1.6 生产机制
- 工人 Servitor 建造建筑，步兵从 Chapel Barracks 生产，载具从 Machine Cult 生产
- 小队系统：Tactical Marine 小队初始 4 人，可增援至 8 人（SS）/ 10 人（早期版本）
- 重武器：每队 2-4 个武器槽（随版本），在战斗中可增援安装
- Deep Strike：Terminator / Assault Terminator / Dreadnought 可从轨道空降，无需行军

### 1.7 机动哲学
- **空降突袭**：Drop Pod 和 Deep Strike 是 SM 的机动核心，可绕过防线
- **地面慢速推进**：地面步兵移动速度一般，依赖 Rhino 运输加速
- **Land Speeder 快速骚扰**：提供 T2 的机动骚扰能力
- **Assault Marine 跳跃**：喷气跳跃可跨越地形，突袭后排

### 1.8 视野与地图控制
- Scout 可隐身（Infiltration 升级），作为前哨观察
- Skull Probe（T2）可隐身侦察，自爆伤害
- Listening Post 提供区域视野和防御
- Drop Pod 可提供临时视野

### 1.9 反制弱点
- 数量劣势：面对 Ork/Eldar/Guard 的数量压制时吃力
- 早期反甲弱：T1 无反甲武器，T2 Missile Launcher 才补上
- 怕恶魔：Bloodthirster / Possessed 等高近战伤害单位对 SM 步兵威胁大
- 机动性差：地面单位速度一般，被高机动种族（Eldar/DE）放风筝

### 1.10 强势时间窗
- T1 后期：Tactical Marine + Scout Sniper 成型后步兵战力强
- T2：Dreadnought + 重武器组合压制多数种族
- T3-T4：Terminator + Land Raider 终极组合几乎无解

### 1.11 经济模型
- 标准 Requisition + Power 双资源
- 战略点占领后建 Listening Post 保护和增加产出
- 单位造价高但单兵战力强，性价比高
- Power 需求大（载具/重武器/Tech 升级都耗 Power）

---

## 2. Chaos（混沌星际战士）

### 2.1 设计哲学一句话
> SM 的黑暗镜像：以恶魔召唤和腐蚀机制换取更强的近战爆发和 T2 timing，但科技上限略低。

### 2.2 核心签名机制
- **恶魔召唤（Daemon Summoning）**：Bloodthirster、Horrors 等恶魔单位从建筑召唤，部分需要 Sacrifice
- **Possessed Marine（被附身战士）**：T2 终极近战步兵，高伤害高抗性，越打越强
- **Corruption（腐蚀）**：Heretic 可腐蚀地图区域，增加 Chaos 建筑
- **Pact 系统**：通过 Sacrificial Circle 解锁各种恶魔单位

### 2.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Chaos Space Marine | Possessed Marine | Obliterator |
| 近战输出 | Raptor | Khorne Berzerker | Bloodthirster |
| 远程输出 | Cultist (GL) | CSM (Plasma) | Obliterator |
| 反甲 | — | Horror, Tankbusta-equiv | Predator |
| 攻城 | — | Defiler | — |
| 骚扰 | Cultist, Raptor | Defiler | — |
| 侦察 | Cultist (Infil) | — | — |
| 防空 | — | Horror | Predator |
| 运输 | — | — | — |
| 英雄 | Chaos Lord | Sorcerer | — |

### 2.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | CSM + Cultist GL 组合不弱 | 英雄战力一般 |
| T2 | 4-8min | Possessed + Berzerker + Defiler 极强 timing | 远程反甲不足 |
| T3 | 8min+ | Bloodthirster + Obliterator 终极 | 科技树不如 SM 深 |

### 2.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Cultist Grenade + CSM Plasma | 士气+输出 | Cultist GL 破士气，CSM Plasma 输出 |
| Khorne Berzerker + Possessed | 双近战碾压 | Berzerker 高输出 + Possessed 高生存，碾压步兵线 |
| Defiler + CSM Missile | 攻城+反甲 | Defiler 炮击+近战，CSM Missile 防载具 |
| Sorcerer + Doombolt | AOE 爆发 | Sorcerer Doombolt 打步兵团，Corruption 减速 |
| Horror Drop | 突袭反甲 | Horror 可 Deep Strike，突然出现在载具旁 |
| Bloodthirster + Obliterator | 终极双核 | BT 近战无敌 + Obliterator 全能火力 |
| Chaos Lord + Daemon Weapons | 英雄强化 | CL 装 Daemon Weapon 后伤害暴增 |

### 2.6 生产机制
- 工人 Heretic 建造建筑，可加速建造（但消耗自身 HP）
- CSM 小队系统类似 SM，可配备重武器但种类较少
- 恶魔单位从 Sacrificial Circle / Daemon Pit 召唤，不走传统增援
- Horror 可 Deep Strike 到可见区域

### 2.7 机动哲学
- **Raptor 跳跃**：类似 Assault Marine 的喷气跳跃，T1 近战骚扰
- **Defiler 多功能**：既能远程炮击又能近战，慢速推进
- **Deep Strike Horror**：可突然空投反甲单位
- **Bloodthirster 飞行**：T4 恶魔可飞行，高机动

### 2.8 视野与地图控制
- Cultist 可隐身（Infiltration 升级），做前哨
- 无专门侦察单位，依赖 Cultist 和地图点
- Defiler 间接炮击需要视野，需要前哨单位

### 2.9 反制弱点
- 远程火力不如 SM：重武器选择少
- 反甲依赖 Horror：Horror 脆且需召唤
- 科技树浅：T3/T4 单位种类不如 SM 丰富
- 怕士气武器：CSM 士气不如 SM 高

### 2.10 强势时间窗
- T2：Possessed + Berzerker + Defiler 是 Chaos 最强 timing
- T3 初：Obliterator 解锁后远程火力补齐
- T4：Bloodthirster 是游戏最强近战超级单位之一

### 2.11 经济模型
- 标准 Requisition + Power 双资源
- Heretic 加速建造可缩短 timing，但消耗 HP 需要管理
- 恶魔单位造价偏高，需要 Power 储备
- 整体经济模型与 SM 类似，但 timing 更激进

---

## 3. Orks（兽人）

### 3.1 设计哲学一句话
> Waaagh! 狂潮：用免费单位和人海淹没对手，人口越多越强。

### 3.2 核心签名机制
- **Waaagh! 系统**：Ork 人口通过 Waaagh! Banners 累积，Banner 同时提供人口上限和防御塔
- **免费 Slugga Boyz**：Slugga Boy 小队增援免费（仅耗人口），可无限补人
- **Waaagh! Banner 防线**：Banner 是防御塔+人口+科技建筑三位一体
- **Mob Bonus**：Ork 单位聚集时获得战力加成，越多越强
- **Waaagh! 技能**：Warboss 可释放 Waaagh!，全军狂暴加速

### 3.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Slugga Boy | Nob | Killa Kan |
| 近战输出 | Slugga Boy | Stormboy | Nob Squad |
| 远程输出 | Shoota Boy | Shoota Boy (Big Shoota) | Looted Tank |
| 反甲 | Tankbusta | Tankbusta (Rokkit) | Killa Kan |
| 攻城 | — | Looted Tank | — |
| 骚扰 | Stormboy | Wartrakk | — |
| 侦察 | Grot | — | — |
| 防空 | — | Wartrakk (Rokkit) | — |
| 运输 | — | Wartrukk | — |
| 英雄 | Big Mek | Warboss | — |

### 3.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | 免费 Slugga 海，Map 控制 | 单兵战力低 |
| T2 | 4-8min | Stormboy + Tankbusta 爆发 | 怕 AOE |
| T3 | 8min+ | Killa Kan + Nob Squad | 运营压力大 |

### 3.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Slugga Boy 海 | 人海 | 免费增援，无限补人，靠数量碾压 |
| Shoota Boy + Big Shoota | 远程压制 | Big Shoota 高 DPS 压制步兵 |
| Stormboy + Tankbusta | 跳跃+反甲 | Stormboy 跳入粘人，Tankbusta 拆载具 |
| Nob Squad + Warboss | 精英近战 | Nob 高血量+Warboss 光环，碾压一切 |
| Killa Kan + Slugga Screen | 载具+人盾 | Killa Kan 反载具/建筑，Slugga 挡住反甲火力 |
| Wartrukk + Stormboy | 高机动骚扰 | Wartrukk 运输+Stormboy 跳跃，双线骚扰 |
| Waaagh! (Warboss) | 全军狂暴 | Warboss 释放后全军加速+攻速，一波定胜负 |

### 3.6 生产机制
- 工人 Grot 建造建筑，Grot 本身可隐身
- **Waaagh! Banner = 一切**：提供人口上限、科技升级、防御塔功能
- Slugga Boy 小队增援**免费**（仅占人口），是 Ork 海战术的基础
- 必须建造足够数量的 Banner 才能解锁科技等级
- 生产建筑简单，多建筑可并行暴兵

### 3.7 机动哲学
- **人海碾压**：不需要复杂机动，直接 A 过去
- **Stormboy 跳跃**：喷气跳跃提供 T1 机动骚扰
- **Wartrukk 运输**：T2 运输载具，加速步兵投入战场
- **Wartrakk 快速骚扰**：轻载具骚扰经济线

### 3.8 视野与地图控制
- Grot 可隐身做前哨
- Waaagh! Banner 提供区域视野+防御
- 大量 Slugga Boy 自然覆盖地图
- 战略点占领+Listening Post 防御

### 3.9 反制弱点
- 怕 AOE：密集队形被 Artillery/Storm/Flamer 克制
- 怕士气武器：Ork 士气低，容易被崩溃
- 单兵质量低：被 SM/Tau 远程火力逐个点杀
- 怕反载具：Killa Kan 被反甲武器轻易摧毁
- 科技上限低：T3/T4 选择有限

### 3.10 强势时间窗
- T1：免费 Slugga 海可压制多数种族
- T2：Stormboy + Tankbusta timing 爆发
- T3：Nob Squad + Killa Kan 仍是威胁

### 3.11 经济模型
- Requisition + Power 标准
- Waaagh! Banner 提供人口而非传统 Pop Cap 升级
- Slugga Boy 免费增援 = 持续战斗力不需经济投入
- 需要大量 Power 造 Banner 和升级科技
- Squiggoth（T4）需要 Relic

---

## 4. Eldar（神灵族）

### 4.1 设计哲学一句话
> 专精化部队：每个 Aspect Warrior 只做一件事但做到极致，以高机动和 Webway 门户弥补脆弱身板。

### 4.2 核心签名机制
- **Webway Gate（网道门）**：Eldar 独有传送网络，单位可在任意 Webway Gate 间传送
- **Aspect 专精**：每种 Aspect Warrior 只擅长一种战斗角色（Banshee=近战、Reaper=远程反步、Dragon=反甲、Spider=传送突击）
- **Bonesinger（骨歌手）**：Eldar 工人可传送，极快建造建筑
- **FoF（Fleet of Foot）**：Farseer 技能，全选单位加速
- **高机动低生存**：速度最快但 HP 最低

### 4.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | — | Howling Banshee | Wraithlord |
| 近战输出 | — | Howling Banshee | Seer Council |
| 远程输出 | Guardian | Dark Reaper | Fire Prism |
| 反甲 | — | Fire Dragon | Wraithlord (Bright Lance) |
| 攻城 | — | Wraithlord | Fire Prism |
| 骚扰 | Ranger | Warp Spider | Swooping Hawk |
| 侦察 | Ranger | — | — |
| 防空 | — | Dark Reaper | Fire Prism |
| 运输 | — | Falcon | — |
| 英雄 | Farseer | Seer Council | Avatar |

### 4.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Guardian + Ranger 士气骚扰 | 无近战，怕速攻 |
| T2 | 4-8min | Aspect 全面解锁，机动碾压 | HP 低，容错低 |
| T3 | 8min+ | Fire Prism + Seer Council + Avatar | 极强但运营极重 |

### 4.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Dark Reaper + Howling Banshee | 远程+近战 | Reaper 远程压制，Banshee 冲锋保护 |
| Fire Dragon + Falcon | 反甲+运输 | Falcon 运 Dragon 到载具旁，下车拆甲 |
| Warp Spider + Teleport | 突袭 | Spider 传送绕后打经济/远程单位 |
| Ranger + Guardian | 士气摧毁 | Ranger Sniper 破士气，Guardian 补伤害 |
| Farseer + Seer Council | 英雄+精英 | Farseer 的 Mind War + Storm + Seer Council 近战 |
| Webway Gate 传送 | 全图机动 | 步兵通过 Webway 网络瞬间转移 |
| Fleet of Foot + Banshee Charge | 冲锋加速 | FoF 加速 Banshee 快速接敌 |

### 4.6 生产机制
- Bonesinger 工人可**传送**，建造速度极快
- 每个 Aspect Warrior 从对应 Aspect Portal 生产（需要先建对应建筑）
- 小队系统：Guardian 小队初始 5 人可增援，Aspect 小队初始 4-5 人
- 无重武器槽，Aspect 单位自带专用武器
- Webway Gate 可作为传送节点和隐蔽通道

### 4.7 机动哲学
- **全族最快**：Eldar 是游戏中最快的种族
- **Webway 传送**：通过 Webway Gate 网络全图移动
- **Warp Spider 传送**：短距离传送突袭
- **Swooping Hawk 飞行**：飞行单位提供纵深打击
- **Fleet of Foot**：全军加速技能

### 4.8 视野与地图控制
- Ranger 可隐身侦察，射程远
- Webway Gate 分布全图提供视野
- Bonesinger 传送可快速探图
- Falcon 提供载具视野

### 4.9 反制弱点
- **极度脆弱**：全族 HP 最低，容错率最低
- 怕近战突脸：Banshee 虽然近战强但 HP 低
- 怕 AOE：低 HP 单位被一发 AOE 就团灭
- 怕反隐：Ranger/Spider 依赖隐身/传送
- T1 无近战：早期被速攻无解

### 4.10 强势时间窗
- T2：Aspect Warrior 全面解锁，机动+专精碾压
- T3：Fire Prism + Seer Council 组合极强
- 任何时候：FoF 提供的机动优势

### 4.11 经济模型
- Requisition + Power 标准
- Bonesinger 快速建造 = 更快扩张
- 单位造价中等，但需要多个 Aspect Portal 覆盖所有角色
- Webway Gate 需要投资但回报巨大
- Avatar 需要 Relic，且会消耗大量资源

---

## 5. Imperial Guard（帝国卫队）

### 5.1 设计哲学一句话
> 人海+重甲：用廉价 Guardsmen 海和帝国最强载具群碾压对手，T3 后载具碾压无解。

### 5.2 核心签名机制
- **Guardsmen 海**：廉价步兵小队（初始 5 人可增援至 12+），靠数量和 Commissar 执行维持战线
- **Commissar 执行（Execute）**：Commissar 枪毙一名 Guardsmen，全队士气恢复 + 射速暴增
- **重载具群**：Leman Russ / Basilisk / Baneblade = 帝国最强载具火力
- **Bunker / Tunnel 系统**：Infantry 可以进驻建筑防御
- **Tunnel（隧道）**：Guard 可以在建筑间通过隧道快速移动

### 5.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Guardsmen | Ogryn | Baneblade |
| 近战输出 | — | Ogryn | — |
| 远程输出 | Guardsmen (GL) | Kasrkin | Heavy Weapons Team |
| 反甲 | Sentinel (LC) | Heavy Weapons Team (LC) | Leman Russ |
| 攻城 | — | Basilisk | Baneblade |
| 骚扰 | Sentinel | Hellhound | Marauder Bomber |
| 侦察 | Sentinel | Vindicare Assassin | — |
| 防空 | Heavy Weapons Team | — | Leman Russ |
| 运输 | — | Chimera | — |
| 英雄 | General | Command Squad | — |

### 5.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Guardsmen 海 + Commissar | 单兵极弱 |
| T2 | 4-8min | Heavy Weapons + Ogryn + 载具开始 | 仍依赖载具 |
| T3 | 8min+ | Leman Russ + Baneblade 碾压 | 运营压力极大 |

### 5.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Guardsmen + Commissar | 人海+执行 | Commissar Execute 恢复士气+射速，Guardsmen 海输出 |
| Guardsmen + Heavy Weapons Team | 步兵+架设 | HWT 提供重火力，Guardsmen 保护 |
| Basilisk + Guardsmen Screen | 攻城+掩护 | Basilisk 远程炮击，Guardsmen 前线挡 |
| Ogryn + Priest | 近战+狂暴 | Priest 加 buff，Ogryn 高血量近战碾压 |
| Leman Russ + Baneblade | 载具碾压 | 双重载具火力，几乎无法反制 |
| Chimera + Kasrkin | 运输+精英 | Chimera 运 Kasrkin 到前线，下车突击 |
| Sentinel + Hellhound | 快速+火焰 | Sentinel 侦察，Hellhound 烧步兵 |

### 5.6 生产机制
- Techpriest Enginseer 工人建造
- Guardsmen 小队初始 5 人，可增援至 12 人，造价极低
- **Commissar / Priest / Psyker** 可附加到 Command Squad 或步兵小队
- Heavy Weapons Team 需要**架设（Setup）**才能开火，类似 CoH 的 MG
- 载具从 Mechanized Command 生产，可多建筑并行
- Tunnel 系统允许建筑间快速移动

### 5.7 机动哲学
- **隧道系统**：通过建筑间的隧道快速转移步兵
- **Chimera 运输**：T2 运输载具
- **Sentinel 快速侦察**：轻载具提供早期机动
- **地面慢速**：步兵速度慢，依赖隧道和运输
- **Baneblade 慢推**：T4 超级载具慢速推进

### 5.8 视野与地图控制
- Sentinel 提供轻载具视野
- Vindicare Assassin 可隐身侦察+狙击
- 建筑提供区域视野
- Tunnel 入口提供视野
- Marauder Bomber 提供空中视野（SS）

### 5.9 反制弱点
- **步兵极弱**：Guardsmen 单兵 HP 最低（~100-160），无 Commissar 则崩溃
- **依赖载具**：T3 前步兵战力不足以正面对抗
- 怕反甲武器：载具是核心战力，被反甲武器克制
- 怕机动骚扰：步兵慢，被高机动种族（Eldar/DE）放风筝
- 怕 AOE：Guardsmen 密集排列被 Artillery/Flamer 克制

### 5.10 强势时间窗
- T2 后期：Heavy Weapons + Ogryn + 初步载具
- T3：Leman Russ + Basilisk 碾压时机
- T4：Baneblade 是游戏最强超级载具之一

### 5.11 经济模型
- Requisition + Power 标准
- Guardsmen 造价极低，可大规模生产
- 载具造价高但战力极高（Leman Russ / Baneblade）
- 需要 Power 储备支撑载具生产
- Baneblade 需要 Relic

---

## 6. Tau Empire（钛帝国）

### 6.1 设计哲学一句话
> 远程火力至上：用 Kroot 近战屏障保护 Fire Warrior 火力线，通过 Mont'ka/Kauyon 路线选择最终形态。

### 6.2 核心签名机制
- **Mont'ka / Kauyon 路线选择**：T2 时选择科技路线，决定 T3/T4 单位
  - **Mont'ka（ Killing Blow）**：解锁 Crisis Suit（机动战甲）+ Hammerhead（主战坦克），偏向载具/科技
  - **Kauyon（ Patient Hunter）**：解锁 Broadside（重火力战甲）+ Krootox（重型 Kroot），偏向步兵/生物
- **Kroot 共生**：Kroot Carnivore 提供近战屏障，Kroot Hound / Krootox 补充近战火力
- **Fire Warrior 射程**：Fire Warrior 射程极远（35+），DPS 高，是游戏最强基础远程步兵
- **Marker Light**：Pathfinder 标记目标，增加友军对标记单位的伤害

### 6.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Kroot Carnivore | Kroot Hound (Kauyon) | Krootox (Kauyon) |
| 近战输出 | Kroot Carnivore | Kroot Hound | — |
| 远程输出 | Fire Warrior | Stealthsuit | Crisis Suit (Mont'ka) / Broadside (Kauyon) |
| 反甲 | — | Broadside / Sky Ray | Hammerhead (Mont'ka) |
| 攻城 | — | Sky Ray | Hammerhead |
| 骚扰 | Drone | Stealthsuit | Crisis Suit |
| 侦察 | Pathfinder | Drone | — |
| 防空 | — | Broadside | Sky Ray |
| 运输 | — | Devilfish | — |
| 英雄 | Tau Commander | Ethereal | — |

### 6.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Fire Warrior 射程碾压 | 无近战（Kroot 较弱） |
| T2 | 4-8min | 路线选择，Crisis/Broadside 解锁 | 路线选择不可逆 |
| T3 | 8min+ | Mont'ka 载具群 / Kauyon 生物群 | 缺乏空中单位 |

### 6.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Fire Warrior + Kroot Screen | 火力线+屏障 | Kroot 挡近战，Fire Warrior 远程输出 |
| Pathfinder + Marker Light + Fire Warrior | 标记+集火 | Pathfinder 标记，Fire Warrior 集火被标单位 |
| Crisis Suit (Mont'ka) | 机动突击 | Crisis Suit 跳跃突袭+多武器配置 |
| Broadside (Kauyon) + Shield Drone | 重火力架设 | Broadside 远程反甲/反步，Shield Drone 保护 |
| Hammerhead + Sky Ray | 载具火力 | Hammerhead 主炮 + Sky Ray 导弹覆盖 |
| Krootox + Kroot Hound (Kauyon) | 生物近战群 | Kroot 系列近战碾压 |
| Ethereal + Fire Warrior | 光环加成 | Ethereal 提供光环 buff，全族 Fire Warrior 增强 |

### 6.6 生产机制
- Earth Caste Builder 工人建造
- Fire Warrior / Kroot 从各自建筑生产
- **Mont'ka / Kauyon 不可逆选择**：T2 选择后决定 T3/T4 路线，不能同时走两条
- Crisis Suit 可配置不同武器（Fusion Blaster / Plasma Rifle / Missile Pod 等）
- Broadside 需要**架设**才能发挥全部火力
- Ethereal 解锁后提供全军 buff，但阵亡会导致全军士气崩溃

### 6.7 机动哲学
- **Crisis Suit 跳跃**：Mont'ka 路线核心机动，喷气跳跃突袭/撤退
- **Devilfish 隐形运输**：T2 运输载具可隐身
- **Stealthsuit 隐身**：隐身骚扰单位
- **Kroot 快速近战**：Kroot 速度较快，快速接敌
- **Fire Warrior 慢速推进**：远程火力线推进，依赖 Kroot 保护

### 6.8 视野与地图控制
- Pathfinder 提供前线视野 + Marker Light
- Stealthsuit 隐身侦察
- Drone 提供载具视野
- Sky Ray 提供间接火力视野
- Devilfish 隐身运输提供隐蔽视野

### 6.9 反制弱点
- **无近战精英**：Kroot 系列是唯一近战，质量不如 SM/Nob
- **怕突脸**：Fire Warrior 被近战贴脸后无还手之力
- **Ethereal 被杀**：全军士气崩溃，灾难性后果
- **路线锁定**：Mont'ka/Kauyon 不可逆，选错路线无法调整
- **无空军**：没有飞行单位（SS 中仍无）

### 6.10 强势时间窗
- T1：Fire Warrior 射程碾压多数 T1 步兵
- T2：路线选择后立即获得 Crisis/Broadside
- T3：Mont'ka 的 Hammerhead / Kauyon 的 Krootox 成型

### 6.11 经济模型
- Requisition + Power 标准
- Fire Warrior 造价中等但性价比极高
- 路线选择后资源投入方向确定，不可分散
- Kroot 单位便宜，提供低成本近战屏障
- Greater Knarloc（Kauyon T4）/ Mont'ka 载具升级需要 Relic

---

## 7. Necrons（太空死灵）

### 7.1 设计哲学一句话
> 不死不灭：免费重生的 Necron Warrior + 自我修复的金属身躯 + Monolith 终极堡垒，用持续消耗战磨死对手。

### 7.2 核心签名机制
- **免费 Necron Warrior**：Necron Warrior **不花 Requisition**（仅需建造时间和 Power），可无限生产
- **自我修复**：所有 Necron 单位被动回血，不倒下就能恢复
- **Resurrection（复活）**：Necron Lord 可复活阵亡友军，Tomb Spyder 可从尸体构建新单位
- **Monolith（方尖碑）**：HQ 建筑可升级为可移动的 Restored Monolith（T4 超级单位），同时是生产建筑+传送点
- **单一资源经济**：Necron **只使用 Power**，不需要 Requisition（战略点用于增加建造速度和人口）

### 7.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Necron Warrior | Necron Warrior | Pariah |
| 近战输出 | Flayed One | Wraith | Pariah |
| 远程输出 | Necron Warrior | Immortal | — |
| 反甲 | — | Immortal | Heavy Destroyer |
| 攻城 | — | — | Monolith |
| 骚扰 | Flayed One (Deep Strike) | Wraith | — |
| 侦察 | — | Wraith | — |
| 防空 | — | Immortal | Heavy Destroyer |
| 运输 | — | — | Monolith |
| 英雄 | Necron Lord | — | Nightbringer (C'tan) |

### 7.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | 免费 Warrior 海，经济压力极小 | 速度极慢 |
| T2 | 4-8min | Immortal + Wraith 反甲+机动 | 仍慢，怕风筝 |
| T3 | 8min+ | Monolith + Nightbringer 终极 | 运营极重 |

### 7.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Necron Warrior 海 | 免费+再生 | 无限生产 + 被动回血，消耗战碾压 |
| Flayed One Deep Strike | 突袭 | 突然空投到敌阵中，恐惧效果降低敌方士气 |
| Wraith + Immortal | 机动+反甲 | Wraith 快速接近，Immortal 远程反甲 |
| Necron Lord + Resurrection Orb | 复活 | Lord 复活阵亡友军，瞬间扭转战局 |
| Tomb Spyder + 尸体回收 | 补员 | Spyder 从尸体构建新 Warrior/Flayed One |
| Monolith + Warrior 海 | 超级堡垒 | Monolith 传送+火力+生产，Warrior 海掩护 |
| Nightbringer (C'tan) | 终极变身 | Necron Lord 变身为 Nightbringer，暂时无敌 |

### 7.6 生产机制
- Builder Scarab 工人建造
- **Necron Warrior 免费**（仅需建造时间 + 少量 Power），是核心机制
- 所有单位从 Monolith（HQ）生产，无需多建筑
- 战略点建造 Obelisk 增加**建造速度**和人口上限（而非提供 Requisition）
- Flayed One 可 Deep Strike 到可见区域
- Monolith 升级为 Restored Monolith 后可移动并作为生产建筑

### 7.7 机动哲学
- **全族最慢**：Necron 是游戏中最慢的种族
- **Deep Strike**：Flayed One 可空投
- **Monolith 传送**：T4 Monolith 可传送
- **Wraith 相对快**：Wraith 是 Necron 中最快的单位
- **慢推碾压**：不追求机动，靠持续推进和免费补员

### 7.8 视野与地图控制
- Obelisk 提供区域视野
- Wraith 提供前线视野
- Flayed One Deep Strike 提供临时视野
- Monolith 传送提供 T4 视野
- 整体视野能力弱，依赖数量覆盖

### 7.9 反制弱点
- **速度极慢**：被高机动种族（Eldar/DE/Tau）无限风筝
- 怕反甲：Immortal/Destroyer 被反甲武器克制
- 怕 artillery/AOE：密集慢速队形被 AOE 克制
- **战略点控制弱**：不产 Requisition，战略点仅加速建造
- 怕早期快攻：T1 速度慢，被快速种族压制

### 7.10 强势时间窗
- T1：免费 Warrior 海在数量上碾压
- T2：Immortal 反甲 + Wraith 机动补充
- T3-T4：Monolith + Nightbringer 终极组合

### 7.11 经济模型
- **仅 Power 单一资源**：不需要 Requisition
- 战略点 → Obelisk → 增加建造速度 + 人口上限
- Power Generator 是唯一经济建筑，需大量建造
- Necron Warrior 免费 = 无限兵力，只需时间
- Restored Monolith 需要 Relic + 大量 Power

---

## 8. Sisters of Battle（战斗修女）

### 8.1 设计哲学一句话
> 信仰之力：以 Faith（信仰）系统驱动 Acts of Faith（神迹），用圣三一体（爆弹/喷火/熔岩）的火力净化一切。

### 8.2 核心签名机制
- **Faith（信仰）系统**： Sisters 独有资源，通过 Missionary / Cannoness 等单位积累，用于施放 Acts of Faith
- **Acts of Faith（神迹）**：消耗 Faith 施放强力技能（如全员治疗、射速暴增、近战加成等）
- **圣三一体（Holy Trinity）**：Bolter + Flamer + Melta 的三武器组合，反步+士气+反甲全覆盖
- **Seraphim 双手枪**：Seraphim 装备双手爆弹枪/ inferno pistol，高机动跳跃
- **Living Saint（活圣人）**：T4 超级单位，飞行 + 复活 + AOE 治疗

### 8.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Battle Sister | Repentia | Penitent Engine |
| 近战输出 | — | Repentia | Penitent Engine |
| 远程输出 | Battle Sister (Bolter) | Celestian (Melta) | Retributor (Heavy Bolter) |
| 反甲 | — | Celestian (Melta) | Exorcist (Missile) |
| 攻城 | — | Immolator | Exorcist |
| 骚扰 | Seraphim | Seraphim | — |
| 侦察 | Missionary | — | — |
| 防空 | — | Retributor (Heavy Bolter) | Exorcist |
| 运输 | — | Immolator | — |
| 英雄 | Cannoness | Missionary | Confessor |

### 8.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Battle Sister + Missionary 组合扎实 | 缺乏近战 |
| T2 | 4-8min | Seraphim + Celestian + Immolator 全能 | 造价偏高 |
| T3 | 8min+ | Exorcist + Penitent Engine + Living Saint | 运营压力 |

### 8.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Battle Sister + Flamer + Missionary | 士气+信仰 | Flamer 破士气，Missionary 积累 Faith |
| Seraphim + Jump | 高机动骚扰 | Seraphim 跳跃骚扰经济线 |
| Celestian Melta + Repentia | 反甲+近战 | Celestian 拆载具，Repentia 近战保护 |
| Retributor Heavy Bolter + Immolator | 火力阵地 | Retributor 架设输出，Immolator 火焰保护 |
| Exorcist Missile + Penitent Engine | 攻城+近战 | Exorcist 远程导弹，Penitent Engine 冲锋 |
| Acts of Faith: Divine Light | 全军 buff | 消耗 Faith，全员射速/近战暴增 |
| Living Saint + Seraphim | 终极飞行群 | Saint 飞行+AOE治疗 + Seraphim 跳跃护卫 |

### 8.6 生产机制
- 工人建造建筑
- Battle Sister 小队系统类似 SM，可配备重武器
- Faith 通过特定单位（Missionary / Cannoness / Seraphim）在战斗中积累
- Acts of Faith 需要消耗 Faith 点数，有冷却
- Living Saint 从 Relic 建筑召唤

### 8.7 机动哲学
- **Seraphim 跳跃**：核心机动单位，喷气跳跃
- **Immolator 运输**：T2 火焰运输载具
- **Penitent Engine 冲锋**：高速度近战载具
- **Living Saint 飞行**：T4 飞行超级单位
- 整体机动性中等，依赖 Seraphim 提供机动

### 8.8 视野与地图控制
- Missionary 可隐身侦察
- Seraphim 提供前线跳跃视野
- Exorcist 提供间接火力视野
- 整体视野能力一般

### 8.9 反制弱点
- **依赖 Faith**：Faith 耗尽后战力大幅下降
- 怕反甲：Immolator / Penitent Engine / Exorcist 被反甲武器克制
- 近战不足：除 Repentia 和 Penitent Engine 外缺乏近战
- 怕快攻：T1 近战弱，被 Ork/Nid 类种族压制
- Living Saint 有时限：Saint 阵亡后需要重新积累 Faith 召唤

### 8.10 强势时间窗
- T2：Seraphim + Celestian + Immolator 组合成型
- T3：Exorcist + Penitent Engine 载具群
- T4：Living Saint 是强力超级单位

### 8.11 经济模型
- Requisition + Power + **Faith**（第三资源）
- Faith 通过战斗积累，不能直接购买
- 单位造价中等偏高
- 需要 Relic 召唤 Living Saint
- 整体经济模型与 SM 类似，Faith 管理是额外维度

---

## 9. Dark Eldar（暗黑神灵族）

### 9.1 设计哲学一句话
> 速度与掠夺：以全族最快速度和 Soul Essence（灵魂精华）驱动的超级技能，打完就跑，不跑就死。

### 9.2 核心签名机制
- **Soul Essence（灵魂精华）**：第三资源，通过击杀敌方单位积累，用于施放强力技能
- **全族极速**：Dark Eldar 是游戏中最快的种族之一（与 Eldar 竞争）
- **Raid（掠夺）**：快速打击+撤退，不恋战
- **Soul Powers（灵魂技能）**：消耗 Soul Essence 的强力 AOE/召唤/buff 技能
- **Dais of Destruction**：T4 超级载具，Archon 的专属战车

### 9.3 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Mandrake | — | Talos |
| 近战输出 | Mandrake | Hellion | Lelith Hesperax |
| 远程输出 | Warrior (Splinter) | Scourge (Dark Lance) | Ravager |
| 反甲 | — | Scourge (Dark Lance) | Ravager |
| 攻城 | — | — | Ravager |
| 骚扰 | Mandrake (Infil) | Reaver, Hellion | — |
| 侦察 | Mandrake (Infil) | — | — |
| 防空 | — | Scourge | Ravager |
| 运输 | — | Raider | — |
| 英雄 | Archon | Haemonculus | Lelith Hesperax |

### 9.4 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | 极速骚扰，Mandrake 隐身 | 正面战力弱 |
| T2 | 4-8min | Scourge + Raider 高机动打击 | HP 低，容错低 |
| T3 | 8min+ | Ravager + Soul Powers + Dais | 运营压力 |

### 9.5 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| Mandrake + Infiltration | 隐身骚扰 | 隐身接近经济单位，打完就跑 |
| Raider + Warrior/Scourge | 运输+突袭 | Raider 运输步兵到关键位置，下车突袭 |
| Reaver + Hellion | 双线骚扰 | Reaver 快速打击 + Hellion 跳跃骚扰 |
| Scourge Dark Lance + Ravager | 反甲火力网 | Scourge 步兵反甲 + Ravager 载具反甲 |
| Soul Power: Soul Storm | AOE 爆发 | 消耗 Soul Essence 释放 AOE 风暴 |
| Talos + Lelith | 前排+英雄 | Talos 肉盾 + Lelith 高输出近战 |
| Dais of Destruction | 终极载具 | Archon 专属战车，高火力+光环 |

### 9.6 生产机制
- 工人建造建筑
- 小队系统：Warrior / Scourge 小队可增援
- Soul Essence 通过击杀敌方单位积累，不能直接购买
- Soul Powers 从专门的 Soul Essence 管理界面施放
- Dais of Destruction 从 Relic 召唤

### 9.7 机动哲学
- **全族极速**：Dark Eldar 是最快的种族之一
- **Reaver Jetbike**：极快速飞行单位，打完就跑
- **Hellion 跳跃**：喷气跳跃近战
- **Raider 运输**：快速运输载具
- **Raid 战术**：快速打击+撤退，不进行持久战

### 9.8 视野与地图控制
- Mandrake 可隐身侦察
- Reaver 提供快速飞行视野
- 高机动单位自然覆盖地图
- 整体视野能力中等

### 9.9 反制弱点
- **极度脆弱**：全族 HP 最低（与 Eldar 竞争）
- 怕正面对抗：必须靠机动+骚扰，正面硬打必输
- 怕反隐：Mandrake 依赖隐身
- Soul Essence 依赖击杀：无法击杀则无法使用 Soul Powers
- 怕 AOE：低 HP 单位被 AOE 团灭

### 9.10 强势时间窗
- T1：Mandrake 隐身骚扰经济
- T2：Scourge + Raider 高机动打击
- T3：Ravager + Soul Powers 爆发

### 9.11 经济模型
- Requisition + Power + **Soul Essence**（第三资源）
- Soul Essence 需要通过战斗获取，鼓励进攻性打法
- 单位造价低但 HP 也低，性价比靠机动性
- Dais of Destruction 需要 Relic
- 整体经济鼓励快速进攻和持续骚扰

---

# 第二部分：单位数据表

---

## 2.1 Space Marines（星际战士）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 连长（部队指挥官） |
| name_en | Force Commander |
| race | Space Marines |
| tier | 1 |
| built_from | HQ (Stronghold) |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~60s |
| pop_cost | 2 (infantry) |
| hp | ~1200 |
| morale | 600 |
| armor_type | commander |
| tags | 英雄, 指挥官 |
| speed | ~16 |
| jump | 否 |
| fly | 否 |
| vision | ~25 |
| transport_slots | — |
| weapon_name | Power Sword + Bolt Pistol |
| damage | ~85-100 (melee) |
| atk_type | 对 commander/infantry 高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| splash | 0 |
| bonus_vs | — |
| squad_size | 1 |
| reinforce_cost | — |
| heavy_weapons_slots | — |
| active | Orbital Bombardment（轨道轰炸，T3，需目标视野） |
| passive | Commander armor（高全穿透抗性） |
| upgrades | Power Fist（升级近战武器，反甲增强）, Terminator Armor（T3，可穿终结者甲） |

| 字段 | 值 |
|---|---|
| name_zh | 牧师 |
| name_en | Chaplain |
| race | Space Marines |
| tier | 2 |
| built_from | Sacred Artifact |
| cost_req | 100 |
| cost_power | 75 |
| build_time | ~40s |
| pop_cost | 2 |
| hp | ~800 |
| morale | 500 |
| armor_type | commander |
| tags | 英雄 |
| speed | ~16 |
| jump | 否 |
| fly | 否 |
| vision | ~20 |
| transport_slots | — |
| weapon_name | Crozius Arcanum |
| damage | ~60-70 (melee) |
| atk_type | melee |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| squad_size | 1 |
| active | Demoralizing Shout（降低敌方士气） |
| passive | Litanies of Hate（光环：友军士气恢复加速） |

| 字段 | 值 |
|---|---|
| name_zh | 图书管理员 |
| name_en | Librarian |
| race | Space Marines |
| tier | 2 |
| built_from | Sacred Artifact |
| cost_req | 100 |
| cost_power | 100 |
| build_time | ~40s |
| pop_cost | 2 |
| hp | ~700 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 灵能 |
| speed | ~16 |
| jump | 否 |
| fly | 否 |
| vision | ~20 |
| weapon_name | Force Weapon |
| damage | ~50-60 (melee) |
| atk_type | melee |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Smite（AOE 灵能伤害）, Weaken Resolve（降低敌方士气） |
| passive | — |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 仆从 |
| name_en | Servitor |
| race | Space Marines |
| tier | 1 |
| built_from | HQ |
| cost_req | 65 |
| cost_power | 0 |
| build_time | ~10s |
| pop_cost | 1 |
| hp | ~100 |
| morale | 100 |
| armor_type | infantry |
| tags | 工人 |
| speed | ~10 |
| vision | ~15 |
| weapon_name | — |
| damage | — |
| notes | 建造/修理单位，无战斗能力 |

| 字段 | 值 |
|---|---|
| name_zh | 侦察兵小队 |
| name_en | Scout Squad |
| race | Space Marines |
| tier | 1 |
| built_from | Chapel Barracks |
| cost_req | 45 (初始 2 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 侦察 |
| speed | ~16 |
| vision | ~25 |
| weapon_name | Bolt Pistol (默认) / Sniper Rifle (升级) |
| damage | ~20 (Bolt Pistol) / ~150 (Sniper, 高士气伤害) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~0.5s (BP) / ~3s (Sniper) |
| range | ~15 (BP) / ~40 (Sniper) |
| target | B (Sniper 为 G) |
| squad_size | 2 初始, 可增援至 4-5 |
| reinforce_cost | ~22 req |
| heavy_weapons_slots | 1 (Sniper Rifle) |
| active | Infiltration（隐身，需升级） |
| passive | — |
| upgrades | Sniper Rifle, Infiltration |

| 字段 | 值 |
|---|---|
| name_zh | 战术小队 |
| name_en | Tactical Marine Squad |
| race | Space Marines |
| tier | 1 |
| built_from | Chapel Barracks |
| cost_req | 220 (初始 4 人) |
| cost_power | 0 |
| build_time | ~12s |
| pop_cost | 2 (每模型 0.5) |
| hp | ~390 / 模型 |
| morale | 300 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 核心 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Bolter (默认) |
| damage | ~25-30 |
| atk_type | 对 infantry/infantry_heavy 中高穿透 |
| cooldown | ~0.5s |
| range | ~25 |
| target | B |
| squad_size | 4 初始, 可增援至 8 (SS) |
| reinforce_cost | ~50 req |
| heavy_weapons_slots | 2 (T1: Flamer; T2: Missile Launcher, Plasma Gun, Heavy Bolter) |
| active | — |
| passive | — |
| upgrades | Bionics (+HP), Target Finder (+射程), Heavy Weapons 升级 |
| notes | SM 核心单位，多功能重武器使其适应任何战局。Missile Launcher 反甲/反建筑，Plasma Gun 反重步，Flamer 反士气，Heavy Bolter 反轻步 |

| 字段 | 值 |
|---|---|
| name_zh | 突击小队 |
| name_en | Assault Marine Squad |
| race | Space Marines |
| tier | 1 (需 Armory) |
| built_from | Chapel Barracks |
| cost_req | 220 (初始 4 人) |
| cost_power | 0 |
| build_time | ~15s |
| pop_cost | 2 |
| hp | ~390 / 模型 |
| morale | 300 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 跳跃 |
| speed | ~14 |
| jump | 是 (喷气跳跃) |
| vision | ~20 |
| weapon_name | Bolt Pistol + Chainsword |
| damage | ~35-40 (melee) |
| atk_type | melee, 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~55 req |
| heavy_weapons_slots | 1 (Melta Gun, T2) |
| active | Jump (跳跃, 有冷却) |
| passive | — |
| upgrades | Melta Gun (反甲) |

| 字段 | 值 |
|---|---|
| name_zh | 终结者小队 |
| name_en | Terminator Squad |
| race | Space Marines |
| tier | 3 |
| built_from | Orbital Relay (Deep Strike) |
| cost_req | 280 (初始 3 人) |
| cost_power | 80 |
| build_time | ~20s |
| pop_cost | 3 |
| hp | ~600 / 模型 |
| morale | 500 |
| armor_type | infantry_heavy_high |
| tags | 重步兵, 终结者, 精英 |
| speed | ~10 (慢) |
| vision | ~20 |
| weapon_name | Storm Bolter (默认) |
| damage | ~30-35 |
| atk_type | 对 infantry/infantry_heavy 高穿透 |
| cooldown | ~0.4s |
| range | ~25 |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~90 req + 25 power |
| heavy_weapons_slots | 2 (Assault Cannon, Heavy Flamer) |
| active | Deep Strike (从轨道空降) |
| passive | — |
| upgrades | Assault Cannon, Heavy Flamer |
| notes | 最强步兵之一，高 HP 高士气高甲，但慢且贵 |

| 字段 | 值 |
|---|---|
| name_zh | 突击终结者小队 |
| name_en | Assault Terminator Squad |
| race | Space Marines |
| tier | 3 |
| built_from | Orbital Relay (Deep Strike) |
| cost_req | 280 (初始 3 人) |
| cost_power | 80 |
| build_time | ~20s |
| pop_cost | 3 |
| hp | ~600 / 模型 |
| morale | 500 |
| armor_type | infantry_heavy_high |
| tags | 重步兵, 终结者, 近战 |
| speed | ~10 |
| jump | 否 |
| vision | ~20 |
| weapon_name | Lightning Claws / Thunder Hammer |
| damage | ~80-100 (melee) |
| atk_type | melee, 对 infantry/infantry_heavy/commander 高穿透 |
| cooldown | ~1.2s |
| range | melee |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~90 req + 25 power |
| active | Deep Strike |
| passive | — |
| notes | 终极近战步兵，克制一切步兵但慢 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 无畏机甲 |
| name_en | Dreadnought |
| race | Space Marines |
| tier | 2 |
| built_from | Machine Cult |
| cost_req | 150 |
| cost_power | 300 |
| build_time | ~30s |
| pop_cost | 2 (vehicle) |
| hp | ~3800 |
| armor_type | vehicle_med |
| tags | 载具, 机械, 近战 |
| speed | ~10 |
| vision | ~20 |
| weapon_name | Assault Cannon (默认) / Twin-linked Lascannon (升级) + Power Weapon (melee) |
| damage | ~60 (Assault Cannon) / ~150 (TL Lascannon) / ~200 (melee) |
| atk_type | AC: 对 infantry 高穿透; LC: 对 vehicle 高穿透 |
| cooldown | ~0.3s (AC) / ~2s (LC) |
| range | ~25 (AC) / ~35 (LC) / melee |
| target | B |
| squad_size | 1 |
| active | — |
| passive | — |
| upgrades | Twin-linked Lascannon (反甲升级) |
| notes | T2 核心，可近战可远程，反步/反甲二选一 |

| 字段 | 值 |
|---|---|
| name_zh | 犀牛运输车 |
| name_en | Rhino |
| race | Space Marines |
| tier | 2 |
| built_from | Machine Cult |
| cost_req | 50 |
| cost_power | 50 |
| build_time | ~10s |
| pop_cost | 1 (vehicle) |
| hp | ~2000 |
| armor_type | vehicle_med |
| tags | 载具, 运输 |
| speed | ~20 |
| vision | ~15 |
| weapon_name | Storm Bolter |
| damage | ~10 |
| transport_slots | 乘载 3 个小队 |
| notes | 纯运输载具，火力可忽略 |

| 字段 | 值 |
|---|---|
| name_zh | 土地快艇 |
| name_en | Land Speeder |
| race | Space Marines |
| tier | 2 |
| built_from | Machine Cult |
| cost_req | 100 |
| cost_power | 150 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1200 |
| armor_type | vehicle_low |
| tags | 载具, 快速, 飞行 |
| speed | ~24 (快) |
| fly | 是 |
| vision | ~25 |
| weapon_name | Heavy Bolter (默认) / Assault Cannon + Multi-Melta (升级) |
| damage | ~30 (HB) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~0.3s |
| range | ~25 |
| target | B |
| notes | 快速飞行骚扰单位，低 HP |

| 字段 | 值 |
|---|---|
| name_zh | 捕食者坦克 |
| name_en | Predator |
| race | Space Marines |
| tier | 3 |
| built_from | Machine Cult |
| cost_req | 150 |
| cost_power | 350 |
| build_time | ~30s |
| pop_cost | 3 (vehicle) |
| hp | ~4000 |
| armor_type | vehicle_high |
| tags | 载具, 坦克 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Twin-linked Lascannon ( turret) + Heavy Bolter sponsons (默认) / Lascannon sponsons (升级) |
| damage | ~150 (TL LC) / ~30 (HB) |
| atk_type | LC: 对 vehicle 高穿透; HB: 对 infantry |
| cooldown | ~2s (LC) / ~0.3s (HB) |
| range | ~40 (LC) / ~25 (HB) |
| target | B |
| upgrades | Lascannon Sponsons (全反甲配置) |
| notes | T3 主战坦克，反甲/反步配置可选 |

| 字段 | 值 |
|---|---|
| name_zh | 旋风导弹车 |
| name_en | Whirlwind |
| race | Space Marines |
| tier | 3 |
| built_from | Machine Cult |
| cost_req | 120 |
| cost_power | 300 |
| build_time | ~25s |
| pop_cost | 3 (vehicle) |
| hp | ~3000 |
| armor_type | vehicle_med |
| tags | 载具, 攻城 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Vengeance Missile Launcher |
| damage | ~100 |
| atk_type | 对 infantry/building 高穿透, AOE |
| cooldown | ~4s |
| range | ~60 (远程间接火力) |
| target | G |
| splash | 大范围 AOE |
| notes | 间接火力攻城单位，需要视野 |

| 字段 | 值 |
|---|---|
| name_zh | 兰德掠袭者 |
| name_en | Land Raider |
| race | Space Marines |
| tier | 4 |
| built_from | Machine Cult (需 Relic) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 4 (vehicle) |
| hp | ~6000 |
| armor_type | vehicle_high |
| tags | 载具, 超级, 运输 |
| speed | ~12 |
| vision | ~25 |
| weapon_name | Twin-linked Lascannon × 2 + Twin-linked Heavy Bolter |
| damage | ~150 (each LC) / ~30 (TLHB) |
| atk_type | LC: 反 vehicle; HB: 反 infantry |
| cooldown | ~2s (LC) / ~0.3s (HB) |
| range | ~40 (LC) / ~25 (HB) |
| target | B |
| transport_slots | 乘载 1 个终结者小队 |
| notes | T4 超级单位，最重装甲+运输+双 LC，几乎无敌 |

---

## 2.2 Chaos（混沌星际战士）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 混沌之主 |
| name_en | Chaos Lord |
| race | Chaos |
| tier | 1 |
| built_from | HQ (Desecrated Stronghold) |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~60s |
| pop_cost | 2 |
| hp | ~1200 |
| morale | 600 |
| armor_type | commander |
| tags | 英雄 |
| speed | ~16 |
| vision | ~25 |
| weapon_name | Power Sword + Bolt Pistol |
| damage | ~85-100 (melee) |
| atk_type | melee, 对 commander/infantry 高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Corruption（腐蚀地面，减速+伤害）, Daemon Weapons（T3，升级武器，伤害暴增） |
| passive | — |
| upgrades | Daemon Weapons (T3 升级, 近战伤害大幅增加) |

| 字段 | 值 |
|---|---|
| name_zh | 巫师 |
| name_en | Sorcerer |
| race | Chaos |
| tier | 2 |
| built_from | Sacrificial Circle |
| cost_req | 100 |
| cost_power | 100 |
| build_time | ~40s |
| pop_cost | 2 |
| hp | ~700 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 灵能 |
| speed | ~16 |
| vision | ~20 |
| weapon_name | Force Weapon |
| damage | ~50-60 (melee) |
| atk_type | melee |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Doombolt（灵能 AOE 弹）, Corruption, Chains of Torment（定身） |
| passive | — |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 异教徒 |
| name_en | Heretic |
| race | Chaos |
| tier | 1 |
| built_from | HQ |
| cost_req | 60 |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~80 |
| morale | 50 |
| armor_type | infantry |
| tags | 工人 |
| speed | ~12 |
| vision | ~15 |
| weapon_name | — |
| damage | — |
| notes | 工人单位，可加速建造（消耗 HP），可隐身（升级后） |

| 字段 | 值 |
|---|---|
| name_zh | 邪教徒小队 |
| name_en | Cultist Squad |
| race | Chaos |
| tier | 1 |
| built_from | Chaos Temple |
| cost_req | 90 (初始 4 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~120 / 模型 |
| morale | 80 |
| armor_type | infantry |
| tags | 轻步兵 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Bolt Pistol (默认) / Grenade Launcher (升级) |
| damage | ~10 (BP) / ~40 (GL, 士气伤害) |
| atk_type | GL: 对 infantry + 士气 |
| cooldown | ~0.5s (BP) / ~3s (GL) |
| range | ~15 (BP) / ~30 (GL) |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~15 req |
| heavy_weapons_slots | 2 (Grenade Launcher) |
| active | Infiltration（隐身，需升级） |
| passive | — |
| upgrades | Grenade Launcher, Infiltration |

| 字段 | 值 |
|---|---|
| name_zh | 混沌星际战士小队 |
| name_en | Chaos Space Marine Squad |
| race | Chaos |
| tier | 1 |
| built_from | Chaos Temple |
| cost_req | 220 (初始 4 人) |
| cost_power | 0 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~390 / 模型 |
| morale | 250 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 核心 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Bolter (默认) |
| damage | ~25-30 |
| atk_type | 对 infantry/infantry_heavy 中高穿透 |
| cooldown | ~0.5s |
| range | ~25 |
| target | B |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~50 req |
| heavy_weapons_slots | 2 (Plasma Gun, Missile Launcher, Heavy Bolter) |
| upgrades | Plasma Gun, Missile Launcher, Heavy Bolter |
| notes | CSM 是 SM Tactical 的镜像，重武器选择略少 |

| 字段 | 值 |
|---|---|
| name_zh | 恐虐狂战士 |
| name_en | Khorne Berzerker |
| race | Chaos |
| tier | 2 |
| built_from | Sacrificial Circle |
| cost_req | 180 (初始 4 人) |
| cost_power | 20 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~450 / 模型 |
| morale | 300 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 近战 |
| speed | ~16 (较快) |
| vision | ~20 |
| weapon_name | Chainsword + Bolt Pistol |
| damage | ~50-60 (melee) |
| atk_type | melee, 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~45 req + 5 power |
| active | Blood Rage (被动加速) |
| passive | 高士气抗性 |
| notes | T2 核心近战，高输出高士气，Chaos timing 的关键 |

| 字段 | 值 |
|---|---|
| name_zh | 被附身战士 |
| name_en | Possessed Marine |
| race | Chaos |
| tier | 2 |
| built_from | Daemon Pit |
| cost_req | 200 (初始 3 人) |
| cost_power | 40 |
| build_time | ~15s |
| pop_cost | 3 |
| hp | ~550 / 模型 |
| morale | 400 |
| armor_type | daemon_low |
| tags | 恶魔, 重步兵, 近战 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Daemon Claws |
| damage | ~70-80 (melee) |
| atk_type | 对 infantry/infantry_heavy 高穿透 |
| cooldown | ~1.2s |
| range | melee |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~65 req + 15 power |
| active | — |
| passive | Daemon armor（对多数武器有抗性） |
| notes | T2 终极近战，恶魔甲使其难以被常规武器伤害 |

| 字段 | 值 |
|---|---|
| name_zh | 恐魔 |
| name_en | Horror |
| race | Chaos |
| tier | 2 |
| built_from | Daemon Pit |
| cost_req | 150 (初始 3 人) |
| cost_power | 40 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~300 / 模型 |
| morale | — (免疫士气) |
| armor_type | daemon_low |
| tags | 恶魔, 远程, 反甲 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Fire of Tzeentch |
| damage | ~80-100 |
| atk_type | 对 vehicle/building 高穿透 |
| cooldown | ~2s |
| range | ~30 |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~50 req + 15 power |
| active | Deep Strike |
| passive | 免疫士气 |
| notes | 恶魔反甲单位，可 Deep Strike 突袭载具 |

| 字段 | 值 |
|---|---|
| name_zh | 湮灭者 |
| name_en | Obliterator |
| race | Chaos |
| tier | 3 |
| built_from | Daemon Pit (需 T3) |
| cost_req | 200 (初始 3 人) |
| cost_power | 80 |
| build_time | ~20s |
| pop_cost | 3 |
| hp | ~600 / 模型 |
| morale | — (免疫士气) |
| armor_type | daemon_high |
| tags | 恶魔, 重步兵, 全能 |
| speed | ~10 (慢) |
| vision | ~20 |
| weapon_name | Assault Cannon / Lascannon / Plasma Cannon (可切换) |
| damage | ~60 (AC) / ~150 (LC) / ~80 (PC, AOE) |
| atk_type | 全类型高穿透 |
| cooldown | ~0.3s (AC) / ~2s (LC) |
| range | ~25-40 |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~65 req + 30 power |
| active | — |
| passive | 免疫士气, 自我修复, 武器自适应 |
| notes | T3 终极步兵，全能火力+恶魔甲+自修，几乎无弱点 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 亵渎者 |
| name_en | Defiler |
| race | Chaos |
| tier | 2 |
| built_from | Machine Pit |
| cost_req | 150 |
| cost_power | 300 |
| build_time | ~30s |
| pop_cost | 3 (vehicle) |
| hp | ~3500 |
| armor_type | vehicle_med |
| tags | 载具, 机械, 攻城, 近战 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Battle Cannon (远程) + Claws (melee) |
| damage | ~100 (BC, AOE) / ~200 (melee) |
| atk_type | BC: 对 infantry/building; melee: 对 vehicle |
| cooldown | ~4s (BC) / ~1.5s (melee) |
| range | ~50 (BC, 间接火力) / melee |
| target | B |
| notes | 多功能载具，远程炮击+近战+反步+攻城，Chaos T2 核心 |

| 字段 | 值 |
|---|---|
| name_zh | 混沌捕食者 |
| name_en | Chaos Predator |
| race | Chaos |
| tier | 3 |
| built_from | Machine Pit |
| cost_req | 150 |
| cost_power | 350 |
| build_time | ~30s |
| pop_cost | 3 (vehicle) |
| hp | ~4000 |
| armor_type | vehicle_high |
| tags | 载具, 坦克 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Twin-linked Lascannon + Heavy Bolter sponsons / LC sponsons |
| damage | ~150 (TL LC) / ~30 (HB) |
| atk_type | LC: 反 vehicle; HB: 反 infantry |
| cooldown | ~2s (LC) / ~0.3s (HB) |
| range | ~40 (LC) / ~25 (HB) |
| target | B |
| upgrades | Lascannon Sponsons |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 嗜血者 |
| name_en | Bloodthirster |
| race | Chaos |
| tier | 4 |
| built_from | Sacrificial Circle (需 Relic + T3) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~8000 |
| armor_type | daemon_high |
| tags | 恶魔, 飞行, 超级 |
| speed | ~16 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Axe of Khorne + Lash of Khorne |
| damage | ~300-400 (melee) |
| atk_type | 对全类型高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | — |
| passive | 飞行, 恐惧光环（降低敌方士气） |
| notes | T4 超级恶魔，飞行+极高近战伤害+士气光环，游戏最强超级单位之一 |

---

## 2.3 Orks（兽人）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 大技霸 |
| name_en | Big Mek |
| race | Orks |
| tier | 1 |
| built_from | HQ (Settlement) |
| cost_req | 120 |
| cost_power | 50 |
| build_time | ~30s |
| pop_cost | 2 |
| hp | ~800 |
| morale | 300 |
| armor_type | commander |
| tags | 英雄 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Power Klaw |
| damage | ~80-100 (melee) |
| atk_type | melee, 对 infantry/vehicle 中穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Turbo Boost（加速冲刺） |
| passive | Mekboy aura |
| notes | T1 英雄，可建 Waaagh! Banner |

| 字段 | 值 |
|---|---|
| name_zh | 战帅 |
| name_en | Warboss |
| race | Orks |
| tier | 2 |
| built_from | HQ (需 T2) |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~40s |
| pop_cost | 3 |
| hp | ~1200 |
| morale | 500 |
| armor_type | commander |
| tags | 英雄 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Power Klaw |
| damage | ~120-150 (melee) |
| atk_type | melee, 对全类型高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Waaagh!（全军狂暴：加速+攻速+士气恢复） |
| passive | Warboss aura（友军士气恢复） |
| notes | Waaagh! 技能是 Ork 终极 timing 的核心 |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 小鬼 |
| name_en | Grot |
| race | Orks |
| tier | 1 |
| built_from | HQ |
| cost_req | 45 |
| cost_power | 0 |
| build_time | ~5s |
| pop_cost | 1 |
| hp | ~50 |
| morale | 50 |
| armor_type | infantry |
| tags | 工人 |
| speed | ~12 |
| vision | ~15 |
| weapon_name | — |
| damage | — |
| notes | 工人，可隐身（升级后），建造建筑 |

| 字段 | 值 |
|---|---|
| name_zh | 砍杀小子 |
| name_en | Slugga Boy |
| race | Orks |
| tier | 1 |
| built_from | Boyz Hut |
| cost_req | 130 (初始 4 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~250 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 近战 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Slugga + Choppa |
| damage | ~25-30 (melee) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 15+ |
| reinforce_cost | **免费**（仅占人口） |
| heavy_weapons_slots | 1 (Burna, T2) |
| active | — |
| passive | Mob Bonus（周围友军 Ork 越多，战力越高） |
| upgrades | Burna (火焰武器, T2) |
| notes | **免费增援**是 Ork 核心机制，可无限补人 |

| 字段 | 值 |
|---|---|
| name_zh | 射击小子 |
| name_en | Shoota Boy |
| race | Orks |
| tier | 1 |
| built_from | Boyz Hut |
| cost_req | 140 (初始 4 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~250 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 远程 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Shoota (默认) / Big Shoota (升级) |
| damage | ~15 (Shoota) / ~30 (Big Shoota) |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.5s |
| range | ~25 |
| target | B |
| squad_size | 4 初始, 可增援至 8+ |
| reinforce_cost | ~15 req |
| heavy_weapons_slots | 2 (Big Shoota) |
| upgrades | Big Shoota |

| 字段 | 值 |
|---|---|
| name_zh | 暴风小子 |
| name_en | Stormboy |
| race | Orks |
| tier | 2 (需 Pile O' Gunz) |
| built_from | Boyz Hut |
| cost_req | 180 (初始 4 人) |
| cost_power | 10 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~280 / 模型 |
| morale | 200 |
| armor_type | infantry |
| tags | 轻步兵, 跳跃, 近战 |
| speed | ~14 |
| jump | 是 |
| vision | ~20 |
| weapon_name | Choppa + Slugga |
| damage | ~30 (melee) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~40 req + 2 power |
| active | Jump |

| 字段 | 值 |
|---|---|
| name_zh | 坦克粉碎者 |
| name_en | Tankbusta |
| race | Orks |
| tier | 2 |
| built_from | Boyz Hut |
| cost_req | 150 (初始 3 人) |
| cost_power | 20 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~250 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 反甲 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Rokkit Launcha |
| damage | ~120-150 |
| atk_type | 对 vehicle/building 高穿透 |
| cooldown | ~2s |
| range | ~30 |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~50 req + 5 power |
| notes | Ork 核心反甲步兵 |

| 字段 | 值 |
|---|---|
| name_zh | 贵族小队 |
| name_en | Nob Squad |
| race | Orks |
| tier | 3 |
| built_from | Da Panze (需 T3) |
| cost_req | 200 (初始 3 人) |
| cost_power | 40 |
| build_time | ~15s |
| pop_cost | 3 |
| hp | ~500 / 模型 |
| morale | 300 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 近战, 精英 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Power Klaw + Slugga |
| damage | ~80-100 (melee) |
| atk_type | 对 infantry/infantry_heavy/vehicle 中高穿透 |
| cooldown | ~1.2s |
| range | melee |
| target | G |
| squad_size | 3 初始, 可增援至 6 |
| reinforce_cost | ~65 req + 15 power |
| heavy_weapons_slots | 1 (Power Klaw 升级) |
| active | — |
| passive | Mob Bonus |
| notes | Ork 终极近战步兵，高血量+高伤害 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 战卡车 |
| name_en | Wartrukk |
| race | Orks |
| tier | 2 |
| built_from | Mek Shop |
| cost_req | 80 |
| cost_power | 60 |
| build_time | ~15s |
| pop_cost | 1 (vehicle) |
| hp | ~1200 |
| armor_type | vehicle_low |
| tags | 载具, 运输, 快速 |
| speed | ~24 (快) |
| vision | ~20 |
| weapon_name | Twin-linked Big Shoota |
| damage | ~20 |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.3s |
| range | ~25 |
| target | B |
| transport_slots | 乘载 1 个小队 |
| notes | 快速运输载具 |

| 字段 | 值 |
|---|---|
| name_zh | 战车 |
| name_en | Wartrakk |
| race | Orks |
| tier | 2 |
| built_from | Mek Shop |
| cost_req | 100 |
| cost_power | 80 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1000 |
| armor_type | vehicle_low |
| tags | 载具, 快速, 反甲 |
| speed | ~22 (快) |
| vision | ~20 |
| weapon_name | Rokkit Launcha (默认) / Bomb Chukka (升级) |
| damage | ~120 (Rokkit) |
| atk_type | 对 vehicle 高穿透 |
| cooldown | ~2s |
| range | ~30 |
| target | B |
| notes | 快速反甲轻载具，骚扰利器 |

| 字段 | 值 |
|---|---|
| name_zh | 杀手罐 |
| name_en | Killa Kan |
| race | Orks |
| tier | 3 |
| built_from | Mek Shop (需 T3) |
| cost_req | 120 |
| cost_power | 200 |
| build_time | ~25s |
| pop_cost | 2 (vehicle) |
| hp | ~2800 |
| armor_type | vehicle_med |
| tags | 载具, 机械, 近战 |
| speed | ~10 |
| vision | ~20 |
| weapon_name | Big Shoota (远程) + Power Klaw (melee) |
| damage | ~30 (BS) / ~200 (melee) |
| atk_type | BS: 对 infantry; melee: 对 vehicle/building 高穿透 |
| cooldown | ~0.3s (BS) / ~1.5s (melee) |
| range | ~25 (BS) / melee |
| target | B |
| notes | Ork 主力载具，反载具/反建筑近战+远程火力 |

| 字段 | 值 |
|---|---|
| name_zh | 掠夺坦克 |
| name_en | Looted Tank |
| race | Orks |
| tier | 3 |
| built_from | Mek Shop (需 T3) |
| cost_req | 150 |
| cost_power | 300 |
| build_time | ~30s |
| pop_cost | 3 (vehicle) |
| hp | ~3500 |
| armor_type | vehicle_med |
| tags | 载具, 坦克, 攻城 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Battle Cannon |
| damage | ~120 |
| atk_type | 对 infantry/building 高穿透, AOE |
| cooldown | ~3s |
| range | ~50 (间接火力) |
| target | G |
| splash | 大范围 AOE |
| notes | Ork 间接火力攻城单位 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 斯奎戈斯 |
| name_en | Squiggoth |
| race | Orks |
| tier | 4 |
| built_from | Da Panze (需 Relic + T3) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~9000 |
| armor_type | monster_high |
| tags | 怪兽, 超级, 近战 |
| speed | ~14 |
| vision | ~25 |
| weapon_name | Tusks + Twin-linked Big Shoota |
| damage | ~300 (melee) / ~20 (TLBS) |
| atk_type | melee: 对全类型高穿透 |
| cooldown | ~1.5s (melee) / ~0.3s (TLBS) |
| range | melee / ~25 (TLBS) |
| target | G |
| active | Trample（践踏冲锋，路径上单位受伤） |
| passive | 高血量怪兽, 可运输步兵 |
| notes | T4 超级怪兽，极高 HP+践踏冲锋，可搭载步兵 |

---

## 2.4 Eldar（神灵族）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 先知 |
| name_en | Farseer |
| race | Eldar |
| tier | 1 |
| built_from | HQ (Webway Assembly) |
| cost_req | 120 |
| cost_power | 75 |
| build_time | ~40s |
| pop_cost | 2 |
| hp | ~700 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 灵能 |
| speed | ~16 |
| vision | ~25 |
| weapon_name | Witchblade |
| damage | ~60-70 (melee) |
| atk_type | melee, 对 commander/vehicle 中穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Mind War（对单一目标高灵能伤害）, Fleet of Foot（全军加速）, Eldritch Storm（T3, AOE 灵能风暴）, Guide（增加友军射程和准确率） |
| passive | — |
| notes | Eldar 核心英雄，FoF 是全族机动关键 |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 骨歌手 |
| name_en | Bonesinger |
| race | Eldar |
| tier | 1 |
| built_from | HQ |
| cost_req | 65 |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~120 |
| morale | 100 |
| armor_type | infantry |
| tags | 工人 |
| speed | ~16 |
| vision | ~15 |
| weapon_name | Shuriken Pistol |
| damage | ~10 |
| active | Teleport（传送，短距离） |
| notes | 可传送的工人，建造速度极快 |

| 字段 | 值 |
|---|---|
| name_zh | 守护者小队 |
| name_en | Guardian Squad |
| race | Eldar |
| tier | 1 |
| built_from | Webway Gate / Aspect Portal |
| cost_req | 120 (初始 5 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~150 / 模型 |
| morale | 120 |
| armor_type | infantry |
| tags | 轻步兵, 远程 |
| speed | ~16 |
| vision | ~20 |
| weapon_name | Shuriken Catapult |
| damage | ~15-20 |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.4s |
| range | ~20 |
| target | G |
| squad_size | 5 初始, 可增援至 8 |
| reinforce_cost | ~15 req |
| heavy_weapons_slots | 1 (Plasma Grenade, Shuriken Cannon) |
| active | Entangle（减速敌方步兵） |
| notes | 基础远程步兵，HP 极低但便宜 |

| 字段 | 值 |
|---|---|
| name_zh | 游侠小队 |
| name_en | Ranger Squad |
| race | Eldar |
| tier | 1 |
| built_from | Aspect Portal |
| cost_req | 100 (初始 3 人) |
| cost_power | 10 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~120 / 模型 |
| morale | 100 |
| armor_type | infantry |
| tags | 轻步兵, 侦察, 狙击 |
| speed | ~16 |
| vision | ~30 |
| weapon_name | Ranger Long Rifle |
| damage | ~80-100 |
| atk_type | 对 infantry, 高士气伤害 |
| cooldown | ~3s |
| range | ~40 |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~35 req + 3 power |
| active | Infiltration（隐身） |
| notes | 狙击手，破士气利器 |

| 字段 | 值 |
|---|---|
| name_zh | 咆哮女妖 |
| name_en | Howling Banshee |
| race | Eldar |
| tier | 2 |
| built_from | Aspect Portal (需 Aspect Stone) |
| cost_req | 180 (初始 4 人) |
| cost_power | 10 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 近战 |
| speed | ~18 (快) |
| vision | ~20 |
| weapon_name | Power Weapon |
| damage | ~40-50 (melee) |
| atk_type | 对 infantry/infantry_heavy 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~40 req + 3 power |
| active | Fleet of Foot (被動加速), War Shout（降低敌方士气） |
| notes | T2 近战 Aspect，速度快输出高但 HP 极低 |

| 字段 | 值 |
|---|---|
| name_zh | 暗黑死神 |
| name_en | Dark Reaper |
| race | Eldar |
| tier | 2 |
| built_from | Aspect Portal (需 Aspect Stone) |
| cost_req | 200 (初始 4 人) |
| cost_power | 20 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 远程 |
| speed | ~16 |
| vision | ~25 |
| weapon_name | Reaper Launcher |
| damage | ~40-50 |
| atk_type | 对 infantry_heavy 高穿透 |
| cooldown | ~0.5s |
| range | ~35 |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~45 req + 5 power |
| notes | 反重步兵远程专家，克制 SM/CSM |

| 字段 | 值 |
|---|---|
| name_zh | 火龙 |
| name_en | Fire Dragon |
| race | Eldar |
| tier | 2 |
| built_from | Aspect Portal (需 Aspect Stone) |
| cost_req | 180 (初始 4 人) |
| cost_power | 30 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 反甲 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Fusion Gun |
| damage | ~100-120 |
| atk_type | 对 vehicle/building 高穿透 |
| cooldown | ~1.5s |
| range | ~15 (短) |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~40 req + 8 power |
| notes | 反甲 Aspect，射程短但伤害高 |

| 字段 | 值 |
|---|---|
| name_zh | 织网蛛 |
| name_en | Warp Spider |
| race | Eldar |
| tier | 2 |
| built_from | Aspect Portal (需 Aspect Stone) |
| cost_req | 200 (初始 4 人) |
| cost_power | 30 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 传送, 远程 |
| speed | ~16 |
| vision | ~20 |
| weapon_name | Death Spinner |
| damage | ~30-40 |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~0.4s |
| range | ~20 |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~45 req + 8 power |
| active | Teleport（短距离传送, 有冷却） |
| passive | — |
| notes | 传送突袭单位，可绕后打远程/经济 |

| 字段 | 值 |
|---|---|
| name_zh | 飞鹰 |
| name_en | Swooping Hawk |
| race | Eldar |
| tier | 2 |
| built_from | Aspect Portal (需 Aspect Stone) |
| cost_req | 180 (初始 4 人) |
| cost_power | 20 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~180 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 飞行 |
| speed | ~16 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Lasblaster |
| damage | ~20-25 |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.3s |
| range | ~25 |
| target | B |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~40 req + 5 power |
| active | Deep Strike / Flight |
| notes | 飞行步兵，可空降+飞行骚扰 |

| 字段 | 值 |
|---|---|
| name_zh | 议会 |
| name_en | Seer Council |
| race | Eldar |
| tier | 3 |
| built_from | HQ (需 T3) |
| cost_req | 250 (初始 3 人) |
| cost_power | 80 |
| build_time | ~20s |
| pop_cost | 3 |
| hp | ~500 / 模型 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 灵能, 近战 |
| speed | ~14 |
| vision | ~25 |
| weapon_name | Witchblade |
| damage | ~60-70 (melee) |
| atk_type | 对全类型高穿透 |
| cooldown | ~1.2s |
| range | melee |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~80 req + 25 power |
| active | Embolden（士气恢复）, Guide |
| passive | 灵能光环 |
| notes | T3 终极步兵，指挥官甲+灵能+高近战 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 猎鹰 |
| name_en | Falcon |
| race | Eldar |
| tier | 2 |
| built_from | Webway Assembly (需 Support Portal) |
| cost_req | 100 |
| cost_power | 150 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1500 |
| armor_type | vehicle_low |
| tags | 载具, 运输, 飞行 |
| speed | ~22 (快) |
| fly | 是 |
| vision | ~25 |
| weapon_name | Shuriken Cannon / Scatter Laser / Starcannon (升级) |
| damage | ~25 (SC) / ~40 (SL) / ~60 (Starcannon) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~0.3s |
| range | ~25 |
| target | B |
| transport_slots | 乘载 1 个小队 |
| notes | 快速飞行运输载具 |

| 字段 | 值 |
|---|---|
| name_zh | 幽灵领主 |
| name_en | Wraithlord |
| race | Eldar |
| tier | 2 |
| built_from | Webway Assembly (需 Support Portal) |
| cost_req | 120 |
| cost_power | 250 |
| build_time | ~25s |
| pop_cost | 2 (vehicle) |
| hp | ~2800 |
| armor_type | vehicle_med |
| tags | 载具, 机械, 近战 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Bright Lance (默认) / Shuriken Cannon + Ghost Sword (melee) |
| damage | ~150 (BL) / ~200 (melee) |
| atk_type | BL: 对 vehicle 高穿透; melee: 对 vehicle/infantry |
| cooldown | ~2s (BL) / ~1.5s (melee) |
| range | ~40 (BL) / melee |
| target | B |
| notes | Eldar 多用Walker，反甲远程+近战 |

| 字段 | 值 |
|---|---|
| name_zh | 火棱镜 |
| name_en | Fire Prism |
| race | Eldar |
| tier | 3 |
| built_from | Webway Assembly (需 T3) |
| cost_req | 150 |
| cost_power | 350 |
| build_time | ~30s |
| pop_cost | 3 (vehicle) |
| hp | ~2500 |
| armor_type | vehicle_med |
| tags | 载具, 坦克, 飞行, 攻城 |
| speed | ~18 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Prism Cannon |
| damage | ~150-200 |
| atk_type | 对全类型高穿透, AOE |
| cooldown | ~3s |
| range | ~50 |
| target | B |
| splash | 中等范围 AOE |
| notes | T3 飞行主战坦克，高机动+AOE+反全类型 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 战神化身 |
| name_en | Avatar of Khaine |
| race | Eldar |
| tier | 4 |
| built_from | HQ (需 Relic + T3) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~8000 |
| armor_type | monster_high |
| tags | 怪兽, 超级, 近战, 飞行 |
| speed | ~16 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Wailing Doom |
| damage | ~300-400 (melee) |
| atk_type | 对全类型极高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | — |
| passive | Flight, Khaine's Presence（光环：友军士气无限/恢复加速） |
| notes | T4 超级单位，飞行+极高近战+士气光环 |

---

## 2.5 Imperial Guard（帝国卫队）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 将军 |
| name_en | General |
| race | Imperial Guard |
| tier | 1 |
| built_from | HQ (Field Command) |
| cost_req | 120 |
| cost_power | 50 |
| build_time | ~30s |
| pop_cost | 2 |
| hp | ~800 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Power Sword + Bolt Pistol |
| damage | ~60-70 (melee) |
| atk_type | melee |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Strafing Run（呼叫空袭）, Earthshaker Round（T3, 远程炮击） |
| passive | Command Aura（友军士气恢复） |
| notes | General + Command Squad 附加单位组成指挥班 |

| 字段 | 值 |
|---|---|
| name_zh | 委员 |
| name_en | Commissar |
| race | Imperial Guard |
| tier | 2 |
| built_from | HQ (需 T2) |
| cost_req | 80 |
| cost_power | 20 |
| build_time | ~10s |
| pop_cost | 1 |
| hp | ~400 |
| morale | 300 |
| armor_type | infantry_heavy_med |
| tags | 英雄, 附件 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Bolt Pistol + Power Sword |
| damage | ~40 (melee) |
| active | Execute（枪毙一名友军，全队士气恢复+射速暴增） |
| passive | — |
| notes | 可附加到 Guardsmen 小队或 Command Squad，Execute 是 IG 核心机制 |

| 字段 | 值 |
|---|---|
| name_zh | 牧师 |
| name_en | Priest |
| race | Imperial Guard |
| tier | 2 |
| built_from | HQ (需 T2) |
| cost_req | 80 |
| cost_power | 25 |
| build_time | ~10s |
| pop_cost | 1 |
| hp | ~500 |
| morale | 300 |
| armor_type | infantry_heavy_med |
| tags | 英雄, 附件 |
| active | Fanaticism（友军短暂无敌） |
| passive | — |
| notes | 附加到小队后提供近战 buff + Fanaticism 无敌技能 |

| 字段 | 值 |
|---|---|
| name_zh | 灵能者 |
| name_en | Psyker |
| race | Imperial Guard |
| tier | 2 |
| built_from | HQ (需 T2) |
| cost_req | 80 |
| cost_power | 30 |
| build_time | ~10s |
| pop_cost | 1 |
| hp | ~300 |
| morale | 200 |
| armor_type | infantry |
| tags | 英雄, 灵能, 附件 |
| active | Lightning Arc（灵能链电）, Curse of the Machine（瘫痪载具） |
| notes | 附加到 Command Squad，灵能支援 |

| 字段 | 值 |
|---|---|
| name_zh | 狙击手 |
| name_en | Vindicare Assassin |
| race | Imperial Guard |
| tier | 3 |
| built_from | HQ (需 T3 + Relic 建筑前置) |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~20s |
| pop_cost | 2 |
| hp | ~300 |
| morale | — (免疫) |
| armor_type | infantry |
| tags | 英雄, 狙击, 隐身 |
| speed | ~16 |
| vision | ~30 |
| weapon_name | Exitus Rifle |
| damage | ~300-400 |
| atk_type | 对 infantry/commander 极高穿透 |
| cooldown | ~3s |
| range | ~50 |
| target | B |
| active | Infiltration（隐身） |
| notes | 终极狙击手，一枪一个步兵 |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 技术神甫 |
| name_en | Techpriest Enginseer |
| race | Imperial Guard |
| tier | 1 |
| built_from | HQ |
| cost_req | 65 |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~150 |
| morale | 100 |
| armor_type | infantry_heavy_med |
| tags | 工人 |
| speed | ~10 |
| vision | ~15 |
| notes | 工人，建造/修理，有基础战斗能力 |

| 字段 | 值 |
|---|---|
| name_zh | 卫兵小队 |
| name_en | Guardsmen Squad |
| race | Imperial Guard |
| tier | 1 |
| built_from | Infantry Command |
| cost_req | 90 (初始 5 人) |
| cost_power | 0 |
| build_time | ~6s |
| pop_cost | 2 |
| hp | ~100-160 / 模型 |
| morale | 80 |
| armor_type | infantry |
| tags | 轻步兵, 核心 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Lasgun (默认) |
| damage | ~8-12 |
| atk_type | 对 infantry 低穿透 |
| cooldown | ~0.3s |
| range | ~20 |
| target | G |
| squad_size | 5 初始, 可增援至 12+ |
| reinforce_cost | ~10 req |
| heavy_weapons_slots | 2 (Grenade Launcher, Plasma Gun) |
| active | — |
| passive | — |
| upgrades | Grenade Launcher, Plasma Gun |
| notes | 最便宜最弱的步兵，靠数量+Commissar Execute 维持战力 |

| 字段 | 值 |
|---|---|
| name_zh | 卡斯基亚 |
| name_en | Kasrkin |
| race | Imperial Guard |
| tier | 3 |
| built_from | Infantry Command (需 T3) |
| cost_req | 200 (初始 4 人) |
| cost_power | 30 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~350 / 模型 |
| morale | 200 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 精英 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Hellgun (默认) |
| damage | ~25-30 |
| atk_type | 对 infantry_heavy 中穿透 |
| cooldown | ~0.4s |
| range | ~25 |
| target | B |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~50 req + 8 power |
| heavy_weapons_slots | 2 (Melta Gun, Plasma Gun) |
| notes | T3 精英远程步兵，IG 版 "Tactical Marine" |

| 字段 | 值 |
|---|---|
| name_zh | 欧格林 |
| name_en | Ogryn |
| race | Imperial Guard |
| tier | 3 |
| built_from | Infantry Command (需 T3) |
| cost_req | 180 (初始 3 人) |
| cost_power | 40 |
| build_time | ~12s |
| pop_cost | 3 |
| hp | ~600 / 模型 |
| morale | 300 |
| armor_type | monster_med |
| tags | 怪兽, 近战 |
| speed | ~12 |
| vision | ~15 |
| weapon_name | Ripper Gun + melee |
| damage | ~60-70 (melee) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee / ~10 (Ripper Gun) |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~60 req + 15 power |
| notes | T3 近战肉盾，高 HP 高近战 |

| 字段 | 值 |
|---|---|
| name_zh | 重武器组 |
| name_en | Heavy Weapons Team |
| race | Imperial Guard |
| tier | 2 |
| built_from | Infantry Command (需 T2) |
| cost_req | 120 |
| cost_power | 30 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 100 |
| armor_type | infantry |
| tags | 步兵, 架设 |
| speed | ~8 (慢, 搬运状态) |
| vision | ~20 |
| weapon_name | Heavy Bolter (默认) / Lascannon / Mortar / Missile Launcher (升级) |
| damage | ~40 (HB) / ~150 (LC) / ~80 (Mortar, AOE) |
| atk_type | HB: 反 infantry; LC: 反 vehicle; Mortar: 攻城 AOE |
| cooldown | ~0.3s (HB) / ~2s (LC) / ~4s (Mortar) |
| range | ~30 (HB) / ~45 (LC) / ~60 (Mortar, 间接) |
| target | B |
| active | Setup/Pack（架设/收起） |
| notes | 需要**架设**才能开火，类似 CoH 的 MG。多种武器配置 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 哨兵机甲 |
| name_en | Sentinel |
| race | Imperial Guard |
| tier | 1 |
| built_from | Mechanized Command |
| cost_req | 80 |
| cost_power | 20 |
| build_time | ~10s |
| pop_cost | 1 (vehicle) |
| hp | ~800 |
| armor_type | vehicle_low |
| tags | 载具, 侦察, 快速 |
| speed | ~24 (快) |
| vision | ~30 |
| weapon_name | Multi-Laser (默认) / Lascannon (升级) |
| damage | ~30 (ML) / ~120 (LC) |
| atk_type | ML: 反 infantry; LC: 反 vehicle |
| cooldown | ~0.3s (ML) / ~2s (LC) |
| range | ~25 (ML) / ~35 (LC) |
| target | B |
| notes | 快速侦察载具，T1 即可生产 |

| 字段 | 值 |
|---|---|
| name_zh | 奇美拉 |
| name_en | Chimera |
| race | Imperial Guard |
| tier | 2 |
| built_from | Mechanized Command |
| cost_req | 80 |
| cost_power | 60 |
| build_time | ~12s |
| pop_cost | 2 (vehicle) |
| hp | ~2000 |
| armor_type | vehicle_med |
| tags | 载具, 运输 |
| speed | ~18 |
| vision | ~20 |
| weapon_name | Multi-Laser + Heavy Bolter |
| damage | ~30 (ML) / ~20 (HB) |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.3s |
| range | ~25 |
| target | B |
| transport_slots | 乘载 2 个小队 |
| notes | 运输载具，可进驻步兵射击 |

| 字段 | 值 |
|---|---|
| name_zh | 地狱犬 |
| name_en | Hellhound |
| race | Imperial Guard |
| tier | 2 |
| built_from | Mechanized Command |
| cost_req | 120 |
| cost_power | 150 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~2200 |
| armor_type | vehicle_med |
| tags | 载具, 火焰 |
| speed | ~18 |
| vision | ~20 |
| weapon_name | Inferno Cannon |
| damage | ~60-80 |
| atk_type | 对 infantry 极高穿透, AOE, 高士气伤害 |
| cooldown | ~1s |
| range | ~20 |
| target | G |
| splash | 锥形 AOE |
| notes | 火焰坦克，反步兵+破士气利器 |

| 字段 | 值 |
|---|---|
| name_zh | 黎曼·鲁斯 |
| name_en | Leman Russ |
| race | Imperial Guard |
| tier | 3 |
| built_from | Mechanized Command (需 T3) |
| cost_req | 150 |
| cost_power | 350 |
| build_time | ~30s |
| pop_cost | 3 (vehicle) |
| hp | ~4500 |
| armor_type | vehicle_high |
| tags | 载具, 坦克 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Battle Cannon ( turret) + Heavy Bolter sponsons |
| damage | ~150 (BC, AOE) / ~30 (HB) |
| atk_type | BC: 对 infantry/building 高穿透; HB: 反 infantry |
| cooldown | ~3s (BC) / ~0.3s (HB) |
| range | ~50 (BC) / ~25 (HB) |
| target | B |
| notes | IG 主战坦克，T3 核心战力 |

| 字段 | 值 |
|---|---|
| name_zh | 蜥炮 |
| name_en | Basilisk |
| race | Imperial Guard |
| tier | 3 |
| built_from | Mechanized Command (需 T3) |
| cost_req | 120 |
| cost_power | 300 |
| build_time | ~25s |
| pop_cost | 3 (vehicle) |
| hp | ~2500 |
| armor_type | vehicle_med |
| tags | 载具, 攻城, 间接火力 |
| speed | ~10 |
| vision | ~15 |
| weapon_name | Earthshaker Cannon |
| damage | ~200-250 |
| atk_type | 对 infantry/building 极高穿透, 大 AOE |
| cooldown | ~5s |
| range | ~80 (超远间接火力) |
| target | G |
| splash | 大范围 AOE |
| notes | 超远程间接火力攻城炮，需要前哨视野 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 荒野之刃 |
| name_en | Baneblade |
| race | Imperial Guard |
| tier | 4 |
| built_from | Mechanized Command (需 Relic + T3) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~10000 |
| armor_type | vehicle_high |
| tags | 载具, 超级, 坦克 |
| speed | ~10 |
| vision | ~25 |
| weapon_name | Mega Battle Cannon + Twin-linked Heavy Bolter × 3 + Demolisher Cannon + Lascannon |
| damage | ~250 (MBC, AOE) / ~150 (LC) / ~80 (Demolisher, AOE) |
| atk_type | 全类型高穿透 |
| cooldown | ~3s (MBC) / ~2s (LC) / ~4s (Demolisher) |
| range | ~60 (MBC) / ~40 (LC) / ~25 (Demolisher) |
| target | B |
| notes | T4 超级坦克，游戏最强载具之一，11 个武器系统全方位火力 |

---

## 2.6 Tau Empire（钛帝国）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 钛指挥官 |
| name_en | Tau Commander |
| race | Tau |
| tier | 1 |
| built_from | HQ (Cadre Headquarters) |
| cost_req | 120 |
| cost_power | 50 |
| build_time | ~30s |
| pop_cost | 2 |
| hp | ~800 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 远程 |
| speed | ~14 |
| jump | 是 (喷气背包, 需升级) |
| vision | ~25 |
| weapon_name | Plasma Rifle (默认) / Missile Pod / Fusion Blaster / Flamer (可配置) |
| damage | ~60 (PR) / ~120 (MP) / ~100 (FB) |
| atk_type | PR: 反 infantry_heavy; MP: 反 vehicle; FB: 反 vehicle 近距离 |
| cooldown | ~1s |
| range | ~30 |
| target | B |
| active | Jump (需升级喷气背包) |
| passive | — |
| upgrades | Missile Pod, Fusion Blaster, Flamer, Jump Pack |
| notes | 可配置多种武器的远程英雄，高度可定制 |

| 字段 | 值 |
|---|---|
| name_zh | 以太 |
| name_en | Ethereal |
| race | Tau |
| tier | 3 |
| built_from | HQ (需 T3) |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~20s |
| pop_cost | 2 |
| hp | ~500 |
| morale | 300 |
| armor_type | commander |
| tags | 英雄, 光环 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Honor Blade |
| damage | ~40 (melee) |
| active | — |
| passive | Ethereal Aura（全族 Fire Warrior 伤害+士气提升） |
| notes | 提供全军 buff，但**阵亡后全军士气崩溃** |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 铸造工人 |
| name_en | Earth Caste Builder |
| race | Tau |
| tier | 1 |
| built_from | HQ |
| cost_req | 65 |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~100 |
| armor_type | infantry |
| tags | 工人 |
| notes | 建造/修理单位 |

| 字段 | 值 |
|---|---|
| name_zh | 火战士小队 |
| name_en | Fire Warrior Team |
| race | Tau |
| tier | 1 |
| built_from | Cadre Barracks |
| cost_req | 150 (初始 4 人) |
| cost_power | 0 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~300 / 模型 |
| morale | 200 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 远程, 核心 |
| speed | ~12 |
| vision | ~25 |
| weapon_name | Pulse Rifle |
| damage | ~40-50 |
| atk_type | 对 infantry/infantry_heavy 高穿透 |
| cooldown | ~0.5s |
| range | ~35 (极远) |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~35 req |
| heavy_weapons_slots | — (无重武器槽) |
| notes | 游戏最强基础远程步兵，射程极远+DPS 高 |

| 字段 | 值 |
|---|---|
| name_zh | 克鲁特食肉者 |
| name_en | Kroot Carnivores |
| race | Tau |
| tier | 1 |
| built_from | Kroot Nexus |
| cost_req | 120 (初始 4 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~300 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 近战 |
| speed | ~16 (快) |
| vision | ~20 |
| weapon_name | Kroot Rifle + melee |
| damage | ~25-30 (melee) / ~15 (ranged) |
| atk_type | melee: 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee / ~20 (ranged) |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~25 req |
| active | — |
| passive | Cannibalize（可吃尸体恢复 HP） |
| notes | Tau 唯一 T1 近战屏障，保护 Fire Warrior 火力线 |

| 字段 | 值 |
|---|---|
| name_zh | 寻路者 |
| name_en | Pathfinders |
| race | Tau |
| tier | 2 |
| built_from | Cadre Barracks (需 T2) |
| cost_req | 100 (初始 3 人) |
| cost_power | 10 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~250 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 侦察 |
| speed | ~14 |
| vision | ~30 |
| weapon_name | Pulse Carbine |
| damage | ~25 |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.5s |
| range | ~30 |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~30 req + 3 power |
| active | Marker Light（标记目标，友军对其伤害增加） |
| notes | 侦察+标记单位，Marker Light 是 Tau 火力协同核心 |

| 字段 | 值 |
|---|---|
| name_zh | 隐身服 |
| name_en | Stealthsuits |
| race | Tau |
| tier | 2 |
| built_from | Cadre Barracks (需 T2) |
| cost_req | 150 (初始 3 人) |
| cost_power | 30 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 隐身, 骚扰 |
| speed | ~14 |
| vision | ~25 |
| weapon_name | Burst Cannon (默认) / Fusion Blaster (升级) |
| damage | ~25 (BC) / ~100 (FB) |
| atk_type | BC: 对 infantry; FB: 对 vehicle |
| cooldown | ~0.3s (BC) / ~1.5s (FB) |
| range | ~20 (BC) / ~15 (FB) |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~45 req + 10 power |
| active | Infiltration（隐身） |
| notes | 隐身骚扰单位，可升级反甲 |

| 字段 | 值 |
|---|---|
| name_zh | 危机战斗服（Mont'ka 路线） |
| name_en | Crisis Suit |
| race | Tau |
| tier | 3 (Mont'ka) |
| built_from | Mont'ka Command Post |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~15s |
| pop_cost | 3 (vehicle) |
| hp | ~800 |
| armor_type | vehicle_low |
| tags | 载具, 跳跃, 可配置 |
| speed | ~14 |
| jump | 是 |
| vision | ~25 |
| weapon_name | 可配置: Plasma Rifle / Missile Pod / Fusion Blaster / Flamer / Burst Cannon |
| damage | 视武器而定 (~60-120) |
| atk_type | 视武器而定 |
| cooldown | ~1s |
| range | ~25-35 |
| target | B |
| active | Jump |
| notes | Mont'ka 路线核心单位，可跳跃+多武器配置 |

| 字段 | 值 |
|---|---|
| name_zh | 宽边战斗服（Kauyon 路线） |
| name_en | Broadside |
| race | Tau |
| tier | 3 (Kauyon) |
| built_from | Kauyon Command Post |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~15s |
| pop_cost | 3 (vehicle) |
| hp | ~1000 |
| armor_type | vehicle_med |
| tags | 载具, 架设, 反甲 |
| speed | ~8 (慢) |
| vision | ~25 |
| weapon_name | Twin-linked Railgun + Smart Missile System |
| damage | ~200 (TLRG) / ~40 (SMS) |
| atk_type | TLRG: 对 vehicle 极高穿透; SMS: 反 infantry |
| cooldown | ~2s (TLRG) / ~0.5s (SMS) |
| range | ~45 (TLRG) / ~30 (SMS) |
| target | B |
| active | Setup/Pack（架设/收起） |
| notes | Kauyon 路线核心，需架设的重火力反甲平台 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 魔鬼鱼 |
| name_en | Devilfish |
| race | Tau |
| tier | 2 |
| built_from | Vehicle Beacon |
| cost_req | 100 |
| cost_power | 100 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1500 |
| armor_type | vehicle_low |
| tags | 载具, 运输, 隐身, 飞行 |
| speed | ~22 (快) |
| fly | 是 |
| vision | ~25 |
| weapon_name | Burst Cannon |
| damage | ~25 |
| atk_type | 对 infantry 中穿透 |
| cooldown | ~0.3s |
| range | ~25 |
| target | B |
| transport_slots | 乘载 1 个小队 |
| active | Infiltration（隐身） |
| notes | 隐身飞行运输载具，可隐蔽运输 |

| 字段 | 值 |
|---|---|
| name_zh | 天鳐 |
| name_en | Sky Ray |
| race | Tau |
| tier | 2 |
| built_from | Vehicle Beacon |
| cost_req | 120 |
| cost_power | 150 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1800 |
| armor_type | vehicle_med |
| tags | 载具, 导弹, 飞行 |
| speed | ~20 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Seeker Missiles |
| damage | ~120 |
| atk_type | 对 vehicle/building 高穿透, AOE |
| cooldown | ~2s |
| range | ~40 |
| target | B |
| active | Seeker Missile Strike（需要 Marker Light 标记） |
| notes | 导弹载具，可配合 Pathfinder 的 Marker Light |

| 字段 | 值 |
|---|---|
| name_zh | 铎头鲨 |
| name_en | Hammerhead |
| race | Tau |
| tier | 3 (Mont'ka) |
| built_from | Mont'ka Command Post |
| cost_req | 150 |
| cost_power | 300 |
| build_time | ~25s |
| pop_cost | 3 (vehicle) |
| hp | ~3000 |
| armor_type | vehicle_med |
| tags | 载具, 坦克, 飞行 |
| speed | ~18 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Railgun ( turret) + Burst Cannons |
| damage | ~200 (RG) / ~25 (BC) |
| atk_type | RG: 对 vehicle 极高穿透; BC: 反 infantry |
| cooldown | ~2s (RG) / ~0.3s (BC) |
| range | ~50 (RG) / ~25 (BC) |
| target | B |
| notes | Mont'ka 路线主战坦克，Railgun 是游戏最强反甲武器之一 |

| 字段 | 值 |
|---|---|
| name_zh | 克鲁特牛 |
| name_en | Krootox |
| race | Tau |
| tier | 3 (Kauyon) |
| built_from | Kauyon Command Post |
| cost_req | 120 |
| cost_power | 250 |
| build_time | ~25s |
| pop_cost | 3 (vehicle) |
| hp | ~3500 |
| armor_type | monster_med |
| tags | 怪兽, 近战 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Kroot Gun + melee |
| damage | ~60 (ranged) / ~200 (melee) |
| atk_type | melee: 对 vehicle/infantry 高穿透 |
| cooldown | ~1.5s |
| range | ~25 / melee |
| target | B |
| notes | Kauyon 路线重型近战怪兽，高 HP+近战反甲 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 巨型克鲁特兽（Kauyon 路线） |
| name_en | Greater Knarloc |
| race | Tau |
| tier | 4 (Kauyon) |
| built_from | Kauyon Command Post (需 Relic) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~8000 |
| armor_type | monster_high |
| tags | 怪兽, 超级, 近战 |
| speed | ~14 |
| vision | ~25 |
| weapon_name | Claws + Beak |
| damage | ~300 (melee) |
| atk_type | 对全类型高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| notes | Kauyon 路线 T4 超级怪兽，高近战伤害 |

---

## 2.7 Necrons（太空死灵）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 死灵之主 |
| name_en | Necron Lord |
| race | Necrons |
| tier | 1 |
| built_from | Monolith (HQ) |
| cost_req | 0 |
| cost_power | 100 |
| build_time | ~30s |
| pop_cost | 2 |
| hp | ~1200 |
| morale | — (免疫) |
| armor_type | commander |
| tags | 英雄, 机械 |
| speed | ~12 |
| vision | ~25 |
| weapon_name | Staff of Light |
| damage | ~70-80 (melee) / ~50 (ranged) |
| atk_type | 对全类型中高穿透 |
| cooldown | ~1.5s (melee) / ~1s (ranged) |
| range | melee / ~20 |
| target | G |
| active | Resurrection Orb（复活阵亡友军）, Nightmare Shroud（恐惧光环，降低敌方士气）, Lightning Field（AOE 伤害）, Chronometron（时间减速）, Solar Pulse（致盲）, Phase Shifter（短暂无敌）, Veil of Darkness（传送） |
| passive | 自我修复 |
| upgrades | 多种可解锁技能（Resurrection Orb, Nightmare Shroud, Lightning Field, Chronometron, Solar Pulse, Phase Shifter, Veil of Darkness） |
| notes | 最强英雄之一，可配置多种技能。T3 可变身为 Nightbringer |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 建造圣甲虫 |
| name_en | Builder Scarab |
| race | Necrons |
| tier | 1 |
| built_from | Monolith |
| cost_req | 0 |
| cost_power | 15 |
| build_time | ~5s |
| pop_cost | 1 |
| hp | ~100 |
| armor_type | infantry |
| tags | 工人 |
| speed | ~12 |
| notes | 工人，建造建筑 |

| 字段 | 值 |
|---|---|
| name_zh | 死灵战士 |
| name_en | Necron Warrior |
| race | Necrons |
| tier | 1 |
| built_from | Monolith |
| cost_req | **0** |
| cost_power | 0 |
| build_time | ~15s (随 Obelisk 数量加速) |
| pop_cost | 2 |
| hp | ~400 / 模型 |
| morale | — (免疫) |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 核心, 机械 |
| speed | ~10 (慢) |
| vision | ~20 |
| weapon_name | Gauss Flayer |
| damage | ~30-40 |
| atk_type | 对 infantry/infantry_heavy/vehicle 中穿透 |
| cooldown | ~0.5s |
| range | ~25 |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | **0 req, 0 power** (仅建造时间) |
| active | — |
| passive | 自我修复, 免疫士气 |
| notes | **免费**生产+增援，Necron 核心机制。慢但无敌消耗战 |

| 字段 | 值 |
|---|---|
| name_zh | 剥皮者 |
| name_en | Flayed One |
| race | Necrons |
| tier | 1 (需 Summoning Core) |
| built_from | Monolith |
| cost_req | 0 |
| cost_power | 30 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~450 / 模型 |
| morale | — (免疫) |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 近战, 突袭 |
| speed | ~10 |
| vision | ~20 |
| weapon_name | Flensing Blades |
| damage | ~50-60 (melee) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | 0 req, ~10 power |
| active | Deep Strike（可空投到可见区域） |
| passive | 自我修复, 免疫士气, 恐惧效果（降低敌方士气） |
| notes | 可 Deep Strike 的近战步兵，恐惧效果破敌方士气 |

| 字段 | 值 |
|---|---|
| name_zh | 不朽者 |
| name_en | Immortal |
| race | Necrons |
| tier | 2 |
| built_from | Monolith (需 T2) |
| cost_req | 0 |
| cost_power | 40 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~500 / 模型 |
| morale | — (免疫) |
| armor_type | infantry_heavy_high |
| tags | 重步兵, 远程, 反甲 |
| speed | ~10 |
| vision | ~20 |
| weapon_name | Gauss Blaster |
| damage | ~80-100 |
| atk_type | 对 vehicle/building 高穿透 |
| cooldown | ~1s |
| range | ~30 |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | 0 req, ~15 power |
| passive | 自我修复, 免疫士气 |
| notes | 反甲远程步兵，Gauss 武器对载具穿透极高 |

| 字段 | 值 |
|---|---|
| name_zh | 幽灵 |
| name_en | Wraith |
| race | Necrons |
| tier | 2 |
| built_from | Monolith (需 T2) |
| cost_req | 0 |
| cost_power | 50 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~550 |
| morale | — (免疫) |
| armor_type | infantry_heavy_high |
| tags | 重步兵, 近战, 机动 |
| speed | ~16 (Necron 中最快) |
| vision | ~25 |
| weapon_name | Claws |
| damage | ~80-100 (melee) |
| atk_type | 对 infantry/vehicle 中高穿透 |
| cooldown | ~1.2s |
| range | melee |
| target | G |
| squad_size | 1 |
| active | Phase（短暂无敌穿越） |
| passive | 自我修复, 免疫士气 |
| notes | Necron 中少数有速度的单位，可穿越地形 |

| 字段 | 值 |
|---|---|
| name_zh | 死亡突击者 |
| name_en | Pariah |
| race | Necrons |
| tier | 3 |
| built_from | Monolith (需 T3 + Energy Core) |
| cost_req | 0 |
| cost_power | 80 |
| build_time | ~15s |
| pop_cost | 3 |
| hp | ~700 / 模型 |
| morale | — (免疫) |
| armor_type | infantry_heavy_high |
| tags | 重步兵, 近战, 精英 |
| speed | ~10 |
| vision | ~20 |
| weapon_name | Warscythe |
| damage | ~100-120 (melee) |
| atk_type | 对全类型高穿透 |
| cooldown | ~1.2s |
| range | melee |
| target | G |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | 0 req, ~30 power |
| passive | 自我修复, 免疫士气, Aura of Death（周围敌方持续伤害） |
| notes | T3 终极近战步兵，极高伤害+光环 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 毁灭者 |
| name_en | Destroyer |
| race | Necrons |
| tier | 2 |
| built_from | Monolith (需 T2) |
| cost_req | 0 |
| cost_power | 100 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1200 |
| armor_type | vehicle_med |
| tags | 载具, 机械, 快速 |
| speed | ~18 (快, Necron 中少见) |
| vision | ~25 |
| weapon_name | Gauss Cannon |
| damage | ~60-80 |
| atk_type | 对 infantry/infantry_heavy 高穿透 |
| cooldown | ~0.5s |
| range | ~35 |
| target | B |
| passive | 自我修复 |
| notes | 快速远程载具，Necron 中少数有机动性的单位 |

| 字段 | 值 |
|---|---|
| name_zh | 重型毁灭者 |
| name_en | Heavy Destroyer |
| race | Necrons |
| tier | 3 |
| built_from | Monolith (需 T3) |
| cost_req | 0 |
| cost_power | 150 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~1200 |
| armor_type | vehicle_med |
| tags | 载具, 反甲, 快速 |
| speed | ~18 |
| vision | ~25 |
| weapon_name | Heavy Gauss Cannon |
| damage | ~150-200 |
| atk_type | 对 vehicle 极高穿透 |
| cooldown | ~2s |
| range | ~40 |
| target | B |
| passive | 自我修复 |
| notes | 重型反甲载具，Gauss 武器对载具极高穿透 |

| 字段 | 值 |
|---|---|
| name_zh | 墓穴蛛 |
| name_en | Tomb Spyder |
| race | Necrons |
| tier | 2 |
| built_from | Monolith (需 T2) |
| cost_req | 0 |
| cost_power | 80 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~2000 |
| armor_type | vehicle_med |
| tags | 载具, 机械, 辅助 |
| speed | ~10 |
| vision | ~20 |
| weapon_name | Claws + Particle Projector |
| damage | ~80 (melee) / ~50 (PP) |
| atk_type | melee: 对 vehicle; PP: 对 infantry |
| cooldown | ~1.5s |
| range | melee / ~20 |
| target | B |
| active | Create Necron Warrior/Flayed One（从尸体构建新单位） |
| passive | 自我修复 |
| notes | 辅助载具，可从尸体回收+生产新步兵 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 复活方尖碑 |
| name_en | Restored Monolith |
| race | Necrons |
| tier | 4 |
| built_from | Monolith (需 Relic + T3 + Awaken Monolith 升级) |
| cost_req | 0 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~10000 |
| armor_type | building_high |
| tags | 超级, 堡垒, 生产建筑 |
| speed | ~8 (可移动) |
| vision | ~25 |
| weapon_name | Particle Whip × 4 + Gauss Flux Arc × 4 |
| damage | ~200 (PW, AOE) / ~50 (GFA) |
| atk_type | 全类型极高穿透 |
| cooldown | ~3s (PW) / ~0.3s (GFA) |
| range | ~60 (PW) / ~25 (GFA) |
| target | B |
| active | Teleport（传送）, 继续生产步兵（移动 HQ） |
| passive | 自我修复, 建筑甲（极高抗性） |
| notes | 游戏最强超级单位之一，移动堡垒+生产建筑+传送+全方位火力 |

| 字段 | 值 |
|---|---|
| name_zh | 夜灵（C'tan 变身） |
| name_en | Nightbringer |
| race | Necrons |
| tier | 3 (需 T3 + Nightbringer upgrade) |
| built_from | Necron Lord 变身 |
| cost_req | 0 |
| cost_power | 200 (升级费用) |
| build_time | — (变身) |
| pop_cost | — (Lord 的 pop) |
| hp | ~5000 (变身持续 ~60s) |
| armor_type | monster_high |
| tags | 怪兽, 超级, 飞行, 限时 |
| speed | ~16 |
| fly | 是 |
| weapon_name | Warscythe |
| damage | ~300-400 (melee) |
| atk_type | 对全类型极高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | — |
| passive | 飞行, **无敌**（变身期间大部分攻击无效）, 生命窃取 |
| notes | Necron Lord 变身为 C'tan 神明，限时无敌+极高近战+飞行 |

---

## 2.8 Sisters of Battle（战斗修女）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 修女长 |
| name_en | Cannoness |
| race | Sisters of Battle |
| tier | 1 |
| built_from | HQ (Convent) |
| cost_req | 120 |
| cost_power | 50 |
| build_time | ~30s |
| pop_cost | 2 |
| hp | ~800 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 信仰 |
| speed | ~14 |
| jump | 是 (需升级喷气背包) |
| vision | ~25 |
| weapon_name | Bolt Pistol + Power Weapon (默认) / Inferno Pistol / Eviscerator |
| damage | ~60 (melee) |
| atk_type | melee |
| cooldown | ~1.5s |
| range | melee / ~15 (BP) |
| target | G |
| active | Acts of Faith（消耗 Faith 施放神迹）, Jump (需升级) |
| passive | 产生 Faith |
| upgrades | Inferno Pistol, Eviscerator, Jump Pack |

| 字段 | 值 |
|---|---|
| name_zh | 传教士 |
| name_en | Missionary |
| race | Sisters of Battle |
| tier | 1 |
| built_from | HQ |
| cost_req | 60 |
| cost_power | 10 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~300 |
| morale | 200 |
| armor_type | infantry_heavy_med |
| tags | 英雄, 侦察, 信仰 |
| speed | ~14 |
| vision | ~25 |
| weapon_name | Bolt Pistol |
| damage | ~15 |
| active | Infiltration（隐身）, 产生 Faith |
| passive | — |
| notes | 可隐身侦察+积累 Faith |

| 字段 | 值 |
|---|---|
| name_zh | 忏悔牧师 |
| name_en | Confessor |
| race | Sisters of Battle |
| tier | 3 |
| built_from | HQ (需 T3) |
| cost_req | 100 |
| cost_power | 50 |
| build_time | ~15s |
| pop_cost | 2 |
| hp | ~500 |
| morale | 300 |
| armor_type | commander |
| tags | 英雄 |
| active | Emperor's Benediction（友军 buff）, 产生 Faith |
| notes | T3 辅助英雄，提供 buff 和 Faith |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 战斗修女小队 |
| name_en | Battle Sister Squad |
| race | Sisters of Battle |
| tier | 1 |
| built_from | Infantry Convent |
| cost_req | 180 (初始 4 人) |
| cost_power | 0 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~350 / 模型 |
| morale | 250 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 核心 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Bolter (默认) |
| damage | ~25-30 |
| atk_type | 对 infantry/infantry_heavy 中高穿透 |
| cooldown | ~0.5s |
| range | ~25 |
| target | B |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~45 req |
| heavy_weapons_slots | 2 (Flamer, Melta Gun, Heavy Bolter, Plasma Gun) |
| active | — |
| passive | — |
| upgrades | Flamer, Melta Gun, Heavy Bolter, Plasma Gun |
| notes | 圣三一体核心，可配置多种重武器 |

| 字段 | 值 |
|---|---|
| name_zh | 炽天使小队 |
| name_en | Seraphim Squad |
| race | Sisters of Battle |
| tier | 2 |
| built_from | Infantry Convent (需 T2) |
| cost_req | 200 (初始 4 人) |
| cost_power | 20 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~300 / 模型 |
| morale | 250 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 跳跃, 飞行 |
| speed | ~16 |
| jump | 是 |
| vision | ~25 |
| weapon_name | Twin Bolt Pistols (默认) / Inferno Pistols (升级) |
| damage | ~30 (TBP) / ~60 (IP) |
| atk_type | 对 infantry / vehicle |
| cooldown | ~0.4s |
| range | ~20 |
| target | B |
| squad_size | 4 初始, 可增援至 6 |
| reinforce_cost | ~50 req + 5 power |
| active | Jump, 产生 Faith |
| notes | 跳跃高机动单位，可装备反甲 inferno pistol |

| 字段 | 值 |
|---|---|
| name_zh | 忏悔者 |
| name_en | Repentia |
| race | Sisters of Battle |
| tier | 2 |
| built_from | Infantry Convent (需 T2) |
| cost_req | 180 (初始 4 人) |
| cost_power | 20 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~400 / 模型 |
| morale | 200 |
| armor_type | infantry |
| tags | 轻步兵, 近战 |
| speed | ~16 |
| vision | ~15 |
| weapon_name | Eviscerator |
| damage | ~80-100 (melee) |
| atk_type | 对 infantry/vehicle 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 6 |
| reinforce_cost | ~45 req + 5 power |
| notes | 近战反甲步兵，高伤害但装甲轻 |

| 字段 | 值 |
|---|---|
| name_zh | 修女老兵小队 |
| name_en | Celestian Squad |
| race | Sisters of Battle |
| tier | 2 |
| built_from | Infantry Convent (需 T2) |
| cost_req | 200 (初始 4 人) |
| cost_power | 30 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~380 / 模型 |
| morale | 250 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 反甲 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Melta Gun (默认) / Multi-Melta (升级) |
| damage | ~100 (MG) / ~150 (MM) |
| atk_type | 对 vehicle/building 高穿透 |
| cooldown | ~1.5s |
| range | ~15 (MG) / ~10 (MM) |
| target | G |
| squad_size | 4 初始, 可增援至 6 |
| reinforce_cost | ~55 req + 10 power |
| notes | 专业反甲步兵 |

| 字段 | 值 |
|---|---|
| name_zh | 裁决者小队 |
| name_en | Retributor Squad |
| race | Sisters of Battle |
| tier | 3 |
| built_from | Infantry Convent (需 T3) |
| cost_req | 200 (初始 4 人) |
| cost_power | 40 |
| build_time | ~12s |
| pop_cost | 3 |
| hp | ~380 / 模型 |
| morale | 250 |
| armor_type | infantry_heavy_med |
| tags | 重步兵, 架设 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Heavy Bolter (默认) / Multi-Melta / Heavy Flamer |
| damage | ~40 (HB) / ~150 (MM) / ~60 (HF) |
| atk_type | HB: 反 infantry; MM: 反 vehicle; HF: 反 infantry+士气 |
| cooldown | ~0.3s (HB) / ~1.5s (MM) |
| range | ~30 (HB) / ~10 (MM) / ~15 (HF) |
| target | B |
| squad_size | 4 初始, 可增援至 6 |
| reinforce_cost | ~55 req + 15 power |
| notes | 重武器架设小队，多种武器配置 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 焚化者 |
| name_en | Immolator |
| race | Sisters of Battle |
| tier | 2 |
| built_from | Vehicle Convent |
| cost_req | 100 |
| cost_power | 120 |
| build_time | ~15s |
| pop_cost | 2 (vehicle) |
| hp | ~2000 |
| armor_type | vehicle_med |
| tags | 载具, 运输, 火焰 |
| speed | ~18 |
| vision | ~20 |
| weapon_name | Twin-linked Heavy Flamer (默认) / Twin-linked Multi-Melta (升级) |
| damage | ~60 (TLHF, AOE) / ~120 (TLMM) |
| atk_type | TLHF: 反 infantry+士气; TLMM: 反 vehicle |
| cooldown | ~1s (TLHF) / ~1.5s (TLMM) |
| range | ~20 (TLHF) / ~15 (TLMM) |
| target | G |
| transport_slots | 乘载 1 个小队 |
| notes | 火焰运输载具，反步/反甲可选 |

| 字段 | 值 |
|---|---|
| name_zh | 管风琴 |
| name_en | Exorcist |
| race | Sisters of Battle |
| tier | 3 |
| built_from | Vehicle Convent (需 T3) |
| cost_req | 150 |
| cost_power | 250 |
| build_time | ~25s |
| pop_cost | 3 (vehicle) |
| hp | ~2800 |
| armor_type | vehicle_med |
| tags | 载具, 导弹, 攻城 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Exorcist Missile Launcher |
| damage | ~120-150 |
| atk_type | 对 infantry/building 高穿透, AOE |
| cooldown | ~3s |
| range | ~50 (间接火力) |
| target | B |
| splash | 中等 AOE |
| notes | 间接火力导弹载具，攻城利器 |

| 字段 | 值 |
|---|---|
| name_zh | 苦修引擎 |
| name_en | Penitent Engine |
| race | Sisters of Battle |
| tier | 3 |
| built_from | Vehicle Convent (需 T3) |
| cost_req | 120 |
| cost_power | 200 |
| build_time | ~20s |
| pop_cost | 2 (vehicle) |
| hp | ~2500 |
| armor_type | vehicle_med |
| tags | 载具, 近战, 快速 |
| speed | ~20 (快) |
| vision | ~20 |
| weapon_name | Flamers (ranged) + Power Blades (melee) |
| damage | ~50 (Flamer) / ~200 (melee) |
| atk_type | Flamer: 反 infantry+士气; melee: 对 vehicle/infantry 高穿透 |
| cooldown | ~0.5s (Flamer) / ~1.5s (melee) |
| range | ~15 (Flamer) / melee |
| target | G |
| notes | 高速近战载具，冲锋+火焰 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 活圣人 |
| name_en | Living Saint |
| race | Sisters of Battle |
| tier | 4 |
| built_from | HQ (需 Relic + T3) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~6000 |
| armor_type | monster_high |
| tags | 怪兽, 超级, 飞行 |
| speed | ~18 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Flaming Sword |
| damage | ~250-300 (melee) |
| atk_type | 对全类型高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Divine Light（消耗 Faith, AOE 治疗+伤害）, Resurrection（阵亡后可复活一次） |
| passive | 飞行, 圣光光环（友军治疗+士气恢复） |
| notes | T4 飞行超级单位，AOE治疗+复活+高近战 |

---

## 2.9 Dark Eldar（暗黑神灵族）

### 英雄

| 字段 | 值 |
|---|---|
| name_zh | 大君 |
| name_en | Archon |
| race | Dark Eldar |
| tier | 1 |
| built_from | HQ (Haemonculus Lair) |
| cost_req | 120 |
| cost_power | 50 |
| build_time | ~30s |
| pop_cost | 2 |
| hp | ~800 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄 |
| speed | ~16 (快) |
| vision | ~25 |
| weapon_name | Husk Blade + Splinter Pistol |
| damage | ~70-80 (melee) |
| atk_type | 对 commander/infantry 高穿透 |
| cooldown | ~1.5s |
| range | melee |
| target | G |
| active | Soul Powers（消耗 Soul Essence 施放） |
| passive | 产生 Soul Essence |
| notes | DE 核心英雄，Soul Powers 是关键 |

| 字段 | 值 |
|---|---|
| name_zh | 酷刑师 |
| name_en | Haemonculus |
| race | Dark Eldar |
| tier | 2 |
| built_from | HQ (需 T2) |
| cost_req | 100 |
| cost_power | 50 |
| build_time | ~15s |
| pop_cost | 2 |
| hp | ~600 |
| morale | 300 |
| armor_type | commander |
| tags | 英雄, 灵能 |
| speed | ~14 |
| vision | ~20 |
| weapon_name | Destructor |
| damage | ~50 (melee) |
| active | Soul Powers, Torture（减速+伤害） |
| notes | T2 辅助英雄 |

| 字段 | 值 |
|---|---|
| name_zh | 莉莉丝·海斯佩拉克斯 |
| name_en | Lelith Hesperax |
| race | Dark Eldar |
| tier | 3 |
| built_from | HQ (需 T3) |
| cost_req | 150 |
| cost_power | 100 |
| build_time | ~20s |
| pop_cost | 2 |
| hp | ~700 |
| morale | 400 |
| armor_type | commander |
| tags | 英雄, 近战 |
| speed | ~18 (极快) |
| vision | ~25 |
| weapon_name | Penetrating Blades |
| damage | ~100-120 (melee) |
| atk_type | 对 infantry/commander 极高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| active | — |
| passive | 高闪避, 高攻速 |
| notes | T3 终极近战英雄，极快+极高近战 DPS |

### 步兵

| 字段 | 值 |
|---|---|
| name_zh | 奴隶工人 |
| name_en | Slave |
| race | Dark Eldar |
| tier | 1 |
| built_from | HQ |
| cost_req | 60 |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 1 |
| hp | ~80 |
| armor_type | infantry |
| tags | 工人 |
| speed | ~14 |
| notes | 工人，建造建筑 |

| 字段 | 值 |
|---|---|
| name_zh | 曼德拉客 |
| name_en | Mandrakes |
| race | Dark Eldar |
| tier | 1 |
| built_from | Dark Foundry |
| cost_req | 120 (初始 4 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 近战, 隐身 |
| speed | ~16 (快) |
| vision | ~25 |
| weapon_name | Claws |
| damage | ~30-40 (melee) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~25 req |
| active | Infiltration（隐身） |
| notes | 隐身骚扰步兵，打完就跑 |

| 字段 | 值 |
|---|---|
| name_zh | 战士小队 |
| name_en | Warrior Squad |
| race | Dark Eldar |
| tier | 1 |
| built_from | Dark Foundry |
| cost_req | 150 (初始 4 人) |
| cost_power | 0 |
| build_time | ~8s |
| pop_cost | 2 |
| hp | ~180 / 模型 |
| morale | 120 |
| armor_type | infantry |
| tags | 轻步兵, 远程 |
| speed | ~16 (快) |
| vision | ~20 |
| weapon_name | Splinter Rifle (默认) / Shardcarbine / Blaster (升级) |
| damage | ~20 (SR) / ~30 (SC) / ~100 (Blaster) |
| atk_type | SR/SC: 对 infantry; Blaster: 对 vehicle |
| cooldown | ~0.4s (SR) / ~1.5s (Blaster) |
| range | ~25 (SR) / ~15 (Blaster) |
| target | B |
| squad_size | 4 初始, 可增援至 8 |
| reinforce_cost | ~30 req |
| heavy_weapons_slots | 2 (Shardcarbine, Blaster) |
| notes | DE 基础远程步兵，HP 极低但速度快 |

| 字段 | 值 |
|---|---|
| name_zh | 鞭笞者 |
| name_en | Scourges |
| race | Dark Eldar |
| tier | 2 |
| built_from | Dark Foundry (需 T2) |
| cost_req | 180 (初始 3 人) |
| cost_power | 30 |
| build_time | ~12s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 飞行, 反甲 |
| speed | ~16 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Dark Lance (默认) / Splinter Cannon |
| damage | ~120 (DL) / ~30 (SC) |
| atk_type | DL: 对 vehicle 极高穿透; SC: 反 infantry |
| cooldown | ~2s (DL) / ~0.3s (SC) |
| range | ~40 (DL) / ~25 (SC) |
| target | B |
| squad_size | 3 初始, 可增援至 5 |
| reinforce_cost | ~55 req + 10 power |
| notes | 飞行反甲步兵，Dark Lance 是强力反甲武器 |

| 字段 | 值 |
|---|---|
| name_zh | 地狱飞龙 |
| name_en | Hellions |
| race | Dark Eldar |
| tier | 2 |
| built_from | Dark Foundry (需 T2) |
| cost_req | 150 (初始 4 人) |
| cost_power | 20 |
| build_time | ~10s |
| pop_cost | 2 |
| hp | ~200 / 模型 |
| morale | 150 |
| armor_type | infantry |
| tags | 轻步兵, 跳跃, 近战 |
| speed | ~18 (快) |
| jump | 是 |
| vision | ~25 |
| weapon_name | Hellglaive |
| damage | ~40 (melee) |
| atk_type | 对 infantry 高穿透 |
| cooldown | ~1.0s |
| range | melee |
| target | G |
| squad_size | 4 初始, 可增援至 6 |
| reinforce_cost | ~40 req + 5 power |
| active | Jump |
| notes | 跳跃近战骚扰单位 |

### 载具

| 字段 | 值 |
|---|---|
| name_zh | 掠夺者 |
| name_en | Raider |
| race | Dark Eldar |
| tier | 2 |
| built_from | Slave Cage |
| cost_req | 80 |
| cost_power | 80 |
| build_time | ~12s |
| pop_cost | 2 (vehicle) |
| hp | ~1000 |
| armor_type | vehicle_low |
| tags | 载具, 运输, 飞行, 快速 |
| speed | ~26 (极快) |
| fly | 是 |
| vision | ~25 |
| weapon_name | Dark Lance / Disintegrator |
| damage | ~100 (DL) / ~50 (D) |
| atk_type | DL: 反 vehicle; D: 反 infantry |
| cooldown | ~2s |
| range | ~35 |
| target | B |
| transport_slots | 乘载 1 个小队 |
| notes | 极快速飞行运输载具，打完就跑 |

| 字段 | 值 |
|---|---|
| name_zh | 掠夺者战机 |
| name_en | Reaver |
| race | Dark Eldar |
| tier | 2 |
| built_from | Slave Cage |
| cost_req | 100 |
| cost_power | 100 |
| build_time | ~12s |
| pop_cost | 2 (vehicle) |
| hp | ~800 |
| armor_type | vehicle_low |
| tags | 载具, 飞行, 快速, 骚扰 |
| speed | ~28 (极快) |
| fly | 是 |
| vision | ~25 |
| weapon_name | Splinter Cannon / Dark Lance / Blaster |
| damage | ~25 (SC) / ~120 (DL) / ~100 (B) |
| atk_type | SC: 反 infantry; DL/B: 反 vehicle |
| cooldown | ~0.3s (SC) / ~2s (DL) |
| range | ~25 (SC) / ~35 (DL) |
| target | B |
| notes | 极快速飞行骚扰载具，游戏最快单位之一 |

| 字段 | 值 |
|---|---|
| name_zh | 掠食者 |
| name_en | Ravager |
| race | Dark Eldar |
| tier | 3 |
| built_from | Slave Cage (需 T3) |
| cost_req | 150 |
| cost_power | 200 |
| build_time | ~20s |
| pop_cost | 3 (vehicle) |
| hp | ~1800 |
| armor_type | vehicle_med |
| tags | 载具, 飞行, 反甲 |
| speed | ~22 (快) |
| fly | 是 |
| vision | ~25 |
| weapon_name | Dark Lance × 3 / Disintegrator × 3 |
| damage | ~120 (each DL) / ~50 (each D) |
| atk_type | DL: 对 vehicle 极高穿透; D: 反 infantry |
| cooldown | ~2s (DL) / ~0.5s (D) |
| range | ~40 (DL) / ~25 (D) |
| target | B |
| notes | 飞行重火力载具，三 DL 配置反甲极强 |

| 字段 | 值 |
|---|---|
| name_zh | 塔洛斯 |
| name_en | Talos |
| race | Dark Eldar |
| tier | 3 |
| built_from | Slave Cage (需 T3) |
| cost_req | 120 |
| cost_power | 200 |
| build_time | ~20s |
| pop_cost | 3 (vehicle) |
| hp | ~3000 |
| armor_type | monster_med |
| tags | 怪兽, 近战, 肉盾 |
| speed | ~12 |
| vision | ~20 |
| weapon_name | Claws + Sting |
| damage | ~150 (melee) / ~60 (Sting, AOE) |
| atk_type | melee: 对 vehicle/infantry; Sting: 反 infantry |
| cooldown | ~1.5s |
| range | melee / ~15 (Sting) |
| target | G |
| active | Soul Charge（消耗 Soul Essence, 临时 buff） |
| notes | DE 唯一肉盾单位，怪兽甲提供较好抗性 |

### 超级单位

| 字段 | 值 |
|---|---|
| name_zh | 毁灭之台 |
| name_en | Dais of Destruction |
| race | Dark Eldar |
| tier | 4 |
| built_from | Slave Cage (需 Relic + T3) |
| cost_req | 250 |
| cost_power | 500 |
| build_time | ~45s |
| pop_cost | 5 (vehicle) |
| hp | ~5000 |
| armor_type | vehicle_high |
| tags | 载具, 超级, 飞行 |
| speed | ~22 |
| fly | 是 |
| vision | ~25 |
| weapon_name | Twin-linked Dark Lance × 2 + Disintegrator |
| damage | ~150 (each TLDL) / ~80 (D, AOE) |
| atk_type | 全类型高穿透 |
| cooldown | ~2s (TL DL) / ~0.5s (D) |
| range | ~40 (TL DL) / ~25 (D) |
| target | B |
| active | Soul Powers (强化版) |
| passive | Archon 专属载具, 飞行 |
| notes | T4 超级飞行载具，Archon 的座驾，高火力+飞行+Soul Powers |

---

## 附录 A：DoW1 护甲穿透参考表（典型武器）

> 以下为常见武器的护甲穿透百分比近似值（100% = 全伤害），实际值因版本/补丁有波动

| 武器 \ 护甲类型 | inf | inf_hv_med | inf_hv_high | commander | vehicle_low | vehicle_med | vehicle_high | building |
|---|---|---|---|---|---|---|---|---|
| Bolter | 100% | 70% | 30% | 20% | 5% | 3% | 1% | 5% |
| Sniper Rifle | 100% | 100% | 80% | 50% | 5% | 3% | 1% | 5% |
| Plasma Gun | 70% | 100% | 80% | 50% | 30% | 20% | 10% | 15% |
| Missile Launcher | 30% | 50% | 50% | 40% | 100% | 80% | 60% | 80% |
| Lascannon | 20% | 30% | 30% | 30% | 100% | 100% | 100% | 60% |
| Flamer | 100% | 100% | 80% | 30% | 10% | 5% | 1% | 20% |
| Heavy Bolter | 100% | 80% | 40% | 20% | 5% | 3% | 1% | 5% |
| Assault Cannon | 100% | 100% | 60% | 40% | 30% | 20% | 10% | 15% |
| Pulse Rifle (Tau) | 100% | 100% | 50% | 30% | 5% | 3% | 1% | 5% |
| Gauss Flayer (Necron) | 80% | 80% | 60% | 40% | 30% | 20% | 10% | 20% |
| Gauss Blaster (Necron) | 60% | 80% | 80% | 50% | 80% | 60% | 40% | 60% |
| Dark Lance (DE) | 20% | 30% | 30% | 30% | 100% | 100% | 100% | 70% |
| Bright Lance (Eldar) | 20% | 30% | 30% | 30% | 100% | 100% | 100% | 70% |
| Battle Cannon | 80% | 80% | 60% | 40% | 60% | 40% | 30% | 60% |

## 附录 B：士气系统参考值

| 单位 | 最大士气 | 士气恢复/秒 | 崩溃后准确率 |
|---|---|---|---|
| Space Marine | 300 | ~10 | ~30% |
| Chaos Space Marine | 250 | ~8 | ~30% |
| Ork Boy | 150 | ~6 | ~20% |
| Guardian (Eldar) | 120 | ~8 | ~20% |
| Guardsman | 80 | ~5 | ~10% |
| Fire Warrior (Tau) | 200 | ~8 | ~25% |
| Necron Warrior | — (免疫) | — | — |
| Battle Sister | 250 | ~8 | ~25% |
| Dark Eldar Warrior | 120 | ~6 | ~20% |

## 附录 C：数据来源说明

- **主要来源**：Dawn of War Wiki (dawnofwar.fandom.com) / Liquipedia DoW / 游戏内属性文件（.lua 文件）
- **版本基准**：Soulstorm v1.51（最终补丁）
- **注意事项**：
  - DoW1 经历了从 2004 年 v1.0 到 2008 年 v1.51 的多次平衡性改动
  - Winter Assault / Dark Crusade / Soulstorm 各资料片均有平衡调整
  - 部分数值（HP、伤害、费用）在不同版本间有显著差异
  - 标注 `~` 的数值为近似值，实际值可能有 ±10-20% 波动
  - 升级加成（Bionics, Target Finder 等）可显著改变基础数值
  - 重武器槽位数量在部分补丁中有调整
  - Soulstorm 添加的空军单位（Marauder Bomber, 等）未全部列出
  - 由于网络访问限制，部分数据基于训练知识整理，建议与 wiki 交叉验证