class_name MinimapMarkerData
extends RefCounted
## 小地图标记数据结构。外部系统创建此实例，通过 register_marker() 注册到 minimap。

# === 形状枚举 ===
enum Shape {
	CIRCLE,    # 圆点
	DIAMOND,   # 菱形
	TRIANGLE,  # 三角形
	SQUARE,    # 方块
	STAR,      # 星形（十字交叉线）
	CROSS,     # 十字（ping 用）
}

# === 动画枚举 ===
enum Anim {
	NONE,          # 静态
	PULSE,         # 脉动呼吸（sin 波驱动大小+alpha）
	BLINK,         # 闪烁（方波开关）
	EXPAND_RING,   # 扩散环（从小→大，渐隐消失）
	BOUNCE,        # 弹跳（Y 轴上下轻跳）
	FADE_OUT,      # 收缩消失（缩小+淡出）
	COLOR_BREATHE, # 颜色呼吸（两色间平滑渐变）
	ROTATE,        # 旋转
	RIPPLE,        # 波纹（多圈连续扩散环）
	SHAKE,         # 抖动（随机位置偏移）
	BURST,         # 脉冲爆发（突大→回缩）
}

# === 属性 ===
var world_pos: Vector2        # 世界坐标
var shape: Shape = Shape.CIRCLE
var color: Color = Color.WHITE
var size: float = 3.0         # 基础大小（半径/边长）
var priority: int = 0         # 越高越靠上层绘制
var anim_type: Anim = Anim.NONE
var anim_speed: float = 1.0   # 动画速度倍率
var lifetime: float = 0.0     # 0=永久，>0=到期自动移除
var group: String = ""        # 分组 ID，可批量 hide/show
var visible: bool = true

# === 内部状态 ===
var _marker_id: int = -1
var _elapsed: float = 0.0     # 已存活时间（秒）
var _anim_phase: float = 0.0  # 动画相位偏移（用于非同步启动）
var _extra: Dictionary = {}   # 自定义扩展数据

# 颜色呼吸用
var color_b: Color = Color.WHITE  # 呼吸渐变的目标色


func _init(p_world_pos: Vector2, p_color: Color, p_shape: Shape = Shape.CIRCLE,
		p_size: float = 3.0, p_anim: Anim = Anim.NONE, p_lifetime: float = 0.0) -> void:
	world_pos = p_world_pos
	color = p_color
	shape = p_shape
	size = p_size
	anim_type = p_anim
	lifetime = p_lifetime


## 工厂方法：快速创建一个扩散环 ping
static func make_ping(world_pos: Vector2, color: Color, duration: float = 1.5,
		shape: Shape = Shape.CROSS) -> MinimapMarkerData:
	var m := MinimapMarkerData.new(world_pos, color, shape, 4.0, Anim.EXPAND_RING, duration)
	m._anim_phase = 0.0
	return m
