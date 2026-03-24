extends Node
# OnlineNetwork.gd
# WebSocket 联机网络模块
# 挂载为 Autoload 单例: OnlineNetwork
#
# 职责：
# - 连接/断开 WebSocket 服务器
# - 管理房间（创建/加入/离开）
# - 发送/接收玩家实时状态
# - 发送/接收游戏事件

const SERVER_URL = "ws://124.222.176.41:8080"

var _ws: WebSocketClient = null
var is_connected: bool = false

# 本地玩家信息
var my_player_id: int = 0
var my_player_name: String = "Player"
var my_room_id: String = ""
var is_host: bool = false

# 房间成员列表 [{id, name, ready}]
var room_members: Array = []

# 信号
signal on_connected()
signal on_disconnected()
signal on_error(msg)

signal on_room_list(rooms)
signal on_room_created(room_id)
signal on_room_joined(room_id, members)
signal on_room_join_failed(code)
signal on_player_joined(player_id, player_name)
signal on_player_left(player_id, player_name)
signal on_player_ready(player_id, ready)
signal on_host_changed(new_host_id)

signal on_game_start(level_name, host_id)
signal on_player_state(player_id, pos, pressure, hold_item, face, state)
signal on_game_event(player_id, event_name, data)
signal on_host_sync(data)
signal on_chat(player_id, player_name, text)

# 状态同步定时器（每 0.1s 发送一次玩家状态）
var _sync_timer: float = 0.0
const SYNC_INTERVAL: float = 0.1
var _sync_enabled: bool = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS  # 暂停时也要继续轮询 WebSocket
	_ws = WebSocketClient.new()
	_ws.set_buffers(1048576, 1024, 1048576, 1024)  # 1MB 收发缓冲区
	var _r1 = _ws.connect("connection_established", self, "_on_ws_connected")
	var _r2 = _ws.connect("connection_closed", self, "_on_ws_closed")
	var _r3 = _ws.connect("connection_error", self, "_on_ws_error")
	var _r4 = _ws.connect("data_received", self, "_on_ws_data")
	set_process(false)

func _process(delta):
	if _ws:
		_ws.poll()
	if _sync_enabled and is_connected and my_room_id != "":
		_sync_timer += delta
		if _sync_timer >= SYNC_INTERVAL:
			_sync_timer = 0.0
			_send_player_state()

# ── 连接管理 ──────────────────────────────────────────────

func connect_to_server(player_name: String = "Player"):
	my_player_name = player_name
	if is_connected:
		return
	var err = _ws.connect_to_url(SERVER_URL)
	if err != OK:
		emit_signal("on_error", "无法连接服务器: " + str(err))
		return
	set_process(true)

func disconnect_from_server():
	if _ws and is_connected:
		leave_room()
		_ws.disconnect_from_host()
	is_connected = false
	set_process(false)

# ── 房间操作 ──────────────────────────────────────────────

func get_room_list():
	_send({ "type": "get_rooms" })

func create_room(level_name: String = "", max_players: int = 4):
	_send({
		"type": "create_room",
		"playerName": my_player_name,
		"levelName": level_name,
		"maxPlayers": max_players,
	})

func join_room(room_id: String):
	_send({
		"type": "join_room",
		"roomId": room_id,
		"playerName": my_player_name,
	})

func leave_room():
	if my_room_id == "":
		return
	_send({ "type": "leave_room" })
	my_room_id = ""
	is_host = false
	room_members.clear()
	_sync_enabled = false

func set_ready(ready: bool):
	_send({ "type": "set_ready", "ready": ready })

func start_game(level_name: String = ""):
	if not is_host:
		return
	_send({ "type": "start_game", "levelName": level_name })

# ── 游戏中同步 ────────────────────────────────────────────

func enable_state_sync(enabled: bool):
	_sync_enabled = enabled
	_sync_timer = 0.0

# 发送游戏事件（订单完成、天数结束等）
func send_game_event(event_name: String, data = null):
	_send({
		"type": "game_event",
		"event": event_name,
		"data": data,
	})

# 主机发送权威状态（金钱、订单列表、天数等）
func send_host_sync(data: Dictionary):
	if not is_host:
		return
	_send({ "type": "host_sync", "data": data })

func send_chat(text: String):
	_send({ "type": "chat", "text": text })

# ── 内部：发送玩家状态 ────────────────────────────────────

