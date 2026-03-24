extends CanvasLayer

var cur_UI = CUI.ESC
enum CUI{
	ESC
	OPTION
}

var cur_pressed: bool
var cur_paused: bool
var _paused: bool

var DayEnd: bool

export var TrafficMax = 50
var cur_Traffic: float
var PV_Max: float
var PV_Passer: float
var PV_Customer: float
var PPTime_Array = [12, 18, 19, 20]

var cur_OrderID = 1

var weather
enum WEATHER{
	CLOUD,
	SUN,
	RAIN,
	RAINSTORM,
	SNOW,
	BLIZZARD,
	FOG,
}
var temperature

var CurTime: float = 10
var _time: int
var _butType: String
var Order_SellCount: int
var money: int setget money_set

onready var TimePointer = get_node("RightUp/Timer/Pointer")
onready var _Timer = get_node("Timer")
onready var _passerTimer = get_node("passerTimer")
onready var _customerTimer = get_node("customerTimer")

onready var _RightInfoNode = $RightUp / InfoNode
onready var _moneyNode = _RightInfoNode.get_node("money/MoneyLabel")
onready var MoneyPlusLabel = _RightInfoNode.get_node("money/MoneyLabel/MoneyPlus")
onready var MoneyPlusAni = _RightInfoNode.get_node("money/MoneyLabel/MoneyPlusAni")
onready var _HomeMoneyNode = _RightInfoNode.get_node("money/HomeMoneyLabel")
onready var HomeMoneyPlusLabel = _HomeMoneyNode.get_node("MoneyPlus")
onready var HomeMoneyAni = _HomeMoneyNode.get_node("MoneyPlusAni")

onready var _EggCoinNode = _RightInfoNode.get_node("money/EggCoin")
onready var EggCoinPlusLabel = _EggCoinNode.get_node("MoneyPlus")
onready var EggCoinAni = _EggCoinNode.get_node("MoneyPlusAni")

onready var _DevilCoinNode = _RightInfoNode.get_node("money/DevilCoin")
onready var _OrderCoinNode = _RightInfoNode.get_node("money/OrderCoin")

onready var OrderNode = get_node("RightUp/OrderNode")
onready var OrderButNode = OrderNode.get_node("OrderScrollCon/OrderButCon")
onready var OrderAni = OrderNode.get_node("OrderAni")

onready var _SellCountLabel = get_node("RightUp/OrderNode/CountSell/MoneyLabel")

onready var OrderBox = get_node("OrderBoxCon")
onready var DayLabel = get_node("RightUp/DayInfo/BG/DayLabel")

onready var BuyButton = get_node("RightUp/BuyButton")

onready var LButton = OrderNode.get_node("L")
onready var RButton = OrderNode.get_node("R")
onready var CurSelect
onready var CurButGroup

onready var _But_TSCN = preload("res://TscnAndGd/UI/InGame/Order_Button.tscn")
onready var _ButGroup = preload("res://TscnAndGd/Buttons/OrderButton_buttongroup.tres")
onready var UIAni = get_node("UIAni")
onready var DayEndUI

onready var OpenCloseTypeAni = get_node("RightUp/Timer/OpenClose/TypeAni")
onready var OpenCloseAni = get_node("RightUp/Timer/OpenClose/Ani")
var Is_Open: bool
onready var OpenTimeLabel = get_node("RightUp/Timer/OpenClose/TimeTip/OpenTime")
onready var CloseTimeLabel = get_node("RightUp/Timer/OpenClose/TimeTip/CloseTime")

onready var Combo = get_node("Combo")
onready var Popularity = get_node("Popularity")

onready var GameEndUI
onready var SaveUIAni = get_node("SaveUI/AutoSave/ShowAni")
onready var EscAni = get_node("MainMenu/Ani")
onready var WarningAni = get_node("RightUp/Timer/Warning/WarningAni")

onready var MainMenu = get_node("MainMenu")
onready var InfoLabel = get_node("InfoLabel")

onready var OptionNode
onready var PanelAni = get_node("Panel/Ani")
onready var KeySettingNode

onready var ResumeBut = get_node("MainMenu/VBoxContainer/ResumeBut")

onready var StaffInfo = get_node("Left/StaffInfo")
onready var CloseProgress = get_node("RightUp/Timer/Base/CloseProgress")
onready var OverTimeProgress = get_node("RightUp/Timer/Base/OverTimeProgress")
onready var Tutorial_Devil = get_node("Tutorial_Devil")
onready var Tutorial_UI = get_node("Tutorial_1")
signal TimeChange()

var cur_RushHour: float
var cur_BlackOut: float
var MenuUIShow: bool

func _Ani_Init():
	WarningAni.play("init")
	OpenCloseAni.play("init")
func call_DevilLogic(_Switch: bool):
	Tutorial_Devil.call_Switch(_Switch)
func call_PanelAni(_Switch: bool):
	match _Switch:
		true:
			if PanelAni.assigned_animation != "show":
				PanelAni.play("show")
		false:
			if PanelAni.assigned_animation != "hide":
				PanelAni.play("hide")
func _DayClosedCheck():
	_Timer.stop()
	_passerTimer.stop()
	_customerTimer.stop()

func _ready() -> void :
	call_deferred("GameUI_Init")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("Reward", self, "set_CloseProgress"):
		var _CON = GameLogic.connect("Reward", self, "set_CloseProgress")


	$HomeInfo.hide()
	call_NewMail_init()
func call_OverTime_Audio_Switch(_Switch: bool):
	match _Switch:
		true:
			get_node("RightUp/Timer/Warning/Audio").play()
		false:
			get_node("RightUp/Timer/Warning/Audio").stop()

func call_DayEnd_Close():

	if DayEndUI.has_method("call_UI_End"):
		DayEndUI.call_UI_End()
func GameUI_Init():
	if not SteamLogic.is_connected("NewMail", self, "_NewMail_Show"):
		var _CON = SteamLogic.connect("NewMail", self, "_NewMail_Show")

	if GameLogic.DEMO_bool:
		$RightUp / InfoNode / money / VERSION.text = "DEMO" + GameLogic.Save.VERSION + GameLogic.Save.LASTVER
	else:
		$RightUp / InfoNode / money / VERSION.text = GameLogic.Save.VERSION + GameLogic.Save.LASTVER
	_Timer.wait_time = 1






	var _DAYENDTSCN = load("res://TscnAndGd/UI/InGame/DayEndUI.tscn")
	var _DayEndUINode = _DAYENDTSCN.instance()
	self.add_child(_DayEndUINode)
	DayEndUI = _DayEndUINode
	_DAYENDTSCN = null

	var _GAMEENDTSCN = load("res://TscnAndGd/UI/InGame/NEWGameEndUI.tscn")
	var _GameEndUINode = _GAMEENDTSCN.instance()
	self.add_child(_GameEndUINode)
	GameEndUI = _GameEndUINode
	_GAMEENDTSCN = null

	var _TSCN = load("res://TscnAndGd/UI/Main/KeySettings.tscn")
	var _KeySettingNode = _TSCN.instance()
	self.add_child(_KeySettingNode)
	KeySettingNode = _KeySettingNode


	_TSCN = load("res://TscnAndGd/UI/Main/Options.tscn")
	var _OptionNode = _TSCN.instance()
	self.add_child(_OptionNode)
	OptionNode = _OptionNode
	_TSCN = null







