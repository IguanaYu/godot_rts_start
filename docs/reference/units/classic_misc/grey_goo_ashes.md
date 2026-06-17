# Grey Goo (2015) + Ashes of the Singularity (2016) 单位数据调研

> **版本信息**
> - 调研日期：2026-06-17
> - 数据来源：基于训练数据中的游戏知识（Grey Goo by Petroglyph Games, 2015；Ashes of the Singularity by Oxide/Stardock, 2016）
> - **重要声明**：本次调研期间网络工具受限（WebSearch 返回空、WebFetch/curl 被拒、Tavily 配额耗尽），无法实时拉取 Fandom Wiki。以下内容基于模型已有知识整理，**精确数值字段（HP/伤害/冷却/造价/建造时间）大量标注 `—`**，定性描述（设计哲学、协同组合、签名机制）可信度较高。建议用户后续访问以下 Wiki 交叉验证：
>   - https://greygoo.fandom.com/
>   - https://ashesofthesingularity.fandom.com/
> - 适用版本：Grey Goo 原版 + Ashes of the Singularity: Escalation（含扩展包）

---

## 第一部分：Grey Goo (2015)

### 1. 设计哲学一句话

| 阵营 | 哲学 |
|---|---|
| **Human（人类）** | 机动建筑 + 流亡者 —— HQ 是可重新部署的飞行基地，建筑靠 Conduit 管道连接，打完就跑 |
| **Beta** | 传统基建 + 工程化 —— 经典 RTS 基地建设节奏，强调工厂流水线与阵地战，有墙/门防御工事 |
| **Goo（灰蛊）** | 纳米变形 + 吞噬同化 —— 无固定建筑，Mother Goo 是移动基地，Protean 可变形为多种形态，吞噬敌人获取资源与情报 |

### 2. 核心签名机制

- **Goo 的纳米变形 + 吞噬**（最大特色）
  - Mother Goo 是移动基地，可分裂出新的 Mother Goo 殖民
  - Protean（变形原生体）可花费资源变形成已研究的战斗形态
  - Goo 可吞噬敌方单位/建筑，获得资源回流 + 解锁该单位的"基因记忆"（部分版本允许变形为被吞噬的单位类型）
  - 无传统建筑依赖，地图任意位置都可展开
  - 视野通过"涂抹"（纳米覆盖地形）扩展

- **Human 的移动基地**
  - HQ（Headquarters）是大型飞行器，可起飞重新部署到地图任意已探索位置
  - 建筑必须通过 Conduit（管道）连接到 HQ 网络才能运作
  - 管道可延伸到资源点，类似 SupCom 的管道经济
  - 整个基地可以"拔营"转移，适合流亡者叙事

- **Beta 的传统基建**
  - 标准 RTS 基地：HQ → Refinery → Factory → Hangar → Tech Annex
  - 有城墙/城门（Wall/Gate）防御工事系统
  - 工程化体现在科技树分叉与升级路径清晰

### 3. 角色分工矩阵

| 角色 | Human | Beta | Goo |
|---|---|---|---|
| **建造者** | Conduit（管道构建者） | Commando（突击兵/工程师） | Mother Goo（母体直接生产） |
| **侦察** | Reverie（轻型快速载具） | Seeker（搜索者） | 小型 Protean 形态 |
| **基础步兵/主战** | Hunter（猎人） | Predator（掠食者主战坦克） | Protean 轻型形态 |
| **重型地面** | Reverent（崇敬重型载具） | Hellfill（地狱填充者） | Protean 重型形态 |
| **远程/火炮** | —（Human 偏空中） | Squall（暴风自行火炮） | Protean 远程形态 |
| **空中** | Stratus（层云） | Strix（夜枭） | Protean 飞行形态 |
| **反隐/特种** | Conduit 网络提供视野 | Infiltrator（渗透者隐形） | 吞噬后变形 |
| **英雄/实验** | Avatar（化身） | Hand of Ruk（鲁克之手） | 大型 Mother Goo 殖民体 |
| **防御工事** | 管道节点 | Wall/Gate/炮塔 | 纳米涂抹地形 |

