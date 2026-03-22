extends Head_Object
var SelfDev = "Plate"

var _OBJLIST: Array
var LayerA_Obj = null
var LayerB_Obj = null
var LayerX_Obj = null
var LayerY_Obj = null
onready var Layer_A = get_node("Obj_A")
onready var Layer_B = get_node("Obj_B")
onready var Layer_X = get_node("Obj_X")
onready var Layer_Y = get_node("Obj_Y")

onready var _A = get_node("But/A")
onready var _X = get_node("But/X")

var _TurnOn: bool
var IsBlackOut: bool

func But_Switch(_bool, _Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	_CanMove_Check()

	get_node("But").show()
	if not _bool:
		get_node("But").hide()
	if not _Player.Con.IsHold:
		_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_Str)
		if _OBJLIST.size():
			_X.show()
		else:
			_X.hide()
	else:
		_X.hide()
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		var _Check = return_canput_check(_Dev)
		if _Check:
			if _OBJLIST.size() < 4:
				_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_1)

	.But_Switch(_bool, _Player)
func _DayClosedCheck():
	if _TurnOn:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		GameLogic.Total_Electricity += float(5)
func _ready() -> void :
	if editor_description == "FreezerOnTable":
		SelfDev = "FreezerOnTable"
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("OpenStore", self, "_CanMove_Check"):
		var _con = GameLogic.connect("OpenStore", self, "_CanMove_Check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if CanLayout:
		CanMove = true

	_CanMove_Check()
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_turn_logic()
func _CanMove_Check():
	if get_parent().name != "ObjNode":
		if LayerA_Obj == null and LayerB_Obj == null and LayerX_Obj == null and LayerY_Obj == null:
			CanMove = true
		return
	if CanLayout:
		if LayerA_Obj == null and LayerB_Obj == null and LayerX_Obj == null and LayerY_Obj == null:
			CanMove = true

		else:
			CanMove = false

	else:
		CanMove = false
	call_turn_logic()

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if get_parent().name == "ObjNode":
		get_node("CollisionShape2D").disabled = true
	self.position = _Info.pos

	if _Info.LayerA_Obj != null:
		var _ObjInfo = _Info.LayerA_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _CUPOBJ = _TSCN.instance()
		_CUPOBJ.name = _ObjInfo.NAME

		call_CupOn(_CUPOBJ)
		_CUPOBJ.call_load(_ObjInfo)
	if _Info.LayerB_Obj != null:
		var _ObjInfo = _Info.LayerB_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _CUPOBJ = _TSCN.instance()
		_CUPOBJ.name = _ObjInfo.NAME
		call_CupOn(_CUPOBJ)
		_CUPOBJ.call_load(_ObjInfo)
	if _Info.LayerX_Obj != null:
		var _ObjInfo = _Info.LayerX_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _CUPOBJ = _TSCN.instance()
		_CUPOBJ.name = _ObjInfo.NAME
		call_CupOn(_CUPOBJ)
		_CUPOBJ.call_load(_ObjInfo)
	if _Info.LayerY_Obj != null:
		var _ObjInfo = _Info.LayerY_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _CUPOBJ = _TSCN.instance()
		_CUPOBJ.name = _ObjInfo.NAME
		call_CupOn(_CUPOBJ)
		_CUPOBJ.call_load(_ObjInfo)
	_CanMove_Check()

func call_DrinkCup_puppet():

	pass
func call_DrinkCup_Logic(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			var A_bool: bool
			var B_bool: bool
			var X_bool: bool
			var Y_bool: bool
			if LayerA_Obj:
				if LayerA_Obj.FuncType in ["Top"] and _Dev.Top == "":
					A_bool = true
				if LayerA_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					A_bool = true
				if LayerA_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerA_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						A_bool = true
				if LayerA_Obj.FuncType in ["Can"]:

					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 == "":
								A_bool = true
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 == "":
								A_bool = true
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 == "":
								A_bool = true
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								A_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								A_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								A_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								A_bool = true
			if LayerB_Obj:
				if LayerB_Obj.FuncType in ["Top"] and _Dev.Top == "":
					B_bool = true
				if LayerB_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					B_bool = true
				if LayerB_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerB_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						B_bool = true
				if LayerB_Obj.FuncType in ["Can"]:

					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 == "":
								B_bool = true
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 == "":
								B_bool = true
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 == "":
								B_bool = true
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								B_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								B_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								B_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								B_bool = true
			if LayerX_Obj:
				if LayerX_Obj.FuncType in ["Top"] and _Dev.Top == "":
					X_bool = true
				if LayerX_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					X_bool = true
				if LayerX_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerX_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						X_bool = true

				if LayerX_Obj.FuncType in ["Can"]:


					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 == "":
								X_bool = true
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 == "":
								X_bool = true
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 == "":
								X_bool = true
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								X_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								X_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								X_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								X_bool = true
			if LayerY_Obj:
				if LayerY_Obj.FuncType in ["Top"] and _Dev.Top == "":
					Y_bool = true
				if LayerY_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					Y_bool = true
				if LayerY_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerY_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						Y_bool = true
				if LayerY_Obj.FuncType in ["Can"]:

					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 == "":
								Y_bool = true
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 == "":
								Y_bool = true
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 == "":
								Y_bool = true
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								Y_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								Y_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								Y_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								Y_bool = true


			if A_bool or B_bool or X_bool or Y_bool:
				get_node("But").show()

		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerA_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerA_Obj)
				call_Ani("L")

				if LayerA_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerA_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				if LayerA_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)
				return _return
		1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerB_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerB_Obj)

				call_Ani("R")
				if LayerB_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerB_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				if LayerB_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)
				return _return
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerX_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerX_Obj)
				call_Ani("L")

				if LayerX_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerX_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				if LayerX_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)

				return _return
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerY_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerY_Obj)
				call_Ani("R")

				if LayerY_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerY_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				elif LayerY_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"EggRoll_white", "EggRoll_black":
							if _Dev.Liquid_Count > 0 and _Dev.Liquid_Count <= 2 and _Dev.Extra_1 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 2 and _Dev.Liquid_Count <= 4 and _Dev.Extra_2 != "":
								But_Switch(false, _Player)
							elif _Dev.Liquid_Count > 4 and _Dev.Liquid_Count <= 6 and _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)
				return _return
