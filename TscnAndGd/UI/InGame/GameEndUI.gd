extends Control
onready var CostLabel = $Control / BG / money / TotalCost / Label
onready var StoreBaseValueLabel = $Control / BG / InfoControl / Reward / StoreBaseValueLabel / Label

onready var HomeMoneyValueLabel = $Control / BG / InfoControl / Reward / StoreValueLabel / Label
onready var RateLabel = $Control / BG / InfoControl / Reward / RateLabel

onready var HomeMoneyLabel = $Control / BG / money / MoneyLabel
onready var TotalHomeMoneyLabel = $Control / BG / money / TotalCost
onready var FinalHomeMoneyLabel = $Control / BG / money / FinalMoney

onready var EndAccount_TSCN = preload("res://TscnAndGd/UI/InGame/GameEndAccount.tscn")
onready var CardInfo_TSCN = preload("res://TscnAndGd/Buttons/EndGameCardInfo.tscn")
onready var UnlockLabel = get_node("Control/BG/UnlockLevel")

onready var _GiftCountNode = $Control / BG / Special / GiftNode / GiftCountNode

onready var Ani = get_node("Ani")
onready var TypeAni = get_node("TypeAni")
onready var CurChoose = $DevilMoney / CurChoose
var EndAccountNode
var StoreValue: int
var StoreMult: int
var MultBase: int = 1
var MultValue: float = 0.2
var FINAL_VALUE: int
var cur_show: bool
var cur_pressed: bool
var FirstPassReward: int

var _INIT_BOOL: bool
var _MAXNUM: int

func call_upload_DailyLeaderBoard(_POINT, _LEVELID, _DEVIL, _PLAYERNUM, _PERFECT, _GOOD, _BAD, _2ID, _3ID, _4ID):

	SteamLogic.call_FindLeaderBoard()
	if int(_LEVELID) == 11 and _POINT > 9999999:
		return
	var _CHECKNUM = GameLogic.return_MC()

	var _ARRAY: Array = [_LEVELID, _DEVIL, _PLAYERNUM, _PERFECT, _GOOD, _BAD, _2ID, _3ID, _4ID, _CHECKNUM]
	if GameLogic.SPECIALLEVEL_Int:
		_ARRAY[1] = - 1
	if SteamLogic.IsJoin:
		if SteamLogic.LevelDic.SPECIALLEVEL_Int:
			_ARRAY[1] = - 1
		var _MONEY = SteamLogic.LevelDic.MoneyCHECK
		if _MONEY > 0:
			_CHECKNUM = int(round(_MONEY / GameLogic._MONEYCHECKMULT))
		_ARRAY = [_LEVELID, _DEVIL, _PLAYERNUM, _PERFECT, _GOOD, _BAD, _2ID, _3ID, _4ID, _CHECKNUM]
		SteamLogic.call_upload_daily_leaderboard(_POINT, _ARRAY)
		return



	var _CUPNUM: int = int(_PERFECT) + int(_GOOD) + int(_BAD)

	if GameLogic.CHEATINGBOOL:
		return
	SteamLogic.call_upload_daily_leaderboard(_POINT, _ARRAY)

func _ready() -> void :
	var _Check = GameLogic.connect("GameOver", self, "_GameOver_Logic")

func call_show_switch(_switch: bool):
	cur_show = _switch
	if cur_show:
		cur_pressed = false
		call_GrabFocus()

func call_GrabFocus():

	if CurChoose.get_node("Reward/Grid").get_child_count():
		CurChoose.get_node("Reward/Grid").get_child(0).grab_focus()
	elif CurChoose.get_node("Challenge/Grid").get_child_count():
		CurChoose.get_node("Challenge/Grid").get_child(0).grab_focus()
func _control_logic(_but, _value, _type):

	if not cur_show:
		match _but:
			"A":
				if _value in [1, - 1]:
					EndAccountNode._QUICK_BOOL = true
					Ani.playback_speed = 5
					$MoneyAni.playback_speed = 5
				elif _value == 0:
					EndAccountNode._QUICK_BOOL = false
					Ani.playback_speed = 1
					$MoneyAni.playback_speed = 1
		return
	if _value == 0:
		cur_pressed = false
	match _but:
		"A", 0:
			_on_Button_pressed()
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
			var _input = InputEventAction.new()
			_input.action = "ui_left"
			_input.pressed = true
			Input.parse_input_event(_input)
		"R", "r":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			cur_pressed = true
			var _input = InputEventAction.new()
			_input.action = "ui_right"
			_input.pressed = true
			Input.parse_input_event(_input)
	if _type == 0:
		cur_pressed = false