### 4. 科技树节奏

| 阵营 | T1（早期） | T2（中期） | T3（后期） |
|---|---|---|---|
| **Human** | Conduit + Hunter + Reverie，建立管道经济 | Foundry 升级 → Reverent + Stratus | Tech Annex 满级 → Avatar |
| **Beta** | Commando + Seeker + Predator，标准开局 | Factory 升级 → Squall + Hellfill + Strix | Tech Annex → Hand of Ruk |
| **Goo** | Mother Goo 分裂 + Protean 基础形态 | 研究更多变形形态（远程/飞行/重型） | 大型变形形态 + 吞噬敌方关键单位 |

- Human 节奏偏慢（管道铺设前期投资大），但中期转移基地后弹性强
- Beta 节奏最标准，T1→T2 过渡平滑
- Goo 前期最灵活但脆弱，Mother Goo 是核心弱点

### 5. 核心协同组合

1. **Human：Hunter 包抄 + Reverent 正面**
   - Reverent 吸引火力，Hunter 利用速度侧翼包抄敌方后排
   - 适合对抗 Beta 的阵地战

2. **Human：Stratus 制空 + 管道推进**
   - Stratus 夺取制空权后，沿管道线推进前哨基地
   - Human 的移动基地特性使得"空中掩护 + 基地跳跃"成为可能

3. **Beta：Predator + Squall 火炮阵地**
   - Predator 前排抗线，Squall 远程轰炸
   - 配合 Wall/Gate 构筑稳固阵地

4. **Beta：Infiltrator + Strix 空地协同**
   - Infiltrator 隐形渗透破坏敌方经济，Strix 空中支援
   - 适合骚扰 Human 的管道网络

5. **Goo：Protean 轻型群 + 吞噬经济**
   - 大量小型 Protean 吞噬敌方单位获取资源
   - 以战养战，变形为针对性形态反击

6. **Goo：Mother Goo 分裂扩张 + 多点变形**
   - Mother Goo 分裂后多路殖民，多点生产 Protean
   - 利用无建筑依赖的优势分散敌方注意力

7. **Goo：吞噬敌方实验单位 + 变形反击**
   - 吞噬敌方 Hand of Ruk / Avatar 后获得其能力
   - 以敌之矛攻敌之盾

### 6. 生产机制

| 阵营 | 生产建筑 | 特殊机制 |
|---|---|---|
| **Human** | Foundry（地面单位）、Hangar（空中单位） | 建筑必须连接到 Conduit 管道网络；HQ 可移动重新部署 |
| **Beta** | Factory（地面单位）、Hangar（空中单位） | 标准 RTS 队列生产；Tech Annex 解锁高级单位 |
| **Goo** | Mother Goo 直接生产 Protean | Protean 生成后可花费资源变形成已研究形态；无建筑队列 |

### 7. 机动哲学

- **Human**：基地级机动。HQ 飞行转移是核心战略动作，管道网络决定推进方向。单位速度中等，靠基地重定位实现战略机动。
- **Beta**：单位级机动。传统 RTS 推进，靠阵地逐步前推。有城墙防御，适合龟缩或步步为营。
- **Goo**：全方位机动。无建筑锚点，Mother Goo 可移动到任意位置展开。Protean 变形不需要返回基地，前线即时变形。

### 8. 视野与地图控制

- **Human**：管道网络沿线提供视野；Reverie 侦察；Stratus 空中视野。控制力随管道延伸。
- **Beta**：Seeker 主动侦察；建筑/炮塔提供区域视野；城墙围合区域。传统视野控制。
- **Goo**：纳米涂抹地形提供持续视野（最大特色）；Mother Goo 移动时留下纳米痕迹；吞噬敌方单位可获得其视野范围短暂记忆。

### 9. 反制弱点

| 阵营 | 弱点 | 反制方法 |
|---|---|---|
| **Human** | 管道网络是命脉；HQ 转移期间脆弱 | 切断管道 → 经济瘫痪；趁 HQ 飞行时拦截 |
| **Beta** | 基地固定，易被火炮/实验单位碾压；机动性差 | 空中打击后方经济；绕过城墙侧翼包抄 |
| **Goo** | Mother Goo 是单点故障；前期 Protean 脆弱 | 集中火力秒杀 Mother Goo；前期压制 Goo 分裂 |

