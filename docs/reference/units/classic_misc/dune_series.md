# 沙丘系列（Dune 2000 + Emperor: Battle for Dune）单位参考

> 数据版本: Dune 2000 (1998, Westwood) + Emperor: Battle for Dune (2001, Westwood)
> 数据源: 训练知识 + dune.fandom.com / emperorbattlefordune.fandom.com (未能实时抓取，部分数值为近似值)
> 采集日期: 2026-06-17
> 说明: 沙丘系列经济资源为"香料(Spice)"，采集后转化为信用点(Credits/Solaris)。电力由 Wind Trap 提供。沙虫(Sandworm)是地图环境威胁。Dune 2000 使用 C&C 引擎，Emperor 为全 3D 引擎。部分具体数值（HP/伤害/造价）基于训练知识估算，标注 `—` 的为不确定值。

---

## 游戏机制概述

### 通用机制
- **香料经济**：唯一资源。Harvester 从香料场采集，运回 Refinery 转化为 Credits。Spice Silo 存储溢出。
- **沙虫威胁**：沙虫在沙地随机游走，吞食沙地上的单位。Thumper 可吸引沙虫。岩石地面安全。
- **地形系统**：Rock（可建造，沙虫不可达）/ Sand（不可建造，沙虫活动区）/ Spice（可采集的沙地变种）/ Dune（减速部分单位）。
- **Concrete Slab**（Dune 2000）：建筑必须建在混凝土上，否则缓慢损毁。Emperor 中简化。
- **C&C 建造系统**：MCV 部署为 Construction Yard → 解锁建筑链 → 各建筑解锁单位。
- **Starport/CHOAM**：从轨道订购单位，由 Carryall 投送。价格浮动，有时比自造便宜，但需等待送达。
- **Power 系统**：Wind Trap 提供电力，电力不足则建筑功能停摆。

### Emperor 独有机制
- **子阵营(Subfaction)系统**：三大主家族各可结盟一个子阵营（共五个可选），解锁专属建筑和单位。
  - **Fremen**（弗雷曼人）：沙漠隐者，潜行+沙虫骑乘
  - **Ix**（伊克斯）：科技专家，全息投影+渗透
  - **Tleilaxu**（特莱拉克斯）：生物工程，僵尸+克隆
  - **Guild**（宇航公会）：空间折叠，传送+沙虫控制
  - **Sardaukar**（萨多卡）： imperial 精锐，重装步兵
- **战役子阵营可用性**：Atreides 可选 Fremen/Ix/Guild；Harkonnen 可选 Sardaukar/Tleilaxu/Ix；Ordos 可选 Guild/Tleilaxu/Ix。多人对战可自由搭配。
- **研究设施(Research Facility)**：Emperor 独有科技建筑，解锁高级单位和升级。

---

## 第一部分：阵营设计分析

---

### Atreides（亚崔迪家族）

#### 1. 设计哲学一句话
**"声望+精准+空军"** — 以荣誉作战、精准火力投射和空中优势为核心，用 Sonic 武器和 Ornithopter 实现高技术含量打击，均衡而可靠。

#### 2. 核心签名机制
- **Sonic Tank / 音波坦克**：发射直线音波束，穿透射程内所有单位，是系列最具辨识度的武器。高伤害+长射程+线型 AOE，但装甲薄弱。
- **Ornithopter / 扑翼机**：Dune 2000 中唯一拥有武装飞行器的阵营。可侦察+对地打击，提供空中投射能力。
- **Fremen 联盟**：Palace 可召唤 Fremen 隐身战士，具有狙击级别火力。Emperor 中 Fremen 是独立子阵营，Fedaykin 拥有 Weirding Module（声波攻击）。
- **Sniper / 狙击手**（Emperor）：静止时隐身，超远射程反步兵，提供前线视野和反隐。
- **精准而非蛮力**：单位整体均衡，不靠单一终极单位，靠兵种协同和空军优势。

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Combat Tank | Assault Tank (Emp) | — |
| 远程输出 | Quad | Mongoose (Emp) | Sonic Tank |
| 攻城/远程 | — | Siege Tank | Sonic Tank |
| 防空 | Rocket Tank | Mongoose / Rocket Tank | — |
| 骚扰 | Ornithopter / Sand Bike | Ornithopter | Sonic Tank |
| 侦察 | Trike / Sand Bike | Ornithopter / Air Drone | Fremen |
| 运输 | Carryall | APC | Carryall |
| 反步兵 | Light Infantry | Sniper (Emp) | Fremen |
| 经济 | Harvester | — | — |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | 均衡的 Trike+Quad 侦察骚扰 | 缺乏反重甲手段 |
| T2 | 4-8min | Combat/Siege Tank 成型，Ornithopter 空中骚扰 | Sonic Tank 尚未解锁 |
| T3 | 8min+ | Sonic Tank+Ornithopter 立体打击 | 终极单位不如 Devastator 耐打 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| **Sonic Tank + Combat Tank** | 输出+肉盾 | 坦克前排吸收火力，Sonic Tank 后排线型输出 |
| **Ornithopter + 地面推进** | 空地协同 | 扑翼机骚扰/侦察迫使对手分散，地面主力推进 |
| **Fremen + Sniper** | 隐形+狙击 | 双隐身单位，Fremen 反甲+Sniper 反步，无视野死角 |
| **Siege Tank + Rocket Tank** | 攻城+防空 | 迫击炮远程轰炸+火箭车防空保护 |
| **APC + Sniper** | 机动+狙杀 | APC 快速部署 Sniper 到关键位置 |
| **Mongoose + Assault Tank** (Emp) | 反甲+通用 | Mongoose 部署反甲+Assault Tank 通用输出 |
| **Carryall + Combat Tank** | 空投机动 | Carryall 运输坦克绕后突袭 |

#### 6. 生产机制
- **C&C 建造系统**：MCV → Construction Yard → 逐步解锁建筑链
- **建筑链**：Wind Trap → Refinery → Barracks → Light Factory → Heavy Factory → High-Tech Factory / Starport → Palace
- **空军独占**：Atreides 是 Dune 2000 唯一拥有武装飞行器（Ornithopter）的阵营，需 High-Tech Factory
- **Palace 召唤**：Fremen 从 Palace 免费召唤，有冷却时间
- **Starport**：可从 CHOAM 订购单位，价格浮动

#### 7. 机动哲学
- **空军主导**：Ornithopter 提供空中侦察和打击，不受地形限制
- **地面均衡**：Combat Tank 速度中等，Trike/Quad 提供早期机动
- **Carryall 空投**：可用 Carryall 运输车辆/步兵进行侧翼突袭
- **Emperor 加成**：Sand Bike 高速侦察，APC 快速运兵

#### 8. 视野与地图控制
- **Ornithopter 侦察**：Dune 2000 唯一飞行侦察单位
- **Air Drone**（Emperor）：无人侦察机，廉价高效
- **Fremen 隐身视野**：隐身单位提供前线持续视野
- **Sniper 隐身视野**（Emperor）：静止隐身+远视野
- **优势**：三阵营中视野能力最强，空中+隐身双重侦察手段