func call_Ani(_TYPE):

	if has_node("AniNode/Act"):
		match _TYPE:
			"L":

				$AniNode / Act.play("OpenLeft")

			"R":

				$AniNode / Act.play("OpenRight")
func return_canput_check(_Obj):
	if not is_instance_valid(_Obj):
		return false
	match _Obj.FuncType:
		"DrinkCup":
			return true
		_:
			return false

func call_PutOn(_butID, _Player):

	if get_parent().name != "ObjNode":
		return
	match _butID:
		- 2:
			But_Switch(false, _Player)
		- 1:


			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			But_Switch(true, _Player)

		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			call_Put(_Player)
			But_Switch(true, _Player)

		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return


func call_PutOn_puppet(_PLAYERPATH, _OBJPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj = get_node(_OBJPATH)
	if not is_instance_valid(_Obj):
		return
	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)
	match _Layer:
		"A":
			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			call_Ani("L")

			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"X":
			Layer_X.add_child(_Obj)
			LayerX_Obj = _Obj
			call_Ani("L")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"Y":
			Layer_Y.add_child(_Obj)
			LayerY_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)

	if editor_description == "FreezerOnTable":

		if _Obj.has_method("call_Info_Switch"):
			_Obj.call_Info_Switch(false)
	else:
		if _Layer in ["A", "B"]:
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
	_CanMove_Check()
	call_pick( - 1, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)
func _Touch_pup(_TYPE, _PATH, _CUPID):
	match _TYPE:
		0:
			if not SteamLogic.OBJECT_DIC.has(_CUPID):
				printerr(" DeviceLogic OBJECT_DIC 无：", _CUPID)
				return
			var _Player = get_node(_PATH)
			var _CUPOBJ = SteamLogic.OBJECT_DIC[_CUPID]
			_CUPOBJ.get_parent().remove_child(_CUPOBJ)
			call_deferred("call_CupOn", _CUPOBJ)
			if is_instance_valid(_Player):
				GameLogic.Device.call_touch(_Player, _CUPOBJ, false)
				_CUPOBJ.But_Switch(false, _Player)
		1:
			if not SteamLogic.OBJECT_DIC.has(_CUPID):
				printerr(" DeviceLogic OBJECT_DIC 无：", _CUPID)
				return
			var _Player = get_node(_PATH)
			var _CUPOBJ = SteamLogic.OBJECT_DIC[_CUPID]
			var _DEV = _CUPOBJ.get_parent().get_parent()
			_CUPOBJ.get_parent().remove_child(_CUPOBJ)
			_DEV.OnTableObj = null
			call_deferred("call_CupOn", _CUPOBJ)
			if is_instance_valid(_Player):
				_CUPOBJ.But_Switch(false, _Player)
