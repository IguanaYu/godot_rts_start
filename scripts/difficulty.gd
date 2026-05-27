class_name Difficulty
extends RefCounted

## 难度系统：枚举、默认值、持久化读写

enum Level { EASY, NORMAL, HARD }

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "game"
const SETTINGS_KEY := "difficulty"

const _PresetScript := preload("res://scripts/difficulty_preset.gd")

## 默认预设值（未配置时的回退）
static func _make_default(level: int) -> Resource:
	var p: Resource = _PresetScript.new()
	match level:
		Level.EASY:
			p.hp_mult = 0.7
			p.atk_mult = 0.8
			p.speed_mult = 0.9
			p.count_mult = 0.8
			p.gold_mult = 1.25
			p.wave_delay_mult = 1.4
		Level.NORMAL:
			pass
		Level.HARD:
			p.hp_mult = 1.5
			p.atk_mult = 1.4
			p.speed_mult = 1.15
			p.count_mult = 1.3
			p.gold_mult = 0.75
			p.wave_delay_mult = 0.7
	return p

## 获取指定地图+难度的预设。优先用地图配置，null 则回退默认值
static func get_preset(map_config: Resource, level: int) -> Resource:
	if map_config != null:
		var preset: Resource = null
		match level:
			Level.EASY:
				preset = map_config.easy_preset
			Level.NORMAL:
				preset = map_config.normal_preset
			Level.HARD:
				preset = map_config.hard_preset
		if preset != null:
			return preset
	return _make_default(level)

## 持久化难度选择到 settings.cfg
static func save_to_config(level: int) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(SETTINGS_SECTION, SETTINGS_KEY, level)
	config.save(SETTINGS_PATH)

## 从 settings.cfg 读取难度选择，默认 NORMAL
static func load_from_config() -> int:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		return config.get_value(SETTINGS_SECTION, SETTINGS_KEY, Level.NORMAL)
	return Level.NORMAL
