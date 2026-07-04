# -*- coding: utf-8 -*-
"""
RTS 战斗节奏数值设计计算器
从目标 TTK 反推 HP / DPS / 护甲 / 克制倍率
"""

import math

# ============================================================
# 1. 设计目标
# ============================================================
# 核心目标：T1 vs T1 的 TTK ≈ 10 秒
# Tier 跨度：T1→T2→T3 逐步增强

DESIGN_GOALS = {
    "t1_vs_t1": 10,      # T1 vs T1: 10秒击杀 —— 基准
    "t2_vs_t1": 6,       # T2 vs T1: 6秒（高级兵秒低级兵快一点）
    "t1_vs_t2": 18,      # T1 vs T2: 18秒（低级兵打高级兵很慢）
    "t3_vs_t1": 3,       # T3 vs T1: 3秒（碾压）
    "t1_vs_t3": 30,      # T1 vs T3: 30秒（几乎打不动）
    "t2_vs_t2": 12,      # T2 vs T2: 12秒（比T1稍慢，因为血厚了）
    "t3_vs_t3": 15,      # T3 vs T3: 15秒（重甲互殴）
}

# ============================================================
# 2. 参数搜索范围
# ============================================================

# 伤害公式选择：减法公式（SC2风格）
# 实际伤害/次 = max(damage_per_hit - target_armor, 最小伤害)
# DPS = 实际伤害/次 / cooldown
# TTK = HP / DPS

# T1 基准参数搜索空间
T1_HP_RANGE = list(range(50, 151, 10))        # 50-150 HP
T1_DMG_RANGE = list(range(6, 21, 2))          # 6-20 伤害/次
T1_CD_RANGE = [0.8, 1.0, 1.2, 1.5]           # 攻击间隔（秒）
T1_ARMOR_RANGE = [0, 1, 2, 3]                 # 护甲
MIN_DAMAGE = 1                                 # 最小伤害（防止无限刮痧）


def compute_ttk(hp, damage, cooldown, armor, min_dmg=1):
    """计算击杀时间（秒）"""
    actual_dmg_per_hit = max(damage - armor, min_dmg)
    if cooldown <= 0:
        return float('inf')
    dps = actual_dmg_per_hit / cooldown
    if dps <= 0:
        return float('inf')
    return hp / dps


def hits_to_kill(hp, damage, armor, min_dmg=1):
    """计算击杀所需攻击次数"""
    actual_dmg = max(damage - armor, min_dmg)
    if actual_dmg <= 0:
        return float('inf')
    return math.ceil(hp / actual_dmg)


# ============================================================
# 3. 搜索 T1 基准参数
# ============================================================
print("=" * 70)
print("【1】T1 基准参数搜索 — 目标 TTK = 10s")
print("=" * 70)

candidates = []
for hp in T1_HP_RANGE:
    for dmg in T1_DMG_RANGE:
        for cd in T1_CD_RANGE:
            for armor in T1_ARMOR_RANGE:
                ttk = compute_ttk(hp, dmg, cd, armor)
                if 8.5 <= ttk <= 11.5:  # 容忍 ±1.5s
                    hits = hits_to_kill(hp, dmg, armor)
                    dps = (max(dmg - armor, MIN_DAMAGE)) / cd
                    candidates.append((hp, dmg, cd, armor, ttk, hits, dps))

# 按 TTK 排序
candidates.sort(key=lambda x: abs(x[4] - 10))

print(f"找到 {len(candidates)} 组参数（TTK 8.5-11.5s）：")
print(f"\n{'HP':<6}{'伤害':<6}{'CD':<6}{'护甲':<6}{'TTK':<8}{'击中数':<8}{'DPS':<8}{'评估'}")
print("-" * 70)

# 只显示前 20 组最佳匹配
for hp, dmg, cd, armor, ttk, hits, dps in candidates[:20]:
    # 评估：击中数 5-15 次比较合理
    if 4 <= hits <= 12:
        assessment = "[OK]"
    elif hits < 4:
        assessment = "太少刀"
    else:
        assessment = "太多刀"
    print(f"{hp:<6}{dmg:<6}{cd:<6}{armor:<6}{ttk:<8.2f}{hits:<8}{dps:<8.2f}{assessment}")

