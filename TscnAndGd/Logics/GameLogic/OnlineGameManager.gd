extends Node
# OnlineGameManager.gd
# 游戏中的联机协调器
# 挂载到 GameLogic 节点下（或作为 Autoload）
#
# 职责：
# - 监听 OnlineNetwork 事件，驱动游戏逻辑
# - 主机：定期同步权威状态（金钱、订单、天数）
# - 客机：接收主机状态并更新本地 GameLogic
# - 管理远程玩家节点的创建/销毁

var _remote_players: Dictionary = {}  # player_id -> RemotePlayer node
var _host_sync_timer: float = 0.0
const HOST_SYNC_INTERVAL: float = 1.0  # 每秒同步一次权威状态

# 远程玩家节点的父节点路径（关卡场景中的 Players 节点）
const PLAYERS_NODE_PATH = "Level/YSort/Players"

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS  # 暂停时也要处理网络事件
	var _c1 = OnlineNetwork.connect("on_game_start", self, "_on_game_start")
	var _c2 = OnlineNetwork.connect("on_player_joined", self, "_on_player_joined")
	var _c3 = OnlineNetwork.connect("on_player_left", self, "_on_player_left")
	var _c4 = OnlineNetwork.connect("on_game_event", self, "_on_game_event")
	var _c5 = OnlineNetwork.connect("on_host_sync", self, "_on_host_sync")
	var _c6 = OnlineNetwork.connect("on_disconnected", self, "_on_disconnected")
	set_process(false)

func _process(delta):
	if not OnlineNetwork.is_connected or OnlineNetwork.my_room_id == "":
		return
	# 主机定期广播权威状态
	if OnlineNetwork.is_host:
		_host_sync_timer += delta
		if _host_sync_timer >= HOST_SYNC_INTERVAL:
			_host_sync_timer = 0.0
			_broadcast_host_state()

func start_online_session():
	set_process(true)
	OnlineNetwork.enable_state_sync(true)

func stop_online_session():
	set_process(false)
	OnlineNetwork.enable_state_sync(false)
	_clear_remote_players()

# ── 主机广播权威状态 ──────────────────────────────────────

func _broadcast_host_state():
	OnlineNetwork.send_host_sync({
		"money": GameLogic.cur_money,
		"day": GameLogic.cur_Day,
		"pressure_p1": GameLogic.P1_Pressure,
		"combo": GameLogic.cur_Combo,
		"sell_num": GameLogic.cur_SellNum,
		"perfect": GameLogic.cur_Perfect,
		"good": GameLogic.cur_Good,
		"bad": GameLogic.cur_Bad,
	})

# ── 游戏事件发送（供其他脚本调用）────────────────────────

func notify_order_complete(order_id: int, quality: String):
	OnlineNetwork.send_game_event("order_complete", {
		"orderId": order_id,
		"quality": quality,
	})

func notify_day_end():
	OnlineNetwork.send_game_event("day_end", {
		"day": GameLogic.cur_Day,
		"money": GameLogic.cur_money,
	})

func notify_game_over(complete: bool):
	OnlineNetwork.send_game_event("game_over", {
		"complete": complete,
	})

# ── 网络回调 ──────────────────────────────────────────────

