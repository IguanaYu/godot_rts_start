"""
Generate 14 test level files for the RTS game.

Creates .tres (map config) and .tscn (map scene) files for each test level.
Run from the repo root: python tools/generate_test_levels.py
"""

import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESOURCES_DIR = os.path.join(BASE_DIR, "resources")
SCENES_DIR = os.path.join(BASE_DIR, "scenes", "maps")

os.makedirs(RESOURCES_DIR, exist_ok=True)
os.makedirs(SCENES_DIR, exist_ok=True)

# ── Shared UID / path references ─────────────────────────────────────────────

UID_MAIN = "uid://cg2igjmusi0dq"
UID_SOLDIER = "uid://mmgbo1ded4ro"
UID_ARCHER = "uid://e5by4tc82spk"
UID_BARRACKS = "uid://dhyxequcxurbh"
UID_CASTLE = "uid://8rfekrdqs7gf"
UID_TOWER = "uid://tower0001"
UID_WALL = "uid://wall00001"
UID_CAPTURE_POINT = "uid://cmp1bdjkabfkb"
UID_VICTORY_BLITZ = "uid://bl6nwwaua5wpn"
UID_VICTORY_DESTROY_BASE = "uid://jhcf43ds1dy6"

# Scripts without known UIDs (new files) - use path only
PATH_WAVE_MANAGER = "res://scripts/systems_game/wave_manager.gd"
PATH_TERRITORY_TRACKER = "res://scripts/systems_game/territory_tracker.gd"
PATH_CAPTURE_POINT = "res://scripts/systems_game/capture_point.gd"

# ── Helper to build ext_resource lines ────────────────────────────────────────

def ext_resource(res_type, path, id_str, uid=None):
    """Build an [ext_resource ...] line."""
    parts = f'type="{res_type}" path="{path}" id="{id_str}"'
    if uid:
        parts = f'type="{res_type}" uid="{uid}" path="{path}" id="{id_str}"'
    return f'[ext_resource {parts}]'


# ── Navigation polygon (shared small map) ─────────────────────────────────────

def nav_poly(x0, y0, x1, y1):
    return (
        f'[sub_resource type="NavigationPolygon" id="NavPoly_1"]\n'
        f'vertices = PackedVector2Array({x0}, {y0}, {x1}, {y0}, {x1}, {y1}, {x0}, {y1})\n'
        f'polygons = Array[PackedInt32Array]([PackedInt32Array(0, 1, 2, 3)])'
    )


# ── Common UI nodes ───────────────────────────────────────────────────────────

def common_ui_nodes():
    return """\
[node name="SelectionBox" type="ColorRect" parent="."]
visible = false
mouse_filter = 2
color = Color(0.4, 0.7, 1, 0.25)

[node name="PreviewRect" type="ColorRect" parent="."]
visible = false
mouse_filter = 2
color = Color(0, 1, 0, 0.3)

[node name="ResultLabel" type="Label" parent="."]
offset_left = 200.0
offset_top = 180.0
offset_right = 400.0
offset_bottom = 280.0
theme_override_font_sizes/font_size = 48
horizontal_alignment = 1
vertical_alignment = 1

[node name="AttackMoveIndicator" type="Label" parent="."]
visible = false
offset_left = 10.0
offset_top = 10.0
offset_right = 200.0
offset_bottom = 40.0
theme_override_colors/font_color = Color(1, 0.8, 0.2, 1)
theme_override_font_sizes/font_size = 20
text = "Attack Move (Click)\""""


# ── .tres config generation ───────────────────────────────────────────────────

def generate_tres(name, map_name, bounds, initial_gold, camera_start,
                  player_units, player_buildings, enemy_units, enemy_buildings,
                  environment=None, available_items=None,
                  star_time_3=180.0, star_time_2=300.0,
                  star_deaths_3=0, star_deaths_2=3,
                  terrain_theme=0, border_width=1, map_description=""):
    if environment is None:
        environment = {"trees": 5, "rocks": 3, "bushes": 4, "sheep": 2}
    if available_items is None:
        available_items = []

    def fmt_dict_array(arr):
        if not arr:
            return "Array[Dictionary]([])"
        items = []
        for d in arr:
            parts = []
            for k, v in d.items():
                if isinstance(v, str):
                    parts.append(f'"{k}": {v}')
                else:
                    parts.append(f'"{k}": {v}')
            items.append("{" + ", ".join(parts) + "}")
        inner = ", ".join(items)
        return f"Array[Dictionary]( [\n\t\t{inner}\n\t] )"

    def fmt_int_array(arr):
        if not arr:
            return "Array[int]([])"
        return f"Array[int]([{', '.join(str(x) for x in arr)}])"

    lines = [
        '[gd_resource type="Resource" script_class="MapConfig" load_steps=2 format=3]',
        '',
        '[ext_resource type="Script" path="res://scripts/map_config.gd" id="1"]',
        '',
        '[resource]',
        'script = ExtResource("1")',
        f'map_name = "{map_name}"',
        f'map_bounds = Rect2({bounds[0]}, {bounds[1]}, {bounds[2]}, {bounds[3]})',
        f'nav_bounds = Array[Vector2]([Vector2({bounds[0]}, {bounds[1]}), Vector2({bounds[0]+bounds[2]}, {bounds[1]}), Vector2({bounds[0]+bounds[2]}, {bounds[1]+bounds[3]}), Vector2({bounds[0]}, {bounds[1]+bounds[3]})])',
        f'initial_gold = {initial_gold}',
        f'camera_start = Vector2({camera_start[0]}, {camera_start[1]})',
        '',
        f'player_units = {fmt_dict_array(player_units)}',
        '',
        f'player_buildings = {fmt_dict_array(player_buildings)}',
        '',
        f'enemy_units = {fmt_dict_array(enemy_units)}',
        '',
        f'enemy_buildings = {fmt_dict_array(enemy_buildings)}',
        '',
        f'environment = {{{", ".join(f"\"{k}\": {v}" for k, v in environment.items())}}}',
        '',
        f'available_items = {fmt_int_array(available_items)}',
        '',
        f'terrain_theme = {terrain_theme}',
        f'border_width = {border_width}',
        f'map_description = "{map_description}"',
        '',
        f'star_time_3 = {star_time_3}',
        f'star_time_2 = {star_time_2}',
        f'star_deaths_3 = {star_deaths_3}',
        f'star_deaths_2 = {star_deaths_2}',
    ]
    return "\n".join(lines) + "\n"


