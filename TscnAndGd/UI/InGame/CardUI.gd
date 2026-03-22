extends Control

onready var CardBut = preload("res://TscnAndGd/Buttons/CardInfoButton.tscn")

onready var Ani = get_node("Ani/Ani")

onready var Card1_But = get_node("ScrollButHBox/1")
onready var Card2_But = get_node("ScrollButHBox/2")
onready var Card3_But = get_node("ScrollButHBox/3")

onready var But_1
onready var BackBut = get_node("ButControl/BackBut")
var cur_pressed: bool
var _Choose_bool: bool = true

func call_show():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		if GameLogic.cur_ReDrawCoin > 0:
			get_node("ButControl/ReBut").show()
		else:
			get_node("ButControl/ReBut").hide()
	else:
		call_init()
		_Choose_bool = true
		cur_pressed = false
		Ani.play("show")
		GameLogic.Can_ESC = false
		_Card_hide()
		call_CardShow()
func call_up():
	var _FocusOwner = get_focus_owner()
	if not _FocusOwner:
		return
	var _CurType = _FocusOwner.get_parent().get_parent().name
	if _CurType == "CardUI":
		if get_node("CurChoose/Challenge/Grid").get_child_count():
			get_node("CurChoose/Challenge/Grid").get_child(0).grab_focus()
		elif get_node("CurChoose/Reward/Grid").get_child_count():
			get_node("CurChoose/Reward/Grid").get_child(0).grab_focus()
	if _CurType == "Challenge":
		if get_node("CurChoose/Reward/Grid").get_child_count():
			get_node("CurChoose/Reward/Grid").get_child(0).grab_focus()
func call_down():
	var _FocusOwner = get_focus_owner()
	if not _FocusOwner:
		return
	var _CurType = _FocusOwner.get_parent().get_parent().name
	if _CurType == "Reward":
		if get_node("CurChoose/Challenge/Grid").get_child_count():
			get_node("CurChoose/Challenge/Grid").get_child(0).grab_focus()
		else:
			get_focus_owner().pressed = false
			get_node("CurChoose").call_ShowInfo_Hide()
			get_node("ScrollButHBox/1").grab_focus()
	if _CurType == "Challenge":
		get_focus_owner().pressed = false
		get_node("CurChoose").call_ShowInfo_Hide()
		get_node("ScrollButHBox/1").grab_focus()
func call_CardShow():
	Card1_But.call_show()
	Card2_But.call_show()
	Card3_But.call_show()
	_ShowFinish_Logic()
func _ShowFinish_Logic():
	if GameLogic.GameUI.CurTime >= GameLogic.cur_OpenTime:
		BackBut.hide()
	yield(get_tree().create_timer(1.1), "timeout")
	call_GrabFocus()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
		return

	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.connect("P2_Control", self, "_control_logic")
func call_GrabFocus():

	if not Card2_But.visible and Card1_But.visible:
		if not Card1_But.has_focus():
			Card1_But.grab_focus()
	elif Card2_But.focus_mode == Control.FOCUS_ALL:
		if not Card2_But.has_focus():
			Card2_But.grab_focus()
	_Choose_bool = false
func _control_logic(_but, _value, _type):

	if _value == 0:
		cur_pressed = false
	match _but:
		"X":
			if _value == 1 or _value == - 1:
				if _Choose_bool:
					return
				if not cur_pressed:

					cur_pressed = true
					if GameLogic.cur_ReDrawCoin > 0:
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							var _PLAYER: int = 0
							match SteamLogic.STEAM_ID:
								SteamLogic.SLOT_2:
									_PLAYER = 2
								SteamLogic.SLOT_3:
									_PLAYER = 3
								SteamLogic.SLOT_4:
									_PLAYER = 4
							call_NetChoose(_PLAYER)
							return
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "_on_Re_pressed")
					_on_Re_pressed()

		"A":
			if _value == 1 or _value == - 1:
				if _Choose_bool:
					return
				if not cur_pressed:

					cur_pressed = true
					if Card1_But.has_focus():
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							var _PLAYER: int = 0
							match SteamLogic.STEAM_ID:
								SteamLogic.SLOT_2:
									_PLAYER = 2
								SteamLogic.SLOT_3:
									_PLAYER = 3
								SteamLogic.SLOT_4:
									_PLAYER = 4
							Card1_But.call_NetChoose(_PLAYER)
							return

						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_select", [Card1_But.name])
						call_select(Card1_But.name)
					if Card2_But.has_focus():
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							var _PLAYER: int = 0
							match SteamLogic.STEAM_ID:
								SteamLogic.SLOT_2:
									_PLAYER = 2
								SteamLogic.SLOT_3:
									_PLAYER = 3
								SteamLogic.SLOT_4:
									_PLAYER = 4
							Card2_But.call_NetChoose(_PLAYER)
							return

						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_select", [Card2_But.name])
						call_select(Card2_But.name)
					if Card3_But.has_focus():
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							var _PLAYER: int = 0
							match SteamLogic.STEAM_ID:
								SteamLogic.SLOT_2:
									_PLAYER = 2
								SteamLogic.SLOT_3:
									_PLAYER = 3
								SteamLogic.SLOT_4:
									_PLAYER = 4
							Card3_But.call_NetChoose(_PLAYER)
							return

						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_select", [Card3_But.name])
						call_select(Card3_But.name)
		"B":
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
				if _value == 1 or _value == - 1:
					cur_pressed = true
					BackBut.call_down()
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "_on_Back_pressed")
					_on_Back_pressed()
		"U", "u":
			if _value == 1 or _value == - 1:
				if cur_pressed:
					return
				cur_pressed = true
				call_up()
		"D", "d":
			if _value == 1 or _value == - 1:
				if cur_pressed:
					return
				cur_pressed = true
				call_down()
		"L", "l":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			cur_pressed = true
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "_udlf_logic", ["ui_left"])
			_udlf_logic("ui_left")
		"R", "r":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			cur_pressed = true
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "_udlf_logic", ["ui_right"])
			_udlf_logic("ui_right")
	if _type == 0:
		cur_pressed = false
