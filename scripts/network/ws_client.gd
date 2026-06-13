extends Node
class_name WSClient

var _socket: WebSocketPeer = WebSocketPeer.new()
var _connected := false
var _pending_messages: Array = []

func _ready():
	set_process(true)

func connect_to_server(url: String) -> bool:
	var err := _socket.connect_to_url(url)
	if err != OK:
		push_error("WebSocket connect failed: ", err)
		connection_error.emit()
		return false
	return true

func disconnect_from_server():
	_socket.close()
	_connected = false
	disconnected.emit()

func send_message(type: String, payload: Dictionary):
	var msg := JSON.stringify({"type": type, "payload": payload})
	if _connected:
		_socket.send_text(msg)
	else:
		_pending_messages.append(msg)

func _process(_delta):
	_socket.poll()
	var state := _socket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass
		WebSocketPeer.STATE_OPEN:
			if not _connected:
				_connected = true
				connected.emit()
				for msg in _pending_messages:
					_socket.send_text(msg)
				_pending_messages.clear()
			_read_messages()
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CLOSED:
			if _connected:
				_connected = false
				disconnected.emit()

func _read_messages():
	while _socket.get_available_packet_count() > 0:
		var packet := _socket.get_packet()
		var text := packet.get_string_from_utf8()
		var json := JSON.new()
		var err := json.parse(text)
		if err != OK:
			push_warning("WS: failed to parse: ", text)
			continue
		var data: Dictionary = json.get_data()
		message_received.emit(data.get("type", ""), data.get("payload", {}))

signal connected()
signal disconnected()
signal message_received(type: String, payload: Dictionary)
signal connection_error()
