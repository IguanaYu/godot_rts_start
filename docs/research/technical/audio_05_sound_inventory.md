# RTS 游戏精确音效清单（基于实际代码扫描）

> 调研日期：2026-08-10
> 项目：Godot 4.6 RTS
> 扫描范围：[scripts/units/](../../scripts/units/)、[scripts/buildings/](../../scripts/buildings/)、[scripts/commander_skill/](../../scripts/commander_skill/)、[scripts/effects/](../../scripts/effects/)、[scripts/main.gd](../../scripts/main.gd)、UI 脚本、场景文件
> 配套：[audio_06_research_summary.md](audio_06_research_summary.md)（方案）、[audio_04_opensource_and_godot.md](audio_04_opensource_and_godot.md)（Godot 集成代码）

---

## 0. 设计原则：按类型分组共用配音

游戏有 **35 个单位 PlaceMode**，但绝大多数单位按**武器/角色类型**共用音效，不需要 35 套独立配音。这样把工作量从 ~700 句台词压缩到 ~150 句。

### 单位配音分组（6 套配音 + 1 套特殊）

| 组 | 包含单位 | 音色定位 | 单位数 |
|----|---------|---------|--------|
| **A. 剑士类** | soldier, shieldbearer, berserker, duelist, paladin, revenant, banner_bearer, avenger, warden, inquisitor | 铿锵人类男声 | 10 |
| **B. 弓箭类** | archer, crossbowman, armor_piercer, stormcaller, elite_archer | 干练人类女声或沉静男声 | 5 |
| **C. 长柄/重武器** | lancer, pikeman, hammerer, ram, stoneguard, salamander, troll | 粗犷低沉男声 | 7 |
| **D. 法师类** | pyromancer, cryomancer, enchanter | 神秘中性声（女声优） | 3 |
| **E. 黑暗/潜行** | necromancer, shadowblade, blinker, venomblade | 阴森低语或沙哑 | 4 |
| **F. 支援类** | monk, war_drummer, bomber | 温润或豪迈 | 3 |
| **G. 召唤物** | skeleton（死灵召唤） | 骨头碰撞声 + 嘶哑吼叫（**非配音**） | 1 |
| **合计** | 35 个单位 | 6 套配音 + 1 套发声 | 33 + 2 无配音 |

**为什么 necromancer 独立一组**：用户在 memory [project_summon_effect.md](../../../C:/Users/haoyu/.claude/projects/f--godot-game-rts-base-rts-base/memory/project_summon_effect.md) 中已标注"召唤特效待替换"，是核心角色需要专属音色。

---

## 1. 单位音效清单

### 1.1 单位语音（按 6 套配音 × 5 种动作 = 30 个语音事件）

| 事件 | 触发位置 | 变体数 | 优先级 | 音色描述 | CC0/CC-BY 来源 | AI 生成 prompt |
|------|---------|--------|--------|---------|---------------|---------------|
| **A1. 剑士-选中** | unit.gd `_on_selected` | 3 | HIGH | "Yes?" "Ready!" "Command?" | Kenney Voiceover Fighter (CC0) | ElevenLabs: "成年男性战士，铿锵有力，'Ready!' 'Yes sir!' 'Command me.'" |
| **A2. 剑士-移动** | unit.gd `_on_move_order` | 3 | NORMAL | "Moving out!" "On my way!" | 同上 | "Moving out!" "On my way!" "Acknowledged!" |
| **A3. 剑士-攻击** | unit.gd `_on_attack_order` | 3 | NORMAL | "For glory!" "Attack!" | 同上 | "For glory!" "Charge!" "Attack!" |
| **A4. 剑士-死亡** | unit.gd `die()` | 3 | HIGH | 短促惨叫 + 倒地 | Bark (MIT) 本地生成 | ElevenLabs whisper→shout 渐弱 + Bark 处理 |
| **B1. 弓箭-选中** | 同上 | 3 | HIGH | "Yes?" "Ready to fire" | OpenGameArt CC0 Voice | ElevenLabs: "成年女性，沉静，'Ready' 'Aye'" |
| **B2-B4. 弓箭-移动/攻击/死亡** | 同上 | 各 3 | NORMAL/HIGH | 类似 | 同上 | 同上 |
| **C1-C4. 长柄类** | 同上 | 各 3 | 同上 | 粗犷男声 | 同上 | "成年男性粗犷低沉，长柄武器战士" |
| **D1-D4. 法师类** | 同上 | 各 3 | 同上 | 神秘女声 | 同上 | "成年女性神秘，法师，吟诵感" |
| **E1-E4. 暗影/死灵** | 同上 | 各 3 | 同上 | 阴森低语 | 同上 | "成年男性阴森低语，沙哑，dark sorcerer" |
| **F1-F4. 支援类** | 同上 | 各 3 | 同上 | 温润或豪迈 | 同上 | "成年男性温润/豪迈，monk" |
| **G. 骷髅** | 同上 | 各 2 | LOW | 骨头碰撞 + 嘶吼 | Freesound CC0 bone rattle | Bark: "[growls] [bone rattling]" |

