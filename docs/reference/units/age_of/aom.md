# 神话时代 重述版（Age of Mythology: Retold）单位数据

**版本说明**：本文档基于 Age of Mythology: Retold（2024 年 9 月发布）公开资料整理。
**数据来源**：Liquipedia、Age of Empires Fandom Wiki、官方补丁说明。
**注意事项**：
- Retold 相对原版的核心改动：神力（God Power）改为可多次施放（消耗 Favor 资源）、希腊英雄不再免费（需占用人口并消耗资源生产）、亚特兰蒂斯神力机制调整、各系平衡性数值调整。
- 具体数值可能随补丁版本波动，表中数据以 Retold 发布版本为准，标注 `≈` 表示近似值。
- 字段缺失填 `—`。

---

## 第一部分：主神系设计分析

---

### 一、Greek（希腊）

#### 1. 设计哲学一句话
经典三角克制 + 神话英雄单兵作战，以 Favor 资源投资英雄/神话单位形成质变。

#### 2. 签名机制
- **英雄系统**：每个主神可生产专属希腊英雄（Jason、Odysseus、Heracles 等），对神话单位有 5x~7x 加成，是反神话的核心。Retold 中英雄需占用人口并消耗资源生产（原版免费自动出现）。
- **Favor 获取**：村民在 Temple 祈祷（pray），1 村民 ≈ 0.1/s，需要大量村民投入。
- **完整兵种三角**：Hoplite（步兵反骑）← Toxotes（弓兵反步）← Hippikon（骑兵反弓），是 4 系中最教科书式的克制。

#### 3. 角色分工
| 角色 | 单位 | 备注 |
|---|---|---|
| 村民 | Villager | 希腊村民，建造/采集/祈祷 |
| 人类步兵 | Hoplite, Hypaspist | 重装步兵主战 + 反步专家 |
| 人类弓兵 | Toxotes, Peltast, Gastraphetes | 主战弓 + 反弓 + 反建筑弓 |
| 人类骑兵 | Hippikon, Prodromos | 主战骑 + 反骑专家 |
| 英雄 | Jason, Odysseus, Theseus, Atalanta, Hippolyta, Chiron, Bellerophon, Perseus, Heracles, Achilles | 反神话加成 |
| 神话单位 | Pegasus, Centaur, Minotaur, Cyclops, Hydra, Nemean Lion | 多样化 |
| 攻城 | Helepolis | 移动攻城塔，可驻军 |
| 海军 | Trireme, Pentekonter, Juggernaut | 三列桨/撞击/重型 |

#### 4. 核心协同组合
1. **Hoplite + Toxotes**：经典步弓组合，Hoplite 抗骑兵，Toxotes 输出。
2. **Hippikon + Toxotes**：骑兵弓兵协同，机动性强。
3. **Hoplite + Centaur**：步兵前排，半人马后排机动射箭。
4. **Minotaur + Hoplite**：米诺陶冲锋 + 步兵肉盾，米诺陶特殊技能可将敌人撞飞。
5. **Hydra + Hippikon**：九头蛇成长型肉盾 + 骑兵收割。
6. **Hero (Heracles) + Hoplite**：英雄反神话 + 步兵主战，反 Mythic 时代快攻。
7. **Cyclops + Hypaspist**：独眼巨人投石溅射 + 反步专家清理步兵海。

#### 5. 次神选择
**Classical Age（古典时代）**：
- **Athena**：神力 Restoration（群体治疗），技术 Sarissa（Hoplite 反骑加成），神话单位 Minotaur。
- **Hermes**：神力 Cease Fire（停火），技术 Spirited Charge（骑兵冲锋），神话单位 Centaur。
- **Ares**：神力 Pestilence（瘟疫阻止造兵），技术 Will of Kronos（人类单位对神话加成），神话单位 Cyclops。

**Heroic Age（英雄时代）**：
- **Apollo**：神力 Underworld Passage（地下通道传送），技术 Oracle（视野），神话单位 Manticore。
- **Artemis**：神力 Earthquake（地震反建筑），技术 Talaria（Hippikon 速度），神话单位 Chimera（神话 Chimera）。
- **Dionysus**：神力 Bronze（人类单位护甲+），技术 Thurifer（Favor 产出），神话单位 Hydra。

**Mythic Age（神话时代）**：
- **Hera**：神力 Lightning Storm（闪电风暴 AoE），技术 Face of the Gorgon（Medusa 提升），神话单位 Nemean Lion（Retold 新增/强化）。
- **Hephaestus**：神力 Plenty（免费资源），技术 Hand of Talos（Bronze 升级 Colossus），神话单位 Colossus（可吃树/金矿回血）。

#### 6. 强势时间窗
- **Archaic（远古）**：弱（经济启动慢，需村民祈祷 Favor）
- **Classical（古典）**：中（Hero + 神话单位小规模）
- **Heroic（英雄）**：强（完整兵种 + 多英雄）
- **Mythic（神话）**：极强（Colossus/Hydra + Lightning Storm/Earthquake）

#### 7. 反制弱点
- Favor 依赖村民祈祷，早期被骚扰损失村民会断 Favor。
- 英雄昂贵（Retold 占人口），数量有限。
- 反骑兵若 Hoplite 死光，骑兵海可碾压。
- 没有 Atlantean 的"全能单位"，需要兵种搭配。

---

### 二、Egyptian（埃及）

#### 1. 设计哲学一句话
纪念碑式经济 + Pharaoh 强化 + Mercenary 雇佣兵速成军队。

#### 2. 签名机制
- **Pharaoh（法老）**：英雄单位，开局拥有 1 名。可"Empower"建筑（提升 20% 产出/速度），战斗中对神话单位有加成。Retold 中 Pharaoh 死亡后会从 Town Center 重生。
- **Monument（纪念碑）**：5 座 Monument 提供 Favor 被动产出，无需村民祈祷。需要逐级解锁（Age 升级后建更高阶）。
- **Mercenary（雇佣兵）**：可在 5 秒内从 Town Center 速出，但持续消耗黄金维持（或一次性成本）。是埃及应急防御/快攻的关键。
- **Priest（祭司）**：可召唤 Obelisk（视野）、治疗、Empower 建筑、招降神话单位（部分版本）。

#### 3. 角色分工
| 角色 | 单位 | 备注 |
|---|---|---|
| 村民 | Laborer | 埃及村民 |
| 英雄 | Pharaoh, Priest | Pharaoh 强化建筑/Priest 治疗+Obelisk |
| 人类步兵 | Spearman, Axeman | 反骑 / 反弓 |
| 人类弓兵 | Slinger | 反步兵 |
| 人类骑兵 | Chariot Archer, Camel Rider, War Elephant | 弓骑/反骑/重型 |
| 神话单位 | Sphinx, Petsuchos, Scorpion Man, Wadjet, War Serpent, Leviathan, Mummy, Phoenix, Roc | 多样飞行/召唤 |
| 攻城 | Siege Tower, Catapult | 攻城塔/投石 |
| 海军 | Kebenit, War Barge | 弓船/重型 |