func _on_game_start(level_name: String, host_id: int):
	# 用 WebSocket 房间数据填充 SteamLogic，让 GameLogic/NewLevel 的联机逻辑生效
	SteamLogic.IsMultiplay = true
	SteamLogic.LOBBY_IsMaster = OnlineNetwork.is_host
	SteamLogic.STEAM_ID = OnlineNetwork.my_player_id
	SteamLogic.MasterID = host_id

	# 填充 LOBBY_MEMBERS（NewLevel._PlayerCreate 依赖此列表）
	SteamLogic.LOBBY_MEMBERS.clear()
	for m in OnlineNetwork.room_members:
		SteamLogic.LOBBY_MEMBERS.append({
			"steam_id": m.id,
			"steam_name": m.get("name", "Player"),
			"Check": false,
			"Init": false,
		})

	# 填充 SLOT（NewLevel 用 SLOT 判断本地玩家位置）
	SteamLogic.SLOT = OnlineNetwork.my_player_id
	var others = []
	for m in OnlineNetwork.room_members:
		if m.id != OnlineNetwork.my_player_id:
			others.append(m.id)
	SteamLogic.SLOT_2 = others[0] if others.size() > 0 else 0
	SteamLogic.SLOT_3 = others[1] if others.size() > 1 else 0
	SteamLogic.SLOT_4 = others[2] if others.size() > 2 else 0

	SteamLogic.PlayerNum = OnlineNetwork.room_members.size()
	start_online_session()

	if OnlineNetwork.is_host:
		# 主机：把存档数据广播给所有客机，使用 base64 保留 Godot 类型
		var _sync_data = {
			"LOBBY_gameData": GameLogic.Save.gameData,
			"LOBBY_statisticsData": GameLogic.Save.statisticsData,
			"LOBBY_levelData": GameLogic.Save.levelData,
			"cur_levelInfo": GameLogic.cur_levelInfo,
			"SPECIALLEVEL_Int": GameLogic.SPECIALLEVEL_Int,
			"SLOT": SteamLogic.SLOT,
			"SLOT_2": SteamLogic.SLOT_2,
			"SLOT_3": SteamLogic.SLOT_3,
			"SLOT_4": SteamLogic.SLOT_4,
		}
		var _bytes = var2bytes(_sync_data)
		var _b64 = Marshalls.raw_to_base64(_bytes)
		OnlineNetwork.send_game_event("lobby_data_sync", {"b64": _b64})
		# 主机直接加载 Home 场景
		GameLogic.call_HomeLoad()
	# 客机等待 lobby_data_sync 事件后再加载（见 _on_game_event）

func _on_player_joined(player_id: int, player_name: String):
	_spawn_remote_player(player_id, player_name)

func _on_player_left(player_id: int, _player_name: String):
	if _remote_players.has(player_id):
		var node = _remote_players[player_id]
		if is_instance_valid(node):
			node.queue_free()
		_remote_players.erase(player_id)

