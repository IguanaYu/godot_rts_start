# 国家的崛起 (Rise of Nations, 2003) + 爱国战争 (Thrones and Patriots, 2004) 单位数据调研

> **版本信息**
> - 调研日期：2026-06-17
> - 数据来源：基于训练数据中的游戏知识（Rise of Nations by Big Huge Games, 2003；Thrones and Patriots 扩展包, 2004）
> - **重要声明**：本次调研期间网络工具受限（WebSearch 返回空、WebFetch/curl/Tavily 被拒），无法实时拉取 Fandom Wiki。以下内容基于模型已有知识整理，**精确数值字段（HP/伤害/冷却/造价/建造时间）部分为近似值或标注 `—`**，定性描述（设计哲学、文明加成、协同组合、克制关系）可信度较高。建议用户后续访问以下 Wiki 交叉验证：
>   - https://riseofnations.fandom.com/
> - 适用版本：Rise of Nations 原版 + Thrones and Patriots 扩展包（共 24 个文明）
> - 资源体系：Food（食物）/ Timber（木材）/ Metal（金属）/ Wealth（财富）/ Knowledge（知识）/ Oil（石油，工业纪元起）

---

## 第一部分：文明设计分析（8 个代表性文明）

RoN 原版含 18 个文明，扩展包新增 6 个（Americans/Dutch/Iroquois/Lakota/Persians/第6个存在争议），合计 24 个。以下选 8 个代表性文明。

### 1. Americans 美国人（扩展包新增）

| 项目 | 内容 |
|---|---|
| **设计哲学** | 经济灵活 + 政府自由切换，通过制度优势实现快速追赶与多变策略 |
| **文明加成** | 无需建造 Senate 即可切换政体；首个政体研究免费；奇迹建造速度 +20%；每城免费获得 1 个 Scholar（学者） |
| **独特单位** | Minuteman（民兵，火药纪元，替代 Musketeer）；Continental Marine（大陆军海军陆战队，启蒙纪元，替代 Rifleman） |
| **核心协同组合** | 1. 免费政体 + 奇迹加速 → 早期奇迹争夺<br>2. Minuteman 快速量产 + Militia 民兵 → 领土防御<br>3. Scholar 流 + Knowledge 经济 → 信息纪元冲刺 |
| **强势时间窗** | 火药纪元（Minuteman 量产）→ 信息纪元（科技经济领先） |

### 2. British 英国人

| 项目 | 内容 |
|---|---|
| **设计哲学** | 商业帝国 + 海上霸权，通过税收与贸易积累财富，长弓兵主导中世纪战场 |
| **文明加成** | 税收收入 +25%（Taxation 科技每次升级额外财富）；商业上限 +25%；舰船建造速度 +33%；每座城市领土范围 +1 |
| **独特单位** | Longbowman（长弓兵，中世纪，替代 Crossbowman，射程更远）；King's Royal Rifleman（皇家来复枪兵，启蒙纪元，替代 Rifleman） |
| **核心协同组合** | 1. Longbowman + Pikeman → 中世纪阵地战（长弓射程压制，长枪反骑）<br>2. 税收 + Trade Route → 财富经济碾压<br>3. Frigate/Ship of the Line 海量舰队 → 制海权<br>4. King's Royal Rifleman + Cannon → 启蒙纪元火力推进 |
| **强势时间窗** | 中世纪（Longbowman 射程优势）→ 启蒙纪元（Royal Rifleman + 海军） |

### 3. Chinese 中国人

| 项目 | 内容 |
|---|---|
| **设计哲学** | 科技领先 + 早期经济爆发，用更低的科研成本抢占纪元先机 |
| **文明加成** | 科学研究成本 -20%；游戏开始时免费获得 1 项科技；草药术（Herbal Lore）治疗效果 +50%；农场食物产出 +10% |
| **独特单位** | Fire Lance（火枪，中世纪，早期火药轻型步兵，比标准 Arquebusier 早 1 个纪元出现）；Heavy Cavalry / Manchu Cavalry（满洲重骑兵，中世纪，替代 Knight） |
| **核心协同组合** | 1. Fire Lance + Pikeman → 中世纪火药推进（提前一纪元获得火药单位）<br>2. 科研折扣 + 免费科技 → 纪元冲刺（Age Rush）<br>3. 满洲骑兵 + Crossbowman → 中世纪标准协同<br>4. 知识经济 + 火药先手 → 火药纪元压制 |
| **强势时间窗** | 古代-古典（科技领先起步）→ 中世纪（Fire Lance 独家火药） |

### 4. Egyptians 埃及人

| 项目 | 内容 |
|---|---|
| **设计哲学** | 农业帝国 + 奇迹竞速，通过农场食物溢出支撑庞大人口，奇迹提供全局加成 |
| **文明加成** | 每座农场 +2 食物产出；奇迹建造成本 -25% 且建造速度 +33%；游戏开始时额外获得 1 座农场 |
| **独特单位** | War Chariot（战车，古代，替代 Chariot，HP 与伤害更高）；Mamluk（马穆鲁克，中世纪，替代 Heavy Cavalry/Knight） |
| **核心协同组合** | 1. War Chariot Rush → 古代快攻（战车碾压同期步兵）<br>2. 奇迹竞速 + 农场经济 → 经济胜利/奇迹胜利<br>3. Mamluk + Archer → 中世纪骑兵+弓兵协同<br>4. Pyramids 奇迹 + 农场 → 食物经济滚雪球 |
| **强势时间窗** | 古代（War Chariot Rush）→ 中世纪（Mamluk + 奇迹积累） |

### 5. French 法国人

| 项目 | 内容 |
|---|---|
| **设计哲学** | 商业与骑士精神的结合，强力重骑兵 + 将军治疗 = 持久战线 |
| **文明加成** | 每次纪元升级免费获得 Civics（公民）科技；贸易路线财富产出 +20%；将军（General）附近单位治疗效果 +100%（或更快治疗）；采集速率 +10% |
| **独特单位** | Chevalier（骑士，中世纪，替代 Knight，HP 更高）；Garde du Corps（近卫骑兵，火药纪元，替代 Heavy Cavalry）；Imperial Guard（帝国卫队，启蒙纪元，替代 Elite Heavy Cavalry） |
| **核心协同组合** | 1. Chevalier + Crossbowman → 中世纪骑兵冲锋+远程掩护<br>2. 将军 + 治疗 + Garde du Corps → 火药纪元持续作战<br>3. 免费公民科技 + 贸易财富 → 扩展经济<br>4. Imperial Guard + Cannon → 启蒙纪元骑兵+炮兵推进 |
| **强势时间窗** | 中世纪（Chevalier）→ 启蒙纪元（Imperial Guard 线持续升级） |

### 6. Germans 德国人