#### 4. 核心协同组合
1. **Spearman + Slinger**：反骑 + 反步，便宜双重克制。
2. **War Elephant + Chariot Archer**：象兵前排冲阵，战车弓兵后排输出。
3. **Sphinx + Spearman**：狮身人面冲锋 + 反骑保护。Sphinx 特殊攻击范围震飞。
4. **Petsuchos + Axeman**：鳄鱼神兵（远程穿透）+ 反弓保护。
5. **Mummy + Priest**：木乃伊召唤亡灵 + 祭司治疗。
6. **Phoenix + Chariot Archer**：凤凰（飞行）+ 地面机动输出。
7. **Pharaoh (Empower) + Mercenary**：法老强化 TC + 雇佣兵速出反 rush。

#### 5. 次神选择
**Classical Age**：
- **Ptah**：神力 Shifting Sands（传送单位），技术 Scalloped Axe（Axeman 加成），神话单位 Wadjet（蛇形弓兵）。
- **Bast**：神力 Eclipse（敌方降速），技术 Sacred Cats（_cats？），神话单位 Sphinx。
- **Ptah** / **Sekhmet**：神力 Citadel（要塞化 TC），神话单位 Petsuchos。

**Heroic Age**：
- **Hathor**：神力 Sun Ray（？）或 Locust Swarm（蝗群反经济），神话单位 Roc（运输飞行）。
- **Nephthys**：神力 Ancestors（召唤亡灵士兵），神话单位 Scorpion Man。
- **Thoth**：神力 Meteor（陨石），技术 Valley of the Kings（Mercenary 强化），神话单位 Phoenix。

**Mythic Age**：
- **Horus**：神力 Tornado（龙卷风），技术 Atef Crown（Pharaoh 强化），神话单位 Avenger。
- **Osiris**：神力 Son of Osiris（Pharaoh 升级为神之子），技术 New Kingdom（双 Pharaoh），神话单位 Mummy。
- **Set** / **Anubis**：神力（取决于资料片），神话单位 Anubite（跳跃）。

#### 6. 强势时间窗
- **Archaic**：中（Monument 直升，Pharaoh Empower 加速经济）
- **Classical**：强（Mercenary 速防 + Sphinx）
- **Heroic**：极强（War Elephant + 多神话单位）
- **Mythic**：强（Mummy + Son of Osiris + Tornado）

#### 7. 反制弱点
- 无纪念碑则 Favor 断流，敌方拆 Monument 即可掐死神话单位。
- 早期依赖 Mercenary，黄金消耗大。
- 步兵质量弱（Spearman/Axeman 都是反制型而非主战），主战靠 War Elephant（贵）。
- 缺乏真正的反英雄单位（需靠数量或 Son of Osiris）。

---

### 三、Norse（北欧）

#### 1. 设计哲学一句话
移动经济 + 免费步兵造兵 + 战斗产 Favor，全攻势种族。

#### 2. 签名机制
- **Ulfsark 作为建造者**：步兵单位建造所有建筑，无需村民。这意味着北欧可早期前压建造。
- **Ox Cart（牛车）**：移动资源投放点，可在前线收集资源，无需回城。
- **Favor 通过战斗获取**：Hersir（英雄步兵）和一般单位战斗时产生 Favor，攻势越猛 Favor 越多。
- **Hersir**：英雄步兵，对神话单位有加成，移动快、生产便宜。

#### 3. 角色分工
| 角色 | 单位 | 备注 |
|---|---|---|
| 村民 | Gatherer, Dwarf | Gatherer 采集食物/木材，Dwarf 采集黄金 |
| 经济单位 | Ox Cart | 移动仓库 |
| 人类步兵 | Ulfsark, Huskarl, Hirdman | Ulfsark 反骑/Huskarl 反弓/Hirdman 反步 |
| 人类弓兵 | Throwing Axeman | 远程但造成近战伤害，反步兵 |
| 人类骑兵 | Raiding Cavalry, Jarl | 反弓 / 重型 |
| 英雄 | Hersir | 可装备神捡物品，反神话 |
| 神话单位 | Valkyrie, Frost Giant, Mountain Giant, Fire Giant, Troll, Kraken, Jormun Elver | 治疗/冻/攻城/远程/再生/海怪 |
| 攻城 | Ballista, Ram | 弩炮/撞城 |
| 海军 | Longboat, Drakkar | 弓船/龙头船 |

#### 4. 核心协同组合
1. **Ulfsark + Throwing Axeman**：步兵肉盾 + 远程（近战伤害）反步。
2. **Raiding Cavalry + Huskarl**：骑兵突弓兵 + 反弓步兵双保险。
3. **Hersir + Raiding Cavalry**：英雄反神话 + 骑兵绕后排。
4. **Mountain Giant + Ulfsark**：山巨人攻城 + 步兵保护。
5. **Frost Giant + Huskarl**：霜巨人冰冻（特殊攻击）+ 步兵清理。
6. **Valkyrie + Jarl**：女武神治疗（光环）+ 雅尔输出。
7. **Troll + Throwing Axeman**：巨魔远程 + 再生 + 斧兵反步。

#### 5. 次神选择
**Classical Age**：
- **Freyja**：神力 Forest Fire（烧林），技术 Thundering Hooves（骑兵加成），神话单位 Valkyrie。
- **Heimdall**：神力 Underworld Passage（？或为其他），神话单位 Einheri。
- **Forseti**：神力 Healing Spring（治疗泉），技术 Hamarr（？），神话单位 Troll。

**Heroic Age**：
- **Njord**：神力 Walking Woods（树林行走/召唤树人），技术 Wanderer（？），神话单位 Kraken（海战）+ Mountain Giant。
- **Skadi**：神力 Frost（冰冻全场敌方单位），技术 Winter Harvest（？），神话单位 Frost Giant。
- **Bragi**：神力 Flaming Weapons（武器点燃），神话单位 Battle Boar。

**Mythic Age**：
- **Tyr**：神力 Fimbulwinter（芬布尔之冬，狼群侵袭），技术 Berserkergang（Huskarl 狂暴），神话单位 Fenris Wolf Brood。
- **Hel**：神力 Nidhogg（召唤尼德霍格飞龙），神话单位 Fire Giant + Nidhogg。
- **Baldr** / **Vidar**：神力 Ragnarok（Ragnarök，村民变 Huskarl），神话单位 Jormun Elver（？）。