# ============================================================
# 4. 推荐 T1 基准组合
# ============================================================
print("\n" + "=" * 70)
print("【2】推荐 T1 基准组合")
print("=" * 70)

# 我手动选几组合理组合
recommended = [
    # (name, hp, damage, cd, armor)
    ("近战轻甲兵", 80, 10, 1.0, 0),
    ("近战重甲兵", 100, 8, 1.0, 2),
    ("远程脆皮兵", 60, 12, 1.0, 0),
    ("远程标准兵", 75, 10, 1.1, 0),
    ("近战肉盾兵", 120, 8, 1.2, 2),
    ("刺客型兵", 65, 14, 1.0, 0),
]

print(f"\n{'兵种类型':<14}{'HP':<6}{'伤害':<6}{'CD':<8}{'护甲':<6}{'DPS':<8}{'TTK(自打)':<10}{'TTK(打0甲)':<10}{'TTK(打2甲)':<10}{'击中数(自打)'}")
print("-" * 100)
for name, hp, dmg, cd, armor in recommended:
    ttk_self = compute_ttk(hp, dmg, cd, armor)
    ttk_vs0 = compute_ttk(hp, dmg, cd, 0)
    ttk_vs2 = compute_ttk(hp, dmg, cd, 2)
    hits_self = hits_to_kill(hp, dmg, armor)
    dps = max(dmg - armor, MIN_DAMAGE) / cd
    print(f"{name:<14}{hp:<6}{dmg:<6}{cd:<8.2f}{armor:<6}{dps:<8.2f}{ttk_self:<10.2f}{ttk_vs0:<10.2f}{ttk_vs2:<10.2f}{hits_self:<6}")

# ============================================================
# 5. Tier 跨度设计
# ============================================================
print("\n" + "=" * 70)
print("【3】Tier 跨度设计 — 从 T1 基准外推")
print("=" * 70)

# 选定一组 T1 基准：HP=80, DMG=10, CD=1.0, ARMOR=0
BASE_T1 = {"hp": 80, "dmg": 10, "cd": 1.0, "armor": 0, "name": "T1标准步兵"}

# Tier 跨度系数（可调）
TIER_SCALE = {
    "T1": {"hp_mul": 1.0, "dmg_mul": 1.0, "armor_bonus": 0},
    "T2": {"hp_mul": 1.8, "dmg_mul": 1.4, "armor_bonus": 1},
    "T3": {"hp_mul": 3.0, "dmg_mul": 1.8, "armor_bonus": 2},
}

print(f"\n基准单位: {BASE_T1['name']} (HP={BASE_T1['hp']}, DMG={BASE_T1['dmg']}, CD={BASE_T1['cd']}, ARMOR={BASE_T1['armor']})")
print(f"\nTier 跨度系数:")
for tier, s in TIER_SCALE.items():
    print(f"  {tier}: HP x{s['hp_mul']}, DMG x{s['dmg_mul']}, 额外护甲 +{s['armor_bonus']}")

# 计算各 Tier 属性
tier_stats = {}
for tier, s in TIER_SCALE.items():
    stats = {
        "hp": round(BASE_T1["hp"] * s["hp_mul"]),
        "dmg": round(BASE_T1["dmg"] * s["dmg_mul"]),
        "cd": BASE_T1["cd"],
        "armor": BASE_T1["armor"] + s["armor_bonus"],
    }
    tier_stats[tier] = stats

print(f"\n{'Tier':<6}{'HP':<8}{'伤害':<8}{'CD':<8}{'护甲':<8}{'DPS':<8}")
print("-" * 50)
for tier, s in TIER_SCALE.items():
    st = tier_stats[tier]
    dps = max(st["dmg"] - st["armor"], MIN_DAMAGE) / st["cd"]
    print(f"{tier:<6}{st['hp']:<8}{st['dmg']:<8}{st['cd']:<8.2f}{st['armor']:<8}{dps:<8.2f}")