**语音变体总数**：6 组 × 5 动作 × 3 变体 + 骷髅 5 动作 × 2 变体 = **100 个语音文件**

### 1.2 单位战斗音效（按武器类型共用）

| 事件 | 触发位置 | 变体数 | 优先级 | 音色描述 | CC0/CC-BY 来源 | AI 生成 prompt |
|------|---------|--------|--------|---------|---------------|---------------|
| **剑击 swing** | unit.gd 攻击动画启动 | 5 | NORMAL | 金属破空声 | OpenGameArt CC0 sword pack | ElevenLabs: "sharp metal sword swing whoosh, close-up" |
| **剑击 hit** | unit.gd 命中判定 | 5 | NORMAL | 金属碰撞+火花 | 同上 | "metal clash, steel against steel, bright ringing" |
| **弓弦拉放** | arrow.tscn 实例化时 | 3 | NORMAL | 弓弦弹回声 | Kenney RPG Audio (CC0) | "bow string twang, arrow release" |
| **箭矢命中** | arrow.gd 命中 | 3 | NORMAL | 木质/肉质穿刺 | OpenGameArt CC0 | "arrow impact, flesh thud" |
| **弩箭发射** | crossbowman 攻击 | 3 | NORMAL | 机械上弦 + 弹射 | 同上 | "crossbow mechanical fire, click then twang" |
| **法术施法（火）** | pyromancer 攻击 | 3 | NORMAL | 火球酝酿+喷射 | JC Sounds CC-BY 火魔法 | "fireball cast, whoosh ignition, crackling" |
| **法术施法（冰）** | cryomancer 攻击 | 3 | NORMAL | 冰晶凝结+碎裂 | JC Sounds CC-BY 冰魔法 | "ice cast, crystalline forming, sharp crack" |
| **法术施法（死灵）** | necromancer 召唤 | 3 | HIGH | 低语+骨头碰撞+反向录音 | Bark + 后期处理 | "dark necromantic energy, whispering spirits, reversed audio" |
| **法术施法（增益）** | enchanter/caster_boost | 3 | NORMAL | 上升音阶+柔和光晕 | Kenney Music Jingles | "magical buff cast, ascending ethereal chime" |
| **长柄武器挥击** | lancer/pikeman 攻击 | 4 | NORMAL | 木质+金属混合 swing | Sonniss GDC 武器包 | "polearm swing, wooden shaft whoosh with metal tip" |
| **重锤落地** | hammerer 攻击 | 3 | NORMAL | 沉闷砸地+震动 | Sonniss GDC | "heavy hammer impact, deep thud with debris" |
| **盾牌格挡** | shieldbearer/defense aura | 3 | NORMAL | 木质+金属碰撞 | OpenGameArt CC0 | "shield block, heavy wood with metal rim" |
| **战鼓节拍** | war_drummer 攻击 | 3 | LOW | 鼓点节奏 | Kenney Music Loops | "rhythmic war drum, two-beat cadence" |
| **旗帜展开** | banner_bearer 出生 | 1 | LOW | 布料飘展 | Freesound CC0 | "fabric unfurl, cloth whoosh" |
| **自爆引信** | bomber 攻击 | 1 | HIGH | 嗤嗤燃烧 | Sonniss GDC | "bomb fuse burning, sizzling" |
| **单位出生** | spawn_effect.tscn 实例化 | 3 | NORMAL | 软体出现+魔法光晕 | Kenney Music Jingles | "magical summon appear, soft burst with chime" |
| **脚步（通用）** | unit.gd 移动 | 4 | LOW | 草地/沙地脚步 | Kenney Foley Sounds (CC0) | "footstep on dirt, light armor" |
| **受伤 grunt** | unit.gd `take_damage` | 3 | NORMAL | 短促闷哼 | Kenney Voiceover | "short pain grunt, male warrior" |

