extends Node
## 玩家指挥官选择状态：跨场景持久化（main_menu → level_select → commander_select → main）
## main.gd Step 7 通过 player_selected_id 读取

var player_selected_id: StringName = &"balanced"

## 由 commander_select.gd 在确认时调用
func select_commander(cmd_id: StringName) -> void:
	player_selected_id = cmd_id

## 由 level_select 在进入指挥官选择前调用，暂存待加载关卡
var pending_level_scene: String = ""
var pending_level_id: String = ""

func set_pending_level(scene_path: String, level_id: String) -> void:
	pending_level_scene = scene_path
	pending_level_id = level_id
