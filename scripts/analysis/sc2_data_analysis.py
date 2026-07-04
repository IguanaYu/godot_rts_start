#!/usr/bin/env python3
"""
SC2 单位数据全分析脚本
计算: TTK矩阵, eHP, 人口效率, 护甲收益, 造价回归, Overkill, 性价比排行, Tier基准
"""

import math

# 字段索引: name,race,tier,hp,shield,armor,dmg,bonus_dmg,bonus_type,cd,range,speed,cost_m,cost_g,supply,bt,splash,tags
U = [
    ("Marine","T","T1",45,0,0,6,0,"",0.61,5,3.15,50,0,1,25,0,"轻甲"),
    ("Marauder","T","T1.5",125,0,0,10,5,"重甲",1.5,6,2.95,100,25,2,30,0,"重甲"),
    ("Reaper","T","T1",60,0,0,4,5,"轻甲",1.1,4.5,3.75,50,50,1,40,0,"轻甲"),
    ("Ghost","T","T2",100,0,0,10,10,"灵能",1.5,6,3.0,150,125,2,36,0,"灵能"),
    ("Hellion","T","T2",90,0,0,8,12,"轻甲",2.5,5,4.25,100,0,2,30,1.5,"轻甲"),
    ("Hellbat","T","T2",135,0,0,18,10,"重甲",1.9,2,2.95,100,0,2,4,1.5,"重甲"),
    ("Cyclone","T","T2",180,0,0,18,14,"重甲",0.48,5,3.78,150,100,3,36,0,"重甲"),
    ("SiegeTank","T","T2",175,0,1,15,0,"",1.04,7,2.25,150,125,3,39,0,"重甲"),
    ("SiegeTank(S)","T","T2",175,0,1,35,15,"重甲",2.5,13,0,150,125,3,39,2.0,"重甲"),
    ("Thor","T","T3",400,0,1,30,0,"",1.28,7,2.25,300,200,6,55,0,"重甲"),
    ("Viking","T","T2",125,0,0,16,0,"",1.5,9,3.15,150,75,2,30,0,"轻甲"),
    ("Banshee","T","T2",140,0,0,12,0,"",1.2,6,3.85,150,100,3,43,0,"轻甲"),
    ("Liberator","T","T2",130,0,0,10,0,"",1.0,5,4.0,150,125,3,43,0,"轻甲"),
    ("Battlecruiser","T","T3",550,0,3,8,0,"",0.23,6,2.62,400,300,6,75,0,"重甲"),
    ("Zealot","P","T1",100,50,0,16,0,"",1.2,0.1,3.15,100,0,2,27,0,"轻甲"),
    ("Stalker","P","T2",80,80,0,10,4,"重甲",1.34,6,3.38,125,50,2,30,0,"重甲"),
    ("Sentry","P","T2",40,40,0,6,0,"",1.0,5,2.75,50,100,2,30,0,"轻甲"),
    ("Adept","P","T2",70,70,0,10,7,"轻甲",1.34,4,3.5,100,25,2,30,0,"轻甲"),
    ("HighTemplar","P","T3",40,40,0,0,0,"",0,0,2.75,50,150,2,39,0,"轻甲"),
    ("DarkTemplar","P","T3",40,80,0,45,0,"",1.54,0.1,3.0,125,125,2,39,0,"轻甲"),
    ("Immortal","P","T3",200,100,1,20,30,"重甲",1.04,6,2.75,275,100,4,43,0,"重甲"),
    ("Colossus","P","T3",200,150,1,10,10,"轻甲",1.65,7,2.62,300,200,6,54,1.5,"重甲"),
    ("Archon","P","T3",10,350,1,25,10,"生物",1.04,3,2.75,100,300,4,0,1.5,"灵能"),
    ("Phoenix","P","T2",60,60,0,5,0,"",1.1,4,4.95,150,100,2,28,0,"轻甲"),
    ("Oracle","P","T2",60,60,0,0,0,"",0,0,4.0,150,150,3,36,0,"轻甲"),
    ("VoidRay","P","T3",100,100,1,6,0,"",0.36,6,2.62,250,150,4,36,0,"重甲"),
    ("Tempest","P","T3",150,125,2,30,15,"重甲",2.5,14,2.62,250,175,4,43,0,"重甲"),
    ("Carrier","P","T3",200,150,2,40,0,"",1.0,8,2.62,350,250,6,64,0,"重甲"),
    ("Zergling","Z","T1",35,0,0,5,0,"",0.5,0.1,4.51,25,0,0.5,17,0,"轻甲"),
    ("Baneling","Z","T1.5",30,0,0,16,10,"轻甲",0,0.1,3.5,25,25,1,14,2.2,"轻甲"),
    ("Roach","Z","T2",145,0,1,12,0,"",1.5,4,2.95,75,25,2,24,0,"重甲"),
    ("Ravager","Z","T2",120,0,1,10,0,"",1.5,4,2.95,25,75,3,14,0,"重甲"),
    ("Hydralisk","Z","T2",80,0,0,12,0,"",0.48,5,3.15,100,50,2,24,0,"轻甲"),
    ("Lurker","Z","T3",120,0,1,20,15,"重甲",1.54,9,2.95,50,100,3,18,1.5,"重甲"),
    ("Infestor","Z","T2",90,0,0,0,0,"",0,0,2.75,100,150,2,36,0,"灵能"),
    ("SwarmHost","Z","T3",140,0,0,0,0,"",0,0,2.75,100,75,3,36,0,"重甲"),
    ("Ultralisk","Z","T3",500,0,1,35,0,"",1.28,0.1,3.15,300,200,6,46,0.7,"重甲"),
    ("Mutalisk","Z","T2",120,0,0,9,0,"",1.52,3,4.0,100,100,2,24,1.0,"重甲"),
    ("Corruptor","Z","T2",200,0,1,12,0,"",1.2,6,4.0,150,100,2,24,0,"重甲"),
    ("BroodLord","Z","T3",225,0,1,20,0,"",1.9,10,1.4,150,150,2,24,0,"重甲"),
]