**战斗音效变体总数**：约 **55 个文件**

---

## 2. 建筑音效清单

建筑类型：wall, tower, castle, barracks, monastery, archery_range, farm, altar_archer（共 8 种）

### 2.1 建筑通用事件（每种建筑都触发）

| 事件 | 触发位置 | 变体数 | 优先级 | 音色描述 | CC0/CC-BY 来源 | AI 生成 prompt |
|------|---------|--------|--------|---------|---------------|---------------|
| **建筑放置** | building_placer 放下时 | 1 | NORMAL | 木质落地+尘土 | Sonniss GDC | "wooden structure placement, thud with debris" |
| **建造锤击循环** | building.gd 建造中（loop） | 3 | LOW | 锤子敲击木/石 | OpenGameArt CC0 | "construction hammer on wood, rhythmic" |
| **建造完成** | building.gd 完成时 | 2 | HIGH | 满意的"嘭"+音乐提示 | Kenney Music Jingles | "structure completion, satisfying thud with fanfare" |
| **生产开始** | 兵营/靶场生产单位 | 1 | NORMAL | 机械启动+金属 | Sonniss GDC | "production start, mechanical engaging" |
| **生产循环** | production_circle.tscn | 1 | LOW | 锻造/打磨声 | OpenGameArt CC0 | "blacksmith working, rhythmic hammer" |
| **生产完成** | 单位出生时 | 1 | NORMAL | 出兵口开启 | Sonniss GDC | "barracks door opening, mechanical" |
| **受攻击警报** | building.gd 受伤时（首次/冷却） | 1 | **CRITICAL** | 急促警报铃声 | Sonniss GDC | "alarm bell, urgent warning, base under attack" |
| **建筑摧毁** | building.gd hp <= 0 | 2 | HIGH | 坍塌+尘土 | Sonniss GDC | "building collapse, masonry crumbling with dust" |

### 2.2 特定建筑音效

| 建筑 | 事件 | 变体 | 优先级 | 来源 |
|------|------|------|--------|------|
| **Tower（箭塔）** | 攻击发射（同弓箭） | 共用 B2 | NORMAL | OpenGameArt CC0 |
| **Farm（农场）** | 收获音效（金币产生时） | 2 | LOW | Kenney Music Jingles / Sonniss |
| **Altar_Archer（据点）** | 占领开始/进度/完成 | 各 2 | HIGH | 自定义魔法音色 |
| **Castle（基地）** | 升级时代时特殊提示 | 1 | HIGH | Kenney Music Jingles |

**建筑音效变体总数**：约 **25 个文件**

---

## 3. 指挥官技能音效清单

13 个技能：ORBITAL_STRIKE, HEAL_FIELD, SHIELD_WALL, UNIT_DROP, NAPALM_STRIKE, CLUSTER_BOMB, SNIPER_MARK, POISON_CLOUD, EMERGENCY_REPAIR, FORCE_FIELD, REPAIR_DRONE, SUPPLY_DROP, FORTIFY

每个技能通常有 3 个阶段：**释放 → 飞行/落地 → 命中/持续**。

