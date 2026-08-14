# PR-4：BuildingActivityVisual 组件

> **目标**：实现建筑活动视觉组件，接入 9 种建筑的生产/施工/升级/产金/受击反馈。
>
> **预期收益**：建筑不再是死图。玩家不看 UI 也能看出哪些建筑在工作、哪个刚完成、哪个在被攻击。
>
> **关联**：[ROADMAP](程序化特效落地_ROADMAP.md) | [总方案 2.3](../design/程序化特效落地总方案.md) | [建筑活动设计稿](../design/建筑活动视觉设计方案.md)

---

## 1. 现状盘点

### 已有建筑视觉（不用改）

- 建造进度条（`build_bar`，金色填充）
- HP 条（`hp_bar`）
- 生产圆圈（`production_circle.gd`，队列进度可视化）
- 产金飘字（`floating_text.gd`，金色 "+N"）
- 箭塔攻击轻微回弹（`jelly_effect.gd`）
- 死亡爆炸 + scale-to-zero

### 缺失的建筑视觉

| 状态 | 缺失内容 |
|---|---|
| 单位入队 | 无反馈（玩家不知道点击是否生效）|
| 生产中 | 无规律微震/尘土（建筑像死的）|
| 单位完成 | 无完成回弹（只有出生光柱）|
| 施工中 | 半透明有，**无尘土** |
| 落成 | scale 回弹 + 尘土（设计稿有，未实现）|
| 产金 | 只有飘字，**无地面金环** |
| 升级中 | **无持续反馈**（只有进度条）|
| 升级完成 | **无大脉冲/双环** |
| 受击 | **无震动/碎片** |
| 城墙连结 | 加成激活时**无视觉** |

### 关键代码位置

- [scripts/buildings/building.gd:556](../../scripts/buildings/building.gd) `_production_process()` — 生产 tick
- [scripts/buildings/building.gd:603](../../scripts/buildings/building.gd) `queue_unit()` — 入队
- [scripts/buildings/building.gd:612](../../scripts/buildings/building.gd) `_spawn_next_unit()` — 完成
- [scripts/buildings/building.gd:734](../../scripts/buildings/building.gd) `_produce_gold()` — 产金
- [scripts/buildings/building.gd:886](../../scripts/buildings/building.gd) `set_age_upgrade_progress()` — 升级
- [scripts/buildings/building.gd:896](../../scripts/buildings/building.gd) `take_damage()` — 受击
- [scripts/buildings/building.gd:929](../../scripts/buildings/building.gd) `die()` — 死亡
- [scripts/buildings/building.gd:951](../../scripts/buildings/building.gd) `start_construction()` — 施工开始
- [scripts/buildings/building.gd:982](../../scripts/buildings/building.gd) `_finish_construction()` — 落成

### 9 种建筑

`WALL / TOWER / CASTLE / BARRACKS / MONASTERY / ARCHERY_RANGE / FARM / ACADEMY / ALTAR_ARCHER`

---

## 2. 决策点

### 决策点 1：脉冲实现方式？

**方案 A**：每次事件创建 Tween
- ✅ 简单
- ❌ 持续状态（生产中规律微震）会爆 Tween

**方案 B**：组件内部计时器 + _process 插值
- ✅ 性能好
- ✅ 持续状态可控
- ❌ 代码量大

**方案 C**：复用 `jelly_effect.gd` 的 Tween 模式 + 组件管持续状态
- ✅ 复用现有代码
- ❌ JellyEffect 是 static func，每单位管理 tween 要靠 meta

**💡 我的建议**：**方案 B**。组件维护"持续状态"（idle/producing/constructing/age_upgrading）+ "短事件"（order_received/production_completed/hit/resource_tick），_process 里合成 scale。参考 PR-3 的合成规则。

---

### 决策点 2：不同建筑的配置怎么管理？

**方案 A**：if-else 按 building_type 硬编码
- ✅ 简单
- ❌ 9 种建筑 × 多个参数，代码很长

**方案 B**：数据驱动——一个 Dictionary 配置表
- ✅ 清晰
- ✅ 添加新建筑只改配置
- ❌ 配置表较大

**方案 C**：每建筑类型一个 `_configure_<type>()` 方法
- ✅ 可读
- ❌ 代码膨胀