func _on_game_event(player_id: int, event_name: String, data):
	match event_name:
		# SteamLogic P2P 消息中继：base64 解码后交给 _read_Logic 处理
		"p2p_relay":
			if data and data.has("b64"):
				var _bytes = Marshalls.base64_to_raw(data.b64)
				var payload = bytes2var(_bytes, true)
				if payload is Dictionary:
					if not payload.has("from"):
						payload["from"] = player_id
					var _msg_type = payload.get("message", "")
					if _msg_type != "Callv" and _msg_type != "Set":
						print("[WS P2P] 收到: ", _msg_type, " from=", payload.get("from", "?"))
					SteamLogic._read_Logic(payload)
				else:
					print("[WS P2P] 解码失败，非Dictionary")
			elif data and data.has("payload"):
				var payload = data.payload
				if not payload.has("from"):
					payload["from"] = player_id
				print("[WS P2P] 收到(legacy): ", payload.get("message", ""))
				SteamLogic._read_Logic(payload)
			return

		# 主机广播的存档数据，客机收到后填充 SteamLogic 并加载场景
		"lobby_data_sync":
			if OnlineNetwork.is_host or not data:
				return
			print("[WS] 收到 lobby_data_sync")
			# base64 解码还原完整 Godot 类型
			if data.has("b64"):
				var _bytes = Marshalls.base64_to_raw(data.b64)
				data = bytes2var(_bytes, true)
				if not data is Dictionary:
					print("[WS] lobby_data_sync 解码失败")
					return
			print("[WS] lobby_data_sync 数据keys: ", data.keys())
			if data.has("LOBBY_gameData"):
				SteamLogic.LOBBY_gameData = data.LOBBY_gameData
			if data.has("LOBBY_statisticsData"):
				SteamLogic.LOBBY_statisticsData = data.LOBBY_statisticsData
			if data.has("LOBBY_levelData"):
				SteamLogic.LOBBY_levelData = data.LOBBY_levelData
			if data.has("cur_levelInfo"):
				GameLogic.cur_levelInfo = data.cur_levelInfo
				SteamLogic.LevelDic["cur_levelInfo"] = data.cur_levelInfo
			if data.has("SPECIALLEVEL_Int"):
				GameLogic.SPECIALLEVEL_Int = data.SPECIALLEVEL_Int
				SteamLogic.LevelDic["SPECIALLEVEL_Int"] = data.SPECIALLEVEL_Int
			# 更新 SLOT（主机分配的槽位）
			if data.has("SLOT_2"):
				SteamLogic.SLOT_2 = data.SLOT_2
			if data.has("SLOT_3"):
				SteamLogic.SLOT_3 = data.SLOT_3
			if data.has("SLOT_4"):
				SteamLogic.SLOT_4 = data.SLOT_4
			# 从主机数据加载游戏状态
			GameLogic.call_LobbyData_Load()
			# 客机加载 Home 场景
			GameLogic.call_HomeLoad()
			return
		"order_complete":
			# 显示其他玩家完成订单的提示
			if data and data.has("quality"):
				var pname = OnlineNetwork.get_member_name(player_id)
				GameLogic.call_Info(1, pname + " 完成订单: " + data.quality)

		"day_end":
			# 客机收到主机的天结束通知
			if not OnlineNetwork.is_host:
				pass  # 主机已通过 host_sync 同步了状态

		"game_over":
			if not OnlineNetwork.is_host:
				var complete = data.get("complete", false) if data else false
				GameLogic.call_gameover(complete)

func _on_host_sync(data: Dictionary):
	# 客机接收主机权威状态
	if OnlineNetwork.is_host:
		return
	if data.has("money"):
		GameLogic.cur_money = data.money
		GameLogic.GameUI.call_money_change(data.money)
	if data.has("day"):
		GameLogic.cur_Day = data.day
	if data.has("combo"):
		GameLogic.cur_Combo = data.combo
		GameLogic.GameUI.Combo.call_combo(data.combo)
	if data.has("sell_num"):
		GameLogic.cur_SellNum = data.sell_num
	if data.has("perfect"):
		GameLogic.cur_Perfect = data.perfect
	if data.has("good"):
		GameLogic.cur_Good = data.good
	if data.has("bad"):
		GameLogic.cur_Bad = data.bad

func _on_disconnected():
	SteamLogic.IsMultiplay = false
	SteamLogic.LOBBY_IsMaster = false
	stop_online_session()
	# 断线时返回主菜单
	if GameLogic.LoadingUI.IsLevel:
		GameLogic.call_Info(2, "联机断开")
		yield(get_tree().create_timer(2.0), "timeout")
		GameLogic.call_HomeLoad()

# ── 远程玩家节点管理 ──────────────────────────────────────

func _spawn_remote_player(player_id: int, player_name: String):
	if _remote_players.has(player_id):
		return
	# 尝试找到关卡中的 Players 节点
	var root = get_tree().get_root()
	if not root.has_node(PLAYERS_NODE_PATH):
		return
	var players_node = root.get_node(PLAYERS_NODE_PATH)

	# 创建简单的远程玩家节点
	var remote = Node2D.new()
	remote.set_script(load("res://TscnAndGd/Main/Player/RemotePlayer.gd"))
	remote.name = "Remote_" + str(player_id)
	players_node.add_child(remote)
	remote.init(player_id, player_name)
	_remote_players[player_id] = remote

func _clear_remote_players():
	for pid in _remote_players:
		var node = _remote_players[pid]
		if is_instance_valid(node):
			node.queue_free()
	_remote_players.clear()
