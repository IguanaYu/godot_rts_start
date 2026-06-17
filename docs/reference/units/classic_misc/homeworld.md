# 万舰齐发（Homeworld）系列 — 单位数据调研

> **版本基准**：Homeworld Remastered Collection (2015) + 原版 HW1 (1999) / HW2 (2003) 参照
> **数据来源**：Homeworld Fandom Wiki (https://homeworld.fandom.com/)、Homeworld官方手册、社区实测
> **调研日期**：2026-06-17
> **注意**：因网络访问受限，部分数值为基于训练数据的近似值（标记 `~`），精确数值请以 wiki 实测为准。缺失项标记 `—`。

---

## 第一部分：种族设计分析

### 1.1 设计哲学一句话

| 种族 | 游戏 | 设计哲学 |
|---|---|---|
| **Kushan（库珊）** | HW1 | 流亡者母舰远征 — 多功能、适应性优先，以母舰为唯一支点进行全舰队远征 |
| **Taiidan（泰丹）** | HW1 | 帝国正规军 — 重型化、火力优先，利用成熟军工体系压制流亡者 |
| **Hiigaran（希格拉）** | HW2 | 归乡者的重建 — 科技成熟、攻防均衡，以离子炮与战斗巡洋舰为核心决兵种 |
| **Vaygr（维格）** | HW2 | 游牧掠夺者 — 模块化、导弹化、快节奏，以数量和机动压垮对手 |

### 1.2 核心签名机制

1. **母舰（Mothership）**：全舰队核心，集生产、研究、资源处理、dock 于一身。母舰毁灭=游戏结束（绝大多数关卡）。
2. **纯 3D 空间**：六自由度移动，Z 轴与 XY 同等重要。攻击可来自任何方向，编队朝向影响受弹面。
3. **RU（Resource Units）资源采集**：资源采集器（Resource Collector）从小行星/尘埃云采集 RU，返回母舰/资源控制船卸货。
4. **研究科技树**：HW1 需建造研究船（最多 7 艘叠加加速）；HW2 在母舰/航母上建造研究模块解锁科技。
5. **Strike Group / 编队系统**：HW2 特色 — 战斗机/护卫舰以小队（Squadron）形式生产，编队时自动维持阵型与分工。
6. **Hyperspace 跳跃**：主力舰以上可超空间跳跃跨地图移动（HW2 需消耗 RU），实现战略级机动。
7. **传感器管理器（Sensors Manager）**：暂停时间流的战术全景视图，查看全地图已探索区域与敌人信号。

### 1.3 角色分工矩阵

| 层级 | Kushan / Hiigaran | Taiidan / Vaygr | 通用角色 |
|---|---|---|---|
| **战斗机 Fighter** | Scout→Interceptor→Bomber | Scout→Interceptor→Bomber(+Lance) | 侦察/制空/反主力舰 |
| **护航艇 Corvette** | Light→Heavy/Repair/Salvage | Light→Heavy/Repair/Salvage | 反战斗机/反护卫舰/特种 |
| **护卫舰 Frigate** | Assault/Ion/Drone/Support | Assault/Ion/Field/Support | 中坚火力/特种支援 |
| **主力舰 Capital** | Destroyer/Missile Dest/Cruiser | Destroyer/Missile Dest/Cruiser | 决战火力 |
| **母舰级 Mothership** | Mothership/Carrier | Mothership/Carrier | 生产枢纽 |

### 1.4 科技树节奏

| 阶段 | HW1 | HW2 |
|---|---|---|
| **开局 T0** | Scout + Resource Collector 采集，建研究船 | Scout + Resource Collector 采集，建研究模块 |
| **早期 T1** | 解锁 Fighter Drive → Interceptor / Defender | 解锁 Fighter Tech → Interceptor |
| **中期 T2** | Corvette Drive → Light/Heavy Corvette；Frigate Drive → Assault Frigate | Corvette Tech → Pulsar/Gunship；Frigate Tech → Torpedo/Assault |
| **中后 T3** | Ion Beam Frigate / Drone(Field) Frigate | Ion Cannon Frigate / Marine Frigate；Capital Tech → Destroyer |
| **后期 T4** | Capital Ship Drive → Destroyer / Missile Destroyer | Battlecruiser Tech + Advanced Tech |
| **终局 T5** | Heavy Cruiser（需多研究船+大量 RU） | Battlecruiser + Hyperspace Jump |

节奏特点：HW1 研究船数量决定并行速度（最多 7 艘 = 7 条研究线），HW2 改为模块化研究，节奏更线性。

### 1.5 核心协同组合

| 编号 | 组合 | 说明 |
|---|---|---|
| **1** | **战斗机护航 + 轰炸机突击** | Interceptor 编队护送 Bomber 突入主力舰盲区投弹，Bomber 的等离子弹/炸弹对主力舰有加成 |
| **2** | **离子炮护卫舰线列 + 防空屏** | Ion Beam/Cannon Frigate 排成线列集火主力舰，Defender / Gunship 护卫舰屏拦截敌方战斗机 |
| **3** **| 打捞护卫舰突袭** | Salvage Corvette / Marine Frigate 捕获敌方主力舰，低成本获得高价值单位（HW1 经典战术） |
| **4** | **重型巡洋舰 + 驱逐舰护卫** | Heavy Cruiser / Battlecruiser 为主力输出，Destroyer 屏卫反护卫舰，形成不可正面击破的舰队 |
| **5** | **探针 + 侦察快攻** | Probe 提供视野，Scout 高速侦察定位，为 Bomber 突袭或 hyperspace 跳跃提供目标 |
| **6** | **布雷艇 + 咽喉点封锁** | Minelayer Corvette 在超空间出口/资源点布设雷场，阻断敌方跳跃或采集 |
| **7** | **支援护卫舰 + 持久战** | Support Frigate / Repair Corvette 跟随舰队持续修复，形成滚雪球式推进（HW1 尤为强大） |

### 1.6 生产机制

- **母舰/航母建造**：所有舰船均由 Mothership 或 Carrier 建造。Carrier 可在前线建立分基地。
- **HW1**：Fighter/Corvette 可在 Carrier 或 Support Frigate 建造和 dock；Frigate+ 仅限 Mothership。
- **HW2**：引入模块系统 — 母舰/航母需建造 Fighter Facility / Corvette Facility / Frigate Facility / Capital Ship Facility 模块才能生产对应级别。Shipyard 可建造主力舰。
- **研究解锁**：多数高级单位需先完成对应研究项目。
- **小队生产（HW2）**：Fighter/Corvette 以整队生产，一队多机，生产时间随队内剩余机体数动态调整（残队可增援补满）。

### 1.7 机动哲学

- **3D 空间机动**：全向六自由度。编队可设定 X/Y/Z 三轴队形，战斗中朝向和速度向量分离。
- **Hyperspace 跳跃**：Capital Ship 以上可跳跃。HW1 跳跃由剧情触发；HW2 可主动跳跃，消耗 RU，距离越远费用越高。可建造 Hyperspace Module 让护卫舰跟随跳跃。
- **Strike Group 编队（HW2）**：编队中战斗机自动护卫主力舰，护卫舰维持阵型，形成"舰队"而非散兵。
- **Dock / 补给**：HW1 战斗机需定期回 dock 补燃料；HW2 取消燃料系统，战斗机无需补给。

### 1.8 视野与地图控制

| 手段 | 说明 |
|---|---|
| **Scout** | 高速战斗机，视野一般，可主动巡逻 |
| **Probe（探针）** | 一次性廉价（10-15 RU）视野单位，发射后不可移动，提供静态视野 |
| **Sensor Array（传感器阵列）** | HW1 昂贵建筑船（~600 RU），揭示全图敌我信号 |
| **Sensors Manager** | 全景战术视图，显示所有已发现单位 |
| **Cloak / 隐形** | Cloaked Fighter 可隐形接近，敌方需近距传感器才能发现 |

### 1.9 反制弱点

| 单位类型 | 克制者 | 被克制者 |
|---|---|---|
| Fighter | Interceptor / Defender / Missile Destroyer / Gunship Corvette | Bomber 对 Fighter 无效 |
| Corvette | Assault Frigate / Pulsar Corvette / Torpedo Frigate | Fighter 对 Corvette 效果差 |
| Frigate | Destroyer / Ion Cannon Frigate / Heavy Cruiser | Fighter 骚扰有效但慢 |
| Capital Ship | Bomber / Ion Cannon Frigate / Heavy Cruiser | Corvette 无法有效伤害 |
| Mothership | 任何能输出的单位（无自卫） | 需舰队保护 |

关键弱点：
- **母舰无自卫火力**：一旦被 hyperspace 突袭或 Bomber 绕后，极易被击杀。
- **Ion Frigate 只能攻击正前方**：侧后方完全无火力，易被 Fighter 绕后。
- **Heavy Cruiser / Battlecruiser 机动极慢**：无法追击，易被 hyperspace 跳跃绕过。
- **资源线脆弱**：Resource Collector 无武装，被 Fighter 袭扰即经济瘫痪。

### 1.10 强势时间窗

| 阶段 | 强势方 | 原因 |
|---|---|---|
| **极早期** | Scout rush 方 | 便宜 Scout 可骚扰资源采集器 |
| **早期** | Interceptor + Defender 方 | 制空权 = 资源保护权 |
| **中期** | Ion Frigate 方 | Ion Beam 对 Frigate+ 有毁灭性输出 |
| **中后期** | Salvage/Marine 方 | 捕获敌方 Frigate/Capital 翻盘 |
| **后期** | Cruiser/BC 方 | 终极兵种正面碾压 |
| **终局** | Hyperspace 跳跃方 | 绕正面直捣母舰 |

### 1.11 经济模型（RU 资源采集）

| 要素 | HW1 | HW2 |
|---|---|---|
| **资源来源** | 小行星（小/中/大）、尘埃云、星云 | 小行星（小/中/大）、尘埃云 |
| **采集单位** | Resource Collector（~400 RU） | Resource Collector（~550 RU） |
| **卸货点** | Mothership / Resource Controller（~600 RU）/ Support Frigate | Mothership / Carrier / Mobile Refinery |
| **采集效率** | 单 Collector 约 8-12 RU/s | 单 Collector 约 10-15 RU/s |
| **资源枯竭** | 地图资源有限，需扩张 | 地图资源有限，需扩张 |
| **跳跃成本** | 无（剧情触发） | 按 RU 计费，距离×质量 |

经济特点：资源是零和博弈 — 你采了对手就没了。资源点争夺是战略核心。

---

## 第二部分：Deserts of Kharak（地面版前传）

> 《Homeworld: Deserts of Kharak》（2016）— Blackbird Interactive 开发，故事发生在 HW1 之前，Kharak 星球表面。

### 2.1 从太空到地面的转变

| 维度 | HW1/2（太空） | DoK（地面沙漠） |
|---|---|---|
| **空间** | 全 3D 六自由度 | 2.5D 地面，有地形高低差 |
| **资源** | 小行星 RU | 地表资源点 CU（Catalyst Units） |
| **母舰** | Mothership（太空） | Carrier（地面载具母舰，可移动） |
| **跳跃** | Hyperspace | 无跳跃，靠地面移动 |
| **空军** | 所有单位都是"空军" | 有独立空军（Strike Aircraft），地面单位占多数 |
| **地形** | 无 | 沙丘/峡谷/高地影响视野和射程 |

### 2.2 阵营分析

#### Coalition of the Northern Kiithid（北方基思联盟）
- **设计哲学**：标准均衡型 — 流亡前的前身，科技基础扎实，火力/机动/防御均衡。
- **核心签名**：Carrier 为移动基地，Railgun 长射程狙击，Artillery 攻城。
- **节奏**：中速展开，靠 Railgun + Artillery 阵地战推进。

#### Khaaneph（卡内夫，DLC 阵营）
- **设计哲学**：沙漠掠夺者 — 更激进、更快、更脆弱，以数量和速度压倒对手。
- **核心签名**：高机动载具、突袭型 Railgun、更便宜的 Carrier。
- **节奏**：快攻骚扰，避免正面阵地战。

#### Soban（索班，DLC 阵营）
- **设计哲学**：雇佣军 — 战术型，单位更精锐但更贵，依赖微操和技能。
- **核心签名**：Overcharge Railgun、精准打击、强力 Support Cruiser。
- **节奏**：少而精，靠技能窗口打赢关键战斗。

### 2.3 DoK 协同组合

1. **Recon + Railgun 阵地**：Recon 提供视野，Railgun 在射程外狙击
2. **Strike Aircraft + 地面推进**：空军清反装甲，AAV 推进占点
3. **Artillery + Carrier repair**：Artillery 轰击，Carrier 修复受损单位
4. **Sandskimmer 快攻骚扰**：高速突入资源区击杀 Worker

---

## 第三部分：单位数据表

### 3.1 Homeworld 1 — Kushan（库珊）

> HW1 中 Kushan 与 Taiidan 单位类型基本对称，数值差异在 5% 以内。仅标注差异单位。
> 战斗机在 HW1 中以个体生产，但以编队（formation）形式作战。

#### 战斗机 Fighter

| 字段 | Scout | Interceptor | Defender | Cloaked Fighter | Attack Bomber | Defense Fighter |
|---|---|---|---|---|---|---|
| **name_zh** | 侦察机 | 拦截机 | 防御机 | 隐形战斗机 | 攻击轰炸机 | 防御战斗机 |
| **name_en** | Scout | Interceptor | Defender | Cloaked Fighter | Attack Bomber | Defense Fighter |
| **faction** | Kushan | Kushan | Kushan | Kushan | Kushan | Kushan |
| **game** | HW1 | HW1 | HW1 | HW1 | HW1 | HW1 |
| **tier** | 战斗机 | 战斗机 | 战斗机 | 战斗机 | 战斗机 | 战斗机 |
| **built_from** | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier |
| **cost_RU** | ~50 | ~60 | ~65 | ~120 | ~135 | ~85 |
| **build_time** | ~12s | ~15s | ~16s | ~25s | ~28s | ~20s |
| **pop** | 1 | 1 | 1 | 1 | 1 | 1 |
| **research_req** | 无 | Fighter Drive | Fighter Drive | Cloak Fighter Tech | Fighter Drive + Bomber Tech | Fighter Drive |
| **hp** | ~60 | ~95 | ~110 | ~75 | ~120 | ~100 |
| **armor** | 轻型 | 轻型 | 轻型 | 轻型 | 轻型 | 轻型 |
| **tags** | 侦察/高速 | 制空 | 防空/慢速 | 隐形/偷袭 | 反主力舰 | 反导弹 |
| **speed** | ~1000 | ~850 | ~400 | ~700 | ~500 | ~700 |
| **hyperspace** | 否 | 否 | 否 | 否 | 否 | 否 |
| **vision** | 中 | 中 | 中 | 中 | 中 | 中 |
| **sensor_range** | 中 | 中 | 中 | 中 | 中 | 中 |
| **damage** | ~15 | ~25 | ~20 | ~30 | ~120(炸弹) | ~5(反导弹) |
| **atk_type** | 质量驱动器 | 质量驱动器 | 质量驱动器 | 质量驱动器 | 等离子炸弹 | 反导弹弹幕 |
| **cooldown** | ~1s | ~1s | ~1s | ~1s | ~3s | ~0.5s |
| **range** | 短 | 短 | 短 | 短 | 中 | 短 |
| **target** | 任意 | 战斗机优先 | 战斗机 | 任意 | 主力舰/护卫舰 | 导弹 |
| **splash** | 无 | 无 | 无 | 无 | 小范围 | 无 |
| **bonus_vs** | 无 | 战斗机 | 战斗机 | 无 | 主力舰 | 导弹 |
| **active** | — | — | — | Cloak(隐形) | — | — |
| **passive** | 高速 | — | — | 隐形时不可见 | — | 自动拦截导弹 |
| **special** | 可 patrol 侦察 | — | — | 隐形消耗燃料 | — | 区域反导弹 |
| **strike_group_role** | 侦察/骚扰 | 制空护航 | 防空屏 | 偷袭 | 反主力舰 | 反导弹屏 |

#### 护航艇 Corvette

| 字段 | Light Corvette | Heavy Corvette | Repair Corvette | Salvage Corvette | Minelayer Corvette |
|---|---|---|---|---|---|
| **name_zh** | 轻型护航艇 | 重型护航艇 | 维修护航艇 | 打捞护航艇 | 布雷艇 |
| **name_en** | Light Corvette | Heavy Corvette | Repair Corvette | Salvage Corvette | Minelayer Corvette |
| **faction** | Kushan | Kushan | Kushan | Kushan | Kushan |
| **game** | HW1 | HW1 | HW1 | HW1 | HW1 |
| **tier** | 护航艇 | 护航艇 | 护航艇 | 护航艇 | 护航艇 |
| **built_from** | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier | Mothership/Carrier |
| **cost_RU** | ~275 | ~400 | ~300 | ~400 | ~350 |
| **build_time** | ~30s | ~40s | ~35s | ~40s | ~38s |
| **pop** | 1 | 1 | 1 | 1 | 1 |
| **research_req** | Corvette Drive | Corvette Drive + Heavy Tech | Corvette Drive + Repair Tech | Corvette Drive + Salvage Tech | Corvette Drive + Mine Tech |
| **hp** | ~550 | ~800 | ~450 | ~350 | ~500 |
| **armor** | 中型 | 中型 | 中型 | 中型 | 中型 |
| **tags** | 反战斗机 | 反护航艇/护卫舰 | 维修 | 捕获 | 布雷 |
| **speed** | ~500 | ~400 | ~400 | ~350 | ~350 |
| **hyperspace** | 否 | 否 | 否 | 否 | 否 |
| **vision** | 中 | 中 | 中 | 中 | 中 |
| **sensor_range** | 中 | 中 | 中 | 中 | 中 |
| **damage** | ~30 | ~50 | 0 | 0 | 0(雷 ~200) |
| **atk_type** | 双联质量驱动器 | 重型质量驱动器 | — | — | 触发式水雷 |
| **cooldown** | ~1s | ~1.5s | — | — | — |
| **range** | 短 | 中 | — | — | — |
| **target** | 战斗机 | 护航艇/护卫舰 | 友军 | 敌舰 | — |
| **splash** | 无 | 无 | — | — | 大范围 |
| **bonus_vs** | 战斗机 | 护航艇 | — | — | 主力舰 |
| **active** | — | — | Repair(维修目标) | Salvage(捕获目标) | Lay Mine(布雷) |
| **passive** | — | — | 自动维修附近友军 | — | — |
| **special** | — | — | 可维修战斗机/护航艇 | 多艘协同捕获大型舰 | 雷场持续存在 |
| **strike_group_role** | 反战斗机屏 | 反护航艇 | 后勤维修 | 捕获特种 | 区域封锁 |

#### 护卫舰 Frigate

| 字段 | Assault Frigate | Ion Beam Frigate | Drone Frigate (Kushan独有) | Support Frigate |
|---|---|---|---|---|
| **name_zh** | 突击护卫舰 | 离子束护卫舰 | 无人机护卫舰 | 支援护卫舰 |
| **name_en** | Assault Frigate | Ion Beam Frigate | Drone Frigate | Support Frigate |
| **faction** | Kushan | Kushan | Kushan | Kushan |
| **game** | HW1 | HW1 | HW1 | HW1 |
| **tier** | 护卫舰 | 护卫舰 | 护卫舰 | 护卫舰 |
| **built_from** | Mothership | Mothership | Mothership | Mothership |
| **cost_RU** | ~650 | ~775 | ~600 | ~800 |
| **build_time** | ~60s | ~70s | ~55s | ~70s |
| **pop** | 1 | 1 | 1 | 1 |
| **research_req** | Frigate Drive | Frigate Drive + Ion Cannon Tech | Frigate Drive + Drone Tech | Frigate Drive + Support Tech |
| **hp** | ~5000 | ~4000 | ~3500 | ~6000 |
| **armor** | 重型 | 重型 | 重型 | 重型 |
| **tags** | 反护航艇/护卫舰 | 反主力舰 | 无人机/防空 | 维修/补给 |
| **speed** | ~350 | ~300 | ~300 | ~300 |
| **hyperspace** | 否 | 否 | 否 | 否 |
| **vision** | 中 | 中 | 中 | 中 |
| **sensor_range** | 中 | 中 | 中 | 中 |
| **damage** | ~80(多炮) | ~250(离子束) | ~10×4(无人机) | 0 |
| **atk_type** | 多管质量驱动器+导弹 | 离子束 | 无人机群 | — |
| **cooldown** | ~1.5s | 持续光束 | ~1s | — |
| **range** | 中 | 长 | 短 | — |
| **target** | 护航艇/护卫舰 | 主力舰/护卫舰 | 战斗机 | 友军 |
| **splash** | 无 | 无 | 无 | — |
| **bonus_vs** | 护航艇 | 主力舰 | 战斗机 | — |
| **active** | — | — | Deploy Drones(部署无人机) | Repair(维修) / Refuel(补给) |
| **passive** | — | — | 无人机自动防空 | 自动维修附近友军 |
| **special** | — | 光束持续伤害，只能攻击正前方 | 无人机可被摧毁但会再生 | 可 dock 战斗机补给燃料 |
| **strike_group_role** | 中坚火力 | 反主力舰输出 | 防空屏 | 后勤枢纽 |

#### 主力舰 Capital Ship

| 字段 | Destroyer | Missile Destroyer | Heavy Cruiser | Carrier |
|---|---|---|---|---|
| **name_zh** | 驱逐舰 | 导弹驱逐舰 | 重型巡洋舰 | 航母 |
| **name_en** | Destroyer | Missile Destroyer | Heavy Cruiser | Carrier |
| **faction** | Kushan | Kushan | Kushan | Kushan |
| **game** | HW1 | HW1 | HW1 | HW1 |
| **tier** | 主力舰 | 主力舰 | 主力舰 | 母舰级 |
| **built_from** | Mothership | Mothership | Mothership | Mothership |
| **cost_RU** | ~1500 | ~1500 | ~4000 | ~1000 |
| **build_time** | ~90s | ~90s | ~180s | ~75s |
| **pop** | 1 | 1 | 1 | 1 |
| **research_req** | Capital Ship Drive | Capital Ship Drive + Missile Tech | Capital Ship Drive + Heavy Tech | Capital Ship Drive |
| **hp** | ~14000 | ~12000 | ~28000 | ~12000 |
| **armor** | 重型 | 重型 | 超重 | 重型 |
| **tags** | 反护卫舰/主力舰 | 反战斗机 | 终极火力 | 生产/补给 |
| **speed** | ~300 | ~280 | ~250 | ~250 |
| **hyperspace** | 是 | 是 | 是 | 是 |
| **vision** | 中 | 中 | 中 | 中 |
| **sensor_range** | 中 | 中 | 中 | 中 |
| **damage** | ~300(双联炮) | ~50×N(导弹群) | ~400(离子)+~300(炮) | 0 |
| **atk_type** | 重型质量驱动器 | 多发导弹 | 离子炮+重型炮 | — |
| **cooldown** | ~2s | ~1s | ~2s | — |
| **range** | 中 | 中(全向) | 长 | — |
| **target** | 护卫舰/主力舰 | 战斗机 | 任意 | — |
| **splash** | 无 | 小范围 | 小范围 | — |
| **bonus_vs** | 护卫舰 | 战斗机 | 主力舰 | — |
| **active** | — | — | — | — |
| **passive** | — | 全向导弹发射 | 多炮塔全向 | 可生产 Fighter/Corvette |
| **special** | — | 导弹可被 Defense Fighter 拦截 | 最强常规战舰 | 可 dock 战斗机/护航艇 |
| **strike_group_role** | 护卫舰杀手 | 防空主力 | 舰队核心 | 前线分基地 |

#### 支援/非战斗单位

| 字段 | Resource Collector | Resource Controller | Research Ship | Probe | Sensor Array |
|---|---|---|---|---|---|
| **name_zh** | 资源采集器 | 资源控制船 | 研究船 | 探针 | 传感器阵列 |
| **name_en** | Resource Collector | Resource Controller | Research Ship | Probe | Sensor Array |
| **faction** | Kushan | Kushan | Kushan | Kushan | Kushan |
| **game** | HW1 | HW1 | HW1 | HW1 | HW1 |
| **tier** | 非战斗 | 非战斗 | 非战斗 | 非战斗 | 非战斗 |
| **built_from** | Mothership | Mothership | Mothership | Mothership | Mothership |
| **cost_RU** | ~400 | ~600 | ~500 | ~10 | ~600 |
| **build_time** | ~30s | ~40s | ~25s | ~3s | ~50s |
| **pop** | 1 | 1 | 1 | — | 1 |
| **research_req** | 无 | 无 | 无 | 无 | 无 |
| **hp** | ~3000 | ~2000 | ~1000 | ~10 | ~2000 |
| **armor** | 中型 | 中型 | 轻型 | — | 轻型 |
| **tags** | 采集 | 卸货点 | 研究 | 侦察 | 全图视野 |
| **speed** | ~300 | ~300 | ~250 | 一次性 | ~250 |
| **damage** | 0 | 0 | 0 | 0 | 0 |
| **special** | 采集 RU 返回卸货 | 移动卸货点 | 最多 7 艘叠加加速研究 | 发射后固定位置提供视野 | 揭示全图敌我信号 |
| **strike_group_role** | 经济核心 | 经济延伸 | 科技加速 | 临时视野 | 战略情报 |

---

### 3.2 Homeworld 1 — Taiidan（泰丹）

> Taiidan 与 Kushan 单位几乎完全对称，以下仅列出差异单位。其余单位参考 Kushan 数据，数值差异 < 5%。

#### Taiidan 独有/差异单位

| 字段 | Defense Field Frigate (Taiidan独有) | Heavy Cruiser (Taiidan差异) |
|---|---|---|
| **name_zh** | 防御场护卫舰 | 重型巡洋舰 |
| **name_en** | Defense Field Frigate | Heavy Cruiser |
| **faction** | Taiidan | Taiidan |
| **game** | HW1 | HW1 |
| **tier** | 护卫舰 | 主力舰 |
| **built_from** | Mothership | Mothership |
| **cost_RU** | ~600 | ~4000 |
| **build_time** | ~55s | ~180s |
| **pop** | 1 | 1 |
| **research_req** | Frigate Drive + Defense Field Tech | Capital Ship Drive + Heavy Tech |
| **hp** | ~3500 | ~28000 |
| **armor** | 重型 | 超重 |
| **tags** | 防御场/护盾 | 终极火力 |
| **speed** | ~300 | ~250 |
| **damage** | 0 | ~400(离子)+~300(炮) |
| **atk_type** | — | 离子炮+重型炮 |
| **active** | Defense Field(展开防御场) | — |
| **passive** | 防御场内友军减伤 | — |
| **special** | 对应 Kushan 的 Drone Frigate；防御场可弹开/减伤来袭火力 | 外形为分体式双壳设计（Kushan为单体） |
| **strike_group_role** | 舰队护盾 | 舰队核心 |

#### Taiidan 外观差异说明
- Taiidan 舰船设计更"帝国化" — 对称、棱角分明、深红/黑涂装
- Kushan 舰船更"流亡者" — 不对称、工业感、黄/白涂装
- Heavy Cruiser 外形差异最大：Taiidan 为经典左右分壳双离子炮设计，Kushan 为单体前射离子炮

---

### 3.3 Homeworld 2 — Hiigaran（希格拉）

> HW2 引入小队系统：Fighter/Corvette 以整队生产，每队含多架机体。
> 生产模块系统：母舰/航母需建造 Fighter Facility / Corvette Facility / Frigate Facility / Capital Ship Facility 才能生产对应级别。

#### 战斗机 Fighter（以小队生产）

| 字段 | Scout | Interceptor | Bomber |
|---|---|---|---|
| **name_zh** | 侦察机 | 拦截机 | 轰炸机 |
| **name_en** | Scout | Interceptor | Bomber |
| **faction** | Hiigaran | Hiigaran | Hiigaran |
| **game** | HW2 | HW2 | HW2 |
| **tier** | 战斗机 | 战斗机 | 战斗机 |
| **built_from** | Mothership/Carrier (Fighter Facility) | Mothership/Carrier (Fighter Facility) | Mothership/Carrier (Fighter Facility) |
| **cost_RU** | ~350 | ~500 | ~700 |
| **build_time** | ~20s | ~25s | ~30s |
| **pop** | 1 小队 | 1 小队 | 1 小队 |
| **research_req** | Fighter Facility | Fighter Tech | Fighter Tech + Bomber Tech |
| **hp** | ~60×6 | ~100×5 | ~130×5 |
| **armor** | 轻型 | 轻型 | 轻型 |
| **tags** | 侦察/高速 | 制空 | 反主力舰 |
| **speed** | ~1000 | ~850 | ~500 |
| **hyperspace** | 否 | 否 | 否 |
| **vision** | 中 | 中 | 中 |
| **sensor_range** | 中 | 中 | 中 |
| **damage** | ~15/机 | ~25/机 | ~150/机(炸弹) |
| **atk_type** | 质量驱动器 | 质量驱动器 | 等离子炸弹 |
| **cooldown** | ~1s | ~1s | ~3s |
| **range** | 短 | 短 | 中 |
| **target** | 任意 | 战斗机 | 主力舰/护卫舰 |
| **splash** | 无 | 无 | 小范围 |
| **bonus_vs** | 无 | 战斗机 | 主力舰 |
| **active** | EMP Blast(电磁脉冲) | — | — |
| **passive** | 高速 | — | — |
| **special** | EMP 可瘫痪敌战斗机/护航艇 | — | 反主力舰核心 |
| **strike_group_role** | 侦察/EMP支援 | 制空护航 | 反主力舰 |

#### 护航艇 Corvette（以小队生产）

| 字段 | Gunship Corvette | Pulsar Corvette | Minelayer Corvette |
|---|---|---|---|
| **name_zh** | 炮艇护航艇 | 脉冲护航艇 | 布雷艇 |
| **name_en** | Gunship Corvette | Pulsar Corvette | Minelayer Corvette |
| **faction** | Hiigaran | Hiigaran | Hiigaran |
| **game** | HW2 | HW2 | HW2 |
| **tier** | 护航艇 | 护航艇 | 护航艇 |
| **built_from** | Mothership/Carrier (Corvette Facility) | Mothership/Carrier (Corvette Facility) | Mothership/Carrier (Corvette Facility) |
| **cost_RU** | ~500 | ~475 | ~400 |
| **build_time** | ~28s | ~28s | ~25s |
| **pop** | 1 小队 | 1 小队 | 1 |
| **research_req** | Corvette Facility | Corvette Tech + Pulsar Tech | Corvette Tech + Mine Tech |
| **hp** | ~400×4 | ~600×3 | ~500 |
| **armor** | 中型 | 中型 | 中型 |
| **tags** | 反战斗机 | 反护卫舰 | 布雷 |
| **speed** | ~450 | ~400 | ~350 |
| **damage** | ~20/机 | ~80/机(脉冲) | 0(雷 ~300) |
| **atk_type** | 旋转炮塔 | 脉冲光束 | 触发式水雷 |
| **cooldown** | ~1s | ~2s | — |
| **range** | 短 | 中 | — |
| **target** | 战斗机 | 护卫舰/护航艇 | — |
| **bonus_vs** | 战斗机 | 护卫舰 | 主力舰 |
| **active** | — | — | Lay Mine(布雷) |
| **passive** | 多炮塔全向 | — | — |
| **special** | 旋转炮塔可追踪高速战斗机 | 脉冲光束对护卫舰有加成 | 雷场封锁 |
| **strike_group_role** | 反战斗机屏 | 反护卫舰 | 区域封锁 |

#### 护卫舰 Frigate（单艘生产）

| 字段 | Torpedo Frigate | Assault Frigate | Ion Cannon Frigate | Marine Frigate | Defense Field Frigate |
|---|---|---|---|---|---|
| **name_zh** | 鱼雷护卫舰 | 突击护卫舰 | 离子炮护卫舰 | 陆战护卫舰 | 防御场护卫舰 |
| **name_en** | Torpedo Frigate | Assault Frigate | Ion Cannon Frigate | Marine Frigate | Defense Field Frigate |
| **faction** | Hiigaran | Hiigaran | Hiigaran | Hiigaran | Hiigaran |
| **game** | HW2 | HW2 | HW2 | HW2 | HW2 |
| **tier** | 护卫舰 | 护卫舰 | 护卫舰 | 护卫舰 | 护卫舰 |
| **built_from** | Mothership/Carrier (Frigate Facility) | Mothership/Carrier (Frigate Facility) | Mothership/Carrier (Frigate Facility) | Mothership/Carrier (Frigate Facility) | Mothership/Carrier (Frigate Facility) |
| **cost_RU** | ~700 | ~700 | ~850 | ~700 | ~700 |
| **build_time** | ~55s | ~55s | ~60s | ~55s | ~55s |
| **pop** | 1 | 1 | 1 | 1 | 1 |
| **research_req** | Frigate Facility + Frigate Tech | Frigate Tech | Frigate Tech + Ion Tech | Frigate Tech + Marine Tech | Frigate Tech + Defense Field Tech |
| **hp** | ~5000 | ~5000 | ~4000 | ~4000 | ~3500 |
| **armor** | 重型 | 重型 | 重型 | 重型 | 重型 |
| **tags** | 反护卫舰 | 反护航艇 | 反主力舰 | 捕获 | 护盾 |
| **speed** | ~350 | ~350 | ~300 | ~300 | ~300 |
| **hyperspace** | 需 Hyper Module | 需 Hyper Module | 需 Hyper Module | 需 Hyper Module | 需 Hyper Module |
| **damage** | ~150(鱼雷) | ~80(多炮) | ~250(离子束) | 0 | 0 |
| **atk_type** | 制导鱼雷 | 多管质量驱动器 | 离子束 | — | — |
| **cooldown** | ~2s | ~1.5s | 持续光束 | — | — |
| **range** | 中 | 中 | 长 | — | — |
| **target** | 护卫舰 | 护航艇/护卫舰 | 主力舰/护卫舰 | 敌舰 | — |
| **bonus_vs** | 护卫舰 | 护航艇 | 主力舰 | — | — |
| **active** | — | — | — | Board(登舰捕获) | Defense Field(展开护盾) |
| **passive** | — | — | — | — | 护盾内友军减伤 |
| **special** | 鱼雷可追踪 | — | 只能攻击正前方 | 捕获后可控制敌舰 | 对应 HW1 的 Field Frigate |
| **strike_group_role** | 反护卫舰 | 反护航艇屏 | 反主力舰输出 | 捕获特种 | 舰队护盾 |

#### 主力舰 Capital Ship

| 字段 | Destroyer | Battlecruiser | Carrier | Shipyard |
|---|---|---|---|---|
| **name_zh** | 驱逐舰 | 战斗巡洋舰 | 航母 | 船坞 |
| **name_en** | Destroyer | Battlecruiser | Carrier | Shipyard |
| **faction** | Hiigaran | Hiigaran | Hiigaran | Hiigaran |
| **game** | HW2 | HW2 | HW2 | HW2 |
| **tier** | 主力舰 | 主力舰 | 母舰级 | 母舰级 |
| **built_from** | Mothership/Shipyard | Shipyard | Mothership | Mothership |
| **cost_RU** | ~2000 | ~4000 | ~2500 | ~3500 |
| **build_time** | ~80s | ~120s | ~90s | ~100s |
| **pop** | 1 | 1 | 1 | 1 |
| **research_req** | Capital Ship Facility | Capital Tech + Battlecruiser Tech | Capital Tech | Capital Tech |
| **hp** | ~14000 | ~26000 | ~16000 | ~20000 |
| **armor** | 重型 | 超重 | 重型 | 超重 |
| **tags** | 反护卫舰/主力舰 | 终极火力 | 生产/补给 | 主力舰生产 |
| **speed** | ~300 | ~250 | ~250 | ~200 |
| **hyperspace** | 是 | 是 | 是 | 是 |
| **damage** | ~300(双联炮) | ~500(离子)+~300(炮) | 0 | 0 |
| **atk_type** | 重型质量驱动器 | 离子炮+重型炮+导弹 | — | — |
| **cooldown** | ~2s | ~2s | — | — |
| **range** | 中 | 长 | — | — |
| **target** | 护卫舰/主力舰 | 任意 | — | — |
| **bonus_vs** | 护卫舰 | 主力舰 | — | — |
| **active** | — | — | — | — |
| **passive** | — | 多炮塔全向 | 可生产 Fighter/Corvette/Frigate | 可生产 Capital Ship |
| **special** | — | 可建造 Fire Control Tower(火控塔)提升精度 | 可跳跃 | 不可自航(需拖拽/跳跃) |
| **strike_group_role** | 护卫舰杀手 | 舰队核心 | 前线分基地 | 主力舰工厂 |

#### 非战斗单位

| 字段 | Resource Collector | Mobile Refinery | Probe | Scout (HW2) |
|---|---|---|---|---|
| **name_zh** | 资源采集器 | 移动精炼船 | 探针 | 侦察机 |
| **name_en** | Resource Collector | Mobile Refinery | Probe | Scout |
| **faction** | Hiigaran | Hiigaran | Hiigaran | Hiigaran |
| **game** | HW2 | HW2 | HW2 | HW2 |
| **tier** | 非战斗 | 非战斗 | 非战斗 | 战斗机 |
| **cost_RU** | ~550 | ~1000 | ~15 | ~350 |
| **hp** | ~3000 | ~5000 | ~10 | ~60×6 |
| **speed** | ~300 | ~280 | 一次性 | ~1000 |
| **special** | 采集 RU | 移动卸货/精炼点 | 发射后固定视野 | EMP 瘫痪敌机 |
| **strike_group_role** | 经济核心 | 经济延伸 | 临时视野 | 侦察/EMP |

---

### 3.4 Homeworld 2 — Vaygr（维格）

> Vaygr 与 Hiigaran 在舰船级别上对称，但单位特性差异显著：
> - Vaygr 偏重**导弹/动能武器**，Hiigaran 偏重**能量/离子武器**
> - Vaygr 有独有单位 **Lance Fighter**（能量长矛战斗机）和 **Command Corvette**（指挥护航艇）
> - Vaygr 缺少 **Defense Field Frigate**，但 **Command Corvette** 提供类似增益

#### 战斗机 Fighter（以小队生产）

| 字段 | Scout | Interceptor | Bomber | Lance Fighter (Vaygr独有) |
|---|---|---|---|---|
| **name_zh** | 侦察机 | 拦截机 | 轰炸机 | 长矛战斗机 |
| **name_en** | Scout | Interceptor | Bomber | Lance Fighter |
| **faction** | Vaygr | Vaygr | Vaygr | Vaygr |
| **game** | HW2 | HW2 | HW2 | HW2 |
| **tier** | 战斗机 | 战斗机 | 战斗机 | 战斗机 |
| **built_from** | Mothership/Carrier (Fighter Facility) | Mothership/Carrier (Fighter Facility) | Mothership/Carrier (Fighter Facility) | Mothership/Carrier (Fighter Facility) |
| **cost_RU** | ~350 | ~500 | ~700 | ~600 |
| **build_time** | ~20s | ~25s | ~30s | ~28s |
| **pop** | 1 小队(6机) | 1 小队(5机) | 1 小队(5机) | 1 小队(5机) |
| **research_req** | Fighter Facility | Fighter Tech | Fighter Tech + Bomber Tech | Fighter Tech + Lance Tech |
| **hp** | ~55×6 | ~95×5 | ~120×5 | ~110×5 |
| **armor** | 轻型 | 轻型 | 轻型 | 轻型 |
| **tags** | 侦察 | 制空 | 反主力舰 | 反护航艇/护卫舰 |
| **speed** | ~1000 | ~850 | ~500 | ~700 |
| **damage** | ~15/机 | ~25/机 | ~140/机(炸弹) | ~60/机(长矛) |
| **atk_type** | 质量驱动器 | 质量驱动器 | 等离子炸弹 | 能量长矛 |
| **cooldown** | ~1s | ~1s | ~3s | ~1.5s |
| **range** | 短 | 短 | 中 | 中 |
| **target** | 任意 | 战斗机 | 主力舰/护卫舰 | 护航艇/护卫舰 |
| **bonus_vs** | 无 | 战斗机 | 主力舰 | 护航艇 |
| **active** | — | — | — | — |
| **passive** | 高速 | — | — | — |
| **special** | — | — | — | Vaygr独有；能量长矛对护航艇有高加成 |
| **strike_group_role** | 侦察 | 制空护航 | 反主力舰 | 反护航艇特种 |

#### 护航艇 Corvette（以小队生产）

| 字段 | Missile Corvette | Laser Corvette | Minelayer Corvette | Command Corvette (Vaygr独有) |
|---|---|---|---|---|
| **name_zh** | 导弹护航艇 | 激光护航艇 | 布雷艇 | 指挥护航艇 |
| **name_en** | Missile Corvette | Laser Corvette | Minelayer Corvette | Command Corvette |
| **faction** | Vaygr | Vaygr | Vaygr | Vaygr |
| **game** | HW2 | HW2 | HW2 | HW2 |
| **tier** | 护航艇 | 护航艇 | 护航艇 | 护航艇 |
| **built_from** | Mothership/Carrier (Corvette Facility) | Mothership/Carrier (Corvette Facility) | Mothership/Carrier (Corvette Facility) | Mothership/Carrier (Corvette Facility) |
| **cost_RU** | ~450 | ~475 | ~400 | ~500 |
| **build_time** | ~28s | ~28s | ~25s | ~30s |
| **pop** | 1 小队(4机) | 1 小队(3机) | 1 | 1 |
| **research_req** | Corvette Facility + Corvette Tech | Corvette Tech + Laser Tech | Corvette Tech + Mine Tech | Corvette Tech + Command Tech |
| **hp** | ~350×4 | ~600×3 | ~500 | ~450 |
| **armor** | 中型 | 中型 | 中型 | 中型 |
| **tags** | 反战斗机/护航艇 | 反护卫舰 | 布雷 | 增益/指挥 |
| **speed** | ~450 | ~400 | ~350 | ~350 |
| **damage** | ~30/机(导弹) | ~70/机(激光) | 0(雷 ~300) | 0 |
| **atk_type** | 多发导弹 | 切割激光 | 触发式水雷 | — |
| **cooldown** | ~1.5s | ~2s | — | — |
| **range** | 中 | 中 | — | — |
| **target** | 战斗机/护航艇 | 护卫舰 | — | — |
| **bonus_vs** | 战斗机 | 护卫舰 | 主力舰 | — |
| **active** | — | — | Lay Mine(布雷) | Command Aura(指挥光环) |
| **passive** | — | — | — | 附近友军射速/精度提升 |
| **special** | 对应 Hiigaran Gunship，但用导弹 | 对应 Hiigaran Pulsar，但用激光 | — | Vaygr独有；替代 Defense Field Frigate 的增益角色 |
| **strike_group_role** | 反战斗机屏 | 反护卫舰 | 区域封锁 | 舰队增益 |

#### 护卫舰 Frigate

| 字段 | Assault Frigate | Heavy Missile Frigate | Infiltrator Frigate |
|---|---|---|---|
| **name_zh** | 突击护卫舰 | 重型导弹护卫舰 | 渗透护卫舰 |
| **name_en** | Assault Frigate | Heavy Missile Frigate | Infiltrator Frigate |
| **faction** | Vaygr | Vaygr | Vaygr |
| **game** | HW2 | HW2 | HW2 |
| **tier** | 护卫舰 | 护卫舰 | 护卫舰 |
| **built_from** | Mothership/Carrier (Frigate Facility) | Mothership/Carrier (Frigate Facility) | Mothership/Carrier (Frigate Facility) |
| **cost_RU** | ~700 | ~750 | ~700 |
| **build_time** | ~55s | ~58s | ~55s |
| **pop** | 1 | 1 | 1 |
| **research_req** | Frigate Facility + Frigate Tech | Frigate Tech + Missile Tech | Frigate Tech + Infiltrator Tech |
| **hp** | ~5000 | ~4500 | ~4000 |
| **armor** | 重型 | 重型 | 重型 |
| **tags** | 反护航艇 | 反主力舰 | 捕获 |
| **speed** | ~350 | ~320 | ~300 |
| **hyperspace** | 需 Hyper Module | 需 Hyper Module | 需 Hyper Module |
| **damage** | ~80(多炮) | ~200(导弹群) | 0 |
| **atk_type** | 多管质量驱动器 | 重型导弹齐射 | — |
| **cooldown** | ~1.5s | ~2s | — |
| **range** | 中 | 中 | — |
| **target** | 护航艇/护卫舰 | 主力舰/护卫舰 | 敌舰 |
| **bonus_vs** | 护航艇 | 主力舰 | — |
| **active** | — | — | Board(登舰捕获) |
| **passive** | — | — | — |
| **special** | 对应 Hiigaran Assault Frigate | 对应 Hiigaran Ion Cannon Frigate，但用导弹 | 对应 Hiigaran Marine Frigate |
| **strike_group_role** | 反护航艇屏 | 反主力舰输出 | 捕获特种 |

> **注意**：Vaygr 没有直接对应 Hiigaran Torpedo Frigate 和 Defense Field Frigate 的单位。Vaygr 的反护卫舰火力由 Heavy Missile Frigate 兼任，防御增益由 Command Corvette 提供。

#### 主力舰 Capital Ship

| 字段 | Destroyer | Battlecruiser | Carrier | Flagship |
|---|---|---|---|---|
| **name_zh** | 驱逐舰 | 战斗巡洋舰 | 航母 | 旗舰(母舰) |
| **name_en** | Destroyer | Battlecruiser | Carrier | Flagship |
| **faction** | Vaygr | Vaygr | Vaygr | Vaygr |
| **game** | HW2 | HW2 | HW2 | HW2 |
| **tier** | 主力舰 | 主力舰 | 母舰级 | 母舰级 |
| **built_from** | Shipyard | Shipyard | Mothership | — (初始) |
| **cost_RU** | ~2000 | ~4000 | ~2500 | — |
| **build_time** | ~80s | ~120s | ~90s | — |
| **pop** | 1 | 1 | 1 | 1 |
| **research_req** | Capital Ship Facility | Capital Tech + Battlecruiser Tech | Capital Tech | — |
| **hp** | ~14000 | ~26000 | ~16000 | ~30000 |
| **armor** | 重型 | 超重 | 重型 | 超重 |
| **tags** | 反护卫舰/主力舰 | 终极火力 | 生产/补给 | 母舰 |
| **speed** | ~300 | ~250 | ~250 | ~200 |
| **hyperspace** | 是 | 是 | 是 | 是 |
| **damage** | ~300(导弹+炮) | ~450(三联炮)+~300(导弹) | 0 | 0 |
| **atk_type** | 导弹+质量驱动器 | 三联炮+导弹齐射 | — | — |
| **cooldown** | ~2s | ~2s | — | — |
| **range** | 中 | 长 | — | — |
| **target** | 护卫舰/主力舰 | 任意 | — | — |
| **bonus_vs** | 护卫舰 | 主力舰 | — | — |
| **active** | — | — | — | — |
| **passive** | — | 多炮塔全向 | 可生产 Fighter/Corvette/Frigate | 全舰队生产枢纽 |
| **special** | 导弹可被拦截 | Trinity Cannon(三联主炮)为 Vaygr 标志性武器 | 可跳跃 | Vaygr 的母舰，比 Hiigaran Mothership 更具战斗改装感 |
| **strike_group_role** | 护卫舰杀手 | 舰队核心 | 前线分基地 | 全军枢纽 |

---

### 3.5 Homeworld: Deserts of Kharak — Coalition of the Northern Kiithid

> DoK 为地面 RTS，资源为 CU（Catalyst Units），从地表资源点采集。
> 单位以地面载具为主，有少量空中单位。Carrier 为移动基地。
> 以下数值为近似值（训练数据回忆），精确值请以 wiki 为准。

#### 基础载具

| 字段 | Recon Buggy | Sandskimmer | Strike Aircraft | Armored Vehicle (AAV) |
|---|---|---|---|---|
| **name_zh** | 侦察车 | 沙地飞艇 | 攻击机 | 装甲突击车 |
| **name_en** | Recon Buggy | Sandskimmer | Strike Aircraft | Armored Assault Vehicle |
| **faction** | Coalition | Coalition | Coalition | Coalition |
| **game** | DoK | DoK | DoK | DoK |
| **tier** | 轻型 | 轻型 | 空军 | 中型 |
| **built_from** | Carrier | Carrier | Carrier | Carrier |
| **cost_CU** | ~100 | ~200 | ~300 | ~300 |
| **build_time** | ~10s | ~15s | ~20s | ~20s |
| **pop** | 1 | 1 | 1 | 1 |
| **research_req** | 无 | 无 | Aircraft Tech | Armor Tech |
| **hp** | ~200 | ~250 | ~150 | ~500 |
| **armor** | 轻型 | 轻型 | 轻型 | 中型 |
| **tags** | 侦察/高速 | 骚扰/反轻 | 空军/反装甲 | 坦克/反轻 |
| **speed** | 高 | 高 | 空中(不受地形) | 中 |
| **damage** | ~15 | ~25 | ~60(对地) | ~40 |
| **atk_type** | 机枪 | 导弹/炮 | 航炮/导弹 | 重型炮 |
| **range** | 短 | 短 | 中 | 中 |
| **target** | 轻型 | 轻型 | 装甲 | 轻型 |
| **bonus_vs** | 无 | 轻型 | 装甲 | 轻型 |
| **active** | — | — | — | — |
| **passive** | 高速/视野大 | — | 可飞越地形 | — |
| **special** | 便宜量大 | 高机动骚扰 | 空中支援 | 正面抗线 |
| **strike_group_role** | 侦察 | 骚扰 | 空中打击 | 前线坦克 |

#### 中高级载具

| 字段 | Railgun Vehicle | Heavy Railgun | Artillery | Support Cruiser | Production Cruiser |
|---|---|---|---|---|---|
| **name_zh** | 电磁炮车 | 重型电磁炮 | 自行火炮 | 支援巡洋舰 | 生产巡洋舰 |
| **name_en** | Railgun | Heavy Railgun | Artillery | Support Cruiser | Production Cruiser |
| **faction** | Coalition | Coalition | Coalition | Coalition | Coalition |
| **game** | DoK | DoK | DoK | DoK | DoK |
| **tier** | 中型 | 重型 | 重型 | 重型 | 重型 |
| **built_from** | Carrier | Carrier | Carrier | Carrier | Carrier |
| **cost_CU** | ~350 | ~500 | ~400 | ~500 | ~600 |
| **build_time** | ~25s | ~35s | ~30s | ~35s | ~40s |
| **pop** | 1 | 1 | 1 | 1 | 1 |
| **research_req** | Railgun Tech | Railgun Tech + Heavy Tech | Artillery Tech | Support Tech | Production Tech |
| **hp** | ~300 | ~450 | ~350 | ~600 | ~800 |
| **armor** | 中型 | 重型 | 中型 | 重型 | 重型 |
| **tags** | 远程狙击 | 超远程狙击 | 攻城/溅射 | 维修/C&C | 移动工厂 |
| **speed** | 中 | 低 | 低 | 中 | 低 |
| **damage** | ~80 | ~150 | ~100(溅射) | 0 | 0 |
| **atk_type** | 电磁炮弹 | 重型电磁炮弹 | 炮弹(范围) | — | — |
| **range** | 长 | 超长 | 超长 | — | — |
| **target** | 装甲 | 装甲/建筑 | 建筑/集群 | 友军 | — |
| **bonus_vs** | 装甲 | 建筑 | 建筑 | — | — |
| **active** | — | — | — | Repair(维修) / C&C(指挥增益) | — |
| **passive** | — | — | — | 自动维修附近友军 | 可生产基础载具 |
| **special** | 远程反装甲核心 | 终极反装甲/反建筑 | 超远距离攻城 | 维修+指挥光环 | 前线分基地 |
| **strike_group_role** | 远程火力 | 超远程狙击 | 攻城 | 后勤/增益 | 前线生产 |

#### 母舰级

| 字段 | Carrier (Sakala/Kapisi-class) |
|---|---|
| **name_zh** | 运载舰（萨卡拉/卡皮西部级） |
| **name_en** | Carrier |
| **faction** | Coalition |
| **game** | DoK |
| **tier** | 母舰级 |
| **built_from** | — (初始) |
| **cost_CU** | — |
| **hp** | ~5000 |
| **armor** | 超重 |
| **tags** | 移动基地/生产/研究 |
| **speed** | 低 |
| **damage** | ~50(自卫炮) |
| **active** | — |
| **passive** | 可生产所有单位；可研究科技 |
| **special** | 可自我修复附近友军；移动速度慢但可重新定位 |
| **strike_group_role** | 全军枢纽 |

#### 非战斗单位

| 字段 | Worker (Salik) |
|---|---|
| **name_zh** | 采集车 |
| **name_en** | Worker |
| **faction** | Coalition |
| **game** | DoK |
| **tier** | 非战斗 |
| **built_from** | Carrier |
| **cost_CU** | ~150 |
| **hp** | ~150 |
| **speed** | 中 |
| **special** | 从地表资源点采集 CU，返回 Carrier 卸货 |
| **strike_group_role** | 经济核心 |

---

### 3.6 Homeworld: Deserts of Kharak — Khaaneph & Soban（DLC 阵营）

> Khaaneph 和 Soban 是 Coalition 的变体阵营，共享基础单位框架但有关键差异。
> 以下仅列出与 Coalition 的差异点。

#### Khaaneph（卡内夫）差异

| 单位 | 差异 |
|---|---|
| **Carrier** | 更便宜但 HP 更低；生产速度更快 |
| **Sandskimmer** | 更快、更便宜但 HP 更低 — 强化骚扰 |
| **Railgun** | 射程略短但伤害更高 — 更激进 |
| **Strike Aircraft** | 更快但 HP 更低 |
| **特色** | 无 Production Cruiser 替代品；Carrier 更早可上前线 |
| **设计** | 沙漠掠夺者，快攻骚扰型，避免持久阵地战 |

#### Soban（索班）差异

| 单位 | 差异 |
|---|---|
| **Carrier** | 更贵但 HP 更高；自带防御炮塔更强 |
| **Railgun** | 可 Overcharge（过载射击）— 牺牲自身 HP 换取高伤害 |
| **Support Cruiser** | 维修效率更高；C&C 光环范围更大 |
| **Armored Vehicle** | 更贵但 HP 和伤害都更高 — 精锐型 |
| **Artillery** | 精度更高但射速更慢 |
| **特色** | 全单位更精锐但更贵；依赖 Overcharge 窗口打赢关键战斗 |
| **设计** | 雇佣军，少而精，战术微操型 |

---

## 附录：关键术语对照

| 英文 | 中文 | 说明 |
|---|---|---|
| Mothership | 母舰 | 全舰队核心，生产+研究枢纽 |
| Carrier | 航母/运载舰 | 移动前线基地 |
| RU (Resource Units) | 资源单位 | HW1/2 通用货币 |
| CU (Catalyst Units) | 催化单位 | DoK 货币 |
| Fighter | 战斗机 | 最小级别，HW2 以小队生产 |
| Corvette | 护航艇 | 中型，反战斗机/特种 |
| Frigate | 护卫舰 | 中坚火力，主力舰下级 |
| Capital Ship | 主力舰 | Destroyer/Cruiser 级 |
| Strike Group | 打击群/编队 | HW2 编队系统 |
| Hyperspace | 超空间跳跃 | 战略级跨地图移动 |
| Sensors Manager | 传感器管理器 | 全景战术视图 |
| Dock | 停泊/补给 | 战斗机回母舰补给（HW1有燃料系统） |
| Salvage | 打捞 | 捕获敌方舰船 |
| Ion Cannon | 离子炮 | 持续光束武器，反主力舰核心 |

---

## 数据来源说明

- **主要来源**：Homeworld Fandom Wiki (https://homeworld.fandom.com/)
- **辅助来源**：Homeworld 官方手册、Homeworld Remastered Patch Notes、社区数据库
- **限制说明**：本文档基于训练数据编写，因调研时网络访问受限，无法实时核对 wiki 最新数值。部分 HP/伤害/建造时间数值为近似值（标记 `~`）。如需精确数值用于游戏平衡设计，建议直接查阅 wiki 或游戏内 BigFile 数据。
- **版本差异**：Homeworld Remastered (2015) 对原版 HW1/HW2 的部分数值进行了调整，本文档以 Remastered 版为基准。