#### 6. 强势时间窗
- **Archaic**：强（Ulfsark 早期前压，Ox Cart 移动经济）
- **Classical**：极强（Raiding Cavalry + Hersir 战斗产 Favor）
- **Heroic**：强（Frost / Mountain Giant 攻城）
- **Mythic**：中（依赖 Nidhogg/Fimbulwinter 收尾）

#### 7. 反制弱点
- 没有传统村民建造，早期 Ulfsark 死亡影响建筑进度。
- 远程步兵质量弱，面对弓兵海需要 Huskarl。
- 经济偏黄金（Dwarf 采矿）+ Favor 靠战斗，被动局面无 Favor。
- 建筑防御弱（无大型防御塔系统）。

---

### 四、Atlantean（亚特兰蒂斯）

#### 1. 设计哲学一句话
多功能昂贵单位 + 神力可多次施放 + 单位可升级为英雄。

#### 2. 签名机制
- **Citizen（公民）**：村民消耗 3 人口，但采集效率高且可建造 Manor（人口上限+）。1 个 Citizen ≈ 3 个普通村民效率。
- **Hero 升级（Promote to Hero）**：任何人类单位可消耗 Favor 升级为英雄版本，提升属性 + 反神话加成。
- **God Power 多次施放**：所有神力可多次使用，每次消耗 Favor，是 4 系中唯一可"刷神力"的种族。
- **Orichalcum（奥利哈康）技术**：科技树独特升级路径。

#### 3. 角色分工
| 角色 | 单位 | 备注 |
|---|---|---|
| 村民 | Citizen | 3 人口，多功能高效率 |
| 人类步兵 | Murmillo, Katapeltes | 主战 / 反骑 |
| 人类弓兵 | Cheiroballista | 穿透弩炮，反骑兵 |
| 人类骑兵 | Contarius, Destroyer | 主战骑 / 反弓骑 |
| 攻城 | Onager, Fire Siphon | 投石 / 火焰攻城 |
| 英雄 | 任何单位升级为 Hero | 通用机制 |
| 神话单位 | Promethean, Automaton, Satyr, Behemoth, Caladrius, Servant, Argus, Heka Gigantes, Lampades, Man O' War | 多功能 |
| 海军 | Arrow Ship, Siege Ship | 弓船/攻城船 |

#### 4. 核心协同组合
1. **Murmillo (Hero) + Cheiroballista**：英雄化重步兵 + 穿透弩炮反骑。
2. **Contarius + Destroyer**：骑兵组合，Contarius 抗 + Destroyer 切弓兵。
3. **Promethean + Murmillo**：普罗米修斯之子（死亡分裂为两个小怪）+ 步兵保护。
4. **Behemoth + Katapeltes**：攻城兽 + 反骑保护。
5. **Automaton + Murmillo**：自动机（可互相维修）+ 步兵防线。
6. **Caladrius + Contarius**：飞鸟治疗 + 骑兵突袭。
7. **Heka Gigantes + Destroyer**：百臂巨人（AoE 近战）+ 反弓骑兵。

#### 5. 次神选择
**Classical Age**：
- **Prometheus**：神力 Valor（免费升级若干单位为英雄），技术 Heart of the Titans（神话单位加成），神话单位 Promethean。
- **Leto**：神力 Spy（？），技术 Volcanic Forge（？），神话单位 Automaton。
- **Oceanus**：神力 Carnivora（食肉植物陷阱），技术 Mythic Rejuvenation（神话单位再生），神话单位 Servant + Caladrius。

**Heroic Age**：
- **Rheia**：神力 Traitor（招降敌方神话单位），技术 Mythic Rejuvenation（？），神话 unit Satyr。
- **Theia**：神力 Hesperides（？），技术 Lemurian Descendants（？），神话单位 Heka Gigantes。
- **Hyperion**：神力 Chaos（敌方单位混乱），技术 Heroes（？），神话单位 Nereid（海战）。

**Mythic Age**：
- **Atlas**：神力 Implode（内爆 AoE），技术 Earthen Wall（城墙升级），神话 unit Argus。
- **Hekate**：神力 Tartarian Gate（ Tartarus 之门召唤），技术 Mythic Rejuvenation，神话 unit Lampades。
- **Cronos** / **Kronos**：神力 Time Shift（时间转移建筑），技术 Titan Shield，神话 unit Behemoth。

#### 6. 强势时间窗
- **Archaic**：中（Citizen 高效但贵）
- **Classical**：强（Promethean + Hero 升级性价比高）
- **Heroic**：极强（完整多功能 + Behemoth 攻城 + Hero 单位）
- **Mythic**：极强（Tartarian Gate + 多次神力 + Atlas Implode）

#### 7. 反制弱点
- Citizen 占 3 人口，前期损失 Citizen 等于损失 3 村民，灾难性。
- 单位昂贵，黄金消耗大。
- 没有真正的"反英雄"专属单位，依赖 Hero 升级通用单位。
- 早期被压制时 Favor 不足无法升 Hero，陷入恶性循环。

---

## 第二部分：单位数据表

> **数据约定**：
> - HP/Attack/Armor 为基础值（未升级）
> - cost 单位为 F=Food / W=Wood / G=Gold / V=Favor
> - train_time 单位秒
> - speed 单位 m/s
> - cooldown 单位秒
> - Retold 中希腊英雄需占用人口并消耗资源（原版免费）

---

### 2.1 村民 / 经济单位

| name_zh | name_en | civ | type | built_from | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 希腊村民 | Villager | Greek | 人类 | TC | 50 | — | — | — | 12 | 1 | 60 | 10% | 10% | 3.8 | 16 | 3 | hack | 1.5 | — | — | 可建造/采集/在 Temple 祈祷产 Favor | 人类 |
| 埃及劳工 | Laborer | Egyptian | 人类 | TC | 50 | — | — | — | 12 | 1 | 60 | 10% | 10% | 3.8 | 16 | 3 | hack | 1.5 | — | — | 可建造/采集/Monument 提供 Favor 被动 | 人类 |
| 北欧采集者 | Gatherer | Norse | 人类 | TC | 50 | — | — | — | 12 | 1 | 50 | 10% | 10% | 3.8 | 16 | 2 | hack | 1.5 | — | — | 采集食物/木材，不建造 | 人类 |
| 北欧矮人 | Dwarf | Norse | 人类 | TC | — | — | 60 | — | 12 | 1 | 50 | 10% | 10% | 3.8 | 16 | 2 | hack | 1.5 | — | — | 仅采集黄金（效率高） | 人类 |
| 牛车 | Ox Cart | Norse | 人类 | TC | — | 50 | — | — | 10 | 1 | 70 | 20% | 20% | 3.5 | 14 | — | — | — | — | — | 移动资源投放点（无需回城） | 人类 |
| 亚特兰蒂斯公民 | Citizen | Atlantean | 人类 | TC | 75 | — | 25 | — | 18 | 3 | 110 | 15% | 15% | 3.8 | 18 | 4 | hack | 1.5 | — | — | 高效采集，可建 Manor（+10 pop） | 人类 |