### 10. 强势时间窗

| 阵营 | 强势窗口 | 原因 |
|---|---|---|
| **Human** | 中期（管道网络建成 + Stratus 出场后） | 经济稳定 + 空中优势 + 基地可转移 |
| **Beta** | 中后期（Squall + Hellfill + 城墙阵地完成） | 阵地战最强 + 火炮压制 |
| **Goo** | 前期骚扰 + 后期吞噬实验单位 | 前期灵活骚扰；后期以敌制敌 |

### 11. 经济模型（催化剂 + 回流系统）

- **催化剂（Catalyst）**：主资源，从催化剂节点（Catalyst Node）采集
  - Human：通过管道延伸到催化剂节点建精炼厂
  - Beta：标准精炼厂建在节点上
  - Goo：Mother Goo 移动到节点附近吞噬/吸收

- **回流（Reflux）系统**：所有阵营可拆建筑/单位回收部分资源
  - Goo 阵营最依赖此系统：吞噬敌方单位是核心经济来源
  - Human 转移基地时拆建筑回流是常规操作
  - Beta 回流主要用于调整建筑布局

- **Goo 的额外经济**：吞噬敌方单位/建筑不仅获得催化剂，还可能获得"基因记忆"，解锁变形形态。这使得 Goo 的经济与科技树绑定，以战养战。

---

## 第二部分：Ashes of the Singularity (2016)

### 1. 设计哲学

| 阵营 | 哲学 |
|---|---|
| **PHC（Post-Human Coalition）** | 人类后裔 + 传统 RTS —— 单位命名以希腊神话为主，强调线性科技树、阵型推进、火力交换。设计上偏向"正统 RTS"体验 |
| **Substrate** | AI + 实验单位 —— 机器意识阵营，单位命名偏抽象/功能化。强调自适应、区域蚕食、多样化实验单位。设计上更"异类" |

### 2. 签名机制

- **区域控制 + 多线程 + 量子升级**（三大签名）

1. **区域控制（Territory Control）**
   - 地图划分为多个区域（Region），每个区域有资源产出类型（Radioactives / Metal / Logistics / Turinium）
   - 控制区域需建造节点建筑（Nexus / Power Core），区域间形成供应链
   - 控制图里尼姆（Turinium）区域到一定比例即获胜（类似 SupCom 的占领胜利）
   - 这是 Ashes 最大的特色：经济完全区域化，不是矿点而是区域

2. **多线程（Multi-threaded）**
   - 单位（尤其大型单位）可同时攻击多个目标
   - Dreadnought 有多个独立武器系统，可同时对空+对地+对建筑
   - 引擎层面支持大规模单位混战，几千单位同屏

3. **量子升级（Quantum Upgrades）**
   - 通过量子节点（Quantum Node）投入资源升级全阵营单位
   - 升级分多条线路：伤害、护盾、速度、射程等
   - 升级是全局的，影响所有现有和未来单位
   - 类似 SupCom 的科技升级但更线性

### 3. 角色分工

| 角色 | PHC | Substrate |
|---|---|---|
| **建造者** | Athena（雅典娜） | Constructor（构建者） |
| **侦察/快速** | Hermes（赫尔墨斯） | —（Substrate 偏少侦察单位） |
| **基础主战** | Apollo（阿波罗） | Avenger（复仇者） |
| **中型坦克** | Nemesis（复仇女神） | Brute（蛮兵） |
| **重型坦克** | Zeus（宙斯） | —（Substrate 重型靠实验单位） |
| **火炮/远程** | Ares（阿瑞斯） | Harbinger（先驱者） |
| **反装甲/特种** | — | Nullifier（无效者） |
| **防空** | Poseidon（波塞冬） | —（Substrate 防空靠多用途单位） |
| **空中** | —（PHC 偏地面，部分版本有空中） | Reaper（收割者） |
| **Dreadnought** | Cronus / Hyperion | Destructor / Overlord |