umap = {u[0]: u for u in U}

def ehp(hp, shield, armor, atk):
    ad = max(atk - armor, 0.5)
    return shield + (hp / ad * atk) if ad > 0 else shield + hp * 1000

def dps(dmg, cd):
    return 0 if cd <= 0 else dmg / cd

# ============================================================
# 1. TTK 矩阵
# ============================================================
print("=" * 80)
print("1. TTK 击杀时间矩阵（秒）")
print("=" * 80)

keys = ["Marine","Marauder","Zealot","Stalker","Zergling","Roach",
        "Hydralisk","Immortal","Ultralisk","SiegeTank(S)","Battlecruiser","Baneling"]

print(f"{'攻击\\目标':<14}", end="")
for t in keys:
    print(f"{t:<12}", end="")
print()

for ak in keys:
    a = umap[ak]
    print(f"{ak:<14}", end="")
    for tk in keys:
        t = umap[tk]
        ed = a[6] + (a[7] if a[8] and a[8] in t[17] else 0)
        adps = dps(ed, a[9])
        tehp = ehp(t[3], t[4], t[5], a[6])
        ttk = tehp / adps if adps > 0 else float('inf')
        print(f"{'∞':<12}" if ttk == float('inf') or ttk > 60 else f"{ttk:<12.2f}", end="")
    print()

# ============================================================
# 2. eHP 分析
# ============================================================
print("\n" + "=" * 80)
print("2. eHP 有效HP分析")
print("=" * 80)

test_atks = [5,6,8,10,15,20,35,50]
print(f"{'单位':<16}", end="")
for a in test_atks:
    print(f"vs{a:<8}", end="")
print(f"{'面板HP':<8}{'eHP比(6)':<10}")

for u in U:
    if u[0] in ("HighTemplar","Sentry","Infestor","SwarmHost","Oracle"):
        continue
    raw = u[3] + u[4]
    print(f"{u[0]:<16}", end="")
    for a in test_atks:
        print(f"{ehp(u[3],u[4],u[5],a):<10.1f}", end="")
    print(f"{raw:<8}{ehp(u[3],u[4],u[5],6)/raw:<10.2f}")

# ============================================================
# 3. 人口效率排行
# ============================================================
print("\n" + "=" * 80)
print("3. 人口效率排行")
print("=" * 80)

print(f"\n{'排名':<4}{'单位':<16}{'种族':<4}{'Tier':<6}{'DPS':<8}{'DPS/Pop':<10}{'HP×DPS':<10}{'HP×DPS/Pop':<12}{'eHP(6)':<10}{'eHP/Pop':<10}")

