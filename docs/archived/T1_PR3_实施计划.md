# T1 PR-3 实施计划

## Context

PR-1（commit `c65c2d9`）完成了 T1 经济底层，PR-2 补完了操作端 UI 体验。当前 T1 测试关卡**只有静态守军，没有动态骚扰** —— 玩家造完农场 + 兵营后无事可做，验证不到"防守 harass"的核心玩法循环。

PR-3 的目标：在 T1 测试关卡注入 4 波骚扰（敌方城堡 → 玩家城堡），让玩家体验完整的经济→军事→防守闭环。所有玩法决策已在 [T1_实施计划.md](docs/active/T1_实施计划.md) §5.2 敲定（Q3-1~Q3-6 + 4 波配置表），本计划是它的可执行展开。

**当前 WaveManager 状态**：
- 节点级 @export waves（场景级配置，不走 map_config）
- 单阶段 delay 驱动：`_start_next_wave` 设 `_countdown = delay` → 倒计时 → spawn
- 已有信号 `wave_started` / `countdown_updated` / `all_waves_completed`，main.gd 已 connect

**主要偏离**：
1. 主计划 schema 的 `warning_time` / `spawn_time` 是**绝对游戏秒数**（90s/120s），当前 wave_manager 是**相对 delay** → 需重构为绝对时间驱动
2. map_config.gd 无 waves 字段，main.gd 不注入 waves 到 WaveManager
3. `_calc_formation_positions` 无 circle 阵型（[game_spawner.gd:369](scripts/systems/game_spawner.gd)）

---

## 一、决策汇总（已敲定，引自主计划 §5.2）

| # | 项 | 决策 | 来源 |
|---|---|---|---|
| Q3-1 | 警告 UI | objectives_panel 倒计时（已实现）+ 新建 warning_marker.tscn 红色脉冲 | 已敲定 |
| Q3-2 | 配置存储 | map_config 新增 `waves: Array[Dictionary]` 字段（数据驱动）| 已敲定 |
| Q3-3 | spawn 位置 | circle 模式（敌方城堡周围）；schema 留 `spawn_pattern` 字段 | 已敲定 |
| Q3-4a | 步兵 stats | 复用 soldier（type=5, stats_id=&"soldier"）| 已敲定 |
| Q3-4b | 精英 stats | 新建 elite_vanguard_stats.tres（HP 150 / ATK 18 / 速度 100 / scale 1.2），复用 soldier.tscn | 已敲定 |
| Q3-5 | 倒计时粒度 | 秒级 + 进度条（objectives_panel 已实现）| 已敲定 |
| Q3-6 | 最后警告 | 不要，倒计时到点直接出兵 | 已敲定 |

### 4 波配置（已敲定）

| 波 | warning_time | spawn_time | 步兵 | 弓兵 | 精英 | 总 DPS |
|---|---|---|---|---|---|---|
| 1 | 90s (1:30) | 120s (2:00) | 3 | 0 | 0 | 50 |
| 2 | 210s (3:30) | 240s (4:00) | 4 | 1 | 0 | 75 |
| 3 | 330s (5:30) | 360s (6:00) | 6 | 2 | 1 | 128 |
| 4 | 450s (7:30) | 480s (8:00) | 8 | 3 | 2 | 194 |

固定 120s 间隔，warning 持续 30s。

### 推演决策（实施时按此走，不在问用户）

