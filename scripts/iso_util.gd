extends Node

## 等距菱形网格工具类（Autoload 单例）

const TILE_W := 64
const TILE_H := 32
const TILE_HALF_W := 32
const TILE_HALF_H := 16

const GRID_COLS := 20
const GRID_ROWS := 16


## 网格坐标 → 屏幕坐标
func grid_to_world(gx: int, gy: int) -> Vector2:
	return Vector2(
		(gx - gy) * TILE_HALF_W + TILE_HALF_W,
		(gx + gy) * TILE_HALF_H + TILE_HALF_H
	)


## 屏幕坐标 → 网格坐标（逆变换）
func snap_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(
		floori((pos.x / TILE_HALF_W + pos.y / TILE_HALF_H - 2.0) / 2.0),
		floori((pos.y / TILE_HALF_H - pos.x / TILE_HALF_W) / 2.0)
	)


## 多格建筑从原点格子到建筑中心的偏移
func building_center_offset(gw: int, gh: int) -> Vector2:
	var dx := float(gw - 1) / 2.0
	var dy := float(gh - 1) / 2.0
	return Vector2((dx - dy) * TILE_HALF_W, (dx + dy) * TILE_HALF_H)


## 获取建筑菱形轮廓（4 个顶点，绝对屏幕坐标）
func building_diamond(gx: int, gy: int, gw: int, gh: int) -> PackedVector2Array:
	var top := grid_to_world(gx, gy)
	var right := grid_to_world(gx + gw - 1, gy)
	var bottom := grid_to_world(gx + gw - 1, gy + gh - 1)
	var left := grid_to_world(gx, gy + gh - 1)
	return PackedVector2Array([
		Vector2(top.x, top.y - TILE_HALF_H),
		Vector2(right.x + TILE_HALF_W, right.y),
		Vector2(bottom.x, bottom.y + TILE_HALF_H),
		Vector2(left.x - TILE_HALF_W, left.y),
	])
