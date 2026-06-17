# 星际争霸2 合作指挥官单位数据参考

> 版本：StarCraft II 5.0+（精通/威望系统）
> 最后更新：2026-06
> 数据来源：游戏内数据、Liquipedia、StarCraft Fandom Wiki、starcraft2coop.com

---

## 第一部分：合作模式概述

合作模式（Co-op Missions）是星际争霸2的PVE游戏模式。两名玩家选择指挥官并肩作战，对抗由 AI "亚蒙"（Amon）控制的部队。

**核心设计特点：**
- 共 18 位指挥官，每位拥有独立的单位池、升级树和顶级栏技能
- 每位指挥官有自己的**设计主轴**（例如 Raynor = 生化海，Swann = 机械化）
- 每个指挥官拥有**独特单位**（标准对战没有的）和**变异单位**（标准单位经大幅改动）
- 精通等级（Mastery）和威望系统（Prestige）进一步定制玩法
- 部分指挥官拥有**英雄单位**（Hero Unit），可重生，战斗力远超普通单位

---

## 第二部分：按指挥官列出

---

### 1. Raynor — 雷诺（Terran）

**设计哲学：** 生化海 + 医疗兵 + MULE 经济爆发，用数量和质量碾压敌人。

**签名单位：** Firebat（火焰兵）、Vulture（秃鹫）、Dusk Wings（黄昏之翼）、Hyperion（休伯利安号）

**核心协同：** Marine + Medic + Firebat 为核心生化地面部队；Vulture 蜘蛛雷控场；Banshee/Viking 提供空中支援。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 火焰兵 | Firebat | Terran | 独特单位 | 200 | — | 3 | 18(+6对轻甲) | 1.5 | 3（升级后5） | 地面 | 火焰喷射（扇形AOE）、Widen Firebat（升级后溅射半径+40%） | 战役单位；科技实验室解锁升级可使血量+100、护甲+2 |
| 秃鹫 | Vulture | Terran | 独特单位 | 100 | — | 0 | 20(+10对重甲) | 1.5 | 5 | 地面 | 蜘蛛雷（Spider Mine）：放置地雷自动追击敌人，爆炸50伤害AOE | 战役单位；升级可使蜘蛛雷触发半径+33% |
| 黄昏之翼 | Dusk Wings | Terran | 召唤单位（Banshee） | 200 | — | 2 | 24×2 | 1.1 | 8（隐形时+2） | 空/地 | 隐形（永久），到达时AOE轰炸 | 顶级栏技能召唤，有存活时间限制 |
| 休伯利安号 | Hyperion | Terran | 召唤单位（Battlecruiser） | 3000 | — | 4 | 20×8 | 0.23 | 10 | 空/地 | 等离子鱼雷、对空导弹 | 顶级栏技能召唤，有存活时间限制 |
| 陆战队 | Marine | Terran | 标准变异 | 80 | — | 0 | 8(+3对轻甲) | 0.86 | 5 | 空/地 | 可兴奋剂 | 同标准版；通过升级获得攻击速度+15% |
| 劫掠者 | Marauder | Terran | 标准变异 | 150 | — | 1 | 20(+10对重甲) | 1.5 | 6 | 地面 | 可兴奋剂、震荡弹 | 同标准版 |
| 医疗兵 | Medic | Terran | 标准变异 | 100 | — | 1 | — | — | 4（升级后） | 友军 | 治疗（可治疗机械单位）、减少被治疗单位受伤 | 升级后可比标准版治疗机械单位 |
| 围攻坦克 | Siege Tank | Terran | 标准变异 | 200 | — | 2 | 40(+15对重甲) | 2.8 | 13（攻城） | 地面 | 攻城模式 | 同标准版 |
| 维京战机 | Viking | Terran | 标准变异 | 150 | — | 1 | 24(+8对机械) | 0.9 | 9（空） | 空/地 | 可变形 | 同标准版 |
| 女妖战机 | Banshee | Terran | 标准变异 | 175 | — | 2 | 24×2 | 1.1 | 8（隐形时+2） | 空/地 | 隐形 | 隐形时射程+2（独特升级） |
| 战列巡航舰 | Battlecruiser | Terran | 标准变异 | 750 | — | 4 | 20×8 | 0.23 | 10 | 空/地 | 等离子鱼雷、战术跃迁 | 同标准版 |

---

### 2. Kerrigan — 凯瑞甘（Zerg）

**设计哲学：** 英雄女王冲锋 + 虫海，凯瑞甘本人就是最强武器。

**签名单位：** Omega Worm（Omega虫道）、Kerrigan（英雄单位）

**核心协同：** Kerrigan 开路 + Zergling/Hydralisk 跟进；Omega Worm 全图机动。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 凯瑞甘（英雄） | Kerrigan (Hero) | Zerg | 英雄单位 | 500+500护盾 | 500 | 3 | 60(+30对重甲) | 1.5 | 近战 | 地面 | 跳跃攻击（Leaping Strike 300伤害）、灵能位移（Psionic Shift 100伤害AOE）、定身波（Immobilization Wave）、牵引（Kinetic Blast）、暴怒（Fury：每次攻击+10%攻速最高50%） | 死亡后在孵化场重生；精通可增加攻速 |
| Omega虫道 | Omega Worm | Zerg | 变异单位（Nydus） | 800 | — | 2 | — | — | — | — | 可在任意视野内位置钻出、免费建造、可反隐、可驻军移动 | 取代Nydus Network；Kerrigan Lv8解锁 |
| 异化虫 | Zergling | Zerg | 标准变异 | 40 | — | 0 | 10(+5对重甲) | 0.69 | 近战 | 地面 | 攻击可减目标护甲至0持续10秒 | 升级后获得减甲能力 |
| 刺蛇 | Hydralisk | Zerg | 标准变异 | 100 | — | 1 | 18(+6对轻甲) | 0.83 | 6 | 空/地 | 狂乱（Frenzy）：攻速+50%持续15秒 | 升级后解锁Frenzy |
| 异龙 | Mutalisk | Zerg | 标准变异 | 140 | — | 1 | 12×3（弹射） | 1.5 | 4 | 空/地 | 弹射攻击 | 同标准版 |
| 雷兽 | Ultralisk | Zerg | 标准变异 | 500 | — | 4 | 35(+20对重甲) | 1.3 | 近战 | 地面 | 溅射 | 同标准版 |
| 感染者 | Infestor | Zerg | 标准变异 | 150 | — | 0 | — | — | — | — | 真菌增生、神经控制 | 同标准版 |
| 腐化者 | Corruptor | Zerg | 标准变异 | 200 | — | 2 | 18(+8对重甲) | 1.5 | 7 | 空中 | 腐化（降低目标伤害40%） | 同标准版 |
| 巢虫领主 | Brood Lord | Zerg | 标准变异 | 350 | — | 3 | 24（巢虫） | 2.0 | 11 | 地面 | 孵化巢虫攻击 | 同标准版 |

