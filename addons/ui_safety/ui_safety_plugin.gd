@tool
extends EditorPlugin
## UI Safety 插件入口。
## 启用时自动注册 UIBoundsValidator autoload，禁用时自动移除。
## 用户不需要手动改 project.godot。

const AUTOLOAD_NAME := "UIBoundsValidator"
const AUTOLOAD_PATH := "res://addons/ui_safety/runtime/ui_bounds_validator.gd"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	print("[UI Safety] plugin enabled — UIBoundsValidator autoload registered")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("[UI Safety] plugin disabled — UIBoundsValidator autoload removed")
