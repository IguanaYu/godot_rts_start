# 魔兽争霸2 单位数据参考

> **游戏**: Warcraft II: Tides of Darkness (1995) + Beyond the Dark Portal (1996)
> **开发商**: Blizzard Entertainment
> **资源体系**: Gold + Lumber（木材）+ Oil（石油，仅海军）
> **版本**: Battle.net Edition / 原版 DOS
> **数据来源**: 游戏内数据、社区参考

---

## 第一部分：种族设计分析

---

### Human（人类）

#### 1. 设计哲学
**均衡防御型** — 兵种线性升级链完善，防御建筑强悍（Cannon Tower / Guard Tower），依赖科技攀爬逐步解锁高级兵种。

#### 2. 核心签名机制
- **升级链体系**: Footman → (无升级)、Archer → Elven Ranger、Knight → Paladin、Conjurer → Mage
- **牧师/法师支援**: 唯一拥有群体治疗（Paladin Holy Light / Heal）+ 变形术（Polymorph）+ 隐形术（Invisibility）的种族
- **Cannon Tower**: 人族防御塔升级后射程远、伤害高，是防守反击的核心

#### 3. 角色分工矩阵

| 阶层 | 角色 | 单位 |
|------|------|------|
| T1 | 工人 | Peasant |
| T1 | 基础近战 | Footman |
| T1 | 基础远程 | Archer |
| T1 | 基础空军 | Flying Machine |
| T2 | 重型近战 | Knight (→ Paladin) |
| T2 | 法术支援 | Conjurer (→ Mage) |
| T2 | 攻城 | Ballista |
| T2 | 运输 | Transport Ship |
| T3 | 精英空军 | Gryphon Rider |
| T3 | 终极海军 | Battleship |

#### 4. 科技树节奏

```
T1 (Town Hall) → Peasant
T1 (Barracks) → Footman
T1 (Barracks + Lumber Mill) → Archer
T1 (Lumber Mill) → Ballista
T1 (Factory) → Flying Machine
T2 (Barracks + Stables) → Knight
T2 (Barracks + Church + Mage Tower) → Conjurer
T2 (Church) → Paladin 升级
T2 (Mage Tower) → Mage 升级
T2 (Lumber Mill) → Elven Ranger 升级
T3 (Gryphon Aviary) → Gryphon Rider
T3 (Shipyard + Foundry) → Battleship
```

黑铁（Blacksmith）提供武器/护甲升级，每级 +1 伤害 / +1 护甲，最多 3 级。

#### 5. 核心协同组合
- **Footman + Archer 混合**: 传统人族万金油，Footman 抗线，Archer 输出
- **Knight 骚扰**: 高速骑兵切远程/工人
- **Paladin + Knight 推进**: Paladin 回血保障骑兵持续作战
- **Mage + Ballista 攻城**: Invisibility 掩护 Ballista，Polymorph 点杀英雄/重型
- **Gryphon Rider 制空**: 唯一对地空军，但惧怕 Flying Machine 和 Dragon

#### 6. 生产机制
- 所有单位从对应建筑训练，无全局队列
- Peasant 从 Town Hall 训练
- 最多 5 个 Peasant 可同时采集一个金矿
- 升级链单位通过研究升级转化（如 Knight → Paladin），升级后训练即出高级版

#### 7. 机动哲学
- **陆军**: Knight/Paladin 高速（12），适合游击；Footman/Archer 中速（8）适合阵地
- **空军**: Flying Machine 高速（16），Gryphon Rider 高速（16）
- **海军**: Destroyer 高速（12）适合巡逻；Battleship 低速（8）但火力猛
- **运输船**: 可搭载 8 个单位，速度慢（6），需要护航

#### 8. 视野与地图控制
- 初始视野 4，Archer 视野 6
- Flying Machine 视野 8，适合探路
- Conjurer/Mage 的 Invisibility 提供独特视野/偷袭能力
- 无免费侦察单位

#### 9. 反制弱点
- **怕 Grunt 海**: 前期 Footman（60HP/6dmg）对上 Grunt（80HP/8dmg）处于劣势
- **空军过渡期**: T2 只有 Flying Machine（对空专精），对地无力；出 Gryphon 需要 T3
- **脆皮法师**: Conjurer/Mage 只有 40-60HP，被 Troll Axethrower/Dragon 一发带走
- **海军弱势**: Destroyer 相比 Battleship 太脆，需要大量操作