---

### 2.2 步兵（人类）

| name_zh | name_en | civ | type | built_from | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 重装步兵 | Hoplite | Greek | 人类 | Academy | 60 | — | — | — | 10 | 2 | 110 | 30% | 20% | 4.5 | 16 | 12 | hack | 1.5 | — | x2 骑兵 | — | 人类, 步兵 |
| 轻盾兵 | Hypaspist | Greek | 人类 | Academy | 55 | — | 10 | — | 10 | 2 | 90 | 25% | 20% | 4.5 | 16 | 10 | hack | 1.5 | — | x2 步兵 | 反步专家 | 人类, 步兵 |
| 长矛兵 | Spearman | Egyptian | 人类 | Barracks | 40 | — | 10 | — | 8 | 2 | 70 | 20% | 15% | 4.5 | 14 | 6 | hack | 1.5 | — | x3 骑兵 | 便宜反骑 | 人类, 步兵 |
| 斧兵 | Axeman | Egyptian | 人类 | Barracks | 35 | — | 15 | — | 8 | 2 | 65 | 20% | 15% | 4.5 | 14 | 6 | hack | 1.5 | — | x2 弓兵 | 反弓 | 人类, 步兵 |
| 北欧狂战士 | Ulfsark | Norse | 人类 | Longhouse | 40 | — | 10 | — | 8 | 2 | 80 | 20% | 15% | 4.8 | 14 | 7 | hack | 1.5 | — | x2 骑兵 | 可建造建筑 | 人类, 步兵 |
| 胡斯卡尔 | Huskarl | Norse | 人类 | Longhouse | 45 | — | 15 | — | 9 | 2 | 85 | 30% | 30% | 4.5 | 14 | 8 | hack | 1.5 | — | x2 弓兵 | 高远程护甲 | 人类, 步兵 |
| 希德曼 | Hirdman | Norse | 人类 | Hill Fort | 60 | — | 20 | — | 10 | 2 | 100 | 25% | 20% | 4.5 | 14 | 10 | hack | 1.5 | — | x2 步兵 | 反步 | 人类, 步兵 |
| 重装剑士 | Murmillo | Atlantean | 人类 | Barracks | 60 | — | 30 | — | 12 | 2 | 130 | 30% | 25% | 4.5 | 16 | 12 | hack | 1.5 | — | — | 可升 Hero | 人类, 步兵 |
| 反骑投手 | Katapeltes | Atlantean | 人类 | Barracks | 50 | — | 30 | — | 12 | 2 | 100 | 25% | 20% | 4.5 | 16 | 10 | hack | 1.5 | — | x3 骑兵 | 反骑 | 人类, 步兵 |

---

### 2.3 弓兵（人类）

| name_zh | name_en | civ | type | built_from | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 弓箭手 | Toxotes | Greek | 人类 | Archery Range | 40 | 40 | — | — | 10 | 2 | 70 | 15% | 25% | 4.2 | 18 | 7 | pierce | 1.5 | 16 | x2 步兵 | — | 人类, 弓兵 |
| 投石兵 | Peltast | Greek | 人类 | Archery Range | 30 | 50 | — | — | 10 | 2 | 55 | 15% | 25% | 4.2 | 18 | 6 | pierce | 1.5 | 14 | x2 弓兵 | 反弓 | 人类, 弓兵 |
| 腹弩手 | Gastraphetes | Greek | 人类 | Archery Range | 40 | 60 | — | — | 12 | 2 | 65 | 15% | 25% | 4.0 | 18 | 10 | pierce | 2.0 | 18 | x2 建筑 | 反建筑弓 | 人类, 弓兵 |
| 投石手 | Slinger | Egyptian | 人类 | Barracks | 30 | 40 | — | — | 9 | 2 | 55 | 10% | 25% | 4.2 | 16 | 5 | pierce | 1.5 | 14 | x2 步兵 | 反步 | 人类, 弓兵 |
| 战车弓兵 | Chariot Archer | Egyptian | 人类 | Migdol Stronghold | 40 | 60 | — | — | 12 | 3 | 80 | 15% | 25% | 5.0 | 18 | 7 | pierce | 1.5 | 16 | — | 高机动 | 人类, 弓兵, 骑兵 |
| 掷斧兵 | Throwing Axeman | Norse | 人类 | Longhouse | 30 | 40 | — | — | 9 | 2 | 60 | 15% | 20% | 4.2 | 14 | 7 | hack | 1.5 | 12 | x2 步兵 | 远程但造 hack 伤害 | 人类, 弓兵 |
| 穿透弩炮 | Cheiroballista | Atlantean | 人类 | Barracks | 40 | 60 | — | — | 12 | 2 | 70 | 15% | 25% | 4.0 | 18 | 9 | pierce | 2.0 | 18 | x2 骑兵, 穿透多目标 | 穿透线形多目标 | 人类, 弓兵 |

---

### 2.4 骑兵（人类）

| name_zh | name_en | civ | type | built_from | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 伴骑骑兵 | Hippikon | Greek | 人类 | Academy | 60 | — | 40 | — | 12 | 3 | 130 | 25% | 20% | 5.5 | 16 | 12 | hack | 1.5 | — | x2 弓兵 | — | 人类, 骑兵 |
| 先驱骑兵 | Prodromos | Greek | 人类 | Academy | 50 | — | 50 | — | 12 | 3 | 110 | 25% | 20% | 5.5 | 16 | 10 | hack | 1.5 | — | x2 骑兵 | 反骑 | 人类, 骑兵 |
| 骆驼骑兵 | Camel Rider | Egyptian | 人类 | Migdol Stronghold | 50 | — | 50 | — | 12 | 3 | 100 | 20% | 20% | 5.5 | 16 | 9 | hack | 1.5 | — | x2 骑兵 | 反骑 | 人类, 骑兵 |
| 战象 | War Elephant | Egyptian | 人类 | Migdol Stronghold | 120 | — | 60 | — | 16 | 4 | 280 | 30% | 30% | 4.8 | 16 | 18 | hack | 1.8 | — | — | 高 HP, 溅射 | 人类, 骑兵 |
| 突袭骑兵 | Raiding Cavalry | Norse | 人类 | Hill Fort | 50 | — | 50 | — | 12 | 3 | 110 | 25% | 20% | 5.5 | 16 | 10 | hack | 1.5 | — | x2 弓兵 | 反弓 | 人类, 骑兵 |
| 雅尔 | Jarl | Norse | 人类 | Hill Fort | 80 | — | 60 | — | 14 | 4 | 200 | 30% | 25% | 5.2 | 16 | 15 | hack | 1.8 | — | — | 重型骑兵 | 人类, 骑兵 |
| 主战骑兵 | Contarius | Atlantean | 人类 | Palace | 60 | — | 60 | — | 12 | 3 | 140 | 30% | 25% | 5.5 | 16 | 14 | hack | 1.5 | — | x2 弓兵 | — | 人类, 骑兵 |
| 毁灭者 | Destroyer | Atlantean | 人类 | Palace | 50 | — | 80 | — | 12 | 3 | 120 | 25% | 30% | 5.5 | 16 | 12 | hack | 1.5 | — | x3 弓兵 | 反弓骑兵 | 人类, 骑兵 |

