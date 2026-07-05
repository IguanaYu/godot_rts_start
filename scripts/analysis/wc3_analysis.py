# -*- coding: utf-8 -*-
"""
魔兽争霸3 数值分析脚本
计算伤害公式、英雄系统、种族对比、单位性价比等
"""

# ============================================================
# 1. WC3 伤害公式
# ============================================================
"""
WC3 伤害公式（减法+百分比混合）:

当护甲 > 0:
    减免比例 = (armor × 0.06) / (1 + 0.06 × armor)
    实际伤害 = 攻击 × type_multiplier × (1 - 减免比例)

当护甲 < 0:
    实际伤害 = 攻击 × type_multiplier × (2 - 0.94^|armor|)

护甲边际收益递减:
    1甲 ≈ 5.66% 减免
    5甲 ≈ 23.08% 减免
    10甲 ≈ 37.50% 减免
    20甲 ≈ 54.55% 减免
"""

# 攻击类型 × 护甲类型 倍率表 (6×6)
# 行: 攻击类型 Normal, Pierce, Siege, Magic, Chaos, Spells
# 列: 护甲类型 Light, Medium, Heavy, Fortified, Hero, Unarmored
ATTACK_TYPE_TABLE = {
    "Normal":  {"Light": 1.0, "Medium": 1.5, "Heavy": 1.0, "Fortified": 0.7, "Hero": 1.0, "Unarmored": 1.0},
    "Piercing": {"Light": 2.0, "Medium": 0.75, "Heavy": 1.0, "Fortified": 0.35, "Hero": 1.0, "Unarmored": 1.5},
    "Siege":   {"Light": 1.0, "Medium": 0.5, "Heavy": 1.0, "Fortified": 1.5, "Hero": 1.0, "Unarmored": 1.5},
    "Magic":   {"Light": 1.25, "Medium": 0.75, "Heavy": 2.0, "Fortified": 0.35, "Hero": 1.0, "Unarmored": 1.0},
    "Chaos":   {"Light": 1.0, "Medium": 1.0, "Heavy": 1.0, "Fortified": 1.0, "Hero": 1.0, "Unarmored": 1.0},
    "Spells":  {"Light": 1.0, "Medium": 1.0, "Heavy": 1.0, "Fortified": 1.0, "Hero": 0.75, "Unarmored": 1.0},
}

ARMOR_TYPES = ["Light", "Medium", "Heavy", "Fortified", "Hero", "Unarmored"]


def armor_damage_reduction(armor):
    """计算护甲减免比例"""
    if armor >= 0:
        return (armor * 0.06) / (1 + 0.06 * armor)
    else:
        return 1 - (2 - 0.94 ** abs(armor))


def compute_actual_damage(atk_damage, atk_type, target_armor, target_armor_type):
    """计算实际伤害 = 攻击 × 类型倍率 × (1 - 护甲减免)"""
    type_mult = ATTACK_TYPE_TABLE.get(atk_type, {}).get(target_armor_type, 1.0)
    reduction = armor_damage_reduction(target_armor)
    return atk_damage * type_mult * (1 - reduction)