#### 9. 反制弱点
- **终极单位不够硬**：Sonic Tank 装甲薄弱，不如 Harkonnen Devastator 耐打
- **缺乏超级武器**：Dune 2000 中 Palace 只召唤 Fremen，无 Death Hand 式核打击
- **正面火力不足**：中期面对 Harkonnen 重装集群时，缺乏硬推能力
- **Sonic Tank 误伤**：线型攻击可能伤害友军，需要谨慎走位
- **空军被克制**：Ornithopter 被防空单位/火箭兵针对

#### 10. 强势时间窗
- **4-7 分钟**：Ornithopter 解锁后空中骚扰黄金期，对手防空未成型
- **8-12 分钟**：Sonic Tank 成型，线型输出在阵型密集时毁灭性
- **全程**：Fremen 隐身骚扰经济线，持续施压

#### 11. 经济模型
- **标准香料经济**：Harvester 采集 → Refinery 转化 → Credits
- **Starport 投机**：可利用 CHOAM 价格波动低价购入单位
- **无特殊经济加成**：经济效率取决于 Harvester 数量和保护
- **电力**：Wind Trap 提供电力，标准 C&C 电力管理

---

### Harkonnen（哈肯宁家族）

#### 1. 设计哲学一句话
**"重装+火力+残暴"** — 以最厚装甲、最猛火力和最残忍手段为核心，用 Devastator 碾碎一切，用 Death Hand 核弹抹平敌方基地。

#### 2. 核心签名机制
- **Devastator / 毁灭者**：系列最重型坦克。双联等离子炮，极高伤害+极厚装甲，可自爆造成大范围毁灭性伤害。慢但不可阻挡。
- **Death Hand Missile / 死亡之手导弹**（Dune 2000）：Palace 超级武器，核弹级区域毁灭。是 Dune 2000 三阵营中最强 Palace 能力。
- **Flamethrower / 火焰喷射器**（Emperor）：范围持续伤害，反步兵+区域拒止。
- **Inkvine Catapult / 墨藤投石车**（Emperor）：发射腐蚀性弹丸，持续 DoT 伤害，攻城利器。
- **Sardaukar 联盟**：Dune 2000 从 Palace 召唤 Sardaukar 精锐步兵；Emperor 中 Sardaukar 为可选子阵营，拥有最强步兵。
- **重甲碾压**：所有车辆单位比同位其他阵营更厚更慢更狠。

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Combat Tank (重) | Assault Tank (重) | Devastator |
| 远程输出 | Quad | Missile Tank (Emp) | Devastator |
| 攻城/远程 | — | Inkvine Catapult (Emp) | Death Hand (Palace) |
| 防空 | Rocket Tank | Missile Tank | — |
| 骚扰 | Buzzsaw (Emp) | Gunship (Emp) | Death Hand |
| 侦察 | Trike / Buzzsaw | Gunship | — |
| 运输 | Carryall | — | — |
| 反步兵 | Light Infantry | Flamethrower (Emp) | Sardaukar |
| 经济 | Harvester | — | — |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Combat Tank 最硬，正面强 | 机动差，侦察慢 |
| T2 | 4-8min | 重甲集群推线，对手难挡 | 缺乏空军，防空弱 |
| T3 | 8min+ | Devastator+Death Hand 终极碾压 | 经济压力大，转型慢 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| **Devastator + Missile Tank** | 重甲+防空 | Devastator 正面碾压+Missile Tank 防空掩护 |
| **Devastator 自爆 + Death Hand** | 双超级武器 | 自爆冲入敌阵+Death Hand 核弹补刀基地 |
| **Flamethrower + Sardaukar** | 区域拒止+精锐 | 火焰兵烧退步兵+Sardaukar 精锐收割 |
| **Inkvine Catapult + Assault Tank** | 攻城+护卫 | 投石车远程 DoT+坦克护卫防冲锋 |
| **Buzzsaw + Gunship** | 快速骚扰 | 地面 Buzzsaw 切后排+空中 Gunship 火力支援 |
| **Combat Tank 海 + Siege Tank** | 钢铁洪流 | 重甲坦克海正面+迫击炮远程支援 |
| **Sardaukar + Devastator** | 步坦协同 | 精锐步兵护驾+终极坦克推进 |

#### 6. 生产机制
- **C&C 建造系统**：同 Atreides，MCV → 建筑链
- **无空军**（Dune 2000）：Harkonnen 在 Dune 2000 无武装飞行器，只有 Carryall 运输
- **Palace 双能力**：Dune 2000 中 Palace 同时提供 Sardaukar 召唤和 Death Hand Missile 超级武器
- **Gunship**（Emperor）：Emperor 中 Harkonnen 获得 Gunship 重型攻击机，弥补空军短板

#### 7. 机动哲学
- **钢铁洪流**：慢速重甲集群推进，不追求机动，追求碾压
- **Buzzsaw 快速骚扰**（Emperor）：唯一的快速单位，用于早期骚扰
- **无空投能力**：Dune 2000 中缺乏武装空军，侧翼脆弱
- **Devastator 自爆机动**：残血 Devastator 冲入敌阵自爆，是独特的"机动"手段

#### 8. 视野与地图控制
- **视野最差**：无飞行侦察单位（Dune 2000），依赖地面单位缓慢推进
- **Gunship 侦察**（Emperor）：有所改善，但不如 Atreides Ornithopter 灵活
- **区域拒止**：Inkvine Catapult 的 DoT 弹药可封锁区域，间接控制地图
- **Death Hand 侦察需求**：超级武器需要目标视野，缺乏侦察时效率降低

#### 9. 反制弱点
- **机动性差**：所有单位慢，怕 hit-and-run 骚扰
- **早期空军空白**（Dune 2000）：无武装飞行器，怕空中骚扰
- **经济脆弱**：重甲单位造价高，Harvester 被骚扰则雪崩
- **怕 Deviator**：Ordos 的 Deviator 可临时控制 Devastator 反打
- **转型慢**：一旦走重甲路线很难转型反骚扰

#### 10. 强势时间窗
- **6-10 分钟**：Combat Tank 海+Siege Tank 正面推进，对手难以阻挡
- **12 分钟+**：Devastator 解锁+Death Hand 蓄能完毕，终极碾压期
- **全程正面**：任何正面交锋都不落下风，弱在侧翼和经济线

#### 11. 经济模型
- **标准香料经济**：同 Atreides
- **高消耗**：单位造价最高，需要更多 Harvester 支撑
- **Starport 缓解**：可从 CHOAM 低价订购弥补经济压力
- **无经济加成**：纯靠香料采集量

---

### Ordos（奥多斯家族）

#### 1. 设计哲学一句话
**"科技+生化+诡计"** — 以非法科技、化学武器和欺骗控制为核心，用 Deviator 窃取敌方单位，用 Saboteur 摧毁后方，用生化武器腐蚀一切。

#### 2. 核心签名机制
- **Deviator / 偏转器**：发射控制气体，临时将敌方单位转为己方控制。Dune 2000 和 Emperor 中的招牌武器，直接"借用"对手的终极单位。
- **Saboteur / 破坏者**：Palace 召唤的隐身破坏单位，潜入敌方基地摧毁建筑。
- **Chemical Trooper / 化学兵**（Emperor）：发射毒素气体，持续 DoT+区域拒止，反步兵利器。
- **Laser Tank / 激光坦克**（Emperor）：悬浮坦克，极高机动性，地形适应强。
- **Eye in the Sky / 天眼**（Emperor）：飞行破坏单位，可空投到敌方后方进行破坏。
- **Kobra / 眼镜蛇炮**（Emperor）：部署式远程火炮，部署后射程和精度大幅提升。
- **科技窃取**：Deviator 可窃取敌方终极单位（如 Devastator、Sonic Tank），以彼之道还施彼身。