#### 10. 强势时间窗
- **T1 中期 Archer 出山**: 远程压制 Troll/Footman 对拼
- **T2 Knight 成型**: 高速骑兵对抗 Orc 缺乏反骑手段的时期
- **T3 Paladin+Mage 完全体**: 回血 + 变形 + 隐形，人族最强势期

#### 11. 经济模型
- Peasant: 400g
- 单矿满采集 5 Peasant
- 伐木需要额外 Peasant
- 升级链花费大量 Gold（Blacksmith 3级武器/3级护甲各需 800/1600/2400g）
- 海军需要 Oil（海上油田），额外经济维度

---

### Orc（兽族）

#### 1. 设计哲学
**侵略压制型** — 前期 Grunt 肉搏更强，Troll 远程不弱于人，缺乏治疗但 Death Knight 提供独特亡灵法术，Dragon 制空霸道。

#### 2. 核心签名机制
- **亡灵法术**: Death Knight 的 Death Coil（伤敌/回血）+ Raise Dead（召唤骷髅）
- **Ogre-Mage 双修**: 近战大块头同时拥有法术能力（Eye of Kilrogg 侦察、Rune of Shielding 加防）
- **Goblin Zeppelin**: 独特的空中运输，跨地形投放部队
- **Dragon 制空**: 对空对地全能，但造价高昂

#### 3. 角色分工矩阵

| 阶层 | 角色 | 单位 |
|------|------|------|
| T1 | 工人 | Peon |
| T1 | 基础近战 | Grunt |
| T1 | 基础远程 | Troll Axethrower |
| T1 | 空军运输 | Goblin Zeppelin |
| T2 | 重型近战 | Ogre (→ Ogre-Mage) |
| T2 | 亡灵法师 | Death Knight |
| T2 | 攻城 | Catapult |
| T2 | 运输 | Transport Ship |
| T3 | 精英空军 | Dragon |
| T3 | 终极海军 | Battleship |

#### 4. 科技树节奏

```
T1 (Town Hall) → Peon
T1 (Barracks) → Grunt
T1 (Barracks + Lumber Mill) → Troll Axethrower
T1 (Lumber Mill) → Catapult
T1 (Goblin Shipyard) → Goblin Zeppelin
T2 (Barracks + Ogre Mound) → Ogre
T2 (Barracks + Temple of the Damned + Altar of Storms) → Death Knight
T2 (Ogre Mound) → Ogre-Mage 升级
T2 (Lumber Mill) → Troll Berserker 升级
T3 (Dragon Roost) → Dragon
T3 (Shipyard + Foundry) → Battleship
```

Forge 提供武器/护甲升级，每级 +1 伤害 / +1 护甲，最多 3 级。Orc 升级价格与人族不同：
- 武器升级: 600/1200/1800g
- 护甲升级: 400/800/1200g
（比人族便宜）

#### 5. 核心协同组合
- **Grunt + Troll Axethrower 混合**: Orc 版万金油，Grunt 更肉、Troll 输出相同
- **Ogre + Death Knight 推进**: Ogre 抗线，Death Knight 在后面 Death Coil 治疗/ Raise Dead 炮灰
- **Catapult + Zeppelin 空投**: Zeppelin 运 Catapult 到悬崖/岛屿偷袭
- **Dragon 制空后 Troll 推进**: Dragon 清空军，Troll 地面推进
- **Death Knight Demon 一波**: Whirlwind 召唤 Demon（Beyond the Dark Portal），强拆基地

#### 6. 生产机制
- 与人族结构相同，从对应建筑训练
- Peon 从 Town Hall 训练
- Goblin Zeppelin 从 Goblin Shipyard 训练（代替人族的 Factory）

#### 7. 机动哲学
- **陆军**: Ogre 速度 12（与 Knight 同速），Grunt 速度 8
- **空军**: Dragon 速度 16，Zeppelin 速度 8（慢速运输）
- **Zeppelin 空投**: 独有机制，可跨越地形障碍，战术价值极高
- **海军**: 与人族完全相同（共用海军单位模板）

#### 8. 视野与地图控制
- Ogre-Mage 的 Eye of Kilrogg 提供免费飞行侦察（60 法力，召唤一个不可攻击的眼睛）
- Death Knight 的 Raise Dead 可用来侦察危险区域
- 其他与人族相同