func call_esc_logic():


	if EscAni.assigned_animation != "show":
		if is_instance_valid(GameLogic.player_1P):
			GameLogic.player_1P.call_control(1)
		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.connect("P1_Control", self, "_control_logic")
		if GameLogic.player_2P:
			if is_instance_valid(GameLogic.player_2P):
				GameLogic.player_2P.call_control(1)
			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.connect("P2_Control", self, "_control_logic")
	else:
		GameLogic.player_1P.call_control(0)
		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if GameLogic.player_2P:
			GameLogic.player_2P.call_control(0)
			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	MainMenu.call_esc_logic()

func call_ResumeBut_grabfocus():
	ResumeBut.grab_focus()
func call_OptionsBut_grabfocus():
	ResumeBut.grab_focus()

func _control_logic(_but, _value, _type):

	if _value < 1 and _value > - 1:
		cur_pressed = false
	match _but:
		"B":
			match cur_UI:
				CUI.ESC:
					pass
				CUI.OPTION:
					pass
			pass
		"A":
			var _input = InputEventAction.new()
			_input.action = "ui_accept"
			if _value == 1:
				_input.pressed = true
				Input.parse_input_event(_input)
				cur_pressed = true
			elif _value == 0:
				_input.pressed = false
				Input.parse_input_event(_input)
				cur_pressed = false
		"U":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"D":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"L":
			match cur_UI:
				CUI.OPTION:
					var _OptionButArray = OptionNode.OptionListNode.get_children()
					for i in _OptionButArray.size():
						var _But = _OptionButArray[i]
						if _But.has_focus():

							if _But.has_node("L"):
								var _But_L = _But.get_node("L")
								_But_L.pressed()
								break
		"R":
			match cur_UI:
				CUI.OPTION:
					var _OptionButArray = OptionNode.OptionListNode.get_children()
					for i in _OptionButArray.size():
						var _But = _OptionButArray[i]
						if _But.has_focus():

							if _But.has_node("R"):
								var _But_L = _But.get_node("R")
								_But_L.pressed()
								break
		"u":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"d":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"l":
			pass
		"r":
			pass
	if _type == 0 or _value == 0:
		cur_pressed = false
var _ESCCHECK: bool = false
func call_esc(_value):

	var _C = GameLogic.Can_ESC

	if not GameLogic.Can_ESC:

		return

	if get_tree().get_root().has_node("1_4"):
		if _value == 1 or _value == - 1:
			if not MainMenu._paused and MainMenu.EscAni.current_animation != "hide":

				cur_pressed = true
				if not GameLogic.LoadingUI.Is_Loading:
					MainMenu.call_esc_logic()
	if not is_instance_valid(GameLogic.player_1P):
		return

	if OrderNode.cur_used:
		return
	if GameLogic.LoadingUI.IsLevel and MenuUIShow == true:
		return
	if _value == 1 or _value == - 1:
		if not MainMenu._paused and not MainMenu.EscAni.current_animation in ["hide"]:

			cur_pressed = true
			if not GameLogic.LoadingUI.Is_Loading:
				MainMenu.call_esc_logic()
				GameLogic.player_1P.call_SetPause(true)
				if GameLogic.Player2_bool:
					if is_instance_valid(GameLogic.player_2P):
						GameLogic.player_2P.call_SetPause(true)
	if _value == 0:

		if MainMenu.EscAni.current_animation in ["hide", "init"]:
			cur_pressed = false
			GameLogic.player_1P.call_SetPause(false)
			if GameLogic.Player2_bool:
				if is_instance_valid(GameLogic.player_2P):
					GameLogic.player_2P.call_SetPause(false)

func call_DayEndLogic():
	_Ani_Init()
	var _Order_Array = OrderBox.get_children()
	for i in _Order_Array.size():
		var _node = _Order_Array[i]
		_node.get_parent().remove_child(_node)
		_node.queue_free()
	Popularity.call_hide()

func call_DayEndUI_switch(_switch):
	if _switch:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			pass
		else:

			DayEndUI.call_DayEnd()
		DayEnd = true
		Is_Open = false
		if OrderAni.get_assigned_animation() == "show":
			OrderAni.play("hide")
	else:

		DayEndUI.call_UI_End()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_DayEndUI_switch", [_switch])
func call_MainUI():

	$InfoLabel.call_del()
	UIAni.play("init")
	_Ani_Init()
	_Timer.stop()
	_passerTimer.stop()
	_customerTimer.stop()
	call_UI_init()
func call_UI_init():

	DayEndUI.call_init()
	$RewardUI.call_init()
	$Tutorial_1.call_init()
	SteamLogic.JOIN.call_init()
	call_PanelAni(false)
	call_JoinInfo( - 1)
func call_HomeInfo():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		var _NAME: String = ""
		if SteamLogic.STEAM_BOOL:
			_NAME = Steam.getFriendPersonaName(SteamLogic.MasterID)
		else:
			_NAME = OnlineNetwork.get_member_name(SteamLogic.MasterID)
		$HomeInfo / Label.text = _NAME + " " + GameLogic.CardTrans.get_message("信息-的家")
		$HomeInfo.show()
		$HomeInfo / AnimationPlayer.play("Home")
	else:
		call_DEMOINFO()
func call_DEMOINFO():
	if SteamLogic.INIT_ID == 2336220:
		if GameLogic.DEMO_bool:
			match SteamLogic._INIT_TYPE:

				3:
					$HomeInfo / Label.text = GameLogic.CardTrans.get_message("网络-Steam版本旧")
				_:
					$HomeInfo / Label.text = GameLogic.CardTrans.get_message("网络-启动DEMO")
			$HomeInfo.show()
			$HomeInfo / AnimationPlayer.play("Fail")
		else:
			$HomeInfo.hide()
	else:
		$HomeInfo.hide()
func call_InHome():
	if has_node("Test"):
		$Test.call_hide()
	Order_SellCount = 0
	var _DAY: int = GameLogic.cur_Day
	var _SPECIALNUM: int = GameLogic.SPECIALLEVEL_Int

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		_SPECIALNUM = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if _SPECIALNUM:
		DayLabel.text = "SPECIAL"
	else:
		DayLabel.text = "Day " + str(_DAY)

	UIAni.play("InHome")
	call_UI_init()

	MainMenu.call_init()
	_Timer.stop()
	_passerTimer.stop()
	_customerTimer.stop()

	_info_Init()
	GameLogic.Tutorial.call_Check_Level2()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		var _NAME: String = ""
		if SteamLogic.STEAM_BOOL:
			_NAME = Steam.getFriendPersonaName(SteamLogic.MasterID)
		else:
			_NAME = OnlineNetwork.get_member_name(SteamLogic.MasterID)
		$HomeInfo / Label.text = _NAME + " " + GameLogic.CardTrans.get_message("信息-的家")
		$HomeInfo / AnimationPlayer.play("Home")
		$HomeInfo.show()
	else:
		$HomeInfo.hide()
