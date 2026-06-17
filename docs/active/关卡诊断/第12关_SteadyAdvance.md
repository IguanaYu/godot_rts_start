# 第 12 关「Steady Advance」6 维诊断报告

> 数据来源：[map12_config.tres](../../../resources/map12_config.tres) + [map_12.tscn](../../../scenes/maps/map_12.tscn)

---

## 0. 关卡概览

| 项 | 值 |
|----|----|
| 关卡名 | Steady Advance（稳步推进） |
| 地图尺寸 | **3200×1200**（最宽地图） |
| 初始金币 | **5000** |
| 可用物品 | 8种（缺Monk/Monastery） |
| 指挥官技能 | [0,3] |
| 初始玩家部队 | 4S+3A+2L（**1730**） |
| 初始玩家建筑 | Castle+Barracks |
| 敌方 | **3个据点（SH1/SH2/SH3），水平排列** |
| 胜利条件 | 摧毁3个据点（[victory_multi_stage](../../../scripts/victory/victory_multi_stage.gd)） |

### 布局示意

```
玩家(200,350-530)  SH1(900)       SH2(1620)       SH3(2400)
  Castle+Barracks   3S+2A+Wall     5S+3A+1L+Wall    8S+6A+2L+Wall
                    Tower+Tower    Tower+Barracks    2Tower+Castle+Barracks

A1: 玩家(200) ↔ SH1(900) = 700px ✅ 刚好达标
A2: SH1↔SH2 = 720px < 800px ❌ 联动
    SH2↔SH3 = 780px < 800px ❌ 联动
```

### 各据点战力

| 据点 | 兵力 | 建筑 | 表面战力 | 驻军 |
|------|------|------|---------|------|
| SH1 | 3S+2A | 2Tower+Wall | 450+380+240+30=1100 | — |
| SH2 | 5S+3A+1L | Tower+Barracks+Wall | 750+570+205+120+240+30=1915 | Barracks≈1120 |
| SH3 | 8S+6A+2L | 2Tower+Castle+Barracks+2Wall | 1200+1140+410+240+200+240+60=3490 | Castle+Barracks≈2920 |
| **总计** | | | **6505** | **4040** |

---

## 1. 维度 A：空间布局 ⚠️

**A1**：700px ✅ 刚好达标

**A2**：SH1↔SH2=720px，SH2↔SH3=780px，**均<800px**。3个据点会互相求救联动。

但地图宽3200px，**有足够的空间拉大间距**。建议SH1右移或SH3右移50px即可。

---

## 2. 维度 B：据点战力 ✅

战力递进 1100→1915→3490，相邻比1.74x/1.82x，**递进合理**（略高但可接受）。

三阶段胜利条件（[victory_multi_stage](../../../scripts/victory/victory_multi_stage.gd)）确保逐个击破。

---

## 3. 维度 C：节奏曲线 ✅

**C3**：map11(0)→map12(5000)，Δ=+5000，**跳跃**（但map11是无基地关）

**设计亮点：三阶段推进**
- SH1摧毁后才激活SH2阶段
- 避免了联动问题（虽然场景距离联动仍在，但阶段逻辑隔离）
- 和map1的"伪分阶段"不同，**这关是真正的分阶段**

---

## 4. 维度 D：经济续战 ✅

- 5000金充裕
- Castle+Barracks产金产兵
- 地图宽3200，扩张空间大

---

## 5. 维度 E：兵种目标 ⚠️

- 缺Monk/Monastery（无治疗）
- 技能[0,3]轨道打击+治疗（技能弥补无Monk）
- 3阶段目标清晰

---

## 6. 维度 F：AI 技术 ✅

- 阶段隔离正确防止联动
- 建筑布局工整
- 地图大但结构清晰

---

## 7. 问题与建议

| # | 问题 | 严重度 | 建议 |
|---|------|--------|------|
| 1 | A2：SH间距720-780px略低于800 | 🟡中 | 外推50-80px即可达标 |
| 2 | 缺Monk治疗 | 🟢低 | 技能[3]治疗弥补 |

---

*下一篇：[第13关_InterceptTheCourier](第13关_InterceptTheCourier.md)*