| 项目 | 内容|
|---|---|
| **设计哲学** | 工业军事强国，从中世纪条顿骑士到现代虎式坦克，重装单位贯穿全局 |
| **文明加成** | 每条贸易路线 +5 财富；谷仓（Granary）升级食物产出加成 +25%；潜艇建造成本 -33%；空军单位成本 -10% |
| **独特单位** | Teutonic Knight（条顿骑士，中世纪，替代 Knight，更慢但 HP/伤害更高）；Soldner（雇佣兵，火药纪元，替代 Musketeer）；Tiger Tank（虎式坦克，现代纪元，替代 Tank，HP 与伤害显著更高）；V-2 Rocket（V-2 火箭，现代纪元，独特攻城单位） |
| **核心协同组合** | 1. Teutonic Knight + Pikeman → 中世纪慢速推进堡垒<br>2. Tiger Tank + V-2 Rocket → 现代装甲+导弹攻城<br>3. 潜艇群 + 空军 → 现代/信息纪元海空协同<br>4. 贸易财富 + 谷仓食物 → 双经济支撑军事 |
| **强势时间窗** | 中世纪（条顿骑士）+ 现代-信息纪元（Tiger Tank + V-2 + 空军） |

### 7. Mongols 蒙古人

| 项目 | 内容 |
|---|---|
| **设计哲学** | 游牧骑兵文明，以速度和数量碾压，快攻与劫掠为核心 |
| **文明加成** | 骑兵单位成本 -10%；骑兵移动速度 +15%；每建造 1 座马厩免费获得 2 个 Light Cavalry；骑兵升级免费 |
| **独特单位** | Nomad（游牧骑兵，古代，早期轻骑兵，比标准 Light Cavalry 早 1 个纪元）；Mangudai（蒙兀弓骑，古典纪元，独特骑射单位，不替代标准单位） |
| **核心协同组合** | 1. Nomad Rush → 古代骑兵快攻（对手尚未建马厩）<br>2. Mangudai + Light Cavalry → 古典纪元骑射+轻骑包抄<br>3. 免费骑兵 + 折扣 → 骑兵海数量碾压<br>4. 速度优势 → 骚扰经济线/劫掠商人 |
| **强势时间窗** | 古代-古典（Nomad + Mangudai 快攻窗口）→ 中世纪（骑兵海） |

### 8. Russians 俄国人

| 项目 | 内容 |
|---|---|
| **设计哲学** | 领土纵深 + 消耗战，利用庞大领土与冬季消耗敌人，防守反击型文明 |
| **文明加成** | 国家领土范围 +100%；敌军在俄方领土内的消耗（Attrition）伤害 +100%；在己方领土内单位伤害 +15%；间谍（Spy）免费 |
| **独特单位** | Boyar（波雅尔贵族骑兵，中世纪，替代 Heavy Cavalry/Knight，HP 更高）；Cossack（哥萨克，火药纪元，替代 Light Cavalry）；T-34 Tank（T-34 坦克，工业纪元，替代 Tank，HP 更高且造价略低） |
| **核心协同组合** | 1. 消耗 + 领土 → 防守反击（敌军进入即掉血）<br>2. Boyar + Archer → 中世纪领土防御<br>3. 间谍 + 消耗 → 情报战+领土战<br>4. T-34 海 + Artillery → 工业纪元装甲洪流 |
| **强势时间窗** | 中世纪-火药（领土防御）→ 工业纪元（T-34 装甲优势） |

---

## 第二部分：纪元演进（8 纪元）

RoN 共 8 个纪元，每个纪元需在图书馆（Library）研究对应的 Military/Civic/Commerce/Science 科技来推进。以下列出每纪元解锁的核心单位与科技。

### 1. Ancient Age 古代纪元（起始纪元）

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Slinger（投石兵，轻型步兵）；Hoplite（重装步兵，重型步兵） |
| **弓兵** | Bowman（弓箭手） |
| **骑兵** | Chariot（战车，轻骑兵） |
| **攻城** | —（无攻城单位） |
| **海军** | Fishing Boat（渔船）；Merchant Ship（商船）；Galley（桨帆船） |
| **建筑** | City（城市）；Farm（农场）；Lumber Camp（伐木场）；Mine（矿场）；Market（市场）；Library（图书馆）；Barracks（兵营）；Stable（马厩）；Tower（塔楼）；Temple（神庙） |
| **科技** | Military 1（军事1）；Civic 1（公民1）；Commerce 1（商业1）；Science 1（科学1） |
| **资源** | Food / Timber / Metal / Wealth / Knowledge（5 种基础资源可用） |

### 2. Classical Age 古典纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Javelineer（标枪兵，升级 Slinger）；Phalanx（方阵兵，升级 Hoplite） |
| **弓兵** | Archer（弓兵，升级 Bowman） |
| **骑兵** | Light Cavalry（轻骑兵，升级/替代 Chariot） |
| **攻城** | Catapult（投石机，首个攻城单位） |
| **海军** | Bireme（双列桨船）；Trireme（三列桨船） |
| **建筑** | Siege Factory（攻城工厂）；University（大学，产出 Knowledge）；Senate（元老院，选政体） |
| **科技** | Military 2 / Civic 2 / Commerce 2 / Science 2；可研究政体（Monarchy/Republic 等） |
| **关键解锁** | 政体系统（Senate）；大学与知识经济；攻城武器 |

### 3. Medieval Age 中世纪纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Pikeman（长枪兵，升级 Phalanx，反骑兵增强）；Men-at-Arms（武装步兵，重型步兵升级） |
| **弓兵** | Crossbowman（弩兵，升级 Archer） |
| **骑兵** | Knight（骑士，重型骑兵）；Light Cavalry 升级版 |
| **攻城** | Trebuchet（配重投石机，升级 Catapult） |
| **海军** | Carrack（卡拉克帆船） |
| **建筑** | Castle（城堡，防御工事+领土）；Wonder（奇迹，部分可建） |
| **科技** | Military 3 / Civic 3 / Commerce 3 / Science 3 |
| **关键解锁** | 城堡与领土防御；骑士（重型骑兵）；奇迹系统全面开放；部分文明独特单位（Longbowman/Fire Lance/Teutonic Knight 等） |

### 4. Gunpowder Age 火药纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Arquebusier（火绳枪兵，轻型步兵升级为火药单位）；Elite Pikeman（精英长枪兵） |
| **弓兵** | 弓兵线逐渐被火药步兵取代 |
| **骑兵** | Dragoon（龙骑兵，马上火枪手）；Heavy Cavalry 升级（Cuirassier 前身） |
| **攻城** | Bombard（火炮，升级 Trebuchet，首个火药攻城单位） |
| **海军** | Frigate（护卫舰，风帆战舰） |
| **建筑** | Supply Wagon（补给车，消除敌境消耗伤害） |
| **科技** | Military 4 / Civic 4 / Commerce 4 / Science 4 |
| **关键解锁** | 火药武器全面登场；补给车（在敌方领土作战必需）；Supply Wagon 反消耗机制 |

### 5. Enlightenment Age 启蒙纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Rifleman（来复枪兵，升级 Arquebusier/Musketeer）；Fusilier（燧发枪兵） |
| **骑兵** | Cuirassier（胸甲骑兵，重型骑兵升级）；Hussar（ Hussar 轻骑兵升级） |
| **攻城** | Cannon（加农炮，升级 Bombard） |
| **海军** | Ship of the Line（战列舰，风帆时代巅峰） |
| **科技** | Military 5 / Civic 5 / Commerce 5 / Science 5 |
| **关键解锁** | 来复枪替代火绳枪（射程+精度提升）；战列舰（制海权核心）；线式战术时代 |

