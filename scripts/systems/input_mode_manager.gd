extends Node
## 输入模式管理器：Q键造兵模式 / W键建筑模式 / 默认编队模式

enum InputMode { DEFAULT, UNIT_PRODUCTION, BUILDING_PLACEMENT, COMMANDER_SKILL_CAST, RALLY_PLACEMENT }

var current_mode: InputMode = InputMode.DEFAULT

signal mode_changed(new_mode: int)


func enter_unit_production() -> void:
	if current_mode == InputMode.UNIT_PRODUCTION:
		# Toggle: 再按一次Q退出
		cancel_mode()
		return
	current_mode = InputMode.UNIT_PRODUCTION
	mode_changed.emit(current_mode)


func enter_building_placement() -> void:
	if current_mode == InputMode.BUILDING_PLACEMENT:
		# Toggle: 再按一次W退出
		cancel_mode()
		return
	current_mode = InputMode.BUILDING_PLACEMENT
	mode_changed.emit(current_mode)


func cancel_mode() -> void:
	if current_mode == InputMode.DEFAULT:
		return
	current_mode = InputMode.DEFAULT
	mode_changed.emit(current_mode)


func is_default() -> bool:
	return current_mode == InputMode.DEFAULT


func is_unit_production() -> bool:
	return current_mode == InputMode.UNIT_PRODUCTION


func is_building_placement() -> bool:
	return current_mode == InputMode.BUILDING_PLACEMENT


func enter_commander_skill_cast() -> void:
	if current_mode == InputMode.COMMANDER_SKILL_CAST:
		cancel_mode()
		return
	current_mode = InputMode.COMMANDER_SKILL_CAST
	mode_changed.emit(current_mode)


func is_commander_skill_cast() -> bool:
	return current_mode == InputMode.COMMANDER_SKILL_CAST


func enter_rally_placement() -> void:
	if current_mode == InputMode.RALLY_PLACEMENT:
		# Toggle: 再按一次Y退出
		cancel_mode()
		return
	current_mode = InputMode.RALLY_PLACEMENT
	mode_changed.emit(current_mode)


func is_rally_placement() -> bool:
	return current_mode == InputMode.RALLY_PLACEMENT