#### 3. 角色分工矩阵

| 角色 \ 科技 | T1 | T2 | T3 |
|---|---|---|---|
| 肉盾/前排 | Combat Tank (快) | Laser Tank (Emp) | 借来的 Devastator |
| 远程输出 | Quad | Laser Tank | Deviator |
| 攻城/远程 | — | Kobra (Emp) | Kobra (部署) |
| 防空 | Rocket Tank | AA Trooper (Emp) | — |
| 骚扰 | Saboteur | Dust Scout (Emp) | Eye in the Sky |
| 侦察 | Trike / Dust Scout | Eye in the Sky | Deviator (窃取侦察) |
| 运输 | Carryall | APC (hover) | — |
| 反步兵 | Light Infantry | Chemical Trooper (Emp) | — |
| 经济 | Harvester | — | — |

#### 4. 科技树节奏

| 阶段 | 时间窗口 | 强势点 | 弱势点 |
|---|---|---|---|
| T1 | 0-4min | Combat Tank 最快，早期机动骚扰 | 正面火力不足 |
| T2 | 4-8min | Deviator 解锁，窃取对手单位反转 | 单位脆，正面弱 |
| T3 | 8min+ | Kobra+Deviator+Eye in the Sky 多线施压 | 终极正面交锋弱 |

#### 5. 核心协同组合

| 组合 | 类型 | 协同方式 |
|---|---|---|
| **Deviator + Combat Tank** | 窃取+输出 | Deviator 偷敌方坦克+自家坦克收割 |
| **Saboteur + Eye in the Sky** | 双线破坏 | 地面 Saboteur 破坏+空中 Eye in the Sky 补刀 |
| **Chemical Trooper + Kobra** | DoT+攻城 | 毒气封锁前线+Kobra 远程轰炸 |
| **Laser Tank 海** | 机动骚扰 | 悬浮坦克高机动 hit-and-run |
| **Deviator + 借来的 Devastator** | 以彼之道 | 偷来 Devastator 正面碾压原主人 |
| **Dust Scout + Saboteur** | 侦察+破坏 | 快速侦察定位+Saboteur 精准打击 |
| **Kobra 部署 + AA Trooper** | 阵地+防空 | Kobra 部署成炮塔+AA Trooper 防空保护 |

#### 6. 生产机制
- **C&C 建造系统**：同其他阵营
- **Palace 召唤**：Saboteur 从 Palace 免费召唤，有冷却
- **悬浮单位**（Emperor）：Laser Tank、Dust Scout、APC 均为悬浮，不受地形减速影响
- **Starport**：可从 CHOAM 订购单位

#### 7. 机动哲学
- **Hit-and-run**：Combat Tank 最快+Laser Tank 悬浮高机动，打完就跑
- **多线骚扰**：Saboteur 地面渗透+Eye in the Sky 空中破坏，多线施压
- **悬浮优势**（Emperor）：悬浮单位无视地形减速，沙丘地形如履平地
- **避免正面**：不追求正面交锋，靠诡计和机动取胜

#### 8. 视野与地图控制
- **Eye in the Sky 侦察**（Emperor）：飞行单位提供空中视野
- **Dust Scout 快速侦察**：高速悬浮侦察，快速扫图
- **Saboteur 隐身视野**：潜入敌方基地获取内部视野
- **中等**：不如 Atreides 的空军+隐身组合，但优于 Harkonnen

#### 9. 反制弱点
- **正面火力最弱**：单位伤害低，正面交锋几乎必败
- **单位脆弱**：装甲薄，被集火快速蒸发
- **Deviator 不稳定**：控制时间短，冷却长，不能依赖
- **怕反隐**：Saboteur 被反隐单位发现则任务失败
- **终极单位靠偷**：没有自己的超级坦克，依赖窃取对手的

#### 10. 强势时间窗
- **2-5 分钟**：Combat Tank 快速骚扰经济线，对手重甲未成型
- **6-9 分钟**：Deviator 解锁，偷取对手 T3 单位反打
- **8-12 分钟**：Kobra+Chemical+Eye in the Sky 多线施压高峰

#### 11. 经济模型
- **标准香料经济**：同其他阵营
- **低成本高效益**：单位造价中等偏低，靠 Deviator "免费"获取敌方高价单位
- **Saboteur 经济战**：破坏敌方 Refinery/Harvester 打击经济
- **Starport 补充**：可订购单位弥补产能不足

---

## 第二部分：单位数据表

> 字段说明: cost_credits = 信用点(香料转化); build_time = 秒; power_use = 电力消耗(负值=提供电力); hp = 生命值; speed = 游戏内速度; range = 游戏内距离; cooldown = 秒
> 标注 `≈` 的为近似值，`—` 为不确定

---

### Dune 2000 单位

---

#### 通用单位（三阵营共享）

##### Light Infantry（轻步兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 轻步兵 / Light Infantry |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈50 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈75 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage / atk_type | ≈5 / Normal (反步兵) |
| | cooldown / range | ≈0.5s / ≈3 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | — |

##### Trooper（火箭兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 火箭兵 / Trooper |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈100 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈60 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈30 / Explosive (反装甲) |
| | cooldown / range | ≈2s / ≈5 |
| | target / splash / bonus_vs | G+A / 0 / 车辆×2 |
| **技能** | active[] | — |
| | passive[] | — |

##### Engineer（工程师）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 工程师 / Engineer |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈250 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈50 |
| | armor / tags | 无甲 / 步兵, 生物 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage | — |
| **技能** | active[] | 占领敌方建筑（进入建筑即夺取控制权） |
| | passive[] | — |

##### Thumper（敲击者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 敲击者 / Thumper |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈100 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈50 |
| | armor / tags | 无甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈3 |
| **攻击** | damage | — |
| **技能** | active[] | 部署后持续敲击地面，吸引沙虫前往该位置 |
| | passive[] | — |

##### Harvester（采集车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 采集车 / Harvester |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Heavy Factory (或随 Refinery 附赠) |
| | cost_credits | ≈300 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈400 |
| | armor / tags | 重甲 / 机械, 车辆 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage | — |
| **技能** | active[] | 采集香料 → 运回 Refinery 转化为 Credits |
| | passive[] | 可被 Carryall 运输 |

##### MCV（移动建造车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 移动建造车 / Mobile Construction Vehicle |
| | faction / game / tier | 通用 / Dune 2000 / T0 |
| **生产** | built_from | Heavy Factory (需 Repair Pad) |
| | cost_credits | ≈1500 |
| | build_time | ≈30s |
| | power_use | 0 |
| **生存** | hp | ≈500 |
| | armor / tags | 重甲 / 机械, 车辆 |
| **机动** | speed | ≈1 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage | — |
| **技能** | active[] | 部署为 Construction Yard（建造场） |
| | passive[] | 可被 Carryall 运输 |