### 6. Industrial Age 工业纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Infantry（现代步兵，升级 Rifleman）；Machine Gun（机枪，重型步兵升级） |
| **装甲** | Tank（坦克，首辆装甲单位）；Armored Car（装甲车） |
| **攻城** | Artillery（火炮，升级 Cannon） |
| **海军** | Ironclad（铁甲舰）；Submarine（潜艇） |
| **建筑** | Oil Well（油井，开采石油）；Refinery（炼油厂）；Airfield 预备 |
| **科技** | Military 6 / Civic 6 / Commerce 6 / Science 6 |
| **关键解锁** | 石油资源解锁（第 6 种资源）；坦克与装甲战；潜艇（隐形单位）；工业时代经济转型 |

### 7. Modern Age 现代纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Modern Infantry（现代步兵，升级 Infantry）；Bazooka（巴祖卡火箭筒，反坦克） |
| **装甲** | Main Battle Tank（主战坦克，升级 Tank） |
| **空军** | Fighter（战斗机）；Bomber（轰炸机） |
| **海军** | Destroyer（驱逐舰）；Cruiser（巡洋舰）；Battleship（战列舰）；Aircraft Carrier（航空母舰） |
| **攻城** | Howitzer（榴弹炮，升级 Artillery） |
| **科技** | Military 7 / Civic 7 / Commerce 7 / Science 7 |
| **关键解锁** | 空军（制空权）；航空母舰（海上空中力量投射）；巴祖卡（反装甲）；全面机械化战争 |

### 8. Information Age 信息纪元

| 类别 | 解锁内容 |
|---|---|
| **步兵** | Assault Infantry（突击步兵，升级 Modern Infantry） |
| **装甲** | Advanced Main Battle Tank（先进主战坦克） |
| **空军** | Jet Fighter（喷气战斗机）；Strategic Bomber（战略轰炸机）；Helicopter（直升机） |
| **海军** | Missile Cruiser（导弹巡洋舰）；Nuclear Submarine（核潜艇） |
| **导弹** | Nuclear Missile（核导弹）；Cruise Missile（巡航导弹） |
| **科技** | Military 8 / Civic 8 / Commerce 8 / Science 8（满级） |
| **关键解锁** | 核武器（大规模杀伤）；导弹系统；直升机（垂直起降空中支援）；信息战与精确打击 |

---

## 第三部分：单位数据表

### 资源缩写

| 缩写 | 资源 | 说明 |
|---|---|---|
| F | Food 食物 | 农场/渔民/谷仓 |
| T | Timber 木材 | 伐木场/锯木厂 |
| M | Metal 金属 | 矿场 |
| W | Wealth 财富 | 贸易路线/税收/神庙/市场 |
| K | Knowledge 知识 | 大学/学者 |
| O | Oil 石油 | 油井（工业纪元+） |

### 伤害类型说明

| 类型 | 说明 |
|---|---|
| Slashing | 斩击（近战步兵/骑兵） |
| Piercing | 穿刺（弓箭/弩） |
| Crushing | 粉碎（攻城武器） |
| Fire | 火药（火绳枪/来复枪/火炮） |
| Explosive | 爆炸（坦克炮/炸弹/导弹） |

---

### A. 步兵线（Barracks 兵营）

#### A1. 轻型步兵线（Light Infantry，远程，反重骑兵）

| 字段 | Slinger 投石兵 | Javelineer 标枪兵 | Arquebusier 火绳枪兵 | Musketeer 火枪手 | Rifleman 来复枪兵 | Infantry 步兵 | Modern Infantry 现代步兵 | Assault Infantry 突击步兵 |
|---|---|---|---|---|---|---|---|---|
| name_zh | 投石兵 | 标枪兵 | 火绳枪兵 | 火枪手 | 来复枪兵 | 步兵 | 现代步兵 | 突击步兵 |
| name_en | Slinger | Javelineer | Arquebusier | Musketeer | Rifleman | Infantry | Modern Infantry | Assault Infantry |
| line | 轻型步兵 | 轻型步兵 | 轻型步兵(火药) | 轻型步兵(火药) | 轻型步兵(火药) | 轻型步兵(现代) | 轻型步兵(现代) | 轻型步兵(现代) |
| age | 古代 | 古典 | 火药 | 火药/启蒙 | 启蒙 | 工业 | 现代 | 信息 |
| built_from | Barracks | Barracks | Barracks | Barracks | Barracks | Barracks | Barracks | Barracks |
| cost_F | 40 | 50 | 50 | 50 | 60 | 60 | 60 | 70 |
| cost_T | 20 | 30 | 40 | 40 | 50 | 40 | 30 | 30 |
| cost_M | — | — | 20 | 30 | 30 | 20 | 20 | 30 |
| cost_O | — | — | — | — | — | — | 10 | 10 |
| cost_W | — | — | — | — | — | — | — | — |
| cost_K | — | — | — | — | — | — | — | — |
| build_time | ~13s | ~15s | ~17s | ~17s | ~18s | ~16s | ~16s | ~18s |
| hp | 74 | 92 | 120 | 135 | 155 | 175 | 200 | 230 |
| armor | 轻型 | 轻型 | 轻型 | 轻型 | 轻型 | 轻型 | 轻型 | 轻型 |
| pierce_armor | 低 | 低 | 低 | 中 | 中 | 中 | 高 | 高 |
| tags | 轻步兵,远程 | 轻步兵,远程 | 轻步兵,火药 | 轻步兵,火药 | 轻步兵,火药 | 轻步兵,现代 | 轻步兵,现代 | 轻步兵,现代 |
| speed | 32 | 32 | 32 | 32 | 32 | 34 | 34 | 34 |
| fly | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 |
| vision | 8 | 8 | 9 | 9 | 10 | 10 | 10 | 11 |
| damage | 8 | 10 | 14 | 16 | 20 | 24 | 28 | 32 |
| atk_type | 穿刺 | 穿刺 | 火药 | 火药 | 火药 | 火药 | 火药 | 火药 |
| cooldown | ~1.5s | ~1.5s | ~2.0s | ~2.0s | ~1.8s | ~1.5s | ~1.3s | ~1.2s |
| range | 6 | 7 | 8 | 9 | 10 | 10 | 10 | 10 |
| target | 地面 | 地面 | 地面 | 地面 | 地面 | 地面+空 | 地面+空 | 地面+空 |
| splash | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 |
| bonus_vs | 重骑兵 | 重骑兵 | 重骑兵 | 重骑兵 | 重骑兵 | — | — | — |
| upgrades_from | — | Slinger | Javelineer | Arquebusier | Musketeer | Rifleman | Infantry | Modern Infantry |
| upgrades_to | Javelineer | Arquebusier | Musketeer | Rifleman | Infantry | Modern Infantry | Assault Infantry | — |

#### A2. 重型步兵线（Heavy Infantry，近战，反骑兵）