#### 9. 反制弱点
- **无治疗**: 除 Death Coil 外无持续恢复手段，战损更难恢复
- **空军选择单一**: Dragon 造价高昂，T2 无对地空军
- **魔法弱势**: 缺乏 Polymorph 和 Invisibility 这类强力控制法术
- **反大规模 Knight**: Ogre 虽然同价但训练时间可能更长

#### 10. 强势时间窗
- **T1 前期 Grunt**: 80HP/8dmg 碾压 Footman 的 60HP/6dmg
- **T1 Troll Axethrower 出山**: 远程对射不输 Archer
- **T2 Ogre 成型**: 120HP/10dmg，人族出 Knight 前非常强势
- **T3 Dragon 制空**: 唯一能同时制空和对地的空军，非常灵活

#### 11. 经济模型
- Peon: 400g
- 单矿满采集 5 Peon
- 武器/护甲升级比人族便宜（优势经济）
- 无 Oil 经济差异，海军与人族共享

---

## 第二部分：单位数据表

### 数据说明

- **伤害类型**: Normal（普通近战）/ Piercing（穿刺远程）/ Siege（攻城）/ Spell（法术）
- **护甲类型**: Light（轻甲，0 基础）/ Medium（中甲，2 基础）/ Heavy（重甲，4 基础）/ Fortified（城甲，仅建筑）
- **目标**: G=Ground（地面）/ A=Air（空中）/ B=Both（两者）
- **speed**: WC2 内部速度值，数值越大越快
- **vision**: 视野范围（格数）
- **supply**: 占用的食物数（WC2 中称为 Food）
- 升级链单位的属性变化以 `基础→升级后` 标注

---

### Human 单位

#### 1. Peasant（农民）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 农民 |
| | name_en | Peasant |
| | race | Human |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Town Hall |
| | prereq_tech | — |
| | cost_gold | 400 |
| | cost_lumber | 0 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 40 |
| | armor_type | Light |
| | armor | 0 |
| | tags | worker |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 3 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | 采集金矿、采集木材、修理建筑/机械、建造建筑 |
| | passive[] | — |

#### 2. Footman（步兵）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 步兵 |
| | name_en | Footman |
| | race | Human |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Barracks |
| | prereq_tech | — |
| | cost_gold | 400 |
| | cost_lumber | 0 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 60 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | melee |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 6 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | 可升级 Blacksmith 武器/护甲 |

#### 3. Archer → Elven Ranger（弓箭手→精灵游侠）

**Archer（基础）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 弓箭手 |
| | name_en | Archer |
| | race | Human |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Barracks |
| | prereq_tech | Lumber Mill |
| | cost_gold | 500 |
| | cost_lumber | 0 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 40 |
| | armor_type | Light |
| | armor | 0 |
| | tags | ranged |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 6 |
| **攻击** | damage | 5 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 4 |
| | target | G, A |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | 可升级 Blacksmith 武器/护甲 |

**Elven Ranger（升级后）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 精灵游侠 |
| | name_en | Elven Ranger |
| | race | Human |
| | tier | T2 |
| | mode | 升级 |
| **生产** | upgrade_from | Archer |
| | prereq_tech | Lumber Mill 升级 |
| | cost_gold | 100 |
| | cost_lumber | 50 |
| | supply | 1 |
| | build_time | 60s (研究) |
| **生存** | hp | 50 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | ranged |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 6 |
| **攻击** | damage | 7 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 5 |
| | target | G, A |
| | splash | — |
| | bonus_vs | — |

#### 4. Knight → Paladin（骑士→圣骑士）

**Knight（基础）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 骑士 |
| | name_en | Knight |
| | race | Human |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Stables |
| | prereq_tech | Barracks |
| | cost_gold | 800 |
| | cost_lumber | 0 |
| | supply | 2 |
| | build_time | 30s |
| **生存** | hp | 120 |
| | armor_type | Heavy |
| | armor | 4 |
| | tags | melee, cavalry |
| **机动** | speed | 12 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 10 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | 可升级 Blacksmith 武器/护甲 |

