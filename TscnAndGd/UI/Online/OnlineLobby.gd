extends Control
# OnlineLobby.gd
# 联机大厅 UI 逻辑
# 对应场景: OnlineLobby.tscn
#
# 节点结构（需在编辑器中搭建）:
# OnlineLobby (Control)
# ├── ConnectPanel (VBoxContainer)
# │   ├── NameInput (LineEdit)       玩家名
# │   ├── ConnectBtn (Button)        连接服务器
# │   └── StatusLabel (Label)
# ├── LobbyPanel (VBoxContainer)
# │   ├── RoomList (ItemList)        房间列表
# │   ├── RefreshBtn (Button)
# │   ├── CreateRoomBtn (Button)
# │   └── JoinRoomBtn (Button)
# └── RoomPanel (VBoxContainer)
#     ├── MemberList (ItemList)      房间成员
#     ├── ReadyBtn (Button)
#     ├── StartBtn (Button)          仅房主可见
#     └── LeaveBtn (Button)

onready var ConnectPanel = $ConnectPanel
onready var LobbyPanel = $LobbyPanel
onready var RoomPanel = $RoomPanel
onready var NameInput = $ConnectPanel/NameInput
onready var StatusLabel = $ConnectPanel/StatusLabel
onready var RoomList = $LobbyPanel/RoomList
onready var MemberList = $RoomPanel/MemberList
onready var StartBtn = null
onready var ReadyBtn = null

var _room_data: Array = []
var _is_ready: bool = false

func _ready():
	if has_node("RoomPanel/StartBtn"):
		StartBtn = $RoomPanel/StartBtn
	else:
		StartBtn = Button.new()
		StartBtn.name = "StartBtn"
		StartBtn.text = "开始游戏"
		StartBtn.disabled = true
		StartBtn.visible = false
		$RoomPanel.add_child(StartBtn)
		StartBtn.connect("pressed", self, "_on_StartBtn_pressed")

	if has_node("RoomPanel/ReadyBtn"):
		ReadyBtn = $RoomPanel/ReadyBtn
	else:
		ReadyBtn = Button.new()
		ReadyBtn.name = "ReadyBtn"
		ReadyBtn.text = "准备"
		ReadyBtn.visible = false
		$RoomPanel.add_child(ReadyBtn)
		ReadyBtn.connect("pressed", self, "_on_ReadyBtn_pressed")
	_show_panel("connect")
	# 若已连接服务器（如从房间返回），直接跳到大厅面板
	if OnlineNetwork.is_connected:
		_show_panel("lobby")
		OnlineNetwork.get_room_list()

	OnlineNetwork.connect("on_connected", self, "_on_connected")
	OnlineNetwork.connect("on_disconnected", self, "_on_disconnected")
	OnlineNetwork.connect("on_error", self, "_on_net_error")
	OnlineNetwork.connect("on_room_list", self, "_on_room_list")
	OnlineNetwork.connect("on_room_created", self, "_on_room_created")
	OnlineNetwork.connect("on_room_joined", self, "_on_room_joined")
	OnlineNetwork.connect("on_room_join_failed", self, "_on_join_failed")
	OnlineNetwork.connect("on_player_joined", self, "_on_player_joined")
	OnlineNetwork.connect("on_player_left", self, "_on_player_left")
	OnlineNetwork.connect("on_player_ready", self, "_on_player_ready")
	OnlineNetwork.connect("on_host_changed", self, "_on_host_changed")
	OnlineNetwork.connect("on_game_start", self, "_on_game_start")

func _exit_tree():
	if OnlineNetwork.is_connected("on_connected", self, "_on_connected"):
		OnlineNetwork.disconnect("on_connected", self, "_on_connected")
	if OnlineNetwork.is_connected("on_disconnected", self, "_on_disconnected"):
		OnlineNetwork.disconnect("on_disconnected", self, "_on_disconnected")
	if OnlineNetwork.is_connected("on_error", self, "_on_net_error"):
		OnlineNetwork.disconnect("on_error", self, "_on_net_error")
	if OnlineNetwork.is_connected("on_room_list", self, "_on_room_list"):
		OnlineNetwork.disconnect("on_room_list", self, "_on_room_list")
	if OnlineNetwork.is_connected("on_room_created", self, "_on_room_created"):
		OnlineNetwork.disconnect("on_room_created", self, "_on_room_created")
	if OnlineNetwork.is_connected("on_room_joined", self, "_on_room_joined"):
		OnlineNetwork.disconnect("on_room_joined", self, "_on_room_joined")
	if OnlineNetwork.is_connected("on_room_join_failed", self, "_on_join_failed"):
		OnlineNetwork.disconnect("on_room_join_failed", self, "_on_join_failed")
	if OnlineNetwork.is_connected("on_player_joined", self, "_on_player_joined"):
		OnlineNetwork.disconnect("on_player_joined", self, "_on_player_joined")
	if OnlineNetwork.is_connected("on_player_left", self, "_on_player_left"):
		OnlineNetwork.disconnect("on_player_left", self, "_on_player_left")
	if OnlineNetwork.is_connected("on_player_ready", self, "_on_player_ready"):
		OnlineNetwork.disconnect("on_player_ready", self, "_on_player_ready")
	if OnlineNetwork.is_connected("on_host_changed", self, "_on_host_changed"):
		OnlineNetwork.disconnect("on_host_changed", self, "_on_host_changed")
	if OnlineNetwork.is_connected("on_game_start", self, "_on_game_start"):
		OnlineNetwork.disconnect("on_game_start", self, "_on_game_start")

