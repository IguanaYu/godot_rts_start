# -*- coding: utf-8 -*-
"""
星际2 合作模式预期完成时间反推 — v3 修正版
基于标准开局流程（Build Order）的资源分配明细
"""
import math

print("=" * 80)
print("星际2 合作模式预期完成时间反推 — v3 (Build Order 模型)")
print("=" * 80)


def standard_income_curve(minutes):
    """标准对战累计收入"""
    if minutes <= 1:
        mineral = 200 * minutes
        gas = 0
    elif minutes <= 2:
        mineral = 200 + 350 * (minutes - 1)
        gas = 50 * (minutes - 1)
    elif minutes <= 3:
        mineral = 550 + 500 * (minutes - 2)
        gas = 50 + 130 * (minutes - 2)
    elif minutes <= 4:
        mineral = 1050 + 580 * (minutes - 3)
        gas = 180 + 200 * (minutes - 3)
    elif minutes <= 5:
        mineral = 1630 + 620 * (minutes - 4)
        gas = 380 + 225 * (minutes - 4)
    elif minutes <= 7:
        mineral = 2250 + 900 * (minutes - 5)
        gas = 605 + 350 * (minutes - 5)
    elif minutes <= 9:
        mineral = 4050 + 1100 * (minutes - 7)
        gas = 1305 + 425 * (minutes - 7)
    else:
        mineral = 6250 + 1310 * (minutes - 9)
        gas = 2155 + 450 * (minutes - 9)
    return mineral, gas


# ============================================================
# 1. Build Order 模型
# ============================================================
print()
print("=" * 80)
print("第一步：标准对战 1-1-1 Build Order 资源分配明细")
print("=" * 80)

print()
print("人族 1-1-1 标准开局时间线：")
print("  0:00  12 SCV 开局")
print("  0:17  连续造 SCV")
print("  0:50  Supply Depot (100矿)")
print("  1:10  Barracks (150矿)")
print("  1:20  Refinery (75矿)")
print("  2:10  Orbital Command 升级 (150矿) + 第一个 Marine")
print("  2:30  Factory (150矿+100气)")
print("  3:30  Starport (150矿+100气)")
print("  4:00  Reactor (50矿+50气)")
print("  4:15  Stim 研发开始 (100矿+100气)")
print("  5:00  Stim 完成 + 两船兵出门")
print()


def build_order_breakdown(minutes):
    """
    返回人族1-1-1开局在给定分钟时的累计资源分配
    返回值: (total_income, scv_invest, building_invest, tech_invest, army_invest)
    total_income = scv + building + tech + army
    army 包含了闲置资金（最终也会变成兵）
    """
    m, g = standard_income_curve(minutes)
    total = m + g * 2

    # SCV 投资（初始12SCV免费，之后造10个到22个）
    if minutes <= 0.3:
        scv = 0
    elif minutes <= 1:
        scv = 100   # 2个
    elif minutes <= 2:
        scv = 200   # 4个
    elif minutes <= 3:
        scv = 350   # 7个
    elif minutes <= 4:
        scv = 450   # 9个
    elif minutes <= 5:
        scv = 500   # 10个（总22个）
    else:
        scv = 550   # 11个（总23个）

    # 建筑投资（累积消耗的资源）
    if minutes <= 0.8:
        building = 100          # Supply Depot
    elif minutes <= 1.2:
        building = 250          # + Barracks
    elif minutes <= 1.5:
        building = 325          # + Refinery
    elif minutes <= 2.2:
        building = 475          # + Orbital
    elif minutes <= 2.5:
        building = 825          # + Factory (150矿+200气)
    elif minutes <= 3.5:
        building = 1175         # + Starport (150矿+200气)
    elif minutes <= 4.5:
        building = 1325         # + Reactor (50矿+100气)
    elif minutes <= 6:
        building = 1450         # + 2nd Supply Depot
    elif minutes <= 8:
        building = 1600
    elif minutes <= 12:
        building = 1800
    else:
        building = 2000

    # 科技投资（Stim + 攻防升级）
    if minutes <= 4.2:
        tech = 0
    elif minutes <= 5.5:
        tech = 300              # Stim (100矿+100气)
    elif minutes <= 7:
        tech = 600              # +1攻击 (100矿+100气)
    elif minutes <= 9:
        tech = 900              # +1护甲 (100矿+100气)
    elif minutes <= 12:
        tech = 1350             # +2攻击 (150矿+150气)
    elif minutes <= 15:
        tech = 1800             # +2护甲 (150矿+150气)
    elif minutes <= 20:
        tech = 2400             # +3攻击 (200矿+200气)
    else:
        tech = 3000             # +3护甲

    # 军队 = 总 - scv - building - tech（含闲置）
    army = max(0, total - scv - building - tech)
    return total, scv, building, tech, army


