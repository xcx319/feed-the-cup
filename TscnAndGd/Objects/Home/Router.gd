extends StaticBody2D
var cur_Used: bool = false
var cur_pressed: bool

onready var ButShow = get_node("Button/A")

onready var OnlyInviteCheckBox = $CanvasLayer / Main / UIControl / CheckBox
onready var ConnectBut = $CanvasLayer / Main / Connect / Connect

onready var FriendVBox = $CanvasLayer / Main / FriendUI / InfoBG / Scroll / VBox
onready var LobbyVBox = $CanvasLayer / Main / LobbyUI / InfoBG / Scroll / VBox
onready var _FriendButTSCN = preload("res://TscnAndGd/UI/Steam/FriendButton.tscn")
onready var _LobbyPlayerButTSCN = preload("res://TscnAndGd/UI/Steam/LobbyPlayerButton.tscn")
onready var TypeAni = $CanvasLayer / TypeAni
onready var ANI = $CanvasLayer / Ani
onready var WaitTimer = $Timer
onready var aniPlayer = $AniNode / Ani

onready var CanJoinBox = $CanvasLayer / Main / UIControl / CheckBox

onready var _GROUP = preload("res://TscnAndGd/UI/Steam/ButtonGroup.tres")

var _OURGAMEARRAY: Array
var _OURDEMOARRAY: Array
var _INGAMEARRAY: Array
var _ONLINEARRAY: Array
var _OFFLINEARRAY: Array
var _UITYPE: int = 0
onready var PhoneNumLabel = $CanvasLayer / Main / TelePhoneUI / PhoneBG / LineEdit
var _PhoneNum: String
func _ready():
	if not SteamLogic.STEAM_BOOL:
		self.queue_free()
func call_used(switch: bool):
	cur_Used = switch

func call_free():
	for _Node in FriendVBox.get_children():
		FriendVBox.remove_child(_Node)
		_Node.queue_free()
	for _Node in LobbyVBox.get_children():
		LobbyVBox.remove_child(_Node)
		_Node.queue_free()
func call_UI_show():
	_UITYPE = 0
	call_free()
	var _IS_ONLINE: bool = Steam.loggedOn()

	if _IS_ONLINE:
		TypeAni.play("连接网络")
		call_Load()
		SteamLogic.call_InHome()
	else:
		TypeAni.play("未连接网络")

func _Refresh():
	call_free()
	call_Load()

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)

		0, "A":
			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return

			if not cur_Used:
				GameLogic.player_1P.call_control(1)
				if is_instance_valid(GameLogic.player_2P):
					GameLogic.player_2P.call_control(1)
				ANI.play("show")
				GameLogic.Can_ESC = false
				if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
					GameLogic.Con.connect("P1_Control", self, "_control_logic")
				if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
					GameLogic.Con.connect("P2_Control", self, "_control_logic")
				if not SteamLogic.is_connected("LobbyUpdate", self, "_Refresh"):
					var _CON = SteamLogic.connect("LobbyUpdate", self, "_Refresh")
				call_UI_show()

func call_closed():
	ANI.play("hide")
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	if SteamLogic.is_connected("LobbyUpdate", self, "_Refresh"):
		SteamLogic.disconnect("LobbyUpdate", self, "_Refresh")
func call_CanControl():
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(0)
	if is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(0)
	GameLogic.Can_ESC = true
func call_Load():
	call_Lobby_Set()
	call_Friend_Set()

func call_Lobby_Set():

	var _MEMBERS = Steam.getNumLobbyMembers(SteamLogic.LOBBY_ID)
	var _HasMaster: bool
	for i in _MEMBERS:
		var _test = Steam.getLobbyMemberByIndex(SteamLogic.LOBBY_ID, i)

		var _LOBBYPLAYERBUT = _LobbyPlayerButTSCN.instance()
		_LOBBYPLAYERBUT.name = str(LobbyVBox.get_child_count())
		LobbyVBox.add_child(_LOBBYPLAYERBUT)

		var _INFO: Dictionary = {"id": _test, "name": Steam.getFriendPersonaName(_test)}
		_LOBBYPLAYERBUT.call_init(_INFO)
		var _Group = _GROUP
		_LOBBYPLAYERBUT.set_button_group(_Group)
		if _LOBBYPLAYERBUT.IsMaster:
			_HasMaster = true
	$CanvasLayer / Main / LobbyUI / Number.text = str(_MEMBERS) + "/4"

	if _MEMBERS == 0 and not SteamLogic.IsMultiplay:
		call_NoLabby_Logic()

	$CanvasLayer / Main / LobbyUI / InfoBG / LOBBYBG / LobbyID.text = str(SteamLogic.LOBBY_ID)