##### Trike（三轮摩托）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 三轮摩托 / Trike |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Light Factory |
| | cost_credits | ≈150 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈100 |
| | armor / tags | 轻甲 / 机械, 车辆 |
| **机动** | speed | ≈6（最快地面单位之一） |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈10 / Normal (反步兵) |
| | cooldown / range | ≈0.3s / ≈3 |
| | target / splash / bonus_vs | G / 0 / 步兵×1.5 |
| **技能** | active[] | — |
| | passive[] | — |

##### Quad（四轮装甲车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 四轮装甲车 / Quad |
| | faction / game / tier | 通用 / Dune 2000 / T1 |
| **生产** | built_from | Light Factory |
| | cost_credits | ≈200 |
| | build_time | ≈6s |
| | power_use | 0 |
| **生存** | hp | ≈150 |
| | armor / tags | 轻甲 / 机械, 车辆 |
| **机动** | speed | ≈5 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈15 / Piercing (反车辆) |
| | cooldown / range | ≈0.8s / ≈4 |
| | target / splash / bonus_vs | G+A / 0 / — |
| **技能** | active[] | — |
| | passive[] | — |

##### Siege Tank（攻城坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 攻城坦克 / Siege Tank |
| | faction / game / tier | 通用 / Dune 2000 / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈400 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈250 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈50 / Siege (攻城) |
| | cooldown / range | ≈3s / ≈7 |
| | target / splash / bonus_vs | G / ≈2 / 建筑×1.5 |
| **技能** | active[] | — |
| | passive[] | 最小射程限制（太近无法开火） |

##### Rocket Tank（火箭坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 火箭坦克 / Rocket Tank |
| | faction / game / tier | 通用 / Dune 2000 / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈350 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈180 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈25 / Explosive |
| | cooldown / range | ≈1.5s / ≈6 |
| | target / splash / bonus_vs | G+A / 0 / — |
| **技能** | active[] | — |
| | passive[] | 可对空 |

##### Carryall（运输机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 运输机 / Carryall |
| | faction / game / tier | 通用 / Dune 2000 / T2 |
| **生产** | built_from | High-Tech Factory |
| | cost_credits | ≈200 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈150 |
| | armor / tags | 轻甲 / 机械, 飞行 |
| **机动** | speed | ≈5 |
| | fly / hover / vision | true / true / ≈6 |
| **攻击** | damage | — |
| **技能** | active[] | 拾起并运输地面单位（Harvester/车辆/MCV）到指定位置 |
| | passive[] | 自动运输 Harvester 往返 Refinery（可设置） |

---

#### Atreides 专属单位（Dune 2000）

##### Combat Tank - Atreides（亚崔迪主战坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 主战坦克 / Combat Tank |
| | faction / game / tier | Atreides / Dune 2000 / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈300 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈300 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈35 / Explosive |
| | cooldown / range | ≈1.5s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 三阵营中最均衡：中甲/中速/中伤 |

##### Sonic Tank（音波坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 音波坦克 / Sonic Tank |
| | faction / game / tier | Atreides / Dune 2000 / T3 |
| **生产** | built_from | Heavy Factory (需升级) |
| | cost_credits | ≈500 |
| | build_time | ≈15s |
| | power_use | 0 |
| **生存** | hp | ≈200 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈60 / Sonic (线型穿透) |
| | cooldown / range | ≈2s / ≈7 |
| | target / splash / bonus_vs | G / 线型 / — |
| **技能** | active[] | — |
| | passive[] | 音波束穿透射程内所有单位（直线 AOE），可能误伤友军 |

##### Ornithopter（扑翼机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 扑翼机 / Ornithopter |
| | faction / game / tier | Atreides / Dune 2000 / T2 |
| **生产** | built_from | High-Tech Factory |
| | cost_credits | ≈300 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈100 |
| | armor / tags | 轻甲 / 机械, 飞行 |
| **机动** | speed | ≈7（最快单位） |
| | fly / hover / vision | true / true / ≈8 |
| **攻击** | damage / atk_type | ≈20 / Explosive (对地轰炸) |
| | cooldown / range | ≈2s / ≈3 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | 飞行侦察+对地轰炸 |
| | passive[] | Dune 2000 三阵营中唯一武装飞行器 |

##### Fremen（弗雷曼战士）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 弗雷曼战士 / Fremen |
| | faction / game / tier | Atreides / Dune 2000 / T3 |
| **生产** | built_from | Palace (免费召唤，有冷却) |
| | cost_credits | 0 (冷却 ≈60s) |
| | build_time | — |
| | power_use | 0 |
| **生存** | hp | ≈80 |
| | armor / tags | 轻甲 / 步兵, 生物, 隐身 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈25 / Piercing (狙击级) |
| | cooldown / range | ≈1s / ≈6 |
| | target / splash / bonus_vs | G / 0 / 步兵×2 |
| **技能** | active[] | — |
| | passive[] | 隐身（不移动时/移动时均隐身，除非靠近敌方单位） |

---

#### Harkonnen 专属单位（Dune 2000）

##### Combat Tank - Harkonnen（哈肯宁主战坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 主战坦克 / Combat Tank |
| | faction / game / tier | Harkonnen / Dune 2000 / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈300 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈400 |
| | armor / tags | 重甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈45 / Explosive |
| | cooldown / range | ≈1.8s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 三阵营中最硬最慢最高伤害 |

##### Devastator（毁灭者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 毁灭者 / Devastator |
| | faction / game / tier | Harkonnen / Dune 2000 / T3 |
| **生产** | built_from | Heavy Factory (需升级) |
| | cost_credits | ≈600 |
| | build_time | ≈20s |
| | power_use | 0 |
| **生存** | hp | ≈500 |
| | armor / tags | 重甲 / 机械, 坦克 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈80 / Explosive (双联等离子炮) |
| | cooldown / range | ≈2.5s / ≈5 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | 自爆（Overload）：蓄力后自毁，造成大范围毁灭性伤害(≈200) |
| | passive[] | 系列最重型坦克，最厚装甲+最高单体伤害 |

##### Sardaukar（萨多卡精锐）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 萨多卡精锐 / Sardaukar |
| | faction / game / tier | Harkonnen / Dune 2000 / T3 |
| **生产** | built_from | Palace (免费召唤，有冷却) |
| | cost_credits | 0 (冷却 ≈60s) |
| | build_time | — |
| | power_use | 0 |
| **生存** | hp | ≈120 |
| | armor / tags | 中甲 / 步兵, 生物, 精锐 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈30 / Normal |
| | cooldown / range | ≈0.8s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 游戏中最强基础步兵，高 HP+高伤害 |

##### Death Hand Missile（死亡之手导弹）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 死亡之手导弹 / Death Hand Missile |
| | faction / game / tier | Harkonnen / Dune 2000 / T3 |
| **生产** | built_from | Palace (超级武器) |
| | cost_credits | 0 (冷却 ≈300s/5min) |
| | build_time | — |
| | power_use | 0 |
| **生存** | hp | — |
| **机动** | speed | — |
| | fly / hover / vision | — |
| **攻击** | damage / atk_type | ≈500 / Siege (核弹级) |
| | cooldown / range | ≈300s / 全图 |
| | target / splash / bonus_vs | G / ≈10 / 建筑×2 |
| **技能** | active[] | 发射核导弹打击目标区域，毁灭性范围伤害 |
| | passive[] | Dune 2000 最强超级武器 |

---

#### Ordos 专属单位（Dune 2000）

