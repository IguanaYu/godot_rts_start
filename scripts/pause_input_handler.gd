extends Control

# ESC handler for pause menu - runs even when tree is paused
# because parent CanvasLayer has PROCESS_MODE_ALWAYS

var main_node: Node2D = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if main_node and main_node.ui_module and main_node.ui_module.pause_menu_open:
			main_node.ui_module.close_pause_menu()