---

### 2.5 攻城单位

| name_zh | name_en | civ | type | built_from | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 攻城塔 | Helepolis | Greek | 攻城 | Fortress | — | 120 | 80 | — | 20 | 4 | 280 | 40% | 50% | 3.0 | 18 | 30 | crush | 3.0 | 20 | x6 建筑 | 可驻军弓兵 | 攻城 |
| 攻城塔 | Siege Tower | Egyptian | 攻城 | Migdol | — | 100 | 80 | — | 18 | 4 | 250 | 40% | 50% | 3.0 | 16 | 25 | crush | 3.0 | 18 | x5 建筑 | — | 攻城 |
| 投石器 | Catapult | Egyptian | 攻城 | Siege Workshop | — | 140 | 100 | — | 22 | 4 | 200 | 20% | 30% | 3.0 | 18 | 50 | crush | 4.0 | 24 | x6 建筑 | 远程攻城 | 攻城 |
| 撞城车 | Battering Ram | Norse | 攻城 | Hill Fort | — | 100 | 60 | — | 18 | 3 | 220 | 50% | 50% | 3.2 | 14 | 40 | crush | 2.5 | 2 | x8 建筑 | 近战攻城 | 攻城 |
| 弩炮 | Ballista | Norse | 攻城 | Hill Fort | — | 80 | 60 | — | 16 | 3 | 160 | 20% | 30% | 3.2 | 16 | 20 | pierce | 3.0 | 20 | x3 建筑, x2 弓兵 | 穿透 | 攻城 |
| 投石器 | Onager | Atlantean | 攻城 | Palace | — | 120 | 80 | — | 20 | 4 | 240 | 30% | 40% | 3.2 | 18 | 40 | crush | 3.5 | 22 | x6 建筑 | — | 攻城 |
| 火焰虹吸 | Fire Siphon | Atlantean | 攻城 | Palace | — | 100 | 60 | 10 | 18 | 3 | 180 | 30% | 40% | 3.5 | 16 | 30 | crush | 2.5 | 8 | x6 建筑 | 火焰溅射 | 攻城 |

---

### 2.6 神话单位（Myth Units）

> 神话单位均消耗 Favor，来自 Temple（希腊/北欧/亚特兰蒂斯）或由次神解锁。

#### 2.6.1 Greek 神话单位

| name_zh | name_en | 次神 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 飞马 | Pegasus | Hermes | — | — | — | 10 | 8 | 2 | 80 | 10% | 30% | 6.0 (fly) | 24 | 3 | hack | 1.5 | — | — | 飞行侦察 | 神话 |
| 半人马 | Centaur | Hermes | — | — | — | 20 | 14 | 3 | 200 | 25% | 30% | 5.0 | 18 | 12 | pierce | 1.8 | 16 | x2 神话 | 特殊：尾踢击退 | 神话 |
| 米诺陶 | Minotaur | Athena | — | — | — | 20 | 14 | 3 | 280 | 30% | 30% | 4.8 | 16 | 18 | hack | 1.8 | — | x2 神话 | 特殊：冲锋撞飞敌人 | 神话 |
| 独眼巨人 | Cyclops | Ares | — | — | — | 25 | 16 | 3 | 320 | 35% | 30% | 4.5 | 16 | 22 | hack | 2.0 | — | x2 神话 | 特殊：投石溅射 | 神话 |
| 九头蛇 | Hydra | Dionysus | — | — | — | 30 | 18 | 4 | 400 | 35% | 35% | 4.5 | 16 | 25 | hack | 2.0 | — | x2 神话 | 多头攻击，战斗后攻击力成长 | 神话 |
| 涅墨亚狮子 | Nemean Lion | Hera | — | — | — | 25 | 16 | 3 | 350 | 40% | 40% | 4.5 | 16 | 20 | hack | 1.8 | — | x2 神话 | Retold 新增/强化，高护甲 | 神话 |
| 巨像 | Colossus | Hephaestus | — | — | — | 40 | 25 | 5 | 600 | 50% | 50% | 3.8 | 16 | 30 | hack | 2.5 | — | x2 神话, x3 建筑 | 可吃树/金矿回血 | 神话 |
| 喀迈拉 | Chimera | Artemis | — | — | — | 30 | 18 | 4 | 380 | 30% | 30% | 5.0 | 16 | 22 | hack | 2.0 | — | x2 神话 | 特殊：火焰吐息溅射 | 神话 |
| 曼提柯尔 | Manticore | Apollo | — | — | — | 25 | 16 | 3 | 300 | 25% | 30% | 4.8 | 18 | 18 | pierce | 2.0 | 16 | x2 神话 | 远程神话 | 神话 |

#### 2.6.2 Egyptian 神话单位