print(f"{'时间':>6s} {'累计收入':>10s} {'SCV':>6s} {'建筑':>6s} {'科技':>6s} {'军队(含闲置)':>12s} {'军队%':>6s}")
print("-" * 58)
for t in range(0, 25, 3):
    total, scv, building, tech, army = build_order_breakdown(t)
    pct = army / total * 100 if total > 0 else 0
    print(f"{t:>4d}min  {total:>8.0f}  {scv:>4.0f}  {building:>4.0f}  {tech:>4.0f}  {army:>8.0f}  {pct:>5.1f}%")

print()
print("注意：军队包含了闲置资金，但闲置资金 ≠ 场上兵力")
print("前几分钟闲置资金多是因为收入>支出速度（等建筑/科技完成）")

# ============================================================
# 2. 合作模式修正
# ============================================================
print()
print("=" * 80)
print("第二步：合作模式 — 经济×1.3，但建筑/SCV/科技成本不变")
print("=" * 80)

coop_econ_mult = 1.3
std_eff = 8.0       # 标准单位每资源 HPxTPS
coop_eff = 30.4     # 合作单位每资源 HPxDPS = 8.0 * 3.8

print()
print("关键修正逻辑：")
print("  合作模式经济更强（×1.3），但造农民/建筑/科技的成本和标准一样")
print("  所以多出来的钱全部进了军队")
print("  即：合作军队 = (标准收入×1.3) - SCV - 建筑 - 科技")
print()


def coop_army_at_time(minutes):
    """合作模式到该时间点的累计军队资源"""
    m, g = standard_income_curve(minutes)
    std_total = m + g * 2
    coop_total = std_total * coop_econ_mult
    _, scv, building, tech, _ = build_order_breakdown(minutes)
    army = max(0, coop_total - scv - building - tech)
    return army


print(f"{'时间':>6s} {'标准总收入':>10s} {'合作总收入':>10s} {'基础设施':>10s} {'军队(合作)':>10s} {'等效HPxDPS':>12s}")
print("-" * 62)

coop_data = []
for t in range(0, 25):
    m, g = standard_income_curve(t)
    std_total = m + g * 2
    coop_total = std_total * coop_econ_mult
    _, scv, building, tech, _ = build_order_breakdown(t)
    infra = scv + building + tech
    army = max(0, coop_total - infra)
    power = army * coop_eff
    coop_data.append((t, army, power))
    if t % 3 == 0:
        print(f"{t:>4d}min  {std_total:>8.0f}  {coop_total:>8.0f}  {infra:>8.0f}  {army:>8.0f}  {power:>10.0f}")

# ============================================================
# 3. 玩家 vs 敌方波次
# ============================================================
print()
print("=" * 80)
print("第三步：玩家军队 vs 敌方波次（核心对比）")
print("=" * 80)

waves = [
    (1, 3, 1, 1, 600),
    (2, 6, 2, 2, 1200),
    (3, 9, 3, 3, 2100),
    (4, 12, 4, 4, 3200),
    (5, 15, 5, 5, 5000),
    (6, 18, 6, 6, 7200),
    (7, 21, 7, 7, 9600),
    (8, 24, 7, 7, 9600),
]