##### Combat Tank - Ordos（奥多斯主战坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 主战坦克 / Combat Tank |
| | faction / game / tier | Ordos / Dune 2000 / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈300 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈220 |
| | armor / tags | 轻甲 / 机械, 坦克 |
| **机动** | speed | ≈5 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈25 / Explosive |
| | cooldown / range | ≈1.2s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 三阵营中最快最脆最低伤害 |

##### Deviator（偏转器）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 偏转器 / Deviator |
| | faction / game / tier | Ordos / Dune 2000 / T3 |
| **生产** | built_from | Heavy Factory (需升级) |
| | cost_credits | ≈550 |
| | build_time | ≈15s |
| | power_use | 0 |
| **生存** | hp | ≈250 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈10 / Gas (控制气体) |
| | cooldown / range | ≈5s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | 发射控制气体：命中敌方单位后临时转为己方控制（持续≈10s） |
| | passive[] | 可"窃取"敌方终极单位（如 Devastator、Sonic Tank）反打 |

##### Saboteur（破坏者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 破坏者 / Saboteur |
| | faction / game / tier | Ordos / Dune 2000 / T3 |
| **生产** | built_from | Palace (免费召唤，有冷却) |
| | cost_credits | 0 (冷却 ≈60s) |
| | build_time | — |
| | power_use | 0 |
| **生存** | hp | ≈50 |
| | armor / tags | 无甲 / 步兵, 生物, 隐身 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage | — |
| **技能** | active[] | 潜入敌方建筑后自毁，直接摧毁该建筑 |
| | passive[] | 隐身（靠近敌方单位/建筑时仍隐身） |

---

### Emperor: Battle for Dune 单位

---

#### Atreides 单位（Emperor）

##### Kindjal Infantry（金杰尔步兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 金杰尔步兵 / Kindjal Infantry |
| | faction / game / tier | Atreides / Emperor / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈150 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈100 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈40 / Explosive (导弹) |
| | cooldown / range | ≈2s / ≈5 |
| | target / splash / bonus_vs | G / 0 / 车辆×1.5 |
| **技能** | active[] | 部署(Deploy)：部署为固定模式，射程+伤害提升 |
| | passive[] | 部署后无法移动 |

##### Sniper（狙击手）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 狙击手 / Sniper |
| | faction / game / tier | Atreides / Emperor / T2 |
| **生产** | built_from | Barracks (需 Research Facility) |
| | cost_credits | ≈300 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈60 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈8 |
| **攻击** | damage / atk_type | ≈50 / Piercing (狙击) |
| | cooldown / range | ≈2s / ≈8 |
| | target / splash / bonus_vs | G / 0 / 步兵×3 |
| **技能** | active[] | — |
| | passive[] | 静止时隐身；远视野侦察 |

##### Grenadier（掷弹兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 掷弹兵 / Grenadier |
| | faction / game / tier | Atreides / Emperor / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈100 |
| | build_time | ≈4s |
| | power_use | 0 |
| **生存** | hp | ≈70 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈25 / Siege (手雷) |
| | cooldown / range | ≈1.5s / ≈4 |
| | target / splash / bonus_vs | G / ≈1 / 步兵×1.5 |
| **技能** | active[] | — |
| | passive[] | — |

##### Sand Bike（沙地摩托）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 沙地摩托 / Sand Bike |
| | faction / game / tier | Atreides / Emperor / T1 |
| **生产** | built_from | Factory |
| | cost_credits | ≈200 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈120 |
| | armor / tags | 轻甲 / 机械, 车辆 |
| **机动** | speed | ≈7 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈15 / Normal (双联炮) |
| | cooldown / range | ≈0.5s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 最快地面侦察单位之一 |

##### Mongoose（獴蛇导弹车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 獴蛇导弹车 / Mongoose |
| | faction / game / tier | Atreides / Emperor / T2 |
| **生产** | built_from | Factory |
| | cost_credits | ≈400 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈180 |
| | armor / tags | 中甲 / 机械, 车辆 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈35 / Explosive (导弹) |
| | cooldown / range | ≈1.5s / ≈5 |
| | target / splash / bonus_vs | G+A / 0 / 车辆×1.5 |
| **技能** | active[] | 部署(Deploy)：部署后射程+伤害提升 |
| | passive[] | 可对空 |

##### Assault Tank - Atreides（亚崔迪突击坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 突击坦克 / Assault Tank |
| | faction / game / tier | Atreides / Emperor / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈350 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈350 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈40 / Explosive |
| | cooldown / range | ≈1.5s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 均衡型 MBT |

##### Sonic Tank - Emperor（音波坦克 Emperor 版）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 音波坦克 / Sonic Tank |
| | faction / game / tier | Atreides / Emperor / T3 |
| **生产** | built_from | Heavy Factory (需 Research Facility) |
| | cost_credits | ≈600 |
| | build_time | ≈15s |
| | power_use | 0 |
| **生存** | hp | ≈250 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈7 |
| **攻击** | damage / atk_type | ≈70 / Sonic (线型穿透) |
| | cooldown / range | ≈2s / ≈8 |
| | target / splash / bonus_vs | G / 线型 / — |
| **技能** | active[] | — |
| | passive[] | 音波束穿透射程内所有单位 |

##### APC（装甲运兵车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 装甲运兵车 / APC |
| | faction / game / tier | Atreides / Emperor / T2 |
| **生产** | built_from | Factory |
| | cost_credits | ≈400 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈200 |
| | armor / tags | 中甲 / 机械, 车辆 |
| **机动** | speed | ≈5 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈15 / Normal (机枪) |
| | cooldown / range | ≈0.5s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | 运输步兵（≈3-5 个），可卸载 |
| | passive[] | — |

##### Repair Vehicle（维修车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 维修车 / Repair Vehicle |
| | faction / game / tier | Atreides / Emperor / T2 |
| **生产** | built_from | Factory |
| | cost_credits | ≈300 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈150 |
| | armor / tags | 中甲 / 机械, 车辆 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage | — |
| **技能** | active[] | 维修附近机械单位（持续回血） |
| | passive[] | — |

##### Ornithopter - Emperor（扑翼机 Emperor 版）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 扑翼机 / Ornithopter |
| | faction / game / tier | Atreides / Emperor / T2 |
| **生产** | built_from | Hangar |
| | cost_credits | ≈350 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈120 |
| | armor / tags | 轻甲 / 机械, 飞行 |
| **机动** | speed | ≈8 |
| | fly / hover / vision | true / true / ≈8 |
| **攻击** | damage / atk_type | ≈25 / Explosive (对地导弹) |
| | cooldown / range | ≈1.5s / ≈4 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | 飞行侦察+对地攻击 |
| | passive[] | — |

##### Air Drone（空中无人侦察机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 空中无人侦察机 / Air Drone |
| | faction / game / tier | Atreides / Emperor / T1 |
| **生产** | built_from | Hangar |
| | cost_credits | ≈150 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈50 |
| | armor / tags | 轻甲 / 机械, 飞行 |
| **机动** | speed | ≈9 |
| | fly / hover / vision | true / true / ≈8 |
| **攻击** | damage | — |
| **技能** | active[] | 飞行侦察 |
| | passive[] | 廉价高效侦察单位 |

---

#### Harkonnen 单位（Emperor）