func _udlf_logic(_action: String):
	var _input = InputEventAction.new()
	_input.action = _action
	_input.pressed = true
	Input.parse_input_event(_input)
	GameLogic.Audio.But_EasyClick.play(0)

func call_puppet_init(_IDDic: Dictionary):
	GameLogic.Challenge_1 = _IDDic[0]
	GameLogic.Challenge_2 = _IDDic[1]
	GameLogic.Challenge_3 = _IDDic[2]
	_card_set()
	_Choose_bool = true
	cur_pressed = false
	Ani.play("show")
	_Card_hide()
	call_CardShow()
	$CurChoose.call_init()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_Master_Switch(true)
func call_init():

	if GameLogic.cur_DayType in ["升级1", "升级2", "升级3", "升级", "事件1", "事件2", "简化1", "简化2", "随机1", "随机2", "精英随机1", "精英随机2", "精英事件1", "精英事件2"]:
		get_node("ButControl/ReBut").hide()
	else:
		if GameLogic.cur_ReDrawCoin > 0:
			get_node("ButControl/ReBut").show()
			get_node("ButControl/ReBut/RandomCoin/Label").text = str(GameLogic.cur_ReDrawCoin)
	$CurChoose.call_init()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		GameLogic.Card.call_Event_init()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _IDDic: Dictionary
		_IDDic[0] = GameLogic.Challenge_1
		_IDDic[1] = GameLogic.Challenge_2
		_IDDic[2] = GameLogic.Challenge_3
		SteamLogic.call_everybody_node_sync(self, "call_puppet_init", [_IDDic])
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		_card_set()
func _card_set():

	Card1_But.TYPE = 1
	Card2_But.TYPE = 2
	Card3_But.TYPE = 3

func _Card_hide():
	Card1_But.release_focus()
	Card2_But.release_focus()
	Card3_But.release_focus()
	Card1_But.call_hide()
	Card2_But.call_hide()
	Card3_But.call_hide()
func _on_select_pressed() -> void :
	Ani.play("init")
	var _pressedBut = Card1_But.group.get_pressed_button()
	var _SelectCard
	call_select(_pressedBut.name)

func call_select(_ButName):
	if _Choose_bool:
		return
	_Choose_bool = true

	var _SelectChallenge
	var _SelectReward
	GameLogic.Audio.But_Apply.play(0)
	match _ButName:
		"1":

			_SelectReward = Card1_But.Reward_Str
			_SelectChallenge = Card1_But.Challenge_ID
			Card1_But.call_choose(true)
			yield(get_tree().create_timer(0.5), "timeout")
			Card2_But.call_choose(false)
			Card3_But.call_choose(false)

		"2":

			_SelectReward = Card2_But.Reward_Str
			_SelectChallenge = Card2_But.Challenge_ID
			Card2_But.call_choose(true)
			yield(get_tree().create_timer(0.5), "timeout")
			Card1_But.call_choose(false)
			Card3_But.call_choose(false)

		"3":

			_SelectReward = Card3_But.Reward_Str
			_SelectChallenge = Card3_But.Challenge_ID
			Card3_But.call_choose(true)
			yield(get_tree().create_timer(0.5), "timeout")
			Card1_But.call_choose(false)
			Card2_But.call_choose(false)





	GameLogic.cur_Event = _SelectChallenge
	if not GameLogic.CHEATINGBOOL:
		if not GameLogic.Save.statisticsData.EventList.has(_SelectChallenge):
			GameLogic.Save.statisticsData.EventList[_SelectChallenge] = [1, 0, 0]
		else:
			GameLogic.Save.statisticsData.EventList[_SelectChallenge][0] += 1

	GameLogic.Can_Card = false
	GameLogic.call_start_check()
	call_disconnect()

	Ani.play("select")