# ── Unit/building node helpers ────────────────────────────────────────────────

def unit_node(name, parent, ext_id, x, y, team=None, extra=""):
    lines = [f'[node name="{name}" parent="{parent}" instance=ExtResource("{ext_id}")]']
    lines.append(f'position = Vector2({x}, {y})')
    if team is not None:
        lines.append(f'team = {team}')
    for line in extra.split("\n"):
        if line.strip():
            lines.append(line.strip())
    return "\n".join(lines)


def building_node(name, ext_id, x, y, team=None):
    lines = [f'[node name="{name}" parent="Buildings" instance=ExtResource("{ext_id}")]']
    lines.append(f'position = Vector2({x}, {y})')
    if team is not None:
        lines.append(f'team = {team}')
    return "\n".join(lines)


def wave_data(waves_list):
    """Build the waves Array[Dictionary] string using old format."""
    wave_strs = []
    for w in waves_list:
        parts = []
        parts.append(f'"delay": {w.get("delay", 10.0)}')
        if "post_clear_delay" in w:
            parts.append(f'"post_clear_delay": {w["post_clear_delay"]}')
        if w.get("wave_attack"):
            parts.append(f'"wave_attack": true')
        if "wave_target" in w:
            tx, ty = w["wave_target"]
            parts.append(f'"wave_target": Vector2({tx}, {ty})')
        if "units" in w:
            unit_strs = []
            for u in w["units"]:
                ux, uy = u["pos"]
                unit_strs.append(f'{{"type": {u["type"]}, "pos": Vector2({ux}, {uy})}}')
            units_inner = ", ".join(unit_strs)
            parts.append(f'"units": Array[Dictionary]( [{units_inner}] )')
        wave_strs.append("{" + ", ".join(parts) + "}")

    inner = ",\n\t\t".join(wave_strs)
    return f'Array[Dictionary]( [\n\t\t{inner}\n\t] )'


# ══════════════════════════════════════════════════════════════════════════════
#  LEVEL DEFINITIONS
# ══════════════════════════════════════════════════════════════════════════════

LEVELS = {}

# ──────────────────────────────────────────────────────────────────────────────
# T1: test_vip_survival
# ──────────────────────────────────────────────────────────────────────────────

def gen_t1():
    name = "test_vip_survival"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: VIP Survival", bounds,
        initial_gold=3000, camera_start=(350, 200),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 180)"},
            {"type": 0, "pos": "Vector2(100, 220)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 1, "pos": "Vector2(70, 200)"},
            {"type": 1, "pos": "Vector2(70, 240)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(400, 200)"},
            {"type": 0, "pos": "Vector2(400, 240)"},
            {"type": 0, "pos": "Vector2(500, 220)"},
        ],
        enemy_buildings=[],
        star_time_3=60.0, star_time_2=120.0,
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("Script", "res://scripts/victory/victory_composite.gd", "victory_composite"),
        ext_resource("Script", "res://scripts/victory/victory_blitz.gd", "victory_blitz", UID_VICTORY_BLITZ),
        ext_resource("Script", "res://scripts/victory/victory_vip_survival.gd", "victory_vip"),
        ext_resource("Script", "res://scripts/systems_game/capture_point.gd", "capture_point", UID_CAPTURE_POINT),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 180),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 220),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 200),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 240),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 400, 200, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 400, 240, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 500, 220, team=1),
    ])

    nav = nav_poly(-100, -100, 700, 500)

    victory_nodes = """\
[node name="VictoryComposite" type="Node" parent="."]
script = ExtResource("victory_composite")
logic_mode = 0
description_key = "OBJ_VIP_SURVIVAL"

[node name="VictoryBlitz" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_blitz")
capture_points = Array[NodePath]([NodePath("../../CapturePoint")])

[node name="VictoryVipSurvival" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_vip")
vip_units = Array[NodePath]([NodePath("../../PlayerUnits/PlayerArcher1"), NodePath("../../PlayerUnits/PlayerArcher2")])

[node name="DetectionArea" type="Marker2D" parent="."]
position = Vector2(480, 220)

[node name="CapturePoint" type="Area2D" parent="."]
position = Vector2(500, 220)
script = ExtResource("capture_point")
detection_area = NodePath("../DetectionArea")
detection_radius = 150.0
can_enemy_capture = false
reward_gold = 0"""

    buildings_section = '[node name="Buildings" type="Node2D" parent="."]'

    tscn = "\n".join([
        f'[gd_scene load_steps=9 format=3]',
        '',
        ext_resources,
        '',
        nav,
        '',
        '[node name="TestVIPSurvival" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        buildings_section,
        '',
        common_ui_nodes(),
        '',
        victory_nodes,
    ])
    return tres, tscn