# ============================================================
# 2. 单位数据
# ============================================================
UNITS = {
    # Human T1
    "Footman": {"hp": 420, "armor_type": "Heavy", "armor": 2, "damage": 12.5, "atk_type": "Normal", "cd": 1.35, "range": 0.1,
                "cost_g": 135, "cost_l": 0, "supply": 2, "tier": "T1", "race": "Human", "role": "近战肉盾"},
    "Rifleman": {"hp": 505, "armor_type": "Medium", "armor": 0, "damage": 18.5, "atk_type": "Piercing", "cd": 1.5, "range": 550,
                 "cost_g": 205, "cost_l": 30, "supply": 3, "tier": "T1", "race": "Human", "role": "远程穿刺"},
    # Human T2
    "Priest": {"hp": 295, "armor_type": "Unarmored", "armor": 0, "damage": 0, "atk_type": "Magic", "cd": 2.0, "range": 550,
               "cost_g": 135, "cost_l": 10, "supply": 2, "tier": "T2", "race": "Human", "role": "法师治疗"},
    "Sorceress": {"hp": 295, "armor_type": "Unarmored", "armor": 0, "damage": 0, "atk_type": "Magic", "cd": 2.0, "range": 550,
                  "cost_g": 155, "cost_l": 20, "supply": 2, "tier": "T2", "race": "Human", "role": "法师控制"},
    "Spell Breaker": {"hp": 550, "armor_type": "Medium", "armor": 2, "damage": 15, "atk_type": "Normal", "cd": 1.35, "range": 0.1,
                      "cost_g": 215, "cost_l": 30, "supply": 3, "tier": "T2", "race": "Human", "role": "魔免近战"},
    "Mortar Team": {"hp": 300, "armor_type": "Medium", "armor": 0, "damage": 48, "atk_type": "Siege", "cd": 3.5, "range": 1100,
                    "cost_g": 225, "cost_l": 60, "supply": 3, "tier": "T2", "race": "Human", "role": "攻城溅射"},
    # Human T3
    "Knight": {"hp": 710, "armor_type": "Heavy", "armor": 5, "damage": 25, "atk_type": "Normal", "cd": 1.4, "range": 0.1,
               "cost_g": 245, "cost_l": 50, "supply": 4, "tier": "T3", "race": "Human", "role": "重甲骑兵"},
    "Gryphon Rider": {"hp": 650, "armor_type": "Heavy", "armor": 0, "damage": 47.5, "atk_type": "Magic", "cd": 2.0, "range": 550,
                      "cost_g": 255, "cost_l": 70, "supply": 4, "tier": "T3", "race": "Human", "role": "空对地轰炸"},
    "Steam Tank": {"hp": 800, "armor_type": "Fortified", "armor": 6, "damage": 53.5, "atk_type": "Siege", "cd": 2.5, "range": 525,
                   "cost_g": 220, "cost_l": 60, "supply": 3, "tier": "T3", "race": "Human", "role": "攻城魔免"},

    # Orc T1
    "Grunt": {"hp": 700, "armor_type": "Heavy", "armor": 1, "damage": 20.5, "atk_type": "Normal", "cd": 1.6, "range": 0.1,
              "cost_g": 200, "cost_l": 0, "supply": 3, "tier": "T1", "race": "Orc", "role": "近战重甲"},
    "Headhunter": {"hp": 350, "armor_type": "Medium", "armor": 0, "damage": 18, "atk_type": "Piercing", "cd": 1.6, "range": 550,
                   "cost_g": 140, "cost_l": 20, "supply": 2, "tier": "T1", "race": "Orc", "role": "远程穿刺"},
    # Orc T2
    "Raider": {"hp": 500, "armor_type": "Heavy", "armor": 0, "damage": 21, "atk_type": "Normal", "cd": 1.7, "range": 0.1,
               "cost_g": 180, "cost_l": 40, "supply": 3, "tier": "T2", "race": "Orc", "role": "近战控制"},
    "Shaman": {"hp": 335, "armor_type": "Unarmored", "armor": 0, "damage": 8.5, "atk_type": "Magic", "cd": 2.0, "range": 550,
               "cost_g": 130, "cost_l": 20, "supply": 2, "tier": "T2", "race": "Orc", "role": "法师嗜血"},
    "Wind Rider": {"hp": 525, "armor_type": "Medium", "armor": 0, "damage": 36.5, "atk_type": "Piercing", "cd": 1.8, "range": 550,
                   "cost_g": 200, "cost_l": 30, "supply": 3, "tier": "T2", "race": "Orc", "role": "空对地"},
    "Kodo Beast": {"hp": 750, "armor_type": "Heavy", "armor": 1, "damage": 12, "atk_type": "Normal", "cd": 1.5, "range": 0.1,
                   "cost_g": 200, "cost_l": 30, "supply": 3, "tier": "T2", "race": "Orc", "role": "辅助吞噬"},
    # Orc T3
    "Tauren": {"hp": 1200, "armor_type": "Heavy", "armor": 3, "damage": 32.5, "atk_type": "Normal", "cd": 1.5, "range": 0.1,
               "cost_g": 280, "cost_l": 80, "supply": 5, "tier": "T3", "race": "Orc", "role": "终极肉盾"},
    "Troll Batrider": {"hp": 400, "armor_type": "Medium", "armor": 0, "damage": 14, "atk_type": "Piercing", "cd": 1.4, "range": 500,
                       "cost_g": 160, "cost_l": 40, "supply": 2, "tier": "T3", "race": "Orc", "role": "自杀反空"},

    # Undead T1
    "Ghoul": {"hp": 330, "armor_type": "Heavy", "armor": 0, "damage": 13, "atk_type": "Normal", "cd": 1.15, "range": 0.1,
              "cost_g": 120, "cost_l": 0, "supply": 2, "tier": "T1", "race": "Undead", "role": "近战采木"},
    "Crypt Fiend": {"hp": 490, "armor_type": "Medium", "armor": 0, "damage": 18.5, "atk_type": "Piercing", "cd": 2.0, "range": 550,
                    "cost_g": 200, "cost_l": 25, "supply": 3, "tier": "T1", "race": "Undead", "role": "远程对空"},
    # Undead T2
    "Abomination": {"hp": 900, "armor_type": "Heavy", "armor": 2, "damage": 27, "atk_type": "Normal", "cd": 1.5, "range": 0.1,
                    "cost_g": 200, "cost_l": 30, "supply": 4, "tier": "T2", "race": "Undead", "role": "重甲肉盾"},
    "Banshee": {"hp": 265, "armor_type": "Unarmored", "armor": 0, "damage": 9, "atk_type": "Magic", "cd": 2.0, "range": 550,
                "cost_g": 135, "cost_l": 30, "supply": 2, "tier": "T2", "race": "Undead", "role": "法师占据"},
    "Destroyer": {"hp": 550, "armor_type": "Heavy", "armor": 2, "damage": 22, "atk_type": "Magic", "cd": 1.8, "range": 550,
                  "cost_g": 250, "cost_l": 85, "supply": 3, "tier": "T2", "race": "Undead", "role": "魔免反魔"},
    # Undead T3
    "Frost Wyrm": {"hp": 1050, "armor_type": "Heavy", "armor": 2, "damage": 51.5, "atk_type": "Magic", "cd": 2.0, "range": 550,
                   "cost_g": 350, "cost_l": 115, "supply": 7, "tier": "T3", "race": "Undead", "role": "减速冰龙"},

    # Night Elf T1
    "Archer": {"hp": 245, "armor_type": "Medium", "armor": 0, "damage": 16, "atk_type": "Piercing", "cd": 1.5, "range": 550,
               "cost_g": 130, "cost_l": 10, "supply": 2, "tier": "T1", "race": "Night Elf", "role": "远程穿刺"},
    "Huntress": {"hp": 475, "armor_type": "Medium", "armor": 2, "damage": 15.5, "atk_type": "Piercing", "cd": 1.5, "range": 0.1,
                 "cost_g": 170, "cost_l": 30, "supply": 3, "tier": "T1", "race": "Night Elf", "role": "近战弹射"},
    # Night Elf T2
    "Dryad": {"hp": 435, "armor_type": "Medium", "armor": 0, "damage": 13, "atk_type": "Piercing", "cd": 1.5, "range": 550,
              "cost_g": 145, "cost_l": 40, "supply": 3, "tier": "T2", "race": "Night Elf", "role": "远程驱散"},
    "Druid of the Claw (Bear)": {"hp": 860, "armor_type": "Heavy", "armor": 2, "damage": 24.5, "atk_type": "Normal", "cd": 1.5, "range": 0.1,
                                  "cost_g": 195, "cost_l": 55, "supply": 4, "tier": "T2", "race": "Night Elf", "role": "肉盾治疗"},
    "Mountain Giant": {"hp": 1300, "armor_type": "Heavy", "armor": 4, "damage": 24, "atk_type": "Normal", "cd": 2.0, "range": 0.1,
                       "cost_g": 280, "cost_l": 100, "supply": 7, "tier": "T2", "race": "Night Elf", "role": "终极肉盾"},
    # Night Elf T3
    "Chimaera": {"hp": 525, "armor_type": "Light", "armor": 2, "damage": 37.5, "atk_type": "Magic", "cd": 2.0, "range": 550,
                 "cost_g": 280, "cost_l": 70, "supply": 5, "tier": "T3", "race": "Night Elf", "role": "空对地溅射"},
}