func call_init():
	if has_node("Test"):

		$Test.call_show()

	GameLogic._dayinfo_init()
	_Ani_Init()

	Is_Open = false
	var _SPECIALNUM: int = GameLogic.SPECIALLEVEL_Int
	var _PlayerNUM = SteamLogic.PlayerNum

	var _CLOSETIME: float = GameLogic.cur_CloseTime
	var _OPENTIME: float = GameLogic.cur_OpenTime
	var _LEVELINFO = GameLogic.cur_levelInfo
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_LEVELINFO = SteamLogic.LevelDic.cur_levelInfo
		_SPECIALNUM = SteamLogic.LevelDic.SPECIALLEVEL_Int
		_PlayerNUM = SteamLogic.LevelDic["PlayerNum"]
		_CLOSETIME = float(_LEVELINFO.CloseTime)
		_OPENTIME = float(_LEVELINFO.OpenTime)
	if _SPECIALNUM:
		DayLabel.text = "SPECIAL"
	else:
		DayLabel.text = "Day " + str(GameLogic.cur_Day)
	var _open = str(int((_OPENTIME - floor(_OPENTIME)) * 60))


	if _open == "0":
		_open = "00"

	OpenTimeLabel.text = str(int(_OPENTIME)) + ":" + _open

	var _close = str(int((_CLOSETIME - floor(_CLOSETIME)) * 60))
	if _close == "0":
		_close = "00"
	CloseTimeLabel.text = str(int(_CLOSETIME)) + ":" + _close

	var _EarlyTime: float = GameLogic.cur_EarlyTime

	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day in [1, 2]:
			_EarlyTime -= 0.5
	else:


		if _LEVELINFO.GamePlay.has("开关店一刻钟"):
			_EarlyTime += 0.25
		if _LEVELINFO.GamePlay.has("开关店半小时"):
			_EarlyTime += 0.5
		if _LEVELINFO.GamePlay.has("开关店一小时"):
			_EarlyTime += 1
		if not _SPECIALNUM:
			if GameLogic.Achievement.cur_EquipList.has("提前到店"):
				_EarlyTime += 0.5
			if GameLogic.Save.gameData.HomeDevList.has("钟"):
				_EarlyTime += 0.125
			if GameLogic.Save.gameData.HomeDevList.has("床头桌"):
				_EarlyTime += 0.125
			if GameLogic.Save.gameData.HomeDevList.has("壁炉"):
				_EarlyTime += 0.125
			if GameLogic.Save.gameData.HomeDevList.has("洗手池"):
				_EarlyTime += 0.125
		if GameLogic.cur_Rewards.has("提前上班"):
			_EarlyTime += 0.5
		elif GameLogic.cur_Rewards.has("提前上班+"):
			_EarlyTime += 1
		if GameLogic.cur_Challenge.has("不想上班"):
			_EarlyTime -= 0.25
		if GameLogic.cur_Challenge.has("不想上班+"):
			_EarlyTime -= 0.5
		if _SPECIALNUM:
			match _PlayerNUM:
				1, 0:
					_EarlyTime = float(_LEVELINFO.SPECIAL_1)
				2, - 2:
					_EarlyTime = float(_LEVELINFO.SPECIAL_2)
				3:
					_EarlyTime = float(_LEVELINFO.SPECIAL_3)
				4:
					_EarlyTime = float(_LEVELINFO.SPECIAL_4)

	CurTime = float(_OPENTIME) - _EarlyTime
	_TIMECHECK = 0
	emit_signal("TimeChange")
	UIAni.play("InGame")
	$HomeInfo.hide()
	MainMenu.call_init()
	set_Pointer()
	_curTraffic_set()
	_info_Init()

	if _passerTimer.is_stopped():
		_passerTimer.start()
	if GameLogic.curLevelList.has("难度-每日随机高峰期"):

		var _NUM = int((_CLOSETIME - 1) - _OPENTIME)
		if _NUM > 0:
			cur_RushHour = _OPENTIME + GameLogic.return_randi() % _NUM
		else:
			cur_RushHour = _OPENTIME

func _info_Init():
	if not GameLogic.is_connected("MoneyChange", self, "call_money_change"):
		var _con = GameLogic.connect("MoneyChange", self, "call_money_change")
	if not GameLogic.is_connected("MoneyHomeChange", self, "call_homemoney_change"):
		var _con = GameLogic.connect("MoneyHomeChange", self, "call_homemoney_change")
	if not GameLogic.is_connected("EggCoinChange", self, "call_EggCoin_change"):
		var _con = GameLogic.connect("EggCoinChange", self, "call_EggCoin_change")
	if not GameLogic.is_connected("DevilCoinChange", self, "call_devilcoin_change"):
		var _con = GameLogic.connect("DevilCoinChange", self, "call_devilcoin_change")


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		if GameLogic.cur_ReDrawCoin == 0:
			_DevilCoinNode.hide()
		else:
			_DevilCoinNode.show()
		_moneyNode.text = str(GameLogic.cur_money)

	_HomeMoneyNode.text = str(GameLogic.return_FullHMK())

	_EggCoinNode.hide()
	_DevilCoinNode.text = str(GameLogic.cur_ReDrawCoin)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_ReDraw_puppet", [GameLogic.cur_ReDrawCoin])

	call_CostumeCoin_change()

	if not SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		_HomeMoneyNode.hide()
	else:
		_HomeMoneyNode.show()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_EggCoinNode.hide()
	sellCount_ShowLogic()
	_on_OrderTypeButton_toggled(true)
func call_ReDraw_puppet(_REDRAW):
	GameLogic.cur_ReDrawCoin = _REDRAW
	_DevilCoinNode.text = str(GameLogic.cur_ReDrawCoin)
	if GameLogic.cur_ReDrawCoin == 0:
		_DevilCoinNode.hide()
	else:
		_DevilCoinNode.show()
func sellCount_ShowLogic():

	if Order_SellCount <= 0:
		Order_SellCount = 0
		_OrderCoinNode.hide()
	else:
		_OrderCoinNode.show()
	_SellCountLabel.text = str(Order_SellCount)
	_OrderCoinNode.text = "-" + str(Order_SellCount)

func call_curTraffic_set():


	var _PVLEVEL_LIST = [12, 15, 18, 21, 24, 27, 30, 33, 36, 39]
	var _PVLEVEL = GameLogic.cur_PV
	var _MULTINT: int = 0

	if _PVLEVEL > 10:
		_PVLEVEL = 10

	var _DevilMult: float = 1
	match GameLogic.cur_Devil:
		0:
			_DevilMult = 0.8
		1:
			_DevilMult = 0.9
		4:
			_DevilMult = 1
	var _PVNUM: float = _PVLEVEL_LIST[(_PVLEVEL - 1)] * GameLogic.return_Multiplier() * _DevilMult
	PV_Max = _PVNUM / 100