**方案 D**：配置存到 `.tres` 资源文件
- ✅ 数据驱动 + 编辑器可视化
- ❌ 资源管理复杂

**💡 我的建议**：**方案 B**。在组件脚本顶部维护一个 `const BUILDING_CONFIGS := { BuildingType.BARRACKS: {...}, ... }`。参考建筑方案"默认建筑配置"表。需要差异化时直接改 const 表。

---

### 决策点 3：受击反馈怎么实现？

**现状**：`take_damage()` 里只有飘字 + 警戒逻辑，**无视觉反馈**

**方案 A**：scale 脉冲（压扁回弹，类似 JellyEffect）
- ✅ 复用现有模式
- ❌ 城墙（长方形）scale 会变形

**方案 B**：position 震动（左右上下抖动 2-3px）
- ✅ 适合所有形状
- ❌ 要小心不要影响碰撞（建筑碰撞一般固定，可接受）

**方案 C**：modulate 闪红（瞬间染红 → 回正）
- ✅ 视觉清晰
- ❌ 和护盾承伤冲突（如果有）

**方案 D**：按建筑类型分——矩形建筑（城墙）走震动，正方形建筑（兵营/城堡）走 scale 脉冲
- ✅ 视觉合理
- ❌ 配置复杂

**💡 我的建议**：**方案 B + C 组合**。所有建筑受击走 `position 微震 2px + modulate 红闪 0.1 秒`，不走 scale（避免长方形变形）。震动不影响碰撞（建筑 collision shape 不动）。

---

### 决策点 4：地面环怎么画？

**方案 A**：组件 `_draw()` 画
- ✅ 灵活
- ❌ 建筑位置固定，_draw 可行

**方案 B**：子节点（Polygon2D / Line2D）
- ✅ 可动画
- ❌ 多建筑多子节点

**方案 C**：贴图环（Sprite2D + 缩放/旋转）
- ✅ 美观
- ❌ 需要贴图

**💡 我的建议**：**方案 A**。建筑不动，地面环用 `_draw` 最简单。持续状态（升级金环转动）通过 `queue_redraw()` 配合 `TIME` 实现。

---

### 决策点 5：尘土位置怎么定？

**现状**：`dust_effect.tscn` 已有，PR-2 已池化

**方案 A**：固定在建筑底部中央
- ✅ 简单
- ❌ 不一定符合所有建筑（比如兵营门口 vs 农场中央）

**方案 B**：每建筑配置 `activity_anchor: Vector2`（相对建筑中心的偏移）
- ✅ 灵活
- ✅ 编辑器可调

**方案 C**：按 building_type 自动选默认值（兵营门口、靶场门口、农场中央）
- ✅ 开箱即用
- ❌ 默认值可能不准，需手动微调

**💡 我的建议**：**方案 C + B**。配置表给默认 anchor，特殊建筑在 Inspector 微调。参考建筑方案"编辑器配置"。

---

### 决策点 6：施工中尘土频率？

**方案 A**：固定频率（0.8 秒一次）
- ✅ 简单
- ❌ 单调

**方案 B**：随机间隔（0.5-1.2 秒）
- ✅ 自然
- ❌ 不可预测

**方案 C**：按施工进度加快（前期慢、后期快）
- ✅ 反映"快完成了"
- ❌ 复杂

**💡 我的建议**：**方案 A**。固定 0.8 秒一次。施工尘土主要是"有动静"的反馈，不需要太花哨。

---

### 决策点 7：升级完成的双环扩散怎么做？

**现状**：升级完成只有飘字，**无世界内反馈**

**方案 A**：组件 `_draw` 画两个扩散环（radius 0→大，alpha 1→0，0.6 秒）
- ✅ 复用 _draw
- ❌ _draw 扩散要 queue_redraw

**方案 B**：粒子环（GPUParticles2D 环形发射）
- ✅ 自动消失
- ❌ 需要专门配方

**方案 C**：Tween 驱动的 Line2D 子节点（临时挂载）
- ✅ 动画干净
- ❌ 要管子节点生命周期

**💡 我的建议**：**方案 A**。组件内部维护"短事件队列"，每帧 _draw 时画活跃的扩散环，结束自动移除。一次升级完成最多 2-3 个环同时（双环扩散 + 中心脉冲），不会爆。