func _send_player_state():
	var player = GameLogic.player_1P
	if not is_instance_valid(player):
		return
	_send({
		"type": "player_state",
		"pos": { "x": player.position.x, "y": player.position.y },
		"pressure": player.cur_Pressure,
		"holdItem": _get_hold_item_name(player),
		"face": player.cur_face if player.get("cur_face") != null else 0,
		"state": int(player.Con.state) if player.get("Con") != null else 0,
	})

func _get_hold_item_name(player) -> String:
	if not player.get("Con"):
		return ""
	if not player.Con.IsHold:
		return ""
	var obj = player.Con.HoldObj
	if is_instance_valid(obj) and obj.get("TypeStr"):
		return obj.TypeStr
	return ""

# ── WebSocket 回调 ────────────────────────────────────────

func _on_ws_connected(_proto):
	is_connected = true
	print("[OnlineNetwork] 已连接服务器")
	emit_signal("on_connected")

func _on_ws_closed(was_clean: bool):
	is_connected = false
	my_room_id = ""
	is_host = false
	room_members.clear()
	_sync_enabled = false
	print("[OnlineNetwork] 连接断开 (clean=", was_clean, ")")
	emit_signal("on_disconnected")

func _on_ws_error():
	is_connected = false
	print("[OnlineNetwork] 连接错误")
	emit_signal("on_error", "连接服务器失败")

func _on_ws_data():
	var raw = _ws.get_peer(1).get_packet().get_string_from_utf8()
	var msg = JSON.parse(raw)
	if msg.error != OK:
		return
	_handle_message(msg.result)

func _handle_message(msg: Dictionary):
	match msg.get("type", ""):

		"room_list":
			emit_signal("on_room_list", msg.get("rooms", []))

		"room_created":
			my_player_id = msg.get("playerId", 0)
			my_room_id = msg.get("roomId", "")
			is_host = true
			room_members = [{ "id": my_player_id, "name": my_player_name, "ready": false }]
			emit_signal("on_room_created", my_room_id)

		"room_joined":
			my_player_id = msg.get("playerId", 0)
			my_room_id = msg.get("roomId", "")
			is_host = false
			room_members = msg.get("members", [])
			emit_signal("on_room_joined", my_room_id, room_members)

		"error":
			emit_signal("on_room_join_failed", msg.get("code", "UNKNOWN"))

		"player_joined":
			var pid = msg.get("playerId", 0)
			var pname = msg.get("playerName", "")
			room_members.append({ "id": pid, "name": pname, "ready": false })
			emit_signal("on_player_joined", pid, pname)

		"player_left":
			var pid = msg.get("playerId", 0)
			for i in room_members.size():
				if room_members[i].id == pid:
					room_members.remove(i)
					break
			emit_signal("on_player_left", pid, msg.get("playerName", ""))

		"player_ready":
			var pid = msg.get("playerId", 0)
			for m in room_members:
				if m.id == pid:
					m.ready = msg.get("ready", false)
					break
			emit_signal("on_player_ready", pid, msg.get("ready", false))

		"host_changed":
			var new_host_id = msg.get("newHostId", 0)
			if new_host_id == my_player_id:
				is_host = true
			emit_signal("on_host_changed", new_host_id)

		"game_start":
			_sync_enabled = true
			emit_signal("on_game_start", msg.get("levelName", ""), msg.get("hostId", 0))

		"player_state":
			var pos_d = msg.get("pos", { "x": 0, "y": 0 })
			emit_signal("on_player_state",
				msg.get("playerId", 0),
				Vector2(pos_d.x, pos_d.y),
				msg.get("pressure", 0),
				msg.get("holdItem", ""),
				msg.get("face", 0),
				msg.get("state", 0)
			)

		"game_event":
			emit_signal("on_game_event",
				msg.get("playerId", 0),
				msg.get("event", ""),
				msg.get("data")
			)

		"host_sync":
			emit_signal("on_host_sync", msg.get("data", {}))

		"chat":
			emit_signal("on_chat",
				msg.get("playerId", 0),
				msg.get("playerName", ""),
				msg.get("text", "")
			)

# ── 工具 ─────────────────────────────────────────────────

func _send(data: Dictionary):
	if not is_connected:
		return
	var json = JSON.print(data)
	_ws.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_ws.get_peer(1).put_packet(json.to_utf8())

func get_member_name(player_id: int) -> String:
	for m in room_members:
		if m.id == player_id:
			return m.name
	return "Unknown"