| 字段 | Hoplite 重装步兵 | Phalanx 方阵兵 | Pikeman 长枪兵 | Elite Pikeman 精英长枪兵 | Machine Gun 机枪手 | Bazooka 巴祖卡 | Anti-Tank Missile 反坦克导弹 |
|---|---|---|---|---|---|---|---|
| name_zh | 重装步兵 | 方阵兵 | 长枪兵 | 精英长枪兵 | 机枪手 | 巴祖卡 | 反坦克导弹 |
| name_en | Hoplite | Phalanx | Pikeman | Elite Pikeman | Machine Gun | Bazooka | Anti-Tank Missile |
| line | 重型步兵 | 重型步兵 | 重型步兵 | 重型步兵 | 重型步兵(现代) | 重型步兵(反装甲) | 重型步兵(反装甲) |
| age | 古代 | 古典 | 中世纪 | 火药 | 工业 | 现代 | 信息 |
| built_from | Barracks | Barracks | Barracks | Barracks | Barracks | Barracks | Barracks |
| cost_F | 50 | 60 | 50 | 50 | 60 | 60 | 60 |
| cost_T | 30 | 40 | 40 | 40 | 40 | 30 | 20 |
| cost_M | — | — | 20 | 30 | 30 | 40 | 50 |
| cost_O | — | — | — | — | — | 20 | 20 |
| cost_W | — | — | — | — | — | — | — |
| cost_K | — | — | — | — | — | — | — |
| build_time | ~15s | ~16s | ~16s | ~17s | ~18s | ~18s | ~20s |
| hp | 120 | 150 | 180 | 200 | 170 | 160 | 150 |
| armor | 重型 | 重型 | 重型 | 重型 | 重型 | 中型 | 中型 |
| pierce_armor | 高 | 高 | 高 | 高 | 中 | 中 | 中 |
| tags | 重步兵,近战 | 重步兵,近战 | 重步兵,近战,反骑 | 重步兵,近战,反骑 | 重步兵,现代 | 重步兵,反装甲 | 重步兵,反装甲 |
| speed | 28 | 28 | 28 | 28 | 28 | 30 | 30 |
| fly | 否 | 否 | 否 | 否 | 否 | 否 | 否 |
| vision | 6 | 6 | 6 | 7 | 8 | 8 | 9 |
| damage | 12 | 15 | 18 | 20 | 22 | 30 | 40 |
| atk_type | 斩击 | 斩击 | 斩击 | 斩击 | 穿刺 | 爆炸 | 爆炸 |
| cooldown | ~1.2s | ~1.2s | ~1.2s | ~1.2s | ~0.5s | ~2.5s | ~2.0s |
| range | 1(近战) | 1(近战) | 1.5(近战) | 1.5(近战) | 7 | 8 | 9 |
| target | 地面 | 地面 | 地面 | 地面 | 地面+空 | 地面 | 地面 |
| splash | 否 | 否 | 否 | 否 | 否 | 小 | 小 |
| bonus_vs | 骑兵(大) | 骑兵(大) | 骑兵(极大) | 骑兵(极大) | 轻步兵 | 装甲(极大) | 装甲(极大) |
| upgrades_from | — | Hoplite | Phalanx | Pikeman | Elite Pikeman | — | Bazooka |
| upgrades_to | Phalanx | Pikeman | Elite Pikeman | Machine Gun | — | Anti-Tank Missile | — |

---

### B. 弓兵线（Barracks 兵营，远程，反轻步兵）

| 字段 | Bowman 弓箭手 | Archer 弓兵 | Crossbowman 弩兵 | Elite Crossbowman 精英弩兵 |
|---|---|---|---|---|
| name_zh | 弓箭手 | 弓兵 | 弩兵 | 精英弩兵 |
| name_en | Bowman | Archer | Crossbowman | Elite Crossbowman |
| line | 远程步兵(弓) | 远程步兵(弓) | 远程步兵(弩) | 远程步兵(弩) |
| age | 古代 | 古典 | 中世纪 | 火药 |
| built_from | Barracks | Barracks | Barracks | Barracks |
| cost_F | 30 | 40 | 50 | 50 |
| cost_T | 40 | 50 | 60 | 60 |
| cost_M | — | — | — | 10 |
| cost_O | — | — | — | — |
| cost_W | — | — | — | — |
| cost_K | — | — | — | — |
| build_time | ~13s | ~14s | ~16s | ~17s |
| hp | 70 | 80 | 100 | 115 |
| armor | 轻型 | 轻型 | 轻型 | 轻型 |
| pierce_armor | 低 | 低 | 低 | 低 |
| tags | 远程,弓 | 远程,弓 | 远程,弩 | 远程,弩 |
| speed | 32 | 32 | 32 | 32 |
| fly | 否 | 否 | 否 | 否 |
| vision | 8 | 9 | 9 | 10 |
| damage | 10 | 12 | 15 | 18 |
| atk_type | 穿刺 | 穿刺 | 穿刺 | 穿刺 |
| cooldown | ~1.5s | ~1.4s | ~1.8s | ~1.6s |
| range | 7 | 8 | 8 | 9 |
| target | 地面 | 地面 | 地面 | 地面 |
| splash | 否 | 否 | 否 | 否 |
| bonus_vs | 轻步兵 | 轻步兵 | 轻步兵 | 轻步兵 |
| upgrades_from | — | Bowman | Archer | Crossbowman |
| upgrades_to | Archer | Crossbowman | Elite Crossbowman | —(被火药取代) |

> **注**：火药纪元后弓兵线被轻型步兵火药线（Arquebusier → Musketeer → Rifleman）取代，不再继续升级。

---

### C. 骑兵线（Stable 马厩）

#### C1. 轻骑兵线（Light Cavalry，快速，反弓兵/劫掠）

| 字段 | Chariot 战车 | Light Cavalry 轻骑兵 | Light Cavalry 升级版 | Dragoon 龙骑兵 | Armored Car 装甲车 |
|---|---|---|---|---|---|
| name_zh | 战车 | 轻骑兵 | 轻骑兵(升级) | 龙骑兵 | 装甲车 |
| name_en | Chariot | Light Cavalry | Light Cavalry (upgraded) | Dragoon | Armored Car |
| line | 轻骑兵 | 轻骑兵 | 轻骑兵 | 轻骑兵(火药) | 轻骑兵(现代) |
| age | 古代 | 古典 | 中世纪/火药 | 火药 | 工业 |
| built_from | Stable | Stable | Stable | Stable | Factory |
| cost_F | 50 | 50 | 60 | 50 | — |
| cost_T | 40 | 50 | 50 | 40 | — |
| cost_M | — | — | 10 | 30 | 50 |
| cost_O | — | — | — | — | 30 |
| cost_W | — | — | — | 20 | — |
| cost_K | — | — | — | — | — |
| build_time | ~16s | ~16s | ~17s | ~17s | ~18s |
| hp | 100 | 120 | 140 | 130 | 180 |
| armor | 轻型 | 轻型 | 轻型 | 中型 | 中型 |
| pierce_armor | 低 | 低 | 中 | 中 | 高 |
| tags | 轻骑,劫掠 | 轻骑,劫掠 | 轻骑,劫掠 | 轻骑,火药 | 轻骑,装甲,侦察 |
| speed | 40 | 42 | 42 | 40 | 38 |
| fly | 否 | 否 | 否 | 否 | 否 |
| vision | 8 | 8 | 9 | 9 | 10 |
| damage | 10 | 12 | 14 | 16 | 18 |
| atk_type | 斩击 | 斩击 | 斩击 | 火药 | 穿刺 |
| cooldown | ~1.2s | ~1.2s | ~1.2s | ~1.8s | ~1.0s |
| range | 1(近战) | 1(近战) | 1(近战) | 7 | 6 |
| target | 地面 | 地面 | 地面 | 地面 | 地面+空 |
| splash | 否 | 否 | 否 | 否 | 否 |
| bonus_vs | 弓兵,市民 | 弓兵,市民 | 弓兵,市民 | 弓兵 | — |
| upgrades_from | — | Chariot | Light Cavalry | Light Cavalry | Dragoon |
| upgrades_to | Light Cavalry | (升级版) | Dragoon | Armored Car | — |