| # | 项 | 决策 | 理由 |
|---|---|---|---|
| D1 | 时间驱动模式 | **绝对时间**（启动记 `_start_time`，每帧 `now - _start_time` 比较 warning_time/spawn_time）| 主计划 schema 是绝对秒数 |
| D2 | wave_started emit 时机 | spawn_time 触发（不再 warning 阶段 emit）| 语义清晰；当前 `_on_wave_started` 仅 reset 标志，不影响 objectives_panel |
| D3 | 新信号 wave_warning_triggered | warning_time 触发，参数 `(wave_number, spawn_pos)` | main.gd 据此实例化 warning_marker |
| D4 | type=5 沿用 | 主计划惯例，注释"走 UNIT_SCENES fallback 到 soldier.tscn" | 不破坏现有惯例 |
| D5 | warning_marker 自毁 | marker 启动时 set_lifetime(spawn_time - warning_time = 30s) | 不依赖 main.gd 显式 free |
| D6 | circle 阵型 radius | 默认 80.0，schema 字段 `spawn_radius` | 主计划已定 |
| D7 | elite_vanguard 路径 | `resources/stats/elite_vanguard_stats.tres`（直接在 stats/ 下，与 soldier_stats.tres 同目录）| 沿用现有目录结构 |
| D8 | 4 波全 circle 阵型 | 不混用 line/grid | 主计划已定 |

---

## 二、改动文件清单

### 代码层（5 个）

| # | 文件 | 改动要点 |
|---|---|---|
| 1 | [map_config.gd](scripts/map_config.gd) | 新增 `@export var waves: Array[Dictionary] = []`（直接在 scripts/ 下，非 scripts/maps/） |
| 2 | [wave_manager.gd](scripts/systems_game/wave_manager.gd) | **重构为绝对时间驱动**：`_ready` 记 `_start_time`；`_process` 每帧遍历 waves 找未触发的 warning/spawn 事件；warning_time 到 → emit `wave_warning_triggered(num, spawn_pos)`；spawn_time 到 → emit `wave_started(num)` + 调 spawn_enemy_wave_v2(formation=circle, radius=spawn_radius)；保留 `countdown_updated(num, remaining, total)` 让 objectives_panel 显示倒计时；新增 `wave_warning_triggered` 信号声明 |
| 3 | [game_spawner.gd](scripts/systems/game_spawner.gd) | `_calc_formation_positions`（static func, line 369）加 circle case + 新增 `radius: float = 80.0` 第 5 参数；`spawn_enemy_wave_v2` 同步加 radius 参数转发 |
| 4 | [main.gd](scripts/main.gd) | `_setup_wave_manager`（line 607-616）扩展：先 `child.waves = map_config.waves`（如非空）再 connect；追加 `child.wave_warning_triggered.connect(_on_wave_warning_triggered)`；新增 `_on_wave_warning_triggered(wave_number, spawn_pos)` 实例化 warning_marker |
| 5 | [warning_marker.gd](scripts/effects/warning_marker.gd) **(新建)** | Node2D + `_draw` 程序化绘制红色脉冲圆环（参考 [objective_marker.gd](scripts/effects/objective_marker.gd)）；`setup(wave_number, lifetime=30.0)` 内部 Timer 自毁；`_process` 跑呼吸动画（scale 1.0±0.1，alpha 0.5±0.2）|

### 资源层（3 个）

| # | 文件 | 改动 |
|---|---|---|
| 6 | [map_t1_economy_test_config.tres](resources/map_t1_economy_test_config.tres) | 加 `waves = Array[Dictionary]([...])` + 4 波数据（按 schema 写全） |
| 7 | [map_t1_economy_test.tscn](scenes/maps/map_t1_economy_test.tscn) | 加 WaveManager 子节点（无 waves 配置，运行时由 main.gd 注入） |
| 8 | [elite_vanguard_stats.tres](resources/stats/elite_vanguard_stats.tres) **(新建)** | 复制 soldier_stats.tres 改：`id=&"elite_vanguard"`, `max_hp=150`, `attack_damage=18`, `move_speed=100`, `sprite_scale=1.2`；其他字段同 soldier |

### 场景层（1 个）

| # | 文件 | 改动 |
|---|---|---|
| 9 | [warning_marker.tscn](scenes/effects/warning_marker.tscn) **(新建)** | 根节点 WarningMarker，挂 warning_marker.gd；⚠️ 新建后 `godot --headless --import` 生成 .import |

### 文案层（0 个）

翻译键已有（PR-1 已预备），无需改 translations.csv。

---

## 三、关键实现要点

### A. wave_manager.gd 绝对时间驱动重构