LEVELS["test_vip_survival"] = gen_t1


# ──────────────────────────────────────────────────────────────────────────────
# T2: test_assassinate
# ──────────────────────────────────────────────────────────────────────────────

def gen_t2():
    name = "test_assassinate"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Assassinate", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 180)"},
            {"type": 0, "pos": "Vector2(100, 220)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 300)"},
            {"type": 0, "pos": "Vector2(100, 340)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(450, 250)"},
            {"type": 0, "pos": "Vector2(420, 220)"},
            {"type": 0, "pos": "Vector2(420, 280)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("Script", "res://scripts/victory/victory_assassinate.gd", "victory_assassinate"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node(f"PlayerSoldier{i}", "PlayerUnits", "soldier", 100, 180 + (i-1)*40)
        for i in range(1, 6)
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemyBoss", "EnemyUnits", "soldier", 450, 250, team=1,
                  extra="variant_hp_bonus = 200\nvariant_atk_bonus = 10\nvariant_scale = 1.5"),
        unit_node("EnemyGuard1", "EnemyUnits", "soldier", 420, 220, team=1),
        unit_node("EnemyGuard2", "EnemyUnits", "soldier", 420, 280, team=1),
    ])

    victory_node = """\
[node name="VictoryAssassinate" type="Node" parent="."]
script = ExtResource("victory_assassinate")
target_units = Array[NodePath]([NodePath("../EnemyUnits/EnemyBoss")])
description_key = "OBJ_ASSASSINATE" """

    tscn = "\n".join([
        '[gd_scene load_steps=5 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestAssassinate" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_assassinate"] = gen_t2


# ──────────────────────────────────────────────────────────────────────────────
# T3: test_destroy_buildings
# ──────────────────────────────────────────────────────────────────────────────

def gen_t3():
    name = "test_destroy_buildings"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Destroy Buildings", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
            {"type": 1, "pos": "Vector2(70, 230)"},
            {"type": 1, "pos": "Vector2(70, 290)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(400, 180)"},
            {"type": 0, "pos": "Vector2(400, 250)"},
            {"type": 0, "pos": "Vector2(400, 320)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/barracks.tscn", "barracks", UID_BARRACKS),
        ext_resource("PackedScene", "res://scenes/buildings/tower.tscn", "tower", UID_TOWER),
        ext_resource("Script", "res://scripts/victory/victory_destroy_buildings.gd", "victory_destroy_buildings"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 230),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 290),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 400, 180, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 400, 250, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 400, 320, team=1),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("PlayerBarracks", "barracks", 288, 128),
        building_node("EnemyTower1", "tower", 480, 160, team=1),
        building_node("EnemyTower2", "tower", 480, 320, team=1),
    ])

    victory_node = """\
[node name="VictoryDestroyBuildings" type="Node" parent="."]
script = ExtResource("victory_destroy_buildings")
target_building_type = 1
description_key = "OBJ_DESTROY_BUILDINGS" """

    tscn = "\n".join([
        '[gd_scene load_steps=9 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestDestroyBuildings" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_destroy_buildings"] = gen_t3


# ──────────────────────────────────────────────────────────────────────────────
# T4: test_protect_building
# ──────────────────────────────────────────────────────────────────────────────

def gen_t4():
    name = "test_protect_building"
    bounds = (-100, -100, 800, 700)

    tres = generate_tres(
        name, "Test: Protect Building", bounds,
        initial_gold=3000, camera_start=(300, 300),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
        ],
        player_buildings=[],
        enemy_units=[],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/tower.tscn", "tower", UID_TOWER),
        ext_resource("Script", "res://scripts/victory/victory_protect_building.gd", "victory_protect"),
        ext_resource("Script", "res://scripts/systems_game/wave_manager.gd", "wave_manager"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 100, 400),
        building_node("PlayerTower", "tower", 300, 250),
    ])

    wave_manager_node = f"""\
[node name="WaveManager" type="Node" parent="."]
script = ExtResource("wave_manager")
clear_then_next = true
waves = {wave_data([
    {"delay": 10.0, "wave_attack": True, "wave_target": (300, 250),
     "units": [{"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)}]},
    {"delay": 10.0, "wave_attack": True, "wave_target": (300, 250),
     "units": [{"type": 0, "pos": (700, 150)}, {"type": 0, "pos": (700, 200)},
               {"type": 0, "pos": (700, 250)}, {"type": 0, "pos": (700, 300)},
               {"type": 0, "pos": (700, 350)}, {"type": 0, "pos": (700, 400)}]},
    {"delay": 10.0, "wave_attack": True, "wave_target": (300, 250),
     "units": [{"type": 0, "pos": (700, 100)}, {"type": 0, "pos": (700, 150)},
               {"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)},
               {"type": 0, "pos": (700, 400)}, {"type": 0, "pos": (700, 450)}]},
])}"""

    victory_node = """\
[node name="VictoryProtectBuilding" type="Node" parent="."]
script = ExtResource("victory_protect")
protected_buildings = Array[NodePath]([NodePath("../Buildings/PlayerTower")])
survival_time = 60.0
description_key = "OBJ_PROTECT_BUILDING" """

    tscn = "\n".join([
        '[gd_scene load_steps=8 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 600),
        '',
        '[node name="TestProtectBuilding" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        wave_manager_node,
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_protect_building"] = gen_t4


# ──────────────────────────────────────────────────────────────────────────────
# T5: test_kill_count
# ──────────────────────────────────────────────────────────────────────────────

def gen_t5():
    name = "test_kill_count"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Kill Count", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
            {"type": 1, "pos": "Vector2(70, 230)"},
            {"type": 1, "pos": "Vector2(70, 290)"},
        ],
        player_buildings=[],
        enemy_units=[],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/barracks.tscn", "barracks", UID_BARRACKS),
        ext_resource("Script", "res://scripts/victory/victory_kill_count.gd", "victory_kill_count"),
        ext_resource("Script", "res://scripts/systems_game/wave_manager.gd", "wave_manager"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 230),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 290),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("PlayerBarracks", "barracks", 288, 128),
    ])

    wave_manager_node = f"""\
[node name="WaveManager" type="Node" parent="."]
script = ExtResource("wave_manager")
clear_then_next = true
waves = {wave_data([
    {"delay": 10.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)}]},
    {"delay": 10.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)}]},
    {"delay": 10.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)}]},
])}"""

    victory_node = """\
[node name="VictoryKillCount" type="Node" parent="."]
script = ExtResource("victory_kill_count")
kill_target = 10
description_key = "OBJ_KILL_COUNT" """

    tscn = "\n".join([
        '[gd_scene load_steps=9 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestKillCount" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        wave_manager_node,
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_kill_count"] = gen_t5


# ──────────────────────────────────────────────────────────────────────────────
# T6: test_gold_target
# ──────────────────────────────────────────────────────────────────────────────

def gen_t6():
    name = "test_gold_target"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Gold Target", bounds,
        initial_gold=500, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
            {"type": 1, "pos": "Vector2(70, 230)"},
            {"type": 1, "pos": "Vector2(70, 290)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(450, 200)"},
            {"type": 0, "pos": "Vector2(450, 260)"},
            {"type": 0, "pos": "Vector2(450, 320)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/barracks.tscn", "barracks", UID_BARRACKS),
        ext_resource("Script", "res://scripts/victory/victory_composite.gd", "victory_composite"),
        ext_resource("Script", "res://scripts/victory/victory_gold_target.gd", "victory_gold_target"),
        ext_resource("Script", "res://scripts/victory/victory_destroy_base.gd", "victory_destroy_base", UID_VICTORY_DESTROY_BASE),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 230),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 290),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 450, 200, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 450, 260, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 450, 320, team=1),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("PlayerBarracks", "barracks", 288, 128),
        building_node("EnemyCastle", "castle", 500, 200, team=1),
    ])

    victory_node = """\
[node name="VictoryComposite" type="Node" parent="."]
script = ExtResource("victory_composite")
logic_mode = 0
description_key = "OBJ_GOLD_TARGET"

[node name="VictoryGoldTarget" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_gold_target")
gold_target = 2000
description_key = "OBJ_GOLD_TARGET"

[node name="VictoryDestroyBase" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_destroy_base")"""

    tscn = "\n".join([
        '[gd_scene load_steps=10 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestGoldTarget" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_gold_target"] = gen_t6


# ──────────────────────────────────────────────────────────────────────────────
# T7: test_time_limit
# ──────────────────────────────────────────────────────────────────────────────

def gen_t7():
    name = "test_time_limit"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Time Limit", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 180)"},
            {"type": 0, "pos": "Vector2(100, 220)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 300)"},
            {"type": 1, "pos": "Vector2(70, 200)"},
            {"type": 1, "pos": "Vector2(70, 280)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(450, 180)"},
            {"type": 0, "pos": "Vector2(450, 250)"},
            {"type": 0, "pos": "Vector2(450, 320)"},
            {"type": 1, "pos": "Vector2(500, 250)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/barracks.tscn", "barracks", UID_BARRACKS),
        ext_resource("Script", "res://scripts/victory/victory_composite.gd", "victory_composite"),
        ext_resource("Script", "res://scripts/victory/victory_destroy_base.gd", "victory_destroy_base", UID_VICTORY_DESTROY_BASE),
        ext_resource("Script", "res://scripts/victory/victory_time_limit.gd", "victory_time_limit"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 180),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 220),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier4", "PlayerUnits", "soldier", 100, 300),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 200),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 280),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 450, 180, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 450, 250, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 450, 320, team=1),
        unit_node("EnemyArcher1", "EnemyUnits", "archer", 500, 250, team=1),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("PlayerBarracks", "barracks", 288, 128),
        building_node("EnemyCastle", "castle", 500, 200, team=1),
    ])

    victory_node = """\
[node name="VictoryComposite" type="Node" parent="."]
script = ExtResource("victory_composite")
logic_mode = 0
description_key = "OBJ_TIME_LIMIT"

[node name="VictoryDestroyBase" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_destroy_base")

[node name="VictoryTimeLimit" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_time_limit")
time_limit = 120.0
description_key = "OBJ_TIME_LIMIT" """

    tscn = "\n".join([
        '[gd_scene load_steps=10 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestTimeLimit" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_time_limit"] = gen_t7


# ──────────────────────────────────────────────────────────────────────────────
# T8: test_survive_timer
# ──────────────────────────────────────────────────────────────────────────────

def gen_t8():
    name = "test_survive_timer"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Survive Timer", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
            {"type": 1, "pos": "Vector2(70, 260)"},
        ],
        player_buildings=[],
        enemy_units=[],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("Script", "res://scripts/victory/victory_survive_timer.gd", "victory_survive_timer"),
        ext_resource("Script", "res://scripts/systems_game/wave_manager.gd", "wave_manager"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 260),
    ])

    buildings_nodes = building_node("PlayerCastle", "castle", 160, 224)

    wave_manager_node = f"""\
[node name="WaveManager" type="Node" parent="."]
script = ExtResource("wave_manager")
clear_then_next = true
waves = {wave_data([
    {"delay": 10.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}]},
    {"delay": 10.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 150)}, {"type": 0, "pos": (700, 200)},
               {"type": 0, "pos": (700, 250)}, {"type": 0, "pos": (700, 300)},
               {"type": 0, "pos": (700, 350)}]},
    {"delay": 10.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 100)}, {"type": 0, "pos": (700, 150)},
               {"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)},
               {"type": 0, "pos": (700, 400)}]},
])}"""

    victory_node = """\
[node name="VictorySurviveTimer" type="Node" parent="."]
script = ExtResource("victory_survive_timer")
survival_time = 90.0
description_key = "OBJ_SURVIVE_TIMER" """

    tscn = "\n".join([
        '[gd_scene load_steps=8 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestSurviveTimer" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        wave_manager_node,
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_survive_timer"] = gen_t8


# ──────────────────────────────────────────────────────────────────────────────
# T9: test_reach_location
# ──────────────────────────────────────────────────────────────────────────────

def gen_t9():
    name = "test_reach_location"
    bounds = (-100, -100, 900, 600)

    tres = generate_tres(
        name, "Test: Reach Location", bounds,
        initial_gold=3000, camera_start=(350, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(300, 180)"},
            {"type": 0, "pos": "Vector2(300, 260)"},
            {"type": 0, "pos": "Vector2(300, 340)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("Script", "res://scripts/victory/victory_reach_location.gd", "victory_reach_location"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 300, 180, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 300, 260, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 300, 340, team=1),
    ])

    victory_node = """\
[node name="Destination" type="Marker2D" parent="."]
position = Vector2(600, 250)

[node name="VictoryReachLocation" type="Node" parent="."]
script = ExtResource("victory_reach_location")
destination = NodePath("../Destination")
require_all = false
reach_radius = 60.0
description_key = "OBJ_REACH_LOCATION" """

    tscn = "\n".join([
        '[gd_scene load_steps=5 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 800, 500),
        '',
        '[node name="TestReachLocation" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_reach_location"] = gen_t9


# ──────────────────────────────────────────────────────────────────────────────
# T12: test_territory_score
# ──────────────────────────────────────────────────────────────────────────────

def gen_t12():
    name = "test_territory_score"
    bounds = (-100, -100, 800, 700)

    tres = generate_tres(
        name, "Test: Territory Score", bounds,
        initial_gold=3000, camera_start=(300, 300),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 280)"},
            {"type": 0, "pos": "Vector2(100, 360)"},
            {"type": 1, "pos": "Vector2(70, 240)"},
            {"type": 1, "pos": "Vector2(70, 320)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(550, 200)"},
            {"type": 0, "pos": "Vector2(550, 280)"},
            {"type": 0, "pos": "Vector2(550, 360)"},
            {"type": 1, "pos": "Vector2(580, 240)"},
            {"type": 1, "pos": "Vector2(580, 320)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("Script", "res://scripts/victory/victory_territory_score.gd", "victory_territory"),
        ext_resource("Script", "res://scripts/systems_game/territory_tracker.gd", "territory_tracker"),
        ext_resource("Script", "res://scripts/systems_game/capture_point.gd", "capture_point", UID_CAPTURE_POINT),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 280),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 360),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 240),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 320),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 550, 200, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 550, 280, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 550, 360, team=1),
        unit_node("EnemyArcher1", "EnemyUnits", "archer", 580, 240, team=1),
        unit_node("EnemyArcher2", "EnemyUnits", "archer", 580, 320, team=1),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("EnemyCastle", "castle", 500, 300, team=1),
    ])

    capture_and_tracker = """\
[node name="CapturePoint1" type="Area2D" parent="."]
position = Vector2(300, 150)
script = ExtResource("capture_point")
trigger_type = 0
detection_radius = 200.0
capture_radius = 80.0
capture_speed = 30.0
can_enemy_capture = true

[node name="CapturePoint2" type="Area2D" parent="."]
position = Vector2(300, 350)
script = ExtResource("capture_point")
trigger_type = 0
detection_radius = 200.0
capture_radius = 80.0
capture_speed = 30.0
can_enemy_capture = true

[node name="CapturePoint3" type="Area2D" parent="."]
position = Vector2(300, 500)
script = ExtResource("capture_point")
trigger_type = 0
detection_radius = 200.0
capture_radius = 80.0
capture_speed = 30.0
can_enemy_capture = true

[node name="TerritoryTracker" type="Node" parent="."]
script = ExtResource("territory_tracker")
capture_points = Array[NodePath]([NodePath("../CapturePoint1"), NodePath("../CapturePoint2"), NodePath("../CapturePoint3")])
score_rate = 2.0
target_score = 500.0

[node name="VictoryTerritoryScore" type="Node" parent="."]
script = ExtResource("victory_territory")
territory_tracker_path = NodePath("../TerritoryTracker")
target_score = 500.0
description_key = "OBJ_TERRITORY_SCORE" """

    tscn = "\n".join([
        '[gd_scene load_steps=9 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 600),
        '',
        '[node name="TestTerritoryScore" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        capture_and_tracker,
    ])
    return tres, tscn