#### C2. 重骑兵线（Heavy Cavalry，冲锋，反步兵）

| 字段 | Knight 骑士 | Heavy Cavalry 重骑兵 | Cuirassier 胸甲骑兵 | Tank 坦克 | Main Battle Tank 主战坦克 | Advanced MBT 先进主战坦克 |
|---|---|---|---|---|---|---|
| name_zh | 骑士 | 重骑兵 | 胸甲骑兵 | 坦克 | 主战坦克 | 先进主战坦克 |
| name_en | Knight | Heavy Cavalry | Cuirassier | Tank | Main Battle Tank | Advanced MBT |
| line | 重骑兵 | 重骑兵 | 重骑兵(火药) | 重骑兵(装甲) | 装甲 | 装甲 |
| age | 中世纪 | 火药 | 启蒙 | 工业 | 现代 | 信息 |
| built_from | Stable | Stable | Stable | Factory | Factory | Factory |
| cost_F | 60 | 60 | 60 | — | — | — |
| cost_T | 60 | 50 | 40 | — | — | — |
| cost_M | — | 20 | 40 | 60 | 80 | 90 |
| cost_O | — | — | — | 60 | 80 | 80 |
| cost_W | — | — | 20 | — | — | — |
| cost_K | — | — | — | — | — | — |
| build_time | ~20s | ~20s | ~21s | ~22s | ~24s | ~26s |
| hp | 200 | 220 | 250 | 300 | 400 | 480 |
| armor | 重型 | 重型 | 重型 | 重型(装甲) | 重型(装甲) | 重型(装甲) |
| pierce_armor | 中 | 中 | 高 | 高 | 极高 | 极高 |
| tags | 重骑,冲锋 | 重骑,冲锋 | 重骑,火药 | 装甲,反步兵 | 装甲,主战 | 装甲,主战 |
| speed | 38 | 38 | 36 | 30 | 32 | 34 |
| fly | 否 | 否 | 否 | 否 | 否 | 否 |
| vision | 8 | 8 | 9 | 9 | 10 | 10 |
| damage | 20 | 22 | 25 | 30 | 35 | 42 |
| atk_type | 斩击 | 斩击 | 火药 | 爆炸 | 爆炸 | 爆炸 |
| cooldown | ~1.2s | ~1.2s | ~1.5s | ~2.0s | ~1.8s | ~1.5s |
| range | 1(近战) | 1(近战) | 1(近战) | 8 | 10 | 10 |
| target | 地面 | 地面 | 地面 | 地面 | 地面 | 地面 |
| splash | 否 | 否 | 否 | 小 | 小 | 中 |
| bonus_vs | 步兵(中) | 步兵(中) | 步兵(中) | 步兵(大) | 步兵(大),建筑 | 步兵(大),建筑 |
| upgrades_from | — | Knight | Heavy Cavalry | Cuirassier | Tank | Main Battle Tank |
| upgrades_to | Heavy Cavalry | Cuirassier | Tank | Main Battle Tank | Advanced MBT | — |

> **注**：重骑兵线在工业纪元演变为坦克，是 RoN 中跨时代最长的升级链之一（中世纪 → 信息）。

---

### D. 攻城线（Siege Factory 攻城工厂）

| 字段 | Catapult 投石机 | Trebuchet 配重投石机 | Bombard 火炮 | Cannon 加农炮 | Artillery 火炮 | Howitzer 榴弹炮 |
|---|---|---|---|---|---|---|
| name_zh | 投石机 | 配重投石机 | 火炮 | 加农炮 | 火炮(现代) | 榴弹炮 |
| name_en | Catapult | Trebuchet | Bombard | Cannon | Artillery | Howitzer |
| line | 攻城 | 攻城 | 攻城(火药) | 攻城(火药) | 攻城(现代) | 攻城(现代) |
| age | 古典 | 中世纪 | 火药 | 启蒙 | 工业 | 现代 |
| built_from | Siege Factory | Siege Factory | Siege Factory | Siege Factory | Siege Factory | Siege Factory |
| cost_F | — | — | — | — | — | — |
| cost_T | 40 | 50 | 50 | 50 | 40 | 40 |
| cost_M | 40 | 50 | 70 | 80 | 80 | 90 |
| cost_O | — | — | — | — | 20 | 30 |
| cost_W | — | — | 30 | 40 | — | — |
| cost_K | — | — | — | — | — | — |
| build_time | ~20s | ~22s | ~24s | ~25s | ~26s | ~28s |
| hp | 60 | 80 | 80 | 100 | 120 | 140 |
| armor | 无 | 无 | 无 | 轻型 | 中型 | 中型 |
| pierce_armor | 低 | 低 | 低 | 中 | 中 | 高 |
| tags | 攻城,机械 | 攻城,机械 | 攻城,火药 | 攻城,火药 | 攻城,现代 | 攻城,现代 |
| speed | 20 | 18 | 18 | 18 | 22 | 24 |
| fly | 否 | 否 | 否 | 否 | 否 | 否 |
| vision | 10 | 10 | 11 | 12 | 12 | 12 |
| damage | 30 | 40 | 50 | 60 | 70 | 85 |
| atk_type | 粉碎 | 粉碎 | 火药 | 火药 | 爆炸 | 爆炸 |
| cooldown | ~3.0s | ~3.5s | ~3.0s | ~2.5s | ~2.5s | ~2.0s |
| range | 10 | 12 | 12 | 14 | 14 | 15 |
| target | 地面,建筑 | 地面,建筑 | 地面,建筑 | 地面,建筑 | 地面,建筑 | 地面,建筑 |
| splash | 中 | 中 | 大 | 大 | 大 | 大 |
| bonus_vs | 建筑(极大) | 建筑(极大) | 建筑(极大) | 建筑(极大) | 建筑(极大) | 建筑(极大) |
| upgrades_from | — | Catapult | Trebuchet | Bombard | Cannon | Artillery |
| upgrades_to | Trebuchet | Bombard | Cannon | Artillery | Howitzer | — |

---

### E. 火药线汇总（Gunpowder，跨兵种）

> 火药纪元起，弓兵线被火药步兵取代，攻城武器转为火药类型，骑兵出现龙骑兵。此节为跨兵种的火药单位索引。