| name_zh | name_en | 次神 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 狮身人面像 | Sphinx | Bast/Ptah | — | — | — | 15 | 12 | 2 | 240 | 30% | 30% | 5.0 | 16 | 15 | hack | 1.8 | — | x2 神话 | 特殊：范围震飞 | 神话 |
| 瓦吉特 | Wadjet | Ptah | — | — | — | 15 | 12 | 2 | 180 | 20% | 25% | 4.5 | 16 | 12 | pierce | 1.8 | 16 | x2 神话 | 蛇形远程 | 神话 |
| 鳄鱼神兵 | Petsuchos | Sekhmet | — | — | — | 20 | 14 | 3 | 260 | 30% | 30% | 4.5 | 16 | 16 | pierce | 2.0 | 18 | x2 神话, x2 英雄 | 远程穿透 | 神话 |
| 蝎子男 | Scorpion Man | Nephthys | — | — | — | 20 | 14 | 3 | 300 | 35% | 30% | 4.5 | 16 | 18 | hack | 1.8 | — | x2 神话 | 特殊：毒尾 | 神话 |
| 战蛇 | War Serpent | — | — | — | — | 25 | 16 | 3 | 350 | 35% | 35% | 5.0 | 16 | 20 | hack | 2.0 | — | x2 神话 | — | 神话 |
| 利维坦 | Leviathan | — | — | — | — | 20 | 14 | 3 | 350 | 30% | 30% | 4.0 | 16 | 18 | hack | 2.0 | — | x2 神话 | 海上运输/战斗 | 神话 |
| 凤凰 | Phoenix | Thoth | — | — | — | 25 | 16 | 3 | 300 | 25% | 40% | 5.5 (fly) | 18 | 15 | pierce | 1.8 | 16 | x2 神话 | 飞行，死亡变蛋重生 | 神话 |
| 石像鬼鸟 | Roc | Hathor | — | — | — | 20 | 14 | 3 | 200 | 30% | 30% | 6.0 (fly) | 18 | 8 | hack | 1.5 | — | — | 飞行运输 | 神话 |
| 木乃伊 | Mummy | Osiris | — | — | — | 35 | 20 | 4 | 350 | 30% | 30% | 4.5 | 16 | 18 | hack | 2.0 | 12 | x2 神话 | 特殊：招杀敌人变亡灵 | 神话 |
| 复仇者 | Avenger | Horus | — | — | — | 30 | 18 | 4 | 380 | 35% | 35% | 5.0 | 16 | 22 | hack | 1.8 | — | x2 神话 | 双刀溅射 | 神话 |

#### 2.6.3 Norse 神话单位

| name_zh | name_en | 次神 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 女武神 | Valkyrie | Freyja | — | — | — | 15 | 12 | 2 | 220 | 30% | 30% | 5.0 | 16 | 12 | hack | 1.5 | — | x2 神话 | 光环治疗友军 | 神话 |
| 巨魔 | Troll | Forseti | — | — | — | 20 | 14 | 3 | 240 | 25% | 30% | 4.5 | 16 | 14 | pierce | 2.0 | 18 | x2 神话 | 战斗再生 | 神话 |
| 战猪 | Battle Boar | Bragi | — | — | — | 25 | 16 | 3 | 320 | 35% | 35% | 5.0 | 16 | 20 | hack | 1.8 | — | x2 神话 | 特殊：冲撞击退 | 神话 |
| 霜巨人 | Frost Giant | Skadi | — | — | — | 25 | 16 | 3 | 350 | 35% | 35% | 4.5 | 16 | 18 | hack | 2.0 | — | x2 神话 | 特殊：冰冻敌人 | 神话 |
| 山巨人 | Mountain Giant | Njord | — | — | — | 30 | 18 | 4 | 450 | 40% | 40% | 4.0 | 16 | 25 | hack | 2.5 | — | x3 建筑 | 攻城型神话 | 神话 |
| 火巨人 | Fire Giant | Hel | — | — | — | 35 | 20 | 4 | 420 | 30% | 30% | 4.5 | 16 | 22 | hack | 2.0 | 16 | x2 神话 | 远程火焰溅射 | 神话 |
| 海怪 | Kraken | Njord | — | — | — | 20 | 14 | 3 | 300 | 30% | 30% | 5.0 | 18 | 18 | hack | 2.0 | — | x2 神话 | 海战神话 | 神话 |
| 芬里尔狼群 | Fenris Wolf Brood | Tyr | — | — | — | 20 | 14 | 2 | 180 | 25% | 25% | 5.5 | 16 | 12 | hack | 1.5 | — | x2 神话 | 群体加成（数量越多越强） | 神话 |
| 尼德霍格 | Nidhogg | Hel | — | — | — | 50 | 25 | 5 | 500 | 30% | 40% | 5.0 (fly) | 18 | 28 | hack | 2.0 | 16 | x2 神话 | 飞龙，神力召唤（仅 Hel 解锁） | 神话 |
| Einheri | Einheri | Heimdall | — | — | — | 15 | 12 | 2 | 200 | 30% | 30% | 4.5 | 16 | 10 | hack | 1.5 | — | x2 神话 | 光环加攻速 | 神话 |

#### 2.6.4 Atlantean 神话单位

| name_zh | name_en | 次神 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 普罗米修斯之子 | Promethean | Prometheus | — | — | — | 15 | 12 | 2 | 200 | 30% | 30% | 4.5 | 16 | 12 | hack | 1.5 | — | x2 神话 | 死亡分裂为 2 个小 Promethean | 神话 |
| 自动机 | Automaton | Leto | — | — | — | 20 | 14 | 3 | 250 | 40% | 40% | 4.5 | 16 | 14 | hack | 1.5 | — | x2 神话 | 可互相维修 | 神话 |
| 仆从 | Servant | Oceanus | — | — | — | 15 | 12 | 2 | 150 | 20% | 20% | 4.5 | 16 | 6 | hack | 1.5 | — | — | 治疗友军（海上/陆地） | 神话 |
| 卡拉德里乌斯 | Caladrius | Oceanus | — | — | — | 20 | 14 | 3 | 180 | 20% | 30% | 6.0 (fly) | 18 | 8 | hack | 1.5 | — | — | 飞行治疗 | 神话 |
| 萨提尔 | Satyr | Rheia | — | — | — | 20 | 14 | 3 | 220 | 25% | 25% | 4.5 | 16 | 14 | pierce | 1.8 | 16 | x2 神话 | 穿透长矛 | 神话 |
| 百臂巨人 | Heka Gigantes | Theia | — | — | — | 30 | 18 | 4 | 380 | 30% | 30% | 4.5 | 16 | 22 | hack | 1.8 | — | x2 神话 | 多手溅射 AoE | 神话 |
| 攻城兽 | Behemoth | Kronos | — | — | — | 30 | 18 | 4 | 450 | 40% | 40% | 4.0 | 16 | 25 | hack | 2.5 | — | x3 建筑 | 攻城型神话，践踏 | 神话 |
| 阿尔戈斯 | Argus | Atlas | — | — | — | 25 | 16 | 3 | 280 | 30% | 30% | 4.5 | 16 | 16 | hack | 1.8 | — | x2 神话 | 特殊：酸液溅射 | 神话 |
| 兰帕德斯 | Lampades | Hekate | — | — | — | 25 | 16 | 3 | 240 | 25% | 25% | 4.5 | 16 | 14 | hack | 1.5 | 12 | x2 神话 | 特殊：混乱敌方单位 | 神话 |
| 海上战士 | Man O' War | — | — | — | — | 25 | 16 | 3 | 280 | 25% | 30% | 5.0 | 18 | 16 | pierce | 1.8 | 16 | x2 神话 | 海战 | 神话 |

---

### 2.7 英雄单位

#### 2.7.1 Greek 英雄（按主神 + 时代解锁）

> Retold 改动：希腊英雄不再免费，需在 Fortress 或 Town Center 生产，消耗资源并占人口（2 pop）。