rank = []
for u in U:
    if u[14] <= 0: continue
    d = dps(u[6], u[9])
    hpd = (u[3]+u[4]) * d
    e6 = ehp(u[3], u[4], u[5], 6)
    rank.append((u[0],u[1],u[2],d,d/u[14],hpd,hpd/u[14],e6,e6/u[14]))

rank.sort(key=lambda x: x[6], reverse=True)
for i,r in enumerate(rank[:20]):
    print(f"{i+1:<4}{r[0]:<16}{r[1]:<4}{r[2]:<6}{r[3]:<8.2f}{r[4]:<10.2f}{r[5]:<10.0f}{r[6]:<12.0f}{r[7]:<10.1f}{r[8]:<10.1f}")

print("\nDPS/人口 排行 TOP 15:")
r2 = sorted(rank, key=lambda x: x[4], reverse=True)
for i,r in enumerate(r2[:15]):
    print(f"{i+1:<4}{r[0]:<16}{r[1]:<4}{r[2]:<6} DPS={r[3]:<6.2f} DPS/Pop={r[4]:<.2f}")

# ============================================================
# 4. 护甲边际收益
# ============================================================
print("\n" + "=" * 80)
print("4. 护甲边际收益曲线")
print("=" * 80)

print(f"\n{'攻击力':<8}", end="")
for arm in range(6):
    print(f"甲{arm}:伤(减伤%){'':<4}", end="")
print()

for atk in [3,5,6,8,10,12,15,20,30,45]:
    print(f"{atk:<8}", end="")
    for arm in range(6):
        d = max(atk-arm, 0.5)
        red = (atk-d)/atk*100
        print(f"{d:<5.1f}({red:<4.0f}%){'':<6}", end="")
    print()

print(f"\n{'攻击力':<8}", end="")
for step in range(1,6):
    print(f"0→{step}甲收益{'':<4}", end="")
print()

for atk in [3,5,6,8,10,12,15,20,30,45]:
    print(f"{atk:<8}", end="")
    for arm in range(5):
        db = max(atk-arm, 0.5)
        da = max(atk-(arm+1), 0.5)
        red = (db-da)/atk*100
        print(f"{red:<14.1f}%", end="")
    print()

print(f"\n{'HP':<6}{'0甲':<14}{'1甲':<14}{'2甲':<14}{'3甲':<14}")
for hp in [35,45,80,100,125,145,175,200,300,400,500]:
    print(f"{hp:<6}", end="")
    for arm in range(4):
        dph = max(6-arm, 0.5)
        hits = math.ceil(hp/dph)
        print(f"{hits:<3d}枪({hits*0.61:<5.2f}s){'':<3}", end="")
    print()

# ============================================================
# 5. 造价 vs 属性关系
# ============================================================
print("\n" + "=" * 80)
print("5. 造价与属性关系")
print("=" * 80)

print(f"\n{'单位':<16}{'Cost':<8}{'HP×DPS':<10}{'Cost/HP×DPS':<14}{'DPS/Pop':<12}{'HP/Pop':<10}{'Cost/Pop':<12}")

for u in U:
    c = u[12] + u[13]*2
    if u[14] <= 0 or c <= 0: continue
    h = u[3]+u[4]
    d = dps(u[6], u[9])
    hpd = h*d
    r = c/hpd if hpd>0 else 0
    print(f"{u[0]:<16}{c:<8}{hpd:<10.0f}{r:<14.4f}{d/u[14]:<12.2f}{h/u[14]:<10.1f}{c/u[14]:<12.1f}")

# ============================================================
# 6. Overkill分析
# ============================================================
print("\n" + "=" * 80)
print("6. Overkill 损耗分析")
print("=" * 80)

print(f"\n{'攻击方':<16}{'单发伤害':<10}{'目标':<16}{'目标HP':<10}{'Overkill':<10}{'效率损失':<10}")

cases = [
    ("SiegeTank(S)",50,"Marine",45),("SiegeTank(S)",50,"Zergling",35),
    ("SiegeTank(S)",50,"Hydralisk",80),("SiegeTank(S)",50,"Roach",145),
    ("SiegeTank(S)",50,"Immortal",300),("SiegeTank(S)",50,"Ultralisk",500),
    ("Immortal",50,"Marine",45),("Immortal",50,"Zergling",35),
    ("Immortal",50,"Stalker",160),
    ("Marine",6,"Zergling",35),("Marine",6,"Marine",45),("Marine",6,"Roach",145),
    ("DarkTemplar",45,"Marine",45),("DarkTemplar",45,"Zergling",35),
    ("DarkTemplar",45,"Ultralisk",500),
    ("Ultralisk",35,"Marine",45),("Ultralisk",35,"Zergling",35),
    ("Battlecruiser",8,"Marine",45),("Battlecruiser",8,"Zergling",35),
    ("Baneling",26,"Marine",45),("Baneling",26,"Zergling",35),
    ("Baneling",26,"Zealot",150),
]