# ============================================================
# 6. TTK 矩阵验证
# ============================================================
print("\n" + "=" * 70)
print("【4】TTK 矩阵验证 — 各 Tier 互打")
print("=" * 70)

print(f"\n{'攻击者\\防御者':<16}", end="")
for t in ["T1", "T2", "T3"]:
    print(f"{t:<16}", end="")
print()

for atk_tier in ["T1", "T2", "T3"]:
    print(f"{atk_tier:<16}", end="")
    for def_tier in ["T1", "T2", "T3"]:
        atk = tier_stats[atk_tier]
        defe = tier_stats[def_tier]
        ttk = compute_ttk(defe["hp"], atk["dmg"], atk["cd"], defe["armor"])
        status = "[OK]" if abs(ttk - DESIGN_GOALS.get(f"{atk_tier.lower()}_vs_{def_tier.lower()}", 10)) <= 5 else ""
        print(f"{ttk:<8.2f}  {status:<8}", end="")
    print()

# 打印目标 vs 实际
print(f"\n{' matchup':<16}{'目标TTK':<10}{'实际TTK':<10}{'偏差':<10}")
print("-" * 50)
for matchup, goal in DESIGN_GOALS.items():
    parts = matchup.split("_vs_")
    if len(parts) == 2:
        atk_tier = parts[0].upper()
        def_tier = parts[1].upper()
        if atk_tier in tier_stats and def_tier in tier_stats:
            atk = tier_stats[atk_tier]
            defe = tier_stats[def_tier]
            actual = compute_ttk(defe["hp"], atk["dmg"], atk["cd"], defe["armor"])
            diff = actual - goal
            print(f" {matchup:<16}{goal:<10}{actual:<10.2f}{diff:<+10.2f}")

# ============================================================
# 7. 克制关系设计
# ============================================================
print("\n" + "=" * 70)
print("【5】克制关系设计 — 引入攻击类型倍率")
print("=" * 70)

# 设计 3 种护甲类型 × 3 种攻击类型的克制矩阵
# 目标：克制时 TTK 减半（×2伤害），被克制时 TTK 加倍（×0.5伤害）

ARMOR_CLASSES = ["轻甲", "中甲", "重甲"]
ATK_CLASSES = ["普通", "穿刺", "魔法"]

# 克制矩阵：行=攻击类型，列=护甲类型
COUNTER_MATRIX = {
    "普通": {"轻甲": 1.0, "中甲": 1.0, "重甲": 1.0},  # 万金油
    "穿刺": {"轻甲": 1.5, "中甲": 1.0, "重甲": 0.75}, # 克轻甲，被重甲抗
    "魔法": {"轻甲": 0.75, "中甲": 1.0, "重甲": 1.5}, # 克重甲，被轻甲抗
}

print(f"\n伤害倍率矩阵（行=攻击类型，列=护甲类型）：")
print(f"{'攻击\\护甲':<10}", end="")
for ac in ARMOR_CLASSES:
    print(f"{ac:<10}", end="")
print()
print("-" * 40)
for atk in ATK_CLASSES:
    print(f"{atk:<10}", end="")
    for ac in ARMOR_CLASSES:
        print(f"{COUNTER_MATRIX[atk][ac]:<10.2f}", end="")
    print()

# 引入克制后 TTK 的变化
print(f"\n引入克制后 TTK 变化（以 T1 标准步兵 HP=80, DMG=10, CD=1.0, ARMOR=0 为例）：")
print(f"{'攻击类型':<10}{'目标护甲':<10}{'倍率':<8}{'实际DPS':<10}{'TTK':<10}")
print("-" * 50)

for atk in ATK_CLASSES:
    for ac in ARMOR_CLASSES:
        mult = COUNTER_MATRIX[atk][ac]
        # 假设攻击者对目标 armor=0
        base_dps = 10 / 1.0  # DMG/CD
        actual_dps = base_dps * mult
        ttk = 80 / actual_dps
        print(f"{atk:<10}{ac:<10}{mult:<8.2f}{actual_dps:<10.2f}{ttk:<10.2f}")