| name_zh | name_en | 主神 | 时代 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 杰森 | Jason | Zeus | Classical | 80 | — | 40 | 10 | 14 | 2 | 350 | 30% | 30% | 4.8 | 16 | 18 | hack | 1.5 | — | x5 神话 | 特殊：召唤 Colchis 龙（？） | 英雄 |
| 奥德修斯 | Odysseus | Poseidon | Classical | 80 | — | 40 | 10 | 14 | 2 | 320 | 30% | 30% | 4.8 | 16 | 16 | hack | 1.5 | — | x5 神话 | 远程弓兵英雄 | 英雄 |
| 忒修斯 | Theseus | Hades | Classical | 80 | — | 40 | 10 | 14 | 2 | 330 | 30% | 30% | 4.8 | 16 | 17 | hack | 1.5 | — | x5 神话 | — | 英雄 |
| 亚特兰大 | Atalanta | Zeus | Heroic | 90 | — | 50 | 15 | 16 | 2 | 320 | 25% | 30% | 5.5 | 16 | 14 | hack | 1.5 | — | x5 神话 | 高机动 | 英雄 |
| 希波吕忒 | Hippolyta | Poseidon | Heroic | 90 | — | 50 | 15 | 16 | 2 | 350 | 30% | 30% | 4.8 | 16 | 18 | hack | 1.5 | — | x5 神话 | 反骑 | 英雄 |
| 喀戎 | Chiron | Hades | Heroic | 90 | — | 50 | 15 | 16 | 2 | 320 | 25% | 30% | 5.0 | 18 | 14 | pierce | 1.5 | 18 | x5 神话 | 远程弓兵英雄 | 英雄 |
| 柏勒洛丰 | Bellerophon | Zeus | Mythic | 100 | — | 60 | 20 | 18 | 2 | 380 | 30% | 30% | 5.5 (fly) | 18 | 20 | hack | 1.5 | — | x5 神话 | 飞行（骑 Pegasus） | 英雄 |
| 珀尔修斯 | Perseus | Poseidon | Mythic | 100 | — | 60 | 20 | 18 | 2 | 360 | 30% | 30% | 5.0 | 16 | 18 | hack | 1.5 | — | x5 神话 | 特殊：Medusa 头石化（？） | 英雄 |
| 赫拉克勒斯 | Heracles | Zeus | Mythic | 120 | — | 80 | 30 | 20 | 3 | 500 | 40% | 40% | 4.8 | 16 | 28 | hack | 1.8 | — | x7 神话 | 最强希腊英雄 | 英雄 |
| 阿喀琉斯 | Achilles | Hades | Mythic | 100 | — | 60 | 20 | 18 | 2 | 400 | 35% | 35% | 5.5 | 16 | 22 | hack | 1.5 | — | x5 神话 | 高机动近战 | 英雄 |

#### 2.7.2 Egyptian 英雄

| name_zh | name_en | 主神 | 时代 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 法老 | Pharaoh | All | Archaic | — | — | — | — | (开局拥有) | 0 | 200 | 25% | 25% | 5.0 | 18 | 12 | hack | 1.5 | — | x4 神话 | Empower 建筑（+20% 产出），死亡从 TC 重生 | 英雄 |
| 祭司 | Priest | All | Archaic | 30 | — | 40 | 5 | 10 | 1 | 120 | 15% | 20% | 4.5 | 18 | 8 | pierce | 1.5 | 16 | x3 神话 | 召唤 Obelisk（视野），治疗 | 英雄 |
| 神之子 | Son of Osiris | Osiris | Mythic | — | — | — | — | (升级) | 0 | 400 | 30% | 30% | 4.5 | 18 | 20 | hack | 1.5 | 12 | x5 神话 | Pharaoh 升级版，连锁闪电 | 英雄 |

#### 2.7.3 Norse 英雄

| name_zh | name_en | 主神 | 时代 | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 赫西尔 | Hersir | All | Classical | 40 | — | 20 | 5 | 10 | 2 | 180 | 25% | 25% | 5.0 | 16 | 12 | hack | 1.5 | — | x4 神话 | 可装备捡取的神器，战斗产 Favor | 英雄 |

#### 2.7.4 Atlantean 英雄机制

> Atlantean 没有固定英雄单位。任何人类单位（Citizen、Murmillo、Katapeltes、Cheiroballista、Contarius、Destroyer）可消耗 Favor 升级为 Hero 版本。
>
> 升级成本约为原单位成本 + 一定 Favor（10~25 V），属性提升约 20%~30% HP/Attack，并获得 x4 神话加成。

| name_zh | name_en | 单位 | cost_F | cost_W | cost_G | cost_V | hp | damage | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 英雄化公民 | Hero Citizen | Citizen | +10F | — | +10G | +10V | ≈140 | ≈6 | x4 神话 | 高效采集 + 战斗 | 英雄 |
| 英雄化重装剑士 | Hero Murmillo | Murmillo | +20F | — | +10G | +15V | ≈170 | ≈16 | x4 神话 | — | 英雄 |
| 英雄化反骑投手 | Hero Katapeltes | Katapeltes | +15F | — | +10G | +15V | ≈130 | ≈13 | x4 神话, x4 骑兵 | 反骑 | 英雄 |
| 英雄化穿透弩炮 | Hero Cheiroballista | Cheiroballista | +10F | +15W | — | +15V | ≈90 | ≈12 | x4 神话, x3 骑兵 | 穿透多目标 | 英雄 |
| 英雄化主战骑兵 | Hero Contarius | Contarius | +20F | — | +20G | +15V | ≈180 | ≈18 | x4 神话 | — | 英雄 |
| 英雄化毁灭者 | Hero Destroyer | Destroyer | +15F | — | +25G | +15V | ≈160 | ≈16 | x4 神话, x4 弓兵 | 反弓 | 英雄 |

---

### 2.8 海军

#### 2.8.1 Greek 海军

| name_zh | name_en | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 三列桨战船 | Trireme | 60 | 60 | — | — | 14 | 3 | 180 | 20% | 30% | 6.0 | 18 | 10 | pierce | 1.5 | 16 | x2 弓船 | 弓兵船 | 海军 |
| 撞击船 | Pentekonter | 80 | — | 40 | — | 14 | 3 | 220 | 30% | 30% | 6.5 | 16 | 15 | hack | 2.0 | 2 | x3 弓船 | 撞击近战 | 海军 |
| 重型战船 | Juggernaut | 100 | 120 | — | 10 | 18 | 4 | 280 | 30% | 40% | 5.5 | 18 | 30 | crush | 3.0 | 22 | x4 建筑 | 远程攻城船 | 海军 |