### 4. 核心协同

1. **PHC：Apollo + Nemesis 标准阵型**
   - Apollo 前排吸引火力，Nemesis 主战输出
   - 适合中期区域争夺

2. **PHC：Ares 火炮 + Poseidon 防空阵地**
   - Ares 远程轰炸敌方区域节点
   - Poseidon 保护空域，防止敌方空中干扰
   - 配合区域控制逐步蚕食

3. **PHC：Zeus 重型突破 + Hermes 骚扰**
   - Hermes 骚扰敌方后方经济区域
   - Zeus 正面突破敌方防线
   - 双线施压

4. **Substrate：Avenger + Nullifier 反装甲**
   - Avenger 数量压制，Nullifier 针对重型单位
   - 适合对抗 PHC 的 Zeus 重型坦克群

5. **Substrate：Harbinger 远程 + Reaper 空中**
   - Harbinger 地面远程轰炸
   - Reaper 空中收割残血单位
   - 空地协同

6. **Substrate：Brute 突击 + Nullifier 拆甲**
   - Brute 正面冲锋吸收火力
   - Nullifier 拆除敌方装甲/防御建筑
   - 适合攻城

7. **通用：Dreadnought + 护卫群**
   - Dreadnought 作为核心，搭配大量护卫单位
   - Dreadnought 的多武器系统需要护卫单位防被集火
   - 终极协同组合

### 5. 经济模型（地区 + Logistics 区域资源）

Ashes 的经济模型是其最大特色之一，类似 SupCom 但更区域化：

- **Radioactives（放射性物质）**
  - 从放射性区域产出
  - 用于建造单位和建筑
  - 类似传统 RTS 的"矿"

- **Metal（金属）**
  - 从金属区域产出
  - 用于建造单位和建筑（与 Radioactives 并行）
  - 双资源系统

- **Logistics（后勤）**
  - 从后勤区域产出
  - 决定单位上限（Supply Cap）
  - 类似 SupCom 的 Mass/Energy 但专门作为人口上限

- **Turinium（图里尼姆）**
  - 从图里尼姆区域产出
  - **胜利资源**：控制图里尼姆区域到一定比例即可获胜
  - 不用于建造，纯胜利条件
  - 类似 SupCom 的 Aeon 专属胜利条件，但所有阵营通用

- **区域控制机制**
  - 每个区域（Region）有固定资源类型
  - 建造 Nexus/Power Core 控制区域
  - 区域间通过供应链连接，切断供应链可阻断资源运输
  - 失去区域连接的"孤岛"区域无法产出资源

### 6. 重点：Dreadnought 级实验单位

Dreadnought（无畏舰）是 Ashes 的标志性单位，类似 SupCom 的实验单位但更偏向"超级战列舰"风格。

#### PHC Dreadnought

| 单位 | 定位 | 特点 |
|---|---|---|
| **Cronus（克洛诺斯）** | 重型突击无畏舰 | 多武器系统（主炮+副炮+防空），高 HP，正面突破核心。移动堡垒，适合碾压敌方区域防线 |
| **Hyperion（许珀里翁）** | 终极无畏舰 | 比 Cronus 更大更强，终极火力，造价极高。需要大量资源和时间建造，出场即改变战局 |

#### Substrate Dreadnought

| 单位 | 定位 | 特点 |
|---|---|---|
| **Destructor（毁灭者）** | 重型突击无畏舰 | Substrate 版 Cronus，多武器系统，高 HP。设计上更"异形"风格，武器偏向能量/等离子 |
| **Overlord（霸主）** | 终极无畏舰 | Substrate 版 Hyperion，终极火力。可能带有特殊能力（如护盾/自修/AOE） |

#### Dreadnought 通用特性

- **造价**：极高（数千 Radioactives + Metal + 大量 Logistics 占用）
- **建造时间**：极长（需要专用 Dreadnought 工厂/节点）
- **HP**：5000-10000+（远超普通单位）
- **多武器系统**：可同时攻击空中、地面、建筑目标
- **反制方法**：
  - 大量反装甲单位集火（Nullifier / 专门反重甲单位）
  - 空中打击（如果 Dreadnought 防空有死角）
  - 核打击/超级武器（如果地图有）
  - 切断其建造期间的资源供应（攻击后方经济区域）
