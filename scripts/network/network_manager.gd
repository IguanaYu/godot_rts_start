extends Node

## 网络管理器 - 通过 RelayManager 管理房间和连接状态

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal connection_failed()

var is_host := false
var my_id := 1
var is_online := false
var room_code := ""

## 玩家会话：player_id -> { alliance_id, slot_id, color, gold }
## - alliance_id: 联盟（0=玩家方, 1=敌方, 预留 2/3 给 PvP）
## - slot_id:    联盟内的槽位。同 alliance+slot 多人 = 共享单位控制权（co-op）
## - color:      Faction.Color 枚举值
## - gold:       玩家金币（各自独立；同槽 co-op 也不共享）
var player_sessions: Dictionary = {}
var player_count: int = 1

# 默认 slot 颜色轮转表（避开 RED=3 留给敌人）
const SLOT_COLORS := [0, 1, 2, 4]  # BLACK, BLUE, PURPLE, YELLOW

func _ready():
	RelayManager.room_created.connect(_on_room_created)
	RelayManager.room_joined.connect(_on_room_joined)
	RelayManager.player_joined.connect(_on_player_joined)
	RelayManager.player_left.connect(_on_player_left)
	RelayManager.connected_to_server.connect(_on_server_connected)
	# 单机/启动默认：自己占 slot 0
	_ensure_session(1)

## 按 player_id deterministic 分配默认 session（无需 RPC 同步）
func _ensure_session(pid: int) -> void:
	if player_sessions.has(pid):
		return
	var slot := maxi(0, pid - 1)
	var color: int = SLOT_COLORS[slot % SLOT_COLORS.size()]
	player_sessions[pid] = {
		"alliance_id": 0,
		"slot_id": slot,
		"color": color,
		"gold": -1,  # -1 = 未初始化，由 main.gd 按 slot 配置填充
	}

func set_player_slot(player_id: int, alliance_id: int, slot_id: int, color: int = -1) -> void:
	_ensure_session(player_id)
	var sess: Dictionary = player_sessions[player_id]
	sess["alliance_id"] = alliance_id
	sess["slot_id"] = slot_id
	if color >= 0:
		sess["color"] = color

func get_player_session(player_id: int) -> Dictionary:
	return player_sessions.get(player_id, {})

func create_room(room_name: String):
	RelayManager.connect_to_server()
	await _wait_connected()
	RelayManager.create_room(room_name)

func join_room(code: String):
	RelayManager.connect_to_server()
	await _wait_connected()
	RelayManager.join_room(code)

func close():
	RelayManager.leave_room()
	is_online = false
	is_host = false
	room_code = ""

func _wait_connected():
	if RelayManager.ws_client._connected:
		return
	await RelayManager.ws_client.connected

func _on_server_connected():
	pass

func _on_room_created(code: String):
	is_host = true
	my_id = 1
	is_online = true
	room_code = code
	player_sessions.clear()
	_ensure_session(1)
	player_count = 1

func _on_room_joined(code: String):
	is_host = false
	my_id = RelayManager.my_player_id  # 服务器分配；当前服务器实现固定 2，未来可扩展 N
	is_online = true
	room_code = code
	# 房间内已有玩家（host=1 + 自己=my_id）都建 deterministic session
	player_sessions.clear()
	for pid in range(1, my_id + 1):
		_ensure_session(pid)
	player_count = player_sessions.size()

func _on_player_joined(player_id: int):
	# server 推送的 player_id 是 server 内部 connection id（如 9），跟 client 自己写死的
	# my_id (=2) 不一致。两端 player_sessions 必须用一致的 pid 才能让 lockstep 命令的
	# player 字段对得上（命令里写 NetworkManager.my_id）。
	# 当前 server 协议只支持 2 人，client 的 my_id 固定为 2，所以 host 端用 deterministic pid=2
	# 表示 client。N 玩家扩展需要 server 在 "room_joined" payload 里包含 client 自己的 pid。
	var deterministic_pid := 2
	if not player_sessions.has(deterministic_pid):
		_ensure_session(deterministic_pid)
	player_count = player_sessions.size()
	peer_connected.emit(deterministic_pid)

func _on_player_left():
	# 不删 session（保留位置便于断线重连），只更新 count
	player_count = maxi(1, player_sessions.size())
	peer_disconnected.emit(0)