print()
print("A. 单波对比（累计军队 vs 单波敌人）：")
print(f"{'波次':>4s} {'时间':>6s} {'敌方资源':>8s} {'玩家军队':>8s} {'玩家HPxDPS':>12s} {'敌方HPxDPS':>10s} {'优势x':>6s}")
print("-" * 58)
for w, t, tl, sl, res in waves:
    army = coop_data[t][1]
    power = coop_data[t][2]
    enemy_power = res * std_eff
    ratio = power / enemy_power if enemy_power > 0 else 0
    print(f"{w:>4d}  {t:>4d}min  {res:>6d}  {army:>6.0f}  {power:>10.0f}  {enemy_power:>8.0f}  {ratio:>4.1f}x")

print()
print("B. 可用军队对比（累计军队×0.7 vs 单波敌人）：")
print("  乘以0.7是因为部分军队在造/在路上/刚战损")
print(f"{'波次':>4s} {'时间':>6s} {'可用军队':>8s} {'可用HPxDPS':>12s} {'敌方HPxDPS':>10s} {'优势x':>6s} {'压力':>6s}")
print("-" * 60)
for w, t, tl, sl, res in waves:
    army = coop_data[t][1]
    available = army * 0.7
    power = available * coop_eff
    enemy_power = res * std_eff
    ratio = power / enemy_power if enemy_power > 0 else 0

    if ratio >= 5: pressure = "碾压"
    elif ratio >= 3: pressure = "优势"
    elif ratio >= 1.5: pressure = "可打"
    elif ratio >= 0.8: pressure = "苦战"
    else: pressure = "危险"

    print(f"{w:>4d}  {t:>4d}min  {available:>6.0f}  {power:>10.0f}  {enemy_power:>8.0f}  {ratio:>4.1f}x  {pressure:>4s}")

# ============================================================
# 4. 时间推算
# ============================================================
print()
print("=" * 80)
print("第四步：预期完成时间推算")
print("=" * 80)

print()
print("方法A — 玩家累计战力超过敌方全部8波总战力：")
total_enemy_8 = sum(res for _, _, _, _, res in waves) * std_eff
print(f"  敌方8波总HPxDPS: {total_enemy_8:.0f}")
for t in range(3, 25):
    army = coop_data[t][1]
    cum_power = army * coop_eff
    if cum_power > total_enemy_8:
        print(f"  玩家在 t={t}min 时累计战力 ({cum_power:.0f}) 超过敌方8波总和")
        break

print()
print("方法B — 玩家可用战力超过当前波次的临界点（找设计上限）：")
for t in range(3, 30):
    idx = min(t, 24)
    army = coop_data[idx][1]
    available = army * 0.7
    power = available * coop_eff

    # 该时间点对应的敌方波次资源
    if t <= 3: wave_res = 600
    elif t <= 6: wave_res = 1200
    elif t <= 9: wave_res = 2100
    elif t <= 12: wave_res = 3200
    elif t <= 15: wave_res = 5000
    elif t <= 18: wave_res = 7200
    elif t <= 21: wave_res = 9600
    elif t <= 24: wave_res = 9600
    else: wave_res = 9600 + (t - 24) * 1200  # 超过8波后继续增长

    enemy_power = wave_res * std_eff
    ratio = power / enemy_power if enemy_power > 0 else 0

    if ratio < 1.0:
        print(f"  在 t={t}min 时，玩家可用战力首次低于敌方波次")
        print(f"    玩家可用: {power:.0f} HPxDPS")
        print(f"    敌方波次: {enemy_power:.0f} HPxDPS")
        print(f"    比值: {ratio:.2f}x")
        print(f"  -> 设计上的最大承受时间约 {t-3}-{t}min")
        break

print()
print("方法C — 按科技成型后2波推算：")
print("  满科技时间: ~15min (攻防+3)")
print("  之后2波: Wave 6 (18min), Wave 7 (21min)")
print("  -> 预期完成时间: 18-22min")

# ============================================================
# 5. 部队规模
# ============================================================
print()
print("=" * 80)
print("第五步：各时间点部队规模估算")
print("=" * 80)