| 技能 | 释放（HIGH） | 命中/落地（HIGH） | 持续（NORMAL） | 来源 |
|------|-------------|------------------|---------------|------|
| **ORBITAL_STRIKE 轨道轰炸** | 太空充能声 | 巨大爆炸 | 余震 | Sonniss GDC + Sky_event |
| **HEAL_FIELD 治疗领域** | 柔和魔法上升 | 光柱落地 | 持续治愈音 | JC Sounds CC-BY 治疗增益 |
| **SHIELD_WALL 盾墙** | 金属共鸣展开 | 盾牌落地 | 持续嗡鸣 | OpenGameArt CC0 盾 |
| **UNIT_DROP 单位空投** | 飞机掠过 + 警报 | 落地碰撞 | — | Sonniss GDC |
| **NAPALM_STRIKE 凝固汽油弹** | 火焰喷射 | 爆炸 + 燃烧 | 火焰持续噼啪 | JC Sounds CC-BY 火 |
| **CLUSTER_BOMB 集束炸弹** | 投弹 | 主爆 + 6 次小爆 | — | Sonniss GDC |
| **SNIPER_MARK 狙击标记** | 锁定嘀嘀声 | 大口径狙击枪 | — | Sonniss GDC |
| **POISON_CLOUD 毒气云** | 嘶嘶喷气 | 毒气扩散 | 咳嗽/气泡 | Sonniss GDC |
| **EMERGENCY_REPAIR 紧急维修** | 机械启动 | 焊接/敲击 | 持续修理 | OpenGameArt CC0 |
| **FORCE_FIELD 力场屏障** | 能量场展开 | 撞击嗡鸣 | 持续能量场 | JC Sounds CC-BY 魔法盾 |
| **REPAIR_DRONE 维修无人机** | 无人机螺旋桨 | 焊接音 | 持续嗡嗡 | Sonniss GDC |
| **SUPPLY_DROP 补给箱** | 飞机掠过 | 木箱落地 | — | Sonniss GDC |
| **FORTIFY 加固** | 木质加固声 | 完成 chime | — | OpenGameArt CC0 |

**通用技能音效**：

| 事件 | 触发位置 | 变体 | 优先级 | 备注 |
|------|---------|------|--------|------|
| **技能按钮点击** | commander_skill_panel | 1 | NORMAL | 区别于普通 UI |
| **技能释放（通用）** | skill_effects.gd | 1 | HIGH | 强力魔法释放 |
| **技能冷却完成** | 按钮亮起 | 1 | NORMAL | 清脆 chime |
| **能量不足错误** | 释放失败 | 1 | NORMAL | 低沉错误音 |
| **目标预览出现** | target_preview.gd | 1 | NORMAL | 瞄准音 |
| **区域指示器** | area_indicator.gd | 1 | LOW | 持续嗡鸣 |

**技能音效总数**：13 技能 × 平均 2 阶段 + 通用 6 = 约 **35 个文件**

---

## 4. UI 音效清单

| 事件 | 触发位置 | 变体 | 优先级 | 音色 | 来源 |
|------|---------|------|--------|------|------|
| **鼠标点击空地（移动命令）** | move_click_effect.tscn | 1 | NORMAL | 软质点击 | Kenney Interface Sounds |
| **鼠标点击敌人（攻击命令）** | attack_click_effect.tscn | 1 | NORMAL | 锐利点击 | 同上 |
| **按钮 click** | button_factory.gd | 2 | NORMAL | 清脆 UI | Kenney UI Audio |
| **按钮 hover** | 同上 | 1 | LOW | 极轻 hover | 同上 |
| **选择单位（框选成功）** | main.gd 选中时 | 1 | NORMAL | 选中 chime | Kenney UI |
| **取消选择** | 同上 | 1 | NORMAL | 取消音 | 同上 |
| **金币不够错误** | building_placer 失败 | 1 | NORMAL | 低沉错误 | Kenney UI |
| **不可建造位置** | 同上 | 1 | NORMAL | 同上 | 同上 |
| **金币增加（生产/击杀）** | main.gd 金币+ | 1 | LOW | 硬币叮当 | Kenney RPG Audio |
| **金币扣减（建造）** | 同上 | 1 | LOW | 轻微扣减 | 同上 |
| **时代升级开始** | main.gd 升级启动 | 1 | HIGH | 史诗 chime | Kenney Music Jingles |
| **时代升级完成（T2）** | age_upgrade_timer 完成 | 1 | HIGH | 战吼/号角 | Sonniss GDC |
| **时代升级完成（T3）** | 同上 | 1 | HIGH | 更强战吼 | 同上 |
| **升级面板打开** | upgrade_panel.gd | 1 | NORMAL | 面板展开 | Kenney UI |
| **升级面板关闭** | 同上 | 1 | NORMAL | 面板收起 | 同上 |
| **技能面板打开/关闭** | commander_skill_panel | 各 1 | NORMAL | 同上 | 同上 |
| **菜单切换（关卡选择等）** | level_select/save_select | 1 | NORMAL | 页面切换 | 同上 |
| **控制组 Ctrl+1/2/3** | main.gd 编队时 | 1 | NORMAL | 简短确认 | Kenney UI |
| **集结点设置** | rally_point_indicator | 1 | NORMAL | 旗帜飘展 | Freesound CC0 |