var _ShowEND: bool
func _GameOver_Logic(_Complete_Bool, _Reward):

	if _INIT_BOOL:
		return
	_ShowEND = false
	_INIT_BOOL = true
	FirstPassReward = _Reward

	get_tree().set_pause(true)

	call_ResetGift()


	if SteamLogic.IsJoin:
		var _c = SteamLogic.LevelDic.IsFinish

		if SteamLogic.LevelDic.IsFinish:

			call_triggerItemDrop()
			TypeAni.play("complete")
			if GameLogic.cur_level == "社区店2" and GameLogic.cur_Devil > 1:
				_ShowEND = true
		else:
			TypeAni.play("Join")
	else:
		match _Complete_Bool:
			true:
				call_triggerItemDrop()
				TypeAni.play("complete")


				pass
			false:
				match GameLogic.GameOverType:
					1:
						TypeAni.play("0")
						pass
					2:
						TypeAni.play("1")
						pass
					3, 4:
						TypeAni.play("2")
				pass
	if not Ani.is_playing():
		call_init()

	Ani.play("play")
	get_node("DemoEnd/Ani").play("init")
	GameLogic.Can_ESC = false

	call_Can_Move(false)
	EndAccountNode = EndAccount_TSCN.instance()
	call_control()

	if not GameLogic.DEMO_bool:
		if SteamLogic.IsJoin:


			var _CHECKNUM: int = 0
			var _MONEY = SteamLogic.LevelDic.MoneyCHECK
			if _MONEY > 0:
				_CHECKNUM = int(round(_MONEY / GameLogic._MONEYCHECKMULT))
			var _x = SteamLogic.LevelDic.Coin
			if _CHECKNUM > SteamLogic.LevelDic.Coin:
				_CHECKNUM = SteamLogic.LevelDic.Coin
			EndAccountNode.ICONNUM = _CHECKNUM
			EndAccountNode.CUPNUM = SteamLogic.LevelDic.Cup

			var _PlayerID = SteamLogic.LevelDic.Character
			if not GameLogic.DEMO_bool and not GameLogic.CHEATINGBOOL:
				var _EXP = int(SteamLogic.LevelDic["EXP"] * SteamLogic.LevelDic["EXP"] / 10)
				GameLogic.Save.statisticsData["Character"][_PlayerID].EXP += _EXP
			if GameLogic.Save.statisticsData["Character"][_PlayerID].EXP > GameLogic.Staff.EXPMAX:
				if not GameLogic.CHEATINGBOOL:
					GameLogic.Save.statisticsData["Character"][_PlayerID].EXP = GameLogic.Staff.EXPMAX
			if not GameLogic.CHEATINGBOOL:
				GameLogic.Save.statisticsData["Character"][_PlayerID].MultplayCount += 1
				GameLogic.Save.statisticsData["Character"][_PlayerID].FeedCups += SteamLogic.LevelDic.Cup
			if _CHECKNUM > GameLogic.Save.statisticsData["Character"][_PlayerID].CupCoinCount:
				if not GameLogic.CHEATINGBOOL:
					GameLogic.Save.statisticsData["Character"][_PlayerID].CupCoinCount = _CHECKNUM

			var _POINT: int = _CHECKNUM

			if GameLogic.Config.SceneConfig.has(SteamLogic.LevelDic.Level):
				var _LEVELID: int = int(str(GameLogic.Config.SceneConfig[SteamLogic.LevelDic.Level].LevelType) + str(GameLogic.Config.SceneConfig[SteamLogic.LevelDic.Level].LevelID))
				var _DEVIL: int = SteamLogic.LevelDic.Devil
				var _PERFECT: int = SteamLogic.LevelDic.Perfect
				var _GOOD: int = SteamLogic.LevelDic.Good
				var _BAD: int = SteamLogic.LevelDic.Bad
				var _PLAYERNUM: int = 0
				if SteamLogic.LevelDic.has("PlayerNum"):
					_PLAYERNUM = SteamLogic.LevelDic.PlayerNum
				if not GameLogic.CHEATINGBOOL:
					call_upload_DailyLeaderBoard(_POINT, _LEVELID, _DEVIL, _PLAYERNUM, _PERFECT, _GOOD, _BAD, 0, 0, 0)

		else:
			var _CHECKNUM = GameLogic.return_MC()

			EndAccountNode.ICONNUM = _CHECKNUM
			EndAccountNode.CUPNUM = GameLogic.level_SellTotal

			if GameLogic.Save.statisticsData["Character"].has(GameLogic.player_1P_ID):
				if not GameLogic.DEMO_bool and not GameLogic.CHEATINGBOOL:
					var _EXP = int(GameLogic.level_EXP_Base * GameLogic.level_EXP_Base / 10)
					GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].EXP += _EXP
				if GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].EXP > GameLogic.Staff.EXPMAX:
					if not GameLogic.CHEATINGBOOL:
						GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].EXP = GameLogic.Staff.EXPMAX
				if not GameLogic.CHEATINGBOOL:
					GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].UseCount += 1
					GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].FeedCups += GameLogic.level_SellTotal
					if _CHECKNUM > GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].CupCoinCount:
						GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].CupCoinCount = _CHECKNUM

			var _POINT: int = GameLogic.return_MC()

			var _LEVELID: int = 0
			if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
				_LEVELID = int(str(GameLogic.Config.SceneConfig[GameLogic.cur_level].LevelType) + str(GameLogic.Config.SceneConfig[GameLogic.cur_level].LevelID))
			var _DEVIL: int = GameLogic.cur_Devil
			var _PERFECT: int = GameLogic.level_Perfect
			var _GOOD: int = GameLogic.level_Good
			var _BAD: int = GameLogic.level_Bad
			var _CUPNUM = _PERFECT + _GOOD + _BAD



			var _PLAYERNUM: int = 1
			if GameLogic.Save.levelData.has("PlayerNum"):
				_PLAYERNUM = GameLogic.Save.levelData["PlayerNum"]
			var _PLAYER_2_ID: int = 0
			var _PLAYER_3_ID: int = 0
			var _PLAYER_4_ID: int = 0
			if GameLogic.Save.levelData.has("PlayerID"):
				var _List = GameLogic.Save.levelData["PlayerID"]
				_PLAYER_2_ID = _List[0]
				_PLAYER_3_ID = _List[1]
				_PLAYER_4_ID = _List[2]
			if _PLAYER_2_ID == 0 and _PLAYER_3_ID == 0 and _PLAYER_4_ID == 0:
				if GameLogic.Player2_bool:
					_PLAYERNUM = 2
				else:
					_PLAYERNUM = 1
			else:
				_PLAYERNUM = 1
				if _PLAYER_2_ID > 0:
					_PLAYERNUM += 1
				if _PLAYER_3_ID > 0:
					_PLAYERNUM += 1
				if _PLAYER_4_ID > 0:
					_PLAYERNUM += 1
			if not GameLogic.CHEATINGBOOL:
				call_upload_DailyLeaderBoard(_POINT, _LEVELID, _DEVIL, _PLAYERNUM, _PERFECT, _GOOD, _BAD, _PLAYER_2_ID, _PLAYER_3_ID, _PLAYER_4_ID)

	self.add_child(EndAccountNode)
	EndAccountNode.call_show()
	if not EndAccountNode.is_connected("Finished", self, "Show_End"):
		EndAccountNode.connect("Finished", self, "Show_End")
	GameLogic.call_LevelFinished()
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_SetPause(true)
	if GameLogic.Player2_bool:
		if is_instance_valid(GameLogic.player_2P):
			GameLogic.player_2P.call_SetPause(true)