| 单位 | 兵营/马厩/攻城工厂 | 纪元 | 说明 |
|---|---|---|---|
| Arquebusier 火绳枪兵 | Barracks | 火药 | 首个火药步兵，替代弓兵线 |
| Musketeer 火枪手 | Barracks | 火药-启蒙 | 火绳枪兵升级 |
| Rifleman 来复枪兵 | Barracks | 启蒙 | 火药步兵最终形态 |
| Dragoon 龙骑兵 | Stable | 火药 | 马上火枪手，远程骑兵 |
| Bombard 火炮 | Siege Factory | 火药 | 首个火药攻城单位 |
| Cannon 加农炮 | Siege Factory | 启蒙 | 火药攻城升级 |
| Supply Wagon 补给车 | Siege Factory | 火药 | 非战斗单位，消除敌境消耗 |

#### 补给车（Supply Wagon）

| 字段 | 值 |
|---|---|
| name_zh | 补给车 |
| name_en | Supply Wagon |
| line | 后勤支援 |
| age | 火药-信息（全程可用） |
| built_from | Siege Factory |
| cost_F | — |
| cost_T | 60 |
| cost_M | 40 |
| cost_O | — |
| cost_W | 40 |
| cost_K | — |
| build_time | ~20s |
| hp | 150 |
| armor | 中型 |
| pierce_armor | 中 |
| tags | 非战斗,后勤,反消耗 |
| speed | 30 |
| fly | 否 |
| vision | 8 |
| damage | 0 |
| atk_type | — |
| cooldown | — |
| range | — |
| target | — |
| splash | — |
| bonus_vs | — |
| upgrades_from | — |
| upgrades_to | —（属性随纪元微调） |

> **关键机制**：补给车范围内的友军在敌方领土内不受到 Attrition（消耗）伤害。对抗俄国人等消耗文明时必需。

---

### F. 现代装甲线（Factory 工厂，工业纪元+）

#### F1. 主战装甲（继承重骑兵线，见 C2 表）

Tank / Main Battle Tank / Advanced MBT 已在 C2 重骑兵线表中列出。

#### F2. 反装甲/支援车辆

| 字段 | Anti-Aircraft Vehicle 防空车 | APC 装甲运兵车 |
|---|---|---|
| name_zh | 防空车 | 装甲运兵车 |
| name_en | Anti-Aircraft Vehicle | APC |
| line | 防空装甲 | 运输/支援 |
| age | 现代 | 现代 |
| built_from | Factory | Factory |
| cost_F | — | — |
| cost_T | — | — |
| cost_M | 50 | 40 |
| cost_O | 40 | 30 |
| cost_W | — | — |
| cost_K | — | — |
| build_time | ~18s | ~18s |
| hp | 160 | 200 |
| armor | 中型 | 中型 |
| pierce_armor | 高 | 高 |
| tags | 装甲,防空 | 装甲,运输 |
| speed | 34 | 32 |
| fly | 否 | 否 |
| vision | 10 | 8 |
| damage | 18 | 8 |
| atk_type | 爆炸 | 穿刺 |
| cooldown | ~1.0s | ~1.0s |
| range | 8(对空) | 5(对地) |
| target | 空中 | 地面 |
| splash | 小 | 否 |
| bonus_vs | 空军(极大) | — |
| upgrades_from | — | — |
| upgrades_to | — | — |

---

### G. 空军线（Airfield 机场，现代纪元+）

| 字段 | Fighter 战斗机 | Jet Fighter 喷气战斗机 | Bomber 轰炸机 | Strategic Bomber 战略轰炸机 | Helicopter 直升机 |
|---|---|---|---|---|---|
| name_zh | 战斗机 | 喷气战斗机 | 轰炸机 | 战略轰炸机 | 直升机 |
| name_en | Fighter | Jet Fighter | Bomber | Strategic Bomber | Helicopter |
| line | 空军-制空 | 空军-制空 | 空军-轰炸 | 空军-轰炸 | 空军-多用途 |
| age | 现代 | 信息 | 现代 | 信息 | 信息 |
| built_from | Airfield | Airfield | Airfield | Airfield | Airfield |
| cost_F | — | — | — | — | — |
| cost_T | — | — | — | — | — |
| cost_M | 60 | 70 | 70 | 80 | 50 |
| cost_O | 60 | 70 | 70 | 80 | 50 |
| cost_W | 40 | 50 | 60 | 70 | 40 |
| cost_K | — | — | — | — | — |
| build_time | ~15s | ~17s | ~20s | ~25s | ~18s |
| hp | 100 | 130 | 150 | 200 | 120 |
| armor | 轻型 | 轻型 | 中型 | 中型 | 中型 |
| pierce_armor | 低 | 中 | 低 | 中 | 中 |
| tags | 空军,制空,对空 | 空军,制空,对空 | 空军,轰炸,对地 | 空军,轰炸,对地 | 空军,多用途,对地+对空 |
| speed | 80 | 90 | 60 | 70 | 50 |
| fly | 是 | 是 | 是 | 是 | 是 |
| vision | 12 | 14 | 10 | 12 | 10 |
| damage | 20 | 28 | 40 | 55 | 18 |
| atk_type | 爆炸 | 爆炸 | 爆炸 | 爆炸 | 穿刺/爆炸 |
| cooldown | ~1.0s | ~0.8s | ~3.0s | ~3.5s | ~1.2s |
| range | 8(空对空) | 10(空对空) | 6(空对地) | 8(空对地) | 7(空对地) |
| target | 空中 | 空中(+地面) | 地面 | 地面 | 地面+空中 |
| splash | 否 | 否 | 大 | 大 | 小 |
| bonus_vs | 空军(大) | 空军(大) | 建筑(大),步兵(中) | 建筑(极大) | 装甲(中) |
| upgrades_from | — | Fighter | — | Bomber | — |
| upgrades_to | Jet Fighter | — | Strategic Bomber | — | — |

> **空军基地机制**：飞机从 Airfield 起飞执行任务后需返回补给，非永久驻空。制空权（Air Supremacy）极大影响地面战。

---

### H. 海军线（Dock 码头/造船厂）

#### H1. 经济船只

| 字段 | Fishing Boat 渔船 | Merchant Ship 商船 |
|---|---|---|
| name_zh | 渔船 | 商船 |
| name_en | Fishing Boat | Merchant Ship |
| line | 经济-捕鱼 | 经济-贸易 |
| age | 古代 | 古代 |
| built_from | Dock | Dock |
| cost_F | — | — |
| cost_T | 30 | 40 |
| cost_M | — | — |
| cost_W | — | — |
| cost_K | — | — |
| build_time | ~10s | ~12s |
| hp | 50 | 60 |
| armor | 无 | 无 |
| tags | 经济,捕鱼 | 经济,贸易 |
| speed | 30 | 28 |
| fly | 否 | 否 |
| vision | 6 | 6 |
| damage | 0 | 0 |
| upgrades_from | — | — |
| upgrades_to | —(随纪元微调) | —(随纪元微调) |

#### H2. 战斗舰艇线

