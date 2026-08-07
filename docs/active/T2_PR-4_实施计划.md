# PR-T2-4 实施计划：兵种全局升级系统（27 节点 + 机制 + UI 接入）

- **日期**：2026-08-06
- **阶段**：T2（时代升级 + 科技系统 + UI 改造）
- **状态**：⏳ 待启动
- **预计**：7-9 小时
- **关联**：
  - 总览：[T2_实施路线图.md](T2_实施路线图.md)
  - 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 2.3.4 节（D 模块科技树）

---

## 一、Context

PR-T2-4 是 T2 阶段**最大的 PR**：建立兵种全局升级系统，玩家花金币升级，所有该兵种单位即时获得加成。这是 T2 设计的核心机制——"玩家做决策点"。

**前置依赖**：PR-T2-3（详情面板就位，升级按钮有地方挂）

**后续依赖**：PR-T2-5（QW 网格化展示升级节点状态、灰色锁对应时代）

**⚠️ 节点数量说明**：设计文档说"27 个升级节点"，按 D 模块拍板的 5 类清单实际算下来是 **31 个**：
- 通用升级 3 线 × 3 级 = 9
- 单位基础升级 4 线（步 HP/步 DMG/弓 HP/弓 DMG）× 3 级 = 12
- 单位特色升级 2 单位 × 3 级 = 6
- 农场科技 1
- 城堡科技 3
- 合计 31 个

可能设计文档把通用升级的"3 线 × 3 级"按"3 个升级（每级独立涨价）"算了。本 PR 按**实际数据 31 个**实施，后续如果设计需要调整为 27 个再聊。

---

## 二、核心交付

### 2.1 完整 T2 科技树（31 节点）

```
T2 科技树
├── 通用升级组（3 线 × 3 级，1.5x 费用）
│   ├── 通用 HP+    300/600/900 金  每级 +10% HP
│   ├── 通用 DMG+   300/600/900 金  每级 +10% DMG
│   └── 通用 SPD+   300/600/900 金  每级 +10% SPD
├── 单位基础升级（每单位 2 线 × 3 级，1x 费用）
│   ├── 步兵 HP+    200/400/600 金  每级 +10% HP
│   ├── 步兵 DMG+   200/400/600 金  每级 +10% DMG
│   ├── 弓兵 HP+    200/400/600 金  每级 +10% HP
│   └── 弓兵 DMG+   200/400/600 金  每级 +10% DMG
├── 单位特色升级（T1/T2/T3 三级递增解锁）
│   ├── 步兵回血 T1  500 金  每 5s 回 1% 最大 HP
│   ├── 步兵回血 T2  700 金  每 5s 回 5% 最大 HP
│   ├── 步兵回血 T3  1000 金 每 5s 回 10% 最大 HP
│   ├── 弓兵减速箭 T1  500 金  减速 10% / 1s
│   ├── 弓兵减速箭 T2  700 金  减速 20% / 2s
│   └── 弓兵减速箭 T3  1000 金 减速 30% / 3s
├── 农场科技（1 个单次，500 金）
│   └── 产量 +30%
└── 城堡科技（3 个独立单次，每项 500 金）
    ├── 箭塔数值 +20%（攻击/射程/攻速）
    ├── 整体建筑血量 +20%
    └── 兵营类建造速度 +20%
```

### 2.2 升级加成规则（百分比加成）

| 加成类型 | 影响范围 |
|---|---|
| 通用 HP+ | 所有玩家单位（步兵+弓兵+未来 T3 单位）|
| 通用 DMG+ | 同上 |
| 通用 SPD+ | 同上 |
| 单位基础 HP+/DMG+ | 仅该兵种单位 |
| 步兵回血 | 步兵单位（被动每 5s 触发）|
| 弓兵减速箭 | 弓兵攻击（命中附加减速）|
| 农场产量 | 所有农场（产能 +30%）|
| 城堡箭塔 | 所有箭塔（攻击/射程/攻速各 +20%）|
| 城堡血量 | 所有玩家建筑（HP +20%）|
| 城堡兵营造速 | 所有兵营类（建造时间 -20%，即建造速度 +20%）|

### 2.3 升级触发机制

