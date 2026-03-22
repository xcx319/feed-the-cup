extends Head_Object

export var TYPE: int
export var CURID: int
var cur_pressed: bool

var cur_Used: bool = false
var cur_DEVIL: int = 0
var AchievementList: Array

onready var ButShow = get_node("Button/A")
onready var OBJAni = get_node("Texture/Layer1/Obj/Ani")
onready var LockNode = get_node("Texture/Lock")
onready var HomeUpdateUI
onready var Ani

onready var BackBut

onready var HomeUpdateBut = preload("res://TscnAndGd/Buttons/AchievementRewardButton.tscn")
onready var CurButGroup
onready var HomeUpdateGroups = preload("res://TscnAndGd/Buttons/Achievement_Group.tres")
onready var InfoButNode

onready var Ach_Name
onready var Ach_Icon

onready var Ach_RewardInfo

onready var CurBut

onready var ApplyBut
onready var A_But
onready var AchNode_1
onready var AchNode_2
onready var AchNode_3
onready var AchNode_4
var IsBuy: bool
func _ready() -> void :

	_ObjShowLogic()
	var _con = GameLogic.connect("SYNC", self, "_ObjShowLogic")


func _TypwShow_logic():

	_del_all_InfoButton()
	_add_InfoButton()

func _wrong_audio():
	var _Audio = GameLogic.Audio.return_Effect("错误1")
	_Audio.play(0)

func _Equip_Logic_puppet(_EQUIPLIST):
	SteamLogic.LOBBY_gameData.cur_EquipList = _EQUIPLIST

	GameLogic.emit_signal("SYNC")

func _Equip_Logic():
	HomeUpdateUI.get_node("AnimationPlayer").play("init")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.cur_level != "" and GameLogic.cur_Day >= 1:
		HomeUpdateUI.get_node("AnimationPlayer").play("wrong")
		_wrong_audio()
		return

	var _BUT = CurBut.group.get_pressed_button()
	var _RewardID = _BUT.NameInfo
	if GameLogic.Achievement.cur_EquipList.has(_RewardID):
		GameLogic.Achievement.cur_EquipList.erase(_RewardID)
		_BUT._check_logic()
		GameLogic.Audio.But_Apply.play(0)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "_Equip_Logic_puppet", [GameLogic.Achievement.cur_EquipList])
	elif GameLogic.Achievement.AchievementReward_Array.has(_RewardID):

		if GameLogic.Achievement.cur_EquipList.size() < GameLogic.Achievement.EquipMax:
			GameLogic.Achievement.cur_EquipList.append(_RewardID)
			_BUT._check_logic()
			GameLogic.Audio.But_Apply.play(0)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "_Equip_Logic_puppet", [GameLogic.Achievement.cur_EquipList])
		else:
			HomeUpdateUI.get_node("AnimationPlayer").play("Full")
			_wrong_audio()
	else:
		HomeUpdateUI.get_node("AnimationPlayer").play("Full")
		_wrong_audio()

	AchNode_1._ObjShowLogic()
	AchNode_2._ObjShowLogic()
	AchNode_3._ObjShowLogic()
	AchNode_4._ObjShowLogic()


func call_OBJpuppet():
	_ObjShowLogic()
func _ObjShowLogic():

	match TYPE:
		0:
			LockNode.hide()
		1:

			if GameLogic.Achievement.EquipMax >= CURID:
				LockNode.hide()
			else:
				LockNode.show()

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.LOBBY_gameData.has("cur_EquipList"):

			if SteamLogic.LOBBY_gameData.cur_EquipList.size() >= CURID:
				for i in SteamLogic.LOBBY_gameData.cur_EquipList.size():
					if i == CURID - 1:
						var _Name = SteamLogic.LOBBY_gameData.cur_EquipList[i]

						if OBJAni.assigned_animation != _Name and OBJAni.has_animation(_Name):
							OBJAni.play(_Name)
						return
		OBJAni.play("init")
		return
	if GameLogic.Achievement.cur_EquipList.size() >= CURID:
		for i in GameLogic.Achievement.cur_EquipList.size():
			if i == CURID - 1:
				var _Name = GameLogic.Achievement.cur_EquipList[i]
				if OBJAni.assigned_animation != _Name and OBJAni.has_animation(_Name):
					OBJAni.play(_Name)
	else:

		OBJAni.play("init")
