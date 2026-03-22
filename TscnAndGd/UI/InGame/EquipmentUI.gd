extends CanvasLayer

onready var ANI = $Ani
onready var C = $Control / InfoControl / Model / TexNode / LogicNode / C

onready var EquipGrid = $Control / Info / BG / Scroll / Grid
onready var EQUIPBUTTON_TSCN = preload("res://TscnAndGd/Buttons/EquipButton.tscn")
onready var Group = preload("res://TscnAndGd/UI/Info/RewardInfo.tres")
var CurGroup

var _TYPE: int = 1
var EquipList: Array
var _AVATARID: int

var ALLShow_Bool: bool = true

onready var BUT_1 = get_node("Control/Info/Control/HBoxContainer/1")
onready var BUT_2 = get_node("Control/Info/Control/HBoxContainer/2")
onready var BUT_3 = get_node("Control/Info/Control/HBoxContainer/3")
onready var BUT_4 = get_node("Control/Info/Control/HBoxContainer/4")
onready var BUT_5 = get_node("Control/Info/Control/HBoxContainer/5")
onready var BUT_6 = get_node("Control/Info/Control/HBoxContainer/6")
onready var TYPEBUT = get_node("Control/Info/BG/TYPEButton")
func _ready():
	if not GameLogic.is_connected("EQUIPCHANGE", self, "call_EQUIPSET"):
		var _CON = GameLogic.connect("EQUIPCHANGE", self, "call_EQUIPSET")
	call_deferred("call_TYPE_Logic")

func call_EquipList_init(_TYPECHECK: String):
	EquipList.clear()

	var _IDKEYS: Array = SteamLogic._EQUIPDIC.keys()
	for _ID in _IDKEYS:
		if GameLogic.Config.CostumeConfig.has(str(_ID)):
			if GameLogic.Config.CostumeConfig[str(_ID)]. class == "Costume":
				var _PART = GameLogic.Config.CostumeConfig[str(_ID)].part
				if _PART == _TYPECHECK:
					EquipList.append(_ID)

func call_EQUIP_Init():

	var _PLAYERID: int = get_parent().cur_PlayerID

	if GameLogic.Save.gameData["EquipDic"].has(_PLAYERID):
		if not GameLogic.Save.gameData["EquipDic"][_PLAYERID].has(_AVATARID):
			GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID] = {
				"Head": 0,
				"Body": 0,
				"Hand": 0,
				"Face": 0,
				"Foot": 0,
				"Accessory_1": 0,
				"Accessory_2": 0,
				"Accessory_3": 0
			}

