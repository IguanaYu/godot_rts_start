extends Node
class_name WSClient

## 应用层心跳参数
## - 客户端每 1s 发一次 app_ping
## - 5s 没收到任何消息（含 app_pong / game_data 等）→ emit connection_stale
##   5s = 连续 5 次心跳无响应，能容忍 1-3s 的网络抖动
##   半开连接（TCP 未断但对方不回）通过这个检测，因为 Godot WebSocketPeer 不暴露 pong 回调
const HEARTBEAT_INTERVAL := 1.0
const STALE_THRESHOLD := 5.0

var _socket: WebSocketPeer = WebSocketPeer.new()
var _connected := false
var _pending_messages: Array = []

var _heartbeat_accum: float = 0.0
var _time_since_last_msg: float = 0.0
var _stale_emitted: bool = false

func _ready():
	set_process(true)

func connect_to_server(url: String) -> bool:
	# 幂等：已连接或正在连接时直接返回成功，避免 ERR_ALREADY_IN_USE
	# WebSocketPeer 的状态判断必须在 _socket.poll() 之后才准确，这里先 poll 一次
	_socket.poll()
	var cur_state := _socket.get_ready_state()
	if cur_state == WebSocketPeer.STATE_OPEN:
		if not _connected:
			# 之前没标记为 connected（边界情况），补一次 emit
			_connected = true
			connected.emit()
		return true
	if cur_state == WebSocketPeer.STATE_CONNECTING:
		return true

	# CLOSED 或 CLOSING：必须新建 socket 才能重连（Godot 4.6 限制）
	# 否则 connect_to_url 会返回 ALREADY_IN_USE
	if cur_state == WebSocketPeer.STATE_CLOSED or cur_state == WebSocketPeer.STATE_CLOSING:
		if cur_state == WebSocketPeer.STATE_CLOSING:
			# 等下一帧再尝试（CLOSING 转 CLOSED 需要时间），避免立即重连
			push_warning("WSClient: socket still closing, will retry next frame")
			return false
		# 重新创建 socket 实例
		_socket = WebSocketPeer.new()
		_connected = false

	var err := _socket.connect_to_url(url)
	if err != OK:
		push_error("WebSocket connect failed: ", err)
		connection_error.emit()
		return false
	# 重置心跳状态
	_heartbeat_accum = 0.0
	_time_since_last_msg = 0.0
	_stale_emitted = false
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

func _process(delta):
	_socket.poll()
	var state := _socket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass
		WebSocketPeer.STATE_OPEN:
			if not _connected:
				_connected = true
				_time_since_last_msg = 0.0
				_stale_emitted = false
				connected.emit()
				for msg in _pending_messages:
					_socket.send_text(msg)
				_pending_messages.clear()
			_read_messages()
			_update_heartbeat(delta)
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
		# 收到任何消息都重置 stale 计时
		_time_since_last_msg = 0.0
		_stale_emitted = false
		message_received.emit(data.get("type", ""), data.get("payload", {}))

func _update_heartbeat(delta: float) -> void:
	# 1. 定时发 app_ping（ping 值更新用，常开）
	_heartbeat_accum += delta
	if _heartbeat_accum >= HEARTBEAT_INTERVAL:
		_heartbeat_accum = 0.0
		send_message("app_ping", {"t": Time.get_ticks_msec()})

	# 2. Stale 检测只在游戏中启用（TickManager.enabled）
	#    主菜单/lobby/loading 阶段双方无定时数据往来（command_buffer 还没启动），
	#    检测 stale 必然误判。这些阶段靠 TCP 断开检测（STATE_CLOSED）就够。
	#    游戏中 tick 在推进 + 每 tick 都发 game_data，5s 没消息才说明真出事。
	if not TickManager.enabled:
		_time_since_last_msg = 0.0
		_stale_emitted = false
		return

	_time_since_last_msg += delta
	if _time_since_last_msg >= STALE_THRESHOLD and not _stale_emitted:
		_stale_emitted = true
		push_warning("WSClient: connection stale (%.1fs no messages)" % _time_since_last_msg)
		connection_stale.emit()

signal connected()
signal disconnected()
signal message_received(type: String, payload: Dictionary)
signal connection_error()
signal connection_stale()
