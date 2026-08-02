# T1 PR-2 实施计划

- **日期**：2026-08-02
- **阶段**：T1 操作端 UI 完善 + PR-1 遗漏补做
- **关联文档**：
  - 主计划：[T1_实施计划.md](T1_实施计划.md)（本文档是其 §5.1 摘要的展开）
  - PR-1 已完成（commit `c65c2d9`）
- **状态**：✅ 决策对齐 / ✅ 系统调研完成 / ⏳ 待启动
- **工时估算**：~9.7h（1-2 天）

---

## Context

PR-1（commit `c65c2d9`）完成了 T1 经济底层，验收通过。但实施过程中**简化/遗漏了 4 项**，导致操作端 UI 不完整：

1. **兵营 production_queue 完全没做** —— 主计划 §4.2 D 节明确要的"队列系统"被简化为"立即 spawn"
2. **农场上限检查缺失** —— 计划要求"农场达 5 个无法再建"，代码里没限制
3. **兵营解锁前置缺失** —— 计划要求"无农场不能造兵营"，代码里没检查
4. **范围外 floating_text 双反馈没接** —— D6 决策"预览变红 + floating_text"只做了一半

PR-2 的目标：补齐上述 4 项底层接口，并在其上完成操作端 UI 体验（造价显示 / 多维灰显 / 兵营头顶队列 UI / 提示文案完善）。

**当前出兵路径**（[main.gd:1285-1290](../scripts/main.gd)）：`_do_place → _find_nearest_barracks → 直接 spawn`。PR-2 要改成"入队 + cooldown 出兵"，并把 `_spawn_produced_unit`（[building.gd:507](../scripts/buildings/building.gd)，目前 dead code）重新激活。

---

## 一、决策汇总

| # | 项 | 决策 | 理由 |
|---|---|---|---|
| D1 | PR-1 遗漏补做范围 | **全补**（队列 + 上限 + 前置 + floating_text） | 用户已确认 |
| D2 | 兵营队列系统 | **顺手做**（数据 + 信号 + cooldown + 头顶 UI 一起） | 用户已确认 |
| D3 | Disable reason 数据结构 | **Enum BuildBlockReason** | 用户已确认；翻译 key 一一对应 |
| D4 | 造价 Label 风格 | **SC2 风格**（右下角纯数字，够=白，不够=红，其他=灰） | 用户已确认 |
| D5 | production_cooldown 数值 | **25.0 → 6.0** | 25s 太慢，6s 符合"5-8s 完成出兵"体感 |
| D6 | 队列上限 | **5**（QUEUE_MAX，从 stats 读） | 沿用主计划 §4.2 D 节 |
| D7 | 农场上限 | **5**（max_farms，从 farm_stats 读） | 沿用主计划 §4.3 验收 |
| D8 | 兵营解锁前置 | **requires_farm=true**（仅 BARRACKS） | 计划要求 |
| D9 | 队列 UI 节点归属 | **挂到 building 子节点**（不复用 _production_circle） | 圆圈是产金反馈，头顶 ProgressBar 是兵营专属 |
| D10 | queue_changed 通知路径 | **building → main → game_ui**（不经 building 直接持有 ui） | 避免循环依赖 |
| D11 | 头顶 UI 刷新方式 | **queue_changed emit 时重排 icon + _process 每帧刷进度条** | 进度条需要每帧平滑，icon 只在 push/pop 时变 |

---

## 二、改动文件清单

### 代码层（7 个）