func _curTraffic_set():

	if GameLogic.Traffic_Array.size() >= int(CurTime):
		cur_Traffic = float(GameLogic.Traffic_Array[int(CurTime)])
	else:
		cur_Traffic = 50
	var _LEVELINFO = GameLogic.cur_levelInfo



	call_curTraffic_set()

	if GameLogic.cur_Rewards.has("开店客流"):
		if CurTime < GameLogic.cur_OpenTime and Is_Open:
			cur_Traffic += 30
	if GameLogic.cur_Rewards.has("开店客流+") and Is_Open:
		if CurTime < GameLogic.cur_OpenTime:
			cur_Traffic = 100

	if GameLogic.cur_Rewards.has("闭店客流"):
		if CurTime >= GameLogic.cur_CloseTime - 1.5 and CurTime <= GameLogic.cur_CloseTime:
			cur_Traffic += 30
	if GameLogic.cur_Rewards.has("闭店客流+"):
		if CurTime >= GameLogic.cur_CloseTime - 1.5 and CurTime <= GameLogic.cur_CloseTime:
			cur_Traffic = 100
	if GameLogic.curLevelList.has("难度-每日随机高峰期"):

		if CurTime >= cur_RushHour and CurTime <= (cur_RushHour + 1):
			cur_Traffic = 100
	if GameLogic.curLevelList.has("难度-每日随机停电") or _LEVELINFO.GamePlay.has("难度-每日随机停电"):

		if not GameLogic.IsBlackOut:
			if cur_BlackOut == 0:
				var _NUM: float = ((GameLogic.cur_CloseTime - 0.5) - GameLogic.cur_OpenTime)
				if _NUM > 0:
					cur_BlackOut = GameLogic.cur_OpenTime + float(GameLogic.return_randi() % int(_NUM * 10)) / 10

		var _BLACKOUTTIME = GameLogic.BlackOutTime
		if GameLogic.cur_Challenge.has("间歇停电"):
			_BLACKOUTTIME += 0.5
		if GameLogic.cur_Challenge.has("间歇停电+"):
			_BLACKOUTTIME += 1
		if cur_BlackOut != 0 and CurTime >= cur_BlackOut and CurTime < cur_BlackOut + 0.1 and not GameLogic.IsBlackOut:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(GameLogic, "call_BlackOut")
			GameLogic.call_BlackOut()
			if GameLogic.cur_Challenge.has("间歇停电"):
				GameLogic.call_Info(2, "间歇停电")
			if GameLogic.cur_Challenge.has("间歇停电+"):
				GameLogic.call_Info(2, "间歇停电+")
		elif cur_BlackOut != 0 and CurTime > cur_BlackOut + _BLACKOUTTIME and CurTime < cur_BlackOut + _BLACKOUTTIME + 0.1 and GameLogic.IsBlackOut:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(GameLogic, "call_BlackOut_Over")
			GameLogic.call_BlackOut_Over()
	elif GameLogic.cur_Challenge.has("间歇停电") or GameLogic.cur_Challenge.has("间歇停电+"):

		if not GameLogic.IsBlackOut:
			if cur_BlackOut == 0:
				var _NUM: float = ((GameLogic.cur_CloseTime - 0.5) - GameLogic.cur_OpenTime)
				if _NUM > 0:
					cur_BlackOut = GameLogic.cur_OpenTime + float(GameLogic.return_randi() % int(_NUM * 10)) / 10
		var _BLACKOUTTIME: float = 0
		if GameLogic.cur_Challenge.has("间歇停电"):
			_BLACKOUTTIME += 0.5
		if GameLogic.cur_Challenge.has("间歇停电+"):
			_BLACKOUTTIME += 1
		if cur_BlackOut != 0 and CurTime >= cur_BlackOut and CurTime < cur_BlackOut + 0.1 and not GameLogic.IsBlackOut:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(GameLogic, "call_BlackOut")
			GameLogic.call_BlackOut()
			if GameLogic.cur_Challenge.has("间歇停电"):
				GameLogic.call_Info(2, "间歇停电")
			if GameLogic.cur_Challenge.has("间歇停电+"):
				GameLogic.call_Info(2, "间歇停电+")
		elif cur_BlackOut != 0 and CurTime > cur_BlackOut + _BLACKOUTTIME and CurTime < cur_BlackOut + _BLACKOUTTIME + 0.1 and GameLogic.IsBlackOut:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(GameLogic, "call_BlackOut_Over")
			GameLogic.call_BlackOut_Over()

	if GameLogic.cur_Challenge.has("冷清"):
		PV_Max = PV_Max * 0.9
	if GameLogic.cur_Challenge.has("冷清+"):
		PV_Max = PV_Max * 0.8


	if GameLogic.cur_Event == "开店长队":

		if CurTime >= GameLogic.cur_OpenTime - 0.1 and CurTime <= GameLogic.cur_OpenTime + 1:
			cur_Traffic = 150

	if GameLogic.cur_Event == "关店长队":

		if CurTime >= GameLogic.cur_CloseTime - 1.5 and CurTime <= GameLogic.cur_CloseTime:
			cur_Traffic = 150

	if GameLogic.Achievement.cur_EquipList.has("顾客加速") and not GameLogic.SPECIALLEVEL_Int:
		if CurTime < GameLogic.cur_OpenTime and Is_Open:
			cur_Traffic += int(float(cur_Traffic) * 0.5)
	if GameLogic.Achievement.cur_EquipList.has("礼物增加") and not GameLogic.SPECIALLEVEL_Int:
		if CurTime >= GameLogic.cur_OpenTime and Is_Open:
			cur_Traffic += int(float(cur_Traffic) * 0.1)
	PV_Customer = float(float(PV_Max) * (float(GameLogic.cur_Day + 31) / 100))




	if PV_Customer > PV_Max:
		PV_Customer = PV_Max
	PV_Passer = PV_Max - PV_Customer

func set_Pointer():
	TimePointer.rotation_degrees = CurTime * 30

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:

		_Timer.start()
	set_CloseProgress()
func set_CloseProgress():
	if GameLogic.LoadingUI.IsLevel:
		var _LEVELINFO = GameLogic.cur_levelInfo
		var _SPECIALNUM: int = GameLogic.SPECIALLEVEL_Int
		var _CLOSETIME: float = GameLogic.cur_CloseTime
		var _OPENTIME: float = GameLogic.cur_OpenTime
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

			_SPECIALNUM = SteamLogic.LevelDic.SPECIALLEVEL_Int
			if _SPECIALNUM:
				_CLOSETIME = float(_LEVELINFO.CloseTime)
				_OPENTIME = float(_LEVELINFO.OpenTime)
		var _RunTime = _CLOSETIME - _OPENTIME
		CloseProgress.value = _RunTime * 30
		var _RadialTime = _OPENTIME * 30
		if _RadialTime > 360:
			_RadialTime -= 360
		CloseProgress.radial_initial_angle = _RadialTime
		var _OverTime: float = 1

		if GameLogic.Achievement.cur_EquipList.has("夜班延长") and not _SPECIALNUM:
			_OverTime += 0.5
		if _LEVELINFO.GamePlay.has("开关店一刻钟"):
			_OverTime += 0.25
		if _LEVELINFO.GamePlay.has("开关店半小时"):
			_OverTime += 0.5
		if _LEVELINFO.GamePlay.has("开关店一小时"):
			_OverTime += 1
		if GameLogic.cur_Rewards.has("值夜班"):
			_OverTime += 1
		elif GameLogic.cur_Rewards.has("值夜班+"):
			_OverTime += 2
		if GameLogic.cur_Challenge.has("快点下班"):
			_OverTime -= 0.25
		if GameLogic.cur_Challenge.has("快点下班+"):
			_OverTime -= 0.5
		if _SPECIALNUM:
			if CurTime < _OPENTIME:
				CloseProgress.value = 0
				CloseProgress.radial_initial_angle = 0
				OverTimeProgress.value = (_OPENTIME - CurTime) * 30
				OverTimeProgress.radial_initial_angle = CurTime * 30
			elif CurTime < _CLOSETIME:
				CloseProgress.value = (_CLOSETIME - _OPENTIME) * 30
				CloseProgress.radial_initial_angle = _OPENTIME * 30
				OverTimeProgress.value = 0
				OverTimeProgress.radial_initial_angle = 0
			else:
				CloseProgress.value = 0
				CloseProgress.radial_initial_angle = 0
				OverTimeProgress.value = _OverTime * 30
				OverTimeProgress.radial_initial_angle = _CLOSETIME * 30
		else:


			OverTimeProgress.value = _OverTime * 30
			OverTimeProgress.radial_initial_angle = _CLOSETIME * 30

		if GameLogic.cur_Challenge.has("间歇停电") or GameLogic.cur_Challenge.has("间歇停电+"):
			var _NUM: float = ((_CLOSETIME - 0.5) - _OPENTIME)
			if _NUM > 0:
				cur_BlackOut = _OPENTIME + float(GameLogic.return_randi() % int(_NUM * 10)) / 10
			else:
				cur_BlackOut = _OPENTIME
	else:
		CloseProgress.value = 0
		OverTimeProgress.value = 0