func _ShowOBJ(i):
	if i == CURID - 1:
		var _Name = GameLogic.Achievement.cur_EquipList[i]
		if OBJAni.assigned_animation != _Name and OBJAni.has_animation(_Name):
			OBJAni.play(_Name)
func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:

			"B", "START":
				BackBut.on_pressed()
				call_closed()

			"A":
				if cur_pressed == false:
					cur_pressed = true
					_Equip_Logic()

			"l", "L":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_left"
					_input.pressed = true
					Input.parse_input_event(_input)
			"r", "R":
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


func _Buy_Check():
	var _But = CurBut.group.get_pressed_button()

	IsBuy = _But.CheckBool

func call_grab_focus():

	cur_Used = true
var _EquipList: Array
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		0, "A":

			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if not is_instance_valid(GameLogic.player_1P) or not is_instance_valid(GameLogic.player_2P):
				return
			if not cur_Used:
				GameLogic.player_1P.call_control(1)
				GameLogic.player_2P.call_control(1)
				_AchievementList_Init()
				_HomeUpdateUI_Load()


				cur_Used = true

				GameLogic.Audio.But_SwitchOn.play(0)
				Ani.play("show")
				GameLogic.Can_ESC = false
				yield(get_tree().create_timer(0.5), "timeout")
				_Control_set()
				return true

func _Control_set():
	if InfoButNode.has_node("0"):
		InfoButNode.get_node("0").grab_focus()
		InfoButNode.get_node("0").pressed = true
		call_AchievementButton_pressed(true)
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")
func _AchievementList_Init():
	for _Ach in GameLogic.Achievement.Achievement_Array:
		if not AchievementList.has(_Ach):
			AchievementList.append(_Ach)
	var _HOMEID = int(GameLogic.Save.gameData["HomeUpdate"])
	if _HOMEID in [1, 2, 3]:
		GameLogic.Achievement.EquipMax = 1
	elif _HOMEID in [4, 5]:
		GameLogic.Achievement.EquipMax = 2
	elif _HOMEID in [6, 7]:
		GameLogic.Achievement.EquipMax = 3
	elif _HOMEID in [8, 9]:
		GameLogic.Achievement.EquipMax = 4
	var _CurEQUIPNUM: int = GameLogic.Achievement.cur_EquipList.size()
	if _CurEQUIPNUM > GameLogic.Achievement.EquipMax:
		var _DELNUM: int = _CurEQUIPNUM - GameLogic.Achievement.EquipMax
		for _i in _DELNUM:
			var _DELACH = GameLogic.Achievement.cur_EquipList.pop_back()

func _HomeUpdateUI_Load():
	GameLogic.Achievement._Load()
	var _UILoad = load("res://TscnAndGd/UI/InGame/AchievementRewardUI.tscn")
	HomeUpdateUI = _UILoad.instance()
	add_child(HomeUpdateUI)
	Ani = HomeUpdateUI.get_node("Ani")

	ApplyBut = HomeUpdateUI.get_node("Control/ButControl/ApplyBut")
	BackBut = HomeUpdateUI.get_node("Control/ButControl/BackBut")
	A_But = ApplyBut.get_node("A")

	InfoButNode = HomeUpdateUI.get_node("Control/Info/BG/Scroll/Grid")

	Ach_Name = HomeUpdateUI.get_node("Control/InfoControl/Name")
	Ach_Icon = HomeUpdateUI.get_node("Control/InfoControl/Icon/TypeAni")
	Ach_RewardInfo = HomeUpdateUI.get_node("Control/InfoControl/RewardInfo")
	AchNode_1 = HomeUpdateUI.get_node("Control/Control/ScrollContainer/HBox/1/1")
	AchNode_2 = HomeUpdateUI.get_node("Control/Control/ScrollContainer/HBox/2/2")
	AchNode_3 = HomeUpdateUI.get_node("Control/Control/ScrollContainer/HBox/3/3")
	AchNode_4 = HomeUpdateUI.get_node("Control/Control/ScrollContainer/HBox/4/4")
	var _con1 = A_But.connect("HoldFinish", self, "_Apply_Logic")
	var _con2 = BackBut.connect("pressed", self, "call_closed")
	_Devil_Load()
	_TypwShow_logic()
	AchNode_1._ObjShowLogic()
	AchNode_2._ObjShowLogic()
	AchNode_3._ObjShowLogic()
	AchNode_4._ObjShowLogic()
	_EquipList.clear()
	for _ACH in GameLogic.Achievement.cur_EquipList:
		if not _EquipList.has(_ACH):
			_EquipList.append(_ACH)