| # | 文件 | 改动要点 |
|---|---|---|
| 1 | [building_stats.gd](../scripts/stats/building_stats.gd) | +3 字段：`max_farms: int = 5` / `production_queue_max: int = 5` / `requires_farm: bool = false` |
| 2 | [building_placer.gd](../scripts/systems/building_placer.gd) | +`enum BuildBlockReason` + `check_build_block(mode, click_pos) -> Reason` + `reason_to_translation_key(r)` + `_count_built(type)` / `_has_farm()`；点击建造被 OUT_OF_RANGE 阻挡时调 floating_text |
| 3 | [building.gd](../scripts/buildings/building.gd) | +`production_queue: Array[StringName]` + `queue_max`（从 stats）+ `signal queue_changed(building)`；`queue_has_space()` / `queue_unit(id) -> bool` / `_spawn_next_unit()`（迁移自 `_spawn_produced_unit`，激活 dead code）；`_production_process` 改成"队列非空才计时 → pop_front → spawn → 重置 timer"；`get_queue_state() -> Dictionary` 供 UI 查 |
| 4 | [main.gd](../scripts/main.gd) | `_do_place` 单位分支：从"立即 spawn"改"找兵营 + queue_unit"；监听兵营 `queue_changed` → 转发 `game_ui.refresh_barracks_queue(building)` |
| 5 | [game_ui.gd](../scripts/systems/game_ui.gd) | `_add_icon_button` 新增 `CostLabel`（右下角，PRESET_BOTTOM_RIGHT，字号 14，黑描边）；`_update_button_affordability` 改调 `check_build_block(mode)` → 按 reason 设 modulate.a + disabled + CostLabel 颜色；新增 `refresh_barracks_queue(building)` 接口 |
| 6 | [barracks_queue_indicator.gd](../scripts/ui/barracks_queue_indicator.gd) **(新建)** | 头顶 5 个 TextureRect slot + 第 1 个上的 ProgressBar；`_ready` 取 building 引用 + connect queue_changed；`_process` 每帧刷进度条 |
| 7 | [game_ui.gd](../scripts/systems/game_ui.gd) `_on_icon_hover` | hover_anim 在 disabled 状态跳过（避免灰显按钮悬停动画误导）—— 仅在 `_on_icon_hover` 入口加守卫，不动 button_factory 本身 |

### 资源层（2 个）

| # | 文件 | 改动 |
|---|---|---|
| 8 | [barracks_stats.tres](../resources/stats/buildings/barracks_stats.tres) | `production_cooldown = 25.0 → 6.0`；显式 `requires_farm = true`；显式 `production_queue_max = 5` |
| 9 | [barracks_queue_indicator.tscn](../scenes/ui/barracks_queue_indicator.tscn) **(新建)** | Control 容器（宽 80 / 高 24）+ 5 个 TextureRect（横排，间距 16）+ 1 个 ProgressBar（覆盖第 1 个 slot） |

### 文案层（1 个）

| # | 文件 | 改动 |
|---|---|---|
| 10 | [translations.csv](../locales/translations.csv) | +2 行：`FARM_LIMIT,Farm limit reached,农场已达上限,農場が上限です`；`NO_GOLD,Not enough gold,金币不足,金貨不足`。⚠️ 改完需重启游戏（无 hot reload） |

---

## 三、关键实现要点

### A. BuildBlockReason enum

```gdscript
# building_placer.gd
enum BuildBlockReason { OK, NO_GOLD, FARM_LIMIT, NEED_FARM, OUT_OF_RANGE, QUEUE_FULL }

func check_build_block(mode: int, click_pos: Vector2 = Vector2.ZERO) -> BuildBlockReason:
    var cost := get_current_cost(mode)
    if _main_node.gold < cost:
        return BuildBlockReason.NO_GOLD
    var bt: int = D.PLACE_MODE_TO_BUILDING.get(mode, -1)
    if bt == BuildingType.FARM and _count_built(BuildingType.FARM) >= _max_farms():
        return BuildBlockReason.FARM_LIMIT
    if bt == BuildingType.BARRACKS and not _has_farm():
        return BuildBlockReason.NEED_FARM
    if click_pos != Vector2.ZERO and not is_in_buildable_area(click_pos):
        return BuildBlockReason.OUT_OF_RANGE
    return BuildBlockReason.OK

static func reason_to_translation_key(r: int) -> StringName:
    match r:
        BuildBlockReason.NO_GOLD:     return &"NO_GOLD"
        BuildBlockReason.FARM_LIMIT:  return &"FARM_LIMIT"
        BuildBlockReason.NEED_FARM:   return &"NEED_FARM"
        BuildBlockReason.OUT_OF_RANGE: return &"OUT_OF_RANGE"
        BuildBlockReason.QUEUE_FULL:  return &"QUEUE_FULL"
    return &""
```

