class_name Faction
extends RefCounted

## 势力颜色（视觉层）。
## 颜色只决定单位/建筑的贴图目录，与控制权/胜负无关：
## - 控制权由 Unit.owner_id 决定
## - 胜负/敌对由 Unit.alliance_id 决定

enum ColorId { BLACK, BLUE, PURPLE, RED, YELLOW, NEUTRAL }

const DIR_NAMES := ["black", "blue", "purple", "red", "yellow"]

static func color_dir(c: int) -> String:
	if c >= 0 and c < DIR_NAMES.size():
		return DIR_NAMES[c]
	return "blue"

## 贴图路径是否真实存在；用于 _setup_texture() 决定是否走 fallback。
static func asset_dir_exists(color: int, unit_dir_name: String) -> bool:
	var path := "res://assets/units/%s_%s" % [color_dir(color), unit_dir_name]
	return ResourceLoader.exists(path + "/Idle.png") or ResourceLoader.exists(path + "/Warrior_Idle.png") or DirAccess.dir_exists_absolute(path)
