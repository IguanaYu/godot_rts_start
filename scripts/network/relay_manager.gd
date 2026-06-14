extends Node

const SERVER_URL := "ws://111.229.19.23:8080"

## 连接丢失原因（用于 UI 弹窗文案区分）
## - "disconnected": 服务器主动断开 / TCP 连接关闭（包括我们这边 ws.close()）
## - "stale": 半开连接（连续 15s 没收到任何消息）
## - "peer_left": 对方玩家断开（服务器通过 peer_timeout 推送）
## - "desync": 状态不一致（由 StateHasher 触发，Step 2 接入）
## - "manual": 我们自己主动断开（不算异常）
var ws_client: WSClient
var room_code := ""
var my_player_id := 0
var is_host := false
var _map_name := "map_1"
var _game_seed := 0
var is_online := false

## 应用层 ping（ms），由 app_pong echo 时间戳计算
var ping_ms: int = 0

## 标志：避免我们主动 close 时还触发 connection_lost
var _manual_disconnect: bool = false

func _ready():
	ws_client = WSClient.new()
	ws_client.name = "WSClient"
	add_child(ws_client)
	ws_client.message_received.connect(_on_message)
	ws_client.connected.connect(_on_connected)
	ws_client.disconnected.connect(_on_disconnected)
	ws_client.connection_stale.connect(_on_ws_stale)

func connect_to_server():
	ws_client.connect_to_server(SERVER_URL)

func disconnect_from_server():
	_manual_disconnect = true
	ws_client.disconnect_from_server()

func request_room_list():
	ws_client.send_message("list_rooms", {})

func create_room(room_name: String):
	ws_client.send_message("create_room", {"name": room_name})

func join_room(code: String):
	ws_client.send_message("join_room", {"code": code})

func leave_room():
	ws_client.send_message("leave_room", {})

func send_ready():
	ws_client.send_message("ready", {})

func send_start_game():
	ws_client.send_message("start_game", {})

func send_load_complete():
	ws_client.send_message("load_complete", {})

func send_game_data(data: Dictionary):
	ws_client.send_message("game_data", data)

func update_map(map_name: String):
	_map_name = map_name
	ws_client.send_message("update_map", {"map": map_name})

func _on_connected():
	print("[RelayManager] Connected to server")
	is_online = true
	_manual_disconnect = false
	connected_to_server.emit()

func _on_disconnected():
	print("[RelayManager] Disconnected from server")
	is_online = false
	ping_ms = 0
	if _manual_disconnect:
		_manual_disconnect = false
		return
	connection_lost.emit("disconnected")

func _on_ws_stale():
	# 半开连接：socket 还没关，但 15s 没收到任何消息
	# 主动断开以触发后续 close 流程；connection_lost 用 "stale" 原因
	if _manual_disconnect:
		return
	push_warning("[RelayManager] Connection stale, forcing disconnect")
	ws_client.disconnect_from_server()
	connection_lost.emit("stale")

func _on_message(type: String, payload: Dictionary):
	match type:
		"app_pong":
			_update_ping(payload)
		"peer_timeout":
			# 服务器告诉我们：对方玩家心跳超时
			peer_timeout.emit(payload.get("player_id", 0))
			if not _manual_disconnect:
				connection_lost.emit("peer_left")
		"room_list":
			room_list_received.emit(payload.get("rooms", []))
		"room_created":
			room_code = payload.get("code", "")
			is_host = true
			my_player_id = 1
			room_created.emit(room_code)
		"room_joined":
			room_code = payload.get("code", "")
			is_host = false
			my_player_id = 2
			room_joined.emit(room_code)
		"player_joined":
			player_joined.emit(payload.get("player_id", 0))
		"player_left":
			player_left.emit()
			# 对方玩家离开（正常关窗口 / 心跳超时被踢 / 主动 leave_room）
			# 视为连接丢失，触发暂停 + 弹窗
			if not _manual_disconnect:
				connection_lost.emit("peer_left")
		"player_ready":
			player_ready.emit(payload.get("ready", false))
		"start_game":
			_map_name = payload.get("map", "map_1")
			game_starting.emit()
		"map_changed":
			_map_name = payload.get("map", "map_1")
			map_changed.emit(_map_name)
		"both_loaded":
			_game_seed = payload.get("seed", 0)
			both_loaded.emit(_game_seed)
		"game_data":
			_handle_game_data(payload)
		"error":
			push_error("[RelayManager] Server error: ", payload.get("message", ""))

func _update_ping(payload: Dictionary) -> void:
	# payload = { t: server_ms, echo: client_ms_at_send }
	var echo: int = payload.get("echo", 0)
	if echo > 0:
		var now_ms := Time.get_ticks_msec()
		var new_ping := maxi(0, now_ms - echo)
		ping_ms = new_ping
		ping_updated.emit(new_ping)

func _handle_game_data(payload: Dictionary):
	var data_type: String = payload.get("type", "")
	if data_type == "commands":
		var tick: int = payload.get("tick", 0)
		var cmds: Array = payload.get("commands", [])
		CommandBuffer.receive_remote_commands(tick, payload.get("player", 0), cmds)
	elif data_type == "hash":
		StateHasher.receive_remote_hash(payload.get("tick", 0), payload.get("hash", 0))

signal room_list_received(rooms: Array)
signal room_created(code: String)
signal room_joined(code: String)
signal player_joined(player_id: int)
signal player_left()
signal player_ready(ready: bool)
signal game_starting()
signal both_loaded(seed: int)
signal connected_to_server()
signal map_changed(map_name: String)
## 网络异常：reason 见文件顶注释
signal connection_lost(reason: String)
## 对方心跳超时（服务器推送）
signal peer_timeout(player_id: int)
## ping 值更新（用于状态条显示）
signal ping_updated(ping_ms: int)