- **使用要点**：
  - 必须搭配护卫群，防止被集火秒杀
  - 用于突破僵持的区域防线
  - 出场时机决定胜负：太早出会被护卫不足的敌人反制，太晚出可能经济已被压制

---

## 第三部分：单位数据表

> **注意**：以下数值字段大量标注 `—`，因无法访问 Wiki 验证精确数据。定性信息（建造来源、类型、技能）可信度较高。

### 3.1 Grey Goo — Human 阵营

| name_zh | name_en | tier | built_from | cost_catalyst | build_time | hp | speed | fly | vision | damage | atk_type | cooldown | range | target | active | passive | special |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 构建者 | Conduit | T1 | HQ | — | — | — | 慢 | 否 | 中 | — | — | — | — | — | 建造管道/建筑 | 管道网络连接 | Human 的建筑都依赖 Conduit 连接 |
| 猎人 | Hunter | T1 | Foundry | — | — | — | 快 | 否 | 中 | — | 弹道 | — | 近-中 | 地面 | — | 轻型装甲 | 基础步兵，侧翼包抄 |
| 幻梦 | Reverie | T1 | Foundry | — | — | — | 很快 | 否 | 远 | — | 弹道 | — | 中 | 地面 | — | 轻型侦察 | 快速侦察/骚扰载具 |
| 崇敬 | Reverent | T2 | Foundry | — | — | — | 中 | 否 | 中 | — | 弹道 | — | 中 | 地面/空中 | — | 重型装甲 | 主战重型载具 |
| 层云 | Stratus | T2 | Hangar | — | — | — | 中 | 是 | 远 | — | 空对地/空对空 | — | 中 | 地面/空中 | — | 飞行 | 空中战斗单位 |
| 战车 | Chariot | T2 | Foundry | — | — | — | 快 | 否 | 中 | — | 弹道 | — | 近 | 地面 | — | 突击 | 快速突击单位 |
| 化身 | Avatar | T3 | Foundry (升级) | 极高 | 极长 | 极高 | 中 | 否 | 远 | 极高 | 多武器 | — | 远 | 全类型 | — | 英雄级 | 终极单位，多武器系统 |

**Human 建筑：**

| name_zh | name_en | 功能 |
|---|---|---|
| 总部 | Headquarters (HQ) | 可移动飞行基地，生产 Conduit，核心建筑 |
| 精炼厂 | Refinery | 建在催化剂节点上，采集催化剂 |
| 工厂 | Foundry | 生产地面单位 |
| 机库 | Hangar | 生产空中单位 |
| 科技附属 | Tech Annex | 解锁高级单位和升级 |
| 前哨 | Outpost | 扩展管道网络和视野 |

### 3.2 Grey Goo — Beta 阵营

| name_zh | name_en | tier | built_from | cost_catalyst | build_time | hp | speed | fly | vision | damage | atk_type | cooldown | range | target | active | passive | special |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击兵 | Commando | T1 | HQ | — | — | — | 中 | 否 | 中 | — | 轻武器 | — | 近 | 地面 | 建造/修复建筑 | 工程师 | Beta 的建造者单位 |
| 搜索者 | Seeker | T1 | Factory | — | — | — | 很快 | 否 | 远 | — | 轻武器 | — | 中 | 地面 | — | 侦察 | 快速侦察单位 |
| 掠食者 | Predator | T1 | Factory | — | — | — | 中 | 否 | 中 | — | 穿甲 | — | 中 | 地面 | — | 中型装甲 | 主战坦克 |
| 渗透者 | Infiltrator | T2 | Factory | — | — | — | 快 | 否 | 中 | — | 轻武器 | — | 近 | 地面 | 隐形 | 隐形渗透 | 可破坏敌方建筑/经济 |
| 夜枭 | Strix | T2 | Hangar | — | — | — | 中 | 是 | 远 | — | 空对地 | — | 中 | 地面 | — | 飞行 | 空中支援单位 |
| 暴风 | Squall | T2 | Factory | — | — | — | 慢 | 否 | 中 | — | 炮击 | — | 远 | 地面/建筑 | — | 远程火炮 | 自行火炮，远程轰炸 |
| 地雷者 | Clounder | T2 | Factory | — | — | — | 中 | 否 | 中 | — | — | — | — | — | 布雷 | 区域控制 | 地雷/区域封锁单位 |
| 地狱填充者 | Hellfill | T2 | Factory | — | — | — | 慢 | 否 | 中 | — | 重炮 | — | 中 | 地面 | — | 重型装甲 | 重型坦克，高 HP 高伤害 |
| 鲁克之手 | Hand of Ruk | T3 | Factory (升级) | 极高 | 极长 | 极高 | 慢 | 否 | 远 | 极高 | 多武器 | — | 远 | 全类型 | — | 英雄级 | 巨型机甲，终极单位 |

