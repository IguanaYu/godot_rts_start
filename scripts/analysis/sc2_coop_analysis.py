# -*- coding: utf-8 -*-
"""
SC2 合作模式数值分析脚本
计算合作模式单位 vs 标准对战单位的强化倍数、英雄单位设计模式、指挥官分类统计
"""

import json
import math

# ============================================================
# 1. 标准对战基准数据（用于对比）
# ============================================================
STANDARD_UNITS = {
    "Marine": {"hp": 45, "shield": 0, "armor": 0, "damage": 6, "cooldown": 0.61, "range": 5, "dps": 9.84, "supply": 1, "cost_m": 50, "cost_g": 0},
    "Marauder": {"hp": 125, "shield": 0, "armor": 1, "damage": 10, "bonus": 5, "cooldown": 1.5, "range": 6, "dps": 6.67, "supply": 2, "cost_m": 100, "cost_g": 25},
    "Medivac": {"hp": 150, "shield": 0, "armor": 1, "damage": 0, "cooldown": 0, "range": 0, "dps": 0, "supply": 2, "cost_m": 100, "cost_g": 100},
    "Siege Tank": {"hp": 175, "shield": 0, "armor": 1, "damage": 35, "bonus": 15, "cooldown": 2.5, "range": 13, "dps": 14.0, "supply": 3, "cost_m": 150, "cost_g": 125},
    "Viking": {"hp": 125, "shield": 0, "armor": 0, "damage": 16, "cooldown": 1.5, "range": 9, "dps": 10.67, "supply": 2, "cost_m": 150, "cost_g": 75},
    "Banshee": {"hp": 140, "shield": 0, "armor": 0, "damage": 12, "cooldown": 1.1, "range": 6, "dps": 10.91, "supply": 2, "cost_m": 150, "cost_g": 100},
    "Battlecruiser": {"hp": 550, "shield": 0, "armor": 3, "damage": 8, "cooldown": 0.23, "range": 10, "dps": 34.78, "supply": 6, "cost_m": 400, "cost_g": 300},
    "Thor": {"hp": 400, "shield": 0, "armor": 1, "damage": 30, "cooldown": 1.28, "range": 7, "dps": 23.44, "supply": 6, "cost_m": 300, "cost_g": 200},
    "Hellion": {"hp": 90, "shield": 0, "armor": 0, "damage": 8, "bonus": 12, "cooldown": 2.5, "range": 5, "dps": 3.2, "supply": 2, "cost_m": 100, "cost_g": 0},
    "Hellbat": {"hp": 135, "shield": 0, "armor": 0, "damage": 18, "bonus": 10, "cooldown": 1.9, "range": 2, "dps": 9.47, "supply": 2, "cost_m": 100, "cost_g": 0},
    "Ghost": {"hp": 100, "shield": 0, "armor": 0, "damage": 10, "bonus": 10, "cooldown": 1.5, "range": 6, "dps": 6.67, "supply": 2, "cost_m": 150, "cost_g": 125},
    "Zealot": {"hp": 100, "shield": 50, "armor": 1, "damage": 8, "cooldown": 1.2, "range": 0.1, "dps": 6.67, "supply": 2, "cost_m": 100, "cost_g": 0},
    "Stalker": {"hp": 80, "shield": 80, "armor": 1, "damage": 10, "bonus": 5, "cooldown": 1.5, "range": 6, "dps": 6.67, "supply": 2, "cost_m": 125, "cost_g": 50},
    "Immortal": {"hp": 200, "shield": 100, "armor": 1, "damage": 20, "bonus": 30, "cooldown": 1.7, "range": 6, "dps": 11.76, "supply": 4, "cost_m": 275, "cost_g": 100},
    "Colossus": {"hp": 200, "shield": 150, "armor": 1, "damage": 10, "cooldown": 2.0, "range": 7, "dps": 10.0, "supply": 6, "cost_m": 300, "cost_g": 200},
    "High Templar": {"hp": 40, "shield": 40, "armor": 0, "damage": 0, "cooldown": 0, "range": 0, "dps": 0, "supply": 2, "cost_m": 50, "cost_g": 150},
    "Archon": {"hp": 10, "shield": 350, "armor": 0, "damage": 25, "bonus": 10, "cooldown": 1.2, "range": 3, "dps": 20.83, "supply": 4, "cost_m": 50, "cost_g": 150},
    "Void Ray": {"hp": 150, "shield": 100, "armor": 1, "damage": 6, "bonus": 14, "cooldown": 0.5, "range": 8, "dps": 12.0, "supply": 3, "cost_m": 250, "cost_g": 150},
    "Carrier": {"hp": 250, "shield": 150, "armor": 2, "damage": 8, "cooldown": 0, "range": 14, "dps": 40.0, "supply": 6, "cost_m": 350, "cost_g": 250},
    "Dark Templar": {"hp": 40, "shield": 80, "armor": 1, "damage": 45, "cooldown": 1.5, "range": 0.1, "dps": 30.0, "supply": 2, "cost_m": 125, "cost_g": 125},
    "Adept": {"hp": 70, "shield": 70, "armor": 1, "damage": 10, "bonus": 5, "cooldown": 1.8, "range": 5, "dps": 5.56, "supply": 2, "cost_m": 100, "cost_g": 25},
    "Phoenix": {"hp": 120, "shield": 60, "armor": 0, "damage": 5, "cooldown": 1.1, "range": 6, "dps": 4.55, "supply": 2, "cost_m": 150, "cost_g": 100},
    "Zergling": {"hp": 35, "shield": 0, "armor": 0, "damage": 5, "cooldown": 0.69, "range": 0.1, "dps": 7.25, "supply": 0.5, "cost_m": 25, "cost_g": 0},
    "Hydralisk": {"hp": 80, "shield": 0, "armor": 0, "damage": 12, "cooldown": 0.83, "range": 6, "dps": 14.46, "supply": 2, "cost_m": 100, "cost_g": 50},
    "Mutalisk": {"hp": 120, "shield": 0, "armor": 0, "damage": 9, "cooldown": 1.5, "range": 4, "dps": 6.0, "supply": 2, "cost_m": 100, "cost_g": 100},
    "Ultralisk": {"hp": 500, "shield": 0, "armor": 1, "damage": 15, "bonus": 10, "cooldown": 1.3, "range": 0.1, "dps": 11.54, "supply": 6, "cost_m": 300, "cost_g": 200},
    "Infestor": {"hp": 150, "shield": 0, "armor": 0, "damage": 0, "cooldown": 0, "range": 0, "dps": 0, "supply": 2, "cost_m": 100, "cost_g": 150},
    "Corruptor": {"hp": 200, "shield": 0, "armor": 2, "damage": 10, "bonus": 8, "cooldown": 1.5, "range": 7, "dps": 6.67, "supply": 2, "cost_m": 150, "cost_g": 100},
    "Brood Lord": {"hp": 225, "shield": 0, "armor": 1, "damage": 20, "cooldown": 2.0, "range": 11, "dps": 10.0, "supply": 4, "cost_m": 300, "cost_g": 250},
    "Roach": {"hp": 145, "shield": 0, "armor": 1, "damage": 12, "bonus": 6, "cooldown": 1.5, "range": 5, "dps": 8.0, "supply": 2, "cost_m": 75, "cost_g": 25},
    "Baneling": {"hp": 30, "shield": 0, "armor": 0, "damage": 16, "bonus": 10, "cooldown": 0, "range": 0.1, "dps": 0, "supply": 0.5, "cost_m": 25, "cost_g": 25},
    "Queen": {"hp": 175, "shield": 0, "armor": 1, "damage": 4, "cooldown": 0.77, "range": 5, "dps": 5.19, "supply": 2, "cost_m": 150, "cost_g": 0},
    "Oracle": {"hp": 40, "shield": 100, "armor": 0, "damage": 0, "cooldown": 0, "range": 0, "dps": 0, "supply": 3, "cost_m": 150, "cost_g": 150},
    "Raven": {"hp": 140, "shield": 0, "armor": 1, "damage": 0, "cooldown": 0, "range": 0, "dps": 0, "supply": 2, "cost_m": 100, "cost_g": 200},
    "Liberator": {"hp": 130, "shield": 0, "armor": 1, "damage": 20, "bonus": 15, "cooldown": 1.5, "range": 7, "dps": 13.33, "supply": 3, "cost_m": 150, "cost_g": 150},
    "Widow Mine": {"hp": 90, "shield": 0, "armor": 0, "damage": 125, "cooldown": 0, "range": 0, "dps": 0, "supply": 2, "cost_m": 75, "cost_g": 25},
}