func _Timer_Set():


	if Is_Open:
		if CurTime > GameLogic.cur_CloseTime:

			if TrafficMax > 0 and cur_Traffic > 0:
				_passerTimer.wait_time = float(TrafficMax) / float(cur_Traffic) / PV_Max
			get_tree().call_group("Customers", "call_leaving_night")
			if WarningAni.assigned_animation == "Fever":
				WarningAni.play("FeverOver")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["FeverOver"])
		else:
			if PV_Passer == 0:
				PV_Passer = 1
			if TrafficMax > 0 and cur_Traffic > 0:
				_passerTimer.wait_time = float(TrafficMax) / float(cur_Traffic) / PV_Passer
				_customerTimer.wait_time = float(TrafficMax) / float(cur_Traffic) / PV_Customer

			if cur_Traffic >= 100 and WarningAni.assigned_animation != "Fever":
				WarningAni.play("Fever")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["Fever"])
			elif cur_Traffic < 100 and WarningAni.assigned_animation == "Fever":
				WarningAni.play("FeverOver")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["FeverOver"])
	else:
		if CurTime >= GameLogic.cur_OpenTime and CurTime <= GameLogic.cur_CloseTime:

			if PV_Passer == 0:
				PV_Passer = 1
			if TrafficMax > 0 and cur_Traffic > 0:
				_passerTimer.wait_time = float(TrafficMax) / float(cur_Traffic) / PV_Passer
				_customerTimer.wait_time = float(TrafficMax) / float(cur_Traffic) / PV_Customer
			if cur_Traffic >= 100 and WarningAni.assigned_animation != "Fever":
				WarningAni.play("Fever")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["Fever"])
			elif cur_Traffic < 100 and WarningAni.assigned_animation == "Fever":
				WarningAni.play("FeverOver")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["FeverOver"])
			print("顾客 Max：", TrafficMax, " cur:", cur_Traffic, " PV Pass:", PV_Passer, " PV_Cust:", PV_Customer)
		else:
			if TrafficMax > 0 and cur_Traffic > 0:
				_passerTimer.wait_time = float(TrafficMax) / float(cur_Traffic) / PV_Max
			if WarningAni.assigned_animation == "Fever":
				WarningAni.play("FeverOver")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["FeverOver"])
			if CurTime > GameLogic.cur_CloseTime:
				get_tree().call_group("Customers", "call_leaving_night")

func call_WariningAni_Puppet(_NAME: String):

	if WarningAni.assigned_animation != _NAME:
		WarningAni.play(_NAME)
func call_OpenCloseAni_Puppet(_NAME: String, _TYPE):

	if _TYPE != null:
		if OpenCloseTypeAni.assigned_animation != _TYPE:
			OpenCloseTypeAni.play(_TYPE)
	if OpenCloseAni.assigned_animation != _NAME:
		OpenCloseAni.play(_NAME)
	if _NAME == "closed":
		GameLogic.Audio.call_speedup()
func call_Open_Puppet():
	var _audio = GameLogic.Audio.return_Effect("提示上课铃")
	_audio.play(0)
	Is_Open = true
	OpenCloseAni.play("hide")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_OpenCloseAni_Puppet", ["hide", null])
func call_Open():
	if Is_Open:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Open_Puppet")
	var _audio = GameLogic.Audio.return_Effect("提示上课铃")
	_audio.play(0)
	Is_Open = true
	_Timer_Set()
	if _customerTimer.is_stopped():
		_on_customerTimer_timeout()
		_customerTimer.start()
	OpenCloseAni.play("hide")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_OpenCloseAni_Puppet", ["hide", null])
	GameLogic.call_OpenStore()
	var _Combo_Start: int = 0
	if GameLogic.SPECIALLEVEL_Int:
		if GameLogic.cur_Rewards.has("永生花"):
			_Combo_Start += 100
		elif GameLogic.cur_Rewards.has("永生花+"):
			_Combo_Start += 200
		if GameLogic.curLevelList.has("难度-快速出杯"):
			GameLogic.cur_Quick = 50
			GameLogic.cur_Quickly = 50
			GameLogic.level_Quickly = 50
		if GameLogic.curLevelList.has("难度-极限出杯"):
			GameLogic.cur_Nearly = 50
			GameLogic.level_Nearly = 50
		if GameLogic.curLevelList.has("难度-跳单出杯"):
			GameLogic.Day_JustJump = 50
			GameLogic.cur_Skipping = 50
			GameLogic.level_Skipping = 50
		if GameLogic.curLevelList.has("难度-暴击出杯"):
			GameLogic.cur_Cri = 50
			GameLogic.level_Cri = 50
			GameLogic.Day_JustCri = 50


	if GameLogic.cur_Rewards.has("气球+"):
		_Combo_Start += 50

	if GameLogic.Achievement.cur_EquipList.has("初始连击") and not GameLogic.SPECIALLEVEL_Int:
		_Combo_Start += 3
	if _Combo_Start > 0:
		GameLogic.call_combo(_Combo_Start)
	if GameLogic.cur_Rewards.has("兔耳发卡"):
		GameLogic.call_Info(1, "兔耳发卡")
		var _POPULAR: float = (GameLogic.cur_OpenTime - GameLogic.GameUI.CurTime) * 100 * GameLogic.return_Multiplayer()
		GameLogic.return_Popular(_POPULAR, GameLogic.HomeMoneyKey)
	elif GameLogic.cur_Rewards.has("兔耳发卡+"):
		GameLogic.call_Info(1, "兔耳发卡+")
		var _POPULAR: float = (GameLogic.cur_OpenTime - GameLogic.GameUI.CurTime) * 300 * GameLogic.return_Multiplayer()
		GameLogic.return_Popular(_POPULAR, GameLogic.HomeMoneyKey)

