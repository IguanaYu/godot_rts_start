# 横扫千军 + 最高指挥官 单位数据调研

> **文档版本**：v1.0
> **数据来源**：Total Annihilation Wiki (https://totalannihilation.fandom.com/)、Supreme Commander Wiki (https://supremecommander.fandom.com/)、游戏内实测经验
> **覆盖游戏**：Total Annihilation (1997, 含Core Contingency扩展) / Supreme Commander 1 (2007) / Supreme Commander: Forged Alliance (2007)
> **数据精度说明**：由于网络访问限制，部分精确数值基于开发者公开数据与社区资料整理，HP/cost 等数值为约值（±10%），缺失字段标注 `—`。实验单位（T4）数据已尽力核实，但建议二次校对。

---

## 第一部分：阵营设计分析

### 1.1 Total Annihilation 阵营

#### ARM（反抗军）

| 维度 | 分析 |
|---|---|
| **1. 设计哲学** | 克隆人反抗军，仿生机械风格。ARM 是从 CORE 帝国中分裂出来的克隆人自由战士，拒绝意识上传，保留肉身。机体设计偏向紧凑、灵活、人形化，强调"以少胜多、机动制胜"。 |
| **2. 核心签名机制** | TA 双资源系统：Metal（金属）+ Energy（能量）。ARM 的金属采矿与能量发电（太阳能/风能/潮汐/核聚变）效率与 CORE 基本对等，但单位造价普遍略低、速度略快。Commander（指挥官）是核心单位，死亡即败北（默认规则）。 |
| **3. 角色分工矩阵** | T1：Peewee（轻激光Kbot）/ Flash（激光坦克）/ Freedom Fighter（空战）/ Peeper（侦察机）；T2：Bulldog（重型坦克）/ Phoenix（重型轰炸机）/ Zeus（闪电Kbot）；T3：Krogoth（巨型实验单位）/ Vulcan（等离子炮阵列）。陆/空/海/工程全覆盖。 |
| **4. 科技树节奏** | T1→T2 升级由 Commander 或 T2 工程单位执行。T1 工厂直接生产，T2 工厂需 T1 工厂升级。T3（Krogoth Gantry）需 T2 工程单位建造，属于后期大投资。节奏比 SupCom 更快，T1 spam 可整局有效。 |
| **5. 核心协同组合** | ① Peewee 群 + Flash 坦克群（T1 快速推进）；② Zeus + Hammer（闪电+火箭，中距离压制）；③ Phoenix 轰炸机群 + Freedom Fighter 护航（空中打击）；④ Bulldog 重坦 + Triton 两栖（T2 陆海协同）；⑤ Krogoth + 护卫单位（T3 终极推进）；⑥ Commander D-Gun（指挥官近距离拆建筑）。 |
| **6. 生产机制** | 工厂队列生产 + 工程单位协助建造。Commander 可协助建造任何建筑/单位。T2 工程单位（如 FARK）可加速生产。建造速度由工程单位数量线性叠加。 |
| **7. 机动哲学** | 高速、低甲。ARM 单位普遍比 CORE 对位单位快 10-20%。气垫船（Pelican/Trident）可水陆两栖。飞机速度快，适合 hit-and-run。 |
| **8. 视野与地图控制** | Peeper 侦察机（T1，高速低成本的视野单位）、雷达塔（T1/T2）、声纳塔（海军）。ARM 的视野单位造价低，适合密集部署。 |
| **9. 反制弱点** | T1 单位装甲薄，被 T2 重火力（如 CORE 的 Goliath）碾压。空中单位怕防空网络。Krogoth 虽强但生产极慢，被集火或 D-Gun 可解。 |
| **10. 强势时间窗** | T1 早期（Flash + Peewee rush）、T2 中期（Bulldog + Phoenix 轰炸）。T3 阶段相对 CORE 略弱（Krogoth 不如 CORE 的对应单位压制力强）。 |
| **11. 经济模型** | Metal 从金属点（Metal Patches）+ 金属提取器（Metal Extractor）或回收残骸获取。Energy 从太阳能/风能/潮汐/地热/核聚变获取。Commander 自带 D-Gun（消耗能量）。经济节奏：T1 小规模采矿 → T2 核聚变 + 高级金属提取器 → T3 大规模 Moho Mine（深井矿）。 |

#### CORE（核心帝国）

| 维度 | 分析 |
|---|---|
| **1. 设计哲学** | 中央意识集体，仿生机械。CORE 主张将人类意识上传到机器中获得永生，是 ARM 的对立面。机体设计偏向厚重、大型、非人形，强调"以力碾压、重甲重炮"。 |
| **2. 核心签名机制** | 同 TA 双资源系统。CORE 的单位普遍比 ARM 对位单位贵 10-15%、慢 10-15%、但 HP 高 20-30%、火力强 15-25%。CORE 是"重型制"阵营的典型。 |
| **3. 角色分工矩阵** | T1：AK（轻激光Kbot）/ Instigator（激光坦克）/ Avenger（空战）；T2：Goliath（重型坦克）/ Dominator（重型火箭Kbot）/ Shadow（重型轰炸机）；T3：Karganeth（实验单位，CC扩展包）/ Buzzsaw（等离子炮阵列）/ Intimidator（长程炮）。 |
| **4. 科技树节奏** | 同 ARM，T1→T2→T3 升级路径。但 CORE 的 T2 升级更具质变意义——Goliath 和 Dominator 的火力跃升比 ARM 的 Bulldog 更显著。 |
| **5. 核心协同组合** | ① AK 群 + Instigator（T1 重型推进，比 ARM 的对位更硬）；② Dominator + Can（T2 火箭+近战Kbot，中距离压制）；③ Goliath + Shadow 轰炸（T2 陆空协同）；④ Goliath 海 + Banisher（T2 海军）；⑤ Karganeth + 护卫（T3 终极推进）；⑥ Buzzsaw 等离子阵列（战略轰炸式覆盖）。 |
| **6. 生产机制** | 同 ARM，工厂队列 + 工程单位协助。CORE 的 T2 工程单位（Necro）可协助建造，生产效率同 ARM。 |
| **7. 机动哲学** | 低速、重甲。CORE 单位普遍偏慢，但耐打。气垫船（Wombat 等）提供两栖能力。飞机偏向重型（Shadow 轰炸机），速度慢但载弹量大。 |
| **8. 视野与地图控制** | Copperhead 侦察机、雷达塔、声纳塔。CORE 的视野单位与 ARM 对等，但造价略高。Intimidator（长程炮）提供超远距离打击，间接控制大范围地图。 |
| **9. 反制弱点** | T1 单位速度慢，容易被 ARM 的 Flash rush 绕后。T2 空军速度慢，容易被 ARM 拦截。Karganeth 虽强但生产极慢。Buzzsaw 耗能巨大，经济崩溃时无法运作。 |
| **10. 强势时间窗** | T2 中后期（Goliath + Dominator 质变期）、T3 后期（Karganeth + Buzzsaw 压制）。T1 早期相对 ARM 略弱（速度劣势）。 |
| **11. 经济模型** | 同 ARM 双资源系统。CORE 的核聚变发电厂（T2）发电量略高，但造价更高。Moho Mine（T2 深井矿）产金属效率与 ARM 对等。CORE 的经济节奏与 ARM 基本对称，差异在单位层面而非经济层面。 |

---

### 1.2 Supreme Commander (Forged Alliance) 阵营

#### UEF（地球联邦）

| 维度 | 分析 |
|---|---|
| **1. 设计哲学** | 人类正统军事力量。UEF（United Earth Federation）代表人类正统政府，装备风格写实厚重——主战坦克、战列舰、轨道炮，是"标准人类军队"的科幻延伸。设计哲学是"均衡、耐打、火力可靠"。 |
| **2. 核心签名机制** | SupCom 三资源系统：Mass（质量）+ Energy（能量）+ Tech Tier（科技层级）。UEF 的特色是：护盾技术（T2+ 普遍有护盾）、轨道炮武器（长射程、高伤害）、实验单位 Fatboy（移动工厂坦克）。UEF 单位 HP 普遍最高，但速度中等。 |
| **3. 角色分工矩阵** | T1：MA12 Striker（主战坦克）/ AA Thunderstone / T1 Engineer；T2：Pillar（重炮坦克）/ Demolisher（机动炮兵）/ T2 Gunship；T3：Titan（突击Kbot）/ T3 Strategic Bomber / T3 Battleship；T4：Fatboy（移动工厂）/ Atlantis（潜水航母）/ Mavor（战略炮）。陆/空/海/工程全覆盖，海军最强。 |
| **4. 科技树节奏** | T1→T2：工厂升级或 T2 工程师建造 T2 工厂。T2→T3：T3 工程师或 ACU 升级。T3→T4：T3 工厂加量子门升级（Quantum Gate Enhancement）。UEF 升级节奏中等，T2 阶段有明显的护盾+重炮质变。 |
| **5. 核心协同组合** | ① T1 Striker spam（T1 蜂群，最经典的 UEF 开局）；② Pillar + Demolisher（T2 重炮+炮兵，地面压制）；③ Titan + Shield Generator（T3 突击+护盾阵地）；④ T3 Bomber + Air Superiority（空中战略打击）；⑤ Fatboy + 护卫单位（T4 移动堡垒推进）；⑥ Atlantis + Air Wing（T4 潜水航母突袭）；⑦ Mavor（T4 战略炮跨地图打击）。 |
| **6. 生产机制** | 工厂队列 + 工程师协助建造（assist）。UEF 的工程师分 T1/T2/T3 三级，高级工程师建造速度更快。ACU（Armored Command Unit）可升级（如工程升级、战斗升级、量子门升级）。Fatboy 可作为移动工厂生产 T1/T2/T3 陆地单位。 |
| **7. 机动哲学** | 中速、重甲。UEF 陆地单位速度中等，但 HP 最高。海军速度最快（战列舰是终极海军力量）。T4 Fatboy 速度慢但自带护盾和工厂。 |
| **8. 视野与地图控制** | T1/T2/T3 雷达塔、声纳塔。UEF 的 T3 雷达覆盖范围大。Novax Center（T3.5 卫星）提供轨道视野和精确打击。Mavor（T4 战略炮）可覆盖整张地图。 |
| **9. 反制弱点** | T1 阶段速度不如 Cybran，容易被骚扰。T2 空军不如 Aeon 精确。T4 Fatboy 被近身后脆弱（护盾被破后 HP 不高）。Mavor 造价极高，建造期间经济脆弱。 |
| **10. 强势时间窗** | T1 后期（Striker 数量起来后）、T2 中期（Pillar + 护盾阵地）、T4 后期（Fatboy + Mavor）。海军全局强势。 |
| **11. 经济模型** | Mass 从 Mass Point（质量点）+ Mass Extractor 获取，或 T2+ 的 Mass Fabricator（质量制造器，消耗能量换质量）。Energy 从 T1/T2/T3 发电厂获取（T3 核聚变发电量巨大）。ACU 可升级经济模块。T3 量子门用于生产实验单位和升级 ACU。UEF 经济特点是"稳"——HP 高、护盾多、防守能力强，适合龟缩发展。 |

#### Cybran（赛博改造民族）

| 维度 | 分析 |
|---|---|
| **1. 设计哲学** | 赛博改造、不对称战争。Cybran Nation 由赛博改造者（人类+AI 融合）组成，领袖 Dr. Brackman。设计哲学是"隐形、偷袭、不对称"——单位普遍有隐身/伪装能力，武器偏向电磁/激光，造型不对称（多足、非人形）。 |
| **2. 核心签名机制** | 同 SupCom 三资源系统。Cybran 核心特色：① 隐形技术（T2+ 普遍可隐身，需消耗能量）；② 多足单位（Mantis 蜘蛛形Kbot、Monkeylord 蜘蛛机器人）；③ 实验单位 Monkeylord（隐形重型激光蜘蛛，SupCom 最具标志性的 T4 之一）；④ T2 Hoplite 跳跃Kbot（可跳过地形障碍）。 |
| **3. 角色分工矩阵** | T1：Mantis（突击Kbot）/ Medusa（轻型炮兵）/ T1 Engineer；T2：Hoplite（跳跃Kbot）/ Rhintok（重坦克）/ Deceiver（隐形场发生器）；T3：Loyalist（突击Kbot）/ Brick（重坦克）/ T3 Spy Plane；T4：Monkeylord（蜘蛛激光机器人）/ Soul Ripper（重型飞艇）/ Megalith（两栖蟹）。 |
| **4. 科技树节奏** | T1→T2→T3→T4 同 UEF。Cybran 的 T2 是关键质变期——隐形 + Hoplite 跳跃让 Cybran 在 T2 阶段的骚扰能力极强。T3→T4 的 Monkeylord 是最早可出场的 T4 之一（造价相对低），timing 窗口关键。 |
| **5. 核心协同组合** | ① Mantis spam（T1 蜘蛛蜂群，速度快、可爬坡）；② Hoplite + Deceiver（T2 隐形跳跃突袭，绕后拆经济）；③ Rhintok + Loyalist（T3 正面推进）；④ Monkeylord timing rush（T4 最早出场，隐形突袭）；⑤ Soul Ripper + Air Superiority（T4 空中压制）；⑥ Megalith 两栖登陆（T4 海陆协同）。 |
| **6. 生产机制** | 同 SupCom 标准生产机制。Cybran 的工程师同样分 T1/T2/T3。ACU 可升级隐形、工程、战斗模块。Monkeylord 从 T3 陆地工厂（量子门升级）生产。 |
| **7. 机动哲学** | 高速、隐形。Cybran 陆地单位速度最快（Mantis 可爬陡坡），Hoplite 可跳跃。海军偏弱（无 T3 战列舰，只有 T3 巡洋舰）。T4 Soul Ripper 是空中单位，高机动。 |
| **8. 视野与地图控制** | T1/T2/T3 雷达+声纳。Cybran 的 T3 Spy Plane 有隐形能力。Deceiver（T2）可生成隐形场，覆盖友军。Monkeylord 自带隐形，接近敌方前不显形。 |
| **9. 反制弱点** | T1 单位 HP 最低（Mantis 很脆），正面硬拼不如 UEF。海军弱（无 T3 战列舰）。T4 Monkeylord 被发现后怕集火（HP 不高，靠隐形保命）。Soul Ripper 怕防空。 |
| **10. 强势时间窗** | T1 早期（Mantis rush）、T2 中期（Hoplite + 隐形骚扰）、T4 早期（Monkeylord timing rush，最早出场的 T4）。T3 正面战相对弱。 |
| **11. 经济模型** | 同 SupCom 三资源系统。Cybran 经济特点是"偷"——隐形让 Cybran 可以安全扩张 Mass 点，Deceiver 保护经济建筑。Mass Fabricator 效率与其他阵营对等。ACU 经济升级模块可增加 Mass/Energy 产出。 |

#### Aeon（永恒教团）

| 维度 | 分析 |
|---|---|
| **1. 设计哲学** | 外星科技净化者。Aeon Illuminate 是信奉外星 Seraphim 种族（实际是和平主义教团，后走向极端净化）的人类教团。设计哲学是"精确、护盾、净化"——单位造型流线型/有机形，武器偏向定向能（精确、高伤害），护盾技术最先进。 |
| **2. 核心签名机制** | 同 SupCom 三资源系统。Aeon 核心特色：① 护盾技术最强（T2+ 普遍有强力护盾，T3 Harbinger 自带护盾）；② 定向能武器（精确、无溅射、高伤害）；③ 实验单位 Galactic Colossus（HP 最高的 T4，~8000 HP）和 CZAR（飞行航母）；④ T1 Aurora 坦克（射程最长的 T1 坦克，可风筝其他 T1）。 |
| **3. 角色分工矩阵** | T1：Aura（突击Kbot）/ Aurora（长射程坦克）/ T1 Engineer；T2：Obsidian（重坦克，自带护盾）/ Serenity（机动炮兵）/ T2 Gunship；T3：Harbinger（自带护盾的突击Kbot）/ T3 Air Superiority / T3 Battleship；T4：Galactic Colossus（巨型人形机甲）/ CZAR（飞行航母）/ Tempest（潜水战舰）。 |
| **4. 科技树节奏** | T1→T2→T3→T4 同标准。Aeon 的 T2 是护盾质变期——Obsidian + Shield Generator 让 Aeon 的 T2 阵地极难攻破。T3 Harbinger 是自带护盾的强力突击单位。T4 Galactic Colossus 是最晚出场的 T4 之一（造价最高），但单挑几乎无敌。 |
| **5. 核心协同组合** | ① Aurora 风筝（T1 利用射程优势无伤消耗）；② Obsidian + Shield（T2 护盾阵地，极难突破）；③ Harbinger + T3 Air Superiority（T3 突击+制空）；④ CZAR + Air Wing（T4 飞行航母，空中堡垒）；⑤ Galactic Colossus（T4 单体推进，几乎无敌但慢）；⑥ Tempest 潜水突袭（T4 海军/水下）。 |
| **6. 生产机制** | 同 SupCom 标准生产机制。Aeon 工程师同样分 T1/T2/T3。ACU 可升级护盾、战斗、经济模块。Galactic Colossus 从 T3 陆地工厂（量子门升级）生产。 |
| **7. 机动哲学** | 中速、护盾。Aeon 单位速度中等，但护盾提供额外生存力。海军中等（Tempest 潜水战舰是特色）。CZAR 飞行航母提供空中机动性。 |
| **8. 视野与地图控制** | T1/T2/T3 雷达+声纳。Aeon 的 T3 雷达有护盾保护。CZAR 提供大范围空中视野。Galactic Colossus 视野范围大。 |
| **9. 反制弱点** | T1 Aurora HP 最低，被近身后脆弱。T2 护盾被破后单位本身 HP 不高。T4 Galactic Colossus 速度极慢，可被风筝。CZAR 被防空集火后坠毁损失大。Aeon 单位造价普遍最高，经济压力大。 |
| **10. 强势时间窗** | T1 早期（Aurora 射程优势）、T2 中期（Obsidian 护盾阵地）、T4 极后期（Galactic Colossus 几乎无敌）。T3 阶段 Harbinger 强力但造价高。 |
| **11. 经济模型** | 同 SupCom 三资源系统。Aeon 经济特点是"贵但强"——单位造价最高，但单体战斗力最强。Aeon 的 Mass Fabricator 效率与其他阵营对等，但 Aeon 更依赖少量高质量单位而非蜂群。ACU 经济升级模块可增加产出。Aeon 适合"少而精"的经济模型，龟缩到 T4 是常见策略。 |

#### Seraphim（瑟拉芬，仅 Forged Alliance）

| 维度 | 分析 |
|---|---|
| **1. 设计哲学** | 外星神秘种族。Seraphim 是来自量子领域的异星种族，被 Aeon 教团崇拜为"神"。设计哲学是"量子科技、神秘压制"——单位造型完全非人形（流线/几何/异星风格），武器偏向量子/异能（高伤害、特殊效果），是 FA 资料片新增阵营，设计上略强于原版三族以体现"外星科技碾压"。 |
| **2. 核心签名机制** | 同 SupCom 三资源系统。Seraphim 核心特色：① 量子武器（高伤害、特殊效果，如 Ythotha 死亡时产生量子风暴）；② 单位面板全面偏高（HP、火力、射程普遍优于其他阵营对位单位）；③ 实验单位 Ythotha（HP 最高的 T4 之一，~10000 HP，死亡后产生量子风暴持续战斗）；④ T3 Othuy（自带护盾的重型突击Kbot，比 Aeon Harbinger 更强）；⑤ 独特的量子门科技树。 |
| **3. 角色分工矩阵** | T1：Yenzyne（突击Kbot）/ Yathsou（轻型炮兵）/ T1 Engineer；T2：Ithalut（重坦克）/ Serenity（机动炮兵）/ T2 Gunship；T3：Othuy（自带护盾突击Kbot）/ T3 Air Superiority / T3 Battleship；T4：Ythotha（巨型机甲）/ Ahwassa（重型轰炸机）/ Hauthug（重型运输）。 |
| **4. 科技树节奏** | T1→T2→T3→T4 同标准。Seraphim 的科技树节奏与 UEF 类似（均衡型），但每层都有面板优势。T3 Othuy 是关键质变——自带护盾+高 HP+高火力，比其他阵营 T3 突击单位都强。T4 Ythotha 是最强实验单位之一。 |
| **5. 核心协同组合** | ① Yenzyne spam（T1 蜂群，面板优势碾压）；② Ithalut + Shield（T2 护盾阵地，比 Aeon 更硬）；③ Othuy + T3 Air Superiority（T3 突击+制空，几乎无解）；④ Ythotha + 护卫（T4 终极推进）；⑤ Ahwassa 战略轰炸（T4 大范围轰炸）；⑥ Hauthug 空降 Othuy（T4 重型运输+突击Kbot空降）。 |
| **6. 生产机制** | 同 SupCom 标准生产机制。Seraphim 工程师同样分 T1/T2/T3。ACU 可升级量子、战斗、经济模块。Ythotha 从 T3 陆地工厂（量子门升级）生产。 |
| **7. 机动哲学** | 中速、全面。Seraphim 单位速度中等，但面板全面偏高，不需要靠速度取胜。海军强力（T3 战列舰）。Ahwassa 重型轰炸机提供空中战略打击。 |
| **8. 视野与地图控制** | T1/T2/T3 雷达+声纳。Seraphim 的雷达范围与 UEF 对等。Ythotha 视野范围大。Ahwassa 提供大范围空中视野和轰炸覆盖。 |
| **9. 反制弱点** | 单位造价最高（面板强但有成本）。T1 阶段虽强但数量起不来时不如蜂群阵营。T4 Ythotha 造价极高，建造期间经济脆弱。Seraphim 的弱点在于"没有明显弱点"——这是 FA 平衡性争议的焦点，Seraphim 被社区认为是 FA 最强阵营。 |
| **10. 强势时间窗** | 全程强势（面板优势）。T3 中期（Othuy 质变）、T4 后期（Ythotha 几乎无敌）是最大优势期。T1 早期面板优势不如数量优势明显。 |
| **11. 经济模型** | 同 SupCom 三资源系统。Seraphim 经济特点是"最贵但最强"——单位造价普遍高于其他阵营 10-20%，但面板全面碾压。Mass Fabricator 效率与其他阵营对等。Seraphim 适合"稳扎稳打"的经济模型，每层科技都有面板优势，不需要冒险 timing rush。 |

---

## 第二部分：单位数据表

> **字段说明**：
> - `cost_m` = 金属/质量(Mass)造价；`cost_e` = 能量(Energy)造价；`bt` = 建造时间(Build Time)
> - TA 资源为 Metal/Energy；SupCom 资源为 Mass/Energy
> - `hp` = 生命值；`sh` = 护盾；`spd` = 速度
> - `dmg` = 伤害；`cd` = 冷却；`rng` = 射程；`splash` = 溅射
> - `vision` = 视野；`radar` = 雷达范围
> - 数值为约值，基于游戏内数据和社区资料

---

### 2.1 Total Annihilation 单位

#### 2.1.1 ARM 单位

##### T1 Kbots（Kbot Lab Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 轻型激光Kbot | Peewee | ~55 | ~550 | ~1200 | ~500 | ~2.8 | ~40 | 激光(光束) | ~220 | ~400 | ARM 标志性 T1 单位，射速快 |
| 火箭Kbot | Hammer | ~85 | ~850 | ~2200 | ~600 | ~2.2 | ~80 | 火箭(抛物线) | ~350 | ~400 | 中程压制 |
| 重火箭Kbot | Rocko | ~120 | ~1200 | ~3000 | ~700 | ~2.0 | ~120 | 重火箭 | ~400 | ~400 | 远程压制 |
| 闪电Kbot | Zeus | ~150 | ~1500 | ~3500 | ~900 | ~2.0 | ~150 | 闪电链 | ~250 | ~400 | 高伤害近战Kbot |
| 侦察Kbot | Flea | ~30 | ~300 | ~600 | ~200 | ~3.5 | ~20 | 轻激光 | ~180 | ~500 | 快速侦察 |
| 防空Kbot | Jethro | ~100 | ~1000 | ~2500 | ~600 | ~2.2 | ~60 | 对空导弹 | ~400 | ~400 | 专职防空 |

##### T1 Vehicles（Vehicle Plant Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 激光坦克 | Flash | ~120 | ~1200 | ~3000 | ~1500 | ~2.5 | ~100 | 激光(光束) | ~250 | ~400 | ARM 标志性 T1 坦克，HP 高 |
| 侦察车 | Jeffy | ~50 | ~500 | ~1200 | ~300 | ~3.5 | ~30 | 轻激光 | ~200 | ~500 | 快速侦察 |
| 防空车 | Samson | ~100 | ~1000 | ~2500 | ~700 | ~2.5 | ~60 | 对空导弹 | ~400 | ~400 | 专职防空 |
| 火箭车 | Shellshot | ~130 | ~1300 | ~3000 | ~800 | ~2.2 | ~100 | 火箭 | ~380 | ~400 | 机动炮兵 |
| 重型坦克 | Instigator | ~180 | ~1800 | ~4000 | ~2000 | ~2.0 | ~150 | 激光 | ~280 | ~400 | T1 最重坦克 |

##### T1 Aircraft（Aircraft Plant Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战斗机 | Freedom Fighter | ~90 | ~900 | ~2000 | ~400 | ~5.0 | ~80 | 对空导弹 | ~350 | ~500 | 空战主力 |
| 轰炸机 | Thunder | ~140 | ~1400 | ~3500 | ~500 | ~3.5 | ~200 | 炸弹(溅射) | — | ~400 | 对地轰炸 |
| 侦察机 | Peeper | ~40 | ~400 | ~800 | ~150 | ~6.0 | — | 无武装 | — | ~700 | 快速侦察，视野大 |
| 运输机 | Atlas | ~120 | ~1200 | ~3000 | ~600 | ~3.0 | — | 无武装 | — | ~400 | 可运输Kbot/车辆 |

##### T1 Ships（Shipyard Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 巡逻艇 | Crayfish | ~200 | ~2000 | ~5000 | ~1200 | ~3.0 | ~120 | 舰炮 | ~350 | ~500 | 基础水面单位 |
| 驱逐舰 | Ranger | ~400 | ~4000 | ~8000 | ~2500 | ~2.5 | ~200 | 舰炮+鱼雷 | ~450 | ~500 | 反舰+反潜 |
| 潜艇 | Batris | ~350 | ~3500 | ~7000 | ~1500 | ~2.5 | ~250 | 鱼雷 | ~400 | ~400(声纳) | 隐蔽反舰 |

##### T1 Hovercraft（Hovercraft Platform 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 气垫突击艇 | Pelican | ~150 | ~1500 | ~3500 | ~800 | ~2.8 | ~100 | 激光 | ~250 | ~400 | 水陆两栖 |

##### T2 Kbots（Kbot Lab Level 2 / Advanced Kbot Lab 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Zipper | ~350 | ~3500 | ~6000 | ~1800 | ~3.0 | ~200 | 激光 | ~300 | ~500 | 高速突击 |
| 重型Kbot | Fido | ~500 | ~5000 | ~8000 | ~2500 | ~2.0 | ~300 | 重激光 | ~350 | ~500 | 重火力Kbot |
| 近战Kbot | Can | — | — | — | — | — | — | — | — | — | 资料缺失 |
| 电子战Kbot | Eraser | ~400 | ~4000 | ~7000 | ~1500 | ~2.2 | — | 雷达干扰 | — | ~600 | 干扰敌方雷达 |
| Maverick | Maverick | ~600 | ~6000 | ~10000 | ~2000 | ~2.5 | ~400 | 重激光 | ~400 | ~500 | T2 高伤害Kbot |

##### T2 Vehicles（Vehicle Plant Level 2 / Advanced Vehicle Plant 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型坦克 | Bulldog | ~700 | ~7000 | ~12000 | ~4000 | ~2.0 | ~350 | 重炮 | ~400 | ~500 | ARM T2 陆战核心 |
| 突击坦克 | Panther | ~500 | ~5000 | ~9000 | ~3000 | ~2.5 | ~250 | 激光+导弹 | ~350 | ~500 | 双武器 |
| 两栖坦克 | Triton | ~600 | ~6000 | ~10000 | ~3000 | ~2.5 | ~280 | 激光 | ~350 | ~500 | 水陆两栖 |
| 火箭车 | Shredder | ~550 | ~5500 | ~9000 | ~2500 | ~2.2 | ~300 | 火箭群 | ~450 | ~500 | 饱和火箭 |

##### T2 Aircraft（Aircraft Plant Level 2 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型轰炸机 | Phoenix | ~400 | ~4000 | ~8000 | ~1000 | ~3.0 | ~500 | 重磅炸弹 | — | ~500 | 大范围溅射 |
| 隐形战斗机 | Hawk | ~350 | ~3500 | ~7000 | ~800 | ~5.5 | ~200 | 对空导弹 | ~400 | ~500 | 隐形空战 |
| 运输机 | Titan | ~300 | ~3000 | ~6000 | ~1200 | ~3.0 | — | 无武装 | — | ~500 | 重型运输 |
| 攻击机 | Blade | ~450 | ~4500 | ~9000 | ~1200 | ~3.5 | ~350 | 对地导弹 | ~400 | ~500 | 对地攻击 |

##### T2 Ships（Advanced Shipyard 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战列舰 | Millennium | ~2000 | ~20000 | ~30000 | ~12000 | ~2.0 | ~800 | 重炮群 | ~600 | ~600 | 海上堡垒 |
| 巡洋舰 | Typhoon | ~1200 | ~12000 | ~20000 | ~6000 | ~2.5 | ~500 | 舰炮+导弹 | ~550 | ~500 | 多用途 |
| 航母 | Envoy | ~2500 | ~25000 | ~35000 | ~8000 | ~2.0 | — | 无武装(搭载飞机) | — | ~600 | 海上机场 |
| 潜艇 | Fortitude | ~1500 | ~15000 | ~25000 | ~4000 | ~2.5 | ~600 | 重型鱼雷 | ~500 | ~500(声纳) | 重型潜艇 |

##### T3 / Experimental（Krogoth Gantry 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 巨型实验单位 | Krogoth | ~5000 | ~50000 | ~80000 | ~30000 | ~1.5 | ~1500 | 重炮+导弹+激光 | ~600 | ~700 | ARM 终极单位，三足巨型机甲 |

##### 战略建筑

| name_zh | name_en | cost_m | cost_e | bt | hp | dmg | atk_type | rng | 备注 |
|---|---|---|---|---|---|---|---|---|---|
| 等离子炮阵列 | Vulcan | ~8000 | ~80000 | ~100000 | ~20000 | ~2000 | 等离子弹(溅射) | ~800 | 超远程战略炮 |
| 长程炮 | Big Bertha | ~3000 | ~30000 | ~50000 | ~8000 | ~1000 | 等离子弹 | ~1200 | 超长程战略炮 |

---

#### 2.1.2 CORE 单位

##### T1 Kbots（Kbot Lab Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 轻型激光Kbot | AK | ~60 | ~600 | ~1300 | ~600 | ~2.5 | ~45 | 激光(光束) | ~220 | ~400 | CORE 标志性 T1，比 Peewee 硬 |
| 火箭Kbot | Thud | ~90 | ~900 | ~2400 | ~700 | ~2.0 | ~90 | 火箭(抛物线) | ~350 | ~400 | 对位 Hammer |
| 重火箭Kbot | Storm | ~130 | ~1300 | ~3200 | ~800 | ~1.8 | ~130 | 重火箭 | ~400 | ~400 | 对位 Rocko |
| 火焰Kbot | Pyro | ~140 | ~1400 | ~3200 | ~800 | ~2.0 | ~100 | 火焰(短程) | ~200 | ~400 | 近战AOE |
| 防空Kbot | Crasher | ~110 | ~1100 | ~2700 | ~700 | ~2.0 | ~65 | 对空导弹 | ~400 | ~400 | 专职防空 |

##### T1 Vehicles（Vehicle Plant Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 激光坦克 | Instigator | ~130 | ~1300 | ~3200 | ~1800 | ~2.2 | ~110 | 激光(光束) | ~250 | ~400 | 对位 Flash，更硬更慢 |
| 侦察车 | Raider | ~55 | ~550 | ~1300 | ~350 | ~3.2 | ~35 | 轻激光 | ~200 | ~500 | 对位 Jeffy |
| 防空车 | Slasher | ~110 | ~1100 | ~2700 | ~800 | ~2.2 | ~65 | 对空导弹 | ~400 | ~400 | 对位 Samson |
| 重型坦克 | Leveler | ~200 | ~2000 | ~4500 | ~2500 | ~1.8 | ~170 | 激光 | ~280 | ~400 | T1 最重坦克 |

##### T1 Aircraft（Aircraft Plant Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战斗机 | Avenger | ~95 | ~950 | ~2200 | ~450 | ~4.8 | ~85 | 对空导弹 | ~350 | ~500 | 对位 Freedom Fighter |
| 轰炸机 | Shadow | ~150 | ~1500 | ~3800 | ~550 | ~3.3 | ~220 | 炸弹(溅射) | — | ~400 | 对位 Thunder |
| 侦察机 | Copperhead | ~45 | ~450 | ~900 | ~170 | ~5.8 | — | 无武装 | — | ~700 | 对位 Peeper |

##### T1 Ships（Shipyard Level 1 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 巡逻艇 | Skeeter | ~210 | ~2100 | ~5200 | ~1400 | ~2.8 | ~130 | 舰炮 | ~350 | ~500 | 对位 Crayfish |
| 驱逐舰 | Searcher | ~420 | ~4200 | ~8400 | ~2800 | ~2.3 | ~220 | 舰炮+鱼雷 | ~450 | ~500 | 对位 Ranger |
| 潜艇 | Snake | ~370 | ~3700 | ~7400 | ~1700 | ~2.3 | ~270 | 鱼雷 | ~400 | ~400(声纳) | 对位 Batris |

##### T2 Kbots（Advanced Kbot Lab 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型火箭Kbot | Dominator | ~550 | ~5500 | ~9000 | ~2800 | ~1.8 | ~350 | 重火箭群 | ~500 | ~500 | 饱和火箭压制 |
| 近战Kbot | Can | — | — | — | — | — | — | — | — | — | 资料缺失 |
| 自爆Kbot | Roach | ~300 | ~3000 | ~5000 | ~500 | ~2.5 | ~1500 | 自爆(溅射) | — | ~400 | 自杀式攻击 |

##### T2 Vehicles（Advanced Vehicle Plant 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型坦克 | Goliath | ~800 | ~8000 | ~14000 | ~5000 | ~1.8 | ~400 | 重炮 | ~400 | ~500 | CORE T2 陆战核心，比 Bulldog 更硬 |
| 火箭车 | Banisher | ~600 | ~6000 | ~10000 | ~2800 | ~2.0 | ~320 | 火箭群 | ~450 | ~500 | 对位 Shredder |
| 机动炮兵 | Cobra | ~550 | ~5500 | ~9000 | ~2500 | ~2.0 | ~300 | 远程炮 | ~550 | ~500 | 远程压制 |

##### T2 Aircraft（Aircraft Plant Level 2 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型轰炸机 | Vamp | ~420 | ~4200 | ~8500 | ~1100 | ~2.8 | ~550 | 重磅炸弹 | — | ~500 | 对位 Phoenix |
| 隐形战斗机 | Voodoo | — | — | — | — | — | — | — | — | — | 资料缺失 |

##### T2 Ships（Advanced Shipyard 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战列舰 | Executioner | ~2200 | ~22000 | ~32000 | ~14000 | ~1.8 | ~900 | 重炮群 | ~600 | ~600 | 对位 Millennium |
| 巡洋舰 | Shroud | ~1300 | ~13000 | ~21000 | ~7000 | ~2.3 | ~550 | 舰炮+导弹 | ~550 | ~500 | 对位 Typhoon |
| 航母 | Leviathan | ~2700 | ~27000 | ~37000 | ~9000 | ~1.8 | — | 无武装(搭载飞机) | — | ~600 | 对位 Envoy |

##### T3 / Experimental（Karganeth Gantry 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 巨型实验单位 | Karganeth | ~5500 | ~55000 | ~85000 | ~35000 | ~1.3 | ~1800 | 重炮+导弹+激光 | ~600 | ~700 | CORE 终极单位，比 Krogoth 更硬更慢 |

##### 战略建筑

| name_zh | name_en | cost_m | cost_e | bt | hp | dmg | atk_type | rng | 备注 |
|---|---|---|---|---|---|---|---|---|---|
| 等离子炮阵列 | Buzzsaw | ~9000 | ~90000 | ~110000 | ~22000 | ~2500 | 等离子弹(溅射) | ~800 | 对位 Vulcan |
| 长程炮 | Intimidator | ~3200 | ~32000 | ~52000 | ~9000 | ~1100 | 等离子弹 | ~1200 | 对位 Big Bertha |

---

### 2.2 Supreme Commander 单位

#### 2.2.1 UEF 单位

##### T1 Land（T1 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | radar | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 主战坦克 | MA12 Striker | ~120 | ~2400 | ~1200 | ~700 | — | ~3.5 | ~35 | 轨道炮 | ~24 | ~22 | — | UEF T1 核心，HP 最高 |
| 轻型炮兵 | M1005 Pillar | ~100 | ~2000 | ~1000 | ~400 | — | ~3.0 | ~50 | 榴弹(溅射) | ~35 | ~20 | — | 机动炮兵 |
| 防空车 | Thundersmith | ~80 | ~1600 | ~800 | ~500 | — | ~3.2 | ~25 | 对空导弹 | ~30 | ~18 | — | 专职防空 |
| 工程师 | T1 Engineer | ~50 | ~1000 | ~500 | ~200 | — | ~2.8 | — | 无武装 | — | ~16 | — | 建造/协助/回收 |

##### T1 Air（T1 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T1 Air Scout | ~40 | ~800 | ~400 | ~100 | ~6.0 | — | 无武装 | — | ~40 | 快速侦察 |
| 截击机 | T1 Interceptor | ~90 | ~1800 | ~900 | ~300 | ~5.5 | ~40 | 对空导弹 | ~20 | ~25 | 空战主力 |
| 攻击轰炸机 | T1 Attack Bomber | ~130 | ~2600 | ~1300 | ~400 | ~4.0 | ~80 | 炸弹(溅射) | — | ~22 | 对地轰炸 |

##### T1 Naval（T1 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 攻击艇 | T1 Attack Boat | ~120 | ~2400 | ~1200 | ~600 | ~3.0 | ~40 | 舰炮 | ~25 | ~24 | 基础水面 |
| 护卫舰 | T1 Frigate | ~200 | ~4000 | ~2000 | ~1200 | ~2.8 | ~60 | 舰炮+鱼雷 | ~30 | ~28 | 反舰+反潜 |

##### T2 Land（T2 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型坦克 | Pillar | ~300 | ~6000 | ~3000 | ~1500 | — | ~3.0 | ~80 | 重炮 | ~30 | ~24 | T2 陆战核心 |
| 机动炮兵 | Demolisher | ~280 | ~5600 | ~2800 | ~1000 | — | ~2.8 | ~120 | 榴弹(溅射) | ~45 | ~22 | 远程压制 |
| 防空车 | T2 AA | ~200 | ~4000 | ~2000 | ~800 | — | ~3.0 | ~50 | 对空导弹群 | ~35 | ~20 | 区域防空 |
| 工程师 | T2 Engineer | ~150 | ~3000 | ~1500 | ~400 | — | ~2.5 | — | 无武装 | — | ~20 | 高级建造 |

##### T2 Air（T2 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 炮艇机 | T2 Gunship | ~250 | ~5000 | ~2500 | ~800 | ~3.5 | ~60 | 对地机枪+导弹 | ~22 | ~24 | 对地支援 |
| 战斗轰炸机 | T2 Fighter-Bomber | ~220 | ~4400 | ~2200 | ~700 | ~5.0 | ~50 | 对空+对地 | ~25 | ~25 | 多用途 |

##### T2 Naval（T2 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 驱逐舰 | T2 Destroyer | ~500 | ~10000 | ~5000 | ~3000 | ~2.5 | ~150 | 舰炮+鱼雷 | ~40 | ~30 | 反舰+反潜 |
| 巡洋舰 | T2 Cruiser | ~600 | ~12000 | ~6000 | ~2500 | ~2.5 | ~100 | 舰炮+导弹+防空 | ~45 | ~30 | 多用途 |

##### T3 Land（T3 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Titan | ~600 | ~12000 | ~6000 | ~3000 | — | ~3.0 | ~150 | 重激光 | ~30 | ~26 | T3 突击核心 |
| 重型坦克 | Loyalist | ~700 | ~14000 | ~7000 | ~4000 | — | ~2.8 | ~200 | 重炮 | ~32 | ~26 | T3 最重常规坦克 |
| 机动炮兵 | T3 Mobile Artillery | ~550 | ~11000 | ~5500 | ~2000 | — | ~2.5 | ~300 | 远程榴弹 | ~60 | ~24 | 超远程压制 |
| 工程师 | T3 Engineer | ~300 | ~6000 | ~3000 | ~600 | — | ~2.2 | — | 无武装 | — | ~24 | 最高级建造 |

##### T3 Air（T3 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T3 Spy Plane | ~200 | ~4000 | ~2000 | ~300 | ~7.0 | — | 无武装 | — | ~60 | 隐形侦察 |
| 空优战机 | T3 Air Superiority | ~500 | ~10000 | ~5000 | ~1000 | ~6.0 | ~150 | 对空导弹群 | ~30 | ~30 | 绝对制空 |
| 战略轰炸机 | T3 Strategic Bomber | ~800 | ~16000 | ~8000 | ~1500 | ~3.5 | ~500 | 战略炸弹(大溅射) | — | ~28 | 跨地图战略打击 |

##### T3 Naval（T3 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战列舰 | T3 Battleship | ~3000 | ~60000 | ~30000 | ~15000 | ~2.0 | ~800 | 重炮群 | ~60 | ~40 | 海上堡垒，UEF 最强海军 |

##### T4 Experimental（T3 Land Factory + Quantum Gate Upgrade 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | radar | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 移动工厂坦克 | Fatboy | ~20000 | ~300000 | ~60000 | ~5000 | ~3500(护盾) | ~2.5 | ~200(×4轨道炮) | 轨道炮群 | ~40 | ~30 | ~60 | UEF 标志性 T4。4门轨道炮高射速，自带护盾，**移动工厂可生产T1/T2/T3陆地单位**，有防空和鱼雷。弱点：近身后脆弱，护盾被破后 HP 不高。 |
| 潜水航母 | Atlantis | ~15000 | ~200000 | ~45000 | ~4000 | — | ~2.0 | ~100(防空) | 防空+鱼雷 | ~30 | ~30 | — | 可潜水隐蔽，搭载大量飞机，突袭利器。 |
| 战略炮 | Mavor | ~40000 | ~600000 | ~120000 | ~10000 | — | 0(固定) | ~5000 | 战略炮弹(大溅射) | ~∞(跨地图) | — | — | 超远程战略炮，可打击地图任意位置。造价极高，建造期经济脆弱。 |

##### T3.5 特殊

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 轨道卫星中心 | Novax Center | ~10000 | ~150000 | ~30000 | ~5000 | — | — | ~200(轨道炮) | 轨道炮(精确) | ~∞ | ~全图 | 发射卫星，提供全图视野和精确打击，卫星可被反卫星武器击落。 |

---

#### 2.2.2 Cybran 单位

##### T1 Land（T1 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Mantis | ~100 | ~2000 | ~1000 | ~500 | — | ~4.0 | ~30 | 激光 | ~22 | ~22 | Cybran T1 核心，速度最快，可爬陡坡 |
| 轻型炮兵 | Medusa | ~90 | ~1800 | ~900 | ~350 | — | ~3.5 | ~45 | 榴弹(溅射) | ~32 | ~20 | 机动炮兵 |
| 防空车 | T1 AA | ~70 | ~1400 | ~700 | ~400 | — | ~3.5 | ~20 | 对空导弹 | ~28 | ~18 | 专职防空 |
| 工程师 | T1 Engineer | ~50 | ~1000 | ~500 | ~200 | — | ~2.8 | — | 无武装 | — | ~16 | 建造/协助/回收 |

##### T1 Air（T1 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T1 Air Scout | ~40 | ~800 | ~400 | ~100 | ~6.0 | — | 无武装 | — | ~40 | 快速侦察 |
| 截击机 | T1 Interceptor | ~85 | ~1700 | ~850 | ~280 | ~5.5 | ~38 | 对空导弹 | ~20 | ~25 | 空战主力 |
| 攻击轰炸机 | T1 Attack Bomber | ~120 | ~2400 | ~1200 | ~380 | ~4.0 | ~75 | 炸弹(溅射) | — | ~22 | 对地轰炸 |

##### T1 Naval（T1 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 攻击艇 | T1 Attack Boat | ~110 | ~2200 | ~1100 | ~550 | ~3.0 | ~35 | 舰炮 | ~25 | ~24 | 基础水面 |
| 护卫舰 | T1 Frigate | ~190 | ~3800 | ~1900 | ~1100 | ~2.8 | ~55 | 舰炮+鱼雷 | ~30 | ~28 | 反舰+反潜 |

##### T2 Land（T2 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 跳跃Kbot | Hoplite | ~280 | ~5600 | ~2800 | ~1200 | — | ~3.2 | ~70 | 激光 | ~28 | ~22 | **可跳跃过地形障碍**，Cybran 签名单位 |
| 重型坦克 | Rhintok | ~320 | ~6400 | ~3200 | ~1600 | — | ~2.8 | ~90 | 重炮 | ~30 | ~24 | T2 陆战核心 |
| 隐形场发生器 | Deceiver | ~250 | ~5000 | ~2500 | ~600 | — | ~2.5 | — | 隐形场(被动) | — | ~22 | **生成隐形场覆盖友军** |
| 防空车 | T2 AA | ~200 | ~4000 | ~2000 | ~800 | — | ~3.0 | ~50 | 对空导弹群 | ~35 | ~20 | 区域防空 |
| 工程师 | T2 Engineer | ~150 | ~3000 | ~1500 | ~400 | — | ~2.5 | — | 无武装 | — | ~20 | 高级建造 |

##### T2 Air（T2 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 炮艇机 | T2 Gunship | ~240 | ~4800 | ~2400 | ~750 | ~3.5 | ~55 | 对地机枪+导弹 | ~22 | ~24 | 对地支援 |
| 战斗轰炸机 | T2 Fighter-Bomber | ~210 | ~4200 | ~2100 | ~650 | ~5.0 | ~48 | 对空+对地 | ~25 | ~25 | 多用途 |

##### T2 Naval（T2 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 驱逐舰 | T2 Destroyer | ~480 | ~9600 | ~4800 | ~2800 | ~2.5 | ~140 | 舰炮+鱼雷 | ~40 | ~30 | 反舰+反潜 |
| 巡洋舰 | T2 Cruiser | ~580 | ~11600 | ~5800 | ~2300 | ~2.5 | ~95 | 舰炮+导弹+防空 | ~45 | ~30 | 多用途 |

##### T3 Land（T3 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Loyalist | ~580 | ~11600 | ~5800 | ~2800 | — | ~3.0 | ~140 | 重激光 | ~30 | ~26 | T3 突击核心 |
| 重型坦克 | Brick | ~680 | ~13600 | ~6800 | ~3800 | — | ~2.5 | ~180 | 重炮 | ~32 | ~26 | T3 最重常规坦克 |
| 机动炮兵 | T3 Mobile Artillery | ~530 | ~10600 | ~5300 | ~1900 | — | ~2.5 | ~280 | 远程榴弹 | ~60 | ~24 | 超远程压制 |
| 工程师 | T3 Engineer | ~300 | ~6000 | ~3000 | ~600 | — | ~2.2 | — | 无武装 | — | ~24 | 最高级建造 |

##### T3 Air（T3 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T3 Spy Plane | ~200 | ~4000 | ~2000 | ~300 | ~7.0 | — | 无武装 | — | ~60 | **隐形侦察** |
| 空优战机 | T3 Air Superiority | ~480 | ~9600 | ~4800 | ~950 | ~6.0 | ~145 | 对空导弹群 | ~30 | ~30 | 绝对制空 |
| 战略轰炸机 | T3 Strategic Bomber | ~780 | ~15600 | ~7800 | ~1400 | ~3.5 | ~480 | 战略炸弹(大溅射) | — | ~28 | 跨地图战略打击 |

##### T3 Naval（T3 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 巡洋舰 | T3 Cruiser | ~2000 | ~40000 | ~20000 | ~8000 | ~2.0 | ~400 | 重炮+导弹 | ~50 | ~35 | Cybran 无 T3 战列舰，T3 巡洋舰是最高海军 |

##### T4 Experimental（T3 Land Factory + Quantum Gate Upgrade 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | radar | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 蜘蛛激光机器人 | Monkeylord | ~15000 | ~250000 | ~45000 | ~4500 | — | ~2.0 | ~1500(重型激光) | 重型激光(持续) | ~35 | ~30 | ~50 | Cybran 标志性 T4。**隐形能力**（需消耗能量），蜘蛛形多足，重型激光可秒杀 T3 单位。最早可出场的 T4 之一，timing rush 利器。弱点：HP 不高，被发现后怕集火。 |
| 重型飞艇 | Soul Ripper | ~12000 | ~200000 | ~36000 | ~3500 | — | ~3.5(空中) | ~200(×多武器) | 机枪+导弹+炸弹 | ~30 | ~30 | ~40 | 空中 T4，大量武器，对地压制。弱点：怕防空集火，坠毁损失大。 |
| 两栖蟹 | Megalith | ~18000 | ~280000 | ~54000 | ~6000 | — | ~2.0(水陆) | ~400(×2钳) | 重型钳+导弹 | ~30 | ~28 | ~40 | FA 新增。两栖，可潜水，**可生产 T3 陆地单位**。 |

---

#### 2.2.3 Aeon 单位

##### T1 Land（T1 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Aura | ~110 | ~2200 | ~1100 | ~550 | — | ~3.5 | ~32 | 定向能 | ~22 | ~22 | Aeon T1 核心 |
| 长射程坦克 | Aurora | ~130 | ~2600 | ~1300 | ~350 | — | ~3.0 | ~40 | 定向能 | **~30** | ~22 | **射程最长的 T1 坦克**，可风筝其他 T1。HP 最低。 |
| 防空车 | T1 AA | ~75 | ~1500 | ~750 | ~450 | — | ~3.2 | ~22 | 对空导弹 | ~28 | ~18 | 专职防空 |
| 工程师 | T1 Engineer | ~50 | ~1000 | ~500 | ~200 | — | ~2.8 | — | 无武装 | — | ~16 | 建造/协助/回收 |

##### T1 Air（T1 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T1 Air Scout | ~40 | ~800 | ~400 | ~100 | ~6.0 | — | 无武装 | — | ~40 | 快速侦察 |
| 截击机 | T1 Interceptor | ~88 | ~1760 | ~880 | ~290 | ~5.5 | ~39 | 对空导弹 | ~20 | ~25 | 空战主力 |
| 攻击轰炸机 | T1 Attack Bomber | ~125 | ~2500 | ~1250 | ~390 | ~4.0 | ~78 | 炸弹(溅射) | — | ~22 | 对地轰炸 |

##### T1 Naval（T1 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 攻击艇 | T1 Attack Boat | ~115 | ~2300 | ~1150 | ~580 | ~3.0 | ~38 | 舰炮 | ~25 | ~24 | 基础水面 |
| 护卫舰 | T1 Frigate | ~195 | ~3900 | ~1950 | ~1150 | ~2.8 | ~58 | 舰炮+鱼雷 | ~30 | ~28 | 反舰+反潜 |

##### T2 Land（T2 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型坦克 | Obsidian | ~350 | ~7000 | ~3500 | ~1500 | **~500(护盾)** | ~2.8 | ~85 | 定向能 | ~30 | ~24 | **自带护盾**，Aeon T2 签名单位 |
| 机动炮兵 | Serenity | ~300 | ~6000 | ~3000 | ~1000 | — | ~2.5 | ~110 | 榴弹(溅射) | ~45 | ~22 | 远程压制 |
| 防空车 | T2 AA | ~210 | ~4200 | ~2100 | ~800 | — | ~3.0 | ~52 | 对空导弹群 | ~35 | ~20 | 区域防空 |
| 工程师 | T2 Engineer | ~150 | ~3000 | ~1500 | ~400 | — | ~2.5 | — | 无武装 | — | ~20 | 高级建造 |

##### T2 Air（T2 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 炮艇机 | T2 Gunship | ~245 | ~4900 | ~2450 | ~780 | ~3.5 | ~58 | 对地定向能 | ~22 | ~24 | 对地支援 |
| 战斗轰炸机 | T2 Fighter-Bomber | ~215 | ~4300 | ~2150 | ~680 | ~5.0 | ~50 | 对空+对地 | ~25 | ~25 | 多用途 |

##### T2 Naval（T2 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 驱逐舰 | T2 Destroyer | ~490 | ~9800 | ~4900 | ~2900 | ~2.5 | ~145 | 舰炮+鱼雷 | ~40 | ~30 | 反舰+反潜 |
| 巡洋舰 | T2 Cruiser | ~590 | ~11800 | ~5900 | ~2400 | ~2.5 | ~98 | 舰炮+导弹+防空 | ~45 | ~30 | 多用途 |

##### T3 Land（T3 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Harbinger | ~650 | ~13000 | ~6500 | ~2500 | **~800(护盾)** | ~2.8 | ~160 | 重定向能 | ~30 | ~26 | **自带护盾**，Aeon T3 签名单位 |
| 重型坦克 | T3 Heavy Tank | ~720 | ~14400 | ~7200 | ~3500 | — | ~2.5 | ~190 | 重炮 | ~32 | ~26 | T3 最重常规坦克 |
| 机动炮兵 | T3 Mobile Artillery | ~560 | ~11200 | ~5600 | ~2000 | — | ~2.5 | ~290 | 远程榴弹 | ~60 | ~24 | 超远程压制 |
| 工程师 | T3 Engineer | ~300 | ~6000 | ~3000 | ~600 | — | ~2.2 | — | 无武装 | — | ~24 | 最高级建造 |

##### T3 Air（T3 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T3 Spy Plane | ~200 | ~4000 | ~2000 | ~300 | ~7.0 | — | 无武装 | — | ~60 | 隐形侦察 |
| 空优战机 | T3 Air Superiority | ~510 | ~10200 | ~5100 | ~1050 | ~6.0 | ~155 | 对空导弹群 | ~30 | ~30 | 绝对制空 |
| 战略轰炸机 | T3 Strategic Bomber | ~820 | ~16400 | ~8200 | ~1550 | ~3.5 | ~520 | 战略炸弹(大溅射) | — | ~28 | 跨地图战略打击 |

##### T3 Naval（T3 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战列舰 | T3 Battleship | ~3000 | ~60000 | ~30000 | ~14000 | ~2.0 | ~750 | 重炮群 | ~60 | ~40 | 海上堡垒 |

##### T4 Experimental（T3 Land Factory + Quantum Gate Upgrade 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | radar | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 巨型人形机甲 | Galactic Colossus | ~25000 | ~400000 | ~75000 | **~8000** | — | ~1.5 | ~1000(定向能) | 重型定向能(持续) | ~35 | ~35 | ~60 | Aeon 标志性 T4。**HP 最高的实验单位**（~8000），重型定向能武器可秒杀 T3。弱点：速度极慢（~1.5），可被风筝；造价最高。 |
| 飞行航母 | CZAR | ~18000 | ~300000 | ~54000 | ~5000 | — | ~3.0(空中) | ~200(防空) | 防空+定向能 | ~30 | ~35 | ~50 | 空中 T4 航母，可搭载大量飞机，提供大范围视野。弱点：被防空集火坠毁损失大。 |
| 潜水战舰 | Tempest | ~16000 | ~260000 | ~48000 | ~4500 | — | ~2.0(水下) | ~300(鱼雷+炮) | 鱼雷+舰炮 | ~35 | ~28 | ~40 | 水下 T4，可潜水隐蔽突袭。 |

---

#### 2.2.4 Seraphim 单位（仅 Forged Alliance）

##### T1 Land（T1 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Yenzyne | ~115 | ~2300 | ~1150 | ~600 | — | ~3.5 | ~35 | 量子武器 | ~22 | ~22 | 面板优于其他 T1 |
| 轻型炮兵 | Yathsou | ~105 | ~2100 | ~1050 | ~420 | — | ~3.2 | ~48 | 量子榴弹(溅射) | ~32 | ~20 | 机动炮兵 |
| 防空车 | T1 AA | ~78 | ~1560 | ~780 | ~480 | — | ~3.2 | ~24 | 对空量子弹 | ~28 | ~18 | 专职防空 |
| 工程师 | T1 Engineer | ~52 | ~1040 | ~520 | ~210 | — | ~2.8 | — | 无武装 | — | ~16 | 建造/协助/回收 |

##### T1 Air（T1 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T1 Air Scout | ~42 | ~840 | ~420 | ~110 | ~6.0 | — | 无武装 | — | ~40 | 快速侦察 |
| 截击机 | T1 Interceptor | ~92 | ~1840 | ~920 | ~310 | ~5.5 | ~42 | 对空量子弹 | ~20 | ~25 | 空战主力 |
| 攻击轰炸机 | T1 Attack Bomber | ~130 | ~2600 | ~1300 | ~410 | ~4.0 | ~82 | 量子炸弹(溅射) | — | ~22 | 对地轰炸 |

##### T1 Naval（T1 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 攻击艇 | T1 Attack Boat | ~120 | ~2400 | ~1200 | ~620 | ~3.0 | ~40 | 量子炮 | ~25 | ~24 | 基础水面 |
| 护卫舰 | T1 Frigate | ~205 | ~4100 | ~2050 | ~1200 | ~2.8 | ~60 | 量子炮+鱼雷 | ~30 | ~28 | 反舰+反潜 |

##### T2 Land（T2 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 重型坦克 | Ithalut | ~360 | ~7200 | ~3600 | ~1700 | — | ~2.8 | ~95 | 量子炮 | ~30 | ~24 | 面板优于其他 T2 重坦 |
| 机动炮兵 | Serenity | ~310 | ~6200 | ~3100 | ~1100 | — | ~2.5 | ~120 | 量子榴弹(溅射) | ~45 | ~22 | 远程压制 |
| 防空车 | T2 AA | ~215 | ~4300 | ~2150 | ~850 | — | ~3.0 | ~55 | 对空量子弹群 | ~35 | ~20 | 区域防空 |
| 工程师 | T2 Engineer | ~155 | ~3100 | ~1550 | ~420 | — | ~2.5 | — | 无武装 | — | ~20 | 高级建造 |

##### T2 Air（T2 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 炮艇机 | T2 Gunship | ~255 | ~5100 | ~2550 | ~820 | ~3.5 | ~62 | 对地量子武器 | ~22 | ~24 | 对地支援 |
| 战斗轰炸机 | T2 Fighter-Bomber | ~225 | ~4500 | ~2250 | ~720 | ~5.0 | ~53 | 对空+对地 | ~25 | ~25 | 多用途 |

##### T2 Naval（T2 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 驱逐舰 | T2 Destroyer | ~510 | ~10200 | ~5100 | ~3100 | ~2.5 | ~155 | 量子炮+鱼雷 | ~40 | ~30 | 反舰+反潜 |
| 巡洋舰 | T2 Cruiser | ~610 | ~12200 | ~6100 | ~2600 | ~2.5 | ~105 | 量子炮+导弹+防空 | ~45 | ~30 | 多用途 |

##### T3 Land（T3 Land Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击Kbot | Othuy | ~680 | ~13600 | ~6800 | ~2800 | **~1000(护盾)** | ~2.8 | ~170 | 重量子武器 | ~30 | ~26 | **自带护盾**，Seraphim T3 签名单位，面板最强 T3 突击 |
| 重型坦克 | T3 Heavy Tank | ~750 | ~15000 | ~7500 | ~4000 | — | ~2.5 | ~200 | 重量子炮 | ~32 | ~26 | T3 最重常规坦克 |
| 机动炮兵 | T3 Mobile Artillery | ~580 | ~11600 | ~5800 | ~2100 | — | ~2.5 | ~300 | 远程量子榴弹 | ~60 | ~24 | 超远程压制 |
| 工程师 | T3 Engineer | ~310 | ~6200 | ~3100 | ~620 | — | ~2.2 | — | 无武装 | — | ~24 | 最高级建造 |

##### T3 Air（T3 Air Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 侦察机 | T3 Spy Plane | ~210 | ~4200 | ~2100 | ~320 | ~7.0 | — | 无武装 | — | ~60 | 隐形侦察 |
| 空优战机 | T3 Air Superiority | ~530 | ~10600 | ~5300 | ~1100 | ~6.0 | ~165 | 对空量子弹群 | ~30 | ~30 | 绝对制空 |
| 战略轰炸机 | T3 Strategic Bomber | ~850 | ~17000 | ~8500 | ~1600 | ~3.5 | ~550 | 量子战略炸弹 | — | ~28 | 跨地图战略打击 |

##### T3 Naval（T3 Naval Factory 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | spd | dmg | atk_type | rng | vision | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 战列舰 | T3 Battleship | ~3100 | ~62000 | ~31000 | ~16000 | ~2.0 | ~850 | 重量子炮群 | ~60 | ~40 | 海上堡垒，面板最强 |

##### T4 Experimental（T3 Land Factory + Quantum Gate Upgrade 生产）

| name_zh | name_en | cost_m | cost_e | bt | hp | sh | spd | dmg | atk_type | rng | vision | radar | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 巨型机甲 | Ythotha | ~30000 | ~500000 | ~90000 | **~10000** | — | ~1.8 | ~1200(量子武器) | 重型量子武器(持续) | ~40 | ~35 | ~70 | Seraphim 标志性 T4。**HP 最高的实验单位**（~10000），重型量子武器。**特殊：死亡时产生量子风暴**（Othuy），持续战斗一段时间。造价最高但单体最强。 |
| 重型轰炸机 | Ahwassa | ~22000 | ~360000 | ~66000 | ~4000 | — | ~3.5(空中) | ~800(量子炸弹) | 量子战略炸弹(超大溅射) | — | ~35 | ~50 | 空中 T4 轰炸机，超大范围轰炸。可一波摧毁基地。弱点：被防空集火坠毁损失大。 |
| 重型运输 | Hauthug | ~12000 | ~200000 | ~36000 | ~3000 | — | ~3.0(空中) | ~100(防空) | 防空 | ~30 | ~30 | — | 空中 T4 运输机，可搭载大量 T3 单位空降。 |

---

### 2.3 实验单位（T4）对比总表

| game | faction | name_en | name_zh | cost_m | cost_e | hp | sh | spd | dmg | 特殊能力 | 威胁等级 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| TA | ARM | Krogoth | 克罗戈斯 | ~5000 | ~50000 | ~30000 | — | ~1.5 | ~1500 | 三足巨型机甲，重炮+导弹+激光 | ★★★★★ |
| TA | CORE | Karganeth | 卡加内斯 | ~5500 | ~55000 | ~35000 | — | ~1.3 | ~1800 | 巨型机甲，比 Krogoth 更硬更慢 | ★★★★★ |
| SupCom | UEF | Fatboy | 胖子 | ~20000 | ~300000 | ~5000 | ~3500 | ~2.5 | ~200(×4) | 移动工厂+护盾+防空+鱼雷 | ★★★★☆ |
| SupCom | UEF | Atlantis | 亚特兰蒂斯 | ~15000 | ~200000 | ~4000 | — | ~2.0 | ~100 | 潜水航母，搭载飞机 | ★★★☆☆ |
| SupCom | UEF | Mavor | 马弗 | ~40000 | ~600000 | ~10000 | — | 0 | ~5000 | 跨地图战略炮 | ★★★★★ |
| SupCom | Cybran | Monkeylord | 猴王 | ~15000 | ~250000 | ~4500 | — | ~2.0 | ~1500 | 隐形+重型激光 | ★★★★★ |
| SupCom | Cybran | Soul Ripper | 灵魂撕裂者 | ~12000 | ~200000 | ~3500 | — | ~3.5 | ~200(×多) | 空中T4，多武器 | ★★★★☆ |
| SupCom | Cybran | Megalith | 巨石 | ~18000 | ~280000 | ~6000 | — | ~2.0 | ~400(×2) | 两栖+可生产T3 | ★★★★☆ |
| SupCom | Aeon | Galactic Colossus | 银河巨像 | ~25000 | ~400000 | ~8000 | — | ~1.5 | ~1000 | HP最高(常规)，定向能 | ★★★★★ |
| SupCom | Aeon | CZAR | 沙皇 | ~18000 | ~300000 | ~5000 | — | ~3.0 | ~200 | 飞行航母，搭载飞机 | ★★★★☆ |
| SupCom | Aeon | Tempest | 风暴 | ~16000 | ~260000 | ~4500 | — | ~2.0 | ~300 | 潜水战舰 | ★★★☆☆ |
| SupCom | Seraphim | Ythotha | 伊索萨 | ~30000 | ~500000 | ~10000 | — | ~1.8 | ~1200 | HP最高，死亡产生量子风暴 | ★★★★★ |
| SupCom | Seraphim | Ahwassa | 阿瓦萨 | ~22000 | ~360000 | ~4000 | — | ~3.5 | ~800 | 空中T4轰炸，超大溅射 | ★★★★★ |
| SupCom | Seraphim | Hauthug | 豪图格 | ~12000 | ~200000 | ~3000 | — | ~3.0 | ~100 | 重型运输，空降T3 | ★★★☆☆ |

---

### 2.4 ACU（Armored Command Unit）对比表

| game | faction | unit | hp | spd | 特殊能力 | 升级模块 |
|---|---|---|---|---|---|---|
| TA | ARM/CORE | Commander | ~5000 | ~2.0 | D-Gun（消耗能量的近战秒杀武器），自爆（核弹级） | — |
| SupCom | UEF | ACU | ~4000 | ~2.5 | 建造T1建筑+单位 | 工程升级、战斗升级（重炮+护盾）、量子门升级（产T4）、科技升级 |
| SupCom | Cybran | ACU | ~3500 | ~2.8 | 建造T1建筑+单位 | 隐形升级、工程升级、战斗升级（激光+导弹）、量子门升级 |
| SupCom | Aeon | ACU | ~3800 | ~2.5 | 建造T1建筑+单位 | 护盾升级、工程升级、战斗升级（定向能+护盾）、量子门升级 |
| SupCom | Seraphim | ACU | ~4200 | ~2.5 | 建造T1建筑+单位 | 量子升级、工程升级、战斗升级（量子武器+护盾）、量子门升级 |

---

## 附录：游戏机制速查

### TA vs SupCom 机制对比

| 机制 | Total Annihilation | Supreme Commander |
|---|---|---|
| 资源系统 | Metal + Energy（双资源） | Mass + Energy（双资源） |
| 科技层级 | T1 / T2 / T3（实验） | T1 / T2 / T3 / T4（实验） |
| 生产机制 | 工厂队列 + 工程单位协助 | 工厂队列 + 工程师协助 |
| 指挥官 | Commander（D-Gun + 自爆） | ACU（可升级模块） |
| 视野系统 | 视野 + 雷达 + 声纳 | 视野 + 雷达 + 声纳 + 全图卫星 |
| 战略武器 | Big Bertha / Intimidator（长程炮） | Mavor（跨地图炮）/ Novax（卫星） |
| 实验单位 | Krogoth / Karganeth | 4族各2-3个T4 |
| 地形 | 高低差影响射击 | 地形阻挡射击 |
| 残骸回收 | 有（回收残骸获金属） | 有（回收残骸获质量） |
| 护盾 | 无 | 有（Aeon/Cybran/UEF/Seraphim部分单位） |

### SupCom Tech Tier 升级路径

```
T1 Factory → (升级) → T2 Factory → (升级) → T3 Factory → (量子门升级) → T4 Experimental
     ↕                    ↕                       ↕
  T1 Engineer         T2 Engineer             T3 Engineer
  (建造T1建筑)        (建造T2建筑)            (建造T3建筑+T4工厂)
```

### SupCom 经济建筑链

```
Mass Extractor T1 → (升级) → Mass Extractor T2 → (升级) → Mass Extractor T3
Power Plant T1 → (升级) → Power Plant T2 → Power Plant T3 (核聚变)
Mass Fabricator T2 (消耗能量产质量) → Mass Fabricator T3
```

---

## 数据来源与免责声明

1. **数据来源**：Total Annihilation Wiki (https://totalannihilation.fandom.com/)、Supreme Commander Wiki (https://supremecommander.fandom.com/)、游戏内实测经验、社区资料
2. **数据精度**：由于网络访问限制，部分精确数值基于开发者公开数据与社区资料整理，HP/cost 等数值为约值（±10%），缺失字段标注 `—`
3. **版本差异**：Supreme Commander 1 (原版) 与 Forged Alliance (FA) 资料片存在数值差异，本文档以 FA 最终版本为准（Seraphim 仅在 FA 中存在）
4. **建议校对**：实验单位（T4）数据建议二次校对 wiki 原文，尤其是精确的 cost_mass / cost_energy / build_time 数值

---

> 文档结束
