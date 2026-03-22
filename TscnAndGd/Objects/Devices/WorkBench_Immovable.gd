extends Head_Object
var SelfDev = "WorkBench_Immovable"

export var CanPutDev: bool = true
export var Tex: int = 1
var TableItemOffset = Vector2(0, - 70)
onready var Name = self.editor_description
onready var _ShapeOffset = get_node("CollisionShape2D").position
onready var ObjNode = $ObjNode
var CurObj
var CurSelect
onready var RayL_1 = get_node("RayL_Up")
onready var RayL_2 = get_node("RayL_Down")
onready var RayR_1 = get_node("RayR_Up")
onready var RayR_2 = get_node("RayR_Down")

onready var L_Single = get_node("TexNode/Single/L")
onready var R_Single = get_node("TexNode/Single/R")
onready var L_Show = get_node("TexNode/Connect/L")
onready var R_Show = get_node("TexNode/Connect/R")
onready var TypeAni = get_node("TexNode/TypeAni")
onready var TakeAni = get_node("TexNode/TakeNode/TakeAni")
onready var PayNode = get_node("TexNode/PayNode")

func _ready() -> void :

	call_init(SelfDev)
	call_deferred("call_connect_check")
	TypeAni.play(str(Tex))

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("OutLineAni").play("show")
		false:
			get_node("OutLineAni").play("init")

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("Tex"):
		Tex = _Info.Tex
		if TypeAni.has_animation(str(_Info.Tex)):
			TypeAni.play(str(_Info.Tex))
	if _Info.Table:
		var _TableData = _Info.Table
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_TableData.TSCN)
		var _Dev = _TSCN.instance()
		_Dev.position = _TableData.pos
		_Dev.name = _TableData.NAME
		ObjNode.add_child(_Dev)
		_Dev.call_load(_TableData)
		OnTableObj = _Dev
	if _Info.has("CanPutDev"):
		CanPutDev = _Info.CanPutDev

func call_OnTable(_Obj):

	if _Obj == null:
		OnTableObj = _Obj
		return
	if _Obj.get_parent().get_parent() == self:
		OnTableObj = _Obj
func call_Box_OnTable(_ButID, _CupObj, _Player):
	if is_instance_valid(OnTableObj):
		if OnTableObj.FuncType == "Box":
			if OnTableObj.has_method("call_PickFruitInCup"):
				OnTableObj.call_PickFruitInCup(_ButID, _CupObj, _Player)
func But_Switch(_bool, _Player):

	if _Player.cur_RayObj != self:
		_bool = false
		call_OutLine(false)
	.But_Switch(_bool, _Player)
func call_puppet_pick_Wrong():
	TakeAni.play("wrong")
	var _DevObj = OnTableObj
	_DevObj.call_finish(false)