```gdscript
# 新增字段
var _start_time: float = -1.0
var _triggered_warnings: Dictionary = {}  # wave_number -> bool
var _triggered_spawns: Dictionary = {}     # wave_number -> bool

# 新信号
signal wave_warning_triggered(wave_number: int, spawn_pos: Vector2)

func start_waves() -> void:
    if waves.is_empty(): return
    _start_time = Time.get_ticks_msec() / 1000.0
    current_wave = -1
    set_process(true)

func _process(delta: float) -> void:
    if _start_time < 0.0: return
    var now: float = Time.get_ticks_msec() / 1000.0 - _start_time
    for i in range(waves.size()):
        if _triggered_spawns.get(i, false): continue
        var w: Dictionary = waves[i]
        var warning_time: float = w.get("warning_time", -1.0)
        var spawn_time: float = w.get("spawn_time", -1.0)
        if spawn_time < 0.0: continue  # 跳过无效波
        # warning 触发（仅一次）
        if warning_time >= 0.0 and now >= warning_time and not _triggered_warnings.get(i, false):
            _triggered_warnings[i] = true
            var spawn_pos: Vector2 = w.get("spawn_pos", Vector2.ZERO)
            wave_warning_triggered.emit(i, spawn_pos)
        # 当前最近未触发的波：emit countdown_updated
        if not _triggered_spawns.get(i, false) and now < spawn_time:
            var remaining: float = spawn_time - now
            if warning_time < 0.0 or now >= warning_time:
                countdown_updated.emit(i, remaining, waves.size())
        # spawn 触发
        if now >= spawn_time:
            _triggered_spawns[i] = true
            _spawn_wave(i)
            wave_started.emit(i)  # 移到 spawn 时 emit（D2）
            if i == waves.size() - 1:
                all_waves_completed.emit()

func _spawn_wave(i: int) -> void:
    var w: Dictionary = waves[i]
    var groups: Array = w.get("groups", [])
    var spawn_center: Vector2 = w.get("spawn_pos", _resolve_spawn_center(w))
    var formation: String = w.get("spawn_pattern", "column")  # schema 字段 spawn_pattern
    var radius: float = w.get("spawn_radius", 80.0)
    var wave_attack: bool = w.get("wave_attack", true)
    var wave_target: Vector2 = w.get("wave_target", Vector2.ZERO)
    game_controller.call("spawn_enemy_wave_v2", groups, spawn_center, wave_attack, wave_target, formation, 50.0, radius)
```

**关键陷阱**：
- `clear_then_next` 模式不兼容绝对时间驱动 —— PR-3 T1 测试关卡用 `clear_then_next=false`（按时间自动出），不破坏现有逻辑
- 旧场景依赖 `delay` 字段 → 添加兼容：`var spawn_time: float = w.get("spawn_time", w.get("delay", -1.0))`
- `wave_started` 时机改了（D2），但 `_on_wave_started` 仅 reset `_wave_clear_notified`，不影响行为
- `countdown_updated` 改成"只在 warning 阶段后 emit"（让 objectives_panel 在 warning_time 才开始显示倒计时），避免一进游戏就显示 "Wave 1 in 120s"

### B. circle 阵型（game_spawner.gd:369）

```gdscript
static func _calc_formation_positions(center: Vector2, count: int, formation: String, spacing: float, radius: float = 80.0) -> Array:
    var positions: Array = []
    match formation:
        # ... 既有 line/grid/column 不变 ...
        "circle":
            for i in count:
                var angle: float = TAU * i / count
                positions.append(center + Vector2(cos(angle), sin(angle)) * radius)
        _:  # column 默认
            # ...
    return positions
```

`spawn_enemy_wave_v2` 函数签名同步加 `radius: float = 80.0` 末位参数（向后兼容）。

### C. main.gd 注入与信号连接