##### Flamethrower Infantry（火焰兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 火焰兵 / Flamethrower Infantry |
| | faction / game / tier | Harkonnen / Emperor / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈120 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈90 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage / atk_type | ≈20 / Siege (火焰, DoT) |
| | cooldown / range | ≈1s / ≈3 |
| | target / splash / bonus_vs | G / ≈2 / 步兵×2 |
| **技能** | active[] | — |
| | passive[] | 火焰持续伤害(DoT)，区域拒止 |

##### Buzzsaw（圆锯车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 圆锯车 / Buzzsaw |
| | faction / game / tier | Harkonnen / Emperor / T1 |
| **生产** | built_from | Factory |
| | cost_credits | ≈250 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈150 |
| | armor / tags | 轻甲 / 机械, 车辆 |
| **机动** | speed | ≈6 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈15 / Normal (圆锯) + ≈10 / Normal (机枪) |
| | cooldown / range | ≈0.5s / ≈2 |
| | target / splash / bonus_vs | G / 0 / 步兵×2 |
| **技能** | active[] | — |
| | passive[] | 圆锯碾压步兵，近战范围高效反步 |

##### Assault Tank - Harkonnen（哈肯宁突击坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 突击坦克 / Assault Tank |
| | faction / game / tier | Harkonnen / Emperor / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈400 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈450 |
| | armor / tags | 重甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈50 / Explosive |
| | cooldown / range | ≈1.8s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 三阵营中最硬最慢最高伤害的 MBT |

##### Missile Tank（导弹坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 导弹坦克 / Missile Tank |
| | faction / game / tier | Harkonnen / Emperor / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈450 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈200 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈35 / Explosive (导弹齐射) |
| | cooldown / range | ≈2s / ≈7 |
| | target / splash / bonus_vs | G+A / 0 / — |
| **技能** | active[] | — |
| | passive[] | 远程火力支援+可对空 |

##### Inkvine Catapult（墨藤投石车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 墨藤投石车 / Inkvine Catapult |
| | faction / game / tier | Harkonnen / Emperor / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈500 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈180 |
| | armor / tags | 中甲 / 机械, 车辆 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈7 |
| **攻击** | damage / atk_type | ≈40 / Siege (腐蚀弹, DoT) |
| | cooldown / range | ≈3s / ≈8 |
| | target / splash / bonus_vs | G / ≈2 / 建筑×1.5 |
| **技能** | active[] | — |
| | passive[] | 弹丸落地后持续腐蚀伤害(DoT)，区域拒止 |

##### Devastator - Emperor（毁灭者 Emperor 版）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 毁灭者 / Devastator |
| | faction / game / tier | Harkonnen / Emperor / T3 |
| **生产** | built_from | Heavy Factory (需 Research Facility) |
| | cost_credits | ≈700 |
| | build_time | ≈20s |
| | power_use | 0 |
| **生存** | hp | ≈600 |
| | armor / tags | 重甲 / 机械, 坦克 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈90 / Explosive (双联等离子炮) |
| | cooldown / range | ≈2.5s / ≈6 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | 自爆(Overload)：蓄力后自毁，大范围毁灭性伤害(≈300) |
| | passive[] | 系列最重坦克 |

##### Gunship（武装炮艇机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 武装炮艇机 / Gunship |
| | faction / game / tier | Harkonnen / Emperor / T2 |
| **生产** | built_from | Hangar |
| | cost_credits | ≈500 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈200 |
| | armor / tags | 中甲 / 机械, 飞行 |
| **机动** | speed | ≈6 |
| | fly / hover / vision | true / true / ≈7 |
| **攻击** | damage / atk_type | ≈40 / Explosive (重炮) |
| | cooldown / range | ≈2s / ≈5 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | — |
| | passive[] | Emperor 中 Harkonnen 的主力空军 |

---

#### Ordos 单位（Emperor）

##### Laser Trooper（激光步兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 激光步兵 / Laser Trooper |
| | faction / game / tier | Ordos / Emperor / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈80 |
| | build_time | ≈4s |
| | power_use | 0 |
| **生存** | hp | ≈70 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈12 / Energy (激光) |
| | cooldown / range | ≈0.8s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 激光即时命中，无弹道延迟 |

##### Chemical Trooper（化学兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 化学兵 / Chemical Trooper |
| | faction / game / tier | Ordos / Emperor / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈130 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈90 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage / atk_type | ≈15 / Poison (毒气, DoT) |
| | cooldown / range | ≈1s / ≈3 |
| | target / splash / bonus_vs | G / ≈2 / 步兵×2 |
| **技能** | active[] | — |
| | passive[] | 毒气持续伤害(DoT)，区域拒止 |

##### AA Trooper（防空步兵）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 防空步兵 / AA Trooper |
| | faction / game / tier | Ordos / Emperor / T1 |
| **生产** | built_from | Barracks |
| | cost_credits | ≈120 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈70 |
| | armor / tags | 轻甲 / 步兵, 生物 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈25 / Explosive (防空导弹) |
| | cooldown / range | ≈1.5s / ≈6 |
| | target / splash / bonus_vs | A / 0 / 飞行×2 |
| **技能** | active[] | — |
| | passive[] | 专用防空，无法对地 |

##### Dust Scout（沙尘侦察车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 沙尘侦察车 / Dust Scout |
| | faction / game / tier | Ordos / Emperor / T1 |
| **生产** | built_from | Factory |
| | cost_credits | ≈200 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈120 |
| | armor / tags | 轻甲 / 机械, 车辆, 悬浮 |
| **机动** | speed | ≈7 |
| | fly / hover / vision | false / true / ≈6 |
| **攻击** | damage / atk_type | ≈15 / Normal (激光) |
| | cooldown / range | ≈0.5s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 悬浮单位，无视地形减速 |

##### Laser Tank（激光坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 激光坦克 / Laser Tank |
| | faction / game / tier | Ordos / Emperor / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈450 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈250 |
| | armor / tags | 中甲 / 机械, 坦克, 悬浮 |
| **机动** | speed | ≈6 |
| | fly / hover / vision | false / true / ≈5 |
| **攻击** | damage / atk_type | ≈30 / Energy (激光) |
| | cooldown / range | ≈0.8s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 悬浮坦克，高机动+即时命中激光，hit-and-run 利器 |

##### Kobra（眼镜蛇炮）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 眼镜蛇炮 / Kobra |
| | faction / game / tier | Ordos / Emperor / T2 |
| **生产** | built_from | Heavy Factory |
| | cost_credits | ≈500 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈200 |
| | armor / tags | 中甲 / 机械, 车辆 |
| **机动** | speed | ≈2 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈45 / Siege (等离子弹) |
| | cooldown / range | ≈2.5s / ≈7 (部署后 ≈9) |
| | target / splash / bonus_vs | G / ≈2 / 建筑×1.5 |
| **技能** | active[] | 部署(Deploy)：固定为炮塔模式，射程+精度大幅提升 |
| | passive[] | 移动模式下射程短且精度低 |

##### Deviator - Emperor（偏转器 Emperor 版）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 偏转器 / Deviator |
| | faction / game / tier | Ordos / Emperor / T3 |
| **生产** | built_from | Heavy Factory (需 Research Facility) |
| | cost_credits | ≈650 |
| | build_time | ≈15s |
| | power_use | 0 |
| **生存** | hp | ≈280 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈10 / Gas (控制气体) |
| | cooldown / range | ≈5s / ≈6 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | 发射控制气体：命中敌方单位后临时转为己方控制（持续≈12s） |
| | passive[] | 可窃取敌方单位（含 Devastator、Sonic Tank 等终极单位） |