func call_select_end():
	Ani.play("init")
	if GameLogic.cur_Event in ["换饮品", "换小料"]:
		call_Menu_Init()
	else:
		if get_tree().is_paused():
			get_tree().set_pause(false)
		GameLogic.call_challenge(true)
		var LevelNode = get_tree().get_root().get_node("Level")
		if LevelNode.has_method("_LEVELSTAT_LOGIC"):
			LevelNode._LEVELSTAT_LOGIC(2)
func call_Menu_Init():
	var _TSCN = load("res://TscnAndGd/UI/InGame/MenuUI.tscn")
	var cur_UI = _TSCN.instance()
	get_parent().add_child(cur_UI)
	cur_UI.call_init()

	cur_UI.call_show()

func _on_Back_pressed() -> void :

	pass
func call_disconnect():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

func _on_Re_pressed() -> void :



	if _Choose_bool:
		return
	if GameLogic.cur_DayType in ["升级1", "升级2", "升级3", "升级", "事件1", "事件2", "简化1", "简化2", "随机1", "随机2", "精英随机1", "精英随机2", "精英事件1", "精英事件2"]:
		return
	if GameLogic.cur_ReDrawCoin > 0 or SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		_Choose_bool = true
		GameLogic.cur_ReDrawCoin -= 1
		if GameLogic.cur_ReDrawCoin < 0:
			GameLogic.cur_ReDrawCoin = 0

		get_node("ButControl/ReBut/RandomCoin/Label").text = str(GameLogic.cur_ReDrawCoin)
		GameLogic.call_ReDrawCoinChange()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Re_puppet", [GameLogic.cur_ReDrawCoin])

		Card1_But.call_choose(false)
		Card2_But.call_choose(false)
		Card3_But.call_choose(false)
		$Ani / BurnAudio.play(0)

		yield(get_tree().create_timer(2.4), "timeout")
		call_init()
		_Card_hide()
		yield(get_tree().create_timer(0.1), "timeout")
		call_CardShow()
	get_node("ButControl/ReBut").call_pressed()

func call_Re_puppet(_RECOIN):
	GameLogic.cur_ReDrawCoin = _RECOIN
	get_node("ButControl/ReBut/RandomCoin/Label").text = str(GameLogic.cur_ReDrawCoin)
	if GameLogic.cur_ReDrawCoin > 0:
		get_node("ButControl/ReBut").show()
	else:
		get_node("ButControl/ReBut").hide()
	Card1_But.call_choose(false)
	Card2_But.call_choose(false)
	Card3_But.call_choose(false)
	yield(get_tree().create_timer(2.4), "timeout")
	_Card_hide()
	yield(get_tree().create_timer(0.1), "timeout")
	call_CardShow()
func _on_1_pressed() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_everybody_node_sync(self, "call_select", ["1"])
	else:
		call_select("1")
func _on_2_pressed() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_everybody_node_sync(self, "call_select", ["2"])
	else:
		call_select("2")
func _on_3_pressed() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_everybody_node_sync(self, "call_select", ["3"])
	else:
		call_select("3")

onready var NetChooseTSCN = preload("res://TscnAndGd/Effects/NetChoose.tscn")

func call_NetChoose(_PLAYER: int):
	var _ChooseTSCN = NetChooseTSCN.instance()
	var _randx = GameLogic.return_RANDOM() % 60 - 30
	var _randy = GameLogic.return_RANDOM() % 40 - 20
	var _POS: Vector2 = Vector2(_randx, _randy)
	var _NUM = $ButControl / ReBut / X.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	_ChooseTSCN.position = _POS
	$ButControl / ReBut / X.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)

	if SteamLogic.IsMultiplay:
		SteamLogic.call_puppet_node_sync(self, "call_NetChoose_puppet", [_PLAYER, _POS])
func call_NetChoose_puppet(_PLAYER, _POS):
	var _ChooseTSCN = NetChooseTSCN.instance()
	_ChooseTSCN.position = _POS
	var _NUM = $ButControl / ReBut / X.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	$ButControl / ReBut / X.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)