func call_NoLabby_Logic():
	SteamLogic.call_create_Lobby()

func call_Friend_Set():
	_OURGAMEARRAY.clear()
	_OURDEMOARRAY.clear()
	_INGAMEARRAY.clear()
	_ONLINEARRAY.clear()
	_OFFLINEARRAY.clear()
	var _Array = Steam.getUserSteamFriends()


	for _Friend in _Array:
		var _ID = _Friend["id"]
		var _GAMEINFO: Dictionary = Steam.getFriendGamePlayed(_ID)
		if _GAMEINFO.has("id"):

			match _GAMEINFO["id"]:
				2336220:
					_OURGAMEARRAY.append(_Friend)
				2400400:
					_OURDEMOARRAY.append(_Friend)
				_:
					_INGAMEARRAY.append(_Friend)

		else:
			if _Friend["status"] == 0:
				_OFFLINEARRAY.append(_Friend)
			else:
				_ONLINEARRAY.append(_Friend)
	$CreateTimer.start(0)

func _InviteLogic(_id):

	SteamLogic.call_invite(_id)

func _on_Connect_pressed():

	WaitTimer.start(0)
	SteamLogic._initialize_Steam()
	ConnectBut.disabled = true
	var IS_ONLINE: bool = Steam.loggedOn()
	if not IS_ONLINE:
		return
	SteamLogic.STEAM_ID = Steam.getSteamID()
	var IS_OWNED: bool = Steam.isSubscribed()
	if not IS_OWNED:
		return
	if SteamLogic.LOBBY_ID != 0:
		return
	SteamLogic.call_create_Lobby()

func _on_Timer_timeout():
	var IS_ONLINE: bool = Steam.loggedOn()
	if not IS_ONLINE:
		TypeAni.play("未连接网络")
		return
	if SteamLogic.LOBBY_ID == 0:
		TypeAni.play("未连接网络")
		return
	else:
		TypeAni.play("连接网络")
		call_UI_show()
func _on_Invite_pressed():
	pass