##### APC - Ordos（悬浮运兵车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 悬浮运兵车 / APC |
| | faction / game / tier | Ordos / Emperor / T2 |
| **生产** | built_from | Factory |
| | cost_credits | ≈400 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈220 |
| | armor / tags | 中甲 / 机械, 车辆, 悬浮 |
| **机动** | speed | ≈5 |
| | fly / hover / vision | false / true / ≈5 |
| **攻击** | damage / atk_type | ≈15 / Energy (激光) |
| | cooldown / range | ≈0.8s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | 运输步兵（≈3-5 个），可卸载 |
| | passive[] | 悬浮单位，无视地形 |

##### Eye in the Sky（天眼飞行器）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 天眼飞行器 / Eye in the Sky |
| | faction / game / tier | Ordos / Emperor / T2 |
| **生产** | built_from | Hangar |
| | cost_credits | ≈400 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈100 |
| | armor / tags | 轻甲 / 机械, 飞行 |
| **机动** | speed | ≈6 |
| | fly / hover / vision | true / true / ≈7 |
| **攻击** | damage | — |
| **技能** | active[] | 投放 Saboteur（破坏者）到目标位置：可空投到敌方后方进行破坏 |
| | passive[] | 飞行侦察+破坏者空投平台 |

---

#### 子阵营单位（Emperor）

---

##### Fremen 子阵营

> 建筑需求: Fremen Camp
> 设计理念: 沙漠隐者，潜行+沙虫亲和。Fedaykin 是核心单位，隐身+声波武器+近战。

###### Fedaykin（弗雷曼死士）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 弗雷曼死士 / Fedaykin |
| | faction / game / tier | Fremen (子阵营) / Emperor / T2 |
| **生产** | built_from | Fremen Camp |
| | cost_credits | ≈400 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈120 |
| | armor / tags | 轻甲 / 步兵, 生物, 隐身, 精锐 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈7 |
| **攻击** | damage / atk_type | ≈35 / Sonic (Weirding Module 声波) |
| | cooldown / range | ≈1.5s / ≈6 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 永久隐身（靠近敌方仍隐身）；沙漠地形移速加成 |

###### Fremen Warrior（弗雷曼战士）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 弗雷曼战士 / Fremen Warrior |
| | faction / game / tier | Fremen (子阵营) / Emperor / T1 |
| **生产** | built_from | Fremen Camp |
| | cost_credits | ≈250 |
| | build_time | ≈6s |
| | power_use | 0 |
| **生存** | hp | ≈90 |
| | armor / tags | 轻甲 / 步兵, 生物, 隐身 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈25 / Piercing (狙击步枪) |
| | cooldown / range | ≈1s / ≈6 |
| | target / splash / bonus_vs | G / 0 / 步兵×2 |
| **技能** | active[] | — |
| | passive[] | 隐身；沙漠地形移速加成 |

---

##### Ix 子阵营

> 建筑需求: Ix Research Facility
> 设计理念: 非法科技专家，全息投影欺骗+渗透破坏。Projector 是核心单位，创造假部队迷惑敌人。

###### Projector（投影车）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 投影车 / Projector |
| | faction / game / tier | Ix (子阵营) / Emperor / T2 |
| **生产** | built_from | Ix Research Facility |
| | cost_credits | ≈500 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈150 |
| | armor / tags | 中甲 / 机械, 车辆 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage | — |
| **技能** | active[] | 全息投影：复制己方单位的全息影像（不造成伤害，但吸引敌方火力） |
| | passive[] | 影像被攻击时消失；用于迷惑敌人、吸收火力 |

###### Infiltrator（渗透者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 渗透者 / Infiltrator |
| | faction / game / tier | Ix (子阵营) / Emperor / T2 |
| **生产** | built_from | Ix Research Facility |
| | cost_credits | ≈400 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈60 |
| | armor / tags | 无甲 / 步兵, 生物, 隐身 |
| **机动** | speed | ≈4 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage | — |
| **技能** | active[] | 渗透敌方建筑：夺取建筑控制权 / 窃取科技 / 破坏建筑 |
| | passive[] | 隐身 |

---

##### Tleilaxu 子阵营

> 建筑需求: Tleilaxu Flesh Vat
> 设计理念: 生物工程邪教，僵尸感染+克隆复生。Contaminator 是核心单位，击杀敌人后将其转化为更多僵尸。

###### Contaminator（感染者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 感染者 / Contaminator |
| | faction / game / tier | Tleilaxu (子阵营) / Emperor / T1 |
| **生产** | built_from | Tleilaxu Flesh Vat |
| | cost_credits | ≈150 |
| | build_time | ≈5s |
| | power_use | 0 |
| **生存** | hp | ≈100 |
| | armor / tags | 生物 / 步兵, 生物, 不死 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈4 |
| **攻击** | damage / atk_type | ≈15 / Normal (近战感染) |
| | cooldown / range | ≈1s / ≈1 (近战) |
| | target / splash / bonus_vs | G / 0 / 步兵×2 |
| **技能** | active[] | — |
| | passive[] | 击杀敌方步兵后，将其尸体转化为新的 Contaminator（自我增殖） |

###### Ghola（古拉/克隆体）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 古拉/克隆体 / Ghola |
| | faction / game / tier | Tleilaxu (子阵营) / Emperor / T2 |
| **生产** | built_from | Tleilaxu Flesh Vat |
| | cost_credits | ≈200 |
| | build_time | ≈6s |
| | power_use | 0 |
| **生存** | hp | ≈80 |
| | armor / tags | 轻甲 / 步兵, 生物, 克隆 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈5 |
| **攻击** | damage / atk_type | ≈20 / Normal |
| | cooldown / range | ≈1s / ≈4 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 克隆己方阵亡步兵（低成本的复制单位，属性略弱于原版） |

---

##### Guild 子阵营

> 建筑需求: Guild Palais
> 设计理念: 宇航公会的空间折叠科技，传送+沙虫控制。NIAB Tank 可瞬移，Guild Maker 可骑乘沙虫。

###### NIAB Tank（NIAB 坦克）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | NIAB 坦克 / NIAB Tank |
| | faction / game / tier | Guild (子阵营) / Emperor / T3 |
| **生产** | built_from | Guild Palais |
| | cost_credits | ≈600 |
| | build_time | ≈15s |
| | power_use | 0 |
| **生存** | hp | ≈300 |
| | armor / tags | 中甲 / 机械, 坦克 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈50 / Energy (等离子炮) |
| | cooldown / range | ≈1.5s / ≈5 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | 空间折叠传送(Teleport)：可瞬移到地图任意已探索位置（有冷却） |
| | passive[] | — |

###### Guild Maker（公会驭虫者）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 公会驭虫者 / Guild Maker |
| | faction / game / tier | Guild (子阵营) / Emperor / T3 |
| **生产** | built_from | Guild Palais |
| | cost_credits | ≈700 |
| | build_time | ≈18s |
| | power_use | 0 |
| **生存** | hp | ≈400 |
| | armor / tags | 生物 / 巨型, 沙虫 |
| **机动** | speed | ≈5 (沙地) / ≈1 (岩石) |
| | fly / hover / vision | false / false / ≈7 |
| **攻击** | damage / atk_type | ≈80 / Normal (吞噬) |
| | cooldown / range | ≈1s / ≈2 (近战) |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | 吞噬：直接消灭沙地上的小型单位 |
| | passive[] | 可控沙虫，不受野 生沙虫攻击；沙地高速移动，岩石极慢 |