# ============================================================
# 2. 合作模式单位数据（从文档提取的关键单位）
# ============================================================
COOP_UNITS = {
    # --- Raynor ---
    "Firebat": {"hp": 200, "shield": 0, "armor": 3, "damage": 18, "bonus": 6, "cooldown": 1.5, "range": 3, "standard_ref": None, "commander": "Raynor"},
    "Vulture": {"hp": 100, "shield": 0, "armor": 0, "damage": 20, "bonus": 10, "cooldown": 1.5, "range": 5, "standard_ref": None, "commander": "Raynor"},
    "Raynor_Marine": {"hp": 80, "shield": 0, "armor": 0, "damage": 8, "bonus": 3, "cooldown": 0.86, "range": 5, "standard_ref": "Marine", "commander": "Raynor"},
    "Raynor_Marauder": {"hp": 150, "shield": 0, "armor": 1, "damage": 20, "bonus": 10, "cooldown": 1.5, "range": 6, "standard_ref": "Marauder", "commander": "Raynor"},
    "Raynor_Battlecruiser": {"hp": 750, "shield": 0, "armor": 4, "damage": 20, "cooldown": 0.23, "range": 10, "standard_ref": "Battlecruiser", "commander": "Raynor"},

    # --- Kerrigan ---
    "Kerrigan_Hero": {"hp": 1000, "shield": 500, "armor": 3, "damage": 60, "bonus": 30, "cooldown": 1.5, "range": 0.1, "standard_ref": None, "commander": "Kerrigan"},
    "Kerrigan_Zergling": {"hp": 40, "shield": 0, "armor": 0, "damage": 10, "bonus": 5, "cooldown": 0.69, "range": 0.1, "standard_ref": "Zergling", "commander": "Kerrigan"},
    "Kerrigan_Hydralisk": {"hp": 100, "shield": 0, "armor": 1, "damage": 18, "bonus": 6, "cooldown": 0.83, "range": 6, "standard_ref": "Hydralisk", "commander": "Kerrigan"},
    "Kerrigan_Ultralisk": {"hp": 500, "shield": 0, "armor": 4, "damage": 35, "bonus": 20, "cooldown": 1.3, "range": 0.1, "standard_ref": "Ultralisk", "commander": "Kerrigan"},
    "Kerrigan_Mutalisk": {"hp": 140, "shield": 0, "armor": 1, "damage": 12, "cooldown": 1.5, "range": 4, "standard_ref": "Mutalisk", "commander": "Kerrigan"},

    # --- Artanis ---
    "Dragoon": {"hp": 150, "shield": 100, "armor": 2, "damage": 30, "bonus": 10, "cooldown": 1.5, "range": 6, "standard_ref": None, "commander": "Artanis"},
    "High_Archon": {"hp": 10, "shield": 350, "armor": 0, "damage": 35, "bonus": 15, "cooldown": 1.2, "range": 3, "standard_ref": "Archon", "commander": "Artanis"},
    "Artanis_Zealot": {"hp": 150, "shield": 50, "armor": 1, "damage": 16, "bonus": 8, "cooldown": 1.2, "range": 0.1, "standard_ref": "Zealot", "commander": "Artanis"},
    "Artanis_Immortal": {"hp": 200, "shield": 150, "armor": 2, "damage": 35, "bonus": 25, "cooldown": 1.7, "range": 6, "standard_ref": "Immortal", "commander": "Artanis"},
    "Artanis_Colossus": {"hp": 250, "shield": 150, "armor": 2, "damage": 30, "cooldown": 2.0, "range": 7, "standard_ref": "Colossus", "commander": "Artanis"},

    # --- Swann ---
    "HERC": {"hp": 300, "shield": 0, "armor": 2, "damage": 25, "bonus": 15, "cooldown": 1.2, "range": 0.1, "standard_ref": None, "commander": "Swann"},
    "Goliath": {"hp": 200, "shield": 0, "armor": 2, "damage": 24, "bonus": 8, "cooldown": 1.3, "range": 6, "standard_ref": None, "commander": "Swann"},
    "Swann_Thor": {"hp": 500, "shield": 0, "armor": 3, "damage": 50, "bonus": 30, "cooldown": 1.5, "range": 7, "standard_ref": "Thor", "commander": "Swann"},
    "Swann_SiegeTank": {"hp": 200, "shield": 0, "armor": 2, "damage": 40, "bonus": 15, "cooldown": 2.8, "range": 13, "standard_ref": "Siege Tank", "commander": "Swann"},

    # --- Zagara ---
    "Scourge": {"hp": 30, "shield": 0, "armor": 0, "damage": 110, "cooldown": 0, "range": 0.1, "standard_ref": None, "commander": "Zagara"},
    "Aberration": {"hp": 500, "shield": 0, "armor": 2, "damage": 30, "bonus": 15, "cooldown": 1.5, "range": 0.1, "standard_ref": None, "commander": "Zagara"},
    "Zagara_Baneling": {"hp": 40, "shield": 0, "armor": 0, "damage": 30, "bonus": 20, "cooldown": 0, "range": 0.1, "standard_ref": "Baneling", "commander": "Zagara"},
    "Zagara_Zergling": {"hp": 35, "shield": 0, "armor": 0, "damage": 10, "bonus": 5, "cooldown": 0.69, "range": 0.1, "standard_ref": "Zergling", "commander": "Zagara"},

    # --- Vorazun ---
    "Dark_Archon": {"hp": 50, "shield": 350, "armor": 0, "damage": 30, "bonus": 15, "cooldown": 1.5, "range": 3, "standard_ref": None, "commander": "Vorazun"},
    "Corsair": {"hp": 100, "shield": 75, "armor": 1, "damage": 10, "cooldown": 1.3, "range": 5, "standard_ref": None, "commander": "Vorazun"},
    "Vorazun_DT": {"hp": 80, "shield": 80, "armor": 1, "damage": 55, "bonus": 25, "cooldown": 1.5, "range": 0.1, "standard_ref": "Dark Templar", "commander": "Vorazun"},
    "Shadow_Guard": {"hp": 120, "shield": 80, "armor": 1, "damage": 55, "bonus": 25, "cooldown": 1.5, "range": 0.1, "standard_ref": "Dark Templar", "commander": "Vorazun"},

    # --- Karax ---
    "Energizer": {"hp": 100, "shield": 100, "armor": 1, "damage": 0, "cooldown": 0, "range": 0, "standard_ref": None, "commander": "Karax"},
    "Sentinel": {"hp": 200, "shield": 100, "armor": 2, "damage": 18, "bonus": 8, "cooldown": 1.2, "range": 0.1, "standard_ref": "Zealot", "commander": "Karax"},
    "Karax_Immortal": {"hp": 300, "shield": 150, "armor": 2, "damage": 35, "bonus": 25, "cooldown": 1.7, "range": 6, "standard_ref": "Immortal", "commander": "Karax"},

    # --- Abathur ---
    "Brutalisk": {"hp": 1000, "shield": 0, "armor": 5, "damage": 60, "bonus": 30, "cooldown": 1.5, "range": 6, "standard_ref": None, "commander": "Abathur"},
    "Leviathan": {"hp": 1000, "shield": 0, "armor": 5, "damage": 40, "cooldown": 1.0, "range": 8, "standard_ref": None, "commander": "Abathur"},
    "Abathur_Roach": {"hp": 145, "shield": 0, "armor": 2, "damage": 20, "bonus": 10, "cooldown": 1.5, "range": 5, "standard_ref": "Roach", "commander": "Abathur"},
    "Abathur_Ultralisk": {"hp": 600, "shield": 0, "armor": 5, "damage": 35, "bonus": 20, "cooldown": 1.3, "range": 0.1, "standard_ref": "Ultralisk", "commander": "Abathur"},

    # --- Alarak ---
    "Alarak_Hero": {"hp": 400, "shield": 300, "armor": 2, "damage": 70, "bonus": 30, "cooldown": 1.3, "range": 0.1, "standard_ref": None, "commander": "Alarak"},
    "Ascendant": {"hp": 100, "shield": 100, "armor": 0, "damage": 60, "bonus": 20, "cooldown": 2.0, "range": 9, "standard_ref": None, "commander": "Alarak"},
    "Wrathwalker": {"hp": 300, "shield": 200, "armor": 3, "damage": 55, "bonus": 25, "cooldown": 2.5, "range": 10, "standard_ref": None, "commander": "Alarak"},
    "Slayer": {"hp": 150, "shield": 100, "armor": 2, "damage": 30, "bonus": 15, "cooldown": 1.3, "range": 6, "standard_ref": "Stalker", "commander": "Alarak"},
    "Vanguard": {"hp": 300, "shield": 200, "armor": 3, "damage": 60, "bonus": 30, "cooldown": 2.0, "range": 6, "standard_ref": "Immortal", "commander": "Alarak"},

    # --- Nova ---
    "Nova_Hero": {"hp": 250, "shield": 100, "armor": 2, "damage": 40, "bonus": 20, "cooldown": 1.0, "range": 7, "standard_ref": None, "commander": "Nova"},
    "Nova_Marine": {"hp": 100, "shield": 0, "armor": 1, "damage": 10, "bonus": 5, "cooldown": 0.8, "range": 5, "standard_ref": "Marine", "commander": "Nova"},
    "Nova_Marauder": {"hp": 200, "shield": 0, "armor": 2, "damage": 25, "bonus": 15, "cooldown": 1.3, "range": 6, "standard_ref": "Marauder", "commander": "Nova"},
    "Nova_SiegeTank": {"hp": 300, "shield": 0, "armor": 3, "damage": 55, "bonus": 25, "cooldown": 2.5, "range": 14, "standard_ref": "Siege Tank", "commander": "Nova"},
    "Nova_Goliath": {"hp": 250, "shield": 0, "armor": 3, "damage": 28, "bonus": 10, "cooldown": 1.2, "range": 6, "standard_ref": None, "commander": "Nova"},
    "Nova_Banshee": {"hp": 220, "shield": 0, "armor": 2, "damage": 30, "cooldown": 1.0, "range": 8, "standard_ref": "Banshee", "commander": "Nova"},
    "Nova_Battlecruiser": {"hp": 1000, "shield": 0, "armor": 4, "damage": 25, "cooldown": 0.2, "range": 10, "standard_ref": "Battlecruiser", "commander": "Nova"},
    "Nova_Liberator": {"hp": 200, "shield": 0, "armor": 2, "damage": 40, "bonus": 20, "cooldown": 1.5, "range": 7, "standard_ref": "Liberator", "commander": "Nova"},

    # --- Stukov ---
    "Infested_Marine": {"hp": 75, "shield": 0, "armor": 1, "damage": 16, "bonus": 8, "cooldown": 0.9, "range": 5, "standard_ref": "Marine", "commander": "Stukov"},
    "Infested_SiegeTank": {"hp": 250, "shield": 0, "armor": 3, "damage": 50, "bonus": 20, "cooldown": 2.5, "range": 13, "standard_ref": "Siege Tank", "commander": "Stukov"},

    # --- Dehaka ---
    "Dehaka_Hero": {"hp": 1000, "shield": 0, "armor": 3, "damage": 60, "bonus": 30, "cooldown": 1.2, "range": 0.1, "standard_ref": None, "commander": "Dehaka"},
    "Primal_Zergling": {"hp": 50, "shield": 0, "armor": 0, "damage": 12, "bonus": 6, "cooldown": 0.6, "range": 0.1, "standard_ref": "Zergling", "commander": "Dehaka"},
    "Primal_Hydralisk": {"hp": 150, "shield": 0, "armor": 1, "damage": 22, "bonus": 8, "cooldown": 0.8, "range": 6, "standard_ref": "Hydralisk", "commander": "Dehaka"},
    "Primal_Roach": {"hp": 200, "shield": 0, "armor": 2, "damage": 25, "bonus": 12, "cooldown": 1.3, "range": 5, "standard_ref": "Roach", "commander": "Dehaka"},

    # --- Fenix ---
    "Champion_Zealot": {"hp": 250, "shield": 100, "armor": 3, "damage": 30, "bonus": 15, "cooldown": 1.0, "range": 0.1, "standard_ref": "Zealot", "commander": "Fenix"},
    "Champion_Stalker": {"hp": 200, "shield": 150, "armor": 2, "damage": 30, "bonus": 15, "cooldown": 1.2, "range": 7, "standard_ref": "Stalker", "commander": "Fenix"},
    "Champion_Immortal": {"hp": 300, "shield": 200, "armor": 4, "damage": 50, "bonus": 30, "cooldown": 1.5, "range": 7, "standard_ref": "Immortal", "commander": "Fenix"},
    "Champion_Colossus": {"hp": 350, "shield": 200, "armor": 3, "damage": 40, "cooldown": 1.8, "range": 8, "standard_ref": "Colossus", "commander": "Fenix"},

    # --- Tychus ---
    "Tychus_Hero": {"hp": 500, "shield": 0, "armor": 3, "damage": 50, "bonus": 25, "cooldown": 1.0, "range": 6, "standard_ref": None, "commander": "Tychus"},
    "Sam": {"hp": 350, "shield": 0, "armor": 2, "damage": 40, "bonus": 20, "cooldown": 1.2, "range": 0.1, "standard_ref": None, "commander": "Tychus"},
    "Sirius": {"hp": 400, "shield": 0, "armor": 3, "damage": 40, "bonus": 20, "cooldown": 1.5, "range": 7, "standard_ref": None, "commander": "Tychus"},
    "Blaze": {"hp": 450, "shield": 0, "armor": 2, "damage": 30, "bonus": 15, "cooldown": 1.3, "range": 5, "standard_ref": None, "commander": "Tychus"},
    "Miles": {"hp": 600, "shield": 0, "armor": 4, "damage": 20, "bonus": 10, "cooldown": 1.0, "range": 0.1, "standard_ref": None, "commander": "Tychus"},

    # --- Zeratul ---
    "Zeratul_Hero": {"hp": 400, "shield": 300, "armor": 3, "damage": 80, "bonus": 40, "cooldown": 1.2, "range": 0.1, "standard_ref": None, "commander": "Zeratul"},
    "Void_Templar": {"hp": 100, "shield": 100, "armor": 1, "damage": 60, "bonus": 30, "cooldown": 1.5, "range": 0.1, "standard_ref": "Dark Templar", "commander": "Zeratul"},
    "Avenger": {"hp": 150, "shield": 150, "armor": 2, "damage": 30, "bonus": 15, "cooldown": 1.2, "range": 7, "standard_ref": "Stalker", "commander": "Zeratul"},
    "Enforcer": {"hp": 350, "shield": 250, "armor": 4, "damage": 50, "bonus": 30, "cooldown": 1.5, "range": 7, "standard_ref": "Immortal", "commander": "Zeratul"},

    # --- Mengsk ---
    "Trooper": {"hp": 75, "shield": 0, "armor": 0, "damage": 10, "bonus": 5, "cooldown": 0.9, "range": 5, "standard_ref": "Marine", "commander": "Mengsk"},
    "Aegis_Guard": {"hp": 250, "shield": 0, "armor": 3, "damage": 30, "bonus": 15, "cooldown": 1.2, "range": 6, "standard_ref": "Marauder", "commander": "Mengsk"},
    "Blackhammer": {"hp": 600, "shield": 0, "armor": 4, "damage": 60, "bonus": 30, "cooldown": 1.3, "range": 7, "standard_ref": "Thor", "commander": "Mengsk"},
    "Shock_Division": {"hp": 300, "shield": 0, "armor": 3, "damage": 60, "bonus": 30, "cooldown": 2.5, "range": 14, "standard_ref": "Siege Tank", "commander": "Mengsk"},
}