- **即时生效**（无研究时间）：扣金币 → 等级+1 → 所有现有 + 未来单位属性更新
- **金币不够**：按钮灰显，点击无响应（或 floating_text 提示）
- **满级（3/3 或单次）**：按钮变灰，不再可点
- **特色升级分级**：T1 阶段只可升初级，T2 解锁中级，T3 解锁高级

### 2.4 UI 接入

- 升级按钮挂在详情面板的"科技区"（PR-T2-3 预留的 VBoxContainer）
- 按钮视觉：**名称 + 当前等级 + 费用**（例：`步兵 HP+  2/3 → 400 金`）
- 点击 → 即时扣金 + 升级 + 全单位强化
- 升级面板按对象类型显示对应升级：
  - 城堡详情：通用升级 3 线 + 城堡科技 3 项 + 时代升级按钮（PR-T2-1）
  - 兵营详情：步兵基础 2 线 + 步兵特色（按时代解锁）
  - 靶场详情：弓兵基础 2 线 + 弓兵特色（按时代解锁）
  - 农场详情：农场科技 1 项
  - 箭塔详情：无升级（受城堡箭塔科技影响）
  - 步兵单位详情：同兵营
  - 弓兵单位详情：同靶场

### 2.5 隐藏单兵升级 UI

- 现有 `scripts/stats/upgrade_manager.gd`（单兵升级）保留代码
- UI 完全隐藏（不再显示升级按钮）
- 未来"老兵系统"激活时再恢复

---

## 三、改动文件清单

| 文件 | 改动 |
|---|---|
| **新建** `scripts/upgrade/unit_upgrade_data.gd` | 升级节点静态数据（RefCounted）|
| **新建** `scripts/upgrade/unit_upgrade_manager.gd` | 升级核心逻辑（Node，挂 main 下）|
| **新建** `resources/upgrades/` 目录 | 31 个 .tres 升级配置（按 5 类分文件）|
| **新建** `scripts/ui/upgrade_button.gd` | 升级按钮组件（名称+等级+费用）|
| `scripts/units/unit.gd` | 加 `recompute_stats()` 方法（升级时刷新属性）+ 加 `regen_timer`（特色升级）|
| `scripts/units/unit.gd` 弓兵攻击分支 | 加减速箭命中效果 |
| `scripts/buildings/building.gd` | 加 `recompute_stats()` 方法（城堡血量科技影响）|
| `scripts/buildings/building.gd` 农场产金分支 | 读农场科技加成 |
| `scripts/buildings/building.gd` 兵营造兵分支 | 读兵营造速科技影响（如有时）|
| `scripts/buildings/building_placer.gd` | 建造速度科技影响 build_time |
| `scripts/ui/detail_panel.gd`（PR-T2-3 新建）| 科技区接入升级按钮 |
| `scripts/systems/main.gd` | 初始化 unit_upgrade_manager |
| `scripts/systems/game_ui.gd` | 单兵升级 UI 隐藏（移除现有 `_update_info_panel` 里的升级按钮，如有）|

---

## 四、实施步骤

### 步骤 1：升级数据结构 + manager（1.5h）

1. 新建 `scripts/upgrade/unit_upgrade_data.gd`，定义枚举和数据：
```gdscript
class_name UnitUpgradeData extends Resource

enum Category { GENERIC, UNIT_BASE, UNIT_FEATURE, FARM, CASTLE_TOWER, CASTLE_HP, CASTLE_BUILD_SPEED }
enum UnlockAge { T1, T2, T3 }
enum EffectType { PERCENT_HP, PERCENT_DMG, PERCENT_SPD, REGEN, SLOW_ARROW, FARM_YIELD, TOWER_STAT, BUILDING_HP, BUILD_SPEED }

@export var id: StringName
@export var display_name_key: String  # translations.csv key
@export var category: Category
@export var target_unit_id: StringName  # 步兵/弓兵/空
@export var line_id: StringName  # 同 line 内分级（如 soldier_feature_regen）
@export var max_level: int  # 3 或 1
@export var costs: Array[int]  # 长度 = max_level
@export var unlock_age: UnlockAge  # 单位特色用，其他默认 T1
@export var effect_type: EffectType
@export var effect_values: Array[float]  # 每级加成
```