#### 2.8.2 Egyptian 海军

| name_zh | name_en | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 克贝尼特 | Kebenit | 50 | 60 | — | — | 14 | 3 | 160 | 20% | 30% | 6.0 | 18 | 9 | pierce | 1.5 | 16 | x2 弓船 | 弓兵船 | 海军 |
| 战斗驳船 | War Barge | 80 | 100 | — | 10 | 18 | 4 | 240 | 30% | 40% | 5.5 | 18 | 25 | crush | 3.0 | 22 | x4 建筑 | 攻城船 | 海军 |

#### 2.8.3 Norse 海军

| name_zh | name_en | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 长船 | Longboat | 60 | 60 | — | — | 14 | 3 | 170 | 20% | 30% | 6.0 | 18 | 10 | pierce | 1.5 | 16 | x2 弓船 | 弓兵船 | 海军 |
| 龙头船 | Drakkar | 80 | — | 40 | — | 14 | 3 | 200 | 30% | 30% | 6.5 | 16 | 14 | hack | 2.0 | 2 | x3 弓船 | 撞击近战 | 海军 |

#### 2.8.4 Atlantean 海军

| name_zh | name_en | cost_F | cost_W | cost_G | cost_V | train_time | pop | hp | armor | pierce | speed | vision | damage | atk_type | cooldown | range | bonus_vs | powers/special | tags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 箭船 | Arrow Ship | 50 | 60 | — | — | 14 | 3 | 170 | 20% | 30% | 6.0 | 18 | 10 | pierce | 1.5 | 16 | x2 弓船 | 弓兵船 | 海军 |
| 攻城船 | Siege Ship | 80 | 100 | — | 10 | 18 | 4 | 250 | 30% | 40% | 5.5 | 18 | 28 | crush | 3.0 | 22 | x4 建筑 | 攻城船 | 海军 |

---

### 2.9 神力（God Power）参考表

> Retold 核心改动：所有神力可多次施放，每次消耗 Favor 资源。首次施放通常免费或低价。

| 神力 | 次神 | 时代 | 效果 | Favor 成本 |
|---|---|---|---|---|
| **Restoration** | Athena | Classical | 友军范围治疗 | 25 |
| **Cease Fire** | Hermes | Classical | 全图停火 30 秒 | 20 |
| **Pestilence** | Ares | Classical | 目标区域敌方无法造兵 | 30 |
| **Shifting Sands** | Ptah | Classical | 传送己方单位 | 25 |
| **Eclipse** | Bast | Classical | 敌方范围减速 | 25 |
| **Citadel** | Sekhmet | Classical | TC 要塞化（强化防御） | 30 |
| **Forest Fire** | Freyja | Classical | 烧毁森林伤害敌方经济 | 25 |
| **Healing Spring** | Forseti | Classical | 召唤治疗泉 | 25 |
| **Valor** | Prometheus | Classical | 免费升级若干单位为英雄 | 10 |
| **Carnivora** | Oceanus | Classical | 召唤食肉植物陷阱 | 25 |
| **Underworld Passage** | Apollo | Classical | 建立地下通道传送 | 30 |
| **Earthquake** | Artemis | Heroic | 大范围建筑伤害 | 50 |
| **Bronze** | Dionysus | Heroic | 人类单位护甲大幅提升 | 40 |
| **Locust Swarm** | Hathor | Heroic | 蝗虫群破坏敌方农田 | 30 |
| **Ancestors** | Nephthys | Heroic | 召唤亡灵士兵临时作战 | 35 |
| **Meteor** | Thoth | Heroic | 陨石 AoE | 50 |
| **Frost** | Skadi | Heroic | 冰冻全场敌方单位 | 40 |
| **Flaming Weapons** | Bragi | Heroic | 友军武器点燃（额外伤害） | 30 |
| **Walking Woods** | Njord | Heroic | 召唤树人作战 | 35 |
| **Traitor** | Rheia | Heroic | 招降敌方神话单位 | 35 |
| **Chaos** | Hyperion | Heroic | 敌方单位混乱互攻 | 40 |
| **Lightning Storm** | Hera | Mythic | 闪电风暴持续 AoE | 60 |
| **Plenty** | Hephaestus | Mythic | 召唤 Plenty Vault 产资源 | 50 |
| **Tornado** | Horus | Mythic | 龙卷风移动 AoE | 60 |
| **Son of Osiris** | Osiris | Mythic | Pharaoh 升级为神之子 | 50 |
| **Meteor** | Thoth | Heroic | 陨石 AoE | 50 |
| **Fimbulwinter** | Tyr | Mythic | 狼群侵袭敌方经济 | 60 |
| **Nidhogg** | Hel | Mythic | 召唤尼德霍格飞龙 | 70 |
| **Ragnarok** | Baldr | Mythic | 所有 Gatherer/Dwarf 变 Huskarl | 60 |
| **Tartarian Gate** | Hekate | Mythic | 召唤 Tartarus 之门产怪 | 70 |
| **Implode** | Atlas | Mythic | 内爆 AoE 吸引敌方单位 | 60 |
| **Time Shift** | Kronos | Mythic | 时间转移建筑 | 40 |

---

### 2.10 资源系统速查

| 资源 | Greek | Egyptian | Norse | Atlantean |
|---|---|---|---|---|
| **Food** | 农田/狩猎/捕鱼 | 农田/狩猎/捕鱼 | 农田/狩猎/捕鱼 | 农田/狩猎/捕鱼 |
| **Wood** | 树木 | 树木 | 树木 | 树木 |
| **Gold** | 金矿/贸易 | 金矿/贸易 | 金矿/贸易 | 金矿/贸易 |
| **Favor** | 村民在 Temple 祈祷（≈0.1/s/村民） | Monument 被动产出 | 战斗产生（Hersir 加成） | Town Center 被动产出（缓慢） |

---

## 附录：设计要点速记

1. **希腊是"教科书 RTS"**：完整三角、英雄反神话、Favor 投资需长期规划。
2. **埃及是"被动经济+雇佣兵"**：Monument 免村民祈祷，但 Mercenary 黄金消耗大，Pharaoh Empower 是核心经济加成。
3. **北欧是"移动攻势"**：Ulfsark 建造 + Ox Cart 移动仓库 + 战斗产 Favor，全程前压。
4. **亚特兰蒂斯是"多功能+多次神力"**：Citizen 高效但贵，单位可升 Hero，神力可反复刷。

---

**数据核实建议**：
- 具体数值（HP/伤害/成本）建议在游戏内 F1 查看单位详情，或参考：
  - https://liquipedia.net/ageofempires/Age_of_Mythology
  - https://ageofempires.fandom.com/
- Retold 补丁可能调整数值，本文档以 2024 年 9 月发布版本为基准。