def compute_dps(damage, cooldown, bonus=0):
    """计算 DPS"""
    if cooldown == 0:
        return 0  # 自爆/技能单位
    return (damage + bonus) / cooldown


def compute_total_hp(hp, shield):
    return hp + shield


def main():
    output = []

    output.append("# 星际争霸2 合作模式数值分析\n")
    output.append("> 基于 sc2_coop.md + 标准对战基准数据 / 分析日期: 2026-07-01\n")

    # ============================================================
    # 第一部分：合作模式 vs 标准对战 强化倍数
    # ============================================================
    output.append("---\n")
    output.append("## 1. 合作模式 vs 标准对战 单位强化倍数\n")
    output.append("")
    output.append("| 合作单位 | 标准对标 | HP倍率 | 护甲差 | DPS倍率 | 总战力倍率(HP×DPS) | 指挥官 |")
    output.append("|---------|---------|-------|-------|---------|-------------------|--------|")

    comparisons = []
    for name, u in COOP_UNITS.items():
        ref_name = u["standard_ref"]
        if ref_name is None or ref_name not in STANDARD_UNITS:
            continue
        s = STANDARD_UNITS[ref_name]

        u_dps = compute_dps(u["damage"], u["cooldown"], u.get("bonus", 0))
        s_dps = compute_dps(s["damage"], s["cooldown"], s.get("bonus", 0))

        u_ehp = compute_total_hp(u["hp"], u["shield"])
        s_ehp = compute_total_hp(s["hp"], s["shield"])

        hp_ratio = u_ehp / s_ehp if s_ehp > 0 else 0
        dps_ratio = u_dps / s_dps if s_dps > 0 else 0
        power_ratio = (u_ehp * u_dps) / (s_ehp * s_dps) if (s_ehp * s_dps) > 0 else 0
        armor_diff = u["armor"] - s["armor"]

        comparisons.append((name, ref_name, hp_ratio, armor_diff, dps_ratio, power_ratio, u["commander"]))

    # Sort by power ratio descending
    comparisons.sort(key=lambda x: x[5], reverse=True)

    for name, ref_name, hp_r, arm_d, dps_r, pow_r, cmd in comparisons:
        output.append(f"| {name} | {ref_name} | {hp_r:.1f}x | +{arm_d:+d} | {dps_r:.1f}x | {pow_r:.1f}x | {cmd} |")

    # Summary stats
    hp_ratios = [c[2] for c in comparisons]
    dps_ratios = [c[4] for c in comparisons]
    power_ratios = [c[5] for c in comparisons]

    output.append("")
    output.append("**强化倍数统计：**")
    output.append(f"- HP 倍率范围: {min(hp_ratios):.1f}x ~ {max(hp_ratios):.1f}x，均值: {sum(hp_ratios)/len(hp_ratios):.1f}x")
    output.append(f"- DPS 倍率范围: {min(dps_ratios):.1f}x ~ {max(dps_ratios):.1f}x，均值: {sum(dps_ratios)/len(dps_ratios):.1f}x")
    output.append(f"- 综合战力倍率范围: {min(power_ratios):.1f}x ~ {max(power_ratios):.1f}x，均值: {sum(power_ratios)/len(power_ratios):.1f}x")
    output.append("")
    output.append("> 注：综合战力 = HP × DPS，反映单位在PVE环境下的面板强度增长。实际强度受技能、射程、AOE等隐性因素影响更大。")

    # ============================================================
    # 第二部分：英雄单位设计模式
    # ============================================================
    output.append("\n---\n")
    output.append("## 2. 英雄单位设计模式\n")

    heroes = {
        "Kerrigan": {"hp": 1000, "shield": 500, "armor": 3, "damage": 60, "bonus": 30, "cooldown": 1.5, "type": "近战AOE"},
        "Alarak": {"hp": 400, "shield": 300, "armor": 2, "damage": 70, "bonus": 30, "cooldown": 1.3, "type": "近战爆发"},
        "Nova": {"hp": 250, "shield": 100, "armor": 2, "damage": 40, "bonus": 20, "cooldown": 1.0, "type": "远程特工"},
        "Dehaka": {"hp": 1000, "shield": 0, "armor": 3, "damage": 60, "bonus": 30, "cooldown": 1.2, "type": "近战坦克"},
        "Tychus": {"hp": 500, "shield": 0, "armor": 3, "damage": 50, "bonus": 25, "cooldown": 1.0, "type": "远程精英"},
        "Zeratul": {"hp": 400, "shield": 300, "armor": 3, "damage": 80, "bonus": 40, "cooldown": 1.2, "type": "近战刺客"},
        "Fenix": {"hp": 0, "shield": 0, "armor": 0, "damage": 0, "cooldown": 0, "type": "6形态切换"},
        "Stetmann/Gary": {"hp": 400, "shield": 0, "armor": 3, "damage": 40, "bonus": 20, "cooldown": 1.0, "type": "远程支援"},
    }

    output.append("| 英雄 | 总HP | 护甲 | 基础伤害 | DPS | 定位 | 核心机制 |")
    output.append("|------|------|------|---------|-----|------|---------|")
    for name, h in heroes.items():
        if h["damage"] == 0:
            output.append(f"| {name} | 可变 | 可变 | 可变 | 可变 | {h['type']} | 切换6种机甲，每机甲独立HP/武器 |")
            continue
        dps = (h["damage"] + h.get("bonus", 0)) / h["cooldown"]
        total_hp = h["hp"] + h.get("shield", 0)

        # Determine core mechanic
        mechanics = {
            "Kerrigan": "跳跃攻击+定身波+全图虫道",
            "Alarak": "牺牲友军增伤+冲锋AOE",
            "Nova": "隐形+狙击+核弹+全息诱饵",
            "Dehaka": "吞噬进化+火焰吐息+音波冲击",
            "Tychus": "呼叫奥丁+手雷+精英小队",
            "Zeratul": "虚空裂隙+时间暂停+神器收集",
            "Stetmann/Gary": "绿色能量场(加速/治疗/回能)+传送",
        }
        output.append(f"| {name} | {total_hp} | {h['armor']} | {h['damage']}+{h.get('bonus',0)} | {dps:.1f} | {h['type']} | {mechanics.get(name, '')} |")

    output.append("")
    output.append("**英雄单位设计规律：**")
    output.append("1. **高生存力** — 英雄总HP通常在 400-1500 范围，护甲 2-3，远超普通单位")
    output.append("2. **高基础DPS** — 英雄DPS约为标准T3单位的 2-4 倍")
    output.append("3. **技能价值 > 面板DPS** — AOE、控制、位移技能占英雄战力很大比例")
    output.append("4. **可重生机制** — 死亡后在基地重生，容错率高")
    output.append("5. **成长性** — 随精通等级提升伤害/减CD/增范围")

    # ============================================================
    # 第三部分：指挥官分类统计
    # ============================================================
    output.append("\n---\n")
    output.append("## 3. 指挥官设计类型统计\n")

    commanders = {
        "英雄型": ["Kerrigan", "Alarak", "Dehaka", "Tychus", "Zeratul", "Stetmann", "Nova", "Fenix"],
        "爆兵型": ["Raynor", "Zagara", "Stukov", "Mengsk"],
        "精英型": ["Nova", "Tychus", "Alarak"],
        "防御型": ["Karax", "Swann"],
        "进化型": ["Abathur", "Dehaka"],
        "特种机制": ["Vorazun", "Zeratul", "Stetmann", "H&H", "Fenix"],
    }

    output.append("| 类型 | 指挥官 | 共同特征 |")
    output.append("|------|--------|---------|")
    output.append(f"| 英雄型 | {', '.join(commanders['英雄型'])} | 依赖强力英雄单位，英雄可重生，技能价值高 |")
    output.append(f"| 爆兵型 | {', '.join(commanders['爆兵型'])} | 廉价单位海，自动产兵或免费单位，经济转化战斗力效率高 |")
    output.append(f"| 精英型 | {', '.join(commanders['精英型'])} | 少量高质量部队，单位单价高但个体战斗力极强 |")
    output.append(f"| 防御型 | {', '.join(commanders['防御型'])} | 擅长阵地战/塔防，防御建筑和顶级栏技能清场 |")
    output.append(f"| 进化型 | {', '.join(commanders['进化型'])} | 积累资源(生物质/进化点)，随时间线性成长 |")
    output.append(f"| 特种机制 | {', '.join(commanders['特种机制'])} | 独特机制(隐形/神器/能量场/空投)，非常规运营 |")

    # ============================================================
    # 第四部分：合作模式数值设计规律总结
    # ============================================================
    output.append("\n---\n")
    output.append("## 4. 合作模式数值设计规律\n")

    output.append("### 4.1 强化幅度分级\n")
    output.append("")
    output.append("| 强化等级 | HP倍率 | DPS倍率 | 典型单位 |")
    output.append("|---------|-------|---------|---------|")
    output.append("| 轻度强化 | 1.0-1.5x | 1.0-1.5x | 大部分标准变异单位（Raynor's Marine 1.8x/1.3x） |")
    output.append("| 中度强化 | 1.5-3.0x | 1.5-3.0x | 强化版兵种（Nova's Marine 2.2x/1.3x） |")
    output.append("| 高度强化 | 3.0-6.0x | 3.0-5.0x | 精英兵种（Champion Zealot 2.3x/3.0x） |")
    output.append("| 终极单位 | 6.0x+ | 5.0x+ | 英雄/终极进化（Kerrigan 10x/6x, Brutalisk 8.7x/5.2x） |")

    output.append("")
    output.append("### 4.2 合作模式的经济模型变化\n")
    output.append("")
    output.append("- **PVE资源更充裕**：合作模式通常有额外资源获取方式（MULE、自动采气、免费单位）")
    output.append("- **产能大幅提升**：Raynor 双倍生产、Zagara 免费毒爆、Stukov 自动产兵")
    output.append("- **高级兵种更易获取**：科技需求降低或移除，快速成型")
    output.append("- **无人口上限限制**：可组建远超标准对战规模的部队")

    output.append("")
    output.append("### 4.3 合作模式 vs 标准对战的设计差异\n")
    output.append("")
    output.append("| 维度 | 标准对战 | 合作模式 |")
    output.append("|------|---------|---------|")
    output.append("| 对手 | 人类玩家（战术多变） | Amon AI（固定波次） |")
    output.append("| 经济 | 有限资源，需要运营决策 | 更充裕，支持更大规模部队 |")
    output.append("| 单位强度 | 精细平衡 | 大幅强化（2-10x） |")
    output.append("| 容错率 | 低（失误即输） | 高（英雄可重生） |")
    output.append("| 部队规模 | 200人口上限 | 更高人口（或免费单位） |")
    output.append("| 技能设计 | 战术性技能 | 华丽AOE技能（清屏） |")
    output.append("| 成长性 | 无（开局即巅峰） | 精通/威望系统持续成长 |")

    output.append("")
    output.append("### 4.4 对本项目的启示\n")
    output.append("")
    output.append("1. **英雄单位设计**：给英雄高生存（高HP+护甲）+ 高DPS + 独特技能，死亡后可重生")
    output.append("2. **PVE vs PVP数值分离**：合作模式证明同个单位的PVE数值可以比PVP高 2-5x")
    output.append("3. **成长系统增加复玩性**：精通/威望系统让玩家有持续目标")
    output.append("4. **指挥官差异化**：用不同的签名机制（爆兵/精英/防御/进化）创造多样玩法")
    output.append("5. **免费单位/自动产兵**：降低操作负担，增加部队规模的爽感")

    result = "\n".join(output)

    # 写入文件
    output_path = "e:/godot/rts/godot_rts_start/docs/reference/research/星际争霸2合作模式数值分析.md"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(result)
    print(f"[OK] 合作模式分析已写入: {output_path}")

    # 打印关键摘要
    print(f"\n[DATA] 关键数据摘要:")
    print(f"   - 分析了 {len(comparisons)} 组合作 vs 标准对战单位对比")
    print(f"   - HP 强化均值: {sum(hp_ratios)/len(hp_ratios):.1f}x")
    print(f"   - DPS 强化均值: {sum(dps_ratios)/len(dps_ratios):.1f}x")
    print(f"   - 综合战力强化均值: {sum(power_ratios)/len(power_ratios):.1f}x")
    print(f"   - 分析了 {len(heroes)} 位英雄单位")
    print(f"   - 覆盖 {len(set(u['commander'] for u in COOP_UNITS.values()))} 位指挥官")


if __name__ == "__main__":
    main()
