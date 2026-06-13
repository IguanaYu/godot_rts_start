extends Node

## 网络管理器 - 通过 RelayManager 管理房间和连接状态

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal connection_failed()

var is_host := false
var my_id := 1
var is_online := false
var room_code := ""

func _ready():
	RelayManager.room_created.connect(_on_room_created)
	RelayManager.room_joined.connect(_on_room_joined)
	RelayManager.player_joined.connect(_on_player_joined)
	RelayManager.player_left.connect(_on_player_left)
	RelayManager.connected_to_server.connect(_on_server_connected)

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

func _on_room_joined(code: String):
	is_host = false
	my_id = 2
	is_online = true
	room_code = code

func _on_player_joined(player_id: int):
	peer_connected.emit(player_id)

func _on_player_left():
	peer_disconnected.emit(0)
