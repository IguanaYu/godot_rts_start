---
name: 技能与效果系统参考
description: 所有单位技能、指挥官技能、视觉特效、通讯系统的完整清单与文件位置
type: reference
originSessionId: d29d97b8-582f-4a4e-abbc-2c499e3358b8
---
## 一、指挥官技能（12个）

全局技能，通过 UI 技能栏释放，消耗能量/金币。  
文件：`commander_skill_data.gd`、`skill_effects.gd`、`commander_skill_manager.gd`

| 技能 | 快捷键 | 消耗 | 冷却 | 效果 |
|---|---|---|---|---|
| 轨道打击 Orbital Strike | Z | 40能量 | 30s | 范围150伤害 AoE + 爆炸特效 |
| 治疗场 Heal Field | X | 30能量 | 25s | 范围治疗友方 50 HP |
| 盾墙 Shield Wall | C | 25能量 | 20s | 500 HP 墙体，持续15s |
| 空降部队 Unit Drop | V | 300金 | 60s | 空降 soldier×2 + lancer |
| 燃烧弹 Napalm Strike | B | 35能量 | 25s | 30 DPS 火焰区域5s |
| 集束炸弹 Cluster Bomb | N | 45能量 | 35s | 6子炸弹×50伤害，随机散布 |
| 狙击标记 Sniper Mark | F | 20能量 | 8s | 500伤害单点 + 红色标记 |
| 毒云 Poison Cloud | T | 30能量 | 25s | 15 DPS 毒区域8s |
| 紧急修复 Emergency Repair | O | 40能量 | 30s | 全体建筑回复40% HP |
| 力场 Force Field | J | 20能量 | 15s | 无敌屏障8s |
| 维修无人机 Repair Drone | K | 35能量 | 25s | 8 HPS 治疗区域10s |
| 补给空投 Supply Drop | L | 0能量 | 60s | +100 金币 |

## 二、单位技能

### 进攻型
| 能力 | 兵种 | 位置 | 效果 |
|---|---|---|---|
| 远程投射 | Archer系 | `unit.gd:1126` | 射出箭矢/弹丸 |
| 链式闪电 | Stormcaller | `unit.gd:1032-1067` | 闪电链弹跳 + 蓝白连线视觉 |
| 锥形AoE | Salamander | `unit.gd:1070-1090` | 扇形范围攻击 + 橙色扇形视觉 |
| 溅射 Splash | Pyromancer | `splash_effect.gd` | 弹丸命中范围伤害 r=50 |
| 减速射击 | Cryomancer | `slow_effect.gd` | 弹丸命中附加25%减速2s |
| 击退 Knockback | Hammerer | `unit.gd:1025-1027` | 近战击退 |
| 毒 DoT | Venomblade | `unit.gd:1541-1544` | 持续毒伤害 |
| 致死爆炸 | Bomber | `unit.gd:1244-1251` | 死亡时范围爆炸 |
| 复仇 Vengeance | Avenger | `unit.gd:1645-1660` | 友方死亡获得攻击加成 |
| 生命偷取 | Paladin, Berserker | `unit.gd:1631-1640` | 伤害回复生命 |

### 防御/生存型
| 能力 | 兵种 | 位置 | 效果 |
|---|---|---|---|
| 闪现 Blink | Blinker | `unit.gd:1692-1703` | 追击时闪现到目标旁 |
| 隐身 Stealth | Shadowblade | `unit.gd:1666-1688` | 闲置隐身，攻击显形 |
| 闪避 Dodge | Duelist, Shadowblade | `unit.gd:1138` | 概率闪避 |
| 生命恢复 | Troll, Salamander | `unit.gd:502-507` | 自动回血 |
| 护甲穿透 | Armor Piercer | `unit.gd:1147` | 无视减伤 |

### 光环型
| 能力 | 兵种 | 位置 |
|---|---|---|
| 光环（恢复/攻击/防御/射程/护盾） | Banner Bearer, Warden, War Drummer | `unit.gd:1839-1865` |
| 护盾光环 | Warden | `unit.gd:1862-1865` |

### 控制/辅助型
| 能力 | 兵种 | 位置 | 效果 |
|---|---|---|---|
| 嘲讽 Taunt | Stoneguard | `unit.gd:1714-1752` | 强制敌人攻击自己 |
| 驱散 Dispel | Inquisitor | `unit.gd:1559-1565` | 攻击驱散敌方 Buff |
| 净化 Cleanse | Inquisitor | `unit.gd:1548-1555` | 治疗移除友方 Debuff |
| 治疗 Heal | Monk | `unit.gd:774-793` | 治疗受伤友方 |
| 劝化 Convert | Enchanter | `unit.gd:1758-1832` | 引导转化敌方为友方 |
| 召唤 Summon | Necromancer | `unit.gd:1579-1625` | 击杀召唤骷髅 |
| 升级系统 | 所有单位 | `unit.gd:224-226` | 科技升级加属性 |