var _OverTimeChance: int = 0
var cur_OverTime: float
var _TIMECHECK: int = 0
func _on_Timer_timeout() -> void :

	var _LEVELINFO = GameLogic.cur_levelInfo
	var _SPECIALNUM: int = GameLogic.SPECIALLEVEL_Int
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		_SPECIALNUM = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 1:
			GameLogic.Buy.call_check(CurTime)
			if not Is_Open:
				GameLogic.Buy.call_check(CurTime)
				return
			if GameLogic.cur_SellNum != 2:
				if CurTime > GameLogic.cur_CloseTime - 0.1:
					return


	CurTime += 0.02
	_TIMECHECK += 1
	GameLogic.Buy.call_check(CurTime)


	if _TIMECHECK >= 5:
		_TIMECHECK = 0
	else:
		return



	if not Is_Open:
		if CurTime < GameLogic.cur_OpenTime:
			if OpenCloseAni.assigned_animation != "show":
				OpenCloseTypeAni.play("open")
				OpenCloseAni.play("show")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_OpenCloseAni_Puppet", ["show", "open"])
		else:

			if OpenCloseAni.assigned_animation == "show":
				call_Open()
	else:

		if CurTime >= (GameLogic.cur_CloseTime - 0.5) and OpenCloseAni.assigned_animation != "show":
			OpenCloseTypeAni.play("close")
			OpenCloseAni.play("show")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_OpenCloseAni_Puppet", ["show", "close"])
		elif CurTime >= GameLogic.cur_CloseTime:

			Is_Open = false
			OpenCloseAni.play("closed")
			GameLogic.Audio.call_speedup()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_OpenCloseAni_Puppet", ["closed", null])
			GameLogic.Tutorial.call_closed()






	var _OverTime: float = 1
	if GameLogic.Achievement.cur_EquipList.has("夜班延长") and not _SPECIALNUM:
		_OverTime += 0.5
	if _LEVELINFO.GamePlay.has("开关店一刻钟"):
			_OverTime += 0.25
	if _LEVELINFO.GamePlay.has("开关店半小时"):
		_OverTime += 0.5
	if _LEVELINFO.GamePlay.has("开关店一小时"):
		_OverTime += 1
	if GameLogic.cur_Rewards.has("值夜班"):
		_OverTime += 1
	elif GameLogic.cur_Rewards.has("值夜班+"):
		_OverTime += 2
	if GameLogic.cur_Challenge.has("快点下班"):
			_OverTime -= 0.25
	if GameLogic.cur_Challenge.has("快点下班+"):
		_OverTime -= 0.5
	cur_OverTime = GameLogic.cur_CloseTime + _OverTime
	if CurTime > cur_OverTime:
		if GameLogic.cur_Rewards.has("加班洗脑"):

			if _OverTimeChance > 1:
				_OverTimeChance = 0
				GameLogic.call_pressure("Night")
			else:
				_OverTimeChance += 1

		elif GameLogic.cur_Rewards.has("加班洗脑+"):

			if _OverTimeChance > 3:
				_OverTimeChance = 0
				GameLogic.call_pressure("Night")
			else:
				_OverTimeChance += 1

		else:
			GameLogic.call_pressure("Night")


		CurTime = cur_OverTime
		if WarningAni.assigned_animation != "OverTime":
			WarningAni.play("OverTime")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_WariningAni_Puppet", ["OverTime"])



	else:



		TimePointer.rotation_degrees += 3

		emit_signal("TimeChange")

		_time += 1
		if _time >= 10:
			_time = 0
		_curTraffic_set()


		var _Pressure: int = 0
		var _Hour: float = floor(CurTime)
		var _Minute: int = int((CurTime - _Hour) * 10)

		if GameLogic.cur_Rewards.has("耳罩") and not _Minute and CurTime < GameLogic.GameUI.cur_OverTime:
			GameLogic.call_Info(1, "耳罩")
			_Pressure -= 1
		if GameLogic.cur_Rewards.has("耳罩+") and not _Minute and CurTime < GameLogic.GameUI.cur_OverTime:
			GameLogic.call_Info(1, "耳罩+")
			_Pressure -= 3



		if GameLogic.cur_Challenge.has("倍感压力") and not _Minute and CurTime <= GameLogic.cur_CloseTime and Is_Open:
			var _rand = GameLogic.return_randi() % 2

			if _rand == 1:
				_Pressure += 1
				GameLogic.call_Info(2, "倍感压力")

		if GameLogic.cur_Challenge.has("倍感压力+") and not _Minute and CurTime <= GameLogic.cur_CloseTime and Is_Open:
			GameLogic.call_Info(2, "倍感压力+")
			_Pressure += 1
		if _LEVELINFO.GamePlay.has("难度-小偷") or GameLogic.curLevelList.has("难度-小偷"):
			if not _Minute and CurTime <= GameLogic.cur_CloseTime:
				GameLogic.NPC.call_thief(GameLogic.HomeMoneyKey)


		if GameLogic.cur_Challenge.has("COMBO减少") and not _Minute and CurTime <= GameLogic.cur_CloseTime and Is_Open:

			GameLogic.call_Info(2, "COMBO减少")
			GameLogic.call_combo( - 1)
		if GameLogic.cur_Challenge.has("COMBO减少+") and _Minute in [0, 5] and CurTime <= GameLogic.cur_CloseTime and Is_Open:

			GameLogic.call_Info(2, "COMBO减少+")
			GameLogic.call_combo( - 1)
		if GameLogic.cur_Event == "调整" and not _Minute and CurTime < GameLogic.GameUI.cur_OverTime:
			_Pressure -= 1
		if GameLogic.cur_Event == "调整+" and _Minute in [0, 5] and CurTime < GameLogic.GameUI.cur_OverTime:
			_Pressure -= 1
		if GameLogic.cur_Event == "调整++" and _Minute in [0, 5] and CurTime < GameLogic.GameUI.cur_OverTime:
			_Pressure -= 2

		if _Pressure != 0:
			GameLogic.call_Pressure_Set(_Pressure)

	if _SPECIALNUM:
		set_CloseProgress()
	_Timer_Set()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_Puppet_Time", [TimePointer.rotation_degrees, CurTime])
func _Puppet_Time(_DEGREES, _TIME):
	TimePointer.rotation_degrees = _DEGREES
	CurTime = _TIME

	emit_signal("TimeChange")
	set_CloseProgress()

func _on_passerTimer_timeout() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NPCNUM = GameLogic.NPC.return_NPCNUM()
	if _NPCNUM < 50:
		GameLogic.NPC.call_passer(GameLogic.HomeMoneyKey)

func _on_customerTimer_timeout() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if Is_Open:

		if GameLogic.cur_Day == 1:
			if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
				return

		var _NPCNUM = GameLogic.NPC.return_NPCNUM()
		if _NPCNUM < 100:

			call_Customer_Logic()