for an,ad,tn,th in cases:
    ok = ad/th
    el = (ad-th)/ad*100 if ad>th else 0
    print(f"{an:<16}{ad:<10}{tn:<16}{th:<10}{ok:<10.2f}{el:<9.1f}%")

# ============================================================
# 7. 综合性价比
# ============================================================
print("\n" + "=" * 80)
print("7. 综合性价比排名")
print("=" * 80)

print(f"\n{'排名':<4}{'单位':<16}{'种族':<4}{'Cost':<8}{'HP×DPS':<10}{'战力/Cost':<12}{'战力/Cost/Pop':<16}")

cr = []
for u in U:
    c = u[12]+u[13]*2
    if c<=0 or u[14]<=0: continue
    h = u[3]+u[4]
    d = dps(u[6]+u[7], u[9])
    hpd = h*d
    if hpd<=0: continue
    v = hpd/c
    cr.append((u[0],u[1],c,hpd,v,v/u[14]))

cr.sort(key=lambda x: x[4], reverse=True)
for i,r in enumerate(cr[:15]):
    print(f"{i+1:<4}{r[0]:<16}{r[1]:<4}{r[2]:<8}{r[3]:<10.0f}{r[4]:<12.2f}{r[5]:<16.2f}")

# ============================================================
# 8. Tier 基准线
# ============================================================
print("\n" + "=" * 80)
print("8. Tier 战力基准线")
print("=" * 80)

tiers = {"T1":[],"T1.5":[],"T2":[],"T3":[]}
for u in U:
    t = u[2]
    if t not in tiers: continue
    h = u[3]+u[4]
    d = dps(u[6], u[9])
    c = u[12]+u[13]*2
    if u[14]>0 and c>0 and d>0:
        tiers[t].append((u[0],h,d,h*d,d/u[14],c))

for t in ["T1","T1.5","T2","T3"]:
    ut = tiers[t]
    if not ut: continue
    ah = sum(u[1] for u in ut)/len(ut)
    ad = sum(u[2] for u in ut)/len(ut)
    ahd = sum(u[3] for u in ut)/len(ut)
    ads = sum(u[4] for u in ut)/len(ut)
    ac = sum(u[5] for u in ut)/len(ut)
    print(f"\n{t} ({len(ut)} units):")
    print(f"  平均HP: {ah:.0f}  平均DPS: {ad:.1f}  平均HP×DPS: {ahd:.0f}")
    print(f"  平均DPS/人口: {ads:.1f}  平均造价: {ac:.0f}")
    print(f"  列表: {', '.join(u[0] for u in ut)}")

# ============================================================
# 9. 造价回归粗略估算
# ============================================================
print("\n" + "=" * 80)
print("9. 造价回归估算 — HP×DPS 与造价的关系")
print("=" * 80)

# 按种族分组计算 HP×DPS 与 Cost 的比值
for race_label, race_key in [("Terran","T"),("Protoss","P"),("Zerg","Z")]:
    units = [u for u in U if u[1]==race_key and u[14]>0 and dps(u[6],u[9])>0]
    if not units: continue
    ratios = []
    for u in units:
        c = u[12]+u[13]*2
        h = u[3]+u[4]
        d = dps(u[6], u[9])
        if c>0 and d>0:
            ratios.append(h*d/c)
    avg = sum(ratios)/len(ratios) if ratios else 0
    print(f"\n{race_label} ({len(units)} units):")
    print(f"  平均 HP×DPS/Cost: {avg:.2f}")
    print(f"  即每 1 单位资源可购买 {avg:.2f} 单位 HP×DPS")

    # 去掉Zergling(太便宜)和法系后
    combat = [r for u,r in zip(units,ratios) if u[0] not in ("Zergling","HighTemplar","Infestor","SwarmHost","Oracle")]
    avg2 = sum(combat)/len(combat) if combat else 0
    print(f"  战斗单位平均: {avg2:.2f}")

print("\n\n分析完毕。")