---

### 3. Artanis — 阿塔尼斯（Protoss）

**设计哲学：** 全单位折越 + 太阳矛轨道打击，刚正面推进。

**签名单位：** Dragoon（龙骑士）、High Archon（高阶执政官）

**核心协同：** Dragoon + Zealot + Immortal 混合部队；Spear of Adun 技能支援。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 龙骑士 | Dragoon | Protoss | 独特单位 | 150 | 100 | 2 | 30(+10对重甲) | 1.5 | 6 | 空/地 | — | 战役单位；星际1经典兵种 |
| 高阶执政官 | High Archon | Protoss | 变异单位（Archon） | 10 | 350 | 0 | 35(+15对生物) | 1.2 | 3 | 空/地 | 可使用反馈（Feedback）和灵能风暴（Psionic Storm） | 普通执政官无法使用技能；升级后风暴可给友军回盾50 |
| 狂战士 | Zealot | Protoss | 标准变异 | 150 | 50 | 1 | 16(+8对重甲) | 1.2 | 近战 | 地面 | 冲锋 | 同标准版 |
| 追猎者 | Stalker | Protoss | 标准变异 | 100 | 80 | 1 | 20(+10对重甲) | 1.5 | 6 | 空/地 | 闪烁 | 同标准版 |
| 不朽者 | Immortal | Protoss | 标准变异 | 200 | 150 | 2 | 35(+25对重甲) | 1.7 | 6 | 地面 | 屏障 | 同标准版 |
| 巨像 | Colossus | Protoss | 标准变异 | 250 | 150 | 2 | 30×2 | 2.0 | 7 | 地面 | 热射线（可跨越地形） | 同标准版 |
| 高阶圣堂武士 | High Templar | Protoss | 标准变异 | 40 | 40 | 0 | — | — | — | — | 灵能风暴、反馈、合成执政官 | 起始能量50→升级后200 |
| 虚空辉光舰 | Void Ray | Protoss | 标准变异 | 150 | 100 | 1 | 22(+14对重甲) | 0.5 | 8 | 空/地 | 充能光束（对同一目标持续增伤） | 同标准版 |
| 航母 | Carrier | Protoss | 标准变异 | 250 | 150 | 2 | 8×8拦截机 | — | 14 | 空/地 | 释放拦截机 | 同标准版 |

---

### 4. Swann — 斯旺（Terran）

**设计哲学：** 重型机械化 + 激光钻机 + 防御专家。

**签名单位：** HERC（赫克）、Thor（雷神-变异）、Science Vessel（科学船）、Laser Drill（激光钻机）

**核心协同：** Siege Tank + Goliath 地面核心；Science Vessel 提供反隐和治疗机械；Thor 作为重型输出。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 赫克 | HERC | Terran | 独特单位 | 300 | — | 2 | 25(+15对重甲) | 1.2 | 近战 | 地面 | 跳跃攻击（Jump Jets）：跳入敌阵造成AOE伤害并减速 | 战役单位；Swann独有步兵 |
| 科学船 | Science Vessel | Terran | 独特单位 | 200 | — | 2 | — | — | — | — | 辐射（Irradiate）、防御矩阵（Defense Matrix）、反隐 | 星际1经典单位回归；可治疗机械 |
| 雷神 | Thor | Terran | 变异单位 | 500 | — | 3 | 50(+30对重甲) | 1.5 | 7（地对地）/10（地对空） | 空/地 | 对空火箭弹幕（250mm Strike Cannons） | 比标准雷神更强；对空模式切换 |
| 歌莉娅 | Goliath | Terran | 独特单位 | 200 | — | 2 | 24(+8对重甲)地对地/18(+6对重甲)地对空 | 1.3 | 6（地）/8（空） | 空/地 | 双管对空导弹 | 星际1经典单位回归 |
| 火焰兵 | Hellion | Terran | 标准变异 | 100 | — | 1 | 18(+12对轻甲) | 2.0 | 5 | 地面 | 可变形为Hellbat | 同标准版 |
| 攻城坦克 | Siege Tank | Terran | 标准变异 | 200 | — | 2 | 40(+15对重甲) | 2.8 | 13（攻城） | 地面 | 攻城模式 | 同标准版 |
| 医疗运输机 | Medivac | Terran | 标准变异 | 150 | — | 1 | — | — | — | — | 治疗、运输 | 同标准版 |
| 女妖战机 | Banshee | Terran | 标准变异 | 175 | — | 2 | 24×2 | 1.1 | 8 | 空/地 | 隐形 | 同标准版 |
| 战列巡航舰 | Battlecruiser | Terran | 标准变异 | 750 | — | 4 | 20×8 | 0.23 | 10 | 空/地 | 等离子鱼雷、战术跃迁 | 同标准版 |

---

### 5. Zagara — 扎加拉（Zerg）

**设计哲学：** 极限爆兵 + 自杀式攻击，用廉价单位淹没敌人。

**签名单位：** Scourge（自爆蚊）、Aberration（变异体）、Bile Launcher（胆汁喷射体）、Baneling（毒爆虫-强化版）