| 字段 | Galley 桨帆船 | Bireme 双列桨船 | Trireme 三列桨船 | Carrack 卡拉克帆船 | Frigate 护卫舰 | Ship of the Line 战列舰 |
|---|---|---|---|---|---|---|
| name_zh | 桨帆船 | 双列桨船 | 三列桨船 | 卡拉克帆船 | 护卫舰 | 战列舰 |
| name_en | Galley | Bireme | Trireme | Carrack | Frigate | Ship of the Line |
| line | 海军(桨船) | 海军(桨船) | 海军(桨船) | 海军(帆船) | 海军(帆船) | 海军(帆船) |
| age | 古代 | 古典 | 古典/中世纪 | 中世纪 | 火药 | 启蒙 |
| built_from | Dock | Dock | Dock | Dock | Dock | Dock |
| cost_F | 40 | 50 | 50 | 50 | 50 | 60 |
| cost_T | 40 | 50 | 50 | 60 | 60 | 60 |
| cost_M | — | — | 10 | 20 | 30 | 40 |
| cost_W | — | — | — | 20 | 30 | 40 |
| build_time | ~18s | ~20s | ~20s | ~22s | ~24s | ~26s |
| hp | 120 | 150 | 180 | 220 | 280 | 380 |
| armor | 轻型 | 轻型 | 轻型 | 中型 | 中型 | 重型 |
| tags | 海军,近战 | 海军,近战 | 海军,近战/远程 | 海军,远程 | 海军,远程 | 海军,远程 |
| speed | 30 | 30 | 32 | 28 | 28 | 26 |
| fly | 否 | 否 | 否 | 否 | 否 | 否 |
| vision | 8 | 8 | 9 | 10 | 10 | 12 |
| damage | 12 | 15 | 18 | 22 | 28 | 40 |
| atk_type | 斩击 | 斩击 | 穿刺 | 穿刺 | 火药 | 火药 |
| cooldown | ~1.5s | ~1.5s | ~2.0s | ~2.5s | ~2.5s | ~3.0s |
| range | 1(近战) | 1(近战) | 6 | 8 | 10 | 12 |
| target | 海面 | 海面 | 海面 | 海面 | 海面 | 海面+岸 |
| splash | 否 | 否 | 否 | 否 | 小 | 中 |
| bonus_vs | — | — | — | — | 建筑(中) | 建筑(大) |
| upgrades_from | — | Galley | Bireme | Trireme | Carrack | Frigate |
| upgrades_to | Bireme | Trireme | Carrack | Frigate | Ship of the Line | Ironclad |

#### H3. 现代/信息纪元舰艇

| 字段 | Ironclad 铁甲舰 | Destroyer 驱逐舰 | Cruiser 巡洋舰 | Battleship 战列舰 | Aircraft Carrier 航空母舰 | Submarine 潜艇 | Missile Cruiser 导弹巡洋舰 |
|---|---|---|---|---|---|---|---|
| name_zh | 铁甲舰 | 驱逐舰 | 巡洋舰 | 战列舰 | 航空母舰 | 潜艇 | 导弹巡洋舰 |
| name_en | Ironclad | Destroyer | Cruiser | Battleship | Aircraft Carrier | Submarine | Missile Cruiser |
| line | 海军(蒸汽) | 海军(现代) | 海军(现代) | 海军(现代) | 海军(航母) | 海军(隐形) | 海军(导弹) |
| age | 工业 | 现代 | 现代 | 现代 | 现代 | 工业/现代 | 信息 |
| built_from | Dock | Dock | Dock | Dock | Dock | Dock | Dock |
| cost_F | — | — | — | — | — | — | — |
| cost_T | 60 | 40 | 50 | 60 | 80 | 40 | 50 |
| cost_M | 60 | 60 | 70 | 80 | 60 | 50 | 70 |
| cost_O | — | 40 | 50 | 60 | 40 | 30 | 40 |
| cost_W | 40 | 30 | 40 | 50 | 60 | 30 | 40 |
| build_time | ~28s | ~24s | ~28s | ~35s | ~40s | ~25s | ~30s |
| hp | 400 | 300 | 400 | 600 | 500 | 200 | 450 |
| armor | 重型 | 中型 | 重型 | 极重 | 重型 | 轻型(隐形) | 重型 |
| pierce_armor | 高 | 高 | 高 | 极高 | 高 | 低 | 高 |
| tags | 海军,蒸汽 | 海军,反潜 | 海军,防空 | 海军,炮击 | 海军,航空 | 海军,隐形,反舰 | 海军,导弹 |
| speed | 22 | 30 | 28 | 24 | 22 | 26 | 28 |
| fly | 否 | 否 | 否 | 否 | 否 | 否 | 否 |
| vision | 10 | 10 | 12 | 12 | 10 | 8(声呐) | 14 |
| damage | 45 | 30 | 25 | 55 | 0(搭载飞机) | 40(鱼雷) | 50(导弹) |
| atk_type | 火药 | 爆炸 | 爆炸 | 爆炸 | — | 爆炸 | 爆炸 |
| cooldown | ~3.0s | ~1.5s | ~1.0s | ~4.0s | — | ~3.0s | ~3.5s |
| range | 12 | 10 | 10(对空) | 16 | — | 6(鱼雷) | 14(导弹) |
| target | 海面+岸 | 海面+水下+空 | 海面+空 | 海面+岸+空 | (生产飞机) | 海面(反舰) | 海面+岸+空 |
| splash | 中 | 小 | 否 | 大 | — | 小 | 大 |
| bonus_vs | 建筑(大) | 潜艇(大) | 空军(大) | 建筑(极大),海军(大) | — | 海军(大) | 建筑(极大) |
| upgrades_from | Ship of the Line | — | — | — | — | — | Cruiser |
| upgrades_to | Destroyer/Battleship | — | Missile Cruiser | — | — | — | — |

> **潜艇机制**：潜艇在非攻击状态下隐形，仅 Destroyer（驱逐舰）和部分空中单位可探测。适合偷袭大型舰艇。

---

### I. 特殊/支援单位

#### I1. 将军与间谍

| 字段 | General 将军 | Spy 间谍 |
|---|---|---|
| name_zh | 将军 | 间谍 |
| name_en | General | Spy |
| line | 指挥官 | 特种 |
| age | 古典+（建 Senate 后） | 火药+ |
| built_from | Fort/Castle | Fort/Castle |
| cost_F | 100 | 80 |
| cost_T | — | — |
| cost_M | 50 | 20 |
| cost_W | 100 | 100 |
| cost_K | — | 50 |
| build_time | ~30s | ~25s |
| hp | 200 | 120 |
| armor | 中型 | 轻型(隐形) |
| tags | 指挥,光环,治疗 | 隐形,贿赂,情报 |
| speed | 30 | 34 |
| fly | 否 | 否 |
| vision | 10 | 12 |
| damage | 5 | 0 |
| atk_type | 斩击 | — |
| cooldown | — | — |
| range | 1 | — |
| target | 地面 | — |
| splash | — | — |
| bonus_vs | — | — |
| upgrades_from | — | — |
| upgrades_to | —(随纪元微调) | —(随纪元微调) |