LEVELS["test_territory_score"] = gen_t12


# ──────────────────────────────────────────────────────────────────────────────
# T13: test_endless
# ──────────────────────────────────────────────────────────────────────────────

def gen_t13():
    name = "test_endless"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Endless", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 200)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 320)"},
            {"type": 1, "pos": "Vector2(70, 230)"},
            {"type": 1, "pos": "Vector2(70, 290)"},
        ],
        player_buildings=[],
        enemy_units=[],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/barracks.tscn", "barracks", UID_BARRACKS),
        ext_resource("Script", "res://scripts/victory/victory_endless.gd", "victory_endless"),
        ext_resource("Script", "res://scripts/systems_game/wave_manager.gd", "wave_manager"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node("PlayerSoldier1", "PlayerUnits", "soldier", 100, 200),
        unit_node("PlayerSoldier2", "PlayerUnits", "soldier", 100, 260),
        unit_node("PlayerSoldier3", "PlayerUnits", "soldier", 100, 320),
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 230),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 290),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("PlayerBarracks", "barracks", 288, 128),
    ])

    wave_manager_node = f"""\
[node name="WaveManager" type="Node" parent="."]
script = ExtResource("wave_manager")
clear_then_next = true
waves = {wave_data([
    {"delay": 15.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}]},
    {"delay": 15.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 150)}, {"type": 0, "pos": (700, 200)},
               {"type": 0, "pos": (700, 250)}, {"type": 0, "pos": (700, 300)},
               {"type": 1, "pos": (700, 350)}]},
    {"delay": 15.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 100)}, {"type": 0, "pos": (700, 150)},
               {"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 1, "pos": (700, 350)},
               {"type": 1, "pos": (700, 400)}]},
    {"delay": 15.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 100)}, {"type": 0, "pos": (700, 150)},
               {"type": 0, "pos": (700, 200)}, {"type": 0, "pos": (700, 250)},
               {"type": 0, "pos": (700, 300)}, {"type": 0, "pos": (700, 350)},
               {"type": 1, "pos": (700, 400)}, {"type": 1, "pos": (700, 450)}]},
    {"delay": 15.0, "wave_attack": True, "wave_target": (200, 250),
     "units": [{"type": 0, "pos": (700, 50)}, {"type": 0, "pos": (700, 100)},
               {"type": 0, "pos": (700, 150)}, {"type": 0, "pos": (700, 200)},
               {"type": 0, "pos": (700, 250)}, {"type": 0, "pos": (700, 300)},
               {"type": 0, "pos": (700, 350)}, {"type": 1, "pos": (700, 400)},
               {"type": 1, "pos": (700, 450)}, {"type": 1, "pos": (700, 500)}]},
])}"""

    victory_node = """\
[node name="VictoryEndless" type="Node" parent="."]
script = ExtResource("victory_endless")
wave_manager_path = NodePath("../WaveManager")
description_key = "OBJ_ENDLESS" """

    tscn = "\n".join([
        '[gd_scene load_steps=9 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestEndless" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        wave_manager_node,
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_endless"] = gen_t13


# ──────────────────────────────────────────────────────────────────────────────
# T14: test_composite_and
# ──────────────────────────────────────────────────────────────────────────────

def gen_t14():
    name = "test_composite_and"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Composite AND", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 180)"},
            {"type": 0, "pos": "Vector2(100, 220)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 300)"},
            {"type": 0, "pos": "Vector2(100, 340)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(500, 250)"},
            {"type": 0, "pos": "Vector2(460, 200)"},
            {"type": 0, "pos": "Vector2(460, 300)"},
            {"type": 0, "pos": "Vector2(500, 180)"},
        ],
        enemy_buildings=[],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("Script", "res://scripts/victory/victory_composite.gd", "victory_composite"),
        ext_resource("Script", "res://scripts/victory/victory_assassinate.gd", "victory_assassinate"),
        ext_resource("Script", "res://scripts/victory/victory_time_limit.gd", "victory_time_limit"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node(f"PlayerSoldier{i}", "PlayerUnits", "soldier", 100, 180 + (i-1)*40)
        for i in range(1, 6)
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemyBoss", "EnemyUnits", "soldier", 500, 250, team=1,
                  extra="variant_hp_bonus = 200\nvariant_scale = 1.5"),
        unit_node("EnemyGuard1", "EnemyUnits", "soldier", 460, 200, team=1),
        unit_node("EnemyGuard2", "EnemyUnits", "soldier", 460, 300, team=1),
        unit_node("EnemyGuard3", "EnemyUnits", "soldier", 500, 180, team=1),
    ])

    victory_node = """\
[node name="VictoryComposite" type="Node" parent="."]
script = ExtResource("victory_composite")
logic_mode = 0
description_key = "OBJ_COMPOSITE_AND"

[node name="VictoryAssassinate" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_assassinate")
target_units = Array[NodePath]([NodePath("../../EnemyUnits/EnemyBoss")])
description_key = "OBJ_ASSASSINATE"

[node name="VictoryTimeLimit" type="Node" parent="VictoryComposite"]
script = ExtResource("victory_time_limit")
time_limit = 120.0
description_key = "OBJ_TIME_LIMIT" """

    tscn = "\n".join([
        '[gd_scene load_steps=7 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestCompositeAnd" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_composite_and"] = gen_t14


# ──────────────────────────────────────────────────────────────────────────────
# T15: test_multi_stage
# ──────────────────────────────────────────────────────────────────────────────

def gen_t15():
    name = "test_multi_stage"
    bounds = (-100, -100, 800, 600)

    tres = generate_tres(
        name, "Test: Multi Stage", bounds,
        initial_gold=3000, camera_start=(300, 250),
        player_units=[
            {"type": 0, "pos": "Vector2(100, 180)"},
            {"type": 0, "pos": "Vector2(100, 220)"},
            {"type": 0, "pos": "Vector2(100, 260)"},
            {"type": 0, "pos": "Vector2(100, 300)"},
            {"type": 0, "pos": "Vector2(100, 340)"},
            {"type": 1, "pos": "Vector2(70, 200)"},
            {"type": 1, "pos": "Vector2(70, 320)"},
        ],
        player_buildings=[],
        enemy_units=[
            {"type": 0, "pos": "Vector2(400, 200)"},
            {"type": 0, "pos": "Vector2(400, 260)"},
            {"type": 0, "pos": "Vector2(400, 320)"},
            {"type": 0, "pos": "Vector2(500, 250)"},
        ],
        enemy_buildings=[
            {"type": 2, "grid_pos": "Vector2i(7, 3)"},
        ],
    )

    ext_resources = "\n".join([
        ext_resource("Script", "res://scripts/main.gd", "main_script", UID_MAIN),
        ext_resource("Resource", f"res://resources/{name}_config.tres", "map_config"),
        ext_resource("PackedScene", "res://scenes/units/soldier.tscn", "soldier", UID_SOLDIER),
        ext_resource("PackedScene", "res://scenes/units/archer.tscn", "archer", UID_ARCHER),
        ext_resource("PackedScene", "res://scenes/buildings/castle.tscn", "castle", UID_CASTLE),
        ext_resource("PackedScene", "res://scenes/buildings/tower.tscn", "tower", UID_TOWER),
        ext_resource("Script", "res://scripts/victory/victory_multi_stage.gd", "victory_multi_stage"),
        ext_resource("Script", "res://scripts/victory/victory_kill_count.gd", "victory_kill_count"),
        ext_resource("Script", "res://scripts/victory/victory_destroy_buildings.gd", "victory_destroy_buildings"),
        ext_resource("Script", "res://scripts/victory/victory_assassinate.gd", "victory_assassinate"),
    ])

    player_units_nodes = "\n\n".join([
        unit_node(f"PlayerSoldier{i}", "PlayerUnits", "soldier", 100, 180 + (i-1)*40)
        for i in range(1, 6)
    ] + [
        unit_node("PlayerArcher1", "PlayerUnits", "archer", 70, 200),
        unit_node("PlayerArcher2", "PlayerUnits", "archer", 70, 320),
    ])

    enemy_units_nodes = "\n\n".join([
        unit_node("EnemySoldier1", "EnemyUnits", "soldier", 400, 200, team=1),
        unit_node("EnemySoldier2", "EnemyUnits", "soldier", 400, 260, team=1),
        unit_node("EnemySoldier3", "EnemyUnits", "soldier", 400, 320, team=1),
        unit_node("EnemyBoss", "EnemyUnits", "soldier", 500, 250, team=1,
                  extra="variant_hp_bonus = 200\nvariant_scale = 1.5"),
    ])

    buildings_nodes = "\n\n".join([
        building_node("PlayerCastle", "castle", 160, 224),
        building_node("EnemyTower", "tower", 450, 200, team=1),
    ])

    victory_node = """\
[node name="VictoryMultiStage" type="Node" parent="."]
script = ExtResource("victory_multi_stage")
stage_names = Array[String](["STAGE_KILL_ENEMIES", "STAGE_DESTROY_TOWER", "STAGE_ASSASSINATE_BOSS"])
description_key = "OBJ_MULTI_STAGE"

[node name="Stage0" type="Node" parent="VictoryMultiStage"]

[node name="VictoryKillCount" type="Node" parent="VictoryMultiStage/Stage0"]
script = ExtResource("victory_kill_count")
kill_target = 3
description_key = "OBJ_KILL_COUNT"

[node name="Stage1" type="Node" parent="VictoryMultiStage"]

[node name="VictoryDestroyBuildings" type="Node" parent="VictoryMultiStage/Stage1"]
script = ExtResource("victory_destroy_buildings")
target_buildings = Array[NodePath]([NodePath("../../../Buildings/EnemyTower")])
description_key = "OBJ_DESTROY_BUILDINGS"

[node name="Stage2" type="Node" parent="VictoryMultiStage"]

[node name="VictoryAssassinate" type="Node" parent="VictoryMultiStage/Stage2"]
script = ExtResource("victory_assassinate")
target_units = Array[NodePath]([NodePath("../../../EnemyUnits/EnemyBoss")])
description_key = "OBJ_ASSASSINATE" """

    tscn = "\n".join([
        '[gd_scene load_steps=11 format=3]',
        '',
        ext_resources,
        '',
        nav_poly(-100, -100, 700, 500),
        '',
        '[node name="TestMultiStage" type="Node2D"]',
        'script = ExtResource("main_script")',
        'map_config = ExtResource("map_config")',
        '',
        '[node name="Ground" type="ColorRect" parent="."]',
        f'offset_left = {bounds[0]}.0',
        f'offset_top = {bounds[1]}.0',
        f'offset_right = {bounds[0]+bounds[2]}.0',
        f'offset_bottom = {bounds[1]+bounds[3]}.0',
        'color = Color(0.35, 0.55, 0.25, 1)',
        '',
        '[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]',
        'navigation_polygon = SubResource("NavPoly_1")',
        '',
        '[node name="Camera2D" type="Camera2D" parent="."]',
        '',
        '[node name="PlayerUnits" type="Node2D" parent="."]',
        '',
        player_units_nodes,
        '',
        '[node name="EnemyUnits" type="Node2D" parent="."]',
        '',
        enemy_units_nodes,
        '',
        '[node name="Buildings" type="Node2D" parent="."]',
        '',
        buildings_nodes,
        '',
        common_ui_nodes(),
        '',
        victory_node,
    ])
    return tres, tscn

LEVELS["test_multi_stage"] = gen_t15


# ══════════════════════════════════════════════════════════════════════════════
#  MAIN: Generate all files
# ══════════════════════════════════════════════════════════════════════════════

def main():
    print("=" * 60)
    print("Generating test level files")
    print("=" * 60)
    print()

    # Ordered list matching spec: T1,T2,T3,T4,T5,T6,T7,T8,T9,T12,T13,T14,T15
    # Skipping T10 (escort) and T11 (collect items)
    level_order = [
        "test_vip_survival",
        "test_assassinate",
        "test_destroy_buildings",
        "test_protect_building",
        "test_kill_count",
        "test_gold_target",
        "test_time_limit",
        "test_survive_timer",
        "test_reach_location",
        "test_territory_score",
        "test_endless",
        "test_composite_and",
        "test_multi_stage",
    ]

    assert len(level_order) == 13, f"Expected 13 levels (skipping T10, T11), got {len(level_order)}"
    assert len(LEVELS) == 13, f"Expected 13 generator functions, got {len(LEVELS)}"

    created_files = []

    for level_name in level_order:
        gen_func = LEVELS[level_name]
        tres_content, tscn_content = gen_func()

        tres_path = os.path.join(RESOURCES_DIR, f"{level_name}_config.tres")
        tscn_path = os.path.join(SCENES_DIR, f"{level_name}.tscn")

        with open(tres_path, "w", encoding="utf-8") as f:
            f.write(tres_content)
        created_files.append(tres_path)

        with open(tscn_path, "w", encoding="utf-8") as f:
            f.write(tscn_content)
        created_files.append(tscn_path)

        print(f"  [OK] {level_name}")

    print()
    print(f"Generated {len(created_files)} files total ({len(level_order)} levels x 2 files)")
    print()
    print("Files created:")
    for fp in created_files:
        rel = os.path.relpath(fp, BASE_DIR).replace("\\", "/")
        print(f"  {rel}")
    print()
    print("Done! Note: T10 (escort) and T11 (collect items) were skipped.")
    print("Remember to re-import the project in Godot editor to generate .uid and .import files.")


if __name__ == "__main__":
    main()