func _show_panel(which: String):
	ConnectPanel.visible = (which == "connect")
	LobbyPanel.visible = (which == "lobby")
	RoomPanel.visible = (which == "room")

# ── 按钮回调 ──────────────────────────────────────────────

func _on_ConnectBtn_pressed():
	var name_str = NameInput.text.strip_edges()
	if name_str == "":
		name_str = "玩家" + str(randi() % 1000)
	StatusLabel.text = "连接中..."
	OnlineNetwork.connect_to_server(name_str)

func _on_RefreshBtn_pressed():
	OnlineNetwork.get_room_list()

func _on_CreateRoomBtn_pressed():
	OnlineNetwork.create_room("", 4)

func _on_JoinRoomBtn_pressed():
	var idx = RoomList.get_selected_items()
	if idx.size() == 0:
		return
	var room_id = _room_data[idx[0]].id
	OnlineNetwork.join_room(room_id)

func _on_ReadyBtn_pressed():
	_is_ready = !_is_ready
	OnlineNetwork.set_ready(_is_ready)
	if ReadyBtn: ReadyBtn.text = "取消准备" if _is_ready else "准备"

func _on_StartBtn_pressed():
	OnlineNetwork.start_game(GameLogic.cur_level)

func _on_LeaveBtn_pressed():
	OnlineNetwork.leave_room()
	_show_panel("lobby")
	OnlineNetwork.get_room_list()

func _on_BackBtn_pressed():
	OnlineNetwork.disconnect_from_server()
	# 返回主菜单
	var _err = get_tree().change_scene("res://TscnAndGd/UI/Main/Start.tscn")

# ── 网络回调 ──────────────────────────────────────────────

func _on_connected():
	StatusLabel.text = "已连接"
	_show_panel("lobby")
	OnlineNetwork.get_room_list()

func _on_disconnected():
	_show_panel("connect")
	StatusLabel.text = "已断开"

func _on_net_error(msg: String):
	StatusLabel.text = "错误: " + msg

func _on_room_list(rooms: Array):
	_room_data = rooms
	RoomList.clear()
	for r in rooms:
		RoomList.add_item("%s  [%d/%d]  %s" % [r.hostName, r.playerCount, r.maxPlayers, r.levelName])

func _on_room_created(_room_id: String):
	_show_panel("room")
	_refresh_member_list()
	if StartBtn:
		StartBtn.visible = true
		StartBtn.disabled = true
	if ReadyBtn: ReadyBtn.visible = false

func _on_room_joined(_room_id: String, _members: Array):
	_show_panel("room")
	_refresh_member_list()
	if StartBtn: StartBtn.visible = false
	if ReadyBtn: ReadyBtn.visible = true

func _on_join_failed(code: String):
	var msg_map = {
		"ROOM_NOT_FOUND": "房间不存在",
		"GAME_ALREADY_STARTED": "游戏已开始",
		"ROOM_FULL": "房间已满",
	}
	StatusLabel.text = msg_map.get(code, "加入失败: " + code)

func _on_player_joined(_player_id: int, _player_name: String):
	_refresh_member_list()

func _on_player_left(_player_id: int, _player_name: String):
	_refresh_member_list()

func _on_player_ready(_player_id: int, _ready: bool):
	_refresh_member_list()
	_update_start_btn()

func _on_host_changed(_new_host_id: int):
	if StartBtn: StartBtn.visible = OnlineNetwork.is_host
	if ReadyBtn: ReadyBtn.visible = !OnlineNetwork.is_host
	_refresh_member_list()

func _on_game_start(_level_name: String, _host_id: int):
	# 场景加载由 OnlineGameManager._on_game_start 统一处理
	# 关闭大厅 UI 即可
	queue_free()

func _update_start_btn():
	if not StartBtn:
		return
	var all_ready = true
	for m in OnlineNetwork.room_members:
		if not m.get("ready", false):
			all_ready = false
			break
	StartBtn.disabled = not all_ready

func _refresh_member_list():
	MemberList.clear()
	for m in OnlineNetwork.room_members:
		var ready_str = " [准备]" if m.get("ready", false) else ""
		var host_str = " [房主]" if m.id == _get_host_id() else ""
		MemberList.add_item(m.name + host_str + ready_str)

func _get_host_id() -> int:
	# 房主是第一个成员（服务器保证）
	if OnlineNetwork.room_members.size() > 0:
		return OnlineNetwork.room_members[0].id
	return -1
