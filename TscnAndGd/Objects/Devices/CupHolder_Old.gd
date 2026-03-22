extends Head_Object
var SelfDev = "CupHolder"
var Cup_Pos_Array = [
	Vector2(4, - 12),
	Vector2( - 2, 20)
]
var Cup_Max: int
var CanTake_bool: bool
var CupType_Array: Array
var CupNum_Array: Array

var HasCup_Count: int

onready var TexNode = get_node("TexNode")
onready var CupNode1 = null
var CupNode1_Type = null
var CupNode1_Num: int
onready var CupNode2 = null
var CupNode2_Type = null
var CupNode2_Num: int
func _ready() -> void :

	CanTake_bool = true
	call_init(SelfDev)

	Cup_Max = 2

func call_load(_Info):
	if _Info.CupNode1_Type != null:
		var _TSCN = GameLogic.TSCNLoad.return_TSCN("DrinkCup_Group")
		var _DrinkGroup = _TSCN.instance()
		_DrinkGroup.Num = _Info.CupNode1_Num

func call_PutOn(_ButID, _Player):
	match _ButID:
		- 1:
			if CupNode1_Type != null and CupNode2_Type != null:
				return
			ButInfo_Switch( - 1, "A")
		0:


			if CupNode1_Type != null and CupNode2_Type != null:
				return
			var _CupGroupTSCN = instance_from_id(_Player.Con.HoldInsId)
			var _CupTypeStr = _CupGroupTSCN.TypeStr


			_Player.WeaponNode.remove_child(_CupGroupTSCN)
			_Player.Stat.call_carry_off()

			TexNode.add_child(_CupGroupTSCN)
			if CupNode1 == null:
				var _name = "1"
				_CupGroupTSCN.name = _name
				_CupGroupTSCN.position = Cup_Pos_Array[0]
				if TexNode.has_node(_name):
					var _CupNode = TexNode.get_node(_name)
					CupNode1 = _CupNode
					CupNode1_Type = _CupTypeStr
					CupNode1_Num = _CupGroupTSCN.Num
			elif CupNode2 == null:
				var _name = "2"
				_CupGroupTSCN.name = _name
				_CupGroupTSCN.position = Cup_Pos_Array[1]
				if TexNode.has_node(_name):
					var _CupNode = TexNode.get_node(_name)
					CupNode2 = _CupNode
					CupNode2_Type = _CupTypeStr
					CupNode2_Num = _CupGroupTSCN.Num
			_CupGroupTSCN.call_Put_Ani()
			HasCup_Count += _CupGroupTSCN.Num

func call_DevLogic(_butID, _Player, _DevObj):

	if HasCup_Count > 0:
		if _butID == - 1:
			ButInfo_Switch(_butID, "A")

		elif _butID == 0:
			var _OrderArray = GameLogic.Order.cur_OrderArray

			if _OrderArray.size() > 0:
				if GameLogic.Order.cur_CupArray.size() == 0:
					_TakeACup(_OrderArray[0], _Player, _DevObj)
				else:
					for y in _OrderArray.size():
						var _NewCup_Bool: bool = true
						for i in GameLogic.Order.cur_CupArray.size():
							if _NewCup_Bool:
								if _OrderArray[y] == GameLogic.Order.cur_CupArray[i]:
									_NewCup_Bool = false
						if _NewCup_Bool:
							_TakeACup(_OrderArray[y], _Player, _DevObj)
							break
func _TakeACup(_ID, _Player, _DevObj):

	GameLogic.Order.call_pickup_cup_logic(_ID, _Player.cur_Player)


	var _Dev = GameLogic.TSCNLoad.DrinkCup_TSCN.instance()
	GameLogic.Device.call_Player_Pick(_Player, _Dev)



	var CupType_menu: String
	var _OrderName = GameLogic.Order.cur_OrderList[_ID]["Name"]
	CupType_menu = GameLogic.Config.FormulaConfig[_OrderName]["CupType"]
	var CupType: String
	match CupType_menu:
		"S":
			CupType = "DrinkCup_S"
		"M":
			CupType = "DrinkCup_M"
		"L":
			CupType = "DrinkCup_L"


	_Dev.call_CupType_init(CupType, true, _Player.cur_Player)
	_Dev.cur_ID = _ID
	_Dev.get_node("CupInfo/IDLabel").text = str(_ID)
	if CupNode1_Type == CupType:

		var _AniName = str(CupNode1_Num)
		CupNode1.CupAni.play(_AniName)
		CupNode1_Num -= 1
		CupNode1.Num -= 1
		if CupNode1_Num <= 0:
			CupNode1_Num = 0
			var _CupGroup = TexNode.get_node("1")
			_CupGroup.queue_free()
			CupNode1 = null
			CupNode1_Type = null

	elif CupNode2_Type == CupType:
		var _AniName = str(CupNode2_Num)
		CupNode2.CupAni.play(_AniName)
		CupNode2_Num -= 1
		CupNode2.Num -= 1
		if CupNode2_Num <= 0:
			CupNode2_Num = 0
			var _CupGroup = TexNode.get_node("2")
			_CupGroup.queue_free()
			CupNode2 = null
			CupNode2_Type = null