# ============================================================
# 8. 最终推荐数值方案
# ============================================================
print("\n" + "=" * 70)
print("【6】推荐数值方案")
print("=" * 70)

# 基于以上分析，给出三套方案
schemes = {
    "方案A - 均衡型": {
        "description": "SC2 风格的减法公式，T1 TTK ≈ 10s",
        "formula": "减法：实际伤害 = max(攻击力 - 护甲, 1)",
        "t1_hp": 80,
        "t1_dmg": 10,
        "t1_cd": 1.0,
        "t1_armor": 0,
        "t2_hp": 150,
        "t2_dmg": 14,
        "t2_cd": 1.0,
        "t2_armor": 1,
        "t3_hp": 250,
        "t3_dmg": 18,
        "t3_cd": 1.0,
        "t3_armor": 2,
        "克制类型": "3 种护甲 × 3 种攻击",
        "护甲范围": "0-5",
    },
    "方案B - 重甲版": {
        "description": "护甲更有存在感，T1 肉盾 TTK ≈ 12s",
        "formula": "减法：实际伤害 = max(攻击力 - 护甲, 1)",
        "t1_hp": 100,
        "t1_dmg": 10,
        "t1_cd": 1.0,
        "t1_armor": 1,
        "t2_hp": 200,
        "t2_dmg": 14,
        "t2_cd": 1.0,
        "t2_armor": 2,
        "t3_hp": 350,
        "t3_dmg": 20,
        "t3_cd": 1.0,
        "t3_armor": 3,
        "克制类型": "轻甲/重甲 2 类 + bonus_vs",
        "护甲范围": "0-6",
    },
    "方案C - 快节奏版": {
        "description": "更快节奏，T1 TTK ≈ 7s",
        "formula": "减法：实际伤害 = max(攻击力 - 护甲, 1)",
        "t1_hp": 60,
        "t1_dmg": 10,
        "t1_cd": 1.0,
        "t1_armor": 0,
        "t2_hp": 110,
        "t2_dmg": 14,
        "t2_cd": 1.0,
        "t2_armor": 1,
        "t3_hp": 180,
        "t3_dmg": 18,
        "t3_cd": 1.0,
        "t3_armor": 2,
        "克制类型": "3×3 克制矩阵",
        "护甲范围": "0-5",
    },
}

for scheme_name, s in schemes.items():
    print(f"\n{'='*50}")
    print(f"  {scheme_name}")
    print(f"  {s['description']}")
    print(f"{'='*50}")
    print(f"  伤害公式: {s['formula']}")
    print(f"  克制系统: {s['克制类型']}")
    print(f"  护甲范围: {s['护甲范围']}")
    print()
    print(f"  {'Tier':<8}{'HP':<8}{'伤害':<8}{'CD':<10}{'护甲':<8}{'DPS':<10}{'自打TTK':<10}")
    print(f"  {'-'*60}")

    for tier in ["T1", "T2", "T3"]:
        hp = s[f"{tier.lower()}_hp"]
        dmg = s[f"{tier.lower()}_dmg"]
        cd = s[f"{tier.lower()}_cd"]
        armor = s[f"{tier.lower()}_armor"]
        dps = max(dmg - armor, 1) / cd
        ttk_self = compute_ttk(hp, dmg, cd, armor)
        print(f"  {tier:<8}{hp:<8}{dmg:<8}{cd:<10.2f}{armor:<8}{dps:<10.2f}{ttk_self:<10.2f}")

    # TTK 矩阵
    print(f"\n  TTK 矩阵：")
    print(f"  {'攻击者\\防御者':<16}", end="")
    for t in ["T1", "T2", "T3"]:
        print(f"{t:<14}", end="")
    print()
    for atk_tier in ["T1", "T2", "T3"]:
        print(f"  {atk_tier:<16}", end="")
        for def_tier in ["T1", "T2", "T3"]:
            hp = s[f"{def_tier.lower()}_hp"]
            dmg = s[f"{atk_tier.lower()}_dmg"]
            cd = s[f"{atk_tier.lower()}_cd"]
            armor = s[f"{def_tier.lower()}_armor"]
            ttk = compute_ttk(hp, dmg, cd, armor)
            print(f"{ttk:<14.2f}", end="")
        print()

    # 每秒击中数
    print(f"\n  击中数（击杀所需攻击次数）：")
    print(f"  {'攻击者\\防御者':<16}", end="")
    for t in ["T1", "T2", "T3"]:
        print(f"{t:<14}", end="")
    print()
    for atk_tier in ["T1", "T2", "T3"]:
        print(f"  {atk_tier:<16}", end="")
        for def_tier in ["T1", "T2", "T3"]:
            hp = s[f"{def_tier.lower()}_hp"]
            dmg = s[f"{atk_tier.lower()}_dmg"]
            armor = s[f"{def_tier.lower()}_armor"]
            hits = hits_to_kill(hp, dmg, armor)
            print(f"{hits:<14}", end="")
        print()


