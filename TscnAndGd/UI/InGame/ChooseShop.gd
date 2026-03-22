extends Control
var _pressed: bool
var Can_Press: bool = true
var show_bool: bool
var cur_pressed: bool
var LoadLevel_bool: bool
var cur_Press: String
var Type: int = 0 setget _Level_Array_init
signal LevelSelect

var Customer_Dic: Dictionary
var WaterType_Array: Array
var cur_Select: String
var Level_Rank1: String
var Level_Rank2: String
var Level_Rank3: String
var Level_Rank4: String
var _Level_Path = "res://TscnAndGd/Main/Level/"
var _check = ERR_FILE_EOF
var cur_Devil: int
var Devil_Max: int
var Devil_Finished: int
var DevilList: Array
var TrafficNum: int

onready var LevelNameLabel = get_node("Control/BG/LevelName/Label")
onready var CostMoneyLabel = get_node("Control/InfoBG/BaseInfo1/CostMoney/Label")
onready var DailyRentLabel = get_node("Control/InfoBG/BaseInfo1/DailyRent/Label")
onready var DayCountLabel = get_node("Control/InfoBG/BaseInfo1/DayCount/Label")

onready var RewardLabel = $Control / InfoBG / BaseInfo1 / Reward / Label
onready var RewardMaxLabel = $Control / InfoBG / BaseInfo2 / RewardMax / Label
onready var RewardGetLabel = $Control / InfoBG / BaseInfo2 / RewardGet / Label
onready var RewardGet = $Control / InfoBG / BaseInfo2 / RewardGet
onready var PopularLabel = get_node("Control/InfoBG/BaseInfo1/Popular")
onready var OpeningHoursLabel = get_node("Control/InfoBG/BaseInfo2/OpeningHours/Label")
onready var TrafficLabel = get_node("Control/InfoBG/BaseInfo2/Traffic/Label")
onready var PeakTimeLabel = get_node("Control/InfoBG/BaseInfo2/PeakTime/Label")
onready var CustomerNode = get_node("Control/InfoBG/Customer/HBox")
onready var WaterTypeNode = get_node("Control/InfoBG/BaseInfo1/Sell/HBox")
onready var DifficultyBut = get_node("Control/Difficulty/HBoxContainer/1")
onready var DifficultyNode = get_node("Control/Difficulty/HBoxContainer")

onready var Ani = get_node("Control/Ani")
onready var view = get_node("Control/ViewportBG/ViewportContainer/Viewport")
var LevelNode
var LevelCamera
onready var MapUI = get_parent().get_node("Map")

onready var BackBut = get_node("Control/ButControl/BackBut")
onready var ApplyBut = get_node("Control/ButControl/ApplyBut")
onready var A_But = ApplyBut.get_node("A")

onready var LButton = get_node("Control/Difficulty/L")
onready var RButton = get_node("Control/Difficulty/R")
onready var TutorialAni = get_node("DevilDialogue/Ani")

var loader
var item_count: int
var now_count: int

export var LOCKTYPE: int = 7

func _ready() -> void :
	set_process(false)
	A_But.connect("HoldFinish", self, "_Apply_Logic")
	if has_node("Control/DemoLabel"):
		get_node("Control/DemoLabel").hide()

func _But_Logic():
	var _PressBut = DifficultyBut.group.get_pressed_button()
	var _L = LButton.get_node("L")
	var _R = RButton.get_node("R")
	if int(_PressBut.name) <= 1:
		LButton.disabled = true
		_L.call_disabled(true)
	else:
		LButton.disabled = false
		_L.call_disabled(false)
	if int(_PressBut.name) >= 4:
		RButton.disabled = true
		_R.call_disabled(true)
	else:
		var _nextBut = str(int(_PressBut.name) + 1)
		if DifficultyNode.get_node(_nextBut).disabled:
			RButton.disabled = true
			_R.call_disabled(true)
		else:
			RButton.disabled = false
			_R.call_disabled(false)

func _Level_Check():
	print("关卡选择：", Level_Rank1, Level_Rank2)
	DifficultyNode.get_node("1").call_unlock(true)
	if GameLogic.Level_Data.has(Level_Rank1):

		DifficultyNode.get_node("1").call_check(Level_Rank1)
		DifficultyNode.get_node("2").call_unlock(true)
	else:

		DifficultyNode.get_node("2").call_unlock(false)
	if GameLogic.Level_Data.has(Level_Rank2):
		DifficultyNode.get_node("2").call_check(Level_Rank2)
		DifficultyNode.get_node("3").call_unlock(true)

	else:
		DifficultyNode.get_node("2").call_check(Level_Rank2)
		DifficultyNode.get_node("3").call_unlock(false)
	if GameLogic.Level_Data.has(Level_Rank3):
		DifficultyNode.get_node("3").call_check(Level_Rank3)
		DifficultyNode.get_node("4").call_unlock(true)
	else:
		DifficultyNode.get_node("3").call_check(Level_Rank3)
		DifficultyNode.get_node("4").call_unlock(false)
	if GameLogic.Level_Data.has(Level_Rank4):
		DifficultyNode.get_node("4").call_check(Level_Rank4)
	else:
		DifficultyNode.get_node("4").call_check(Level_Rank4)
	DifficultyNode.get_node("1").pressed = true
	cur_Press = DifficultyNode.get_node("1").name
	call_cur_level(cur_Press)