辅助函数：
```gdscript
func _count_built(type: int) -> int:
    var n := 0
    for b in get_tree().get_nodes_in_group("player_buildings"):
        if b.building_type == type:
            n += 1
    return n

func _max_farms() -> int:
    var s = BuildingStatsRegistry.get_by_type(BuildingType.FARM)
    return s.max_farms if s else 5

func _has_farm() -> bool:
    return _count_built(BuildingType.FARM) > 0
```

### B. production_queue 系统

```gdscript
# building.gd（BARRACKS 实例）
var production_queue: Array[StringName] = []
var queue_max: int = 5  # _setup_stats 时从 stats 覆盖
signal queue_changed(building: Node)

func queue_has_space() -> bool:
    return production_queue.size() < queue_max

func queue_unit(unit_id: StringName) -> bool:
    if not queue_has_space(): return false
    production_queue.append(unit_id)
    queue_changed.emit(self)
    return true

# _production_process 改造（覆盖 building.gd:485-505）
func _production_process(delta: float) -> void:
    if disable_production or production_cooldown <= 0.0: return
    if NetworkManager.is_online:
        if _production_circle:
            _production_circle.update_progress(production_timer / production_cooldown)
        return
    # T1: CASTLE/FARM 自动产金（保留）
    if building_type == BuildingType.CASTLE or building_type == BuildingType.FARM:
        production_timer += delta
        if _production_circle:
            _production_circle.update_progress(production_timer / production_cooldown)
        if production_timer >= production_cooldown:
            production_timer = 0.0
            _produce_gold()
        return
    # T1 PR-2: BARRACKS 走队列
    if building_type != BuildingType.BARRACKS: return
    if production_queue.is_empty():
        production_timer = 0.0
        if _production_circle:
            _production_circle.update_progress(0.0)
        return
    production_timer += delta
    if _production_circle:
        _production_circle.update_progress(production_timer / production_cooldown)
    if production_timer >= production_cooldown:
        production_timer = 0.0
        _spawn_next_unit()

func _spawn_next_unit() -> void:
    if production_queue.is_empty(): return
    var stats_id := production_queue.pop_front()
    # 复用 _spawn_produced_unit 的剩余逻辑（场景路由 / 集结点 / net_id / 死信号 / AI）
    # 把原 _spawn_produced_unit 主体（building.gd:514-575+）搬过来，
    # stats_id 不再从 variant_ids 取，而是从 pop_front 取
    queue_changed.emit(self)

func get_queue_state() -> Dictionary:
    return {
        "queue": production_queue.duplicate(),
        "remaining": max(0.0, production_cooldown - production_timer),
        "total": production_cooldown,
        "current": production_queue[0] if not production_queue.is_empty() else &"",
    }
```

### C. _do_place 改造（main.gd:1285）

```gdscript
if D.is_unit_mode(place_mode):
    var unit_type: int = D.PLACE_MODE_TO_UNIT[place_mode]
    var stats_id: StringName = D.PLACE_MODE_TO_STATS_ID.get(place_mode, &"")
    var barracks := _find_nearest_barracks(click_pos)
    if barracks == null:
        _show_floating_text(click_pos, tr("NO_BARRACKS"), Color.RED)
        return
    if not barracks.queue_has_space():
        _show_floating_text(barracks.position, tr("QUEUE_FULL"), Color.RED)
        return
    barracks.queue_unit(stats_id if stats_id != &"" else _default_stats_id_for(unit_type))
    gold -= cost
    ui_module.update_gold_display(gold)
    placed = true
```