**Paladin（升级后）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 圣骑士 |
| | name_en | Paladin |
| | race | Human |
| | tier | T3 |
| | mode | 升级 |
| **生产** | upgrade_from | Knight |
| | prereq_tech | Church |
| | cost_gold | 100 |
| | cost_lumber | 100 |
| | supply | 2 |
| | build_time | 60s (研究) |
| **生存** | hp | 140 |
| | armor_type | Heavy |
| | armor | 6 |
| | tags | melee, cavalry, healer |
| **机动** | speed | 12 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 12 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | Holy Light（治疗友军）、Heal（持续治疗）、Exorcism（伤害亡灵） |
| | passive[] | — |

#### 5. Conjurer → Mage（咒术师→大法师）

**Conjurer（基础）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 咒术师 |
| | name_en | Conjurer |
| | race | Human |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Church |
| | prereq_tech | Mage Tower |
| | cost_gold | 350 |
| | cost_lumber | 60 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 40 |
| | armor_type | Light |
| | armor | 0 |
| | tags | caster |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 5 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 3 |
| | target | G, A |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | Slow（减速敌方单位）、Invisibility（隐形友军） |
| | passive[] | 法力 200 |

**Mage（升级后）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 大法师 |
| | name_en | Mage |
| | race | Human |
| | tier | T3 |
| | mode | 升级 |
| **生产** | upgrade_from | Conjurer |
| | prereq_tech | Mage Tower 升级 |
| | cost_gold | 100 |
| | cost_lumber | 50 |
| | supply | 1 |
| | build_time | 60s (研究) |
| **生存** | hp | 60 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | caster |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 7 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 4 |
| | target | G, A |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | Slow、Invisibility、Polymorph（变形为羊）、Water Elemental（召唤水元素） |
| | passive[] | 法力 250 |

#### 6. Ballista（弩炮）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 弩炮 |
| | name_en | Ballista |
| | race | Human |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Lumber Mill |
| | prereq_tech | Blacksmith |
| | cost_gold | 750 |
| | cost_lumber | 150 |
| | supply | 2 |
| | build_time | 30s |
| **生存** | hp | 75 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | siege, mechanical |
| **机动** | speed | 6 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 5 |
| **攻击** | damage | 35 (Siege) |
| | atk_type | Siege |
| | cooldown | — |
| | range | 7 |
| | target | G, B (优先对地) |
| | splash | 小范围溅射 |
| | bonus_vs | 建筑 ×2 |
| **技能** | active[] | — |
| | passive[] | — |

#### 7. Flying Machine（飞行器）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 飞行器 |
| | name_en | Flying Machine |
| | race | Human |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Factory (Gnomish Inventor) |
| | prereq_tech | Lumber Mill |
| | cost_gold | 250 |
| | cost_lumber | 100 |
| | supply | 1 |
| | build_time | 25s |
| **生存** | hp | 60 |
| | armor_type | Light |
| | armor | 0 |
| | tags | air, mechanical |
| **机动** | speed | 16 |
| | fly | true |
| | naval | false |
| | transport_slots | — |
| | vision | 8 |
| **攻击** | damage | 7 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 2 |
| | target | A (仅对空) |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | — |

#### 8. Gryphon Rider（狮鹫骑士）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 狮鹫骑士 |
| | name_en | Gryphon Rider |
| | race | Human |
| | tier | T3 |
| | mode | 标准 |
| **生产** | built_from | Gryphon Aviary |
| | prereq_tech | Lumber Mill |
| | cost_gold | 350 |
| | cost_lumber | 100 |
| | supply | 2 |
| | build_time | 30s |
| **生存** | hp | 100 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | air |
| **机动** | speed | 16 |
| | fly | true |
| | naval | false |
| | transport_slots | — |
| | vision | 8 |
| **攻击** | damage | 14 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 2 |
| | target | G (仅对地) |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | — |

---

### Orc 单位

#### 1. Peon（苦工）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 苦工 |
| | name_en | Peon |
| | race | Orc |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Town Hall |
| | prereq_tech | — |
| | cost_gold | 400 |
| | cost_lumber | 0 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 40 |
| | armor_type | Light |
| | armor | 0 |
| | tags | worker |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 3 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | 采集金矿、采集木材、修理建筑/机械、建造建筑 |
| | passive[] | — |

#### 2. Grunt（步兵）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 步兵 |
| | name_en | Grunt |
| | race | Orc |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Barracks |
| | prereq_tech | — |
| | cost_gold | 600 |
| | cost_lumber | 0 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 80 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | melee |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 8 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | 可升级 Forge 武器/护甲 |