2. 新建 `scripts/upgrade/unit_upgrade_manager.gd`：
```gdscript
extends Node

signal upgrade_purchased(node_id: StringName, new_level: int)

# 升级节点状态：node_id -> current_level
var _levels: Dictionary = {}
# 已加载的节点配置：node_id -> UnitUpgradeData
var _nodes: Dictionary = {}

func initialize() -> void:
    # 加载所有 resources/upgrades/*.tres
    pass

func get_level(node_id: StringName) -> int:
    return _levels.get(node_id, 0)

func get_next_cost(node_id: StringName) -> int:
    var data = _nodes[node_id]
    var lv = get_level(node_id)
    if lv >= data.max_level: return -1
    return data.costs[lv]

func can_purchase(node_id: StringName, current_gold: int, current_age: int) -> bool:
    var data = _nodes[node_id]
    if get_level(node_id) >= data.max_level: return false
    if current_age < data.unlock_age: return false
    return current_gold >= get_next_cost(node_id)

func purchase(node_id: StringName, gold_owner) -> bool:
    # 扣金币 + 等级+1 + 触发全单位刷新
    pass
```

3. 在 main.gd 初始化时创建 unit_upgrade_manager 节点

**验收**：manager 能加载 31 个节点配置，API 可调用。

### 步骤 2：31 个升级配置（2h）

按 5 类创建 .tres 文件：

```
resources/upgrades/
├── generic/                      # 9 个
│   ├── generic_hp.tres           # max_level=3, costs=[300,600,900]
│   ├── generic_dmg.tres
│   └── generic_spd.tres
├── unit_base/                    # 12 个
│   ├── soldier_hp.tres           # max_level=3, costs=[200,400,600]
│   ├── soldier_dmg.tres
│   ├── archer_hp.tres
│   └── archer_dmg.tres
├── unit_feature/                 # 6 个
│   ├── soldier_regen_t1.tres     # max_level=1, cost=[500], unlock_age=T1
│   ├── soldier_regen_t2.tres     # cost=[700], unlock_age=T2
│   ├── soldier_regen_t3.tres     # cost=[1000], unlock_age=T3
│   ├── archer_slow_t1.tres
│   ├── archer_slow_t2.tres
│   └── archer_slow_t3.tres
├── farm/                         # 1 个
│   └── farm_yield.tres           # max_level=1, cost=[500]
└── castle/                       # 3 个
    ├── castle_tower.tres         # max_level=1, cost=[500]
    ├── castle_hp.tres
    └── castle_build_speed.tres
```

每个 .tres 配置：id / display_name_key / category / target_unit_id / max_level / costs / unlock_age / effect_type / effect_values

**验收**：31 个文件存在，editor 里能查看属性，无报错。

### 步骤 3：升级效果应用（2h）

#### 通用 + 单位基础升级
1. unit.gd 加 `recompute_stats(base_stats)` 方法：
   - 从 base_stats 读取原始 HP/DMG/SPD
   - 从 unit_upgrade_manager 查询通用等级 + 单位基础等级
   - 计算最终值：`final_hp = base_hp × (1 + 0.1 × generic_hp_lv) × (1 + 0.1 × unit_base_hp_lv)`
2. 升级触发时遍历所有玩家单位调用 `recompute_stats()`
3. 新单位 spawn 时也调用 `recompute_stats()` 应用当前升级

#### 农场产量
1. building.gd 的 `_produce_gold()` 读 `gold_production_amount` 时叠加农场科技：
   - `final_yield = base_yield × (1 + 0.3 × farm_yield_purchased ? 1 : 0)`

#### 城堡 3 项
1. 城堡血量科技：building.gd 的 `_setup_max_hp()` 时叠加
2. 箭塔科技：箭塔的 attack_damage / attack_range / attack_cooldown 各 ×1.2
3. 兵营造速：building_placer.gd 的 build_time ×0.8（仅兵营类）

#### 单位特色升级
1. 步兵回血：unit.gd 加 `_regen_timer`，每 5s 触发，回血量 = max_hp × regen_rate
2. 弓兵减速箭：弓兵攻击命中时，给目标加 `slow_effect`（move_speed ×0.8，持续 2s）

