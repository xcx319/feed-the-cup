extends Control

var cur_pressed: bool

var cur_used: bool
var Can_Press: bool
var cur_RewardType: String
var cur_Rank: int
var PickDic: Dictionary
var ReMoneyTimes: int = 0
var ReMoneyBase: int
var ReMoney: int
onready var Select_1 = get_node("Select/1")
onready var Select_2 = get_node("Select/2")
onready var Select_3 = get_node("Select/3")

onready var Ani = get_node("Ani")

onready var RewardShowBut = preload("res://TscnAndGd/UI/Buttons/RewardShowButton.tscn")
var ShowBut = null
func _ready() -> void :
	call_deferred("call_init")

func _RandomList():
	GameLogic.Card.call_new_Reward()
	PickDic.clear()
	var _TOTALCHANCE: int = 0
	for _Name in GameLogic.Card.Reward_CanUsed:
		_TOTALCHANCE += GameLogic.Card.Reward_CanUsed[_Name]
		PickDic[_Name] = GameLogic.Card.Reward_CanUsed[_Name]
	if PickDic.size() > 2:
		for _i in 3:
			var _ID: String
			var _RAND: int
			match GameLogic.SPECIALLEVEL_Int:
				1:
					_RAND = GameLogic._SubStationRANDOM.randi() % _TOTALCHANCE
				2:
					_RAND = GameLogic._SubRANDOM.randi() % _TOTALCHANCE
				_:
					_RAND = GameLogic.return_randi() % _TOTALCHANCE

			for _NAME in PickDic:
				if _RAND > PickDic[_NAME]:
					_RAND -= PickDic[_NAME]
				else:
					_ID = _NAME
					_TOTALCHANCE -= PickDic[_NAME]
					var _RE = PickDic.erase(_NAME)
					break

			match _i:
				0:
					Select_1.ID = _ID
				1:
					Select_2.ID = _ID
				2:
					Select_3.ID = _ID
func call_puppet_logic(_Gift, _ID1, _ID2, _ID3):
	GameLogic.cur_Gift = _Gift
	Select_1.ID = _ID1
	Select_2.ID = _ID2
	Select_3.ID = _ID3

	call_show()