```gdscript
func _setup_wave_manager() -> void:
    for child in get_children():
        if child is WaveManager:
            child.set_game_controller(self)
            child.set_difficulty(_diff_preset)
            # PR-3：从 map_config 注入 waves（如非空）
            if map_config != null and map_config.waves.size() > 0:
                child.waves = map_config.waves
            # PR-3：追加 wave_warning_triggered
            child.wave_started.connect(_on_wave_started)
            child.countdown_updated.connect(_on_countdown_updated)
            child.all_waves_completed.connect(_on_all_waves_completed)
            child.wave_warning_triggered.connect(_on_wave_warning_triggered)
            child.start_waves()
            break

func _on_wave_warning_triggered(wave_number: int, spawn_pos: Vector2) -> void:
    var marker := preload("res://scenes/effects/warning_marker.tscn").instantiate()
    add_child(marker)
    marker.global_position = spawn_pos
    var lifetime: float = 30.0  # warning→spawn 间隔
    marker.setup(wave_number, lifetime)
```

### D. warning_marker.gd（参考 objective_marker.gd）

```gdscript
extends Node2D
class_name WarningMarker

var _lifetime: float = 30.0
var _elapsed: float = 0.0
var _wave_number: int = 0

func setup(wave_number: int, lifetime: float = 30.0) -> void:
    _wave_number = wave_number
    _lifetime = lifetime

func _process(delta: float) -> void:
    _elapsed += delta
    if _elapsed >= _lifetime:
        queue_free()
        return
    queue_redraw()  # 触发 _draw

func _draw() -> void:
    var pulse: float = 1.0 + sin(_elapsed * 4.0) * 0.1
    var alpha: float = 0.5 + sin(_elapsed * 4.0) * 0.2
    var radius: float = 60.0 * pulse
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.2, 0.2, alpha), 4.0)
    # 可选：中心红色叉号
    draw_line(Vector2(-10, -10), Vector2(10, 10), Color(1.0, 0.2, 0.2, alpha), 3.0)
    draw_line(Vector2(-10, 10), Vector2(10, -10), Color(1.0, 0.2, 0.2, alpha), 3.0)
```

### E. elite_vanguard_stats.tres

复制 [soldier_stats.tres](resources/stats/soldier_stats.tres) 修改：
- `id = &"elite_vanguard"`
- `max_hp = 150`（soldier=100）
- `attack_damage = 18`（soldier=10）
- `move_speed = 100`（soldier=120，精英略慢）
- `sprite_scale = 1.2`（视觉更大）
- `attack_range = 40` / `attack_cooldown = 0.8`（同 soldier，近战）

**自动注册**：UnitStatsRegistry._load_all() 自动扫描 `resources/stats/*.tres`，无需手动注册。
**场景路由**：`create_unit(type=5, stats_id=&"elite_vanguard")` → `ENEMY_VARIANT_SCENES.get("elite_vanguard", "")` 返回 "" → fallback `UNIT_SCENES[5]` 又 fallback `soldier.tscn` → `set("stats_data", elite_vanguard_stats)`。

### F. 4 波 .tres 数据

```gdscript
waves = Array[Dictionary]([
    {
        "wave_number": 0,
        "warning_time": 90.0, "spawn_time": 120.0,
        "spawn_pos": Vector2(1300, 500),
        "spawn_pattern": "circle", "spawn_radius": 80.0,
        "wave_target": Vector2(200, 500),
        "show_warning_marker": true,
        "groups": [{"type": 5, "count": 3, "stats_id": &"soldier"}]
    },
    # Wave 2: 4 步 + 1 弓
    {
        "wave_number": 1,
        "warning_time": 210.0, "spawn_time": 240.0,
        "spawn_pos": Vector2(1300, 500),
        "spawn_pattern": "circle", "spawn_radius": 80.0,
        "wave_target": Vector2(200, 500),
        "show_warning_marker": true,
        "groups": [
            {"type": 5, "count": 4, "stats_id": &"soldier"},
            {"type": 6, "count": 1, "stats_id": &"archer"}
        ]
    },
    # Wave 3: 6 步 + 2 弓 + 1 精英
    {
        "wave_number": 2,
        "warning_time": 330.0, "spawn_time": 360.0,
        "spawn_pos": Vector2(1300, 500),
        "spawn_pattern": "circle", "spawn_radius": 100.0,  # 单位多，半径加大
        "wave_target": Vector2(200, 500),
        "show_warning_marker": true,
        "groups": [
            {"type": 5, "count": 6, "stats_id": &"soldier"},
            {"type": 6, "count": 2, "stats_id": &"archer"},
            {"type": 5, "count": 1, "stats_id": &"elite_vanguard"}
        ]
    },
    # Wave 4: 8 步 + 3 弓 + 2 精英
    {
        "wave_number": 3,
        "warning_time": 450.0, "spawn_time": 480.0,
        "spawn_pos": Vector2(1300, 500),
        "spawn_pattern": "circle", "spawn_radius": 120.0,
        "wave_target": Vector2(200, 500),
        "show_warning_marker": true,
        "groups": [
            {"type": 5, "count": 8, "stats_id": &"soldier"},
            {"type": 6, "count": 3, "stats_id": &"archer"},
            {"type": 5, "count": 2, "stats_id": &"elite_vanguard"}
        ]
    }
])
```