func call_control():

	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if GameLogic.Player2_bool:
		if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.connect("P2_Control", self, "_control_logic")

func call_Can_Move(_bool: bool):
	match _bool:
		false:
			if is_instance_valid(GameLogic.player_1P):
				GameLogic.player_1P.call_SetPause(true)
			if GameLogic.Player2_bool:
				if is_instance_valid(GameLogic.player_2P):
					GameLogic.player_2P.call_SetPause(true)
		true:
			if is_instance_valid(GameLogic.player_1P):
				GameLogic.player_1P.call_SetPause(false)
			if GameLogic.Player2_bool:
				if is_instance_valid(GameLogic.player_2P):
					GameLogic.player_2P.call_SetPause(false)

func Show_End():

	var _x = GameLogic.curLevelList
	Ani.play("show")
	if FINAL_VALUE == 0:
		$MoneyAni.play("0")
	elif FINAL_VALUE < float(_MAXNUM) * 0.1:
		$MoneyAni.play("1")
	elif FINAL_VALUE < float(_MAXNUM) * 0.2:
		$MoneyAni.play("2")
	elif FINAL_VALUE < float(_MAXNUM) * 0.5:
		$MoneyAni.play("3")
	elif FINAL_VALUE < float(_MAXNUM) * 0.75:
		$MoneyAni.play("4")
	else:
		$MoneyAni.play("5")