func call_Cup_Touch(_ButID, _CUPOBJ, _Player):
	var _PAR = _CUPOBJ.get_parent().name
	if _PAR in ["Items"]:
		var _NUM = _OBJLIST.size()
		if _NUM >= 4:
			return false
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return

		GameLogic.Device.call_touch(_Player, _CUPOBJ, false)
		call_deferred("_Touch_Logic", 0, _CUPOBJ, _Player)

	elif _PAR in ["ObjNode"]:
		var _DEV = _CUPOBJ.get_parent().get_parent()
		var _x = _DEV.get("OnTableObj")
		if _DEV.get("OnTableObj") == _CUPOBJ:
			match _ButID:
				- 2:
					_CUPOBJ.But_Switch(false, _Player)
				- 1:
					_CUPOBJ.But_Switch(true, _Player)
				0:

					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if _OBJLIST.size() >= 4:
						return false
					call_deferred("_Touch_Logic", 1, _CUPOBJ, _Player)
func _Touch_Logic(_TYPE: int, _CUPOBJ, _Player):
	match _TYPE:
		0:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYERPATH = _Player.get_path()
				SteamLogic.call_puppet_id_sync(_SELFID, "_Touch_pup", [0, _PLAYERPATH, _CUPOBJ._SELFID])
			_CUPOBJ.get_parent().remove_child(_CUPOBJ)
			call_deferred("call_CupOn", _CUPOBJ)
			_CUPOBJ.But_Switch(false, _Player)
		1:
			var _DEV = _CUPOBJ.get_parent().get_parent()
			if is_instance_valid(_DEV):
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAYERPATH = _Player.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "_Touch_pup", [1, _PLAYERPATH, _CUPOBJ._SELFID])
				_CUPOBJ.get_parent().remove_child(_CUPOBJ)

				_DEV.OnTableObj = null
				call_CupOn(_CUPOBJ)
				_CUPOBJ.But_Switch(false, _Player)

func call_CupOn_pup(_CUPOBJ):

	_CUPOBJ.position = Vector2.ZERO

	if _CUPOBJ.has_method("call_Info_Switch"):
		_CUPOBJ.call_Info_Switch(false)
	if _CUPOBJ.has_method("call_reset_pickup"):
		_CUPOBJ.call_reset_pickup()
	if _CUPOBJ.has_method("call_Collision_Switch"):
		_CUPOBJ.call_deferred("call_Collision_Switch", false)
func call_CupOn(_CUPOBJ):

	_CUPOBJ.position = Vector2.ZERO
	_OBJLIST.append(_CUPOBJ)
	if not Layer_A.get_child_count():
		Layer_A.add_child(_CUPOBJ)
	elif not Layer_B.get_child_count():
		Layer_B.add_child(_CUPOBJ)
	elif not Layer_X.get_child_count():
		Layer_X.add_child(_CUPOBJ)
	elif not Layer_Y.get_child_count():
		Layer_Y.add_child(_CUPOBJ)

	if _CUPOBJ.has_method("call_Info_Switch"):
		_CUPOBJ.call_Info_Switch(false)
	if _CUPOBJ.has_method("call_reset_pickup"):
		_CUPOBJ.call_reset_pickup()
	if _CUPOBJ.has_method("call_Collision_Switch"):
		_CUPOBJ.call_deferred("call_Collision_Switch", false)
	_CUPOBJ.call_But_hide()

func put_pup(_PLAYERPATH, _CUPID):
	if not SteamLogic.OBJECT_DIC.has(_CUPID):
		printerr(" OBJECT_DIC 未找到物品：", _CUPID)
		return
	var _Player = get_node(_PLAYERPATH)
	var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
	_Put_Logic(_Player, _CUP)
	_Player.Stat.call_carry_off_puppet()
	But_Switch(true, _Player)
func call_Put(_Player):
	if _OBJLIST.size() >= 4:
		return
	var _CUP = instance_from_id(_Player.Con.HoldInsId)
	if is_instance_valid(_CUP):
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "put_pup", [_PLAYERPATH, _CUP._SELFID])
		_Put_Logic(_Player, _CUP)
func _Put_Logic(_Player, _CUP):
	_Player.WeaponNode.remove_child(_CUP)
	_Player.Stat.call_carry_off()
	call_CupOn(_CUP)
	var _AUDIO = GameLogic.Audio.return_Effect("放下")
	_AUDIO.play(0)
	_CUP.But_Switch(false, _Player)