---

## 四、PR-3 验收清单

### 警告 UI
- [ ] 进入 T1 测试关卡，1:30 时 objectives_panel 出现 "Wave 1" 行 + 进度条 + 倒计时
- [ ] 1:30 时 (1300, 500) 出现红色脉冲 warning_marker（呼吸动画）
- [ ] 倒计时进度条从 30s → 0s 秒级精确
- [ ] 2:00 warning_marker 自毁，3 个 soldier 从敌方城堡周围 circle 分布出生

### spawn 节奏
- [ ] 4 波节奏准时：1:30/3:30/5:30/7:30 警告，2:00/4:00/6:00/8:00 出兵（±0.5s）
- [ ] 每波单位 attack-move 到 (200, 500) 玩家城堡
- [ ] 路过玩家单位时主动攻击（ATTACK_MOVE 已有扫描逻辑）
- [ ] Wave 3/4 出现 elite_vanguard（HP 150，scale 1.2 明显比步兵大）

### 信号与状态
- [ ] 所有 4 波完成后 emit `all_waves_completed`，objectives_panel 隐藏倒计时
- [ ] warning_marker 不残留（spawn 时已自毁，无内存泄漏）
- [ ] 后端日志无新增 ERROR/WARNING（参考 `project_known_backend_warnings`）

---

## 五、风险与陷阱

| # | 风险 | 应对 |
|---|---|---|
| 1 | `clear_then_next` 模式不兼容绝对时间驱动 | T1 测试关卡用 `clear_then_next=false`；其他用 `clear_then_next=true` 的场景（如 M3/M5/M7）仍走旧 delay 路径，PR-3 加 schema 兼容（`spawn_time = w.get("spawn_time", w.get("delay"))`） |
| 2 | countdown_updated 在游戏一开始就显示"Wave 1 in 120s" | 改成 warning_time 之后才 emit（`if warning_time < 0.0 or now >= warning_time`）|
| 3 | 旧场景依赖 wave_manager 的 `delay` 字段 | 兼容保留：`spawn_time` 缺失时 fallback 到 `delay`；PR-3 不动其他场景的 WaveManager 节点配置 |
| 4 | circle 阵型 + spacing 语义冲突 | `_calc_formation_positions` 第 5 参数 `radius`，仅 circle 模式读；line/grid/column 忽略 |
| 5 | warning_marker 显示 30s 视觉疲劳 | 首版全程显示（红色脉冲不太刺眼）；验收后调优（如最后 10s 才显示） |
| 6 | map_config.waves 注入失败（WaveManager 节点找不到 / map_config 为空）| main.gd 守卫 `if map_config != null and map_config.waves.size() > 0`，找不到时静默（push_warning）|
| 7 | wave_manager.gd _process 有调试 print（line 55-57）| PR-3 顺手清理（5s 一次的 print 是开发期遗留）|
| 8 | elite_vanguard type=5 走 fallback 看似 hack | 加注释说明：主计划惯例，type=5 实际走 UNIT_SCENES fallback 到 soldier.tscn；stats_id=&"elite_vanguard" 才是路由关键 |
| 9 | 新建 warning_marker.tscn / elite_vanguard_stats.tres 后 ResourceLoader 静默失败 | ⚠️ 必须 `godot --headless --import` 生成 .import 文件（参考 memory `feedback_godot_resource_import`）|