**UI 音效总数**：约 **22 个文件**

---

## 5. 游戏状态事件音效

| 事件 | 触发位置 | 变体 | 优先级 | 音色 | 来源 |
|------|---------|------|--------|------|------|
| **胜利** | victory_*.gd 达成 | 1 | **CRITICAL** | 史诗管弦高潮 | Scott Buckley CC-BY（如 "Cipher"）或 Suno 生成 |
| **失败** | main.gd 失败判定 | 1 | **CRITICAL** | 沉重挽歌 | Scott Buckley CC-BY（如 "Wildflowers"） |
| **基地受攻击** | building_under_attack | 1 | **CRITICAL** | 警报（与建筑受攻击同但更急促） | Sonniss GDC |
| **波次预警** | victory_survive_waves | 1 | HIGH | 战争号角 + 鼓点 | Sonniss GDC |
| **波次开始** | 敌人生成 | 1 | HIGH | 大量单位出生轰鸣 | Sonniss GDC |
| **占领点争夺中** | outpost_capture_ring | 1 | NORMAL | 持续铃声/魔法 | JC Sounds CC-BY |
| **占领点夺取** | 同上完成 | 1 | HIGH | 满意 chime | Kenney Music Jingles |
| **任务目标完成** | bonus_objective | 1 | HIGH | 任务完成提示 | Sonniss GDC |
| **星级评价完成** | star_rating.gd | 1 | HIGH | 上升音阶 + 掌声 | Kenney Music Jingles |
| **AI 队友求救** | ally_distress_marker | 1 | HIGH | 急促呼叫 | Sonniss GDC |
| ** Escort NPC 受伤** | escort_npc.gd | 1 | HIGH | NPC 呻吟 | Kenney Voiceover |

**状态事件总数**：约 **13 个文件**

---

## 6. 视觉特效对应音效清单

22 个视觉特效，部分共用音效：

| 视觉特效 | 对应音效 | 来源 |
|---------|---------|------|
| spawn_effect | 单位出生（见 1.2） | — |
| explosion | 爆炸（见 1.2 + 技能） | — |
| heal_effect | 治疗领域持续音 | JC Sounds CC-BY |
| dust_effect | 脚步声（见 1.2） | — |
| click_effect | UI 点击（见 4） | — |
| jelly_effect | 击中变形音（独立 1 个） | Sonniss GDC |
| damage_number | **无声**（纯视觉飘字） | — |
| production_circle | 生产循环（见 2.1） | — |
| arrow | 弓箭飞行（独立 1 个 whoosh） | OpenGameArt CC0 |
| rally_point_indicator | 集结点设置（见 4） | — |
| aoe_zone_effect | AOE 区域嗡鸣（独立 1 个 loop） | Sonniss GDC |
| beam_effect | 光束发射（独立 1 个） | JC Sounds CC-BY |
| caster_boost | 增益施法（见 1.2） | — |
| floating_text | **无声** | — |
| skill_floating_text | **无声** | — |
| orbiting_orbs_effect | 环绕球嗡鸣（独立 1 个 loop） | Sonniss GDC |
| sky_event_effect | 天空事件（轨道轰炸专用，见技能） | — |
| warning_marker | 警告标记（独立 1 个） | Sonniss GDC |
| elite_aura | 精英光环（独立 1 个 loop，柔和嗡鸣） | Sonniss GDC |
| outpost_capture_ring | 占领点（见 5） | — |
| objective_marker | 任务标记（独立 1 个） | Sonniss GDC |

**视觉特效新增音效**：约 **8 个独立文件**（其余共用）