#### 3. Troll Axethrower → Troll Berserker（巨魔投斧手→巨魔狂战士）

**Troll Axethrower（基础）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 巨魔投斧手 |
| | name_en | Troll Axethrower |
| | race | Orc |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Barracks |
| | prereq_tech | Lumber Mill |
| | cost_gold | 500 |
| | cost_lumber | 0 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 40 |
| | armor_type | Light |
| | armor | 0 |
| | tags | ranged |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 6 |
| **攻击** | damage | 5 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 4 |
| | target | G, A |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | 可升级 Forge 武器/护甲 |

**Troll Berserker（升级后）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 巨魔狂战士 |
| | name_en | Troll Berserker |
| | race | Orc |
| | tier | T2 |
| | mode | 升级 |
| **生产** | upgrade_from | Troll Axethrower |
| | prereq_tech | Lumber Mill 升级 |
| | cost_gold | 100 |
| | cost_lumber | 50 |
| | supply | 1 |
| | build_time | 60s (研究) |
| **生存** | hp | 50 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | ranged |
| **机动** | speed | 8 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 6 |
| **攻击** | damage | 7 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 5 |
| | target | G, A |
| | splash | — |
| | bonus_vs | — |

#### 4. Ogre → Ogre-Mage（食人魔→食人魔法师）

**Ogre（基础）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 食人魔 |
| | name_en | Ogre |
| | race | Orc |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Ogre Mound |
| | prereq_tech | Barracks |
| | cost_gold | 800 |
| | cost_lumber | 0 |
| | supply | 2 |
| | build_time | 30s |
| **生存** | hp | 120 |
| | armor_type | Heavy |
| | armor | 4 |
| | tags | melee |
| **机动** | speed | 12 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 10 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | 可升级 Forge 武器/护甲 |

**Ogre-Mage（升级后）:**

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 食人魔法师 |
| | name_en | Ogre-Mage |
| | race | Orc |
| | tier | T3 |
| | mode | 升级 |
| **生产** | upgrade_from | Ogre |
| | prereq_tech | Ogre Mound 升级 |
| | cost_gold | 100 |
| | cost_lumber | 100 |
| | supply | 2 |
| | build_time | 60s (研究) |
| **生存** | hp | 140 |
| | armor_type | Heavy |
| | armor | 6 |
| | tags | melee, caster |
| **机动** | speed | 12 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 12 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 1 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | Eye of Kilrogg（召唤飞行侦察眼）、Rune of Shielding（增加护甲） |
| | passive[] | 法力 200 |

#### 5. Death Knight（死亡骑士）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 死亡骑士 |
| | name_en | Death Knight |
| | race | Orc |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Temple of the Damned |
| | prereq_tech | Altar of Storms |
| | cost_gold | 350 |
| | cost_lumber | 60 |
| | supply | 1 |
| | build_time | 20s |
| **生存** | hp | 100 |
| | armor_type | Light |
| | armor | 0 |
| | tags | caster |
| **机动** | speed | 12 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 5 |
| **攻击** | damage | 8 (Normal) |
| | atk_type | Normal |
| | cooldown | — |
| | range | 2 (近战) |
| | target | G |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | Death Coil（伤害敌方/治疗亡灵友军）、Raise Dead（召唤 2 个骷髅）、Whirlwind（召唤恶魔 — Beyond the Dark Portal 新增） |
| | passive[] | 法力 200 |

#### 6. Catapult（投石车）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 投石车 |
| | name_en | Catapult |
| | race | Orc |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Lumber Mill |
| | prereq_tech | Forge |
| | cost_gold | 750 |
| | cost_lumber | 150 |
| | supply | 2 |
| | build_time | 30s |
| **生存** | hp | 75 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | siege, mechanical |
| **机动** | speed | 6 |
| | fly | false |
| | naval | false |
| | transport_slots | — |
| | vision | 5 |
| **攻击** | damage | 35 (Siege) |
| | atk_type | Siege |
| | cooldown | — |
| | range | 7 |
| | target | G, B (优先对地) |
| | splash | 小范围溅射 |
| | bonus_vs | 建筑 ×2 |
| **技能** | active[] | — |
| | passive[] | — |