---

## 六、工时估算

| 改动 | 工时 |
|---|---|
| map_config.gd +1 字段 | 0.2h |
| wave_manager.gd 绝对时间重构 + 新信号 | 3.0h |
| game_spawner.gd circle 阵型 + radius 参数 | 0.8h |
| main.gd 注入 waves + connect 新信号 + warning_marker 实例化 | 1.0h |
| warning_marker.gd + .tscn 新建 | 1.5h |
| elite_vanguard_stats.tres 新建（复制 soldier 改字段） | 0.3h |
| map_t1_economy_test_config.tres 写 4 波数据 | 0.5h |
| map_t1_economy_test.tscn 加 WaveManager 子节点 | 0.2h |
| godot --headless --import + 联调验证 | 1.5h |
| **合计** | **~9.0h** |

> 主计划原估 2-3h（仅 4 波配置），扩到补 WaveManager 重构 + circle 阵型 + warning_marker 后约 9h。

---

## 七、Verification

### 步骤 1：实施完成后先 import 资源
```bash
"E:\其他\chorme_download\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe" --path "E:\godot\rts\godot_rts_start" --headless --import
```

### 步骤 2：启动游戏
```bash
"E:\其他\chorme_download\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe" --path "E:\godot\rts\godot_rts_start"
```

### 步骤 3：主菜单 "T1 测试" 入口

### 步骤 4：按验收清单逐项验证
1. 开局 0:00-1:30 期间 objectives_panel 不显示 Wave 行（验证 D2 / 风险 #2）
2. 1:30 objectives_panel 出现 "Wave 1 in 0:30" + 红色脉冲 warning_marker 在 (1300, 500)
3. 2:00 warning_marker 消失，3 个 soldier 在 (1300, 500) 周围 circle 分布出生
4. soldier attack-move 到玩家城堡 (200, 500)，路过玩家单位主动攻击
5. 计时验证：3:30/5:30/7:30 警告，4:00/6:00/8:00 出兵（±0.5s）
6. Wave 3 第 1 个精英出生：HP 150 / scale 1.2（视觉明显比步兵大）
7. Wave 4 完成后 objectives_panel 隐藏倒计时
8. 后端日志检查：无新增 ERROR/WARNING；wave_manager 的 5s print 已清理

### 步骤 5：检查已知问题清单
对照 `project_known_backend_warnings` 内存，确保未新增 WARNING/ERROR。

---

## 八、与主文档关系

本计划是 [T1_实施计划.md](docs/active/T1_实施计划.md) §5.2 PR-3 章节的展开。完成后：
- T1_实施计划.md §3.1 PR-3 状态改为 ✅
- §5.2 PR-3 章节末尾加链接指向本文档
- PR-4（SH1 据点）启动时归档到 `docs/done/`

---

## 九、待实施时确认项

- [ ] `clear_then_next` 在 wave_manager.gd 的实际行为（line 11, 90-93, 95-118）—— PR-3 T1 用 false，但要确认旧场景（M3/M5/M7）的 WaveManager 节点配置不被破坏
- [ ] 旧场景的 WaveManager 节点是否带 `delay` 字段（grep `delay` 在 `scenes/maps/*.tscn`） —— 决定兼容路径是否充分
- [ ] `_on_countdown_updated` 调用 `ui_module.update_wave_countdown`，确认 ui_module 已就绪时 wave_manager 才 start_waves（main.gd init 顺序）
- [ ] warning_marker 视觉是否够明显（红色 + 中心叉号）；如不够，加 Label "Wave N"
- [ ] elite_vanguard attack_range = 40（近战），如需远程改 80+（计划默认近战）
- [ ] 4 波 circle 半径递增（80/80/100/120）是否合适；如单位拥挤可调大
