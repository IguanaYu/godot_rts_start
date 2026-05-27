extends TileMapLayer

# Tile 精灵图路径
const TILE_TEXTURES := [
	preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png"),
	preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color2.png"),
	preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color3.png"),
	preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color4.png"),
	preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color5.png"),
]
const WATER_TEXTURE := preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Water Background color.png")

const SOURCE_TILE_SIZE := Vector2i(64, 64)
const GAME_TILE_SIZE := Vector2i(64, 64)

# Atlas source IDs
const TERRAIN_SOURCE := 0
const WATER_SOURCE := 1

# 草地 tile（3x3 纯草地，无缝拼接）
# (0,0)(1,0)(2,0)
# (0,1)(1,1)(2,1)
# (0,2)(1,2)(2,2)
const GRASS_TILES := [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
]
const WATER_TILE := Vector2i(0, 0)

var _rng := RandomNumberGenerator.new()


func setup(bounds: Rect2, theme_index: int = 0, water_areas: Array[Rect2] = [], _border_width: int = 1) -> void:
	_rng.randomize()
	theme_index = clampi(theme_index, 0, TILE_TEXTURES.size() - 1)

	_build_tileset(TILE_TEXTURES[theme_index])

	var start_col := floori(bounds.position.x / GAME_TILE_SIZE.x)
	var start_row := floori(bounds.position.y / GAME_TILE_SIZE.y)
	var end_col := ceili(bounds.end.x / GAME_TILE_SIZE.x)
	var end_row := ceili(bounds.end.y / GAME_TILE_SIZE.y)

	# 全铺草地（使用中心纯填充 tile）
	for col in range(start_col, end_col):
		for row in range(start_row, end_row):
			set_cell(Vector2i(col, row), TERRAIN_SOURCE, Vector2i(1, 1))

	# 水面区域
	for area in water_areas:
		var ws := floori(area.position.x / GAME_TILE_SIZE.x)
		var wr := floori(area.position.y / GAME_TILE_SIZE.y)
		var we := ceili(area.end.x / GAME_TILE_SIZE.x)
		var wb := ceili(area.end.y / GAME_TILE_SIZE.y)
		for col in range(ws, we):
			for row in range(wr, wb):
				set_cell(Vector2i(col, row), WATER_SOURCE, WATER_TILE)


func _build_tileset(texture: Texture2D) -> void:
	var ts := TileSet.new()
	ts.tile_size = GAME_TILE_SIZE

	var terrain_atlas := TileSetAtlasSource.new()
	terrain_atlas.texture = texture
	terrain_atlas.texture_region_size = SOURCE_TILE_SIZE
	for coord in GRASS_TILES:
		terrain_atlas.create_tile(coord)
	ts.add_source(terrain_atlas, TERRAIN_SOURCE)

	var water_atlas := TileSetAtlasSource.new()
	water_atlas.texture = WATER_TEXTURE
	water_atlas.texture_region_size = Vector2i(64, 64)
	water_atlas.create_tile(WATER_TILE)
	ts.add_source(water_atlas, WATER_SOURCE)

	tile_set = ts