**将军能力**：
- Entrench（挖壕）：附近单位获得防御加成
- Ambush（伏击）：隐藏附近单位
- Forced March（急行军）：附近单位移速提升
- 治疗光环：附近单位缓慢回血（French 加成更高）

**间谍能力**：
- Bribe（贿赂）：花费财富策反敌方单位
- Surveillance（监视）：提供目标区域视野
- 隐形：非行动时不可见，仅 Scout/Fort/Tower 可探测

#### I2. 市民与学者（非战斗经济单位）

| 字段 | Citizen 市民 | Scholar 学者 |
|---|---|---|
| name_zh | 市民 | 学者 |
| name_en | Citizen | Scholar |
| line | 经济-建造/采集 | 经济-知识 |
| age | 古代 | 古典+ |
| built_from | City | University |
| cost_F | 10(随人口递增) | 50 |
| cost_T | 10(随人口递增) | — |
| cost_W | — | — |
| cost_K | — | — |
| build_time | ~5s | ~10s |
| hp | 30 | 30 |
| armor | 无 | 无 |
| tags | 经济,建造,采集 | 经济,知识 |
| speed | 28 | 28 |
| fly | 否 | 否 |
| vision | 5 | 5 |
| damage | 0 | 0 |
| upgrades_from | — | — |
| upgrades_to | —(随纪元微调效率) | —(随纪元微调效率) |

#### I3. 民兵（Militia，临时防御单位）

| 字段 | Militia 民兵 | Minuteman 民兵（升级版） |
|---|---|---|
| name_zh | 民兵 | 快速民兵 |
| name_en | Militia | Minuteman |
| line | 临时防御 | 临时防御 |
| age | 古典+ | 火药+ |
| built_from | City（市民转化） | City（市民转化） |
| cost_F | —(消耗市民) | —(消耗市民) |
| build_time | 即时 | 即时 |
| hp | 60 | 80 |
| armor | 轻型 | 轻型 |
| tags | 临时,防御,有持续时间 | 临时,防御,有持续时间 |
| speed | 30 | 30 |
| damage | 8 | 12 |
| atk_type | 穿刺 | 火药 |
| range | 5 | 6 |
| upgrades_from | — | — |
| upgrades_to | — | — |

> **民兵机制**：市民可临时转化为民兵参与城市防御，一段时间后自动变回市民。是美国文明的特色强化单位。

---

### J. 文明独特单位汇总

以下列出 8 个代表性文明的独特单位及其替代关系。

| 文明 | 独特单位 | 纪元 | 替代单位 | 特殊属性 |
|---|---|---|---|---|
| **Americans** | Minuteman | 火药 | Musketeer | 建造时间更短，可快速量产 |
| **Americans** | Continental Marine | 启蒙 | Rifleman | HP 更高，近战更强 |
| **British** | Longbowman | 中世纪 | Crossbowman | 射程 +2，伤害略高 |
| **British** | King's Royal Rifleman | 启蒙 | Rifleman | HP 与伤害更高 |
| **Chinese** | Fire Lance | 中世纪 | (提前火药步兵) | 比标准 Arquebusier 早 1 纪元 |
| **Chinese** | Heavy Cavalry (Manchu) | 中世纪 | Knight | HP 更高 |
| **Egyptians** | War Chariot | 古代 | Chariot | HP 与伤害更高 |
| **Egyptians** | Mamluk | 中世纪 | Heavy Cavalry/Knight | HP 更高，反骑兵加成 |
| **French** | Chevalier | 中世纪 | Knight | HP 更高，速度略快 |
| **French** | Garde du Corps | 火药 | Heavy Cavalry | HP 与伤害更高 |
| **French** | Imperial Guard | 启蒙 | Elite Heavy Cavalry | HP 与伤害更高 |
| **Germans** | Teutonic Knight | 中世纪 | Knight | 更慢但 HP/伤害显著更高 |
| **Germans** | Soldner | 火药 | Musketeer | 伤害更高 |
| **Germans** | Tiger Tank | 现代 | Tank/Main Battle Tank | HP 与伤害显著更高 |
| **Germans** | V-2 Rocket | 现代 | (独特，无替代) | 远程导弹攻城单位 |
| **Mongols** | Nomad | 古代 | (提前轻骑兵) | 比标准 Light Cavalry 早 1 纪元 |
| **Mongols** | Mangudai | 古典 | (独特，无替代) | 骑射单位，高机动远程 |
| **Russians** | Boyar | 中世纪 | Heavy Cavalry/Knight | HP 更高 |
| **Russians** | Cossack | 火药 | Light Cavalry | 伤害更高，成本略低 |
| **Russians** | T-34 Tank | 工业 | Tank | HP 更高，造价略低 |

---

### K. 克制关系矩阵

| 攻击方 ↓ \ 防守方 → | 轻型步兵 | 重型步兵 | 弓兵 | 轻骑兵 | 重骑兵 | 攻城 |
|---|---|---|---|---|---|---|
| **轻型步兵** | 中性 | 中性 | 中性 | 中性 | **优势** | 劣势 |
| **重型步兵** | 中性 | 中性 | 中性 | **优势(大)** | **优势** | 劣势 |
| **弓兵** | **优势** | 中性 | 中性 | 劣势 | 劣势 | 劣势 |
| **轻骑兵** | **优势** | 劣势 | **优势** | 中性 | 劣势 | **优势(劫掠)** |
| **重骑兵** | **优势** | 劣势 | **优势** | 中性 | 中性 | 劣势 |
| **攻城** | 劣势 | 劣势 | 劣势 | 劣势 | 劣势 | 中性 |
| **攻城 vs 建筑** | — | — | — | — | — | **优势(极大)** |

> **核心克制链**：弓兵 → 轻步兵 → 重骑兵 → 重步兵 → 轻骑兵 → 弓兵（循环）；攻城 → 建筑；轻骑兵 → 经济单位/弓兵

---

## 附录：数据可信度声明

| 数据类别 | 可信度 | 说明 |
|---|---|---|
| 文明加成与独特单位 | **高** | 定性描述基于模型对游戏的深度知识，加成方向与独特单位存在性可靠 |
| 纪元解锁内容 | **高** | 纪元名称、解锁单位类型、建筑类型可靠 |
| 单位克制关系 | **高** | 克克链是 RoN 核心设计，记忆可靠 |
| HP/伤害/造价数值 | **中** | 数量为近似值（误差约 10-20%），部分标注 `—`。RoN 中单位数值随纪元升级而自动调整，基础值参考意义有限 |
| 建造时间/冷却时间 | **中低** | 为近似值，实际受多种科技加成影响 |
| 升级链 | **高** | 跨纪元升级路径可靠，是 RoN 核心机制 |
| 文明具体加成百分比 | **中** | 方向可靠（如"更便宜""更快"），具体百分比可能有偏差 |

### 建议交叉验证来源

1. **Fandom Wiki**: https://riseofnations.fandom.com/
2. **Steam 社区指南**: 搜索 "Rise of Nations unit guide"
3. **游戏内百科**: RoN Extended Edition 自带完整百科（Steam 版本）
4. **Reddit r/riseofnations**: 社区讨论与策略分析

---

> **文档结束** | Rise of Nations + Thrones and Patriots 单位数据调研 | 2026-06-17