func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:

			"R1":
				if cur_pressed == false:
					cur_pressed = true
					_on_JoinButton_pressed()

					$CanvasLayer / Main / LobbyUI / InfoBG / LOBBYBG / PhoneButton.on_pressed()
					$CanvasLayer / Main / LobbyUI / InfoBG / LOBBYBG / PhoneButton.pressed = true
					$CanvasLayer / Main / LobbyUI / InfoBG / LOBBYBG / PhoneButton._button_down()
			"L1":
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if cur_pressed == false:
					cur_pressed = true
					CanJoinBox.pressed = not CanJoinBox.pressed
					SteamLogic.CanJoin = CanJoinBox.pressed
					SteamLogic.call_SetRich()
					GameLogic.Audio.But_Click.play(0)
			"Y":
				_on_RefreshBut_pressed()
			"B", "START":

				call_closed()
				pass
			"X":
				if cur_pressed == false:
					cur_pressed = true
					if LobbyVBox.get_child_count() > 0:
						var _BUT = LobbyVBox.get_child(0)
						if is_instance_valid(_BUT):
							var _CURBUT = _BUT.group.get_pressed_button()
							if is_instance_valid(_CURBUT):

								if _CURBUT.has_method("_on_Join_pressed"):
									_CURBUT._on_Join_pressed()
								elif _CURBUT.has_method("_on_KickBut_pressed"):
									_CURBUT._on_KickBut_pressed()
								elif _CURBUT.has_method("_on_LeaveBut_pressed"):
									_CURBUT._on_LeaveBut_pressed()
					elif FriendVBox.get_child_count() > 0:
						var _BUT = FriendVBox.get_child(0)
						if is_instance_valid(_BUT):
							var _CURBUT = _BUT.group.get_pressed_button()
							if is_instance_valid(_CURBUT):

								if _CURBUT.has_method("_on_Join_pressed"):
									_CURBUT._on_Join_pressed()
								elif _CURBUT.has_method("_on_KickBut_pressed"):
									_CURBUT._on_KickBut_pressed()
								elif _CURBUT.has_method("_on_LeaveBut_pressed"):
									_CURBUT._on_LeaveBut_pressed()

			0, "A":
				match _UITYPE:
					0:
						if cur_pressed == false:
							cur_pressed = true
							if FriendVBox.get_child_count() > 0:
								var _BUT = FriendVBox.get_child(0)
								if not is_instance_valid(_BUT):
									return
								var _CURBUT = _BUT.group.get_pressed_button()

								if is_instance_valid(_CURBUT):

									if _CURBUT.has_method("_on_Invite_pressed"):
										_CURBUT._on_Invite_pressed()
					1:
						if cur_pressed == false:
							cur_pressed = true

							var _input = InputEventAction.new()
							_input.action = "ui_accept"
							_input.pressed = true
							Input.parse_input_event(_input)
							var _BUTLIST = $CanvasLayer / Main / TelePhoneUI / PhoneBG / GridContainer.get_children()
							_BUTLIST.append($CanvasLayer / Main / TelePhoneUI / PhoneBG / Call)
							_BUTLIST.append($CanvasLayer / Main / TelePhoneUI / PhoneBG / Back)
							for _BUT in _BUTLIST:
								if _BUT.has_focus():
									var _BUTNAME = _BUT.name
									var _METHODNAME = "_on_" + _BUTNAME + "_pressed"
									if self.has_method(_METHODNAME):
										self.call(_METHODNAME)
										_BUT.on_pressed()
										_BUT._button_down()
										return

			"l", "L":
				match _UITYPE:
					0:
						if LobbyVBox.has_node("0"):
							var _BUT = LobbyVBox.get_node("0")
							if not _BUT.has_focus():
								_BUT.grab_focus()
					1:
						if cur_pressed == false:
							cur_pressed = true
							var _input = InputEventAction.new()
							_input.action = "ui_left"
							_input.pressed = true
							Input.parse_input_event(_input)

			"r", "R":
				match _UITYPE:
					0:
						if FriendVBox.has_node("0"):
							var _BUT = FriendVBox.get_node("0")
							if not _BUT.has_focus():
								_BUT.grab_focus()
					1:
						if cur_pressed == false:
							cur_pressed = true
							var _input = InputEventAction.new()
							_input.action = "ui_right"
							_input.pressed = true
							Input.parse_input_event(_input)
			"u", "U":
				if cur_pressed == false:
					cur_pressed = true

					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					Input.parse_input_event(_input)

			"d", "D":
				if cur_pressed == false:
					cur_pressed = true

					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					Input.parse_input_event(_input)

	if _type == 0 or _value == 0:
		cur_pressed = false

func _on_BackBut_pressed():
	call_closed()
	pass

func _on_RefreshBut_pressed():
	_Refresh()
	_call_base62()

func _on_CreateTimer_timeout():
	if not cur_Used:
		return
	if is_instance_valid(self):

		if _OURGAMEARRAY.size():

			var _Friend = _OURGAMEARRAY.pop_front()
			var _FriendBUT = _FriendButTSCN.instance()
			_FriendBUT.name = str(FriendVBox.get_child_count())
			FriendVBox.add_child(_FriendBUT)
			var _INFO: Dictionary = Steam.getFriendGamePlayed(_Friend["id"])
			_FriendBUT.call_init(_Friend, _INFO)
			_FriendBUT.connect("_InviteID", self, "_InviteLogic")
			var _Group = _GROUP
			_FriendBUT.set_button_group(_Group)
			$CreateTimer.start(0)

			return
		if _OURDEMOARRAY.size():

			var _Friend = _OURDEMOARRAY.pop_front()
			var _FriendBUT = _FriendButTSCN.instance()
			_FriendBUT.name = str(FriendVBox.get_child_count())
			FriendVBox.add_child(_FriendBUT)
			var _INFO: Dictionary = Steam.getFriendGamePlayed(_Friend["id"])
			_FriendBUT.call_init(_Friend, _INFO)
			_FriendBUT.connect("_InviteID", self, "_InviteLogic")
			var _Group = _GROUP
			_FriendBUT.set_button_group(_Group)
			$CreateTimer.start(0)
			return

		if _ONLINEARRAY.size():
			var _Friend = _ONLINEARRAY.pop_front()
			var _FriendBUT = _FriendButTSCN.instance()
			_FriendBUT.name = str(FriendVBox.get_child_count())
			FriendVBox.add_child(_FriendBUT)
			var _INFO: Dictionary = Steam.getFriendGamePlayed(_Friend["id"])
			_FriendBUT.call_init(_Friend, _INFO)
			_FriendBUT.connect("_InviteID", self, "_InviteLogic")
			var _Group = _GROUP
			_FriendBUT.set_button_group(_Group)
			$CreateTimer.start(0)
			return
		if _INGAMEARRAY.size():

			var _Friend = _INGAMEARRAY.pop_front()
			var _FriendBUT = _FriendButTSCN.instance()
			_FriendBUT.name = str(FriendVBox.get_child_count())
			FriendVBox.add_child(_FriendBUT)
			var _INFO: Dictionary = Steam.getFriendGamePlayed(_Friend["id"])
			_FriendBUT.call_init(_Friend, _INFO)
			_FriendBUT.connect("_InviteID", self, "_InviteLogic")
			var _Group = _GROUP
			_FriendBUT.set_button_group(_Group)
			$CreateTimer.start(0)
			return
		if _OFFLINEARRAY.size():
			var _Friend = _OFFLINEARRAY.pop_front()
			var _FriendBUT = _FriendButTSCN.instance()
			_FriendBUT.name = str(FriendVBox.get_child_count())
			FriendVBox.add_child(_FriendBUT)
			var _INFO: Dictionary = Steam.getFriendGamePlayed(_Friend["id"])
			_FriendBUT.call_init(_Friend, _INFO)
			_FriendBUT.connect("_InviteID", self, "_InviteLogic")
			var _Group = _GROUP
			_FriendBUT.set_button_group(_Group)
			$CreateTimer.start(0)
			return