func Mult_Logic():

	var _DAYMULT: Array = []



	var _OverType: float = 1
	var _Mult: float = 1

	_MAXNUM = 5000
	if SteamLogic.IsJoin:
		var _NetCheck: bool
		if SteamLogic.LevelDic.has("Level"):
			if SteamLogic.LevelDic.Level != "":
				_NetCheck = true

		if _NetCheck:
			_MAXNUM = int(GameLogic.Config.SceneConfig[SteamLogic.LevelDic.Level].HomeMoneyMax)

			var _LEVELMULT: float = float(GameLogic.Config.SceneConfig[SteamLogic.LevelDic.Level].HomeMoneyMult)
			var _DEVILMULT: float = float(SteamLogic.LevelDic.Devil) * 2
			_Mult = _LEVELMULT


	else:

		if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
			_Mult = float(GameLogic.Config.SceneConfig[GameLogic.cur_level].HomeMoneyMult)
			_MAXNUM = int(GameLogic.Config.SceneConfig[GameLogic.cur_level].HomeMoneyMax)


	var _SPECIAL_INT = GameLogic.SPECIALLEVEL_Int
	if SteamLogic.IsJoin:
		if SteamLogic.LevelDic.has("SPECIALLEVEL_Int"):
			_SPECIAL_INT = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if not _SPECIAL_INT:
		if GameLogic.Achievement.cur_EquipList.has("钞票奖励"):
			if GameLogic.GameOverType == 0:
				_Mult += 1
		if GameLogic.Save.gameData.HomeDevList.has("玄关吊灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("月亮灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("冷光灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("厨房灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("香薰蜡烛"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("客厅灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("水晶灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("外墙壁灯"):
			_Mult += 0.5
		if GameLogic.Save.gameData.HomeDevList.has("豪华吊灯"):
			_Mult += 0.5
	if SteamLogic.IsJoin:
		var _MONEY = SteamLogic.LevelDic.MoneyCHECK
		var _CHECKNUM = 0
		if _MONEY > 0:
			_CHECKNUM = round(_MONEY / GameLogic._MONEYCHECKMULT)
		if _CHECKNUM > SteamLogic.LevelDic.Coin:
			_CHECKNUM = SteamLogic.LevelDic.Coin
		StoreValue = int(_CHECKNUM)
		var _CUPNUM = SteamLogic.LevelDic.Perfect + SteamLogic.LevelDic.Good + SteamLogic.LevelDic.Bad
		if not SteamLogic.LevelDic.has("SPECIALLEVEL_Int"):
			SteamLogic.LevelDic["SPECIALLEVEL_Int"] = 0
		if SteamLogic.LevelDic.IsFinish:

			if SteamLogic.LevelDic.SPECIALLEVEL_Int:
				_MAXNUM = _MAXNUM * 3
				var _PlayerNUM = SteamLogic.LevelDic["PlayerNum"]
				match _PlayerNUM:
					1:
						_Mult = 2
					2, - 2:
						_Mult = 1.5
					3:
						_Mult = 1.1
					4:
						_Mult = 0.8
			else:
				_MAXNUM = _MAXNUM * 2
		else:
			if SteamLogic.LevelDic.SPECIALLEVEL_Int:
				_MAXNUM = int(float(_MAXNUM) / 2)
				var _PlayerNUM = SteamLogic.LevelDic["PlayerNum"]
				match _PlayerNUM:
					1:
						_Mult = 1
					2, - 2:
						_Mult = 0.75
					3:
						_Mult = 0.55
					4:
						_Mult = 0.4
			else:
				_Mult = _Mult / 2

	else:
		if GameLogic.GameOverType == 0:
			if GameLogic.SPECIALLEVEL_Int:
				_MAXNUM = _MAXNUM * 3
				var _PlayerNUM = GameLogic.Save.levelData["PlayerNum"]
				match _PlayerNUM:
					1:
						_Mult = 2
					2, - 2:
						_Mult = 1.5
					3:
						_Mult = 1.1
					4:
						_Mult = 0.8
			else:
				_MAXNUM = _MAXNUM * 2
		else:
			if GameLogic.SPECIALLEVEL_Int:
				_MAXNUM = int(float(_MAXNUM) / 2)
				var _PlayerNUM = GameLogic.Save.levelData["PlayerNum"]
				match _PlayerNUM:
					1:
						_Mult = 1
					2, - 2:
						_Mult = 0.75
					3:
						_Mult = 0.55
					4:
						_Mult = 0.4
			else:
				_Mult = _Mult / 2
		var _CHECKNUM = GameLogic.return_MC()

		StoreValue = int(_CHECKNUM)
		var _CUPNUM = GameLogic.level_Perfect + GameLogic.level_Good + GameLogic.level_Bad

	RateLabel.text = str(_Mult) + "%"
	var _value: int = 0
	if _Mult > 0:
		_value = int(float(_Mult) / float(100) * float(StoreValue))






	if _value < 0:
		_value = 0
	if _value >= _MAXNUM:
		_value = _MAXNUM
		$Control / BG / InfoControl / Reward / StoreValueLabel / Label / Icon / MaxLabel.show()
	else:
		$Control / BG / InfoControl / Reward / StoreValueLabel / Label / Icon / MaxLabel.hide()
	var _CANSAVE: bool = false

	var _x = SteamLogic.LevelDic
	var _u = SteamLogic.IsJoin
	if SteamLogic.IsJoin and SteamLogic.LevelDic.Level:

		var _CHECKBOOL: bool = false
		if SteamLogic.LevelDic.has("SPECIALLEVEL_Int"):
			if SteamLogic.LevelDic.SPECIALLEVEL_Int > 0:
				_CANSAVE = false
				_CHECKBOOL = true
		if SteamLogic.LevelDic.IsFinish and SteamLogic.LevelDic.SkipDay == 0 and not _CHECKBOOL:

			var _LEVELNAME = SteamLogic.LevelDic.Level
			var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVELNAME]
			var _LEVELKEY = GameLogic.Save.gameData["Level_Data"].keys()
			if _LEVELKEY.has(_LEVELNAME):
				var _CURDEVIL = int(GameLogic.Save.gameData["Level_Data"][_LEVELNAME].cur_Devil)
				var _LEVELDEVIL = int(SteamLogic.LevelDic.Devil)

				if _CURDEVIL < _LEVELDEVIL:
					_CANSAVE = true

			else:
				var _LEVELTYPE: int = int(_LEVELINFO.LevelType)
				var _LEVELID: int = int(_LEVELINFO.LevelID)
				if _LEVELID == 1:
					if _LEVELTYPE > 1:
						_LEVELTYPE -= 1
						_LEVELID = 4
				else:
					_LEVELID -= 1
				if _LEVELID == 1 and _LEVELTYPE == 1:
					if _LEVELNAME == "新手引导第一关":
						_CANSAVE = true

				var _SCENEKEY = GameLogic.Config.SceneConfig.keys()
				var _JOINTYPE: int = 0
				for _CHECKLEVEL in _SCENEKEY:
					var _INFO = GameLogic.Config.SceneConfig[_CHECKLEVEL]
					if int(_INFO.LevelType) == _LEVELTYPE and int(_INFO.LevelID) == _LEVELID:
						if _LEVELKEY.has(_CHECKLEVEL):
							_CANSAVE = true
						break

		if _CANSAVE:
			var _LEVELNAME = SteamLogic.LevelDic.Level
			var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVELNAME]
			if not GameLogic.Save.gameData.Level_Data.has(_LEVELNAME):
				FirstPassReward = int(_LEVELINFO.RewardList[0])
			else:
				if GameLogic.Save.gameData.Level_Data[_LEVELNAME].has("cur_Devil"):
					var _DEVIL = int(SteamLogic.LevelDic.Devil)
					var _DATADEVIL = int(GameLogic.Save.gameData.Level_Data[_LEVELNAME]["cur_Devil"])
					if _DEVIL > _DATADEVIL:
						var _NEWDEVIL = _DATADEVIL + 1
						if _LEVELINFO.RewardList.size() > _NEWDEVIL:
							FirstPassReward = int(_LEVELINFO.RewardList[_DATADEVIL + 1])
				else:
					FirstPassReward = int(_LEVELINFO.RewardList[0])

			_value += FirstPassReward


	else:

		if GameLogic.SPECIALLEVEL_Int:
			FirstPassReward = 0

		_value += FirstPassReward


	TotalHomeMoneyLabel.text = str(_value)
	HomeMoneyValueLabel.text = str(_value)
	var _HMK = GameLogic.return_FullHMK()

	HomeMoneyLabel.text = str(_HMK)



	StoreBaseValueLabel.text = str(StoreValue)
	GameLogic.call_StatisticsData_Set("Count_HomeMoney", null, _value)

	if GameLogic.Save.statisticsData["Character"].has(GameLogic.player_1P_ID):
		if not GameLogic.CHEATINGBOOL:
			GameLogic.Save.statisticsData["Character"][GameLogic.player_1P_ID].HomeMoneyCount += _value

	FINAL_VALUE = _value
	if FirstPassReward > 0 and not SteamLogic.IsJoin:
		get_node("Control/BG/InfoControl/Reward/StoreValueLabel/First").show()
		get_node("Control/BG/InfoControl/Reward/StoreValueLabel/First/Label").text = str(FirstPassReward)
	else:
		if _CANSAVE and FirstPassReward > 0:
			get_node("Control/BG/InfoControl/Reward/StoreValueLabel/First").show()
			get_node("Control/BG/InfoControl/Reward/StoreValueLabel/First/Label").text = str(FirstPassReward)
		else:
			get_node("Control/BG/InfoControl/Reward/StoreValueLabel/First").hide()

onready var _GIFTTSCN = preload("res://TscnAndGd/UI/Info/GiftUI.tscn")
func call_ResetGift():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_ResetGift")
	var _List = _GiftCountNode.get_children()
	for _Node in _List:
		_Node.queue_free()
func call_Gift_puppet(_GIFTNUM):
	GameLogic.cur_Gift = _GIFTNUM
	for i in GameLogic.cur_Gift:
		if i < 20:
			var _GIFT = _GIFTTSCN.instance()
			_GiftCountNode.add_child(_GIFT)
func call_Gift():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	for i in GameLogic.SPECIAL_NUM:
		var _GIFT = _GIFTTSCN.instance()
		_GiftCountNode.add_child(_GIFT)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Gift_puppet", [GameLogic.SPECIAL_NUM])
func call_init():

	Mult_Logic()
	if GameLogic.cur_Day < 0:
		GameLogic.cur_Day = 0



	if SteamLogic.IsJoin:
		GameLogic.cur_Day = SteamLogic.LevelDic.Day
		var _CHECKNUM: int = 0
		var _MONEY = SteamLogic.LevelDic.MoneyCHECK
		if _MONEY > 0:
			_CHECKNUM = int(round(_MONEY / GameLogic._MONEYCHECKMULT))
		if _CHECKNUM > SteamLogic.LevelDic.Coin:
			_CHECKNUM = SteamLogic.LevelDic.Coin
		var _COIN = SteamLogic.LevelDic.Coin


		$Control / BG / InfoControl / Review / Perfect / Label.text = str(SteamLogic.LevelDic.Perfect)
		$Control / BG / InfoControl / Review / Good / Label.text = str(SteamLogic.LevelDic.Good)
		$Control / BG / InfoControl / Review / Bad / Label.text = str(SteamLogic.LevelDic.Bad)
		if int(_CHECKNUM) > int(GameLogic.Save.statisticsData["Max_FinishMoney"]):
			GameLogic.Save.statisticsData["Max_FinishMoney"] = _CHECKNUM



	else:

		$Control / BG / InfoControl / Review / Perfect / Label.text = str(GameLogic.level_Perfect)
		$Control / BG / InfoControl / Review / Good / Label.text = str(GameLogic.level_Good)
		$Control / BG / InfoControl / Review / Bad / Label.text = str(GameLogic.level_Bad)

		var _CHECKNUM: int = GameLogic.return_MC()
		if int(_CHECKNUM) > int(GameLogic.Save.statisticsData["Max_FinishMoney"]):
			GameLogic.Save.statisticsData["Max_FinishMoney"] = _CHECKNUM
		for _Menu in GameLogic.cur_Menu:
			if not GameLogic.Save.statisticsData["Array_UnlockMenu"].has(_Menu):
				GameLogic.Save.statisticsData["Array_UnlockMenu"].append(_Menu)

	if has_node("Control/DayControl"):
		get_node("Control/DayControl").call_init()
	CurChoose.hide()



var _ADDEggCoin: int
func Call_Special_Logic(_COIN: int):

	var x = 0
	if x == 0:
		return
	var _OVERTYPE: int = 0
	var _PlayerNUM: int
	var _SPECIAL_Int: int
	var _SPECIAL_NUM: int
	if SteamLogic.IsJoin:
		if not SteamLogic.LevelDic.IsFinish:
			_OVERTYPE = 1
		if SteamLogic.LevelDic.has("PlayerNum"):
			_PlayerNUM = SteamLogic.LevelDic["PlayerNum"]
		if SteamLogic.LevelDic.has("SPECIALLEVEL_Int"):
			_SPECIAL_Int = SteamLogic.LevelDic.SPECIALLEVEL_Int
		if SteamLogic.LevelDic.has("SPECIAL_NUM"):
			_SPECIAL_NUM = SteamLogic.LevelDic.SPECIAL_NUM
	else:
		_OVERTYPE = GameLogic.GameOverType
		_PlayerNUM = GameLogic.Save.levelData["PlayerNum"]
		_SPECIAL_Int = GameLogic.SPECIALLEVEL_Int
		_SPECIAL_NUM = GameLogic.SPECIAL_NUM
	_ADDEggCoin = 0

	$Control / BG / Special / MoneyControl / MoneyCount.text = str(_COIN)

	var _MoneyToCoin: int
	var _List: Array = [1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000, 5000000, 10000000, 20000000, 50000000]
	var _CHECKNUM: int = 0
	for _CHECK in _List:
		if _COIN > _CHECK:
			_MoneyToCoin = _CHECKNUM + 1
		else:
			break
		_CHECKNUM += 1
	$Control / BG / Special / MoneyControl / EggCoin.text = "+" + str(_CHECKNUM)
	_ADDEggCoin += _CHECKNUM

	var _GiftToCoin: int
	_GiftToCoin = _SPECIAL_NUM
	$Control / BG / Special / GiftNode / EggCoin.text = "+" + str(_GiftToCoin)
	_ADDEggCoin += _GiftToCoin


	match _SPECIAL_Int:
		1:
			$Control / BG / Special / Finished / Label.call_Tr_TEXT("UI-通关奖励")
			if not _OVERTYPE:
				var _Coin: int = 5
				match _PlayerNUM:
					1:
						_Coin = 10
					2, - 2:
						_Coin = 6
					3:
						_Coin = 3
					4:
						_Coin = 1
				$Control / BG / Special / Finished / EggCoin.text = "+" + str(_Coin)
				_ADDEggCoin += _Coin
			else:
				$Control / BG / Special / Finished / EggCoin.text = "+0"
			$Control / BG / Special / Finished / EggCoin / Sprite.show()

		2:
			$Control / BG / Special / Finished / Label.call_Tr_TEXT("UI-奖励倍率")
			if not _OVERTYPE:
				var _MULT: float = 1
				match _PlayerNUM:
					1:
						_MULT = 3
					2, - 2:
						_MULT = 2
					3:
						_MULT = 1.5
					4:
						_MULT = 1.25
				$Control / BG / Special / Finished / EggCoin.text = "x" + str(_MULT)
				_ADDEggCoin = int(float(_ADDEggCoin) * _MULT)
			else:
				$Control / BG / Special / Finished / EggCoin.text = "x" + str(1)
			$Control / BG / Special / Finished / EggCoin / Sprite.hide()


	var _CurEggCoin = round(GameLogic.cur_EggCoin * GameLogic.EggCoinKey)
	$Control / BG / Special / EggCoinCount / EggCoin.text = "+" + str(_ADDEggCoin)
	$Control / BG / Special / EggCoinCount / TotalEggCoin.text = str(_CurEggCoin + _ADDEggCoin)
func call_CurCard_init():
	if CurChoose:
		CurChoose.call_init()
		CurChoose.show()

func call_Reward_Logic():
	var _IsFinished: int = 0
	var _COIN: int = StoreValue
	var _REWARDLIST = GameLogic.cur_Rewards
	var _CHALLENGELIST = GameLogic.cur_Challenge

	if SteamLogic.IsJoin and SteamLogic.LevelDic.Level:
		if SteamLogic.LevelDic.IsFinish:
			_IsFinished = 1

		if not SteamLogic.LevelDic.has("Choose_Rewards"):
			SteamLogic.LevelDic.Choose_Rewards = []
		if not SteamLogic.LevelDic.has("Choose_Challenge"):
			SteamLogic.LevelDic.Choose_Challenge = []
		_REWARDLIST = SteamLogic.LevelDic.Choose_Rewards
		_CHALLENGELIST = SteamLogic.LevelDic.Choose_Challenge
	else:

		if TypeAni.assigned_animation == "complete":

			_IsFinished = 1

	if not GameLogic.Save.statisticsData.has("CardList"):
		GameLogic.Save.statisticsData["CardList"] = []
	if not GameLogic.Save.statisticsData.has("ChallengeList"):
		GameLogic.Save.statisticsData["ChallengeList"] = []
	for _REWARDNAME in _REWARDLIST:

		if not GameLogic.Save.statisticsData.CardList.has(_REWARDNAME):
			GameLogic.Save.statisticsData.CardList[_REWARDNAME] = [1, _IsFinished, _COIN]
		else:
			var _LISTINFO = GameLogic.Save.statisticsData.CardList[_REWARDNAME]
			if typeof(_LISTINFO) == TYPE_ARRAY:
				var _NUM = _LISTINFO[0] + 1
				var _FINISH = _LISTINFO[1] + _IsFinished
				var _HIGHCOIN = 0
				if _LISTINFO.size() >= 3:
					_HIGHCOIN = _LISTINFO[2]
				if _COIN > _HIGHCOIN:
					_HIGHCOIN = _COIN
				GameLogic.Save.statisticsData.CardList[_REWARDNAME] = [_NUM, _FINISH, _HIGHCOIN]
			else:
				GameLogic.Save.statisticsData.CardList[_REWARDNAME] = [1, _IsFinished, _COIN]

		if GameLogic.Config.CardConfig.has(_REWARDNAME):
			var _INFO = GameLogic.Config.CardConfig[_REWARDNAME]
			if _INFO.UnlockType == "升级":
				var _NAME = _INFO.UnlockValue
				if not GameLogic.Save.statisticsData.CardList.has(_NAME):
					GameLogic.Save.statisticsData.CardList[_NAME] = [1, _IsFinished, _COIN]
				else:
					var _LISTINFO = GameLogic.Save.statisticsData.CardList[_NAME]
					if typeof(_LISTINFO) == TYPE_ARRAY:
						var _NUM = _LISTINFO[0] + 1
						var _FINISH = _LISTINFO[1] + _IsFinished
						var _HIGHCOIN = 0
						if _LISTINFO.size() >= 3:
							_HIGHCOIN = _LISTINFO[2]
						if _COIN > _HIGHCOIN:
							_HIGHCOIN = _COIN
						GameLogic.Save.statisticsData.CardList[_NAME] = [_NUM, _FINISH, _HIGHCOIN]
					else:
						GameLogic.Save.statisticsData.CardList[_NAME] = [1, _IsFinished, _COIN]
	for _CHALLENGENAME in _CHALLENGELIST:
		if not GameLogic.Save.statisticsData.ChallengeList.has(_CHALLENGENAME):
			GameLogic.Save.statisticsData.ChallengeList[_CHALLENGENAME] = [1, _IsFinished, _COIN]
		else:
			var _LISTINFO = GameLogic.Save.statisticsData.ChallengeList[_CHALLENGENAME]
			if typeof(_LISTINFO) == TYPE_ARRAY:
				var _NUM = _LISTINFO[0] + 1
				var _FINISH = _LISTINFO[1] + _IsFinished
				var _HIGHCOIN = _LISTINFO[2]
				if _COIN > _HIGHCOIN:
					_HIGHCOIN = _COIN
				GameLogic.Save.statisticsData.ChallengeList[_CHALLENGENAME] = [_NUM, _FINISH, _HIGHCOIN]
			else:
				GameLogic.Save.statisticsData.ChallengeList[_CHALLENGENAME] = [1, _IsFinished, _COIN]
func call_CheckData():

	if not SteamLogic.LevelDic.has("SPECIALLEVEL_Int"):
		SteamLogic.LevelDic["SPECIALLEVEL_Int"] = 0
	if not SteamLogic.LevelDic.has("Level"):
		SteamLogic.LevelDic["Level"] = ""
	if not SteamLogic.LevelDic.has("IsFinish"):
		SteamLogic.LevelDic["IsFinish"] = false
	if not SteamLogic.LevelDic.has("SkipDay"):
		SteamLogic.LevelDic["SkipDay"] = 0
func _on_Button_pressed() -> void :


	call_CheckData()
	if GameLogic.DEMO_bool:
		if _ShowEND:
			if get_node("DemoEnd/Ani").assigned_animation != "play":
				get_node("DemoEnd/Ani").play("play")
				return
			else:
				if get_node("DemoEnd/Ani").is_playing():
					return
	else:
		if not GameLogic.CHEATINGBOOL:
			SteamLogic.call_upload()
	call_Reward_Logic()


	GameLogic.cur_Rewards.clear()
	GameLogic.cur_Challenge.clear()

	if SteamLogic.IsJoin and SteamLogic.LevelDic.Level:
		GameLogic.call_load_puppet()

		var _CANSAVE: bool = false

		if SteamLogic.LevelDic.IsFinish and SteamLogic.LevelDic.SkipDay == 0:


			if GameLogic.Save.gameData.has("Level_Data"):
				var _LEVEL = SteamLogic.LevelDic.Level
				var _LEVELKEY = GameLogic.Save.gameData["Level_Data"].keys()
				if _LEVELKEY.has(_LEVEL):
					if int(GameLogic.Save.gameData["Level_Data"][_LEVEL].cur_Devil) < int(SteamLogic.LevelDic.Devil):
						_CANSAVE = true
				else:
					if GameLogic.Config.SceneConfig.has(_LEVEL):
						var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVEL]
						var _LEVELTYPE: int = int(_LEVELINFO.LevelType)
						var _LEVELID: int = int(_LEVELINFO.LevelID)
						if _LEVELID == 1:
							if _LEVELTYPE != 1:
								_LEVELTYPE -= 1
								_LEVELID = 4

						else:
							_LEVELID -= 1
						if _LEVELID == 1 and _LEVELTYPE == 1:
							if _LEVEL == "新手引导第一关":
								_CANSAVE = true
						var _SCENEKEY = GameLogic.Config.SceneConfig.keys()
						var _JOINTYPE: int = 0
						for _CHECKLEVEL in _SCENEKEY:
							var _INFO = GameLogic.Config.SceneConfig[_CHECKLEVEL]
							if int(_INFO.LevelType) == _LEVELTYPE and int(_INFO.LevelID) == _LEVELID:
								if _LEVELKEY.has(_CHECKLEVEL):
									_CANSAVE = true
								break

		if _CANSAVE:

			var _LEVELNAME = SteamLogic.LevelDic.Level
			if GameLogic.Config.SceneConfig.has(_LEVELNAME):
				var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVELNAME]
				var _CHECKNUM: int = 0
				var _MONEY = SteamLogic.LevelDic.MoneyCHECK
				if _MONEY > 0:
					_CHECKNUM = int(round(_MONEY / GameLogic._MONEYCHECKMULT))

				if _CHECKNUM > SteamLogic.LevelDic.Coin:
					_CHECKNUM = SteamLogic.LevelDic.Coin
				if not GameLogic.Level_Data.has(_LEVELNAME):
					GameLogic.Level_Data[_LEVELNAME] = {
						"level_CustomerTotal": SteamLogic.LevelDic.Cup,
						"level_MoneyTotal": _CHECKNUM,

						"level_SellTotal": SteamLogic.LevelDic.Perfect + SteamLogic.LevelDic.Good + SteamLogic.LevelDic.Bad,
						"cur_Devil": 0,
						}
					FirstPassReward = int(_LEVELINFO.RewardList[0])
				else:
					if GameLogic.Level_Data[_LEVELNAME].has("level_CustomerTotal"):
						if SteamLogic.LevelDic.Cup > GameLogic.Level_Data[_LEVELNAME]["level_CustomerTotal"]:
							GameLogic.Level_Data[_LEVELNAME]["level_CustomerTotal"] = SteamLogic.LevelDic.Cup
					else:
						GameLogic.Level_Data[_LEVELNAME]["level_CustomerTotal"] = SteamLogic.LevelDic.Cup
					if GameLogic.Level_Data[_LEVELNAME].has("cur_Day"):
						if SteamLogic.LevelDic.Day > GameLogic.Level_Data[_LEVELNAME]["cur_Day"]:
							GameLogic.Level_Data[_LEVELNAME]["cur_Day"] = SteamLogic.LevelDic.Day
					else:
						GameLogic.Level_Data[_LEVELNAME]["cur_Day"] = SteamLogic.LevelDic.Day
					if _CHECKNUM > SteamLogic.LevelDic.Coin:
						_CHECKNUM = SteamLogic.LevelDic.Coin
					if _CHECKNUM > GameLogic.Level_Data[_LEVELNAME]["level_MoneyTotal"]:
						GameLogic.Level_Data[_LEVELNAME]["level_MoneyTotal"] = _CHECKNUM
					if SteamLogic.LevelDic.Cup > GameLogic.Level_Data[_LEVELNAME]["level_SellTotal"]:
						GameLogic.Level_Data[_LEVELNAME]["level_SellTotal"] = SteamLogic.LevelDic.Cup
					if GameLogic.Level_Data[_LEVELNAME].has("cur_Devil"):
						if int(SteamLogic.LevelDic.Devil) > int(GameLogic.Level_Data[_LEVELNAME]["cur_Devil"]):
							GameLogic.Level_Data[_LEVELNAME]["cur_Devil"] += 1
							if _LEVELINFO.RewardList.size() > GameLogic.Level_Data[_LEVELNAME]["cur_Devil"]:
								FirstPassReward = int(_LEVELINFO.RewardList[GameLogic.Level_Data[_LEVELNAME]["cur_Devil"]])
					else:
						GameLogic.Level_Data[_LEVELNAME]["cur_Devil"] = 0
						FirstPassReward = int(_LEVELINFO.RewardList[0])

	if SteamLogic.LevelDic.Level:
		if SteamLogic.LevelDic.SPECIALLEVEL_Int < 5:
			if int(HomeMoneyValueLabel.text) > 0:
				GameLogic.call_MoneyHomeChange(int(HomeMoneyValueLabel.text), GameLogic.HomeMoneyKey)

	else:
		if int(HomeMoneyValueLabel.text) > 0:
			GameLogic.call_MoneyHomeChange(int(HomeMoneyValueLabel.text), GameLogic.HomeMoneyKey)


	if SteamLogic.IsJoin and SteamLogic.LevelDic.Level:

		if SteamLogic.LevelDic.SPECIALLEVEL_Int < 5:

			var _CHECKNUM: int = 0
			var _MONEY = SteamLogic.LevelDic.MoneyCHECK
			if _MONEY > 0:
				_CHECKNUM = int(round(_MONEY / GameLogic._MONEYCHECKMULT))

			if _CHECKNUM > SteamLogic.LevelDic.Coin:
				_CHECKNUM = SteamLogic.LevelDic.Coin
			GameLogic.Save.gameData["cur_HOMEMONEY"] = GameLogic.cur_HOMEMONEY
			GameLogic.Save.gameData["cur_money_home"] = GameLogic.cur_money_home
			GameLogic.Save.call_Statistics_Check()
			GameLogic.call_StatisticsData_Set("Count_Day", null, SteamLogic.LevelDic.Day)

			GameLogic.call_StatisticsData_Set("Count_Money", null, _CHECKNUM)


			GameLogic.call_StatisticsData_Set("Count_SellCup", null, SteamLogic.LevelDic.Cup)

			if SteamLogic.LevelDic.OpenGift > GameLogic.Save.statisticsData["Max_OpenGift"] and not GameLogic.CHEATINGBOOL:
				GameLogic.Save.statisticsData["Max_OpenGift"] = SteamLogic.LevelDic.OpenGift


			if SteamLogic.LevelDic.IsFinish:
				GameLogic.call_StatisticsData_Set("Count_NetVictories", null, 1)

		SteamLogic.LevelDic_Init()
		GameLogic.Save.call_save_puppet()
		GameLogic.call_NewLevel_Init()
		if SteamLogic.IsMultiplay:
			GameLogic.call_LevelFinished_puppet()
			SteamLogic.call_NeedData()
		else:
			if not SteamLogic.LOBBY_IsMaster:
				GameLogic.call_load_puppet()
				GameLogic.call_load()
	else:
		SteamLogic.LevelDic_Init()
		GameLogic.cur_EggList.clear()

		GameLogic.call_save()

	GameLogic.CHEATINGBOOL = false
	GameLogic.SPECIAL_NUM = 0
	GameLogic.SPECIALLEVEL_Int = 0

	Ani.play("init")
	cur_show = false

	GameLogic.GameUI.PanelAni.play("hide")

	GameLogic.call_reset_pressure()
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Player2_bool:
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

	GameLogic.call_SYNC()
	if get_tree().is_paused():
		get_tree().set_pause(false)
		GameLogic.GameUI.call_esc(0)
	EndAccountNode.queue_free()
	EndAccountNode = null
	_INIT_BOOL = false

	yield(get_tree().create_timer(0.1), "timeout")
	GameLogic.Can_ESC = true
	call_Can_Move(true)
	yield(get_tree().create_timer(0.4), "timeout")
	if not GameLogic.CHEATINGBOOL:
		GameLogic.call_TimeCheck()