> ⚠️ 顺序：先 `queue_unit` 失败再 return，gold 不扣。

### D. 兵营头顶 UI

**实例化时机**：building.gd `_ready` / `_setup_visual` 末尾：
```gdscript
if building_type == BuildingType.BARRACKS:
    var indicator = preload("res://scenes/ui/barracks_queue_indicator.tscn").instantiate()
    add_child(indicator)
    indicator.position = Vector2(-40, -stats.grid_size.y * 32 - 50)  # 居中+头顶上方
    indicator.setup(self)  # 传 building 引用 + connect queue_changed
```

**indicator 刷新逻辑**：
```gdscript
# barracks_queue_indicator.gd
var _building: Node
var _slots: Array[TextureRect] = []

func setup(b: Node) -> void:
    _building = b
    b.queue_changed.connect(_on_queue_changed)
    _on_queue_changed(b)

func _on_queue_changed(_b: Node) -> void:
    var state := _building.get_queue_state()
    for i in range(_slots.size()):
        _slots[i].modulate.a = 1.0 if i < state.queue.size() else 0.2
        if i < state.queue.size():
            _slots[i].texture = UnitStatsRegistry.get_icon(state.queue[i])

func _process(_delta: float) -> void:
    if _building == null or not is_instance_valid(_building): return
    var state := _building.get_queue_state()
    $ProgressBar.value = 0.0 if state.current == &"" else (1.0 - state.remaining / state.total) * 100.0
```

### E. CostLabel（game_ui.gd:666 _add_icon_button）

```gdscript
# 在 wrapper 内 btn 之后追加
var cost_label := Label.new()
cost_label.name = "CostLabel"
cost_label.text = str(_main_node.building_placer.get_current_cost(mode))
cost_label.add_theme_font_size_override("font_size", 14)
cost_label.add_theme_color_override("font_color", Color.WHITE)
cost_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
cost_label.add_theme_color_override("font_shadow_offset", Vector2(1, 1))
cost_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
cost_label.offset_left = -28; cost_label.offset_right = -4
cost_label.offset_top = -18; cost_label.offset_bottom = -2
cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
wrapper.add_child(cost_label)
```

### F. _update_button_affordability 多维扩展（game_ui.gd:1063）

```gdscript
func _update_button_affordability(_current_gold: int) -> void:
    for mode in ui_buttons:
        var wrapper: Control = ui_buttons[mode].wrapper
        var btn: Button = ui_buttons[mode].button
        var reason: int = _main_node.building_placer.check_build_block(mode)
        var ok := reason == BuildingPlacer.BuildBlockReason.OK
        wrapper.modulate.a = 1.0 if ok else 0.5
        btn.disabled = not ok
        var cl: Label = wrapper.get_node_or_null("CostLabel")
        if cl:
            var col := Color.WHITE
            if not ok:
                col = Color.RED if reason == BuildingPlacer.BuildBlockReason.NO_GOLD else Color(0.6, 0.6, 0.6)
            cl.add_theme_color_override("font_color", col)
```

⚠️ `check_build_block` 不传 click_pos（建造栏按钮无位置概念），OUT_OF_RANGE 不会在按钮态触发——只在实际点击地图建造时触发 floating_text。两者职责分离。

### G. 范围外 floating_text 接入

`_do_place` 在 main.gd 里调用。建议加守卫：

```gdscript
# main.gd _do_place 顶部，gold 检查之后
var reason := building_placer.check_build_block(place_mode, click_pos)
if reason == BuildingPlacer.BuildBlockReason.OUT_OF_RANGE:
    _show_floating_text(click_pos, tr("OUT_OF_RANGE"), Color.RED)
    return
if reason != BuildingPlacer.BuildBlockReason.OK:
    # 其他 reason（NO_GOLD/FARM_LIMIT/NEED_FARM）UI 已经灰显，这里是双保险
    var key := BuildingPlacer.reason_to_translation_key(reason)
    if key != &"":
        _show_floating_text(click_pos, tr(key), Color.RED)
    return
```