func call_show(_type):

	_Level_Array_init(_type)
	DifficultyBut.pressed = true

	Ani.play("show")
	call_cur_level("1")
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")
	show_bool = true

func call_cur_level(_select):
	match str(_select):
		"1":
			cur_Select = Level_Rank1

		"2":
			cur_Select = Level_Rank2

		"3":
			cur_Select = Level_Rank3
		"4":
			cur_Select = Level_Rank4

	if cur_Select in ["新手引导第一关"] and not GameLogic.Level_Data.has("社区店1") and GameLogic.Level_Data.has("新手引导第一关"):
		if TutorialAni.assigned_animation != "选择第二关":
			TutorialAni.play("选择第二关")
	elif cur_Select in ["新手引导第一关", "社区店2", "社区店3"] and GameLogic.Level_Data.has("社区店1"):
		if GameLogic.Level_Data["社区店1"].cur_Devil == 0:
			if TutorialAni.assigned_animation != "第二关可选难度":
				TutorialAni.play("第二关可选难度")
	elif cur_Select == "社区店1":
		TutorialAni.play("init")
		if GameLogic.Level_Data.has(cur_Select):
			if GameLogic.Level_Data[cur_Select].cur_Devil == 0:
				if TutorialAni.assigned_animation != "选择难度":
					TutorialAni.play("选择难度")

func _Level_Array_init(_type):

	Type = _type

	Level_Rank1 = ""
	Level_Rank2 = ""
	Level_Rank3 = ""
	Level_Rank4 = ""

	var _LevelKeys = GameLogic.Config.SceneConfig.keys()
	for i in _LevelKeys.size():
		if int(GameLogic.Config.SceneConfig[_LevelKeys[i]].LevelType) == Type:
			match int(GameLogic.Config.SceneConfig[_LevelKeys[i]].LevelID):
				1:
					Level_Rank1 = _LevelKeys[i]
				2:
					Level_Rank2 = _LevelKeys[i]
				3:
					Level_Rank3 = _LevelKeys[i]
				4:
					Level_Rank4 = _LevelKeys[i]
	print("Level_Rank2", Level_Rank2)
	_Level_Check()
	_on_Difficulty_pressed()



func call_Load_Logic():

	set_process(false)
	get_node("Timer").start(0)
func _process(_delta):
	if loader != null:
		ApplyBut.hide()
		now_count = loader.get_stage()


		_check = loader.poll()
		if _check == ERR_FILE_EOF:
			var _TSCN = loader.get_resource()

			var _TSCN_Instance = _TSCN.instance()
			_del_view()
			view.add_child(_TSCN_Instance)
			LevelCamera = _TSCN_Instance.get_node("CameraNode/Camera2D")


			LoadLevel_bool = false
			set_process(false)
			GameLogic.TSCNLoad.loader = loader

			if Can_Press:
				ApplyBut.show()
			else:
				ApplyBut.hide()
			_But_Logic()
		elif _check != OK:
			printerr("start loader check error:", _check, " loader:", loader.get_stage(), " count:", loader.get_stage_count())

func _del_view():
	var _viewArray = view.get_children()
	for i in _viewArray.size():
		var _Obj = _viewArray[i]
		_Obj.queue_free()
func _DevilList():

	var _i: int = 0
	DevilList.clear()
	for _Keys in GameLogic.Config.SceneConfig[cur_Select].DevilList:

		if cur_Devil > _i:
			DevilList.append(_Keys)
			_i += 1

func _on_Difficulty_pressed() -> void :

	_on_Apply_button_up()

	var _PressBut = DifficultyBut.group.get_pressed_button()

	if _PressBut:
		if _PressBut.name != "":
			if _PressBut.name != cur_Press:
				LoadLevel_bool = false
				cur_Press = _PressBut.name
				call_cur_level(cur_Press)
	GameLogic.Audio.But_EasyClick.play()
	_show_logic()