# ============================================================
# 3. 英雄数据
# ============================================================
HEROES = {
    "Archmage": {"hp": 475, "mana": 375, "str": 16, "agi": 18, "int": 27, "primary": "int", "race": "Human", "type": "智力法师"},
    "Mountain King": {"hp": 675, "mana": 300, "str": 25, "agi": 14, "int": 18, "primary": "str", "race": "Human", "type": "力量战士"},
    "Paladin": {"hp": 650, "mana": 300, "str": 24, "agi": 15, "int": 18, "primary": "str", "race": "Human", "type": "力量辅助"},
    "Blood Mage": {"hp": 500, "mana": 360, "str": 17, "agi": 16, "int": 26, "primary": "int", "race": "Human", "type": "智力法师"},
    "Blade Master": {"hp": 600, "mana": 250, "str": 22, "agi": 24, "int": 14, "primary": "agi", "race": "Orc", "type": "敏捷刺客"},
    "Far Seer": {"hp": 500, "mana": 350, "str": 18, "agi": 16, "int": 25, "primary": "int", "race": "Orc", "type": "智力召唤"},
    "Tauren Chieftain": {"hp": 700, "mana": 270, "str": 26, "agi": 15, "int": 16, "primary": "str", "race": "Orc", "type": "力量坦克"},
    "Shadow Hunter": {"hp": 550, "mana": 300, "str": 20, "agi": 20, "int": 20, "primary": "agi", "race": "Orc", "type": "敏捷辅助"},
    "Death Knight": {"hp": 625, "mana": 290, "str": 23, "agi": 16, "int": 19, "primary": "str", "race": "Undead", "type": "力量光环"},
    "Lich": {"hp": 475, "mana": 380, "str": 16, "agi": 14, "int": 28, "primary": "int", "race": "Undead", "type": "智力爆发"},
    "Dread Lord": {"hp": 650, "mana": 270, "str": 24, "agi": 16, "int": 18, "primary": "str", "race": "Undead", "type": "力量控制"},
    "Crypt Lord": {"hp": 700, "mana": 260, "str": 26, "agi": 14, "int": 17, "primary": "str", "race": "Undead", "type": "力量召唤"},
    "Demon Hunter": {"hp": 600, "mana": 270, "str": 22, "agi": 22, "int": 16, "primary": "agi", "race": "Night Elf", "type": "敏捷输出"},
    "Keeper of the Grove": {"hp": 500, "mana": 350, "str": 18, "agi": 15, "int": 25, "primary": "int", "race": "Night Elf", "type": "智力召唤"},
    "Priestess of the Moon": {"hp": 500, "mana": 270, "str": 18, "agi": 24, "int": 17, "primary": "agi", "race": "Night Elf", "type": "敏捷光环"},
    "Warden": {"hp": 525, "mana": 260, "str": 19, "agi": 24, "int": 16, "primary": "agi", "race": "Night Elf", "type": "敏捷刺客"},
}