**验收**：
- 升 1 级通用 HP → 所有单位 HP +10%
- 升 1 级步兵 HP → 仅步兵 HP +10%
- 升农场 → 农场产金从 20 变 26
- 升城堡血量 → 所有玩家建筑 HP +20%
- 步兵升回血 → 5s 后 HP 增加
- 弓兵升减速箭 → 命中后目标移速降低

### 步骤 4：升级 UI 组件（1h）

1. 新建 `scripts/ui/upgrade_button.gd`：
```
┌─────────────────────────────┐
│ 🎯 步兵 HP+    2/3 → 400 金  │
└─────────────────────────────┘
```
- 内部 HBoxContainer：图标 + 名称 Label + 等级 Label + 费用 Label
- 状态：
  - 可购买：正常颜色
  - 金币不够：modulate.a = 0.5
  - 满级（3/3 或单次已购）：变灰 + 文字 "MAX"
  - 时代未解锁（特色升级）：变灰 + 文字 "🔒 需要 T2"

2. 点击信号 `purchase_clicked(node_id)` 连接到 detail_panel

### 步骤 5：详情面板接入升级按钮（1.5h）

1. detail_panel.gd 的 `_show_tech_section(target)` 方法：
   - 根据对象类型查询可用的升级节点列表
   - 实例化对应数量的 UpgradeButton
   - 添加到科技区 VBoxContainer
2. 对象类型 → 升级节点映射：
   - 城堡 → generic_hp / generic_dmg / generic_spd / castle_tower / castle_hp / castle_build_speed + 时代升级按钮（PR-T2-1）
   - 兵营 → soldier_hp / soldier_dmg / soldier_regen_t1/t2/t3
   - 靶场 → archer_hp / archer_dmg / archer_slow_t1/t2/t3
   - 农场 → farm_yield
   - 箭塔 → 无升级（提示"无可用科技"）
   - 步兵单位 → 同兵营
   - 弓兵单位 → 同靶场
3. 点击 UpgradeButton → 调用 unit_upgrade_manager.purchase() → 升级成功后刷新按钮状态 + 全单位属性

**验收**：
- 选中城堡 → 详情面板出现通用升级 + 城堡科技 + 时代升级按钮
- 选中兵营 → 出现步兵升级
- 选中农场 → 出现农场科技
- 点击可购买按钮 → 扣金 + 等级 +1 + 按钮刷新
- 金币不够时点击 → 不响应（或提示）

### 步骤 6：隐藏单兵升级 UI（30min）

1. 找到现有单兵升级 UI 的位置（可能在 `game_ui.gd` 的 `_update_info_panel()` 或 unit 详情子面板）
2. 移除/隐藏相关按钮（保留底层 `upgrade_level` 字段和 stats/upgrade_manager.gd 代码）
3. 测试：现有单兵升级 UI 不可见，未来可用代码 flag 重新启用

**验收**：
- 单兵升级按钮在 UI 中消失
- 单位属性不变化（升级系统的 `_execute_effect` 不被调用）
- stats/upgrade_manager.gd 代码仍存在（保留）

### 步骤 7：测试 + 平衡（1h）

1. 跑一遍 5 类升级各升 1 次，验证效果
2. 测试金币不够、满级、时代未解锁三种灰显状态
3. 测试同时升多个升级（性能 + 数据一致性）
4. 测试新单位 spawn 时属性是否正确（带升级加成）

---

## 五、验收点

### 5.1 升级数据 + manager
- [ ] 31 个 .tres 配置文件存在
- [ ] manager 加载后能查询任意 node_id 的等级、费用、效果
- [ ] can_purchase 正确判断金币/时代/满级

### 5.2 升级效果
- [ ] 通用 HP+1 级 → 所有单位 max_hp 显示值 +10%
- [ ] 单位基础 HP+1 级 → 仅对应兵种 HP +10%
- [ ] 农场产量 +30% → 农场每 10s 产 26 金
- [ ] 城堡血量 +20% → 所有玩家建筑 HP +20%
- [ ] 箭塔 +20% → 箭塔攻击/射程/攻速都提升
- [ ] 兵营造速 +20% → 兵营建造时间从 5s → 4s
- [ ] 步兵回血 → 每 5s HP 增加（按等级比例）
- [ ] 弓兵减速箭 → 命中后目标移速降低