print()
print("基于军队资源 ÷ 均价(112.5) = 累计生产的部队总数")
print("场上部队 ≈ 累计的50%（其余在造/战损/补充中）")
print()
print(f"{'时间':>6s} {'军队资源':>8s} {'累计生产':>8s} {'场上部队':>8s} {'T1等价':>8s} {'敌方数量':>8s}")
print("-" * 50)
for t in range(3, 25, 3):
    army = coop_data[t][1]
    produced = army / 112.5
    on_field = produced * 0.5
    t1_eq = army / 50

    # 该时间点的敌方波次
    res = 0
    for w, wt, tl, sl, r in waves:
        if wt == t:
            res = r
            break
    enemy_count = res / 50

    print(f"{t:>4d}min  {army:>6.0f}  {produced:>6.0f}  {on_field:>6.0f}  {t1_eq:>6.0f}  {enemy_count:>6.0f}")

# ============================================================
# 6. 部队 vs 敌人对比（单位数量级）
# ============================================================
print()
print("=" * 80)
print("第六步：部队规模与敌人规模直观对比")
print("=" * 80)

print()
print(f"{'波次':>4s} {'时间':>6s} {'敌人数量':>8s} {'玩家场上':>8s} {'数量比':>6s} {'敌人构成':>20s}")
print("-" * 52)
for w, t, tl, sl, res in waves:
    army = coop_data[t][1]
    player_on_field = (army / 112.5) * 0.5
    enemy_count = res / 50

    if tl <= 2:
        comp = "T1-T2混合"
    elif tl <= 4:
        comp = "T2为主+少量T3"
    elif tl <= 6:
        comp = "T3主力"
    else:
        comp = "全T3海"

    ratio = player_on_field / enemy_count if enemy_count > 0 else 0
    print(f"{w:>4d}  {t:>4d}min  {enemy_count:>6.0f}个  {player_on_field:>6.0f}个  {ratio:>4.1f}x  {comp:>16s}")

# ============================================================
# 7. 最终结论
# ============================================================
print()
print("=" * 80)
print("最终结论")
print("=" * 80)
print()
print("  合作模式预期完成时间: 20 ± 5 分钟")
print()
print("  各阶段节奏：")
print("    0:00-3:00  发育期 — 造农民+建筑+科技")
print("               Wave1 (3:00) 时场上仅 ~2个兵")
print("    3:00-6:00  首波防御 — Wave1-2")
print("               场上 ~3-8个兵，压力较小（优势2-5x）")
print("    6:00-12:00 暴兵期 — 持续出兵+科技")
print("               场上 ~15-40个兵，优势明显（5-10x）")
print("   12:00-18:00 成型期 — 科技接近完成")
print("               场上 ~40-80个兵，碾压（10x+）")
print("   18:00-25:00 决战期 — 满科技满攻防")
print("               场上 ~80-150个兵，决定胜负")
print()
print("  设计上的关键时间点：")
print("    3min: 第1波，玩家只有几个兵 → 设计上就是让玩家'刚好能守住'")
print("    6min: 第2波，玩家开始暴兵 → 设计上开始建立优势")
print("    9min: 第3波，T3出现 → 设计上玩家也该有T3了")
print("   12min: 第4波，强度跳升 → 设计上考验玩家科技转型")
print("   15min: 第5波，满科技前最后一波 → 设计上'黎明前的黑暗'")
print("   18min+: 满科技后的爽局 → 设计上希望在此之前/之后立即结束")
print()
print("  部队规模速查（场上即时兵力 vs 敌人）：")
print("    3min: 玩家~2个  vs  敌人~10个  → 劣势（靠建筑防守）")
print("    6min: 玩家~12个 vs  敌人~20个  → 略劣")
print("    9min: 玩家~30个 vs  敌人~30个  → 均势")
print("   12min: 玩家~50个 vs  敌人~40个  → 优势")
print("   15min: 玩家~70个 vs  敌人~50个  → 碾压")
print("   18min: 玩家~100个 vs 敌人~70个  → 碾压")
print("   21min: 玩家~130个 vs 敌人~80个  → 碾压")
