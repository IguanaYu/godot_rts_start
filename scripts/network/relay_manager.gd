extends Node

const SERVER_URL := "ws://111.229.19.23:8080"

var ws_client: WSClient
var room_code := ""
var my_player_id := 0
var is_host := false
var _map_name := "map_1"
var _game_seed := 0

func _ready():
	ws_client = WSClient.new()
	ws_client.name = "WSClient"
	add_child(ws_client)
	ws_client.message_received.connect(_on_message)
	ws_client.connected.connect(_on_connected)
	ws_client.disconnected.connect(_on_disconnected)

func connect_to_server():
	ws_client.connect_to_server(SERVER_URL)

func disconnect_from_server():
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

func _on_connected():
	print("[RelayManager] Connected to server")
	connected_to_server.emit()

func _on_disconnected():
	print("[RelayManager] Disconnected from server")

func _on_message(type: String, payload: Dictionary):
	match type:
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
		"player_ready":
			player_ready.emit(payload.get("ready", false))
		"start_game":
			_map_name = payload.get("map", "map_1")
			game_starting.emit()
		"both_loaded":
			_game_seed = payload.get("seed", 0)
			both_loaded.emit(_game_seed)
		"game_data":
			_handle_game_data(payload)
		"error":
			push_error("[RelayManager] Server error: ", payload.get("message", ""))

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