### 5.3 升级 UI
- [ ] 城堡详情科技区有 6 个升级按钮（3 通用 + 3 城堡）
- [ ] 兵营详情科技区有 5 个升级按钮（2 基础 + 3 特色）
- [ ] 升级按钮显示：名称 + 当前等级 + 下级费用
- [ ] 满级按钮显示 "MAX" + 灰显
- [ ] 时代未解锁按钮显示锁 + 灰显
- [ ] 金币不够时按钮变半透明

### 5.4 升级触发
- [ ] 点击可购买按钮 → 扣金 + 等级 +1 + 全单位属性刷新
- [ ] 点击金币不够的按钮 → 不响应（或提示 "INSUFFICIENT_GOLD"）
- [ ] 新 spawn 单位属性带升级加成

### 5.5 单兵升级 UI 隐藏
- [ ] UI 中不再有单兵升级按钮
- [ ] stats/upgrade_manager.gd 代码仍在（grep 验证）
- [ ] 现有游戏功能不报错

---

## 六、风险与注意事项

### 6.1 高风险
- **百分比加成的全单位刷新性能**：升 1 次通用升级要刷新所有玩家单位。建议信号驱动（`upgrade_purchased` 信号 → 单位监听并重算），而非每帧轮询
- **特色升级的复杂效果**：步兵回血要加 Timer，弓兵减速箭要加命中 buff。两者都是新机制，要单独测试
- **31 个 .tres 工作量大**：建议先做核心 5-6 个（通用 HP/DMG/SPD + 农场 + 城堡血量）验证机制，再批量配剩下

### 6.2 中风险
- **数据冲突**：通用 HP+ 和单位基础 HP+ 是叠加（乘法）还是合并？设计文档拍板"百分比加成"，建议叠加（`final = base × (1+0.1×generic) × (1+0.1×unit_base)`），避免线性叠加导致后期超模
- **时代未解锁判断**：单位特色升级 T2/T3 等级需要读 PR-T2-1 的 age 状态。同步后才能验证，否则用 mock
- **建筑造价的影响**：兵营递增造价（300/350/400）和兵营造速 +20% 是否冲突？建造速度影响 build_time（5s），不影响 cost（300 金）

### 6.3 注意事项
- **节点命名**：upgrade_button 实例命名 `UpgradeButton_<node_id>`，避免 get_children 误匹配
- **国际化**：display_name_key 用 translations.csv 的 key（如 `UPGRADE_GENERIC_HP_NAME`），不要硬编码中文
- **保留单兵升级代码**：unit.gd 的 `upgrade_level` 字段不要删，stats/upgrade_manager.gd 文件不要删。只是 UI 不显示按钮
- **资源加载**：31 个 .tres 用 `load()` 或 `preload()`？建议 manager 在 initialize 时遍历目录加载，用 `DirAccess` 列文件

---

## 七、与 PR-T2-3 的衔接

PR-T2-3 完成后，detail_panel.gd 的科技区是空 VBoxContainer。本 PR 实例化 UpgradeButton 填入：

```gdscript
# detail_panel.gd 的 _show_tech_section 改造
func _show_tech_section(target):
    for child in _tech_container.get_children():
        child.queue_free()  # 清空占位
    
    var upgrade_ids = _get_upgrades_for_target(target)
    for node_id in upgrade_ids:
        var btn = preload("res://scripts/ui/upgrade_button.gd").new()
        btn.setup(node_id, unit_upgrade_manager)
        btn.purchase_clicked.connect(_on_upgrade_clicked)
        _tech_container.add_child(btn)
```

---

## 八、关联文档

- 总览：[T2_实施路线图.md](T2_实施路线图.md)
- 设计：[T2阶段设计_科技与UI.md](T2阶段设计_科技与UI.md) 第 2.3.4 节（D 模块完整科技树）
- 前置：[T2_PR-3_实施计划.md](T2_PR-3_实施计划.md)（详情面板科技区）
- 后续：[T2_PR-5_实施计划.md](T2_PR-5_实施计划.md)（QW 网格化展示升级状态）