func _show_logic():


	call_init()

	if GameLogic.Config.SceneConfig.has(cur_Select):
		if GameLogic.Config.SceneConfig[cur_Select].DevilList.size() == 0:
			cur_Devil = 0
			Devil_Finished = 0
		elif GameLogic.Level_Data.has(cur_Select):
			var Info = GameLogic.Level_Data[cur_Select]
			if Info.has("cur_Devil"):

				if int(Info.cur_Devil) >= GameLogic.Config.SceneConfig[cur_Select].DevilList.size():
					Devil_Finished = int(Info.cur_Devil)
				else:
					Devil_Finished = int(Info.cur_Devil) + 1
				var _MAX = int(GameLogic.Config.SceneConfig[cur_Select].DevilMax) - 1
				if Devil_Finished > _MAX:
					Devil_Finished = _MAX
				cur_Devil = int(Devil_Finished)



			else:
				cur_Devil = 1
				Devil_Finished = 1
		else:



			cur_Devil = 0
			Devil_Finished = 0
		_DevilList()


	var _Effect = GameLogic.TSCNLoad.LoadingEffect.instance()
	view.add_child(_Effect)
	if GameLogic.Config.SceneConfig.has(cur_Select):
		_Effect.get_node("Ani").play("run")
	call_info_set()
	call_popular_set()

	call_customer_set()
	call_new_info()

	var _DEMO_Level: Array = ["3", "4"]
	if SteamLogic.TEST_FOR_PLAYER:
		_DEMO_Level = ["4"]
		LOCKTYPE = 3



	if GameLogic.DEMO_bool:
		if Type > 2 or cur_Press in _DEMO_Level:
			if has_node("Control/DemoLabel"):
				get_node("Control/DemoLabel").show()
				Can_Press = false
		else:
			if has_node("Control/DemoLabel"):
				get_node("Control/DemoLabel").hide()
				Can_Press = true
				A_But.show()
	else:
		if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:

			if SteamLogic.TEST_FOR_PLAYER:
				if Type >= LOCKTYPE or cur_Press in ["4"]:
					if has_node("Control/DemoLabel"):
						get_node("Control/DemoLabel").show()
					Can_Press = false
				elif has_node("Control/DemoLabel"):
					get_node("Control/DemoLabel").hide()
					Can_Press = true
			elif Type == LOCKTYPE and cur_Press in []:
				if has_node("Control/DemoLabel"):
					get_node("Control/DemoLabel").show()
				Can_Press = false
			elif has_node("Control/DemoLabel"):
				get_node("Control/DemoLabel").hide()
				Can_Press = true


		else:
			if has_node("Control/DemoLabel"):
				get_node("Control/DemoLabel").hide()
				Can_Press = true


	if not GameLogic.Config.SceneConfig.has(cur_Select):
		A_But.show()
		set_process(false)
		return
	LoadLevel_bool = true
	loader = GameLogic.TSCNLoad.loader
	var _SceneName = GameLogic.Config.SceneConfig[cur_Select].TSCN

	var _path = _Level_Path + _SceneName + ".tscn"
	var _checkbool = ResourceLoader.exists(_path)
	if not _checkbool:
		printerr("LoadingUI 错误，MainUILoad 地址不存在。")
		return
	if ResourceLoader.has_cached(_path):

		if GameLogic.TSCNLoad.loader != null:

			if GameLogic.TSCNLoad.loader.get_resource():
				var _TSCN = GameLogic.TSCNLoad.loader.get_resource()

				var _TSCN_Instance = _TSCN.instance()
				_del_view()
				view.add_child(_TSCN_Instance)
				LevelCamera = _TSCN_Instance.get_node("CameraNode/Camera2D")
				LoadLevel_bool = false
				_check = ERR_FILE_EOF
				return
	loader = ResourceLoader.load_interactive(_path)

	if loader != null:
		item_count = loader.get_stage_count()
		set_process(true)


func call_money_set():




	pass

func _popular_set(_Popular: int):


	var _StarList = PopularLabel.get_node("HBox").get_children()
	if _Popular <= 2:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i == 0:
				_Node.get_node("TextureProgress").value = _Popular
			else:
				_Node.get_node("TextureProgress").value = 0

	elif _Popular <= 4:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 1:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 1:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif _Popular <= 6:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 2:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 2:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif _Popular <= 8:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 3:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 3:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif _Popular <= 10:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 4:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 4:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