`_show_floating_text` 辅助函数（main.gd 已有调用先例 line 1292）：
```gdscript
func _show_floating_text(pos: Vector2, text: String, color: Color) -> void:
    var ft := Node2D.new()
    ft.set_script(load("res://scripts/effects/floating_text.gd"))
    get_parent().add_child(ft)  # 加到 world 节点，跟随相机
    ft.setup(text, color, pos)
```

---

## 四、PR-2 验收清单

### 造价显示（D-cost label）
- [ ] 建造栏每个图标右下角显示纯数字造价（字号 14 + 黑描边）
- [ ] 农场造价 100 → 250 → 400 → 550 → 700 随已建数量递增
- [ ] 数字颜色：金币够=白，不够=红，其他限制=灰

### 灰显与多维 disable reason
- [ ] 金币不足：modulate.a = 0.5 + 数字红色 + disabled
- [ ] 农场达 5 上限：modulate.a = 0.5 + 数字灰色 + disabled
- [ ] 兵营无前置农场：modulate.a = 0.5 + 数字灰色 + disabled
- [ ] 金币足够且无限制：modulate.a = 1.0 + 数字白色

### 兵营队列系统
- [ ] Q+1 后点击地图 → 找最近兵营 → 入队（不立即 spawn）
- [ ] 无兵营按 Q+1 → 点击地图 → 红色 floating_text "No barracks available"
- [ ] 队列已满（5）按 Q+1 → 兵营位置红色 floating_text "Queue full"
- [ ] 兵营每 6s 出 1 兵（节奏从 25s 调到 6s）
- [ ] 出兵位置 = 兵营旁（复用 _find_valid_spawn_position）
- [ ] 出兵扣 50 金 + 触发 `[Tech] +5 produce_unit`（沿用 game_spawner.gd:350）

### 兵营头顶队列 UI
- [ ] 仅 BARRACKS 显示（其他建筑不挂）
- [ ] 5 个 icon slot 横排，未用槽位 modulate.a = 0.2
- [ ] 第 1 个 icon 上的 ProgressBar 0→100 循环（period = production_cooldown）
- [ ] 队列首单位完成 → spawn → 所有 icon 左移
- [ ] 出兵后队列空 → ProgressBar 归零

### 提示文案
- [ ] place_mode_label 仍显示 `Place Farm $100 (Esc cancel)` 格式（PLACE_BUILDING line 44 已含 `%s $%d`）
- [ ] 翻译 key NO_GOLD / FARM_LIMIT / NEED_FARM / OUT_OF_RANGE / QUEUE_FULL / NO_BARRACKS 中英日均生效

### floating_text 反馈
- [ ] 范围外点击建造：click 位置红色 "Out of build range"
- [ ] 队列已满按生产键：兵营位置红色 "Queue full"
- [ ] 无兵营按生产键：click 位置红色 "No barracks available"

---

## 五、风险与陷阱

| # | 风险 | 应对 |
|---|---|---|
| 1 | `production_cooldown 25→6` 改动影响数值平衡 | 暂只改 barracks_stats.tres 一处；其他建筑（CASTLE/FARM 产金）保持 25s 不动；PR-5 验证时再回看 |
| 2 | `_spawn_produced_unit` 复用 + lockstep 协议注释（building.gd:548-555）说明两端 net_id 可能不同步 | PR-2 仅保证单机正确，联机模式已知是 T2+ 债务，不修 |
| 3 | button_factory 不支持 disabled 状态，hover_anim 在灰显时仍触发 | `_on_icon_hover` (game_ui.gd:836) 入口加 `if btn.disabled: return` 守卫 |
| 4 | translations.csv 改完需重启 | 所有翻译改动一次性提交，避免反复重启 |
| 5 | queue_changed 信号通知路径 building → main → ui | building 不直接持有 ui 引用；main 在兵营创建时 connect 信号 |
| 6 | 既有 `_production_circle`（building.gd:493）与头顶 ProgressBar 功能重叠 | _production_circle 保留作为通用反馈（CASTLE/FARM/BARRACKS 都显示）；头顶 ProgressBar 仅 BARRACKS 显示队列首单位进度 |
| 7 | barracks_queue_indicator.tscn 是新建场景 | ⚠️ 新建后必须 `godot --headless --import` 生成 .import 文件 |
| 8 | `production_queue_max` / `requires_farm` 字段加到 BuildingStats 后，旧 .tres（castle/wall/tower 等）需保持默认值不破坏 | 用 `= 5` / `= false` 默认值，旧 .tres 不显式 set 也能用 |