# ============================================================
# 9. 从 TTK 反推资源消耗
# ============================================================
print("\n" + "=" * 70)
print("【7】从 TTK 反推经济匹配")
print("=" * 70)

# 如果 T1 兵造价 50 资源，TTK 10s
# 那么 10 秒内你能生产多少个兵？
# 假设单矿收入 ~500 资源/分 = ~8.3 资源/秒

INCOME_PER_SEC = 500 / 60  # ~8.3

print(f"\n假设单矿收入: {INCOME_PER_SEC:.1f} 资源/秒")
print(f"假设 T1 兵造价: 50 资源")
print(f"T1 兵生产时间: 15 秒")
print()

for ttk_target in [5, 7, 10, 12, 15]:
    # 一场战斗中，双方投入的兵力价值
    # 在 TTK 秒内，单矿能产出的资源 = INCOME_PER_SEC × TTK
    resources_during_fight = INCOME_PER_SEC * ttk_target
    soldiers_during_fight = resources_during_fight / 50

    print(f"  TTK={ttk_target}s → 单矿 {ttk_target}s 内产出 {resources_during_fight:.0f} 资源 ≈ {soldiers_during_fight:.1f} 个 T1 兵")

print()
print(f"结论：TTK 10s 时，单矿在一场战斗中只能补充 ~1.7 个 T1 兵")
print(f"这意味着战斗胜负主要取决于**已有兵力**，而非战中补充")
print(f"如果要让战中补充有意义，TTK 需要 > 20s 或降低造价/生产时间")

print("\n" + "=" * 70)
print("【8】推荐击中数分析")
print("=" * 70)
print()
print("击中数（Hits to Kill）是比 TTK 更直观的玩家体验指标：")
print()
print(f"{'场景':<20}{'推荐击中数':<14}{'体验':<20}")
print("-" * 55)
print(f"{'T1 打 T1（标准）':<20}{'5-10 刀':<14}{'能看到血量下降，有紧张感':<20}")
print(f"{'T2 打 T1（碾压）':<20}{'3-5 刀':<14}{'快速击杀，体现科技优势':<20}")
print(f"{'T1 打 T2（劣势）':<20}{'12-20 刀':<14}{'刮痧感，应该逃跑':<20}")
print(f"{'T3 打 T1（秒杀）':<20}{'2-3 刀':<14}{'秒杀，终极兵种的威慑力':<20}")
print(f"{'T3 打 T3（重甲）':<20}{'8-15 刀':<14}{'史诗对决':<20}")

# 验证推荐方案中的击中数
print()
print("验证方案A的击中数：")
s = schemes["方案A - 均衡型"]
for atk_tier in ["T1", "T2", "T3"]:
    for def_tier in ["T1", "T2", "T3"]:
        hp = s[f"{def_tier.lower()}_hp"]
        dmg = s[f"{atk_tier.lower()}_dmg"]
        armor = s[f"{def_tier.lower()}_armor"]
        hits = hits_to_kill(hp, dmg, armor)
        ttk = compute_ttk(hp, dmg, s[f"{atk_tier.lower()}_cd"], armor)
        print(f"  {atk_tier}→{def_tier}: {hits}刀, TTK={ttk:.1f}s")