func call_info_set():

	if not cur_Select:
		LevelNameLabel.text = "-"
		CostMoneyLabel.text = "?"
		DailyRentLabel.text = "?"
		DayCountLabel.text = "?"
		RewardLabel.text = "?"
		RewardMaxLabel.text = "?"
		RewardGetLabel.text = "?"
		OpeningHoursLabel.text = "?"
		PeakTimeLabel.text = "?"
		$Control / InfoBG / BaseInfo2 / Traffic / Label / AnimationPlayer.play("-1")
		$Control / InfoBG / BaseInfo2 / PeakTime / Label / AnimationPlayer.play("0")
		get_node("Control/InfoBG/GamePlay/1").text = ""
		get_node("Control/InfoBG/GamePlay/2").text = ""
		get_node("Control/InfoBG/GamePlay/3").text = ""
		return

	var _LEVELINFO = GameLogic.Config.SceneConfig[cur_Select]
	LevelNameLabel.text = GameLogic.CardTrans.get_message(_LEVELINFO.Name)
	var _StartingFUNDS: int = int(_LEVELINFO.Funds)
	if cur_Devil == 0: _StartingFUNDS += 500
	CostMoneyLabel.text = str(_StartingFUNDS)

	DailyRentLabel.text = str(float(_LEVELINFO.Rent) * float(1 + cur_Devil))

	DayCountLabel.text = str(_LEVELINFO.Difficult.size())
	RewardLabel.text = str(float(_LEVELINFO.HomeMoneyMult) / 2) + "%" + "(" + _LEVELINFO.HomeMoneyMult + "%" + ")"
	var _MAX: String = _LEVELINFO.HomeMoneyMax
	RewardMaxLabel.text = _MAX + "(" + str(int(_MAX) * 2) + ")"
	var _RewardList = _LEVELINFO.RewardList
	RewardGet.hide()
	if GameLogic.Level_Data.has(cur_Select):
		if GameLogic.Level_Data[cur_Select].has("cur_Devil"):
			if int(cur_Devil) > int(GameLogic.Level_Data[cur_Select]["cur_Devil"]):
				RewardGetLabel.text = str(_RewardList[cur_Devil])
				RewardGet.show()
		else:
			RewardGetLabel.text = str(_RewardList[cur_Devil])
			RewardGet.show()
	else:
		RewardGetLabel.text = str(_RewardList[cur_Devil])
		RewardGet.show()




	var _Open = float(_LEVELINFO.OpenTime)
	var _Close = float(_LEVELINFO.CloseTime)
	var _OpenHour = str(int(_Open))
	var _CloseHour = str(int(_Close))
	var _Open_Min = int((_Open - floor(_Open)) * 60)
	var _Close_Min = int((_Close - floor(_Close)) * 60)
	if _Open_Min == 0:
		_Open_Min = "00"
	else:
		_Open_Min = str(_Open_Min)
	if _Close_Min == 0:
		_Close_Min = "00"
	else:
		_Close_Min = str(_Close_Min)
	OpeningHoursLabel.text = _OpenHour + ":" + _Open_Min + "~ " + _CloseHour + ":" + _Close_Min
	TrafficNum = int(_LEVELINFO.PV)

	PeakTimeLabel.text = GameLogic.CardTrans.get_message(_LEVELINFO.PeakTime)
	$Control / InfoBG / BaseInfo2 / PeakTime / Label / AnimationPlayer.play("0")
	get_node("Control/InfoBG/GamePlay/1").text = ""
	get_node("Control/InfoBG/GamePlay/2").text = ""
	get_node("Control/InfoBG/GamePlay/3").text = ""
	var _List = _LEVELINFO.GamePlay
	var _CurNUM: int = 1
	if not _List.has("新手引导1") and cur_Devil == 0:
		if get_node("Control/InfoBG/GamePlay").has_node(str(_CurNUM)):
			get_node("Control/InfoBG/GamePlay").get_node(str(_CurNUM)).text = GameLogic.CardTrans.get_message("新手保护")

			_CurNUM += 1
	for _i in _List.size():
		_CurNUM += _i
		if get_node("Control/InfoBG/GamePlay").has_node(str(_CurNUM)):
			get_node("Control/InfoBG/GamePlay").get_node(str(_CurNUM)).text = GameLogic.CardTrans.get_message(_List[_i])

	if cur_Devil >= 2:
		_CurNUM += 1
		if get_node("Control/InfoBG/GamePlay").has_node(str(_CurNUM)):
			get_node("Control/InfoBG/GamePlay").get_node(str(_CurNUM)).text = GameLogic.CardTrans.get_message("信息-不可保存进度")