**核心协同：** Zergling + Baneling 主力地面；Scourge 反空；Aberration 做肉盾。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 自爆蚊 | Scourge | Zerg | 独特单位 | 30 | — | 0 | 110对空 | — | 近战 | 空中 | 自爆（对空单体高伤害） | 星际1经典单位回归；廉价反空 |
| 变异体 | Aberration | Zerg | 独特单位 | 500 | — | 2 | 30(+15对重甲) | 1.5 | 近战 | 地面 | 可突破单位碰撞（碾压小单位），死亡后分裂出2只小虫 | Zagara独有肉盾单位 |
| 胆汁喷射体 | Bile Launcher | Zerg | 独特建筑 | 500 | — | 2 | 60(+30对重甲) | 3.0 | 10 | 空/地 | 溅射AOE、可反隐 | Zagara独有防御建筑 |
| 毒爆虫 | Baneling | Zerg | 变异单位 | 40 | — | 0 | 30(+20对轻甲) | — | 近战 | 地面 | 自爆AOE | 免费孵化（Zergling自动变Baneling，需升级）；产量极大 |
| 异化虫 | Zergling | Zerg | 标准变异 | 35 | — | 0 | 10(+5对重甲) | 0.69 | 近战 | 地面 | 可升级为Baneling | 比标准版更便宜（Zagara特色） |
| 刺蛇 | Hydralisk | Zerg | 标准变异 | 100 | — | 1 | 18(+6对轻甲) | 0.83 | 6 | 空/地 | — | 同标准版 |
| 异龙 | Mutalisk | Zerg | 标准变异 | 140 | — | 1 | 12×3（弹射） | 1.5 | 4 | 空/地 | 弹射攻击 | 同标准版 |
| 腐化者 | Corruptor | Zerg | 标准变异 | 200 | — | 2 | 18(+8对重甲) | 1.5 | 7 | 空中 | — | 同标准版 |

---

### 6. Vorazun — 沃拉尊（Protoss）

**设计哲学：** 暗影科技 + 隐形 + 时间操控。

**签名单位：** Dark Archon（黑暗执政官）、Shadow Guard（暗影卫队）、Time Stop（时间停止）

**核心协同：** Dark Templar + Corsair 隐形突击；Stalker + Void Ray 正面；Dark Archon 控场。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 黑暗执政官 | Dark Archon | Protoss | 独特单位 | 50 | 350 | 0 | 30(+15对生物) | 1.5 | 3 | 空/地 | 精神控制（Mind Control）、黑洞（Black Hole 减速聚怪）、混乱（Confusion） | Vorazun独有；消耗2暗圣堂合成 |
| 暗影卫队 | Shadow Guard | Protoss | 召唤单位（DT） | 120 | 80 | 1 | 55(+25对轻甲) | 1.5 | 近战 | 地面 | 永久隐形、闪烁 | 顶级栏技能召唤，存活时间限制 |
| 黑暗圣堂武士 | Dark Templar | Protoss | 标准变异 | 80 | 80 | 1 | 55(+25对轻甲) | 1.5 | 近战 | 地面 | 永久隐形 | 可升级获得闪烁（Blink） |
| 追猎者 | Stalker | Protoss | 标准变异 | 100 | 80 | 1 | 20(+10对重甲) | 1.5 | 6 | 空/地 | 闪烁（Blink） | Vorazun的追猎者可在隐形状态下攻击 |
| 海盗船 | Corsair | Protoss | 独特单位 | 100 | 75 | 1 | 10×2 | 1.3 | 5 | 空中 | 破坏网（Disruption Web）：让地面单位无法攻击 | 星际1经典单位回归 |
| 虚空辉光舰 | Void Ray | Protoss | 标准变异 | 150 | 100 | 1 | 22(+14对重甲) | 0.5 | 8 | 空/地 | 充能光束 | 同标准版 |
| 先知 | Oracle | Protoss | 标准变异 | 60 | 100 | 0 | — | — | — | — | 侦测、陷阱 | 同标准版 |
| 净化者 | Purifier (Adept) | Protoss | 变异单位 | 100 | 50 | 1 | 20(+10对轻甲) | 1.8 | 5 | 地面 | 灵能转移（Psionic Transfer） | Vorazun的使徒可升级获得技能 |

---

### 7. Karax — 凯拉克斯（Protoss）

**设计哲学：** 塔防大师 + 轨道净化光束 + 机械部队。

**签名单位：** Sentinel（哨兵-变异）、Energizer（充能器）、Mirages（幻影战机）

**核心协同：** 防御建筑封锁要道 + Immortal + Colossus + Energizer 推进；Spear of Adun 技能清场。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 充能器 | Energizer | Protoss | 独特单位 | 100 | 100 | 1 | — | — | — | — | 充能光环（附近友军攻速+25%）、修复光环（修复机械）、可部署为静止炮台 | Karax独有辅助单位 |
| 幻影战机 | Mirages | Protoss | 变异单位（Phoenix） | 150 | 100 | 1 | 18(+12对轻甲) | 1.1 | 6 | 空中 | 重力牵引可作用于重型单位 | 凤凰变体 |
| 哨兵 | Sentinel | Protoss | 变异单位（Zealot） | 200 | 100 | 2 | 18(+8对重甲) | 1.2 | 近战 | 地面 | 护盾充能（Sentry的力场），冲锋 | 狂战士变体，可施放守护之壳 |
| 不朽者 | Immortal | Protoss | 标准变异 | 300 | 150 | 2 | 35(+25对重甲) | 1.7 | 6 | 地面 | 屏障 | 升级后获得AOE溅射 |
| 巨像 | Colossus | Protoss | 标准变异 | 250 | 150 | 2 | 30×2 | 2.0 | 7 | 地面 | 热射线 | Karax的巨像射程更远 |
| 航母 | Carrier | Protoss | 标准变异 | 250 | 200 | 2 | 8×8拦截机 | — | 14 | 空/地 | 释放拦截机 | 拦截机自动修复 |
| 净化光束 | Purifier Beam | Protoss | 顶级栏技能 | — | — | — | 200/秒 | — | 全图 | 地面 | 持续光束对一条直线造成毁灭性伤害 | Spear of Adun技能 |
| 太阳能轰击 | Solar Lance | Protoss | 顶级栏技能 | — | — | — | 100/秒 | — | 全图 | 地面 | 沿路径轰击 | Spear of Adun技能 |

---

### 8. Abathur — 阿巴瑟（Zerg）

**设计哲学：** 生物进化 + 终极进化，积累生物质进化出终极单位。

**签名单位：** Brutalisk（暴虐兽）、Leviathan（利维坦）、Ultimate Evolution（终极进化）