func return_CUP():
	return _OBJLIST.back()
func return_Remove_CUP(_CUP):
	if _OBJLIST.has(_CUP):
		_OBJLIST.erase(_CUP)
		_CUP.get_parent().remove_child(_CUP)
		return true
	return false

func _PickCup(_Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _NUM = _OBJLIST.size()
	var _CUP = _OBJLIST.pop_back()
	if is_instance_valid(_CUP):
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "Pick_pup", [_PLAYERPATH, _CUP._SELFID])
		GameLogic.Device.call_Player_Pick(_Player, _CUP)


		if _CUP.has_method("call_CupInfo_Switch"):
			if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				_CUP.call_CupInfo_Switch(true)
func Pick_pup(_PLAYERPATH, _CUPID):
	if not SteamLogic.OBJECT_DIC.has(_CUPID):
		printerr(" OBJECT_DIC 未找到物品：", _CUPID)
		return
	var _Player = get_node(_PLAYERPATH)
	var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
	if _OBJLIST.has(_CUP):
		_OBJLIST.erase(_CUP)
	if _CUP.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_CUP.call_CupInfo_Switch(true)
	But_Switch(true, _Player)
func _PutOn(_Layer, _Player):
	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Obj = instance_from_id(_Player.Con.HoldInsId)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _OBJPATH = _Obj.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOn_puppet", [_PLAYERPATH, _OBJPATH, _Layer])

	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)

	match _Layer:
		"A":
			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			call_Ani("L")

			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"X":
			Layer_X.add_child(_Obj)
			LayerX_Obj = _Obj
			call_Ani("L")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"Y":
			Layer_Y.add_child(_Obj)
			LayerY_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
	if editor_description == "FreezerOnTable":
		if _Obj.has_method("call_Freezer_Switch"):
			_Obj.call_Freezer_Switch(true)
		if _Obj.has_method("call_Defrost_Switch"):
			_Obj.call_Defrost_Switch(1)
		if _Obj.has_method("call_Freezer_ColdTimer"):
			_Obj.call_Freezer_ColdTimer()
		if _Obj.has_method("call_Info_Switch"):
			_Obj.call_Info_Switch(false)
	else:
		if _Layer in ["A", "B"]:
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
	_CanMove_Check()
	call_pick( - 1, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)
	return "台架放入"

func call_pick(_butID, _Player):

	match _butID:
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _Player.IsStaff:
				return

			$But.show()

		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			_PickCup(_Player)
			But_Switch(true, _Player)

	_CanMove_Check()
	return "台架取出"
func call_pick_puppet(_PLAYERPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj
	match _Layer:
		"A":
			_Obj = LayerA_Obj
			if not is_instance_valid(_Obj):
				return

			LayerA_Obj = null
			call_Ani("L")
		"B":
			_Obj = LayerB_Obj
			if not is_instance_valid(_Obj):
				return

			LayerB_Obj = null
			call_Ani("R")
		"X":
			_Obj = LayerX_Obj
			if not is_instance_valid(_Obj):
				return

			LayerX_Obj = null
			call_Ani("L")
		"Y":
			_Obj = LayerY_Obj
			if not is_instance_valid(_Obj):
				return

			LayerY_Obj = null
			call_Ani("R")

	if _Obj.has_method("call_Defrost_Switch"):
		_Obj.call_Defrost_Switch(0)
	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _Obj)

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)
	call_PutOn( - 1, _Player)
func _pick(_Layer, _Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_puppet", [_PLAYERPATH, _Layer])
	var _Obj
	match _Layer:
		"A":
			_Obj = LayerA_Obj

			LayerA_Obj = null
			call_Ani("L")
		"B":
			_Obj = LayerB_Obj

			LayerB_Obj = null
			call_Ani("R")
		"X":
			_Obj = LayerX_Obj

			LayerX_Obj = null
			call_Ani("L")
		"Y":
			_Obj = LayerY_Obj

			LayerY_Obj = null
			call_Ani("R")

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)
	if _Obj.has_method("call_Defrost_Switch"):
		_Obj.call_Defrost_Switch(0)
	GameLogic.Device.call_Player_Pick(_Player, _Obj)

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)

func call_turn_logic():
	if SelfDev == "Shelf_OnTable":
		return
	if IsBlackOut:

		return
	if LayerA_Obj or LayerB_Obj or LayerX_Obj or LayerY_Obj:
		_TurnOn = true

	else:
		_TurnOn = false

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func _on_Timer_timeout():
	GameLogic.Total_Electricity += 0.1