func call_new_info():
	var _ComInfoNode = get_node("Control/通关信息")
	var _ChooseNode = get_node("Control/Choose")
	if not GameLogic.Config.SceneConfig.has(cur_Select):
		_ComInfoNode.hide()
		_ChooseNode.hide()
		return

	var _IsDevel: bool = false

	if GameLogic.Level_Data.has(cur_Select):
		_IsDevel = true


	match _IsDevel:
		true:
			_ComInfoNode.show()
			_ChooseNode.show()
			var Info = GameLogic.Level_Data[cur_Select]
			_ComInfoNode.get_node("BaseInfo1/HighMoney/Label").text = str(Info.level_MoneyTotal)
			_ComInfoNode.get_node("BaseInfo2/SellTotal/Label").text = str(Info.level_SellTotal)
			var _ComHBOX = _ComInfoNode.get_node("BaseInfo1/DevelLevel/HBox")
			for _Node in _ComHBOX.get_children():
				_Node.queue_free()

			Devil_Max = int(GameLogic.Config.SceneConfig[cur_Select].DevilMax)
			if Devil_Max < 1:
				Devil_Max = 1
				_ChooseNode.hide()
			for i in Devil_Max:
				var _DevilIcon = GameLogic.TSCNLoad.DevilIcon_TSCN.instance()
				_ComHBOX.add_child(_DevilIcon)
				if i <= int(Info.cur_Devil):
					_DevilIcon.get_node("Ani").play("show")



			var _HBox = get_node("Control/Choose/HBox")
			for _Node in _HBox.get_children():
				_HBox.remove_child(_Node)
				_Node.queue_free()
			for i in Devil_Max:
				var _DevilIcon = GameLogic.TSCNLoad.DevilIcon_TSCN.instance()
				_DevilIcon.name = str(i)
				_HBox.add_child(_DevilIcon)
				_HBox.move_child(_DevilIcon, 0)
				_DevilIcon.call_type(i)

				if i - 1 >= 0 and DevilList.size() > (i - 1):

					_DevilIcon.call_Str(DevilList[i - 1])
				if i <= Devil_Finished:
					_DevilIcon.get_node("Ani").play("select")
				else:
					_DevilIcon.get_node("Ani").play("lock")
		false:
			_ComInfoNode.hide()
			_ChooseNode.hide()
			Devil_Finished = 0
			var _HBox = get_node("Control/Choose/HBox")
			for _Node in _HBox.get_children():
				_HBox.remove_child(_Node)
				_Node.queue_free()
			for i in Devil_Max:
				var _DevilIcon = GameLogic.TSCNLoad.DevilIcon_TSCN.instance()
				_DevilIcon.name = str(i)
				_HBox.add_child(_DevilIcon)
				_HBox.move_child(_DevilIcon, 0)
				if i <= Devil_Finished:
					_DevilIcon.get_node("Ani").play("select")
				else:
					_DevilIcon.get_node("Ani").play("lock")
			cur_Devil = 0

func call_popular_set():
	if not GameLogic.Config.SceneConfig.has(cur_Select):
		_popular_set(0)
		return

	var _POPULAR: int = int(GameLogic.Config.SceneConfig[cur_Select].Popular)
	if DevilList.has("难度-初始星级加2"):
		_POPULAR += 2
	if DevilList.has("难度-初始星级加3"):
		_POPULAR += 3
	if DevilList.has("难度-初始星级加4"):
		_POPULAR += 4
	_popular_set(_POPULAR)
func call_watertype_set():
	WaterType_Array = GameLogic.Config.SceneConfig[cur_Select].DrinkTypeList
	for i in WaterType_Array.size():
		var _TypeName = WaterType_Array[i]
		var _ICONTSCN = GameLogic.TSCNLoad.WaterTypeEffect.instance()
		WaterTypeNode.add_child(_ICONTSCN)
		if _ICONTSCN.get_node("Ani").has_animation(_TypeName):
			_ICONTSCN.get_node("Ani").play(_TypeName)
func call_Traffic_set():
	TrafficNum += DevilList.size()

	if SteamLogic.IsMultiplay:
		match SteamLogic.PlayerNum:
			2:
				TrafficNum += 1
			3:
				TrafficNum += 2
			4:
				TrafficNum += 3
	elif GameLogic.Player2_bool:
		TrafficNum += 1

	if TrafficNum > 9:
		TrafficNum = 9
	if TrafficNum == 0:
		TrafficNum = 1
	var _TrafficText = "信息-客流" + str(TrafficNum)
	TrafficLabel.text = GameLogic.CardTrans.get_message(_TrafficText)
	TrafficLabel.get_node("AnimationPlayer").play(str(TrafficNum))