**核心协同：** 前期靠蟑螂/刺蛇积累生物质，进化出 Brutalisk/Leviathan 后碾压。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 暴虐兽 | Brutalisk | Zerg | 独特单位（终极进化） | 1000 | — | 5 | 60(+30对重甲) | 1.5 | 6 | 空/地 | 碾压小型单位、AOE践踏、酸液喷吐 | 由100生物质进化（从Ultralisk或Guardian变异） |
| 利维坦 | Leviathan | Zerg | 独特单位（终极进化） | 1000 | — | 5 | 40×3 | 1.0 | 8 | 空/地 | 多重攻击、吞噬空中单位 | 由100生物质进化（从Mutalisk或Devourer变异） |
| 毒液巢 | Toxic Nest | Zerg | 独特建筑 | 100 | — | 0 | 40（自爆） | — | 近战 | 地面 | 潜伏、自爆AOE、减速敌人 | Abathur独有；免费放置 |
| 蟑螂 | Roach | Zerg | 标准变异 | 145 | — | 2 | 20(+10对重甲) | 1.5 | 5 | 地面 | 快速恢复 | 可进化 |
| 刺蛇 | Hydralisk | Zerg | 标准变异 | 100 | — | 1 | 18(+6对轻甲) | 0.83 | 6 | 空/地 | — | 可进化 |
| 守护者 | Guardian | Zerg | 独特单位 | 200 | — | 2 | 35(+20对重甲) | 2.0 | 8 | 地面 | 远程攻城 | 由Mutalisk变异 |
| 吞噬者 | Devourer | Zerg | 独特单位 | 200 | — | 2 | 25(+15对重甲) | 1.2 | 6 | 空中 | 降低目标护甲 | 由Mutalisk变异 |
| 异龙 | Mutalisk | Zerg | 标准变异 | 140 | — | 1 | 12×3（弹射） | 1.5 | 4 | 空/地 | 弹射攻击 | 可进化为Guardian或Devourer |
| 雷兽 | Ultralisk | Zerg | 标准变异 | 600 | — | 5 | 35(+20对重甲) | 1.3 | 近战 | 地面 | 溅射 | 可进化为Brutalisk |

---

### 9. Alarak — 阿拉拉克（Protoss）

**设计哲学：** 牺牲弱者强化强者 + 高伤害玻璃大炮。

**签名单位：** Alarak（英雄）、Havoc（浩劫者）、Ascendant（飞升者）、Wrathwalker（ wrathwalker）

**核心协同：** Ascendant 灵能风暴 + Alarak 冲锋 + Wrathwalker 远程火力。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 阿拉拉克（英雄） | Alarak (Hero) | Protoss | 英雄单位 | 400 | 300 | 2 | 70(+30对重甲) | 1.3 | 近战 | 空/地 | 冲锋（Deadly Charge AOE）、闪电波（Lightning Surge）、毁灭光束（Destruction Wave）、牺牲（Sacrifice：吞噬友军获得临时增伤） | 死亡后在基地重生；可通过精通增加伤害 |
| 浩劫者 | Havoc | Protoss | 独特单位 | 100 | 100 | 1 | — | — | — | — | 结构分析（使范围内敌人护甲-3）、侦测隐形 | Alarak独有辅助单位 |
| 飞升者 | Ascendant | Protoss | 独特单位 | 100 | 100 | 0 | 60(+20对生物) | 2.0 | 9 | 空/地 | 灵能弹（Psi Orb 高伤AOE）、心灵粉碎（Mind Blast 单体高伤）、消耗能量球 | 由高阶圣堂武士合成；使用需要能量管理 |
|  wrathwalker | Wrathwalker | Protoss | 独特单位 | 300 | 200 | 3 | 55(+25对重甲) | 2.5 | 10 | 地面 | 攻城模式（更长射程更高伤害） | Alarak独有重型攻城单位 |
| 追猎者 | Stalker | Protoss | 标准变异 | 100 | 80 | 1 | 20(+10对重甲) | 1.5 | 6 | 空/地 | 闪烁 | 可升级为Slayer |
| 杀戮者 | Slayer | Protoss | 变异单位（Stalker） | 150 | 100 | 2 | 30(+15对重甲) | 1.3 | 6 | 空/地 | 闪烁、双重攻击 | 追猎者升级版 |
| 先锋 | Vanguard | Protoss | 变异单位（Immortal） | 300 | 200 | 3 | 60(+30对重甲) | 2.0 | 6 | 地面 | 范围溅射 | 不朽者升级版 |
| 毁灭者 | Destroyer | Protoss | 变异单位（Void Ray） | 200 | 150 | 2 | 30(+20对重甲) | 0.5 | 8 | 空/地 | 充能光束 | 虚空辉光舰升级版 |

---

### 10. Nova — 诺娃（Terran）

**设计哲学：** 特工 + 精英特种部队，高成本高质量的单位组成小型精锐军队。

**签名单位：** Nova（英雄）、所有单位均为独特版"特种部队"