func call_ReMoney_Logic():
	if ReMoneyBase == 0:
		ReMoneyBase = GameLogic.cur_money
	var _REMONEY_BASE = 1000
	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Save.gameData.HomeDevList.has("盆栽竹子"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("挂墙绿植"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("仙人掌"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("捕蝇草"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("清新绿植"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("龟背竹"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("幸运树"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("高大绿植"):
			_REMONEY_BASE -= 50
		if GameLogic.Save.gameData.HomeDevList.has("多肉植物"):
			_REMONEY_BASE -= 50
		if GameLogic.Achievement.cur_EquipList.has("开礼增强"):
			if ReMoneyTimes < 0:
				ReMoney = 0
			else:
				_REMONEY_BASE -= 250

	ReMoney = int(float(ReMoneyTimes + 1) * 0.03 * float(ReMoneyBase + _REMONEY_BASE))
	if GameLogic.Achievement.cur_EquipList.has("开礼增强") and not GameLogic.SPECIALLEVEL_Int:
		if ReMoneyTimes < 0:
			ReMoney = 0
	if SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		ReMoney = 0

	$ButControl / ReBut / Num.text = str(ReMoney)
	var _NAME: String = "init"
	if GameLogic.cur_money >= ReMoney:
		$ButControl / ReBut / Num / AnimationPlayer.play("init")
	else:
		$ButControl / ReBut / Num / AnimationPlayer.play("nomoney")
		_NAME = "nomoney"
	GameLogic.call_StatisticsData_Set("Count_ReOpenGift", null, 1)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_ReMoney_puppet", [ReMoney, _NAME])
func call_ReMoney_puppet(_REMONEY, _ANINAME):
	Ani.play_backwards("ReBut")
	$AudioStreamPlayer.play(0)
	$ButControl / ReBut / Num.text = str(_REMONEY)
	$ButControl / ReBut / Num / AnimationPlayer.play(_ANINAME)
	GameLogic.call_StatisticsData_Set("Count_ReOpenGift", null, 1)

func _CheckLogic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.LoadingUI.IsLevel:
		return

	if GameLogic.cur_Gift > 0:
		if not cur_used:
			get_node("CurChoose").call_init()
			_RandomList()
			GameLogic.cur_Gift -= 1
			ReMoneyTimes = 0
			if GameLogic.Achievement.cur_EquipList.has("开礼增强") and not GameLogic.SPECIALLEVEL_Int:
				ReMoneyTimes = - 1
			call_ReMoney_Logic()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_logic", [GameLogic.cur_Gift, Select_1.ID, Select_2.ID, Select_3.ID])
			call_show()
	else:

		call_end()

func call_show_puppet():
	$ButControl / ReBut / MoneyLabel.text = str(GameLogic.cur_money)
	Can_Press = false
	Ani.play("show")
	GameLogic.GameUI.call_DayEnd_Close()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
		cur_pressed = false
		Can_Press = true
		cur_used = true
		return
func call_show():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		$ButControl / GiveUpButton.hide()
	else:
		if GameLogic.SPECIALLEVEL_Int:
			$ButControl / GiveUpButton.show()
	get_node("CurChoose").call_init()
	$ButControl / ReBut / MoneyLabel.text = str(GameLogic.cur_money)
	if not get_tree().is_paused():
		get_tree().set_pause(true)
	Can_Press = false
	Ani.play("show")
	GameLogic.GameUI.call_DayEnd_Close()

func call_Control():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		call_GrabFocus()
		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
			cur_pressed = false
			Can_Press = true
			cur_used = true
		return
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.connect("P2_Control", self, "_control_logic")
	cur_pressed = false
	Can_Press = true
	cur_used = true
	call_GrabFocus()
	$ButControl / ReBut / MoneyLabel.text = str(GameLogic.cur_money)
func call_disconnect():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
func call_GrabFocus():
	if Select_1.focus_mode == Control.FOCUS_ALL:
		if not Select_1.has_focus():
			Select_1.grab_focus()
func call_ReBut():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.cur_money >= ReMoney:
		Can_Press = false
		ReMoneyTimes += 1
		GameLogic.level_BuyUpdate += int(ReMoney)
		GameLogic.call_MoneyChange( - 1 * ReMoney, GameLogic.HomeMoneyKey)
		call_money_change( - 1 * ReMoney)
		call_ReMoney_Logic()

		Ani.play_backwards("ReBut")
		$AudioStreamPlayer.play(0)
	else:

		$ButControl / ReBut / Num / AnimationPlayer.play("NoMoneyAni")

func call_Pick_Reward():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	_RandomList()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Pick_Reward_puppet", [Select_1.ID, Select_2.ID, Select_3.ID])
func call_Pick_Reward_puppet(_ID_1, _ID_2, _ID_3):
	Select_1.ID = _ID_1
	Select_2.ID = _ID_2
	Select_3.ID = _ID_3



func call_init():
	if not GameLogic.is_connected("RewardUI", self, "_CheckLogic"):
		var _TimeCheck = GameLogic.connect("RewardUI", self, "_CheckLogic")
	ReMoneyBase = GameLogic.cur_money
	Ani.play("init")

func call_puppet_select(_ButName, _SelectReward):
	cur_used = false
	GameLogic.Audio.But_Apply.play(0)
	if GameLogic.Config.CardConfig[_SelectReward].UnlockType == "升级":
		var _VALUE = GameLogic.Config.CardConfig[_SelectReward].UnlockValue
		if GameLogic.cur_Rewards.has(_VALUE):
			GameLogic.cur_Rewards.erase(_VALUE)
	GameLogic.cur_Rewards.append(_SelectReward)

	SteamLogic.LevelDic.cur_Rewards = GameLogic.cur_Rewards
	if not SteamLogic.LevelDic.has("Choose_Rewards"):
		SteamLogic.LevelDic["Choose_Rewards"] = []
	if not SteamLogic.LevelDic["Choose_Rewards"].has(_SelectReward):
		SteamLogic.LevelDic["Choose_Rewards"].append(_SelectReward)
	GameLogic.call_StatisticsData_Set("Count_OpenGift", null, 1)

	GameLogic.level_OpenGiftTotal += 1
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.LevelDic.has("OpenGift"):
			SteamLogic.LevelDic.OpenGift += 1
		else:
			SteamLogic.LevelDic.OpenGift = 0
	Ani.play(_ButName)
	call_disconnect()
func call_select(_ButName):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		var _PLAYER: int = 0
		match SteamLogic.STEAM_ID:
			SteamLogic.SLOT_2:
				_PLAYER = 2
			SteamLogic.SLOT_3:
				_PLAYER = 3
			SteamLogic.SLOT_4:
				_PLAYER = 4
		$Select.get_node(str(_ButName)).call_NetChoose(_PLAYER)
		return
	if not cur_used:
		return

	var _SelectReward
	match _ButName:
		"1":
			_SelectReward = Select_1.ID
		"2":
			_SelectReward = Select_2.ID
		"3":
			_SelectReward = Select_3.ID
	if GameLogic.cur_Rewards.has(_SelectReward):
		return
	call_disconnect()
	cur_used = false

	GameLogic.Audio.But_Apply.play(0)





	if GameLogic.Config.CardConfig[_SelectReward].UnlockType == "升级":
		var _VALUE = GameLogic.Config.CardConfig[_SelectReward].UnlockValue
		if GameLogic.cur_Rewards.has(_VALUE):
			GameLogic.cur_Rewards.erase(_VALUE)
	GameLogic.cur_Rewards.append(_SelectReward)
	GameLogic.call_StatisticsData_Set("Count_OpenGift", null, 1)

	GameLogic.level_OpenGiftTotal += 1

	Ani.play(_ButName)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_select", [_ButName, _SelectReward])

func _NextGift():
	get_node("CurChoose").call_init()
	_CheckLogic()
func call_end():
	Ani.play("init")
	if GameLogic.SPECIALLEVEL_Int:
		var LevelNode = get_tree().get_root().get_node("Level")
		if LevelNode.has_method("_LEVELSTAT_LOGIC"):
			LevelNode._LEVELSTAT_LOGIC(2)
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		pass
	else:
		GameLogic.call_save()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_end")

	GameLogic.call_NewDay()
	ReMoneyBase = 0
	ReMoneyTimes = 0
func call_puppet_end():
	Ani.play("init")
	GameLogic.Save.call_SteamDic_save()

	GameLogic.call_NewDay()
func _control_logic(_but, _value, _type):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		match _but:
			"X":
				if not cur_used:
					return
				if _value == 1 or _value == - 1:
					var _PLAYER: int = 0
					match SteamLogic.STEAM_ID:
						SteamLogic.SLOT_2:
							_PLAYER = 2
						SteamLogic.SLOT_3:
							_PLAYER = 3
						SteamLogic.SLOT_4:
							_PLAYER = 4
					call_NetChoose(_PLAYER)
			"A":
				if _value == 1 or _value == - 1:
					if Select_1.has_focus():
						yield(get_tree().create_timer(0.1), "timeout")

						call_select(Select_1.name)
					if Select_2.has_focus():
						yield(get_tree().create_timer(0.1), "timeout")

						call_select(Select_2.name)
					if Select_3.has_focus():
						yield(get_tree().create_timer(0.1), "timeout")

						call_select(Select_3.name)

			"U", "u":
				if _value == 1 or _value == - 1:
					if not cur_pressed:
						cur_pressed = true
						call_up()
			"D", "d":
				if _value == 1 or _value == - 1:
					if not cur_pressed:
						cur_pressed = true
						call_down()
			"L", "l":
				if _value != 1 and _value != - 1:
					cur_pressed = false
					return
				if cur_pressed:
					return
				cur_pressed = true
				_udlf_logic("ui_left")
			"R", "r":
				if _value != 1 and _value != - 1:
					cur_pressed = false
					return
				if cur_pressed:
					return
				cur_pressed = true
				_udlf_logic("ui_right")
		return
	if not Can_Press:
		return
	if _value == 0:
		cur_pressed = false
	match _but:
		"X":
			if _value == 1 or _value == - 1:


				if not cur_used:
					return
				if not cur_pressed:
					cur_pressed = true
					call_ReBut()
		"B":
			if not cur_used:
				return
			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true
					match cur_UI:
						UI.MAIN:
							_on_GiveUpButton_pressed()

						UI.GIVEUPSECOND:
							_on_Back_pressed()

		"Y":
			if not cur_used:
				return
			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true
					match cur_UI:

						UI.GIVEUPSECOND:
							_on_GiveUp_pressed()
							return

		"A":
			if _value == 1 or _value == - 1:
				if not cur_used:
					return
				if not cur_pressed:
					cur_pressed = true
					if Select_1.has_focus():
						yield(get_tree().create_timer(0.1), "timeout")

						call_select(Select_1.name)
					if Select_2.has_focus():
						yield(get_tree().create_timer(0.1), "timeout")

						call_select(Select_2.name)
					if Select_3.has_focus():
						yield(get_tree().create_timer(0.1), "timeout")

						call_select(Select_3.name)
		"U", "u":
			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true

					call_up()
		"D", "d":
			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true

					call_down()
		"L", "l":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			cur_pressed = true

			_udlf_logic("ui_left")
		"R", "r":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			cur_pressed = true

			_udlf_logic("ui_right")
	if _type == 0:
		cur_pressed = false
func _udlf_logic(_action: String):
	var _input = InputEventAction.new()
	_input.action = _action
	_input.pressed = true
	Input.parse_input_event(_input)
func call_up():
	var _FocusOwner = get_focus_owner()
	if not _FocusOwner:
		return
	var _CurType = _FocusOwner.get_parent().get_parent().name

	if _CurType in ["CardUI", "RewardUI"]:
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
			if has_node("ScrollButHBox/1"):
				get_node("ScrollButHBox/1").grab_focus()
			elif has_node("Select/1"):
				get_node("Select/1").grab_focus()
	if _CurType == "Challenge":
		get_focus_owner().pressed = false
		get_node("CurChoose").call_ShowInfo_Hide()
		if has_node("ScrollButHBox/1"):
			get_node("ScrollButHBox/1").grab_focus()
		elif has_node("Select/1"):
				get_node("Select/1").grab_focus()

func call_money_change(_Num):
	var MoneyPlusLabel = $ButControl / ReBut / MoneyLabel / MoneyPlus
	var MoneyPlusAni = $ButControl / ReBut / MoneyLabel / MoneyPlusAni
	var _moneyNode = $ButControl / ReBut / MoneyLabel

	var _Str = str(_Num)
	if _Num > 0:
		_Str = "+" + str(_Num)
	MoneyPlusLabel.text = _Str
	if MoneyPlusAni.is_playing():
		MoneyPlusAni.stop(true)
	if _Num > 0:
		MoneyPlusAni.play("plus")
	elif _Num < 0:
		MoneyPlusAni.play("reduce")
	_moneyNode.text = str(GameLogic.cur_money)

func _on_1_pressed():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	call_select(Select_1.name)

func _on_2_pressed():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	call_select(Select_2.name)

func _on_3_pressed():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	call_select(Select_3.name)

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

func _on_GiveUp_pressed():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.cur_level:
		return
	GameLogic.Can_ESC = false
	GameLogic.Can_Card = false
	GameLogic.GameOverType = 3
	GameLogic.call_SYNC()
	cur_UI = UI.MAIN
	cur_used = false
	$ButControl / GiveUpButton / Second / AnimationPlayer.play("init")
	Ani.play("init")
	if not GameLogic.InHome_Bool:
		GameLogic.call_save()
		GameLogic._DayOver_Bool = false
		GameLogic.call_dayover()
	if not SteamLogic.STEAM_BOOL:
		return

	var _SetLevel = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Level", "")
	var _SetDevil = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Devil", "")
	var _SetDay = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Day", "0")

var cur_UI = UI.MAIN
enum UI{
	MAIN
	GIVEUPSECOND
}
func _on_GiveUpButton_pressed():

	$ButControl / GiveUpButton / Second / AnimationPlayer.play("show")

func _on_Back_pressed():
	if cur_UI in [UI.GIVEUPSECOND]:
		cur_UI = UI.MAIN
		GameLogic.Audio.But_Back.play(0)
	$ButControl / GiveUpButton / Second / AnimationPlayer.play("init")

func call_GiveUpSecond():
	cur_UI = UI.GIVEUPSECOND

func call_Audio():
	GameLogic.Audio.But_Back.play(0)