---

## 7. 环境音

| 事件 | 触发位置 | 变体 | 优先级 | 音色 | 来源 |
|------|---------|------|--------|------|------|
| **羊咩咩叫** | sheep.gd 偶尔触发 | 3 | LOW | 羊叫 | Sonniss GDC 动物 / Freesound CC0 |
| **羊被击杀** | sheep.gd die | 1 | LOW | 短促哀鸣 | 同上 |
| **树被砍** | tree.gd（如有砍伐机制） | 2 | LOW | 木质砍击 | OpenGameArt CC0 |
| **地图背景环境（鸟叫/虫鸣）** | 场景加载时启动 | 1 | LOW | 森林 ambient loop | Pixabay Music / Sonniss GDC |
| **风声** | 同上 | 1 | LOW | 风声 loop | Kenney Foley |
| **水流声（terrain_river）** | 河流场景 | 1 | LOW | 水流 loop | Sonniss GDC |
| **篝火声（如有）** | 同上 | 1 | LOW | 火焰噼啪 loop | OpenGameArt CC0 |

**环境音总数**：约 **10 个文件**

---

## 8. 背景音乐（BGM）

| 状态 | 触发位置 | 数量 | 来源 |
|------|---------|------|------|
| **主菜单音乐** | main_menu.tscn | 1 | Scott Buckley CC-BY（如 "Simulacra"）|
| **关卡选择/大厅** | level_select/lobby | 1 | Kevin MacLeod CC-BY（如 "Long Note Four"）|
| **和平时期（探索）** | main.gd 和平状态 | 2 | Scott Buckley / OpenGameArt CC0 |
| **战斗时期（普通战斗）** | 进入战斗状态 | 2 | Scott Buckley（如 "Song Of The Forge"）|
| **Boss 战斗（敌人 Boss）** | boss_ai 出现 | 1 | Scott Buckley（如 "Simulacra"）|
| **危机（基地受攻击/血量低）** | building_under_attack | 1 | 紧张氛围乐 |
| **胜利** | game_victory | 1 | 史诗合唱（Suno Pro 生成）|
| **失败** | game_defeat | 1 | 沉重挽歌（Scott Buckley "Wildflowers"）|

**BGM 总数**：约 **9 个 .ogg 文件**

---

## 9. 总览统计

### 9.1 按类别统计

| 类别 | 文件数 | 备注 |
|------|--------|------|
| 单位语音 | 100 | 6 套配音 × 5 动作 × 3 变体 + 骷髅 |
| 单位战斗音效 | 55 | 武器类型共用 |
| 建筑音效 | 25 | 8 种建筑共用通用事件 |
| 指挥官技能 | 35 | 13 技能 × 2 阶段 + 通用 |
| UI 音效 | 22 | |
| 游戏状态事件 | 13 | |
| 视觉特效对应 | 8 | 其余共用 |
| 环境音 | 10 | |
| 背景音乐 | 9 | .ogg |
| **合计** | **~277 个文件** | **不是 800-1000** |

### 9.2 按优先级分布

| 优先级 | 文件数 | 占比 | 含义 |
|--------|--------|------|------|
| **CRITICAL** | ~20 | 7% | 必须穿透战斗噪音（胜利/失败/基地警报/技能释放） |
| **HIGH** | ~80 | 29% | 重要反馈（建筑完成/单位死亡/选中/出生） |
| **NORMAL** | ~140 | 51% | 标准游戏反馈（攻击/移动命令/UI 点击） |
| **LOW** | ~37 | 13% | 装饰性（脚步/环境/按钮 hover） |

### 9.3 按来源分布（推荐方案）

| 来源 | 文件数 | 占比 | 备注 |
|------|--------|------|------|
| **Sonniss GDC Bundle** | ~120 | 43% | 工业级音效主体（武器/爆炸/警报/UI） |
| **Kenney (CC0)** | ~50 | 18% | UI/通用音效/Voiceover 包 |
| **OpenGameArt CC0** | ~25 | 9% | 奇幻战斗/RPG 音效 |
| **JC Sounds CC-BY** | ~10 | 4% | 火冰魔法音效（需署名） |
| **ElevenLabs AI 生成** | ~50 | 18% | 单位英文配音（100 句中除共用的） |
| **CosyVoice 3 / Azure** | ~15 | 5% | 中文配音（如需要） |
| **Suno Pro 生成** | ~9 | 3% | BGM |
| **合计** | ~277 | 100% | |