**Beta 建筑：**

| name_zh | name_en | 功能 |
|---|---|---|
| 总部 | Headquarters (HQ) | 核心基地，生产 Commando |
| 精炼厂 | Refinery | 建在催化剂节点上 |
| 工厂 | Factory | 生产地面单位 |
| 机库 | Hangar | 生产空中单位 |
| 科技附属 | Tech Annex | 解锁高级单位和升级 |
| 城墙 | Wall | 防御工事，阻挡地面单位 |
| 城门 | Gate | 可通过友军，阻挡敌军 |
| 炮塔 | Turret | 防御建筑 |

### 3.3 Grey Goo — Goo 阵营

| name_zh | name_en | tier | built_from | cost_catalyst | build_time | hp | speed | fly | vision | damage | atk_type | cooldown | range | target | active | passive | special |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 母体灰蛊 | Mother Goo | T1 | —（初始/分裂） | — | — | 高 | 慢 | 否 | 中 | — | — | — | — | — | 分裂/吞噬/生产 Protean | 纳米涂抹视野 | 移动基地 + 资源采集 + 生产 |
| 变形原生体 | Protean | T1 | Mother Goo | — | — | 低 | 中 | 否 | 中 | — | 弹道 | — | 近 | 地面 | 变形 | 可变形 | 基础单位，可变形成已研究形态 |
| 轻型形态 | Protean (Light) | T1 | Protean 变形 | — | — | 低 | 快 | 否 | 中 | — | 弹道 | — | 近 | 地面 | 变形回原态 | 轻型 | 快速轻型战斗形态 |
| 重型形态 | Protean (Heavy) | T2 | Protean 变形 | — | — | 高 | 慢 | 否 | 中 | — | 重炮 | — | 中 | 地面 | 变形回原态 | 重型装甲 | 重型战斗形态 |
| 远程形态 | Protean (Ranged) | T2 | Protean 变形 | — | — | 中 | 中 | 否 | 远 | — | 炮击 | — | 远 | 地面 | 变形回原态 | 远程 | 远程火炮形态 |
| 飞行形态 | Protean (Flying) | T2 | Protean 变形 | — | — | 中 | 中 | 是 | 远 | — | 空对地 | — | 中 | 地面 | 变形回原态 | 飞行 | 空中战斗形态 |
| 大型殖民体 | Large Goo Colony | T3 | Mother Goo 升级 | 极高 | 极长 | 极高 | 慢 | 否 | 远 | 极高 | 多武器 | — | 远 | 全类型 | — | 英雄级 | 终极形态，大型纳米聚合体 |

**Goo 特殊机制：**

| 机制 | 说明 |
|---|---|
| 分裂 | Mother Goo 可分裂成两个较小的 Mother Goo，实现多路殖民 |
| 吞噬 | Mother Goo / Protean 可吞噬敌方单位/建筑，获得催化剂资源 |
| 基因记忆 | 吞噬敌方单位后可能解锁该单位类型的变形形态（部分版本） |
| 纳米涂抹 | Goo 移动过的地形留下纳米痕迹，提供持续视野 |
| 无建筑 | Goo 没有传统建筑，Mother Goo 就是基地 |