func call_up():
	var _FocusOwner = get_focus_owner()
	if not _FocusOwner:
		return
	var _CurType = _FocusOwner.get_parent().get_parent().name

	if _CurType in ["CardUI", "RewardUI"]:
		if CurChoose.get_node("Challenge/Grid").get_child_count():
			CurChoose.get_node("Challenge/Grid").get_child(0).grab_focus()
		elif CurChoose.get_node("Reward/Grid").get_child_count():
			CurChoose.get_node("Reward/Grid").get_child(0).grab_focus()
	if _CurType == "Challenge":
		if CurChoose.get_node("Reward/Grid").get_child_count():
			CurChoose.get_node("Reward/Grid").get_child(0).grab_focus()
func call_down():
	var _FocusOwner = get_focus_owner()
	if not _FocusOwner:
		return
	var _CurType = _FocusOwner.get_parent().get_parent().name
	if _CurType == "Reward":
		if CurChoose.get_node("Challenge/Grid").get_child_count():
			CurChoose.get_node("Challenge/Grid").get_child(0).grab_focus()
		else:
			get_focus_owner().pressed = false
			CurChoose.call_ShowInfo_Hide()
			if has_node("Control/ScrollButHBox/1"):
				get_node("Control/ScrollButHBox/1").grab_focus()
			elif has_node("Control/Select/1"):
				get_node("Control/Select/1").grab_focus()
	if _CurType == "Challenge":
		get_focus_owner().pressed = false
		CurChoose.call_ShowInfo_Hide()
		if has_node("Control/ScrollButHBox/1"):
			get_node("Control/ScrollButHBox/1").grab_focus()
		elif has_node("Control/Select/1"):
				get_node("Control/Select/1").grab_focus()

func call_triggerItemDrop():
	if not GameLogic.CHEATINGBOOL:

		SteamLogic.call_TriggerItemDrop()