---

## 六、工时估算

| 改动 | 工时 |
|---|---|
| building_stats.gd +3 字段 | 0.2h |
| building_placer.gd enum + check + farm_limit/barracks_prereq + floating_text 入口 | 1.5h |
| building.gd production_queue 全套 + _production_process 改造 | 2.0h |
| main.gd _do_place 改队列 + queue_changed 转发 + _show_floating_text | 1.0h |
| game_ui.gd CostLabel + 多维 affordability + refresh_barracks_queue | 1.5h |
| barracks_queue_indicator.gd/.tscn 新建 | 1.5h |
| barracks_stats.tres 数值调整 + farm_stats.tres 显式 set | 0.2h |
| translations.csv +2 行 + 重启验证 | 0.3h |
| 联调 / 验证 / 调试 | 1.5h |
| **合计** | **~9.7h** |

> 主计划文档原估 3-4h（纯 UI），扩到补 PR-1 遗漏后约 9-10h。可在 1-2 天内完成。

---

## 七、Verification（实施后端到端测试）

### 步骤 1：启动游戏
```bash
"E:\其他\chorme_download\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe" --path "E:\godot\rts\godot_rts_start"
```

### 步骤 2：主菜单 "T1 测试" 入口

### 步骤 3：按验收清单逐项验证
1. 开局观察建造栏右下角数字（应显示 100 / 100 / 300 / 50 / 50 五个数字）
2. 农场造价递增：连续造 5 个农场，每个造完后再看右下角数字（应 100→250→400→550→700）
3. 第 6 个农场：建造栏农场图标变灰（modulate.a=0.5），数字灰色
4. 没造农场时直接按 W+3（兵营）：图标灰，数字灰
5. 造 1 农场后按 W+3：图标恢复，可建造
6. 按 Q+1 点击地图空地：观察兵营头顶 icon slot 亮起 1 个 + ProgressBar 启动
7. 连续按 Q+1 点击 6 次：第 6 次出现红色 "Queue full"
8. 等待 6s：第 1 个单位 spawn，icon 左移
9. 主基地远处点击建造：红色 "Out of build range" floating_text
10. 后端日志检查：`[Tech] +5 (produce_unit)` 队列出兵时仍触发；无新增 ERROR/WARNING

### 步骤 4：检查已知问题清单
对照 `project_known_backend_warnings` 内存，确保未新增 WARNING/ERROR。

---

## 八、与主文档关系

本计划是 [T1_实施计划.md](T1_实施计划.md) §5.1 摘要的展开。完成后：
- T1_实施计划.md §3.1 PR-2 状态改为 ✅
- §5.1 摘要末尾加链接指向本文档
- 后续 PR-3（骚扰波次）启动时，本计划归档到 `docs/done/`

---

## 九、待实施时确认项

- [ ] `_production_circle` 与新 ProgressBar 是否能共用同一 progress 数据（避免双倍计时）
- [ ] `_find_nearest_barracks` 是否考虑队列已满状态（找次近兵营）—— 当前实现见 main.gd:1506
- [ ] barracks_queue_indicator.tscn 内 ProgressBar 的样式（默认太丑，可能要自定义 StyleBoxFlat）
- [ ] PLACE_MODE_TO_STATS_ID 在 Q+1 时是否传了非空 stats_id（影响变体单位 spawn）