func call_Customer_Logic():

	if GameLogic.cur_levelInfo.GamePlay.has("难度-混混") or GameLogic.curLevelList.has("难度-混混"):
		if GameLogic.cur_level == "社区店2" and GameLogic.cur_Day == 1 and GameLogic.cur_Devil == 0:
			GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)
			return

		if GameLogic.NPC.ThugNum < 0:
			GameLogic.NPC.call_Thug_rand()

		if GameLogic.NPC.ThugNum == 0:
			GameLogic.NPC.call_Thug(GameLogic.HomeMoneyKey)
			GameLogic.NPC.call_Thug_rand()
			return
		else:
			GameLogic.NPC.ThugNum -= 1

	if GameLogic.cur_levelInfo.GamePlay.has("难度-各种顾客") or GameLogic.curLevelList.has("难度-各种顾客"):
		var _Rand = GameLogic.return_randi() % 10
		match _Rand:

			2:
				GameLogic.NPC.call_Uper(GameLogic.HomeMoneyKey)
			3:
				GameLogic.NPC.call_Homeless(GameLogic.HomeMoneyKey)
			4:
				GameLogic.NPC.call_Cupmother(GameLogic.HomeMoneyKey)
			5:
				GameLogic.NPC.call_Critic(GameLogic.HomeMoneyKey)
			6:
				GameLogic.NPC.call_Studyholics(GameLogic.HomeMoneyKey)
			7:
				GameLogic.NPC.call_Thug(GameLogic.HomeMoneyKey)
			_:
				GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)
		return
	if GameLogic.cur_levelInfo.GamePlay.has("难度-玻璃瓶") or GameLogic.curLevelList.has("难度-玻璃瓶"):
		var _Rand = GameLogic.return_randi() % 3
		if _Rand == 0:
			GameLogic.NPC.call_GlassBottle(GameLogic.HomeMoneyKey)
			return
	if GameLogic.cur_levelInfo.GamePlay.has("难度-探店客") or GameLogic.curLevelList.has("难度-探店客"):
		var _Rand = GameLogic.return_randi() % 5
		if _Rand == 0:
			GameLogic.NPC.call_Uper(GameLogic.HomeMoneyKey)
			return
	if GameLogic.cur_levelInfo.GamePlay.has("难度-流浪杯") or GameLogic.curLevelList.has("难度-流浪杯"):

		var _Rand = GameLogic.return_randi() % 3

		if _Rand == 0:
			GameLogic.NPC.call_Homeless(GameLogic.HomeMoneyKey)

	if GameLogic.cur_levelInfo.GamePlay.has("难度-插队客") or GameLogic.curLevelList.has("难度-插队客"):

		var _Rand = GameLogic.return_randi() % 6

		if _Rand == 0:
			GameLogic.NPC.call_Cupmother(GameLogic.HomeMoneyKey)
			return
	if GameLogic.cur_levelInfo.GamePlay.has("难度-批评家") or GameLogic.curLevelList.has("难度-批评家"):

		var _Rand = GameLogic.return_randi() % 5

		if _Rand == 0:
			GameLogic.NPC.call_Critic(GameLogic.HomeMoneyKey)
			return
	if GameLogic.cur_levelInfo.GamePlay.has("难度-学咖族") or GameLogic.curLevelList.has("难度-学咖族"):

		if CurTime < GameLogic.cur_OpenTime + 0.5:
			if GameLogic.NPC.StudyHolics < 0:
				GameLogic.NPC.call_StudyHolics_rand()
			if GameLogic.NPC.StudyHolics == 0:
				GameLogic.NPC.call_Studyholics(GameLogic.HomeMoneyKey)
				GameLogic.NPC.call_StudyHolics_rand()
				return
			else:
				GameLogic.NPC.StudyHolics -= 1

	GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)

func _on_OrderNode_L_pressed() -> void :
	var Order_ButArray = OrderNode.get_node("HBoxContainer/1").group.get_buttons()
	CurSelect = OrderNode.get_node("HBoxContainer/1").group.get_pressed_button()

	if CurSelect == Order_ButArray.front():
		var _but = Order_ButArray.back()
		_but.set_pressed(true)
	else:
		var _key = int(CurSelect.name)
		var _but = Order_ButArray[_key - 2]
		_but.set_pressed(true)
func _on_OrderNode_R_pressed() -> void :
	var Order_ButArray = OrderNode.get_node("HBoxContainer/1").group.get_buttons()
	CurSelect = OrderNode.get_node("HBoxContainer/1").group.get_pressed_button()

	if CurSelect == Order_ButArray.back():
		var _but = Order_ButArray.front()
		_but.set_pressed(true)
	else:
		var _key = int(CurSelect.name)
		var _but = Order_ButArray[_key]
		_but.set_pressed(true)

func _del_all_OrderButton():
	Order_SellCount = 0

	var _child_array = OrderButNode.get_children()
	for i in _child_array.size():
		var _but = _child_array[i]
		var _butPar = _but.get_parent()
		_butPar.remove_child(_but)
		_but.queue_free()

func _add_OrderButton(_SellType):
	var _Sell_Array: Array
	match _SellType:
		"Sell_1":
			_Sell_Array = GameLogic.Buy.Sell_1
		"Sell_2":
			_Sell_Array = GameLogic.Buy.Sell_2
		"Sell_3":
			_Sell_Array = GameLogic.Buy.Sell_3
		"Sell_4":
			_Sell_Array = GameLogic.Buy.Sell_4

	for i in _Sell_Array.size():
		var _objName = _Sell_Array[i]
		var _but = _But_TSCN.instance()
		_but.name = str(OrderButNode.get_child_count())
		OrderButNode.add_child(_but)

		if i == 0:
			CurButGroup = _ButGroup
			_but.set_pressed(true)
			_but.grab_focus()
		_but.set_button_group(CurButGroup)

		_but.cur_type = _objName

		_but.get_node("IconNode/IconAni").play(_objName)
		if GameLogic.Config.ItemConfig.has(_objName):
			_but.cur_sell = GameLogic.Config.ItemConfig[_objName]["Sell"]
	_set_OrderBut_focus()

func _set_OrderBut_focus():




	var _but_Array = OrderButNode.get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		var _butpath = _but.get_path()
		if _but_Array.size() > 1:
			if i == 0:
				_but.set_focus_neighbour(MARGIN_TOP, _butpath)
			else:
				var _upbut = _but_Array[i - 1]
				var _upbutpath = _upbut.get_path()
				_but.set_focus_neighbour(MARGIN_TOP, _upbutpath)
			if i == _but_Array.size() - 1:
				_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
			else:
				var _nextbut = _but_Array[i + 1]
				var _nextbutpath = _nextbut.get_path()
				_but.set_focus_neighbour(MARGIN_BOTTOM, _nextbutpath)
		else:
			_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
		_but.set_focus_neighbour(MARGIN_LEFT, _butpath)
		_but.set_focus_neighbour(MARGIN_RIGHT, _butpath)

func _on_OrderTypeButton_toggled(button_pressed: bool) -> void :
	if button_pressed:
		CurSelect = OrderNode.get_node("HBoxContainer/Sell_1").group.get_pressed_button()
		if _butType != CurSelect.editor_description:
			_butType = CurSelect.editor_description
			_del_all_OrderButton()
			_add_OrderButton(_butType)

func _on_BuyButton_toggled(button_pressed: bool) -> void :

	if DayEnd:
		return
	match button_pressed:
		true:
			OrderAni.play("show")
			OrderNode.call_init()

		false:
			OrderAni.play("hide")

func _on_OrderApply_pressed() -> void :

	if not Order_SellCount:
		return


func _on_Buy_pressed() -> void :
	if money > Order_SellCount:

		money -= Order_SellCount
		GameLogic.Cost_Buy += Order_SellCount

		_money_save()


		_call_buy_Logic()



		_butType = ""
		_on_OrderTypeButton_toggled(true)

		BuyButton.pressed = false

func _call_buy_Logic():
	var _Order: Array
	var _but_array = OrderButNode.get_children()
	var _objinfo: Dictionary
	for i in _but_array.size():
		var _but = _but_array[i]
		if _but.cur_num > 0:
			_objinfo[_but.cur_type] = _but.cur_num
	_Order.append(_objinfo)
	GameLogic.Buy.call_new_buy(_Order, 1)

func call_money_change(_Num):

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

