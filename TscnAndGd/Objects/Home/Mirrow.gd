extends Head_Object
var playerList: Array
var cur_pressed: bool
var cur_Used: bool = false
var _playerNode
var cur_ID: int = 0

onready var HSilder = $CanvasLayer / Control / Choose / SliderNode / HSlider

onready var InfoAni = $CanvasLayer / AniNode / AnimationPlayer
onready var SkillVBox = $CanvasLayer / Control / InfoControl / UnLockInfo / VBoxContainer
onready var AvatarInfoLabel = $CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / Title / Character
onready var Info_1 = get_node("InfoNode/INFO_1")
onready var Info_2 = get_node("InfoNode/INFO_2")
onready var Info_3 = get_node("InfoNode/INFO_3")

onready var C = $CanvasLayer / Control / Choose / TexNode / LogicNode / C

onready var TimerNode = get_node("Timer")
onready var UnLockAni = get_node("TexNode/LogicNode/C/LogicNode/UnlockAni")
onready var ButShow = get_node("Button/A")
onready var ShowAni = $TexNode / Sprite / Ani
onready var aniPlayer = $AniNode / Ani

var AvatarIDList: Array
var AvatarList: Array
var _cur_Avatar
var _PLAYERID: int
func _ready() -> void :
	set_process_input(false)
	call_deferred("_avatar_init")
	if GameLogic.DEMO_bool:
		$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / DEMOLabel.show()
	else:
		$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / DEMOLabel.hide()