**核心协同：** 少量精英单位精确打击 + Nova 本人清场。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 诺娃（英雄） | Nova (Hero) | Terran | 英雄单位 | 250 | 100 | 2 | 40(+20对重甲) | 1.0 | 7 | 空/地 | 隐形、狙击（Snipe 250伤害）、全息诱饵（Holo Decoy）、EMP、核弹（召唤战术核打击） | 死亡后在基地重生；配备C-20狙击步枪 |
| 特种陆战队 | Marine (Specialist) | Terran | 独特单位 | 100 | — | 1 | 10(+5对轻甲) | 0.8 | 5 | 空/地 | 兴奋剂、可对空 | 比标准陆战队更强 |
| 特种劫掠者 | Marauder (Specialist) | Terran | 独特单位 | 200 | — | 2 | 25(+15对重甲) | 1.3 | 6 | 地面 | 兴奋剂、震荡弹 | 比标准劫掠者更强 |
| 特种幽灵 | Ghost (Specialist) | Terran | 独特单位 | 125 | — | 1 | 25(+15对生物) | 1.5 | 8 | 空/地 | 隐形、狙击、核弹 | 可升级 |
| 特种医疗运输机 | Medivac (Specialist) | Terran | 独特单位 | 200 | — | 2 | — | — | — | — | 治疗加速、运输 | 比标准医疗运输机更强 |
| 特种攻城坦克 | Siege Tank (Specialist) | Terran | 独特单位 | 300 | — | 3 | 55(+25对重甲) | 2.5 | 14（攻城） | 地面 | 攻城模式、AOE更大 | 比标准坦克更强 |
| 特种歌莉娅 | Goliath (Specialist) | Terran | 独特单位 | 250 | — | 3 | 28(+10对重甲)地/20(+8对重甲)空 | 1.2 | 6（地）/9（空） | 空/地 | 双管对空导弹 | 歌莉娅回归+强化 |
| 特种女妖 | Banshee (Specialist) | Terran | 独特单位 | 220 | — | 2 | 30×2 | 1.0 | 8（隐形+2） | 空/地 | 永久隐形 | 比标准女妖更强 |
| 特种解放者 | Liberator (Specialist) | Terran | 独特单位 | 200 | — | 2 | 40(+20对重甲) | 1.5 | 7（防守模式） | 空/地 | 防守模式（对地压制） | 比标准解放者更强 |
| 特种战列巡航舰 | Battlecruiser (Specialist) | Terran | 独特单位 | 1000 | — | 4 | 25×8 | 0.2 | 10 | 空/地 | 等离子鱼雷、战术跃迁 | 比标准大和更强 |

---

### 11. Stukov — 斯托科夫（Zerg）

**设计哲学：** 感染泰伦 + 无穷无尽的感染步兵海，自动生成军队。

**签名单位：** Infested Civilian（感染平民）、Infested Marine（感染陆战队）、Infested Siege Tank（感染攻城坦克）、Brood Queen（巢虫女王）、Aleksander（亚历山大号）、Apocalisk（天启兽）

**核心协同：** 自动产兵推进 + 感染建筑持续出兵 + Aleksander 破阵。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 感染平民 | Infested Civilian | Zerg | 独特单位 | 50 | — | 0 | 12 | 1.5 | 近战 | 地面 | 自动从感染建筑产生、廉价炮灰 | 免费单位；从被感染的指挥中心自动生成 |
| 感染陆战队 | Infested Marine | Zerg | 独特单位 | 75 | — | 1 | 16(+8对轻甲) | 0.9 | 5 | 空/地 | 自动回复、可从兵营训练 | Stukov的主要远程步兵 |
| 感染攻城坦克 | Infested Siege Tank | Zerg | 变异单位 | 250 | — | 3 | 50(+20对重甲) | 2.5 | 13（攻城） | 地面 | 攻城模式、感染攻击附带减速 | Siege Tank 感染版 |
| 巢虫女王 | Brood Queen | Zerg | 变异单位 | 250 | — | 2 | — | — | 9 | 空/地 | 治疗（Heal）、产卵（Spawn Broodling 秒杀小型单位）、诱捕（Ensnare 减速） | Queen 强化版 |
| 亚历山大号 | Aleksander | Terran (Zerg) | 召唤单位（Battlecruiser） | 5000 | — | 5 | 30×8 | 0.2 | 10 | 空/地 | 等离子鱼雷、可以碾压地面单位、召唤感染陆战队登船 | 顶级栏技能召唤，存活时间限制 |
| 天启兽 | Apocalisk | Zerg | 召唤单位 | 3000 | — | 5 | 80(+40对重甲) | 1.2 | 近战 | 空/地 | 践踏AOE、吞噬、召唤小虫 | 顶级栏技能召唤，存活时间限制 |
| 感染建筑 | Infested Structure | Terran | 独特建筑 | 1000 | — | 2 | — | — | — | — | 自动生产感染平民、可攻击 | 被感染的指挥中心/兵营等 |

---

### 12. Fenix — 菲尼克斯（Protoss）

**设计哲学：** 可复活AI冠军 + 双模式英雄切换。

**签名单位：** Fenix（英雄切换六种机甲）、Champion Units（6种冠军单位）、Arbiter（仲裁者）、Conservator（守恒者）

**核心协同：** 冠军单位带领同类部队 + Fenix 切换形态填补短板。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 菲尼克斯（英雄） | Fenix (Hero) | Protoss | 英雄单位 | 可变 | 可变 | 可变 | 可变 | — | 可变 | 可变 | 可在六种机甲间切换：狂战士/追猎者/不朽者/巨像/航空母舰/斥候 | 每种机甲有独立HP和武器；死亡后自动切换下一机甲 |
| 仲裁者 | Arbiter | Protoss | 独特单位 | 100 | 200 | 2 | — | — | — | — | 群体隐形（Cloak Field）、传送（Recall）、侦测 | 星际1经典单位回归 |
| 守恒者 | Conservator | Protoss | 独特单位 | 100 | 200 | 1 | — | — | — | — | 防护力场（减少范围内友军受到的伤害50%）、修复 | Fenix独有辅助单位 |
| 冠军狂战士 | Champion Zealot | Protoss | 冠军单位 | 250 | 100 | 3 | 30(+15对重甲) | 1.0 | 近战 | 地面 | 冲锋、AOE挥砍 | 可自动重生；带领附近Zealot |
| 冠军追猎者 | Champion Stalker | Protoss | 冠军单位 | 200 | 150 | 2 | 30(+15对重甲) | 1.2 | 7 | 空/地 | 闪烁、双发齐射 | 可自动重生 |
| 冠军不朽者 | Champion Immortal | Protoss | 冠军单位 | 300 | 200 | 4 | 50(+30对重甲) | 1.5 | 7 | 地面 | 双倍屏障、AOE溅射 | 可自动重生 |
| 冠军巨像 | Champion Colossus | Protoss | 冠军单位 | 350 | 200 | 3 | 40×2 | 1.8 | 8 | 地面 | 热射线（三光束） | 可自动重生 |
| 冠军航母 | Champion Carrier | Protoss | 冠军单位 | 350 | 250 | 3 | 10×12拦截机 | — | 14 | 空/地 | 释放拦截机（12架） | 可自动重生 |
| 冠军斥候 | Champion Scout | Protoss | 冠军单位 | 200 | 150 | 2 | 28(+14对轻甲) | 1.0 | 6 | 空/地 | 对空导弹 | 可自动重生 |
| 斥候 | Scout | Protoss | 独特单位 | 150 | 100 | 1 | 22(+12对轻甲) | 1.2 | 5 | 空/地 | 对空导弹 | 星际1经典单位回归 |