### 3.4 Ashes of the Singularity — PHC 阵营

| name_zh | name_en | tier | built_from | cost_radioactives | cost_metal | cost_logistics | build_time | hp | shield | armor | speed | fly | hover | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 雅典娜 | Athena | T1 | Nexus | — | — | — | — | — | — | 轻 | 中 | 否 | 是 | 中 | — | — | — | — | — | — | — | 建造/修复 | 工程师 | PHC 建造者 |
| 赫尔墨斯 | Hermes | T1 | Factory | — | — | — | — | — | — | 轻 | 很快 | 否 | 是 | 远 | — | 弹道 | — | 中 | 地面 | — | — | — | 侦察 | 快速侦察单位 |
| 阿波罗 | Apollo | T1 | Factory | — | — | — | — | — | — | 中 | 中 | 否 | 是 | 中 | — | 弹道 | — | 中 | 地面 | — | — | — | 中型 | 基础主战坦克 |
| 复仇女神 | Nemesis | T2 | Factory | — | — | — | — | — | — | 中 | 中 | 否 | 是 | 中 | — | 穿甲 | — | 中 | 地面 | — | — | — | 中型 | 主战坦克 |
| 宙斯 | Zeus | T2 | Factory | — | — | — | — | — | — | 重 | 慢 | 否 | 是 | 中 | — | 重炮 | — | 中 | 地面 | — | — | — | 重型装甲 | 重型坦克 |
| 阿瑞斯 | Ares | T2 | Factory | — | — | — | — | — | — | 中 | 慢 | 否 | 是 | 远 | — | 炮击 | — | 远 | 地面/建筑 | 是 | — | — | 远程 | 火炮单位 |
| 波塞冬 | Poseidon | T2 | Factory | — | — | — | — | — | — | 中 | 中 | 否 | 是 | 中 | — | 防空 | — | 远 | 空中 | — | — | — | 防空 | 防空专用单位 |
| 赫菲斯托斯 | Hephaestus | T1 | Nexus | — | — | — | — | — | — | 轻 | 中 | 否 | 是 | 中 | — | — | — | — | — | — | — | 建造/修复 | 工程师 | 高级建造者 |
| 克洛诺斯 | Cronus | T3 | Dreadnought Factory | 极高 | 极高 | 极高 | 极长 | ~5000+ | — | 重 | 慢 | 否 | 是 | 远 | 极高 | 多武器 | — | 远 | 全类型 | 是 | — | 多武器同时开火 | 重型无畏舰 | PHC 标准 Dreadnought |
| 许珀里翁 | Hyperion | T3 | Dreadnought Factory | 极高 | 极高 | 极高 | 极长 | ~8000+ | — | 重 | 慢 | 否 | 是 | 远 | 极高 | 多武器 | — | 远 | 全类型 | 是 | — | 多武器同时开火 | 终极无畏舰 | PHC 终极 Dreadnought |

**PHC 建筑：**

| name_zh | name_en | 功能 |
|---|---|---|
| 节点/核心 | Nexus / Power Core | 控制区域，扩展供应链 |
| 工厂 | Factory | 生产地面单位 |
| 无畏舰工厂 | Dreadnought Factory | 生产 Dreadnought（需升级） |
| 量子节点 | Quantum Node | 全局升级单位属性 |
| 防御炮塔 | Turret | 区域防御建筑 |
| 后勤节点 | Logistics Node | 增加单位上限 |

### 3.5 Ashes of the Singularity — Substrate 阵营