func call_customer_set():

	Customer_Dic.clear()
	if not GameLogic.Config.SceneConfig.has(cur_Select):
		$Control / InfoBG / BaseInfo2 / PeakTime / Label / AnimationPlayer.play("-1")
		return
	var _NUM: int = 0
	for _Keys in GameLogic.Config.SceneConfig[cur_Select].CustomersList:
		Customer_Dic[_NUM] = {"ID": "0", "TYPE": _Keys}

		_NUM += 1

	if DevilList.has("难度-每日随机高峰期"):
		PeakTimeLabel.text = GameLogic.CardTrans.get_message("信息-每日1小时高峰")
		$Control / InfoBG / BaseInfo2 / PeakTime / Label / AnimationPlayer.play("1")

	if DevilList.has("难度-新增鲜柠汁M"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "MarkCup":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "MarkCup"}

	if DevilList.has("难度-小变中"):
		var _CHECK: bool
		for _KEY in Customer_Dic.keys():
			if Customer_Dic[_KEY].TYPE in "LittleCup":
				if Customer_Dic.has(_KEY):
					var _RE = Customer_Dic.erase(_KEY)
			elif Customer_Dic[_KEY].TYPE in "MarkCup":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic["MarkCup" + str(Customer_Dic.size())] = {"ID": "0", "TYPE": "MarkCup"}

	if DevilList.has("难度-大瓶顾客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "BigBottle":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "BigBottle"}

	if DevilList.has("难度-玻璃瓶顾客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "GlassBottle":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "GlassBottle"}

	if DevilList.has("难度-英式茶杯顾客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "BritishCup":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "BritishCup"}

	if DevilList.has("难度-双耳茶杯顾客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "BilateralCup":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "BilateralCup"}

	if DevilList.has("难度-日式茶杯顾客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "TeaCup":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "TeaCup"}

	if DevilList.has("难度-玻璃瓶"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].TYPE in "GlassBottle":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "0", "TYPE": "GlassBottle"}
	if DevilList.has("难度-顾客小增加"):
		TrafficNum += 1
	if DevilList.has("难度-顾客中增加"):
		TrafficNum += 2

	if DevilList.has("难度-顾客大增加"):
		TrafficNum += 3
	if DevilList.has("难度-学咖族"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "student":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "student", "TYPE": "TeaCup"}
	if DevilList.has("难度-混混"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "badguy":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "badguy", "TYPE": "PaperCup"}
	if DevilList.has("难度-插队客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "upper":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "mother", "TYPE": "BilateralCup"}
	if DevilList.has("难度-流浪杯"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "homeless":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "homeless", "TYPE": "GlassBottle"}
	if DevilList.has("难度-探店客"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "upper":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "upper", "TYPE": "LittleCup"}
	if DevilList.has("难度-小偷"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "thief":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "thief", "TYPE": "MarkCup"}
	if DevilList.has("难度-批评家"):
		var _CHECK: bool
		for _KEY in Customer_Dic:
			if Customer_Dic[_KEY].ID in "critic":
				_CHECK = true
				break
		if not _CHECK:
			Customer_Dic[Customer_Dic.size()] = {"ID": "critic", "TYPE": "BritishCup"}
	call_Traffic_set()

	var _NpcTSCN = GameLogic.NPC.NPC_Show_TSCN

	for _NODE in CustomerNode.get_children():
		CustomerNode.remove_child(_NODE)
		_NODE.queue_free()
	var _CHECKNUM: int = 0
	for _KEY in Customer_Dic.keys():
		if _CHECKNUM >= _NUM + cur_Devil:
			break
		_CHECKNUM += 1

		var _NpcType = Customer_Dic[_KEY].TYPE
		var _NPCAvatarTSCN = GameLogic.NPC.return_NPC(_NpcType)
		var _NPC = _NpcTSCN.instance()
		var _NPCAvatar = _NPCAvatarTSCN.instance()
		_NPCAvatar.Show_bool = true
		var _ControlNode = Control.new()
		_ControlNode.rect_min_size.x = 80
		CustomerNode.add_child(_ControlNode)
		_ControlNode.add_child(_NPC)
		_NPC.add_child(_NPCAvatar)
		_NPCAvatar.call_personality_init(Customer_Dic[_KEY].ID)



func _on_BackBut_pressed() -> void :
	if Ani.assigned_animation != "show":
		return
	BackBut.call_down()

	if Ani.assigned_animation == "show":
		Ani.play("init")
		MapUI.call_show()

	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	ApplyBut.release_focus()

func call_init():

	var _ViewArray = view.get_children()
	for i in _ViewArray.size():
		var _Obj = _ViewArray[i]
		var _parentNode = _Obj.get_parent()

		_parentNode.remove_child(_Obj)
		_Obj.queue_free()
	_Info_Init()
func _Info_Init():

	var _CustomerArray = CustomerNode.get_children()
	for i in _CustomerArray.size():
		var _Obj = _CustomerArray[i]
		var _parentNode = _Obj.get_parent()
		_parentNode.remove_child(_Obj)
		_Obj.queue_free()


	var _WaterArray = WaterTypeNode.get_children()
	for i in _WaterArray.size():
		var _Obj = _WaterArray[i]
		var _parentNode = _Obj.get_parent()
		_parentNode.remove_child(_Obj)
		_Obj.queue_free()

func _on_Apply_button_down() -> void :
	if not cur_Select:
		return
	if not Can_Press:
		return
	A_But.call_holding(true)
	ApplyBut.call_down()

func _on_Apply_button_up() -> void :
	if not Can_Press:
		return
	A_But.call_holding(false)
	ApplyBut.call_up()
func _Apply_Logic() -> void :
	if not cur_Select:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

		var _PLAYERLIST = get_tree().get_root().get_node("Home/YSort/Players").get_children()
		var _PLAYERNAMELIST: Array
		for _PLAYER in _PLAYERLIST:
			_PLAYERNAMELIST.append(_PLAYER.name)
		var _STEAMLIST: Array
		for _INFO in SteamLogic.LOBBY_MEMBERS:
			if not str(_INFO.steam_id) in _PLAYERNAMELIST:

				SteamLogic.JOIN.call_SomeJoin_Info()
				return

	GameLogic.SPECIALLEVEL_Int = false
	GameLogic.call_NewLevel_Init()
	_on_Apply_button_up()
	GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	Ani.play("hide")
	GameLogic.Audio.But_Apply.play()

	call_UI_hide()
	GameLogic.Can_ESC = true
	show_bool = false
	GameLogic.cur_Devil = cur_Devil

	_pressed = false
	GameLogic.cur_level = cur_Select
	GameLogic.new_bool = true
	emit_signal("LevelSelect")
	GameLogic.call_SceneConfig_load()

	var _STARTINGFUNDS: int = int(GameLogic.Config.SceneConfig[cur_Select].Funds)
	if cur_Devil == 0:
		_STARTINGFUNDS += 500
	GameLogic.call_MoneyChange(_STARTINGFUNDS, GameLogic.HomeMoneyKey)

	ApplyBut.release_focus()

	GameLogic.cur_StoreStar = int(GameLogic.Config.SceneConfig[cur_Select].Popular)
	GameLogic.Card.call_Event_init()
	GameLogic.Can_Card = true
	GameLogic.Order.call_Formula_init()
	GameLogic.cur_Menu.clear()

	GameLogic.cur_MenuNum = GameLogic.cur_levelInfo.MenuStart

	GameLogic.call_start_check()
	GameLogic.call_save()
	GameLogic.GameUI.call_JoinInfo(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

		SteamLogic.call_send_Data()
		var _SetLevel = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Level", GameLogic.cur_level)
		var _SerDevil = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Devil", str(GameLogic.cur_Devil))
		var _SetDay = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Day", str(GameLogic.cur_Day))

func call_UI_hide():
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(0)
	if is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(0)
	if not TutorialAni.assigned_animation in ["init", "hide"]:
		TutorialAni.play("hide")
func _on_L_pressed() -> void :
	var _PressBut = DifficultyBut.group.get_pressed_button()
	if int(_PressBut.name) > 1:
		var _butName = str(int(_PressBut.name) - 1)
		var _parNode = DifficultyBut.get_parent()
		var _But = _parNode.get_node(_butName)
		if not _But.disabled:
			_But.pressed = true

	_But_Logic()
	_on_Difficulty_pressed()

func _on_R_pressed() -> void :

	var _PressBut = DifficultyBut.group.get_pressed_button()
	if int(_PressBut.name) < 4:
		var _butName = str(int(_PressBut.name) + 1)
		var _parNode = DifficultyBut.get_parent()
		var _But = _parNode.get_node(_butName)
		if not _But.disabled:
			_But.pressed = true
	_But_Logic()
	_on_Difficulty_pressed()

func call_Devil_Set(_Type):

	GameLogic.Audio.But_EasyClick.play(0)
	match _Type:
		"+":
			var _HBOX = get_node("Control/Choose/HBox")
			var _CHOOSEMAX = Devil_Finished
			if GameLogic.Config.SceneConfig.has(cur_Select):
				var _MAX = int(GameLogic.Config.SceneConfig[cur_Select].DevilMax) - 1
				if _CHOOSEMAX >= _MAX:
					_CHOOSEMAX = _MAX

			if cur_Devil >= _CHOOSEMAX:
				cur_Devil = _CHOOSEMAX
				return
			else:
				cur_Devil += 1
			for i in _HBOX.get_child_count():
				if i <= cur_Devil:
					if _HBOX.has_node(str(i)):
						_HBOX.get_node(str(i)).get_node("Ani").play("select")
				else:
					if i > Devil_Finished:
						if _HBOX.has_node(str(i)):
							_HBOX.get_node(str(i)).get_node("Ani").play("lock")
					else:
						if _HBOX.has_node(str(i)):
							_HBOX.get_node(str(i)).get_node("Ani").play("init")
		"-":
			var _HBOX = get_node("Control/Choose/HBox")

			if cur_Devil <= 0:
				cur_Devil = 0

			else:
				cur_Devil -= 1
			for i in _HBOX.get_child_count():

				if i <= cur_Devil:
					if _HBOX.has_node(str(i)):
						_HBOX.get_node(str(i)).get_node("Ani").play("select")
				else:
					if i > Devil_Finished:
						if _HBOX.has_node(str(i)):
							_HBOX.get_node(str(i)).get_node("Ani").play("lock")
					else:
						if _HBOX.has_node(str(i)):
							_HBOX.get_node(str(i)).get_node("Ani").play("init")

	change_logic()
func change_logic():
	_Info_Init()

	_DevilList()
	call_info_set()
	call_popular_set()
	call_watertype_set()
	call_customer_set()
	call_money_set()
func _control_logic(_but, _value, _type):

	if _value == 0 and cur_pressed:
		cur_pressed = false

	if not show_bool:
		return
	match _but:
		"U", "u":
			if _pressed or cur_pressed:
				return
			if _value == 1 or _value == - 1:
				cur_pressed = true
				call_Devil_Set("+")
		"D", "d":
			if _pressed or cur_pressed:
				return
			if _value == 1 or _value == - 1:
				cur_pressed = true
				call_Devil_Set("-")
		"L", "l":
			if _pressed or cur_pressed:
				return
			if _value == 1 or _value == - 1:
				cur_pressed = true
				if not LButton.disabled:
					LButton.call_pressed()
					_on_L_pressed()
		"R", "r":
			if _pressed or cur_pressed:
				return
			if _value == 1 or _value == - 1:

				cur_pressed = true
				if not RButton.disabled:
					RButton.call_pressed()
					_on_R_pressed()
		"B", "START":
			if _pressed or cur_pressed:
				return
			if _value == 1 or _value == - 1:
				cur_pressed = true
				_on_BackBut_pressed()
				GameLogic.Audio.But_Back.play(0)
		"A":

			if cur_pressed:

				return
			if not Can_Press:
				if _value == 1:
					cur_pressed = true
					var _audio = GameLogic.Audio.return_Effect("错误1")
					_audio.play(0)
				return
			if _check == ERR_FILE_EOF:
				if _value == 1 or _value == - 1:
					cur_pressed = true
					if not _pressed:
						_pressed = true
						_on_Apply_button_down()
				else:
					_on_Apply_button_up()
					_pressed = false
			else:
				_on_Apply_button_up()
				_pressed = false

		"X":
			if _pressed or cur_pressed:
				return
			if _value == 1:
				cur_pressed = true
				_on_IN_pressed()
		"Y":
			if _pressed or cur_pressed:
				return
			if _value == 1:
				cur_pressed = true
				_on_OUT_pressed()
	if _type == 0:
		cur_pressed = false

func _on_UP_pressed(_value) -> void :

	if LoadLevel_bool:
		return
	if LevelCamera.position.y > LevelCamera.limit_top + 400:
		LevelCamera.position.y -= (_value * 500)
func _on_DOWN_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.y < LevelCamera.limit_bottom - 400:
		LevelCamera.position.y += (_value * 500)
func _on_LEFT_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.x > LevelCamera.limit_left + 400:
		LevelCamera.position.x -= (_value * 500)
func _on_RIGHT_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.x < LevelCamera.limit_right - 400:
		LevelCamera.position.x += (_value * 500)
func _on_IN_pressed() -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.zoom < Vector2(1.5, 1.5):
		LevelCamera.zoom += Vector2(0.1, 0.1)
func _on_OUT_pressed() -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.zoom > Vector2(1, 1):
		LevelCamera.zoom -= Vector2(0.1, 0.1)

func _on_UPbut_pressed() -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.y > LevelCamera.limit_top + 400:
		LevelCamera.position.y -= (500)

func _on_DOWNbut_pressed() -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.y < LevelCamera.limit_bottom - 400:
		LevelCamera.position.y += (500)

func _on_LEFTbut_pressed() -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.x > LevelCamera.limit_left + 400:
		LevelCamera.position.x -= (500)

func _on_RIGHTbut_pressed() -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.x < LevelCamera.limit_right - 400:
		LevelCamera.position.x += (500)

func _on_Timer_timeout():
	set_process(true)

func _on_UpBut_pressed():
	call_Devil_Set("+")

func _on_DownBut_pressed():
	call_Devil_Set("-")