func _Devil_Load():
	var _KEYS = GameLogic.Level_Data.keys()
	var _LEVELKEYS = GameLogic.Config.SceneConfig.keys()
	var _DEVILCOUNT: int = 0
	for _NAME in _KEYS:
		if _NAME in _LEVELKEYS:
			_DEVILCOUNT += int(GameLogic.Level_Data[_NAME].cur_Devil) + 1

	HomeUpdateUI.get_node("Control/Control/Label").text = str(_DEVILCOUNT)
	cur_DEVIL = _DEVILCOUNT

func call_closed():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

	BackBut.call_down()
	if GameLogic.Achievement.cur_EquipList.size() > 0:
		GameLogic.Save.statisticsData["HasEquipReward"] = 1
	GameLogic.Achievement._Save()
	yield(get_tree().create_timer(0.1), "timeout")
	Ani.play("hide")
	yield(get_tree().create_timer(0.3), "timeout")
	cur_Used = false
	GameLogic.player_1P.call_control(0)
	GameLogic.player_2P.call_control(0)
	GameLogic.Can_ESC = true
	GameLogic.call_SYNC()
	if get_tree().is_paused():
		get_tree().set_pause(false)
	match GameLogic.GlobalData.LoadingType:
		0:
			if is_instance_valid(HomeUpdateUI):
				HomeUpdateUI.queue_free()
	var _SAVECHECK: bool = false
	if _EquipList.size() != GameLogic.Achievement.cur_EquipList.size():
		_SAVECHECK = true
	else:
		for _ACH in GameLogic.Achievement.cur_EquipList:
			if not _EquipList.has(_ACH):
				_SAVECHECK = true
				break

	if _SAVECHECK:
		GameLogic.call_save()
func _del_all_InfoButton():

	var _child_array = InfoButNode.get_children()
	for i in _child_array.size():
		var _but = _child_array[i]
		var _butPar = _but.get_parent()
		_butPar.remove_child(_but)
		_but.queue_free()

func _add_InfoButton():

	var _Data_Array: Array
	_Data_Array = GameLogic.Config.DevilBonusConfig.keys()
	for i in _Data_Array.size():
		var _But = HomeUpdateBut.instance()
		_But.name = str(InfoButNode.get_child_count())
		InfoButNode.add_child(_But)


		_But.connect("toggled", self, "call_AchievementButton_pressed")
		_But.call_init(_Data_Array[i], cur_DEVIL)


		if i == 0:
			CurButGroup = HomeUpdateGroups
			CurBut = _But
			_But.set_button_group(CurButGroup)
			_But.set_pressed(true)
			_But.grab_focus()
		else:
			_But.set_button_group(CurButGroup)



func call_AchievementButton_pressed(_pressed: bool):
	if _pressed:
		var _But = CurBut.group.get_pressed_button()

		call_AchievementInfo_Show(_But.NameInfo)

func call_AchievementInfo_Show(_AchievementID: String):


	if GameLogic.Config.DevilBonusConfig.has(_AchievementID):
		var _INFO = GameLogic.Config.DevilBonusConfig[_AchievementID]
		Ach_Name.text = GameLogic.CardTrans.get_message(_INFO.Name)

		var _INFO_Base = GameLogic.CardTrans.get_message(_INFO.RewardInfo)
		var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)

		var _Info = "[fill][center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center]"
		Ach_RewardInfo.bbcode_text = _Info

		if Ach_Icon.has_animation(_AchievementID):
			Ach_Icon.play(_AchievementID)
		if GameLogic.Achievement.Achievement_Array.has(_AchievementID):

			var _But = CurBut.group.get_pressed_button()
			_But._check_logic()



func _set_OrderBut_focus():




	var _but_Array = InfoButNode.get_children()
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
