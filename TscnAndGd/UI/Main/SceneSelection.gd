extends Control

var playerID
enum LOCATION{






}
onready var ComputerObj = get_parent().get_parent()
var ChooseMax = 3

var cur_size: int
var cur_Cost: int
onready var Scene_0 = get_node("SceneHBox/0")
onready var Scene_1
onready var Scene_2
onready var SceneAni = get_node("AniNode/SceneAni")

onready var MoneyLabel = $money / MoneyLabel
onready var CostLabel = get_node("money/TotalCost")
onready var FinalMoneyLabel = get_node("money/FinalMoney")
var Scene_0_Level
var Scene_1_Level
var Scene_2_Level

var Scene_0_info
var Scene_1_info
var Scene_2_info

var SceneList: Array
var can_press: bool
func _ready() -> void :
	_SceneBut_init()
	call_deferred("call_SceneList_init")

func call_SceneList_init():

	SceneList.clear()
	var _SceneKeys = GameLogic.Config.SceneConfig.keys()
	for i in _SceneKeys.size():
		if int(GameLogic.Config.SceneConfig[_SceneKeys[i]].LevelID) == int(GameLogic.cur_levelRank):
			SceneList.append(_SceneKeys[i])
	Scene_0.disabled = true
	Scene_1.disabled = true
	Scene_2.disabled = true

func _SceneBut_init():
	Scene_1 = Scene_0.duplicate()
	get_node("SceneHBox").add_child(Scene_1)
	Scene_1.name = "1"
	Scene_2 = Scene_0.duplicate()
	get_node("SceneHBox").add_child(Scene_2)
	Scene_2.name = "2"
func call_init():
	var _SceneMax = SceneList.size()
	var _SceneList: Array = SceneList
	_SceneList.shuffle()
	for i in _SceneMax:
		if i > 2:
			break
		var _Scene_Level = _SceneList.pop_back()
		var _Scene_Info = GameLogic.Config.SceneConfig[_Scene_Level]
		var _Scene
		match i:
			0:
				Scene_0_info = _Scene_Info
				Scene_0_Level = _Scene_Level
				_Scene = Scene_0
			1:
				Scene_1_info = _Scene_Info
				Scene_1_Level = _Scene_Level
				_Scene = Scene_1
			2:
				Scene_2_info = _Scene_Info
				Scene_2_Level = _Scene_Level
				_Scene = Scene_2

		var _CostMoneyLabel = _Scene.get_node("BaseInfo/CostMoney/Label")
		_CostMoneyLabel.text = str(_Scene_Info.Cost)
		var _DailyRentLabel = _Scene.get_node("BaseInfo/DailyRent/Label")
		_DailyRentLabel.text = str(_Scene_Info.Rent)
		var _IndoorAreaLabel = _Scene.get_node("BaseInfo/IndoorArea/Label")
		cur_size = int(_Scene_Info.IndoorArea)
		_IndoorAreaLabel.text = str(_Scene_Info.IndoorArea)
		var _OutdoorAreaLabel = _Scene.get_node("BaseInfo/OutdoorArea/Label")
		_OutdoorAreaLabel.text = str(_Scene_Info.OutdoorArea)
		var _OpeningHours = _Scene.get_node("BaseInfo/OpeningHours/Label")
		_OpeningHours.text = str(_Scene_Info.OpenTime) + ":00 ~ " + str(_Scene_Info.CloseTime) + ":00"
		var _DrinkType = _Scene.get_node("BaseInfo/DrinkType/Label")
		_DrinkType.text = _Scene_Info.DrinkType
		var _PV_Progress = _Scene.get_node("BarInfo/PV/Progress")
		_PV_Progress.value = int(_Scene_Info.PV)
		var _CPP_Progress = _Scene.get_node("BarInfo/CPP/Progress")
		_CPP_Progress.value = int(_Scene_Info.CPP)
		var _RB_Progress = _Scene.get_node("BarInfo/RB/Progress")
		_RB_Progress.value = int(_Scene_Info.RB)
	SceneAni.play("show")

func _timeout_logic():
	Scene_0.disabled = false
	Scene_1.disabled = false
	Scene_2.disabled = false
	match SceneList.size():
		0:
			pass
		1:
			Scene_0.disabled = true
			Scene_2.disabled = true
		2:
			Scene_2.disabled = true
	Scene_1.grab_focus()
	can_press = true
func _on_scene_pressed() -> void :
	if not can_press:
		return
	var _Pressed = Scene_0.group.get_pressed_button()
	var _LevelID
	match _Pressed.name:
		"0":
			_LevelID = Scene_0_Level
		"1":
			_LevelID = Scene_1_Level
		"2":
			_LevelID = Scene_2_Level

	GameLogic.NewGame_Bool = true

	GameLogic.cur_level = str(_LevelID)
	GameLogic.cur_money = int(FinalMoneyLabel.text)
	GameLogic.CustomerTypeList = GameLogic.cur_levelInfo.CustomersList
	GameLogic.cur_size = int(GameLogic.cur_levelInfo.IndoorArea)
	GameLogic.cur_Rent = int(GameLogic.cur_levelInfo.Rent)
	GameLogic.cur_OpenTime = float(GameLogic.cur_levelInfo.OpenTime)
	GameLogic.cur_CloseTime = float(GameLogic.cur_levelInfo.CloseTime)
	GameLogic.cur_PV = int(GameLogic.cur_levelInfo.PV)
	GameLogic.cur_CPP = int(GameLogic.cur_levelInfo.CPP)
	GameLogic.cur_RB = int(GameLogic.cur_levelInfo.RB)


	can_press = false
	ComputerObj.Scene_bool = true
	ComputerObj.call_close()
	SceneAni.play("init")
	GameLogic.Can_Start = true
	GameLogic.GameUI.call_money_change(int(CostLabel.text) * - 1)
	GameLogic._save()

func call_money_changed() -> void :

	var _cur_But_list = Scene_0.group.get_buttons()
	var _cur_But
	for i in _cur_But_list.size():
		var _But = _cur_But_list[i]
		if _But.has_focus():
			_cur_But = _But
			break
	var _CostMoneyLabel = _cur_But.get_node("BaseInfo/CostMoney/Label")
	var _Cost = _CostMoneyLabel.text
	MoneyLabel.text = str(GameLogic.cur_money)
	CostLabel.text = _Cost
	var _FinalMoney = int(GameLogic.cur_money) - int(_Cost)
	FinalMoneyLabel.text = str(_FinalMoney)