func call_CostumeCoin_change(_Num: int = 0):

	if SteamLogic._EQUIPDIC.has(20001):
		var _INFO = SteamLogic._EQUIPDIC[20001]
		$RightUp / InfoNode / money / CostumeCoin.text = str(_INFO.Num)
		if int(_INFO.Num) <= 0 and GameLogic.LoadingUI.IsLevel:
			$RightUp / InfoNode / money / CostumeCoin.hide()
		else:
			$RightUp / InfoNode / money / CostumeCoin.show()
	else:
		$RightUp / InfoNode / money / CostumeCoin.hide()
func call_homemoney_change(_Num):

	HomeMoneyPlusLabel.text = str(_Num)
	if HomeMoneyAni.is_playing():
		HomeMoneyAni.stop(true)
	if _Num > 0:
		HomeMoneyAni.play("plus")
	elif _Num < 0:
		HomeMoneyAni.play("reduce")
	_HomeMoneyNode.text = str(GameLogic.return_FullHMK())

func call_EggCoin_change(_Num):
	EggCoinPlusLabel.text = str(_Num)
	if EggCoinAni.is_playing():
		EggCoinAni.stop(true)
	if _Num > 0:
		EggCoinAni.play("plus")
	elif _Num < 0:
		EggCoinAni.play("reduce")

	_EggCoinNode.hide()
func call_devilcoin_change():


	_DevilCoinNode.text = str(GameLogic.cur_ReDrawCoin)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_change_puppet", [GameLogic.cur_ReDrawCoin])

func call_change_puppet(_RECOIN):
	GameLogic.cur_ReDrawCoin = _RECOIN
	_DevilCoinNode.text = str(GameLogic.cur_ReDrawCoin)
func _money_save():
	GameLogic.Save.gameData["money"] = money
	_moneyNode.text = str(money)

func money_set(_value):
	var _oldmoney = money
	money = _value
	if _oldmoney > money:

		pass
	else:

		pass

var _LEVELCHECKINT: int = 0
func call_JoinInfo(_TYPE: int):
	if GameLogic.LoadingUI.IsLevel and _TYPE >= 0:
		call_JoinInfo( - 1)
		return
	if SteamLogic.LOBBY_IsMaster or not SteamLogic.IsMultiplay:
		if GameLogic.LoadingUI.IsHome and GameLogic.cur_level != "":
			$JoinInfo / AnimationPlayer.play("Can")
			call_Master_set()
			return
	match _TYPE:
		- 1:
			$JoinInfo / AnimationPlayer.play("init")
			call_JoinInfo_init()
		0:
			$JoinInfo / AnimationPlayer.play("Can")
			_LEVELCHECKINT = 0
			call_JoinInfo_set()

		1:
			$JoinInfo / AnimationPlayer.play("Can")
			_LEVELCHECKINT = 1
			call_JoinInfo_set()

		2:
			$JoinInfo / AnimationPlayer.play("No")
			_LEVELCHECKINT = 2
			call_JoinInfo_set()

		3:
			$JoinInfo / AnimationPlayer.play("Day")
			_LEVELCHECKINT = 3
			call_JoinInfo_set()
func call_Master_set():
	var _LEVEL = GameLogic.cur_level
	var _Devil = GameLogic.cur_Devil
	$JoinInfo / Info / Devil.text = str(int(_Devil) + 1)
	var _SPECIALNUM: int = GameLogic.SPECIALLEVEL_Int
	var _DAY = GameLogic.cur_Day
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		_SPECIALNUM = SteamLogic.LevelDic.SPECIALLEVEL_Int
		_DAY = SteamLogic.LevelDic.Day
	if _SPECIALNUM:
		$JoinInfo / Info / Day.text = "SPECIAL"
	else:
		$JoinInfo / Info / Day.text = "DAY " + str(_DAY + 1)
	call_LevelInfo_set(_LEVEL)
func call_JoinInfo_set():
	var _LEVEL = ""
	var _Devil = "0"
	var _DAY = "0"
	if SteamLogic.STEAM_BOOL:
		_LEVEL = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Level")
		_Devil = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Devil")
		_DAY = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Day")
	else:
		_LEVEL = GameLogic.cur_level
		_Devil = str(GameLogic.cur_Day)
		_DAY = str(GameLogic.cur_Day)
	var _SPECIALNUM: int = GameLogic.SPECIALLEVEL_Int

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		_SPECIALNUM = SteamLogic.LevelDic.SPECIALLEVEL_Int

	if _SPECIALNUM:
		$JoinInfo / Info / Day.text = "SPECIAL"
	else:
		$JoinInfo / Info / Day.text = "DAY " + str(int(_DAY) + 1)

	$JoinInfo / Info / Devil.text = str(int(_Devil) + 1)
	call_LevelInfo_set(_LEVEL)

func call_LevelInfo_set(_LEVEL):
	if GameLogic.Config.SceneConfig.has(_LEVEL):
		var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVEL]
		var _TYPE = _LEVELINFO.LevelType
		var _ID = _LEVELINFO.LevelID
		$JoinInfo / Info / Level.text = str(_TYPE) + "-" + str(_ID)

func call_JoinInfo_init():
	var _VBOX = $JoinInfo / VBox
	for _NODE in _VBOX.get_children():
		_NODE.call_init()
var _TIMESTOPBOOL: bool
func call_TimeStop(_Bool: bool, _KEY: int = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	GameLogic.CHEATINGBOOL = true
	_TIMESTOPBOOL = _Bool


	match _TIMESTOPBOOL:
		true:
			_Timer.set_paused(true)
		false:
			_Timer.set_paused(false)

func call_Check(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if GameLogic.CHEATINGBOOL:
		return
	if not _TIMESTOPBOOL:
		_Timer.set_paused(false)

var _MAILTIME: int = 3600
var _CHANCE: int = 0

func _on_MailTimer_timeout():

	_CHANCE += 1
	if _CHANCE > 60:
		_CHANCE = 0
		call_NewMail()

func call_NewMail():
	if not SteamLogic.STEAM_BOOL:
		return
	var result = Steam.triggerItemDrop(54001)
	if result:

		while true:
			var status = Steam.getResultStatus(result)
			if status != 22:

				Steam.destroyResult(result)

				break
			yield(get_tree().create_timer(0.5), "timeout")

func call_NewMail_init():

	if SteamLogic.MAILNUM > 0:
		GameLogic.cur_MAILNUM = SteamLogic.MAILNUM
		$RightUp / InfoNode / money / NewMail / AnimationPlayer.play("init")
	else:
		$RightUp / InfoNode / money / NewMail / AnimationPlayer.play("hide")
	$RightUp / InfoNode / money / NewMail / Label.text = str(GameLogic.cur_MAILNUM)
func _NewMail_Show(_SHOWBOOL: bool):
	var _SHOWNUM: int = SteamLogic.MAILNUM
	if _SHOWNUM > 99:
		_SHOWNUM = 99
	$RightUp / InfoNode / money / NewMail / Label.text = str(_SHOWNUM)

	if SteamLogic.MAILNUM > 0:

		if _SHOWBOOL:
			$RightUp / InfoNode / money / NewMail.show()
			if SteamLogic.MAILNUM > GameLogic.cur_MAILNUM:
				GameLogic.cur_MAILNUM = SteamLogic.MAILNUM
				$RightUp / InfoNode / money / NewMail / AnimationPlayer.play("show")
		else:

			$RightUp / InfoNode / money / NewMail.show()

	else:
		$RightUp / InfoNode / money / NewMail / AnimationPlayer.play("hide")
