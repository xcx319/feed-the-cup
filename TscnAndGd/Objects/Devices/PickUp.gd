extends Head_Object

var KeyList
var OrderNum
var CurSelect
var CurNum = 0
var CurObj

onready var SingleNode = get_node("PutNode/single")
onready var DoubleNode1 = get_node("PutNode/double1")
onready var DoubleNode2 = get_node("PutNode/double2")
onready var SquareNode1 = get_node("PutNode/square1")
onready var SquareNode2 = get_node("PutNode/square2")
onready var SquareNode3 = get_node("PutNode/square3")
onready var SquareNode4 = get_node("PutNode/square4")

func _ready() -> void :
	call_init("PickUp")

func call_Put_DrinkCup_On(_ButID, _Player, _DevObj):

	var _CanPut = return_CanPutCheck_Bool(_Player)

	if _CanPut:
		match _ButID:
			- 2:
				But_Switch(false, _Player)
			- 1:
				But_Switch(true, _Player)
			0:

				_CanPut = return_CanPutCheck_Bool(_Player)
				if _CanPut:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					_cupMove_to_PickUp(_Player)


func return_CanPutCheck_Bool(_Player):
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	var _orderid = _Dev.cur_ID

	if GameLogic.Order.cur_OrderList.has(_orderid):
		var _orderInfo = GameLogic.Order.cur_OrderList[_orderid]
		var _name = _orderInfo["Name"]


		var _Celcius = _orderInfo["Celcius"]
		var _Sugar = _orderInfo["Sugar"]
		var _CupCelcius = _Dev.Celcius
		var _CupSugar: int
		match _Dev.SugarType:
			1:
				_CupSugar = GameLogic.Order.SUGARTYPE.SUGAR
			2:
				_CupSugar = GameLogic.Order.SUGARTYPE.FREE
			0:
				_CupSugar = GameLogic.Order.SUGARTYPE.NOSUGAR

		if _Celcius != _CupCelcius:
			return false
		if _Sugar != _CupSugar:
			return false

		var _Formula_List = GameLogic.Order.cur_menu[_name]["Formula_List"]
		var _Cup_WaterType_Array = _Dev.LIQUID_DIR.keys()

		var _Formula_keys = _Formula_List.keys()
		var _ForCheck: bool = true
		for i in _Formula_List.size():
			var _Formula = GameLogic.Liquid.return_WATERTYPE_StrName(_Formula_keys[i])
			var _Formula_Num = int(_Formula_List[_Formula_keys[i]])

			var _Cup_Num: int = 0
			if _Dev.LIQUID_DIR.has(_Formula):
				_Cup_Num = _Dev.LIQUID_DIR[_Formula]
			if _Formula_Num != _Cup_Num:
				_ForCheck = false
		if _ForCheck:
			return true
	else:
		return false

func _cupMove_to_PickUp(_Player):
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	_Player.WeaponNode.remove_child(_Dev)
	_Player.Stat.call_carry_off()
	SingleNode.add_child(_Dev)
	CurObj = _Dev



	CurSelect = _Dev.cur_ID

	var _NPC = GameLogic.Order.return_Picker_Order_PickUp(CurSelect)

	_NPC.call_pickup(self)