## 三、视觉特效

| 特效 | 文件 | 说明 |
|---|---|---|
| 爆炸 | `effects/explosion.gd` | 8帧精灵表，16fps |
| 尘土 | `effects/dust_effect.gd` | 6帧，20fps，随机纹理 |
| 治疗光效 | `effects/heal_effect.gd` | 5帧，14fps |
| 出生光柱 | `effects/spawn_effect.gd` | 3层 LightPillar，蓝/紫，20fps |
| 移动点击 | `effects/move_click_effect.gd` | 缩放0.5→1.5+淡出，0.5s |
| 攻击点击 | `effects/attack_click_effect.gd` | 缩放0.3→1.5+旋转+淡出 |
| 弹性反馈 Jelly | `effects/jelly_effect.gd` | Sprite2D弹性缩放1.3→1.0 |
| 浮动文字 | `effects/floating_text.gd` | 弹出→上飘80px→淡出，2s |
| 链式闪电连线 | `unit.gd:1093` | Line2D蓝白连线，0.25s淡出 |
| 锥形AoE扇形 | `unit.gd:1108` | Polygon2D橙色半透明，0.3s淡出 |
| 攻击线 | `unit.gd:1419` | Line2D显示攻击/治疗目标 |
| 路径线 | `unit.gd:1449` | 显示选中单位路径 |
| 状态指示器 | `unit.gd:1401` | HP条上方颜色圆点 |
| Shader - 单位效果 | `shaders/unit_effects.gdshader` | 轮廓发光/减速冰蓝/兵种色调 |
| Shader - 箭头拖尾 | `shaders/arrow_trail.gdshader` | 投射物脉冲发光 |

## 四、通讯/报警系统

| 系统 | 文件 | 说明 |
|---|---|---|
| 敌方呼救 | `unit.gd:1213-1223` | 被攻击时通知400范围友军/敌军 |
| 敌方AI通信 | `enemy_ai.gd:210` | 被攻击切换追击模式 |
| 友方求救 | `ally_distress_signal.gd` | AI友军受伤求救，200范围10s冷却 |
| 求救感叹号 | `ally_distress_marker.gd` | 闪烁黄色 "!" |
| 情绪系统 | `unit_emotion.gd` | 敌方<50% HP触发 |

### 情绪系统
| 情绪 | 持续 | 效果 |
|---|---|---|
| RAGE 暴怒 | 8s | 满血+30%攻速+红色闪烁 |
| ROAR 咆哮 | 0.5s | 随机群体 Buff |
| CALL_HELP 呼救 | 5s | 呼叫800范围友军→后撤 |
| SEEK_GARRISON 驻守 | 15s | 跑向最近驻守建筑 |
| FEAR 恐惧 | 3s | 随机逃离 |

## 五、Buff/Debuff 系统

所有状态效果在 `unit.gd` 内实现：
- **防御 Buff** `"defense"` — 乘法减伤
- **攻击 Buff** `"attack"` — 乘法增伤
- **近战攻击 Buff** `"attack_melee"` — 乘法近战增伤
- **射程 Buff** `"range_bonus"` — 加法加射程
- **减速** `_slow_factor` — 速度×系数 + 冰蓝染色
- **毒 DoT** `_poison_dps` — 每秒持续伤害
- **嘲讽** `_taunt_expire_timer` — 强制攻击嘲讽者
- **隐身** `_stealth_reveal_timer` — 透明度0.35，AI不可见
- **护盾** `_shield_hp` — 吸收伤害
- **复仇** `"attack"` — 友方死亡触发攻击加成

## 六、持久区域效果

用 `persistent_zone.gd` 实现：
- **燃烧区域** — Napalm Strike，30 DPS
- **毒区域** — Poison Cloud，15 DPS
- **维修区域** — Repair Drone，8 HPS

## 七、架构要点

- **没有统一效果管理器**，效果分散在：`FrameAnimatedEffect`（精灵表动画）、`unit.gd` 内嵌字段（状态效果）、`PersistentZone`（区域效果）
- **链式闪电和锥形AoE** 是代码直接绘制的 Line2D/Polygon2D，无粒子系统
- **音频系统完全空白**，无任何 SFX 实现
