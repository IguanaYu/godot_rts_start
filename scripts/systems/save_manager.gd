extends Node

## 存档管理系统：3 个存档位，JSON 格式持久化

signal save_updated(slot: int)

const SAVE_DIR := "user://saves/"
const SLOTS := 3
const SETTINGS_PATH := "user://settings.cfg"
const LEVELS := [
	"map_1", "map_2", "map_3", "map_4",
	"map_5", "map_6", "map_7", "map_8",
	"map_9", "map_10", "map_11", "map_12",
	"map_13", "map_14", "map_15", "map_16",
]
const LEVEL_SCORES := {
	"map_1": 10, "map_2": 15, "map_3": 20, "map_4": 25,
	"map_5": 20, "map_6": 30, "map_7": 30, "map_8": 35,
	"map_9": 40, "map_10": 40, "map_11": 40, "map_12": 45,
	"map_13": 45, "map_14": 45, "map_15": 50, "map_16": 50,
}

var _current_slot: int = -1
var _session_start_time: float = 0.0
var _session_level_id: String = ""


func _ready() -> void:
	_ensure_save_dir()


func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func get_slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_slot_path(slot))


func load_slot(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return _empty_slot()
	var file := FileAccess.open(get_slot_path(slot), FileAccess.READ)
	if file == null:
		return _empty_slot()
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return _empty_slot()
	var data: Dictionary = json.data
	# 确保所有关卡都有条目
	for level_id in LEVELS:
		if not data.get("levels", {}).has(level_id):
			data["levels"][level_id] = _empty_level_entry()
	return data


func save_slot(slot: int, data: Dictionary) -> void:
	_ensure_save_dir()
	data["last_played"] = Time.get_datetime_string_from_system()
	var file := FileAccess.open(get_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to write slot %d" % slot)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	save_updated.emit(slot)


func delete_slot(slot: int) -> void:
	if slot_exists(slot):
		DirAccess.remove_absolute(get_slot_path(slot))


func _empty_slot() -> Dictionary:
	var levels := {}
	for level_id in LEVELS:
		levels[level_id] = _empty_level_entry()
	return {
		"version": 1,
		"slot_name": "Commander",
		"created_at": Time.get_datetime_string_from_system(),
		"last_played": "",
		"total_score": 0,
		"levels": levels,
	}


func _empty_level_entry() -> Dictionary:
	return {
		"completed": false,
		"best_time_seconds": null,
		"best_score": 0,
		"completion_date": null,
		"difficulty": null,
		"play_count": 0,
	"stars": 0,
	"bonus_objectives": {},
	}


func get_level_score_value(level_id: String) -> int:
	return LEVEL_SCORES.get(level_id, 0)


func is_level_unlocked(data: Dictionary, level_index: int) -> bool:
	if level_index <= 0:
		return true
	var prev_id: String = LEVELS[level_index - 1]
	return data.get("levels", {}).get(prev_id, {}).get("completed", false)


func calc_total_score(data: Dictionary) -> int:
	var total := 0
	for level_id in LEVELS:
		var lvl: Dictionary = data.get("levels", {}).get(level_id, {})
		total += int(lvl.get("best_score", 0))
	return total


func get_completed_count(data: Dictionary) -> int:
	var count := 0
	for level_id in LEVELS:
		var lvl: Dictionary = data.get("levels", {}).get(level_id, {})
		if lvl.get("completed", false):
			count += 1
	return count


# === 当前存档上下文 ===

func get_current_slot() -> int:
	return _current_slot


func set_current_slot(slot: int) -> void:
	_current_slot = slot


func get_current_data() -> Dictionary:
	if _current_slot < 0:
		return _empty_slot()
	return load_slot(_current_slot)


func save_current_data(data: Dictionary) -> void:
	if _current_slot < 0:
		return
	data["total_score"] = calc_total_score(data)
	save_slot(_current_slot, data)


# === 默认存档（快速进入）===

func get_default_slot() -> int:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		var slot: int = config.get_value("save", "last_active_slot", 0)
		if slot >= 0 and slot < SLOTS:
			return slot
	return 0


func set_default_slot(slot: int) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("save", "last_active_slot", slot)
	config.save(SETTINGS_PATH)


# 一键进入默认存档：设 current_slot → 不存在则初始化空档 → 写回记录
func enter_default_slot() -> void:
	var slot := get_default_slot()
	set_current_slot(slot)
	if not slot_exists(slot):
		save_slot(slot, _empty_slot())
	set_default_slot(slot)


# === 游戏会话追踪 ===

func start_game_session(level_id: String) -> void:
	_session_level_id = level_id
	_session_start_time = Time.get_ticks_msec() / 1000.0
	# 增加游玩次数
	if _current_slot < 0:
		return
	var data := load_slot(_current_slot)
	var lvl: Dictionary = data.get("levels", {}).get(level_id, {})
	lvl["play_count"] = int(lvl.get("play_count", 0)) + 1
	data["levels"][level_id] = lvl
	save_current_data(data)


func end_game_session(result: String, difficulty: int) -> void:
	if _current_slot < 0 or _session_level_id == "":
		return
	if result != "victory":
		return
	var elapsed := Time.get_ticks_msec() / 1000.0 - _session_start_time
	var data := load_slot(_current_slot)
	var level_id := _session_level_id
	var lvl: Dictionary = data.get("levels", {}).get(level_id, {})
	var prev_best: float = lvl.get("best_time_seconds", 999999.0) if lvl.get("best_time_seconds") != null else 999999.0
	lvl["completed"] = true
	lvl["best_score"] = get_level_score_value(level_id)
	lvl["difficulty"] = difficulty
	if elapsed < prev_best:
		lvl["best_time_seconds"] = snappedf(elapsed, 0.1)
	if lvl.get("completion_date") == null:
		lvl["completion_date"] = Time.get_datetime_string_from_system()
	data["levels"][level_id] = lvl
	save_current_data(data)
	_session_level_id = ""
	_session_start_time = 0.0


func get_last_session_time() -> float:
	return Time.get_ticks_msec() / 1000.0 - _session_start_time if _session_start_time > 0 else 0.0


func format_time(seconds: float) -> String:
	if seconds <= 0:
		return "--"
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%dm %02ds" % [mins, secs]


func format_date(date_str: String) -> String:
	if date_str == "":
		return "--"
	# ISO datetime "2026-06-03T14:30:00" -> "2026-06-03"
	return date_str.split("T")[0]