#### 7. Goblin Zeppelin（地精飞艇）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 地精飞艇 |
| | name_en | Goblin Zeppelin |
| | race | Orc |
| | tier | T1 |
| | mode | 标准 |
| **生产** | built_from | Goblin Shipyard |
| | prereq_tech | Lumber Mill |
| | cost_gold | 250 |
| | cost_lumber | 125 |
| | supply | 1 |
| | build_time | 25s |
| **生存** | hp | 100 |
| | armor_type | Light |
| | armor | 0 |
| | tags | air, transport |
| **机动** | speed | 8 |
| | fly | true |
| | naval | false |
| | transport_slots | 6 |
| | vision | 8 |
| **攻击** | damage | 0 |
| | atk_type | — |
| | cooldown | — |
| | range | — |
| | target | — |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | 装载/卸载地面单位 |
| | passive[] | 空中运输，可跨越地形 |

#### 8. Dragon（龙）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 龙 |
| | name_en | Dragon |
| | race | Orc |
| | tier | T3 |
| | mode | 标准 |
| **生产** | built_from | Dragon Roost |
| | prereq_tech | Lumber Mill |
| | cost_gold | 350 |
| | cost_lumber | 150 |
| | supply | 2 |
| | build_time | 30s |
| **生存** | hp | 100 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | air |
| **机动** | speed | 16 |
| | fly | true |
| | naval | false |
| | transport_slots | — |
| | vision | 8 |
| **攻击** | damage | 14 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 2 |
| | target | G, A (B) |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | — |

---

### 海军单位（Human / Orc 共用）

海军单位两族完全相同，数据无差异。

#### 1. Transport Ship（运输船）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 运输船 |
| | name_en | Transport Ship |
| | race | Human / Orc |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Shipyard |
| | prereq_tech | — |
| | cost_gold | 400 |
| | cost_lumber | 200 |
| | supply | 1 |
| | build_time | 30s |
| **生存** | hp | 100 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | naval, transport |
| **机动** | speed | 6 |
| | fly | false |
| | naval | true |
| | transport_slots | 8 |
| | vision | 6 |
| **攻击** | damage | 0 |
| | atk_type | — |
| | cooldown | — |
| | range | — |
| | target | — |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | 装载/卸载单位 |
| | passive[] | — |

#### 2. Destroyer（驱逐舰）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 驱逐舰 |
| | name_en | Destroyer |
| | race | Human / Orc |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Shipyard |
| | prereq_tech | — |
| | cost_gold | 400 |
| | cost_lumber | 100 |
| | supply | 1 |
| | build_time | 25s |
| **生存** | hp | 80 |
| | armor_type | Medium |
| | armor | 2 |
| | tags | naval |
| **机动** | speed | 12 |
| | fly | false |
| | naval | true |
| | transport_slots | — |
| | vision | 6 |
| **攻击** | damage | 12 (Piercing) |
| | atk_type | Piercing |
| | cooldown | — |
| | range | 4 |
| | target | G, A, N (对空对海) |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | — |
| | passive[] | — |

#### 3. Battleship（战列舰）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 战列舰 |
| | name_en | Battleship |
| | race | Human / Orc |
| | tier | T3 |
| | mode | 标准 |
| **生产** | built_from | Shipyard |
| | prereq_tech | Foundry |
| | cost_gold | 1000 |
| | cost_lumber | 300 |
| | supply | 2 |
| | build_time | 40s |
| **生存** | hp | 200 |
| | armor_type | Heavy |
| | armor | 4 |
| | tags | naval, siege |
| **机动** | speed | 8 |
| | fly | false |
| | naval | true |
| | transport_slots | — |
| | vision | 7 |
| **攻击** | damage | 25 (Siege) |
| | atk_type | Siege |
| | cooldown | — |
| | range | 7 |
| | target | G, N (对地、对海) |
| | splash | 有 |
| | bonus_vs | 建筑 ×2 |
| **技能** | active[] | — |
| | passive[] | — |

#### 4. Oil Tanker（油轮）