---

### 决策点 8：城墙连结加成怎么可视化？

**现状**：相邻城墙 HP 提升（连结加成），但**无视觉**

**方案 A**：相邻城墙之间画淡金线
- ✅ 直观显示"连结"
- ❌ 每帧检测邻居，性能开销

**方案 B**：连结激活的城墙脚下画金色细环
- ✅ 简单
- ❌ 不显示"和谁连结"

**方案 C**：连结激活的城墙 modulate 微微偏金
- ✅ 最简单
- ❌ 不明显

**方案 D**：不做，连结加成是数值层的事
- ✅ 零工作量
- ❌ 玩家不知道为什么这堵墙更硬

**💡 我的建议**：**方案 B**。连结激活时城墙脚下画淡金细环（持续）。检测在 `start_construction()` 完成时做一次，不每帧检测。

---

## 3. 我的建议总结

| 决策点 | 建议方案 | 理由 |
|---|---|---|
| 脉冲实现 | B（_process 内部插值）| 性能 + 持续状态可控 |
| 配置管理 | B（Dictionary 配置表）| 清晰可扩展 |
| 受击反馈 | B+C（震动 + 红闪）| 适合所有形状 |
| 地面环 | A（_draw）| 建筑不动，最简单 |
| 尘土位置 | C+B（默认 + Inspector 微调）| 开箱即用 |
| 施工尘土频率 | A（固定 0.8 秒）| 够用 |
| 升级双环 | A（_draw 扩散环）| 复用绘制 |
| 城墙连结 | B（脚下金细环）| 直观 |

---

## 4. 接入点 / 涉及文件

### 新增文件

```
scripts/effects/building_activity_visual.gd    # 新组件
```

### 修改文件

| 文件 | 改动 |
|---|---|
| [scenes/buildings/building.tscn](../../scenes/buildings/building.tscn) | 加 BuildingActivityVisual 子节点 |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`_ready`) | 调用 `configure(building_type, body_sprite, seed)` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`_production_process`) | 调用 `set_production(active, ratio)` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`queue_unit`) | 成功后调 `play_order_received()` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`_spawn_next_unit`) | 完成后调 `play_production_completed()` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`_produce_gold`) | 调 `play_resource_tick()` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`start_construction` / 倒计时) | 调 `set_construction(active, ratio)` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`_finish_construction`) | 调 `play_construction_completed()` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`set_age_upgrade_progress`) | 调 `set_age_upgrade(active, ratio)` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`take_damage`) | 调 `play_hit(from_direction)` |
| [scripts/buildings/building.gd](../../scripts/buildings/building.gd) (`die`) | 调 `stop_all()` + 走 PR-2 的爆炸粒子池 |

---

## 5. 9 种建筑配置表（落到 const 字典）

```gdscript
const BUILDING_CONFIGS := {
    BuildingType.BARRACKS: {
        "pulse_strength": 0.015,
        "pulse_interval": 0.8,
        "dust_interval": 1.1,
        "dust_anchor": Vector2(0, 24),     # 门口下方
        "ring_color": null,                 # 不画环
        "complete_feedback": "bounce_strong",
    },
    BuildingType.ARCHERY_RANGE: {
        "pulse_strength": 0.010,
        "pulse_interval": 1.0,
        "dust_interval": 1.5,
        "dust_anchor": Vector2(0, 24),
        "ring_color": null,
        "complete_feedback": "bounce_weak",
    },
    BuildingType.MONASTERY: {
        "pulse_strength": 0.007,
        "pulse_interval": 1.2,
        "dust_interval": 0,                 # 不出尘土
        "ring_color": Color(0.7, 0.85, 1.0), # 白蓝
        "complete_feedback": "light_glow",
    },
    BuildingType.CASTLE: {
        "pulse_strength": 0.005,
        "pulse_interval": 1.5,
        "dust_interval": 0,
        "ring_color": Color(1.0, 0.84, 0.0), # 金
        "complete_feedback": "double_ring",
    },
    BuildingType.TOWER: {
        "pulse_strength": 0.005,             # 很轻
        "pulse_interval": 0,
        "dust_interval": 0,
        "ring_color": null,
        "complete_feedback": "none",
    },
    BuildingType.WALL: {
        "pulse_strength": 0,                 # 不脉冲
        "shake_on_hit": true,                # 用震动
        "ring_color": Color(1.0, 0.84, 0.0, 0.3),  # 连结淡金
    },
    BuildingType.FARM: {
        "pulse_strength": 0.008,
        "pulse_interval": 1.5,
        "dust_interval": 0,
        "ring_color": Color(1.0, 0.84, 0.0),
        "complete_feedback": "gold_flash",
    },
    BuildingType.ACADEMY: {
        "pulse_strength": 0.005,
        "pulse_interval": 1.2,
        "dust_interval": 0,
        "ring_color": Color(1.0, 0.84, 0.0),
        "complete_feedback": "double_ring",
    },
    BuildingType.ALTAR_ARCHER: {
        "pulse_strength": 0.005,
        "pulse_interval": 1.5,
        "dust_interval": 0,
        "ring_color": Color(1.0, 0.84, 0.0),
        "complete_feedback": "big_light_pillar",
    },
}
```