---

### 13. Dehaka — 德哈卡（Zerg）

**设计哲学：** 原始虫群 + 吞噬进化 + 英雄冲锋。

**签名单位：** Dehaka（英雄）、Primal Zerg（原始虫族变体）、Primal Wurm（原始巨虫）、Pack Leaders（首领单位）

**核心协同：** Dehaka 吞噬获得进化点数 + Primal 部队推进。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 德哈卡（英雄） | Dehaka (Hero) | Zerg | 英雄单位 | 1000 | — | 3 | 60(+30对重甲) | 1.2 | 近战 | 空/地 | 吞噬（Devour：吞食敌方单位/尸体获得进化点数）、火焰吐息（Fire Breath AOE）、音波冲击（Sonic Burst 远程）、感知（Detection）、原始恢复 | 死亡后在巢穴重生；进化点数可升级自身能力 |
| 原始异化虫 | Primal Zergling | Zerg | 变异单位 | 50 | — | 0 | 12(+6对重甲) | 0.6 | 近战 | 地面 | 可进化 | 比标准Zergling更强 |
| 原始蟑螂 | Primal Roach | Zerg | 变异单位 | 200 | — | 2 | 25(+12对重甲) | 1.3 | 5 | 地面 | 快速恢复、可进化 | 比标准Roach更强 |
| 原始刺蛇 | Primal Hydralisk | Zerg | 变异单位 | 150 | — | 1 | 22(+8对轻甲) | 0.8 | 6 | 空/地 | 可进化 | 比标准Hydralisk更强 |
| 原始异龙 | Primal Mutalisk | Zerg | 变异单位 | 200 | — | 1 | 15×3（弹射） | 1.3 | 4 | 空/地 | 弹射攻击、可进化 | 比标准Mutalisk更强 |
| 原始守护者 | Primal Guardian | Zerg | 变异单位 | 250 | — | 2 | 40(+20对重甲) | 1.8 | 9 | 地面 | 远程攻城 | 由原始异龙变异 |
| 原始吞噬者 | Primal Devourer | Zerg | 变异单位 | 250 | — | 2 | 28(+15对重甲) | 1.0 | 6 | 空中 | 降低目标护甲 | 由原始异龙变异 |
| 原始巨虫 | Primal Wurm | Zerg | 独特建筑 | 1000 | — | 3 | 60(+30对重甲) | 2.0 | 10 | 空/地 | 潜伏、AOE攻击、可移动位置 | Dehaka独有防御/攻击建筑 |
| 族群首领 | Pack Leader | Zerg | 独特单位 | 可变 | — | 可变 | 可变 | — | 可变 | 可变 | 每个首领有独特能力（Dakrun, Murvar, Glevig等） | 通过进化点召唤，各有专长 |

---

### 14. Han & Horner — 霍纳与汉（Terran）

**设计哲学：** 星际海盗 + 空天一体化 + 经济投机。

**签名单位：** Assault Galleon（突击运输舰）、Reaper（死神-变异版）、Widow Mine（寡妇雷-变异版）、Wraith（幽灵战机-变异版）、Horner's Battlecruiser（霍纳的大和）

**核心协同：** Reaper + Widow Mine 骚扰；Assault Galleon 空投；Horner 舰队提供空中火力。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 突击运输舰 | Assault Galleon | Terran | 独特单位 | 500 | — | 3 | 20(+10对轻甲)×2 | 1.5 | 6 | 空/地 | 可搭载地面单位并在移动中释放、自动修理、升级后增加武器 | H&H核心运载单位 |
| 死神（海盗版） | Reaper (Pirate) | Terran | 变异单位 | 100 | — | 1 | 15(+10对轻甲) | 1.2 | 5 | 地面 | D-8炸药（高伤AOE）、可跳跃悬崖、可升级为三连手雷 | 比标准死神更强；可从Galleon中快速部署 |
| 寡妇雷（海盗版） | Widow Mine (Pirate) | Terran | 变异单位 | 100 | — | 1 | 200对单/50AOE | — | 近战 | 空/地 | 潜伏、自爆、可重新部署 | 比标准寡妇雷伤害更高 |
| 幽灵战机（海盗版） | Wraith (Pirate) | Terran | 独特单位 | 200 | — | 2 | 24(+12对轻甲) | 1.0 | 6 | 空/地 | 永久隐形 | 星际1经典单位回归 |
| 霍纳的战列巡航舰 | Horner's Battlecruiser | Terran | 独特单位 | 800 | — | 4 | 25×8 | 0.2 | 10 | 空/地 | 等离子鱼雷、战术跃迁、天雷（召唤导弹群） | 比标准大和更强 |
| 地狱火地狱蝙蝠 | Hellion/Hellbat | Terran | 标准变异 | 100/200 | — | 1/2 | 18(+12对轻甲) | 2.0 | 5 | 地面 | 可变形 | 同标准版 |
| 天雷 | Mag-Mine | Terran | 顶级栏技能 | — | — | — | 100AOE | — | 全图 | 空/地 | 在目标区域布设大量高伤地雷 | 顶级栏技能 |

---

### 15. Tychus — 泰凯斯（Terran）

**设计哲学：** 精英英雄小队，没有普通单位，只有5名精英Outlaw（亡命徒）。

**签名单位：** Tychus（英雄）、8名可选Outlaws