| 分类 | 字段 | 值 |
|------|------|----|
| **身份** | name_zh | 油轮 |
| | name_en | Oil Tanker |
| | race | Human / Orc |
| | tier | T2 |
| | mode | 标准 |
| **生产** | built_from | Shipyard |
| | prereq_tech | — |
| | cost_gold | 400 |
| | cost_lumber | 200 |
| | supply | 1 |
| | build_time | 30s |
| **生存** | hp | 60 |
| | armor_type | Light |
| | armor | 0 |
| | tags | naval, worker |
| **机动** | speed | 6 |
| | fly | false |
| | naval | true |
| | transport_slots | — |
| | vision | 4 |
| **攻击** | damage | 0 |
| | atk_type | — |
| | cooldown | — |
| | range | — |
| | target | — |
| | splash | — |
| | bonus_vs | — |
| **技能** | active[] | 采集石油（海上油井） |
| | passive[] | — |

---

### 召唤单位

| 单位 | 来源 | HP | 伤害 | 备注 |
|------|------|----|------|------|
| Skeleton（骷髅） | Death Knight - Raise Dead | 20 | 4 (Normal) | 持续一段时间后消失 |
| Demon（恶魔） | Death Knight - Whirlwind | 150 | 20 (Normal) | Beyond the Dark Portal，强力近战 |
| Water Elemental（水元素） | Mage - Water Elemental | 80 | 10 (Normal) | 持续一段时间后消失 |
| Eye of Kilrogg（基尔罗格之眼） | Ogre-Mage - Eye of Kilrogg | 5 | 0 | 飞行侦察单位，不可攻击 |

---

### 伤害类型与护甲类型修正表

| 攻击类型↓ \ 护甲类型→ | Light | Medium | Heavy | Fortified |
|------------------------|-------|--------|-------|-----------|
| **Normal** (近战) | 150% | 100% | 75% | 50% |
| **Piercing** (穿刺) | 100% | 75% | 50% | 25% |
| **Siege** (攻城) | 50% | 50% | 75% | 200% |
| **Spell** (法术) | 100% | 100% | 100% | 100% |

### Blacksmith / Forge 升级

| 等级 | 人族武器 | 人族护甲 | 兽族武器 | 兽族护甲 |
|------|---------|---------|---------|---------|
| 1级 | 800g, 100l | 600g, 100l | 600g, 100l | 400g, 100l |
| 2级 | 1600g, 200l | 1200g, 200l | 1200g, 200l | 800g, 200l |
| 3级 | 2400g, 300l | 1800g, 300l | 1800g, 300l | 1200g, 300l |
| 效果 | +1 伤害/级 | +1 护甲/级 | +1 伤害/级 | +1 护甲/级 |

---

### 单位对照简表

| 角色 | Human | Orc | 对比 |
|------|-------|-----|------|
| 工人 | Peasant (400g, 40HP) | Peon (400g, 40HP) | 完全相同 |
| T1 近战 | Footman (400g, 60HP, 6dmg) | Grunt (600g, 80HP, 8dmg) | Grunt 更强更贵 |
| T1 远程 | Archer (500g, 40HP, 5dmg) | Troll Axethrower (500g, 40HP, 5dmg) | 完全相同 |
| T2 近战 | Knight (800g, 120HP, 10dmg) | Ogre (800g, 120HP, 10dmg) | 完全相同 |
| T2 远程升级 | Elven Ranger (+100g/+50l) | Troll Berserker (+100g/+50l) | 完全相同 |
| T3 近战升级 | Paladin (+100g/+100l) | Ogre-Mage (+100g/+100l) | 技能不同 |
| T2 法师 | Conjurer (350g+60l) | Death Knight (350g+60l) | HP/技能不同 |
| 攻城 | Ballista (750g+150l, 35dmg) | Catapult (750g+150l, 35dmg) | 完全相同 |
| T1 空军 | Flying Machine (250g+100l, 仅对空) | Goblin Zeppelin (250g+125l, 运输) | 功能完全不同 |
| T3 空军 | Gryphon Rider (350g+100l, 仅对地) | Dragon (350g+150l, 对空对地) | Dragon 更灵活 |

---

> **注意**: WC2 的兵种设计是"镜像对称 + 差异化"的早期典范。两族大部分单位数值完全对称（甚至金木消耗一致），核心差异体现在：
> 1. 前期 T1 近战（Grunt 明显强于 Footman，但贵 200g）
> 2. 空军路线（Flying Machine 防空 vs Zeppelin 运输 vs Dragon/Gryphon 制空）
> 3. 法术体系（人族偏防御/控制，兽族偏亡灵/召唤）
> 4. 升级经济（兽族 Forge 升级更便宜）