###### Guild Transport（公会运输机）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 公会运输机 / Guild Transport |
| | faction / game / tier | Guild (子阵营) / Emperor / T2 |
| **生产** | built_from | Guild Palais |
| | cost_credits | ≈500 |
| | build_time | ≈10s |
| | power_use | 0 |
| **生存** | hp | ≈150 |
| | armor / tags | 轻甲 / 机械, 飞行 |
| **机动** | speed | ≈5 |
| | fly / hover / vision | true / true / ≈6 |
| **攻击** | damage | — |
| **技能** | active[] | 空间折叠运输：将地面单位瞬移到地图任意已探索位置 |
| | passive[] | — |

---

##### Sardaukar 子阵营

> 建筑需求: Sardaukar Camp
> 设计理念: 皇帝精锐禁卫军，全系列最强步兵。高 HP+高伤害+双武器，正面碾压一切步兵。

###### Sardaukar Warrior（萨多卡战士）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 萨多卡战士 / Sardaukar Warrior |
| | faction / game / tier | Sardaukar (子阵营) / Emperor / T2 |
| **生产** | built_from | Sardaukar Camp |
| | cost_credits | ≈350 |
| | build_time | ≈8s |
| | power_use | 0 |
| **生存** | hp | ≈200 |
| | armor / tags | 中甲 / 步兵, 生物, 精锐 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈6 |
| **攻击** | damage / atk_type | ≈30 / Normal (步枪) + ≈25 / Explosive (手雷) |
| | cooldown / range | ≈0.8s / ≈5 |
| | target / splash / bonus_vs | G / 0 / — |
| **技能** | active[] | — |
| | passive[] | 双武器系统（步枪+手雷），反步+反甲兼顾 |

###### Sardaukar Elite（萨多卡精英）

| 分类 | 字段 | 值 |
|---|---|---|
| **身份** | name_zh / name_en | 萨多卡精英 / Sardaukar Elite |
| | faction / game / tier | Sardaukar (子阵营) / Emperor / T3 |
| **生产** | built_from | Sardaukar Camp (需 Research Facility) |
| | cost_credits | ≈500 |
| | build_time | ≈12s |
| | power_use | 0 |
| **生存** | hp | ≈300 |
| | armor / tags | 重甲 / 步兵, 生物, 精锐 |
| **机动** | speed | ≈3 |
| | fly / hover / vision | false / false / ≈7 |
| **攻击** | damage / atk_type | ≈40 / Normal (重型步枪) + ≈35 / Explosive (榴弹) |
| | cooldown / range | ≈0.6s / ≈6 |
| | target / splash / bonus_vs | G / ≈1 / — |
| **技能** | active[] | — |
| | passive[] | 系列最强步兵，重甲+高 HP+双武器+高射速 |

---

### 三阵营 Combat Tank 对比（Dune 2000）

| 属性 | Atreides | Harkonnen | Ordos |
|---|---|---|---|
| HP | ≈300 | ≈400 | ≈220 |
| 伤害 | ≈35 | ≈45 | ≈25 |
| 速度 | ≈4 | ≈3 | ≈5 |
| 装甲 | 中甲 | 重甲 | 轻甲 |
| 定位 | 均衡型 | 重甲碾压 | 机动骚扰 |
| 冷却 | ≈1.5s | ≈1.8s | ≈1.2s |

### 三阵营 T3 签名单位对比

| 属性 | Sonic Tank (Atr) | Devastator (Har) | Deviator (Ord) |
|---|---|---|---|
| HP | ≈200 | ≈500 | ≈250 |
| 伤害 | ≈60 (线型) | ≈80 | ≈10 (控制) |
| 射程 | ≈7 | ≈5 | ≈5 |
| 速度 | ≈3 | ≈2 | ≈3 |
| 特殊 | 线型穿透 AOE | 自爆(≈200) | 临时控制敌方单位 |
| 定位 | 远程线型输出 | 超重正面碾压 | 以敌制敌 |

### 三阵营 Palace 能力对比（Dune 2000）

| 阵营 | Palace 产出 | 类型 | 效果 |
|---|---|---|---|
| Atreides | Fremen | 召唤单位 | 隐身狙击步兵，免费召唤有冷却 |
| Harkonnen | Sardaukar + Death Hand | 召唤+超级武器 | 精锐步兵 + 核弹级导弹(冷却5min) |
| Ordos | Saboteur | 召唤单位 | 隐身破坏者，潜入摧毁建筑 |

---

## 附：关键建筑一览

### 通用建筑（两作共有）

| 建筑 | 功能 | 备注 |
|---|---|---|
| Construction Yard | 基地核心，解锁建造链 | 由 MCV 部署 |
| Wind Trap | 电力来源 | 提供 Power |
| Concrete Slab | 防止建筑损毁 | Dune 2000 独有机制 |
| Spice Refinery | 香料加工，附赠 1 Harvester | 经济核心 |
| Spice Silo | 存储溢出香料 | 防止香料浪费 |
| Barracks | 步兵生产 | — |
| Light Factory / Factory | 轻型车辆生产 | Trike/Quad/Sand Bike 等 |
| Heavy Factory | 坦克生产 | Combat Tank/Siege Tank/T3 单位 |
| High-Tech Factory / Hangar | 空军生产 | Carryall/Ornithopter/Gunship 等 |
| Starport | CHOAM 单位订购 | 价格浮动，Carryall 投送 |
| Repair Pad | 车辆维修 | — |
| Gun Turret | 防御建筑 | 反步兵/反车辆 |
| Rocket Turret | 防御建筑 | 防空+反车辆 |
| Palace | 超级武器/精锐单位 | 各阵营不同 |

### Emperor 独有建筑

| 建筑 | 功能 | 备注 |
|---|---|---|
| Research Facility | 科技升级，解锁 T3 单位 | Emperor 独有 |
| Fremen Camp | Fremen 子阵营单位生产 | 需结盟 Fremen |
| Ix Research Facility | Ix 子阵营单位生产 | 需结盟 Ix |
| Tleilaxu Flesh Vat | Tleilaxu 子阵营单位生产 | 需结盟 Tleilaxu |
| Guild Palais | Guild 子阵营单位生产 | 需结盟 Guild |
| Sardaukar Camp | Sardaukar 子阵营单位生产 | 需结盟 Sardaukar |

---

## 数据质量说明

- 本文档数据基于 AI 训练知识编写，因网络工具不可用未能实时核对 Fandom Wiki
- 标注 `≈` 的数值为近似值（基于游戏平衡和 C&C 引擎常识估算），实际游戏内数值可能有 ±20% 偏差
- 标注 `—` 的为不确定值
- 建议后续通过以下方式校验：
  1. dune.fandom.com Dune 2000 各单位页面
  2. emperorbattlefordune.fandom.com Emperor 各单位页面
  3. 游戏内 INI 文件数据挖掘（Westwood 引擎的单位数据通常存储在 .ini 文件中）
  4. Dune 2000 Editor / Emperor 编辑器查看原始数据