**核心协同：** Tychus + 4名Outlaws，每名都有独特的武器和升级树。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 泰凯斯（英雄） | Tyrus (Hero) | Terran | 英雄单位 | 500 | — | 3 | 50(+25对重甲) | 1.0 | 6 | 空/地 | 奥丁呼叫（呼叫奥丁机甲）、手雷、兴奋剂 | 初始英雄；死亡后可在医疗艇重生 |
| 山姆 | Sam | Terran | Outlaw | 350 | — | 2 | 40(+20对重甲) | 1.2 | 近战 | 地面 | 隐形、背刺（高伤）、破片手雷 | 近战刺客型 |
| 纳克斯 | Nux | Terran | Outlaw | 300 | — | 1 | 25(+15对生物) | 1.5 | 8 | 空/地 | 灵能风暴、精神控制、反馈 | 灵能型 |
| 维嘉 | Vega | Terran | Outlaw | 300 | — | 1 | 20(+10对轻甲) | 1.3 | 7 | 空/地 | 精神控制（永久控制敌方单位） | 控制型 |
| 天狼星 | Sirius | Terran | Outlaw | 400 | — | 3 | 40(+20对重甲) | 1.5 | 7 | 空/地 | 放置炮台（攻击/治疗两种模式） | 工程型 |
| 布洛克 | Blaze | Terran | Outlaw | 450 | — | 2 | 30(+15对轻甲) | 1.3 | 5 | 地面 | 火焰喷射器（AOE扇形）、燃烧弹 | 范围伤害型 |
| 拉图尔 | Rattlesnake | Terran | Outlaw | 400 | — | 2 | 35(+15对重甲) | 1.2 | 6 | 空/地 | 治疗光环、复活友军 | 医疗型 |
| 迈尔斯 | Miles | Terran | Outlaw | 600 | — | 4 | 20(+10对轻甲) | 1.0 | 近战 | 地面 | 嘲讽（强制敌人攻击自己）、伤害反射 | 坦克型 |
| 托什站长 | Captain Tosh | Terran | Outlaw | 350 | — | 2 | 30(+15对轻甲) | 1.4 | 7 | 空/地 | 隐形、狙击、核弹 | 特种型 |

---

### 16. Zeratul — 泽拉图（Protoss）

**设计哲学：** 神器收集 + 暗影科技 + 虚空召唤。

**签名单位：** Zeratul（英雄）、Void Templar（虚空圣堂武士）、Avenger（复仇者）、Enforcer（执法者）

**核心协同：** Zeratul 收集神器升级全队 + 暗影部队推进；神器等级决定部队强度。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 泽拉图（英雄） | Zeratul (Hero) | Protoss | 英雄单位 | 400 | 300 | 3 | 80(+40对轻甲) | 1.2 | 近战 | 空/地 | 永久隐形、闪烁、虚空裂隙（Void Rift AOE）、时间暂停 | 死亡后在基地重生；寻找神器碎片增强 |
| 虚空圣堂武士 | Void Templar | Protoss | 独特单位 | 100 | 100 | 1 | 60(+30对轻甲) | 1.5 | 近战 | 地面 | 永久隐形、闪烁、可合成虚空执政官 | Zeratul版黑暗圣堂 |
| 复仇者 | Avenger | Protoss | 独特单位（Stalker变体） | 150 | 150 | 2 | 30(+15对重甲) | 1.2 | 7 | 空/地 | 闪烁、护盾恢复 | Zeratul版追猎者 |
| 执法者 | Enforcer | Protoss | 独特单位（Immortal变体） | 350 | 250 | 4 | 50(+30对重甲) | 1.5 | 7 | 地面 | 溅射AOE、屏障 | Zeratul版不朽者 |
| 虚空使徒 | Void Adept | Protoss | 独特单位（Adept变体） | 120 | 80 | 1 | 25(+12对轻甲) | 1.5 | 5 | 地面 | 灵能转移、虚空护盾 | 使徒变体 |
| 虚空射线 | Void Ray | Protoss | 标准变异 | 150 | 100 | 1 | 22(+14对重甲) | 0.5 | 8 | 空/地 | 充能光束 | 随神器等级增强 |
| 虚空召唤 | Void Summoning | Protoss | 顶级栏召唤 | — | — | — | — | — | — | — | 召唤虚空部队（虚空领主/虚空使者等） | 根据神器等级召唤不同部队 |
| 暗影之怒 | Shadow Rage | Protoss | 顶级栏技能 | — | — | — | 250 | — | 全图 | 空/地 | 虚空能量爆发，对全图敌人造成伤害 | 根据神器等级增加伤害 |

---

### 17. Stetmann — 斯台特曼（Zerg）

**设计哲学：** 高科技机械虫族 + 绿色能量场。

**签名单位：** Stetmann（英雄）、Gary（盖瑞）、Mecha Zerg（机械虫族变体）、Stetellite（绿色能量卫星）、Mecha Infestor（机械感染者）

**核心协同：** Stetellite 提供能量场 + 机械虫族推进；Gary 全能支援。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 斯台特曼/盖瑞 | Stetmann/Gary | Zerg/Terran | 英雄单位 | 400 | — | 3 | 40(+20对重甲) | 1.0 | 7 | 空/地 | 绿色能量场（Stetellite Fields：加速/治疗/能量恢复）、激光、电磁脉冲、传送 | Gary 是 Stetmann 的 AI 伙伴，可独立作战 |
| 机械异化虫 | Mecha Zergling | Zerg | 独特单位 | 60 | — | 1 | 15(+8对重甲) | 0.6 | 近战 | 地面 | 可在绿色能量场中快速恢复、自爆（升级） | 机械版Zergling |
| 机械刺蛇 | Mecha Hydralisk | Zerg | 独特单位 | 150 | — | 2 | 25(+10对轻甲) | 0.8 | 7 | 空/地 | 可在绿色能量场中获得攻速加成 | 机械版Hydralisk |
| 机械蟑螂 | Mecha Roach | Zerg | 独特单位 | 250 | — | 3 | 25(+12对重甲) | 1.3 | 5 | 地面 | 可在绿色能量场中快速修复 | 机械版Roach |
| 机械异龙 | Mecha Mutalisk | Zerg | 独特单位 | 180 | — | 2 | 15×3（弹射） | 1.3 | 4 | 空/地 | 弹射攻击 | 机械版Mutalisk |
| 机械感染者 | Mecha Infestor | Zerg | 独特单位 | 200 | — | 1 | — | — | — | — | 机械真菌增生（Mecha Fungal）、机械神经控制（Mecha Neural）、可产生绿色能量 | 机械版Infestor |
| 机械腐化者 | Mecha Corruptor | Zerg | 独特单位 | 250 | — | 3 | 22(+10对重甲) | 1.3 | 7 | 空中 | — | 机械版Corruptor |
| 机械巢虫领主 | Mecha Brood Lord | Zerg | 独特单位 | 400 | — | 4 | 30（巢虫） | 1.8 | 12 | 地面 | 孵化机械巢虫 | 机械版Brood Lord |
| 绿色能量卫星 | Stetellite | Terran | 独特单位 | 100 | — | 0 | — | — | — | — | 产生绿色能量场（Green Energy Field）：范围内友军加速/治疗/回能量 | Stetmann独有机制核心 |