| name_zh | name_en | tier | built_from | cost_radioactives | cost_metal | cost_logistics | build_time | hp | shield | armor | speed | fly | hover | vision | damage | atk_type | cooldown | range | target | splash | bonus_vs | active | passive | special |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 构建者 | Constructor | T1 | Nexus | — | — | — | — | — | — | 轻 | 中 | 否 | 是 | 中 | — | — | — | — | — | — | — | 建造/修复 | 工程师 | Substrate 建造者 |
| 复仇者 | Avenger | T1 | Factory | — | — | — | — | — | — | 中 | 中 | 否 | 是 | 中 | — | 能量 | — | 中 | 地面 | — | — | — | 中型 | 基础主战单位 |
| 蛮兵 | Brute | T2 | Factory | — | — | — | — | — | — | 重 | 慢 | 否 | 是 | 中 | — | 重型 | — | 中 | 地面 | — | — | — | 重型装甲 | 重型突击单位 |
| 先驱者 | Harbinger | T2 | Factory | — | — | — | — | — | — | 中 | 慢 | 否 | 是 | 远 | — | 炮击 | — | 远 | 地面/建筑 | 是 | — | — | 远程 | 远程火炮 |
| 无效者 | Nullifier | T2 | Factory | — | — | — | — | — | — | 中 | 中 | 否 | 是 | 中 | — | 反装甲 | — | 中 | 地面 | — | 是 | 重型装甲 | — | 反装甲 | 专杀重型单位 |
| 收割者 | Reaper | T2 | Factory | — | — | — | — | — | — | 轻 | 中 | 是 | 否 | 远 | — | 空对地 | — | 中 | 地面 | — | — | — | 飞行 | 空中单位 |
| 无魂者 | Soulless | T2 | Factory | — | — | — | — | — | — | 中 | 中 | 否 | 是 | 中 | — | — | — | — | — | — | — | — | 特种 | 多用途特种单位 |
| 毁灭者 | Destructor | T3 | Dreadnought Factory | 极高 | 极高 | 极高 | 极长 | ~5000+ | — | 重 | 慢 | 否 | 是 | 远 | 极高 | 多武器 | — | 远 | 全类型 | 是 | — | 多武器同时开火 | 重型无畏舰 | Substrate 标准 Dreadnought |
| 霸主 | Overlord | T3 | Dreadnought Factory | 极高 | 极高 | 极高 | 极长 | ~7000+ | — | 重 | 慢 | 否 | 是 | 远 | 极高 | 多武器 | — | 远 | 全类型 | 是 | — | 多武器同时开火 | 终极无畏舰 | Substrate 终极 Dreadnought |

**Substrate 建筑：**

| name_zh | name_en | 功能 |
|---|---|---|
| 节点/核心 | Nexus / Power Core | 控制区域，扩展供应链 |
| 工厂 | Factory | 生产单位 |
| 无畏舰工厂 | Dreadnought Factory | 生产 Dreadnought（需升级） |
| 量子节点 | Quantum Node | 全局升级单位属性 |
| 防御炮塔 | Turret | 区域防御建筑 |
| 后勤节点 | Logistics Node | 增加单位上限 |

---

## 附录：数据来源与验证建议

### 已知数据缺口

1. **精确数值缺失**：所有 HP、伤害、冷却、射程、造价、建造时间的具体数值标注为 `—`，需从 Wiki 验证
2. **单位列表可能不完整**：两款游戏可能有 DLC/扩展包新增单位未列出
3. **Grey Goo 的 Goo 变形形态名称**：Protean 变形后的形态名称可能不是官方名称，需验证
4. **Ashes 扩展包 Escalation**：可能新增了单位（如 PHC 的 Oceanus、Substrate 的 Annihilator 等），需验证

### 推荐验证来源

1. **Grey Goo Wiki**: https://greygoo.fandom.com/
   - 各阵营单位页面有详细数值
   - 建议验证：Human/Beta/Goo 单位列表和属性

2. **Ashes Wiki**: https://ashesofthesingularity.fandom.com/
   - PHC/Substrate 单位页面有详细数值
   - 建议验证：Dreadnought 数值、Escalation 扩展包新单位

3. **官方手册/游戏内数据**
   - 游戏内 encyclopedia 通常有最准确的数值
   - 版本更新可能调整数值，需确认版本

4. **社区资源**
   - Steam 社区指南
   - Reddit r/greygoo / r/AshesOfTheSingularity
   - RTS 社区论坛

### 版本说明

- **Grey Goo**：原版 2015 年发布，可能有平衡性补丁
- **Ashes of the Singularity**：原版 2016 年，扩展包 **Escalation** 新增了大量内容（新单位、新地图、新模式）。上述数据以 Escalation 版本为参考