func call_pickup_logic(_ButID, _Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _DevObj = OnTableObj
	if not is_instance_valid(OnTableObj):
		return
	if OnTableObj.FuncType in ["SodaCan"]:
		match _ButID:
			3:
				if not OnTableObj.IsPack:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoPick()
					return
				if not OnTableObj.cur_ID:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoTicket()
					return
				if not GameLogic.Order.return_HasOrder(OnTableObj.cur_ID):
					OnTableObj.call_OverID()
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_OverID()
					return
				if not GameLogic.Order.return_PickOrder_Check(OnTableObj.cur_ID):
					return
				CurSelect = _DevObj.cur_ID
				var _check = GameLogic.Order.return_CanPickCheck_Bool(_DevObj)
				printerr("出杯判断：", _check, _DevObj.LIQUID_DIR)
				if _Player.Stat.Skills.has("技能-强卖"):
					if _check.WrongType < 0:
						_check.WrongType = 1
				if _check.WrongType != 1:


					if _check in [ - 3]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_WrongCup()
					elif _check in [ - 1]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoHang()
					elif _check in [ - 2]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoTop()
					else:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_DrinkWrong()
					TakeAni.play("wrong")
					_DevObj.call_finish(false)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_pick_Wrong")
					return
				var _NPC = GameLogic.Order.return_Picker_Order_PickUp(CurSelect)
				_DevObj.SELLPLAYER = _Player
				if _NPC.IsSit:
					_DevObj.call_table()

					return
				_DevObj.call_finish(true)

				_NPC.call_pickup(self, _check)
				return "出杯"
	elif OnTableObj.FuncType in ["DrinkCup", "SuperCup", "EggRollCup", "BeerCup"]:
		match _ButID:
			3:

				if not OnTableObj.cur_ID:

					if OnTableObj.FuncType in ["DrinkCup", "SuperCup", "EggRollCup", "BeerCup"]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoTicket()
						return
				if not GameLogic.Order.return_HasOrder(OnTableObj.cur_ID):
					OnTableObj.call_OverID()
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_OverID()
					return
				if OnTableObj.has_method("return_finish"):
					if OnTableObj.return_finish():
						return
				if OnTableObj.get("IsDirty"):

					return
				CurSelect = _DevObj.cur_ID
				var _check = GameLogic.Order.return_CanPickCheck_Bool(_DevObj)
				if _Player.Stat.Skills.has("技能-强卖"):
					if _check.WrongType < 0:
						_check.WrongType = 1
				if _check.WrongType != 1:


					if _check in [ - 3]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_WrongCup()
					elif _check in [ - 1]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoHang()
					elif _check in [ - 2]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoTop()
					else:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_DrinkWrong()
					TakeAni.play("wrong")
					_DevObj.call_finish(false)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_pick_Wrong")
					return

				var _NPC = GameLogic.Order.return_Picker_Order_PickUp(CurSelect)

				_DevObj.SELLPLAYER = _Player
				if _NPC.IsSit:
					_DevObj.call_table()

					return

				_DevObj.call_finish(true)


				_NPC.call_pickup(self, _check)

				return "出杯"

func call_reset_pickup():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if OnTableObj.FuncType == "DrinkCup":
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(int(OnTableObj.name), "call_Sell_hide")
		CurSelect = OnTableObj.cur_ID
		OnTableObj.call_Sell_hide()
		var _NPC = GameLogic.Order.return_Picker_Order_PickUp(CurSelect)
		if is_instance_valid(_NPC):
			if _NPC.IsPickUp:
				_NPC.call_pickUp_false(CurSelect)

func call_NoPut():
	if TakeAni.current_animation != "NoPut":
		TakeAni.play("NoPut")

func return_CanPickCheck_Bool():
	var _Dev = OnTableObj
	var _orderid = _Dev.cur_ID


	var _LiquidMax: int = 0
	match _Dev.TYPE:
		"DrinkCup_S":
			_LiquidMax = 2
		"DrinkCup_M":
			_LiquidMax = 4
		"DrinkCup_L":
			_LiquidMax = 6

	if _Dev.Liquid_Count < _LiquidMax:

		return false


	var _check: Dictionary = {
		"Total": 0,
		"Celcius": 0,
		"Sugar": 0,
		"Extra": 0,
		"ExtraMax": 0,

		"Mixd": 0,

		"SugarIn": true,
		"Condiment_1": 0,
		"Top": "",
		"IsPassDay": _Dev.IsPassDay,



	}

	if GameLogic.Order.cur_OrderList.has(_orderid):
		var _orderInfo = GameLogic.Order.cur_OrderList[_orderid]
		var _name = _orderInfo["Name"]
		var _INFO = GameLogic.Config.FormulaConfig[_name]
		if _Dev.Top != _INFO.Top:
			return false

		var _Celcius = _orderInfo["Celcius"]
		var _Sugar = _orderInfo["Sugar"]
		var _CupCelcius = _Dev.Celcius
		var _CupSugar: int
		match _Dev.SugarType:
			1:
				_CupSugar = GameLogic.Order.SUGARTYPE.SUGAR
				_check.SugarIn = true
			2:
				_CupSugar = GameLogic.Order.SUGARTYPE.FREE
				_check.SugarIn = true
			0:
				_CupSugar = GameLogic.Order.SUGARTYPE.NOSUGAR
				_check.SugarIn = false

		var _NeedMix = int(_INFO.Mixd)
		match _NeedMix:
			0:

				pass
			1:
				_check.Total += 1

				if _Dev.Is_Mix:
					_check.Mixd = 1
			2:
				if not _Dev.Is_Mix:
					_check.Mixd = 1

		var _ExtraList: Array
		if _Dev.Extra_1 != "":
			_ExtraList.append(_Dev.Extra_1)
		if _Dev.Extra_2 != "":
			_ExtraList.append(_Dev.Extra_2)
		if _Dev.Extra_3 != "":
			_ExtraList.append(_Dev.Extra_3)
		if _Dev.get("Extra_4") != "":
			_ExtraList.append(_Dev.Extra_4)
		if _Dev.get("Extra_5") != "":
			_ExtraList.append(_Dev.Extra_5)

		if _orderInfo.ExtraArray.size() != 0:
			_check.ExtraMax = _orderInfo.ExtraArray.size()
			_check.Total += _check.ExtraMax

			for i in 3:
				if _orderInfo.ExtraArray.size() >= (i + 1):
					if _ExtraList.size() >= (i + 1):
						if _orderInfo.ExtraArray[i] == _ExtraList[i]:
							_check.Extra += 1




		_check.Total += 1

		if _Celcius == _CupCelcius:
			_check.Celcius = 1
		elif GameLogic.cur_Event == "无冰日":
			pass

		_check.Total += 1

		if _Sugar == _CupSugar:
			_check.Sugar = 1
		else:
			_check.Sugar = 0


		if _INFO.Condiment_1:

			_check.Total += 1
			if _Dev.Condiment_1 == _INFO.Condiment_1:
				_check.Condiment_1 = 1

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
			return _check
		else:
			printerr("未全部匹配：", _Dev.LIQUID_DIR)




	else:
		printerr("无效ID")
		return false

func _cupMove_to_PickUp(_Player):
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	_Player.WeaponNode.remove_child(_Dev)

	_Player.Stat.call_carry_off()
	ObjNode.add_child(_Dev)
	CurObj = _Dev



	CurSelect = _Dev.cur_ID
	var _NPC = GameLogic.Order.return_Picker_Order_PickUp(CurSelect)
	_NPC.call_pickup(self)

func call_connect_check():
	L_Single.show()
	R_Single.show()
	L_Show.hide()
	R_Show.hide()
	if RayL_1.is_inside_tree():
		RayL_1.force_raycast_update()
		if RayL_1.is_colliding():
			var collider_L_1 = RayL_1.get_collider()
			if collider_L_1.editor_description in ["WorkBench_Immovable", "WorkBench"]:
				if collider_L_1.visible:
					L_Show.show()
					L_Single.hide()
		RayR_1.force_raycast_update()
		if RayR_1.is_colliding():
			var collider_R_1 = RayR_1.get_collider()
			if collider_R_1.editor_description in ["WorkBench_Immovable", "WorkBench"]:
				if collider_R_1.visible:
					R_Show.show()
					R_Single.hide()

func call_player_leave(_PLAYER):
	if is_instance_valid(OnTableObj):
		if OnTableObj.has_method("call_player_leave"):
			OnTableObj.call_player_leave(_PLAYER)
		var _TYPE = OnTableObj.get("FuncType")

		if OnTableObj.get("TypeStr") == "InductionCooker":
			var _OBJ = OnTableObj.OnTableObj
			if is_instance_valid(_OBJ):
				if _OBJ.has_method("call_player_leave"):
					_OBJ.call_player_leave(_PLAYER)
		if _TYPE in ["Beer"]:

			if OnTableObj._PlayerOBJ == _PLAYER:
				OnTableObj.call_Switch(false)