---

### 18. Mengsk — 蒙斯克（Terran）

**设计哲学：** 帝国独裁 + 劳工压迫 + 皇权审判。

**签名单位：** Trooper（帝国兵——替代SCV和Marine）、Aegis Guard（宙斯盾守卫）、Blackhammer（黑锤）、Shock Division（震击部队）、Imperial Justice（皇权审判）

**核心协同：** Trooper 既是工人又是士兵；Aegis Guard + Shock Division 地面推进；皇权技能清场。

#### 单位数据表（独特/变异单位）

| name_zh | name_en | race | type | hp | shield | armor | damage | cooldown | range | target | special_abilities | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 帝国兵 | Trooper | Terran | 独特单位（替代SCV+Marine） | 75 | — | 0 | 10(+5对轻甲) | 0.9 | 5 | 空/地 | 可切换为工人模式（采集资源建造）和战斗模式；可升级为精英；可使用兴奋剂 | Mengsk独有；同时替代SCV和Marine |
| 宙斯盾守卫 | Aegis Guard | Terran | 变异单位（Marauder） | 250 | — | 3 | 30(+15对重甲) | 1.2 | 6 | 地面 | 兴奋剂、震荡弹、防护力场（减少受到的伤害） | 帝国版劫掠者；比标准版强 |
| 黑锤 | Blackhammer | Terran | 变异单位（Thor） | 600 | — | 4 | 60(+30对重甲) | 1.3 | 7（地）/10（空） | 空/地 | 对空火箭弹幕、可对空对地 | 帝国版雷神；可通过皇权强化 |
| 震击部队 | Shock Division | Terran | 变异单位（Siege Tank） | 300 | — | 3 | 60(+30对重甲) | 2.5 | 14（攻城） | 地面 | 攻城模式、皇权强化：额外伤害和射程 | 帝国版攻城坦克 |
| 帝国仲裁者 | Imperial Arbiter | Terran | 独特单位 | 200 | — | 2 | — | — | — | — | 群体隐形、传送、皇权扩散 | 机械单位；星际1仲裁者概念 |
| 火焰兵（帝国） | Flame Trooper | Terran | 变异单位（Firebat） | 200 | — | 3 | 20(+10对轻甲) | 1.3 | 3 | 地面 | 火焰喷射AOE | 帝国版火焰兵 |
| 皇权守卫 | Royal Guard | Terran | 独特单位 | — | — | — | — | — | — | — | 精英Trooper升级而成，有独立名称和强化属性 | Trooper升级路线 |
| 核弹（皇权） | Nuclear Strike (Imperial) | Terran | 顶级栏技能 | — | — | — | 500 | — | 全图 | 空/地 | 大范围核弹 | 皇权技能；无需幽灵引导 |
| 皇权审判 | Imperial Mandate | Terran | 顶级栏资源 | — | — | — | — | — | — | — | 使用劳工技能产生皇权点数，用于释放顶级栏技能 | Mengsk独有资源系统 |

---

## 第三部分：总结

### 独特单位数量分布

| 指挥官 | 独特单位数 | 英雄单位 | 备注 |
|---|---|---|---|
| Raynor | 4 | — | Firebat, Vulture, Dusk Wings, Hyperion |
| Kerrigan | 1 | Kerrigan | Omega Worm 变异 |
| Artanis | 2 | — | Dragoon, High Archon |
| Swann | 4 | — | HERC, Science Vessel, Goliath, 变异Thor |
| Zagara | 4 | — | Scourge, Aberration, Bile Launcher, 变异Baneling |
| Vorazun | 3 | — | Dark Archon, Corsair, Shadow Guard |
| Karax | 3 | — | Energizer, Sentinel, Mirages |
| Abathur | 4 | — | Brutalisk, Leviathan, Toxic Nest, Guardian/Devourer |
| Alarak | 4 | Alarak | Havoc, Ascendant, Wrathwalker, Slayer/Vanguard/Destroyer |
| Nova | 1（全兵种变异） | Nova | 所有兵种为特种部队版 |
| Stukov | 6 | — | Inf.Civilian, Inf.Marine, Inf.Siege Tank, Brood Queen, Aleksander, Apocalisk |
| Fenix | 4 | Fenix(6形态) | Arbiter, Conservator, Scout, 6冠军单位 |
| Dehaka | 3 | Dehaka | Primal全兵种, Primal Wurm, Pack Leaders |
| H&H | 4 | — | Assault Galleon, Wraith, 变异Reaper, 变异Widow Mine |
| Tychus | 9（全部独有） | Tychus | 8名Outlaw，无普通单位 |
| Zeratul | 5 | Zeratul | Void Templar, Avenger, Enforcer, Void Adept, 神器召唤 |
| Stetmann | 8 | Stetmann/Gary | 全机械虫族兵种 + Stetellite |
| Mengsk | 6 | — | Trooper, Aegis Guard, Blackhammer, Shock Division, Flame Trooper, Imperial Arbiter |

### 设计规律总结

1. **英雄型指挥官**：Kerrigan, Alarak, Dehaka, Tychus, Zeratul, Stetmann, Nova, Fenix — 依赖强力英雄单位
2. **爆兵型指挥官**：Raynor, Zagara, Stukov, Mengsk — 数量优势
3. **精英型指挥官**：Nova, Tychus, Alarak — 少量高质量部队
4. **防御型指挥官**：Karax, Swann — 擅长阵地战
5. **进化型指挥官**：Abathur, Dehaka — 积累资源进化
6. **特种机制型指挥官**：Vorazun（隐形）, Zeratul（神器）, Stetmann（能量场）, H&H（空投海盗）, Fenix（冠军重生）

---

> 参考来源：
> - Liquipedia SC2 Co-op: https://liquipedia.net/starcraft2/Co-op_Missions
> - StarCraft Fandom Wiki: https://starcraft.fandom.com/wiki/Co-op_Missions
> - starcraft2coop.com: https://starcraft2coop.com