func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")

func _on_JoinButton_pressed():
	match _UITYPE:
		0:
			_UITYPE = 1
			$CanvasLayer / Main / FriendUI.hide()
			$CanvasLayer / Main / TelePhoneUI.show()
			get_node("CanvasLayer/Main/TelePhoneUI/PhoneBG/GridContainer/1").grab_focus()
		1:
			_UITYPE = 0
			$CanvasLayer / Main / FriendUI.show()
			$CanvasLayer / Main / TelePhoneUI.hide()

func _PhoneNum_Set(_NUM: int):

	if _PhoneNum.length() < 18:
		_PhoneNum = _PhoneNum + str(_NUM)
		PhoneNumLabel.text = _PhoneNum
		call_Call_Check()

func _on_1_pressed():
	_PhoneNum_Set(1)

func _on_2_pressed():
	_PhoneNum_Set(2)

func _on_3_pressed():
	_PhoneNum_Set(3)

func _on_4_pressed():
	_PhoneNum_Set(4)

func _on_5_pressed():
	_PhoneNum_Set(5)

func _on_6_pressed():
	_PhoneNum_Set(6)

func _on_7_pressed():
	_PhoneNum_Set(7)

func _on_8_pressed():
	_PhoneNum_Set(8)

func _on_9_pressed():
	_PhoneNum_Set(9)

func _on_0_pressed():
	_PhoneNum_Set(0)

func _on_C_pressed():
	_PhoneNum = ""
	PhoneNumLabel.text = _PhoneNum
	call_Call_Check()

func _on_D_pressed():
	var _Length = _PhoneNum.length()
	if _Length > 0:
		_PhoneNum = _PhoneNum.left(_Length - 1)

		PhoneNumLabel.text = _PhoneNum
	call_Call_Check()

func _on_LineEdit_text_changed(_new_text):

	_PhoneNum = PhoneNumLabel.text
	call_Call_Check()

func call_Call_Check():
	if _PhoneNum.length() == 18 and int(_PhoneNum) > 0:
		$CanvasLayer / Main / TelePhoneUI / PhoneBG / Call.disabled = false

	else:
		$CanvasLayer / Main / TelePhoneUI / PhoneBG / Call.disabled = true



func _on_Call_pressed():
	var _ID: int = int(_PhoneNum)

	SteamLogic._join_Lobby(_ID)
func _on_Back_pressed():
	_on_JoinButton_pressed()

var base36_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

func to_base62(number: int) -> String:
	var result = ""
	while number > 0:
		result = base36_chars[number % 36] + result
		number /= 36
	return result

func _call_base62():
	var long_room_number = SteamLogic.LOBBY_ID
	var short_room_number = to_base62(long_room_number)
	print(SteamLogic.LOBBY_ID, " Shortened Room Number: ", short_room_number)
	_call_rebase62(short_room_number)

func from_base62(base62_str: String) -> int:
	var number = 0
	for i in range(base62_str.length()):
		number = number * 36 + base36_chars.find(base62_str[i])
	return number

func _call_rebase62(_NUM):
	var short_room_number = _NUM
	var _long_room_number = from_base62(short_room_number)