---

## 6. 组件接口

```gdscript
class_name BuildingActivityVisual
extends Node2D

func configure(building_type: int, body: Sprite2D, seed: int) -> void

# 持续状态
func set_production(active: bool, ratio: float) -> void
func set_construction(active: bool, ratio: float) -> void
func set_age_upgrade(active: bool, ratio: float) -> void

# 短事件
func play_order_received() -> void
func play_production_completed() -> void
func play_construction_completed() -> void
func play_resource_tick() -> void
func play_age_upgrade_completed() -> void
func play_hit(from_direction: Vector2) -> void

# 控制
func stop_all() -> void
```

### 优先级

参考建筑方案："优先级：`destroyed > constructing > age_upgrading > producing > idle`。短事件覆盖 0.1-0.4 秒，结束后回到当前持续状态。"

---

## 7. 验证标准

由于沙盒 PR-0 没有建筑 spawn 入口，PR-4 需要扩展沙盒：

- [ ] 沙盒加建筑 spawn 入口（左面板加建筑 tab，复用 building_placer 逻辑）
- [ ] 选兵营 → 让它生产 → 看到门口**尘土**（1.1 秒一次）+ **微震**（1.5%）
- [ ] 兵营入队 → **下沉回弹**（瞬间反馈）
- [ ] 兵营产兵完成 → **弹性回弹** + 出生光柱
- [ ] 让城堡升时代 → 看到持续**金环转动**，临近完成加快
- [ ] 升级完成 → **双环扩散** + 大脉冲
- [ ] 农场产金 → **金环闪一次** + 飘字
- [ ] 城墙受击 → **震动**（不 scale）+ 红闪 0.1 秒
- [ ] 城墙摧毁 → 爆炸（走池）+ **碎片粒子**

---

## 8. 配置说明

### Inspector 可调参数

```
activity_anchor：     尘土/地面环的相对位置（默认按 building_type）
pulse_strength：      0.005 ~ 0.020
pulse_interval：      0.5 ~ 1.5 秒
activity_color：      金 / 蓝白 / 阵营色
use_dust：            是否使用 Dust 序列帧
use_ground_ring：     是否绘制地面环
```

大多数情况不用调，按 building_type 自动选。只有建筑贴图工作点不对（比如门口偏左）时调 `activity_anchor`。

---

## 9. 已知风险

| 风险 | 缓解 |
|---|---|
| 建筑 BodySprite 被 _process 覆盖 base scale | configure() 缓存 base 值 |
| 9 种建筑配置表漏掉某个类型 | `configure()` 收到未知 type 时 push_warning + 用默认配置 |
| 城墙震动影响相邻城墙判断 | 震动只改 position，不改 collision shape |
| 升级环 _draw 与现有 production_circle 重叠 | 环半径错开（升级环 60px，生产圈 40px） |
| 多个建筑同时升级完成，环满屏 | 这是预期行为（仪式感）|
| `take_damage` 调用 `play_hit` 但 attacker 为 null（掉血光环）| from_direction 兜底为 Vector2.ZERO，组件用"通用震动" |

---

## 10. 后续衔接

- **PR-2**：依赖粒子池（dust / debris 走池）
- **PR-5**：建筑爆炸加 screen shake + shockwave
- **PR-7**：T3 学院升级研究时复用升级环逻辑