func call_Mirrow_init():
	if GameLogic.Save.gameData.has("HomeDevList"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LOBBY_gameData.has("HomeDevList"):
				if SteamLogic.LOBBY_gameData.HomeDevList.has("镜子"):
					ShowAni.play("show_init")
		elif GameLogic.Save.gameData.HomeDevList.has("镜子"):
			ShowAni.play("show_init")
	var _con = GameLogic.connect("SYNC", self, "call_show")
func call_show():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if ShowAni.assigned_animation == "init":

		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has("镜子"):
				ShowAni.play("show")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_show_puppet")

func call_show_puppet():
	ShowAni.play("show")
func _avatar_init():
	call_Mirrow_init()
	var _PlayerListKeys = GameLogic.Config.PlayerConfig.keys()
	HSilder.tick_count = _PlayerListKeys.size()
	HSilder.max_value = _PlayerListKeys.size()
	for _id in _PlayerListKeys:

		var _TSCN = GameLogic.Config.PlayerConfig[str(_id)].TSCN
		var _Avatar = GameLogic.TSCNLoad.return_character(_TSCN).instance()
		_Avatar.name = _id
		_Avatar.CURPLAYER = _PLAYERID
		_Avatar.CURAVATAR = _id
		AvatarList.append(_Avatar)
		AvatarIDList.append(int(_id))
		C.add_child(_Avatar)

		_Avatar.hide()
	C.hide()

func call_Back_Logic():
	TimerNode.start()
	_playerNode.Con.cur_UI = null
	InfoAni.play("hide")
	set_process_input(false)

	GameLogic.Audio.But_SwitchOff.play(0)

func call_CanControl():
	GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool:
		GameLogic.player_2P.call_control(0)
	GameLogic.Can_ESC = true

func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:
			"B", "START":
				call_Back_Logic()
			"A":
				if _value == 1:

					_select_logic(_playerNode.cur_Player)
			"l":
				if not cur_pressed:
					cur_pressed = true
					_avatar_change("L")
			"r":
				if not cur_pressed:
					cur_pressed = true
					_avatar_change("R")
			"L":
				if not cur_pressed:
					cur_pressed = true
					_avatar_change("L")
			"R":
				if not cur_pressed:
					cur_pressed = true
					_avatar_change("R")
	elif _value < 1 and _value > - 1:
		cur_pressed = false
	if _type == 0:
		cur_pressed = false
func _Info_Logic():

	if not GameLogic.cur_Player_Unlock.has(int(cur_ID)):

		$CanvasLayer / AniNode / TypeAni.play("Lock")

	else:
		$CanvasLayer / AniNode / TypeAni.play("UnLock")


	if _playerNode.cur_Player == 2:
		$CanvasLayer / AniNode / TypeAni.play("Player2")

	var _INFO = GameLogic.Save.statisticsData["Character"][cur_ID]

	var _TITLELEVEL: int = 0
	var _LEVEL: int = 0
	if int(_INFO.EXP) > GameLogic.Staff.EXPMAX:
		_INFO.EXP = GameLogic.Staff.EXPMAX
	for _Num in GameLogic.Staff.TITLEARRAY:
		_LEVEL += 1
		if int(_INFO.EXP) < int(_Num):
			break
		_TITLELEVEL = _LEVEL


	var _TITLE: String
	var _MAXVALUE: int
	match _TITLELEVEL:
		0:
			_TITLE = GameLogic.CardTrans.get_message("信息-实习店员")
			_MAXVALUE = GameLogic.Staff.TITLEARRAY[_TITLELEVEL]
		1:
			_TITLE = GameLogic.CardTrans.get_message("信息-正式店员")
			_MAXVALUE = GameLogic.Staff.TITLEARRAY[_TITLELEVEL]
		2:
			_TITLE = GameLogic.CardTrans.get_message("信息-资深店员")
			_MAXVALUE = GameLogic.Staff.TITLEARRAY[_TITLELEVEL]
		3:
			_TITLE = GameLogic.CardTrans.get_message("信息-储备店长")
			_MAXVALUE = GameLogic.Staff.TITLEARRAY[_TITLELEVEL - 1]

	var _PLAYERINFO = GameLogic.Config.PlayerConfig[str(cur_ID)]

	var _SKILLLIST = _PLAYERINFO.Skills
	var _SKILL: Array
	for _i in _SKILLLIST.size():
		if _i <= _TITLELEVEL:
			_SKILL.append(_SKILLLIST[_i])

	var _Pressure = int(_PLAYERINFO.Pressure)

	if _SKILL.has("技能-灵巧"):
		_Pressure = int(float(_Pressure) * 0.8)

	if _SKILL.has("技能-抗压"):
		_Pressure = int(float(_Pressure) * 1.2)

	var _Speed = int(float(_PLAYERINFO.MoveSpeed) * 5 + 10)

	AvatarInfoLabel.call_Tr_TEXT(_PLAYERINFO.INFO_1)
	$CanvasLayer / Control / InfoControl / BaseInfo / PressureLabel.text = str(_Pressure)
	if _Pressure == 25:
		$CanvasLayer / Control / InfoControl / BaseInfo / PressureLabel / AnimationPlayer.play("init")
	elif _Pressure < 25:
		$CanvasLayer / Control / InfoControl / BaseInfo / PressureLabel / AnimationPlayer.play("red")
	elif _Pressure > 25:
		$CanvasLayer / Control / InfoControl / BaseInfo / PressureLabel / AnimationPlayer.play("green")
	$CanvasLayer / Control / InfoControl / BaseInfo / SpeedLabel.text = str(_Speed)
	if _Speed == 50:
		$CanvasLayer / Control / InfoControl / BaseInfo / SpeedLabel / AnimationPlayer.play("init")
	if _Speed < 50:
		$CanvasLayer / Control / InfoControl / BaseInfo / SpeedLabel / AnimationPlayer.play("red")
	elif _Speed > 50:
		$CanvasLayer / Control / InfoControl / BaseInfo / SpeedLabel / AnimationPlayer.play("green")
	var _MASSLABEL = str(int(float(_PLAYERINFO.Mass) * 10))
	if _MASSLABEL == "10":
		_MASSLABEL = "0"
	$CanvasLayer / Control / InfoControl / BaseInfo / MassLabel.text = _MASSLABEL

	$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / Title / EXPLabel / TextureProgress.max_value = _MAXVALUE
	$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / Title / EXPLabel / TextureProgress.value = _INFO.EXP

	$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / Title / TitleLabel.text = _TITLE
	$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / Title / EXPLabel.text = str(_INFO.EXP)
	$CanvasLayer / Control / Info / VBoxContainer / UseCountLabel.text = str(_INFO.UseCount)
	$CanvasLayer / Control / Info / VBoxContainer / MultplayLabel.text = str(_INFO.MultplayCount)
	$CanvasLayer / Control / Info / VBoxContainer / FeedCupsLabel.text = str(_INFO.FeedCups)
	$CanvasLayer / Control / Info / VBoxContainer / HomeMoneyCountLabel.text = str(int(_INFO.HomeMoneyCount))
	$CanvasLayer / Control / Info / VBoxContainer / CupCoinLabel.text = str(_INFO.CupCoinCount)
	$CanvasLayer / Control / InfoControl / BaseInfo / BaseInfo / Title / Label.call_Tr_TEXT(_PLAYERINFO.NAME)
	var _Num: int = 0
	for _NODE in SkillVBox.get_children():
		if _NODE.has_method("call_Lock"):
			_NODE.call_Lock(_Num)
			_Num += 1
	get_node("CanvasLayer/Control/InfoControl/BaseInfo/BaseInfo/0/Label").call_Tr_TEXT("")
	get_node("CanvasLayer/Control/InfoControl/BaseInfo/BaseInfo/1/Label").call_Tr_TEXT("")
	$CanvasLayer / Control / InfoControl / UnLockInfo / Skill / Label.call_Tr_TEXT("信息-储备店长解锁")
	var _BadAni = get_node("CanvasLayer/Control/InfoControl/BaseInfo/BaseInfo/1/BG/Control/NinePatchRect/Icon/AnimationPlayer")
	var _GoodAni = get_node("CanvasLayer/Control/InfoControl/BaseInfo/BaseInfo/0/BG/Control/NinePatchRect/Icon/AnimationPlayer")
	var _IconANI = $CanvasLayer / Control / InfoControl / UnLockInfo / Skill / Control / NinePatchRect / Icon / AnimationPlayer
	_BadAni.play("无")
	_GoodAni.play("无")
	_IconANI.play("无")
	if GameLogic.cur_Player_Unlock.has(int(cur_ID)):
		if GameLogic.Config.PlayerConfig.has(str(cur_ID)):
			var _SkillList = GameLogic.Config.PlayerConfig[str(cur_ID)].Skills

			for _i in _SkillList.size():
				if str(_SkillList[_i]) == "0":

					return
				if _TITLELEVEL < _i:

					return
				var _Skill = _SkillList[_i]
				if GameLogic.Config.SkillConfig.has(_Skill):
					if _i == 0:
						get_node("CanvasLayer/Control/InfoControl/BaseInfo/BaseInfo/0/Label").call_Tr_TEXT(_Skill)
						var _BadSKillLabel = get_node("CanvasLayer/Control/InfoControl/BaseInfo/BaseInfo/1/Label")


						match _Skill:
							"技能-鳄鱼":
								_BadSKillLabel.call_Tr_TEXT("技能-囤积癖")
								_BadAni.play("囤积癖")
								_GoodAni.play("威慑")
								_IconANI.play("无法下单")
							"技能-熊猫":
								_BadSKillLabel.call_Tr_TEXT("技能-完美主义")
								_BadAni.play("完美主义")
								_GoodAni.play("揽客")
								_IconANI.play("卖萌")
							"技能-强壮":
								_BadSKillLabel.call_Tr_TEXT("技能-笨重")
								_BadAni.play("笨重")
								_GoodAni.play("强壮")
								_IconANI.play("投掷")
							"技能-敏捷":
								_BadSKillLabel.call_Tr_TEXT("技能-打滑")
								_BadAni.play("打滑")
								_GoodAni.play("敏捷")
								_IconANI.play("冲刺")
							"技能-灵巧":
								_BadSKillLabel.call_Tr_TEXT("技能-脆弱")
								_BadAni.play("脆弱")
								_GoodAni.play("灵巧")
								_IconANI.play("饮用")
							"技能-河狸基础":
								_BadSKillLabel.call_Tr_TEXT("技能-湿润")
								_BadAni.play("湿润")
								_GoodAni.play("点单")
								_IconANI.play("搓手手")
							"技能-幽灵基础":
								_BadSKillLabel.call_Tr_TEXT("技能-无尺码")
								_BadAni.play("无尺码")
								_GoodAni.play("虚体")
								_IconANI.play("穿墙")
							"技能-史莱姆基础":
								_BadSKillLabel.call_Tr_TEXT("技能-肌无力")
								_BadAni.play("肌无力")
								_GoodAni.play("拖地")
								_IconANI.play("吞食")
					elif _i == 3:
						$CanvasLayer / Control / InfoControl / UnLockInfo / Skill / Label.call_Tr_TEXT(_Skill)
					else:
						SkillVBox.get_node(str(_i)).call_Label_set(_Skill)
				else:
					pass

func _show():
	for _BUT in $CanvasLayer / Control / Head / ScrollContainer / HBoxContainer.get_children():
		if not int(_BUT.name) in GameLogic.cur_Player_Unlock:
			_BUT.get_node("NinePatchRect/Control/Icon").set_modulate(Color(0, 0, 0, 1))
		else:
			_BUT.get_node("NinePatchRect/Control/Icon").set_modulate(Color(1, 1, 1, 1))
	for _Avatar in AvatarList:
		_Avatar.hide()
	var _Num = AvatarIDList.find(int(cur_ID))

	HSilder.value = _Num + 1
	_cur_Avatar = AvatarList[_Num]
	_cur_Avatar.CURPLAYER = _PLAYERID
	_cur_Avatar.call_EquipInit()
	_cur_Avatar.show()
	C.show()

	_Info_Logic()
	if SteamLogic.IsMultiplay:
		if SteamLogic.SLOT == SteamLogic.STEAM_ID:
			$CanvasLayer / Control / Head / HeadTypeAni.play("1")
		if SteamLogic.SLOT_2 == SteamLogic.STEAM_ID:
			$CanvasLayer / Control / Head / HeadTypeAni.play("2")
		if SteamLogic.SLOT_3 == SteamLogic.STEAM_ID:
			$CanvasLayer / Control / Head / HeadTypeAni.play("3")
		if SteamLogic.SLOT_4 == SteamLogic.STEAM_ID:
			$CanvasLayer / Control / Head / HeadTypeAni.play("4")
	elif _playerNode.cur_Player == 2:
		$CanvasLayer / Control / Head / HeadTypeAni.play("2")
	else:
		$CanvasLayer / Control / Head / HeadTypeAni.play("1")
	InfoAni.play("show")
	GameLogic.Can_ESC = false

	var _NODE = $CanvasLayer / Control / Head / ScrollContainer / HBoxContainer
	var _NODENAME = str(HSilder.value - 1)
	var _HEADBUT = _NODE.get_node(_NODENAME)
	_HEADBUT.pressed = true
	yield(get_tree().create_timer(0.3), "timeout")
	_HEADBUT.grab_focus()


func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		0, "A":
			if _value == 0:
				return
			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return

			if not cur_Used:

				_PLAYERID = _Player.cur_Player
				if _PLAYERID == SteamLogic.STEAM_ID:
					_PLAYERID = 1
				match _PLAYERID:
					1, SteamLogic.STEAM_ID:
						if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
							GameLogic.Con.connect("P1_Control", self, "_control_logic")
						get_node("InfoNode/SliderNode/L/LEFT").show_player(1)
						get_node("InfoNode/SliderNode/R/RIGHT").show_player(1)
						$CanvasLayer / AniNode / PlayerSet.play("1")

					2:
						if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
							GameLogic.Con.connect("P2_Control", self, "_control_logic")
						get_node("InfoNode/SliderNode/L/LEFT").show_player(2)
						get_node("InfoNode/SliderNode/R/RIGHT").show_player(2)
						$CanvasLayer / AniNode / PlayerSet.play("2")

				_playerNode = _Player

				GameLogic.player_1P.call_control(1)
				if GameLogic.Player2_bool:
					GameLogic.player_2P.call_control(1)
				cur_Used = true
				cur_ID = int(_Player.cur_ID)
				_Player.Con.cur_UI = self

				for _AVATAR in C.get_children():
					var _id = _AVATAR.name
					if _id != "LogicNode":
						if not int(_id) in GameLogic.cur_Player_Unlock:
							_AVATAR.set_modulate(Color(0, 0, 0, 1))
						else:
							_AVATAR.set_modulate(Color(1, 1, 1, 1))
				_show()
				GameLogic.Audio.But_SwitchOn.play(0)
				return true

func _avatar_change(_LR):
	match _LR:
		"L":
			HSilder.value -= 1

		"R":
			HSilder.value += 1
	var _select = HSilder.value - 1

	_cur_Avatar.hide()
	_cur_Avatar = AvatarList[_select]
	cur_ID = int(AvatarIDList[_select])

	_Info_Logic()
	_cur_Avatar.CURPLAYER = _PLAYERID
	_cur_Avatar.call_EquipInit()
	_cur_Avatar.show()
	GameLogic.Audio.But_EasyClick.play(0)
	var _NODE = $CanvasLayer / Control / Head / ScrollContainer / HBoxContainer
	var _NODENAME = str(HSilder.value - 1)
	var _HEADBUT = _NODE.get_node(_NODENAME)
	_HEADBUT.pressed = true
	_HEADBUT.grab_focus()
	var _TEXTCHECK = get_node("CanvasLayer/Control/InfoControl/UnLockInfo/VBoxContainer/0/Label").text


func _player_avatar_change():

	if SteamLogic.IsMultiplay:

		var _INFO = GameLogic.Save.gameData["EquipDic"][1][cur_ID]

		SteamLogic.call_everybody_node_sync(_playerNode, "call_change_avatar", [cur_ID, _INFO])
		if _playerNode.cur_Player == SteamLogic.STEAM_ID:
			SteamLogic.call_puppet_set_sync(_playerNode.Stat, "Skills", _playerNode.Stat.Skills)
	else:
		_playerNode.call_change_avatar(cur_ID)
func _wrong_audio():
	var _Audio = GameLogic.Audio.return_Effect("错误1")
	_Audio.play(0)
func _select_logic(_1p2p):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		if GameLogic.cur_level != "" and GameLogic.cur_Day >= 1:
			$CanvasLayer / Control / Label / AnimationPlayer.play("wrong")
			_wrong_audio()
			return
	var _select = HSilder.value - 1

	if not GameLogic.cur_Player_Unlock.has(int(_select)):
		var Audio_Wrong = GameLogic.Audio.return_Effect("错误1")
		Audio_Wrong.play(0)
		return

	TimerNode.start()
	_playerNode.Con.cur_UI = null

	if int(_playerNode.cur_ID) != int(_select):

		_player_avatar_change()
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			pass
		else:
			match _1p2p:
				1, SteamLogic.STEAM_ID:
					GameLogic.player_1P_ID = _select
				2:
					GameLogic.player_2P_ID = _select

	C.hide()
	SteamLogic.LevelDic.Character = cur_ID
	GameLogic.JoinPlayer = cur_ID
	InfoAni.play("hide")
	set_process_input(false)

	GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool:
		GameLogic.player_2P.call_control(0)
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		pass
	else:
		GameLogic.Save.gameData["player_1P_ID"] = GameLogic.player_1P_ID
		GameLogic.Save.gameData["player_2P_ID"] = GameLogic.player_2P_ID
		GameLogic.Save.call_save()
	GameLogic.Audio.But_SwitchOff.play(0)

func _on_Timer_timeout() -> void :
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	cur_Used = false

func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")

func _on_ApplyBut_pressed():
	_select_logic(_playerNode.cur_Player)

func _on_BackBut_pressed():
	call_Back_Logic()