### 9.4 按文件格式

| 格式 | 用途 | 文件数 |
|------|------|--------|
| **.wav** | 所有 SFX + 单位配音 | ~268 |
| **.ogg** | 背景音乐 | ~9 |

---

## 10. 落地建议（优先级排序）

### 阶段 1：跑通核心反馈（约 30 个文件，1 天）

只做以下文件即可让游戏"有声音":
1. UI 点击、按钮 hover、选中单位（5 个）
2. 剑击 swing + hit、弓箭发射 + 命中、爆炸（4 个变体组）
3. 单位出生、单位死亡 grunt（2 个）
4. 建筑放置、建造完成、受攻击警报（3 个）
5. 胜利 + 失败 BGM（2 个）
6. 时代升级 chime（1 个）

### 阶段 2：补全战斗反馈（约 80 个文件，2-3 天）

- 6 套配音 × 5 动作 × 3 变体 = 90 个（先做选中/移动/攻击，死亡暂用通用）
- 全部武器音效（剑/弓/弩/法术/长柄/锤/盾）
- 全部技能释放 + 命中音效

### 阶段 3：完整覆盖（约 277 个文件，1 周）

- 全部建筑音效
- 全部 UI 操作（金币、错误、面板）
- 全部状态事件（占领点、波次、星级）
- 视觉特效对应音效
- 环境音（背景 ambient）

### 阶段 4（可选）：AI 定制

- 用 ElevenLabs Creator ($22) 生成 100 句英文配音替换 CC0 通用包
- 用 Suno Pro ($10) 生成专属 BGM 替换 CC-BY
- 用 CosyVoice 3 生成中文配音

---

## 11. 关键文件路径建议

按 [audio_04_opensource_and_godot.md](audio_04_opensource_and_godot.md) 的目录结构：

```
res://audio/
  sfx/
    ui/                    # 22 个 UI 音效
      click_1.wav, click_2.wav, hover_1.wav, error_1.wav ...
    units/
      voices/              # 单位配音
        swordsman/         # 剑士类（A 组共用）
          select_1.wav, select_2.wav, select_3.wav
          move_1.wav, move_2.wav, move_3.wav
          attack_1.wav, attack_2.wav, attack_3.wav
          death_1.wav, death_2.wav, death_3.wav
        archer/            # 弓箭类（B 组共用）
        polearm/           # 长柄类（C 组共用）
        mage/              # 法师类（D 组共用）
        shadow/            # 暗影类（E 组共用）
        support/           # 支援类（F 组共用）
        skeleton/          # 骷髅（G 组）
      combat/              # 武器音效（所有单位共用）
        sword_swing_1.wav ~ sword_swing_5.wav
        sword_hit_1.wav ~ sword_hit_5.wav
        bow_fire_1.wav ~ bow_fire_3.wav
        arrow_impact_1.wav ~ arrow_impact_3.wav
        fireball_1.wav, ice_cast_1.wav, necromancy_1.wav ...
    buildings/
      place_1.wav, build_loop_1.wav, complete_1.wav
      under_attack_alarm.wav, destroy_1.wav ...
    skills/
      orbital_strike_cast.wav, orbital_strike_impact.wav
      heal_field_cast.wav, heal_field_loop.wav ...
    game/
      victory.wav, defeat.wav, era_upgrade_t2.wav ...
  music/
    menu.ogg, peace_1.ogg, combat_1.ogg, boss.ogg
    victory.ogg, defeat.ogg ...
  credits.txt              # CC-BY 素材署名（必备）
```

---

## 12. 一句话执行建议

**先跑通阶段 1（30 个文件）验证 AudioManager 集成 → 用 Sonniss GDC + Kenney CC0 完成 70% 的音效 → 用 ElevenLabs Creator $22 一次性生成 100 句英文单位配音 → 上 Steam 前做 Suno BGM + Credits 署名页面 + AI 披露**。