def main():
    output = []

    output.append("# 魔兽争霸3 数值逆向工程分析\n")
    output.append("> 基于 wc3.md 完整单位数据 / 分析日期: 2026-07-01\n")

    # ============================================================
    # 第一部分：伤害公式体系
    # ============================================================
    output.append("---\n")
    output.append("## 1. 伤害公式体系\n")

    output.append("### 1.1 核心公式：百分比减免型\n")
    output.append("")
    output.append("WC3 使用**百分比护甲减免**（区别于 SC2 的减法公式）：")
    output.append("")
    output.append("```")
    output.append("护甲 > 0:  减免比例 = (护甲 × 0.06) / (1 + 0.06 × 护甲)")
    output.append("护甲 < 0:  减免比例 = 1 - (2 - 0.94^|护甲|)")
    output.append("实际伤害 = 攻击力 × 攻击类型倍率 × (1 - 减免比例)")
    output.append("```")
    output.append("")

    # 护甲减免表
    output.append("**护甲减免表：**")
    output.append("")
    output.append("| 护甲值 | 减免比例 | 等效耐久提升 |")
    output.append("|--------|---------|-------------|")
    for arm in [0, 1, 2, 3, 5, 7, 10, 15, 20]:
        red = armor_damage_reduction(arm)
        ehp_mult = 1 / (1 - red) if red < 1 else float('inf')
        output.append(f"| {arm} | {red*100:.2f}% | {ehp_mult:.2f}x |")

    output.append("")
    output.append("**与 SC2 减法公式对比：**")
    output.append("")
    output.append("| 维度 | WC3 百分比减免 | SC2 减法公式 |")
    output.append("|------|---------------|-------------|")
    output.append("| 公式 | armor×0.06/(1+0.06×armor) | max(dmg-armor, 0.5) |")
    output.append("| 护甲收益 | 递减（每点收益渐降） | 线性（每点减1伤害） |")
    output.append("| 对低伤单位 | 护甲效率高（高减免%） | 护甲效率极高（直接无效化） |")
    output.append("| 对高伤单位 | 护甲效率低（低减免%） | 护甲效率低 |")
    output.append("| 护甲上限 | 理论100%（实际 ~15% 后衰减明显） | 无上限（>攻击力=刮痧） |")

    output.append("")
    output.append("### 1.2 攻击类型 × 护甲类型 倍率系统\n")

    # 显示倍率表
    header = "| 攻击类型 \\ 护甲类型 | " + " | ".join(f"{t}" for t in ARMOR_TYPES) + " |"
    sep = "|---" * (len(ARMOR_TYPES) + 1) + "|"
    output.append(header)
    output.append(sep)
    for atk_type in ["Normal", "Piercing", "Siege", "Magic", "Chaos", "Spells"]:
        row = f"| {atk_type} "
        for arm_type in ARMOR_TYPES:
            mult = ATTACK_TYPE_TABLE[atk_type][arm_type]
            row += f"| {mult:.2f} "
        row += "|"
        output.append(row)

    output.append("")
    output.append("**克制关系解读：**")
    output.append("- **Piercing vs Light = 200%**：穿刺克轻甲，弓箭手/火枪手是轻甲杀手")
    output.append("- **Siege vs Fortified = 150%**：攻城克城甲，拆建筑专用")
    output.append("- **Magic vs Heavy = 200%**：魔法克重甲，法师/狮鹫/冰龙克制大G/骑士")
    output.append("- **Piercing vs Fortified = 35%**：穿刺打城甲极低效")
    output.append("- **Siege vs Medium = 50%**：攻城打中甲只有一半伤害")
    output.append("- **Chaos = 全100%**：混乱攻击无视护甲类型（英雄/召唤物）")

    # ============================================================
    # 第二部分：单位性价比分析
    # ============================================================
    output.append("\n---\n")
    output.append("## 2. 单位性价比分析\n")

    output.append("### 2.1 战斗单位面板对比\n")

    # 计算 DPS 和性价比
    unit_metrics = []
    for name, u in UNITS.items():
        if u["damage"] == 0:
            continue
        dps = u["damage"] / u["cd"]
        hp_dps = u["hp"] * dps
        cost_total = u["cost_g"] + u["cost_l"] * 0.5  # 木材价值约等于黄金的 0.5 倍
        efficiency = hp_dps / cost_total if cost_total > 0 else 0
        unit_metrics.append((name, u["race"], u["tier"], u["role"], u["hp"], dps, u["armor"], u["armor_type"], u["cost_g"], u["cost_l"], u["supply"], efficiency, hp_dps))

    output.append("| 单位 | 种族 | Tier | 定位 | HP | DPS | 护甲 | 造价(G/L) | 人口 | HP×DPS/造价 |")
    output.append("|------|------|------|------|----|-----|------|----------|------|------------|")

    # Sort by tier then race
    tier_order = {"T1": 0, "T2": 1, "T3": 2}
    race_order = {"Human": 0, "Orc": 1, "Undead": 2, "Night Elf": 3}
    unit_metrics.sort(key=lambda x: (tier_order.get(x[2], 9), race_order.get(x[1], 9)))

    for name, race, tier, role, hp, dps, armor, arm_type, cost_g, cost_l, supply, eff, hp_dps in unit_metrics:
        output.append(f"| {name} | {race} | {tier} | {role} | {hp} | {dps:.1f} | {armor}({arm_type}) | {cost_g}/{cost_l} | {supply} | {eff:.2f} |")

    output.append("")
    output.append("### 2.2 种族性价比均值\n")

    race_eff = {}
    for name, race, tier, role, hp, dps, armor, arm_type, cost_g, cost_l, supply, eff, hp_dps in unit_metrics:
        if race not in race_eff:
            race_eff[race] = {"effs": [], "hp_mean": [], "dps_mean": []}
        race_eff[race]["effs"].append(eff)
        race_eff[race]["hp_mean"].append(hp)
        race_eff[race]["dps_mean"].append(dps)

    output.append("| 种族 | 单位数 | 平均HP | 平均DPS | 平均性价比 | 最低性价比 | 最高性价比 |")
    output.append("|------|--------|--------|---------|-----------|-----------|-----------|")
    for race in ["Human", "Orc", "Undead", "Night Elf"]:
        if race in race_eff:
            d = race_eff[race]
            avg_eff = sum(d["effs"]) / len(d["effs"])
            avg_hp = sum(d["hp_mean"]) / len(d["hp_mean"])
            avg_dps = sum(d["dps_mean"]) / len(d["dps_mean"])
            output.append(f"| {race} | {len(d['effs'])} | {avg_hp:.0f} | {avg_dps:.1f} | {avg_eff:.2f} | {min(d['effs']):.2f} | {max(d['effs']):.2f} |")

    # ============================================================
    # 第三部分：Tier 血量梯度
    # ============================================================
    output.append("\n---\n")
    output.append("## 3. Tier 血量梯度\n")

    tier_hp = {}
    for name, u in UNITS.items():
        tier = u["tier"]
        if tier not in tier_hp:
            tier_hp[tier] = {"Human": [], "Orc": [], "Undead": [], "Night Elf": []}
        tier_hp[tier][u["race"]].append(u["hp"])

    output.append("| Tier | Human | Orc | Undead | Night Elf | 区间 |")
    output.append("|------|-------|-----|--------|-----------|------|")
    for tier in ["T1", "T2", "T3"]:
        all_hp = []
        row = f"| {tier} "
        for race in ["Human", "Orc", "Undead", "Night Elf"]:
            hps = tier_hp[tier][race]
            if hps:
                avg = sum(hps) / len(hps)
                row += f"| {avg:.0f} ({min(hps)}-{max(hps)}) "
            else:
                row += "| — "
            all_hp.extend(hps)
        row += f"| {min(all_hp)}-{max(all_hp)} |"
        output.append(row)

    # ============================================================
    # 第四部分：英雄系统分析
    # ============================================================
    output.append("\n---\n")
    output.append("## 4. 英雄系统分析\n")

    output.append("### 4.1 英雄属性分布\n")

    output.append("| 英雄 | 种族 | 类型 | 主属性 | 初始HP | 初始魔 | 力量 | 敏捷 | 智力 | 成长(力/敏/智) |")
    output.append("|------|------|------|--------|--------|--------|------|------|------|---------------|")
    for name, h in HEROES.items():
        output.append(f"| {name} | {h['race']} | {h['type']} | {h['primary']} | {h['hp']} | {h['mana']} | {h['str']} | {h['agi']} | {h['int']} | — |")

    output.append("")
    output.append("### 4.2 种族英雄分布\n")

    race_heroes = {}
    for name, h in HEROES.items():
        race_heroes.setdefault(h["race"], []).append(name)

    for race in ["Human", "Orc", "Undead", "Night Elf"]:
        heroes_list = race_heroes.get(race, [])
        types = [HEROES[h]["type"] for h in heroes_list]
        output.append(f"- **{race}**: {', '.join(heroes_list)}")
        output.append(f"  - 定位: {', '.join(types)}")

    output.append("")
    output.append("### 4.3 英雄技能价值评估\n")

    # Key hero skill DPS calculations
    hero_skills = [
        ("大法师 · 暴风雪", "75/100/125魔", "4波×40/60/80范围伤害", "约 26.7/40/53.3 DPS (6s CD)", "Human"),
        ("山丘之王 · 风暴之锤", "75魔", "单体 100/200/300 + 晕眩2/3/4s", "12.5/25/37.5 DPS + 控制", "Human"),
        ("剑圣 · 致命一击", "被动", "15%/20%/25% 几率 2/3/4倍", "等效 +15%/40%/75% 平均DPS", "Orc"),
        ("牛头人酋长 · 耐久光环", "被动", "移速+10/20/30%, 攻速+5/10/15%", "等效全队 +5/10/15% DPS", "Orc"),
        ("死亡骑士 · 死亡缠绕", "75/50/25魔", "单体 100/200/300 伤害/治疗", "20/40/60 DPS (5s CD)", "Undead"),
        ("巫妖 · 霜冻新星", "100/125/150魔", "范围 100/200/300 + 减速", "12.5/25/37.5 DPS + AOE", "Undead"),
        ("恶魔猎手 · 献祭", "35/55/75魔/秒", "范围每秒 10/17/26 伤害", "10/17/26 DPS AOE (开关)", "Night Elf"),
        ("月之女祭司 · 强击光环", "被动", "远程伤害 +10/20/30%", "等效全队远程 +10/20/30% DPS", "Night Elf"),
    ]

    output.append("| 英雄 · 技能 | 耗魔 | 效果 | 等效DPS/价值 | 种族 |")
    output.append("|-----------|------|------|------------|------|")
    for name, cost, effect, dps_val, race in hero_skills:
        output.append(f"| {name} | {cost} | {effect} | {dps_val} | {race} |")

    output.append("")
    output.append("**英雄系统设计规律：**")
    output.append("1. **英雄是战术核心** — 英雄技能决定种族战术方向（Human 光环推进、Orc 正面碾压、Undead 英雄秒杀、NE 游击消耗）")
    output.append("2. **3+1技能结构** — 3个基础技能（1-3-5级学习）+ 1个终极技能（6级），形成清晰的成长曲线")
    output.append("3. **主属性决定定位** — Str→HP高/近战坦克，Agi→DPS高/刺客，Int→魔法爆发/辅助")
    output.append("4. **光环类技能价值极高** — 被动覆盖全队，不受魔法/冷却限制")
    output.append("5. **终极技能都是改变战局的存在** — 复活、群星坠落、剑刃风暴、天神下凡等")

    # ============================================================
    # 第五部分：种族设计对比
    # ============================================================
    output.append("\n---\n")
    output.append("## 5. 四族设计对比\n")

    output.append("| 维度 | Human | Orc | Undead | Night Elf |")
    output.append("|------|-------|-----|--------|-----------|")
    output.append("| 设计哲学 | 防守反击科技压制 | 正面碾压狂暴压制 | 腐化侵蚀亡灵海啸 | 灵动诡变自然之力 |")
    output.append("| 经济特征 | 开矿最易，民兵协助 | 单矿最优，开矿难 | 腐地免费扩张 | 夜间隐身采矿 |")
    output.append("| T1强度 | 中（步兵420HP） | 最高（大G 700HP） | 中（食尸鬼330HP） | 低（弓箭手245HP） |")
    output.append("| T2强度 | 法师体系（最强T2） | 嗜血+狼骑（控制） | 雕像+毁灭者（极强） | 熊鹿组合（万金油） |")
    output.append("| T3强度 | 骑士+狮鹫 | 牛头人+嗜血 | 冰龙+毁灭者 | 奇美拉+山岭 |")
    output.append("| 机动性 | 慢（靠控制弥补） | 最快（全族高移速） | 快（DK光环） | 快（基础移速高） |")
    output.append("| 法师体系 | 最强（牧师+女巫+破法） | 中等（萨满+巫医） | 中等（女妖+亡灵法师） | 中等（熊+鸟德） |")
    output.append("| 开矿难度 | 最易（民兵+塔） | 最难 | 中等（腐地限制） | 较易（古树防守） |")
    output.append("| 侦察能力 | 中等（水元素/直升机） | 最强（透视/疾风步） | 强（阴影 $50） | 中等（猫头鹰） |")
    output.append("| 强势期 | T2法师成型 | T1大G全程 | T2雕像毁灭者 | 夜间+熊鹿 |")

    # ============================================================
    # 第六部分：TTK 击杀时间矩阵（示例）
    # ============================================================
    output.append("\n---\n")
    output.append("## 6. TTK 击杀时间矩阵（关键单位）\n")

    # Select key units for TTK
    key_units = ["Footman", "Grunt", "Ghoul", "Archer", "Knight", "Tauren", "Frost Wyrm", "Abomination"]
    key_data = {name: UNITS[name] for name in key_units if name in UNITS}

    output.append("### 攻击者 vs 防御者 TTK（秒）\n")
    output.append("| 攻击者 \\ 防御者 | " + " | ".join(key_units) + " |")
    output.append("|---" * (len(key_units) + 1) + "|")

    for atk_name in ["Rifleman", "Grunt", "Crypt Fiend", "Knight", "Tauren", "Frost Wyrm", "Chimaera"]:
        if atk_name not in UNITS:
            continue
        atk = UNITS[atk_name]
        atk_dps = atk["damage"] / atk["cd"]

        row = f"| {atk_name} "
        for def_name in key_units:
            if def_name not in UNITS:
                row += "| — "
                continue
            defender = UNITS[def_name]
            # 实际伤害 = 攻击 × 类型倍率 × (1 - 护甲减免)
            type_mult = ATTACK_TYPE_TABLE.get(atk["atk_type"], {}).get(defender["armor_type"], 1.0)
            reduction = armor_damage_reduction(defender["armor"])
            actual_dps = atk_dps * type_mult * (1 - reduction)

            if actual_dps > 0:
                ttk = defender["hp"] / actual_dps
            else:
                ttk = float('inf')
            row += f"| {ttk:.1f} " if ttk != float('inf') else "| ∞ "
        row += "|"
        output.append(row)

    output.append("")
    output.append("**TTK 分析：**")
    output.append("- Rifleman（穿刺）打 Archer（中甲）：无倍率加成，但 Archer 血薄 → 较快击杀")
    output.append("- Grunt（普通）打 Footman（重甲）：同类型，靠高 HP 和 DPS 优势")
    output.append("- Frost Wyrm（魔法）打 Tauren（重甲）：Magic vs Heavy = 200%，极快击杀")
    output.append("- Chimaera（魔法）打 Archer（中甲）：Magic vs Medium = 75%，效率低")

    # ============================================================
    # 第七部分：对本项目的启示
    # ============================================================
    output.append("\n---\n")
    output.append("## 7. 对本项目的启示\n")

    output.append("### 7.1 伤害公式选择\n")
    output.append("")
    output.append("| 公式类型 | 优点 | 缺点 | 适合场景 |")
    output.append("|---------|------|------|---------|")
    output.append("| 减法公式（SC2） | 简单直观，护甲线性收益 | 高甲对低伤单位极度克制 | DPS 差异大的游戏 |")
    output.append("| 百分比减免（WC3） | 护甲收益递减，平衡性更好 | 计算复杂，需要乘法运算 | 护甲范围大的游戏 |")
    output.append("| 攻击类型倍率（WC3） | 丰富的克制关系，战术深度 | 需要玩家记忆倍率表 | 兵种类型多的游戏 |")

    output.append("")
    output.append("### 7.2 英雄系统设计\n")
    output.append("")
    output.append("1. **3+1 技能结构** — 3个基础技能 + 1个终极技能，6级解锁终极")
    output.append("2. **主属性系统** — Str/Agi/Int 三属性决定英雄定位")
    output.append("3. **光环技能** — 被动覆盖全队，低操作高回报")
    output.append("4. **英雄是战术核心** — 英雄技能决定整体战术方向")

    output.append("")
    output.append("### 7.3 种族差异化设计\n")
    output.append("")
    output.append("1. **四族经济差异**：开矿成本、采集效率、资源转换各有不同")
    output.append("2. **Tier 强度曲线**：各族的强势期错开（Orc T1最强，Human T2最强，Undead T2-T3过渡最强）")
    output.append("3. **签名机制**：民兵/嗜血/腐地/隐身 — 每个种族有独特的不可交易优势")
    output.append("4. **反制关系**：每个种族都有明确的弱点和反制方式")

    result = "\n".join(output)

    output_path = "e:/godot/rts/godot_rts_start/docs/reference/research/魔兽争霸3数值逆向工程分析.md"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(result)
    print(f"[OK] WC3 分析已写入: {output_path}")

    print(f"\n[DATA] 关键数据摘要:")
    print(f"   - 分析了 {len(UNITS)} 个单位")
    print(f"   - 分析了 {len(HEROES)} 个英雄")
    print(f"   - 计算了 {len(key_units)}×{len([k for k in key_units if k in UNITS])} TTK 矩阵")
    print(f"   - 覆盖 4 个种族的全 Tier 对比")


if __name__ == "__main__":
    main()