func call_EQUIPSET():
	call_EQUIP_Init()
	var _PLAYERID: int = get_parent().cur_PlayerID
	var _Head_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Head"])
	var _Face_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Face"])
	var _Body_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Body"])
	var _Hand_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Hand"])
	var _Foot_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Foot"])
	var _Acc_1_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Accessory_1"])
	var _Acc_2_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Accessory_2"])
	var _Acc_3_ID: int = int(GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Accessory_3"])
	match _AVATARID:
		0, 1, 2, 3, 6, 7:
			BUT_1.call_ButShow(_Head_ID, "Head")
			BUT_2.call_ButShow(_Face_ID, "Face")
			BUT_3.call_ButShow(_Body_ID, "Body")
			BUT_4.call_ButShow(_Hand_ID, "Hand")
			BUT_5.call_ButShow(_Foot_ID, "Foot")
			BUT_6.call_ButShow(_Acc_1_ID, "Accessory")
		4:
			BUT_1.call_ButShow(_Head_ID, "Head")
			BUT_2.call_ButShow(_Face_ID, "Face")
			BUT_3.call_ButShow(_Body_ID, "Body")
			BUT_4.call_ButShow(_Acc_2_ID, "Accessory")
			BUT_5.call_ButShow(_Acc_3_ID, "Accessory")
			BUT_6.call_ButShow(_Acc_1_ID, "Accessory")
		5:
			BUT_1.call_ButShow(_Head_ID, "Head")
			BUT_2.call_ButShow(_Face_ID, "Face")
			BUT_3.call_ButShow(_Body_ID, "Body")
			BUT_4.call_ButShow(_Hand_ID, "Hand")
			BUT_5.call_ButShow(_Acc_2_ID, "Accessory")
			BUT_6.call_ButShow(_Acc_1_ID, "Accessory")

func call_EQUIPSHOW():
	SteamLogic.LoadInventory()
	_TYPEBUT_Logic()
	call_TYPE_Logic()
	call_EQUIPSET()
	call_clean_Grid()

	call_CARD_Set(str(_TYPE))
func call_TYPE_Logic():
	var _TYPE_1: bool = false
	var _TYPE_2: bool = false
	var _TYPE_3: bool = false
	var _TYPE_4: bool = false
	var _TYPE_5: bool = false
	var _TYPE_6: bool = false
	match _TYPE:
		1:
			_TYPE_1 = true
		2:
			_TYPE_2 = true
		3:
			_TYPE_3 = true
		4:
			_TYPE_4 = true
		5:
			_TYPE_5 = true
		6:
			_TYPE_6 = true
	BUT_1.call_Select(_TYPE_1)
	BUT_2.call_Select(_TYPE_2)
	BUT_3.call_Select(_TYPE_3)
	BUT_4.call_Select(_TYPE_4)
	BUT_5.call_Select(_TYPE_5)
	BUT_6.call_Select(_TYPE_6)
func call_clean_Grid():
	var _BUTLIST = EquipGrid.get_children()
	for _BUT in _BUTLIST:
		_BUT.queue_free()

func return_RoleCheck(_ID):
	var _EQUIPID: String = str(_ID)
	if GameLogic.Config.CostumeConfig.has(_EQUIPID):
		var _role = GameLogic.Config.CostumeConfig[_EQUIPID].role
		var _RoleInt: int
		match _role:
			"Bear":
				_RoleInt = 0
			"Wolf":
				_RoleInt = 1
			"Fox":
				_RoleInt = 2
			"Beaver":
				_RoleInt = 3
			"Ghost":
				_RoleInt = 4
			"Slime":
				_RoleInt = 5
			"Panda":
				_RoleInt = 6
			"Crocodile":
				_RoleInt = 7
		if _RoleInt == _AVATARID:
			return true
	return false
func _AddBUT(_EQUIPPART: String):

	for _ID in EquipList:
		var _CHECK: bool = return_RoleCheck(_ID)
		if not ALLShow_Bool and not _CHECK:
			continue

		var _BUT = EQUIPBUTTON_TSCN.instance()
		_BUT.ID = _ID
		_BUT.AVATARID = _AVATARID
		_BUT.PLAYERID = get_parent().cur_PlayerID
		match _EQUIPPART:
			"Accessory":
				_BUT.EQUIPPART = "Accessory_1"
			"Hand":
				if _AVATARID in [4]:
					_BUT.EQUIPPART = "Accessory_2"
				else:
					_BUT.EQUIPPART = "Hand"
			"Foot":
				if _AVATARID in [4]:
					_BUT.EQUIPPART = "Accessory_3"
				elif _AVATARID in [5]:
					_BUT.EQUIPPART = "Accessory_2"
				else:
					_BUT.EQUIPPART = "Foot"
			"Head":
				_BUT.EQUIPPART = _EQUIPPART
			"Face":
				_BUT.EQUIPPART = _EQUIPPART
			"Body":
				_BUT.EQUIPPART = _EQUIPPART
		_BUT.set_button_group(CurGroup)
		EquipGrid.add_child(_BUT)
		_BUT.call_ID_Logic()
		if _CHECK:
			EquipGrid.move_child(_BUT, 0)

func call_CARD_Set(_NAMEID: String):
	if not CurGroup:
		CurGroup = Group
	match _NAMEID:
		"1":
			call_EquipList_init("Head")
			_AddBUT("Head")

		"2":
			call_EquipList_init("Face")
			_AddBUT("Face")
		"3":
			call_EquipList_init("Body")
			_AddBUT("Body")
		"4":
			match _AVATARID:
				4:
					call_EquipList_init("Accessory")
				_:
					call_EquipList_init("Hand")
			_AddBUT("Hand")

		"5":
			match _AVATARID:
				4, 5:
					call_EquipList_init("Accessory")
				_:
					call_EquipList_init("Foot")
			_AddBUT("Foot")
		"6":
			call_EquipList_init("Accessory")
			_AddBUT("Accessory")
	call_GrabFocus()
func call_GrabFocus():
	yield(get_tree().create_timer(0.1), "timeout")
	if EquipGrid.get_child_count() > 0:
		EquipGrid.get_child(0).grab_focus()

func call_ESC_true():
	GameLogic.Can_ESC = true

func call_hide():
	if ANI.assigned_animation == "show":
		ANI.play("hide")

func call_check_init():


	if GameLogic.Save.gameData.HomeDevList.has("衣橱"):
		BUT_3.get_node("Lock").hide()
		BUT_6.get_node("Lock").hide()
	if GameLogic.Save.gameData.HomeDevList.has("鞋柜"):
		BUT_4.get_node("Lock").hide()
		BUT_5.get_node("Lock").hide()
	if GameLogic.Save.gameData.HomeDevList.has("帽架"):
		BUT_1.get_node("Lock").hide()
		BUT_2.get_node("Lock").hide()
func call_show():
	call_check_init()
	GameLogic.Can_ESC = false
	if ANI.assigned_animation != "show":
		ANI.play("show")
	for _NODE in C.get_children():
		_NODE.queue_free()

	var _PLAYERID = get_parent().cur_PlayerID
	if _PLAYERID == SteamLogic.STEAM_ID:
		_PLAYERID = 1


	var _TSCNName = GameLogic.Config.PlayerConfig[str(_AVATARID)].TSCN
	var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = str(_AVATARID)
	_Avatar.CURPLAYER = _PLAYERID
	_Avatar.CURAVATAR = _AVATARID
	C.add_child(_Avatar)
	call_EQUIPSHOW()

func call_closed():
	get_parent().call_close()

func _on_But_pressed():

	pass

func _on_1_pressed():
	_TYPE = 1
	call_EQUIPSHOW()
func _on_2_pressed():
	_TYPE = 2
	call_EQUIPSHOW()
func _on_3_pressed():
	_TYPE = 3
	call_EQUIPSHOW()
func _on_4_pressed():
	_TYPE = 4
	call_EQUIPSHOW()
func _on_5_pressed():
	_TYPE = 5
	call_EQUIPSHOW()
func _on_6_pressed():
	_TYPE = 6
	call_EQUIPSHOW()

func call_TYPE_Change(_BOOL: bool):
	if _BOOL:
		if _TYPE < 6:
			_TYPE += 1
		else:
			_TYPE = 1
	else:
		if _TYPE > 1:
			_TYPE -= 1
		else:
			_TYPE = 6
	call_EQUIPSHOW()

func return_Focus_But():
	var _BUTLIST = EquipGrid.get_children()
	if _BUTLIST:
		for _BUT in _BUTLIST:
			if _BUT.has_focus():
				return _BUT

	else:
		return

func _TYPEBUT_Logic():

	var _LockANI = $Control / Info / BG / TYPEButton / LockANI
	if not ALLShow_Bool:
		_LockANI.play(str(_AVATARID))
	else:
		_LockANI.play("All")


func _on_TYPEButton_pressed():
	ALLShow_Bool = not ALLShow_Bool
	call_EQUIPSHOW()
