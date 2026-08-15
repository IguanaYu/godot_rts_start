class_name ParticleTextures
extends Object
## 粒子纹理代码生成 + 静态缓存：软圆盘 / 硬芯亮点 / 小方块
## GPU 粒子配方 .tscn 里 texture 留空，由 gpu_particle_effect.gd 注入

enum Kind { DISC, SPARK, SQUARE }

const DISC_SIZE := 64
const SPARK_SIZE := 16
const SQUARE_SIZE := 8

static var _disc: ImageTexture
static var _spark: ImageTexture
static var _square: ImageTexture


static func get_texture(kind: Kind) -> ImageTexture:
	match kind:
		Kind.DISC:
			if _disc == null:
				_disc = _make_disc()
			return _disc
		Kind.SPARK:
			if _spark == null:
				_spark = _make_spark()
			return _spark
		Kind.SQUARE:
			if _square == null:
				_square = _make_square()
			return _square
	push_error("ParticleTextures: unknown kind %d" % kind)
	return null


static func _make_disc() -> ImageTexture:
	var img := Image.create(DISC_SIZE, DISC_SIZE, false, Image.FORMAT_RGBA8)
	var center := float(DISC_SIZE - 1) * 0.5
	for y in DISC_SIZE:
		for x in DISC_SIZE:
			var d: float = Vector2(x - center, y - center).length() / center
			var a: float = clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)


static func _make_spark() -> ImageTexture:
	var img := Image.create(SPARK_SIZE, SPARK_SIZE, false, Image.FORMAT_RGBA8)
	var center := float(SPARK_SIZE - 1) * 0.5
	for y in SPARK_SIZE:
		for x in SPARK_SIZE:
			var d: float = Vector2(x - center, y - center).length() / center
			# 硬芯 + 快速衰减
			var a: float = clampf((1.0 - d) * 3.0, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)


static func _make_square() -> ImageTexture:
	var img := Image.create(SQUARE_SIZE, SQUARE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)
