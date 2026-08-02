extends Control
## T1 PR-2: 兵营头顶队列 UI
# 仅显示 5 个 icon slot（首位进度由 building 的 _production_circle 圆圈反馈，与 CASTLE/FARM 同款）
# 挂在 building.gd 子节点；setup(building) 接收 building 引用并 connect queue_changed

const D := preload("res://scripts/systems/game_data.gd")

const SLOT_SIZE: int = 24
const SLOT_GAP: int = 4
const SLOT_COUNT: int = 5

var _building: Node = null
var _slots: Array[TextureRect] = []
var _stats_id_to_icon: Dictionary = {}
var _icon_map_inited: bool = false


func _ready() -> void:
	# Control 在 Node2D 父节点下 anchors 行为异常，改用绝对 size + 由 building 直接设 position
	var total_w: float = float(SLOT_COUNT * SLOT_SIZE + (SLOT_COUNT - 1) * SLOT_GAP)
	custom_minimum_size = Vector2(total_w, float(SLOT_SIZE))
	size = Vector2(total_w, float(SLOT_SIZE))
	# 动态创建 5 个 slot
	for i in range(SLOT_COUNT):
		var slot := TextureRect.new()
		slot.name = "Slot%d" % i
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.position = Vector2(i * (SLOT_SIZE + SLOT_GAP), 0)
		slot.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.modulate.a = 0.2
		add_child(slot)
		_slots.append(slot)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(b: Node) -> void:
	_building = b
	if not b.queue_changed.is_connected(_on_queue_changed):
		b.queue_changed.connect(_on_queue_changed)
	_on_queue_changed(b)


func _ensure_icon_map() -> void:
	if _icon_map_inited:
		return
	_icon_map_inited = true
	# 反向 PLACE_MODE_TO_STATS_ID → icon texture（trimmed atlas，避免显示整张精灵图）
	for mode in D.PLACE_MODE_TO_STATS_ID:
		var sid = D.PLACE_MODE_TO_STATS_ID[mode]
		var raw_tex = D.ICON_TEXTURES.get(mode, null)
		_stats_id_to_icon[sid] = _trim_to_first_frame(raw_tex)
	# 默认兵营出 SOLDIER：空 stats_id → SOLDIER icon
	var soldier_raw = D.ICON_TEXTURES.get(D.PlaceMode.SOLDIER, null)
	_stats_id_to_icon[&""] = _trim_to_first_frame(soldier_raw)


## 把横向 spritesheet（如 Warrior_Idle.png）切成首帧 AtlasTexture，避免 TextureRect 显示整张图
## alpha 阈值 0.6 过滤掉源 PNG 自带的脚底阴影（黑色 alpha≈0.3）
func _trim_to_first_frame(tex: Texture2D) -> AtlasTexture:
	if tex == null:
		return null
	var img: Image = tex.get_image()
	var tw: int = img.get_width()
	var th: int = img.get_height()
	var frame_w: int
	var frame_h: int
	if tw > th:
		var frame_count: int = tw / th if th > 0 else 1
		if frame_count > 0:
			frame_w = tw / frame_count
		else:
			frame_w = tw
		frame_h = th
	else:
		frame_w = tw
		frame_h = th
	# 自定义 bbox：用 alpha > 0.6 阈值过滤阴影（默认 get_used_rect alpha>0 包含阴影）
	var bbox := _find_used_rect_threshold(img, frame_w, frame_h, 0.6)
	if bbox.size.x <= 0 or bbox.size.y <= 0:
		bbox = Rect2i(0, 0, frame_w, frame_h)
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(bbox.position.x, bbox.position.y, bbox.size.x, bbox.size.y)
	return atlas


## 在 (0,0)-(w,h) 区域内查找 alpha > threshold 的像素边界（CPU 遍历，启动时 1 次/纹理可接受）
func _find_used_rect_threshold(img: Image, w: int, h: int, threshold: float) -> Rect2i:
	var min_x: int = w
	var min_y: int = h
	var max_x: int = -1
	var max_y: int = -1
	for y in range(h):
		for x in range(w):
			if img.get_pixel(x, y).a > threshold:
				if x < min_x:
					min_x = x
				if y < min_y:
					min_y = y
				if x > max_x:
					max_x = x
				if y > max_y:
					max_y = y
	if max_x < 0:
		return Rect2i(Vector2i.ZERO, Vector2i.ZERO)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _on_queue_changed(_b: Node) -> void:
	if _building == null or not is_instance_valid(_building):
		return
	_ensure_icon_map()
	var state: Dictionary = _building.get_queue_state()
	var q: Array = state.queue
	for i in range(_slots.size()):
		if i < q.size():
			var sid = q[i]
			_slots[i].texture = _stats_id_to_icon.get(sid, null)
			_slots[i].modulate.a = 1.0
		else:
			_slots[i].texture = null
			_slots[i].modulate.a = 0.2
