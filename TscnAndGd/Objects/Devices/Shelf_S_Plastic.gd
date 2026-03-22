extends Head_Object

var SelfDev = "Shelf_GlassCup"
var TableItemOffset = Vector2(0, - 70)

var PutOnPos_Array: Array

var layer1_Array: Array = []
var Layer1_Item
var layer2_Array: Array = []
var Layer2_Item
var layer3_Array: Array = []
var Layer3_Item
var layer4_Array: Array = []
var Layer4_Item
var Layer1_Weight: int = 0
var Layer2_Weight: int = 0
var Layer3_Weight: int = 0
var Layer4_Weight: int = 0
onready var _ShapeOffset = get_node("CollisionShape2D").position

onready var Layer1 = get_node("TexNode/layer1")
onready var Layer2 = get_node("TexNode/layer2")
onready var Layer3 = get_node("TexNode/layer3")
onready var Layer4 = get_node("TexNode/layer4")

onready var GuideNode = get_node("GuideNode")
onready var GuideAni = get_node("GuideNode/Ani")

onready var _A = get_node("But/A")
onready var _B = get_node("But/B")
onready var _X = get_node("But/X")
onready var _Y = get_node("But/Y")

var _TURN: bool
var Electricity_Base: float = 1

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func _But_Plate(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.cur_RayObj != self:
		_A.call_player_out(_Player.cur_Player)
		_B.call_player_out(_Player.cur_Player)
		_Y.call_player_out(_Player.cur_Player)
		_X.call_player_out(_Player.cur_Player)
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	if not is_instance_valid(_Dev):
		return
	var _OBJNUM: int = _Dev._OBJLIST.size()
	if _OBJNUM:
		for _CUP in _Dev._OBJLIST:
			var b1_bool: bool
			var b2_bool: bool
			var b3_bool: bool
			var b4_bool: bool
			if Layer1_Item == _CUP.TypeStr or Layer1_Item == null:
				b1_bool = true
			if Layer2_Item == _CUP.TypeStr or Layer2_Item == null:
				b2_bool = true
			if Layer3_Item == _CUP.TypeStr or Layer3_Item == null:
				b3_bool = true
			if Layer4_Item == _CUP.TypeStr or Layer4_Item == null:
				b4_bool = true



			if _Player.IsStaff:
				return
			if b1_bool:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if b2_bool:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)
			if b3_bool:
				_Y.call_player_in(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)
			if b4_bool:
				_X.call_player_in(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)
	else:
		var b1_bool: bool
		var b2_bool: bool
		var b3_bool: bool
		var b4_bool: bool
		if Layer1_Item != null:
			b1_bool = true
		if Layer2_Item != null:
			b2_bool = true
		if Layer3_Item != null:
			b3_bool = true
		if Layer4_Item != null:
			b4_bool = true



		if b1_bool:
			_A.call_player_in(_Player.cur_Player)
		else:
			_A.call_player_out(_Player.cur_Player)
		if b2_bool:
			_B.call_player_in(_Player.cur_Player)
		else:
			_B.call_player_out(_Player.cur_Player)
		if b3_bool:
			_Y.call_player_in(_Player.cur_Player)
		else:
			_Y.call_player_out(_Player.cur_Player)
		if b4_bool:
			_X.call_player_in(_Player.cur_Player)
		else:
			_X.call_player_out(_Player.cur_Player)
func _But_Show(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	if _Player.cur_RayObj != self:
		_A.call_player_out(_Player.cur_Player)
		_B.call_player_out(_Player.cur_Player)
		_Y.call_player_out(_Player.cur_Player)
		_X.call_player_out(_Player.cur_Player)
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	if not is_instance_valid(_Dev):
		return
	if _Dev.IsItem:
		var b1_bool: bool
		var b2_bool: bool
		var b3_bool: bool
		var b4_bool: bool
		if Layer1_Item == _Dev.TypeStr or Layer1_Item == null:
			b1_bool = true
		if Layer2_Item == _Dev.TypeStr or Layer2_Item == null:
			b2_bool = true
		if Layer3_Item == _Dev.TypeStr or Layer3_Item == null:
			b3_bool = true
		if Layer4_Item == _Dev.TypeStr or Layer4_Item == null:
			b4_bool = true



		if _Player.IsStaff:
			return
		if b1_bool:
			_A.call_player_in(_Player.cur_Player)
		else:
			_A.call_player_out(_Player.cur_Player)
		if b2_bool:
			_B.call_player_in(_Player.cur_Player)
		else:
			_B.call_player_out(_Player.cur_Player)
		if b3_bool:
			_Y.call_player_in(_Player.cur_Player)
		else:
			_Y.call_player_out(_Player.cur_Player)
		if b4_bool:
			_X.call_player_in(_Player.cur_Player)
		else:
			_X.call_player_out(_Player.cur_Player)
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _bool:
		_But_Show(_Player)
	.But_Switch(_bool, _Player)
func _ready() -> void :

	call_init(SelfDev)
	GuideNode.hide()
	$But.show()
	if get_parent().name == "Updates":
		GuideAni.play("show")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _CON = GameLogic.connect("CloseLight", self, "_DayClosedCheck")

	if GameLogic.LoadingUI.IsHome:
		PutOnPos_Array.clear()
		for i in 8:
			if i < 4:
				var _x = 30 + i * 40
				PutOnPos_Array.append(Vector2(_x, 30))
			else:
				var _x = 50 + (i - 4) * 40
				PutOnPos_Array.append(Vector2(_x, 50))

		for _i in 4:
			call_Pos_init(_i + 1)
func call_Pos_init(_Layer: int):
	var _CUPLIST: Array
	match _Layer:
		1:
			_CUPLIST = Layer1.get_children()
		2:
			_CUPLIST = Layer2.get_children()
		3:
			_CUPLIST = Layer3.get_children()
		4:
			_CUPLIST = Layer4.get_children()
	for _i in _CUPLIST.size():
			var _CUP = _CUPLIST[_i]
			_CUP.position = PutOnPos_Array[_i]
func _DayClosedCheck():
	if SelfDev == "FreezeShelf":
		var _ITEMNUM: int = layer1_Array.size() + layer2_Array.size() + layer3_Array.size() + layer4_Array.size()
		GameLogic.Total_Electricity += float(_ITEMNUM * Electricity_Base)

func _del_item():
	if SelfDev == "FreezeShelf":
		var _ITEMNUM: int = layer1_Array.size() + layer2_Array.size() + layer3_Array.size() + layer4_Array.size()
		GameLogic.Total_Electricity += float(_ITEMNUM * Electricity_Base)

	for _ITEM in Layer1.get_children():
		if is_instance_valid(_ITEM):
			Layer1.remove_child(_ITEM)
			_ITEM.queue_free()

	for _ITEM in Layer2.get_children():
		if is_instance_valid(_ITEM):
			Layer2.remove_child(_ITEM)
			_ITEM.queue_free()

	for _ITEM in Layer3.get_children():
		if is_instance_valid(_ITEM):
			Layer3.remove_child(_ITEM)
			_ITEM.queue_free()

	for _ITEM in Layer4.get_children():
		if is_instance_valid(_ITEM):
			Layer4.remove_child(_ITEM)
			_ITEM.queue_free()

func call_guide_hide():
	GuideNode.hide()
func call_guide_show():
	GuideNode.show()
func _set_pos(_Obj):
	PutOnPos_Array.clear()

	if _Obj.IsItem:
		match _Obj.Weight:
			1, 0:
				for i in 8:
					if i < 4:
						var _x = 30 + i * 40
						PutOnPos_Array.append(Vector2(_x, 30))
					else:
						var _x = 50 + (i - 4) * 40
						PutOnPos_Array.append(Vector2(_x, 50))
			2:
				for i in 4:
					if i < 2:
						var _x = - 12 + i * 24
						PutOnPos_Array.append(Vector2(_x, - 10))
					else:
						var _x = - 12 + (i - 2) * 24
						PutOnPos_Array.append(Vector2(_x, 5))
			4:
				pass

func _ObjLoad(_Obj, _Layer):
	_set_pos(_Obj)
	match _Layer:
		1:
			_Obj.position = PutOnPos_Array[layer1_Array.size()]
			Layer1.add_child(_Obj)
			layer1_Array.append(_Obj)

		2:
			_Obj.position = PutOnPos_Array[layer2_Array.size()]
			Layer2.add_child(_Obj)
			layer2_Array.append(_Obj)


		3:
			_Obj.position = PutOnPos_Array[layer3_Array.size()]
			Layer3.add_child(_Obj)
			layer3_Array.append(_Obj)


		4:
			_Obj.position = PutOnPos_Array[layer4_Array.size()]
			Layer4.add_child(_Obj)
			layer4_Array.append(_Obj)


func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME

	.call_Ins_Save(_SELFID)

	if _Info.has("Layer1_Array"):
		if _Info.Layer1_Array.size():
			for _ObjInfo in _Info.Layer1_Array:
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
				var _Obj = _TSCN.instance()
				if _Info.has("NAME"):
					_Obj.name = _Info.NAME

				else:
					_Obj.name = str(get_instance_id())
				var _INFOLoad = _ObjInfo.TSCN
				if _INFOLoad == "Extra": _INFOLoad = _ObjInfo.TypeStr
				_Obj.call_init(_INFOLoad)

				_ObjLoad(_Obj, 1)
				_Obj.call_load(_ObjInfo)
				if _Obj.has_method("call_Info_Switch"):
					_Obj.call_Info_Switch(false)
				Layer1_Weight += _Obj.Weight
		if _Info.Layer2_Array.size():
			for _ObjInfo in _Info.Layer2_Array:
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
				var _Obj = _TSCN.instance()
				if _Info.has("NAME"):
					_Obj.name = _Info.NAME

				else:
					_Obj.name = str(get_instance_id())
				var _INFOLoad = _ObjInfo.TSCN
				if _INFOLoad == "Extra": _INFOLoad = _ObjInfo.TypeStr
				_Obj.call_init(_INFOLoad)

				_ObjLoad(_Obj, 2)
				_Obj.call_load(_ObjInfo)
				if _Obj.has_method("call_Info_Switch"):
					_Obj.call_Info_Switch(false)
				Layer2_Weight += _Obj.Weight
		if _Info.Layer3_Array.size():
			for _ObjInfo in _Info.Layer3_Array:
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
				var _Obj = _TSCN.instance()
				if _Info.has("NAME"):
					_Obj.name = _Info.NAME

				else:
					_Obj.name = str(get_instance_id())
				var _INFOLoad = _ObjInfo.TSCN
				if _INFOLoad == "Extra": _INFOLoad = _ObjInfo.TypeStr
				_Obj.call_init(_INFOLoad)

				_ObjLoad(_Obj, 3)
				_Obj.call_load(_ObjInfo)
				if _Obj.has_method("call_Info_Switch"):
					_Obj.call_Info_Switch(false)
				Layer3_Weight += _Obj.Weight
		if _Info.Layer4_Array.size():
			for _ObjInfo in _Info.Layer4_Array:
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
				var _Obj = _TSCN.instance()
				if _Info.has("NAME"):
					_Obj.name = _Info.NAME

				else:
					_Obj.name = str(get_instance_id())
				var _INFOLoad = _ObjInfo.TSCN
				if _INFOLoad == "Extra": _INFOLoad = _ObjInfo.TypeStr
				_Obj.call_init(_INFOLoad)

				_ObjLoad(_Obj, 4)
				_Obj.call_load(_ObjInfo)
				if _Obj.has_method("call_Info_Switch"):
					_Obj.call_Info_Switch(false)
				Layer4_Weight += _Obj.Weight

	if _Info.has("Layer1_Item"):
		Layer1_Item = _Info.Layer1_Item
	if _Info.has("Layer2_Item"):
		Layer2_Item = _Info.Layer2_Item
	if _Info.has("Layer3_Item"):
		Layer3_Item = _Info.Layer3_Item
	if _Info.has("Layer4_Item"):
		Layer4_Item = _Info.Layer4_Item
	call_TurnAni()
	_CupLogic(true, 1)
	_CupLogic(true, 2)
	_CupLogic(true, 3)
	_CupLogic(true, 4)
func call_PutOn(_butID, _Player):

	if _butID == - 1:
		_But_Show(_Player)

	elif _butID == 0:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer1_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer1_Item != null:
				if Layer1_Item == _Dev.TypeStr:
					var _put = _PutOn(1, _Player)
					call_pick( - 1, _Player, _Dev)
					return _put
			else:
				var _put = _PutOn(1, _Player)
				call_pick( - 1, _Player, _Dev)
				return _put
		elif _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
			_Player.call_Say_NoUse()
	elif _butID == 1:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer2_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer2_Item != null:
				if Layer2_Item == _Dev.TypeStr:
					var _put = _PutOn(2, _Player)
					call_pick( - 1, _Player, _Dev)
					return _put
			else:
				var _put = _PutOn(2, _Player)
				call_pick( - 1, _Player, _Dev)
				return _put
		elif _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
			_Player.call_Say_NoUse()
	elif _butID == 3:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer3_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer3_Item != null:
				if Layer3_Item == _Dev.TypeStr:
					var _put = _PutOn(3, _Player)
					call_pick( - 1, _Player, _Dev)
					return _put
			else:
				var _put = _PutOn(3, _Player)
				call_pick( - 1, _Player, _Dev)
				return _put
		elif _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
			_Player.call_Say_NoUse()
	elif _butID == 2:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer4_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer4_Item != null:
				if Layer4_Item == _Dev.TypeStr:
					var _put = _PutOn(4, _Player)
					call_pick( - 1, _Player, _Dev)
					return _put
			else:
				var _put = _PutOn(4, _Player)
				call_pick( - 1, _Player, _Dev)
				return _put
		elif _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
			_Player.call_Say_NoUse()
func call_PutOn_puppet(_Layer, _PLAYERPATH, _DevID):
	var _Player = get_node(_PLAYERPATH)
	if SteamLogic.OBJECT_DIC.has(_DevID):
		var _Dev = SteamLogic.OBJECT_DIC[_DevID]
		PutOn_Logic(_Layer, _Player, _Dev)
		call_pick( - 1, _Player, null)
		return true

func call_Plate_pup(_Layer, _CUPID, _PLATEID, _POS, _LIST):
	if SteamLogic.OBJECT_DIC.has(_CUPID):
		if SteamLogic.OBJECT_DIC.has(_PLATEID):
			var _PLATE = SteamLogic.OBJECT_DIC[_PLATEID]
			var _BEERCUP = SteamLogic.OBJECT_DIC[_CUPID]
			match _Layer:
				1:

					_BEERCUP.get_parent().remove_child(_BEERCUP)
					_BEERCUP.position = _POS
					Layer1.add_child(_BEERCUP)
					layer1_Array.append(_BEERCUP)

				2:

					_BEERCUP.get_parent().remove_child(_BEERCUP)
					_BEERCUP.position = _POS
					Layer2.add_child(_BEERCUP)
					layer2_Array.append(_BEERCUP)

				3:

					_BEERCUP.get_parent().remove_child(_BEERCUP)
					_BEERCUP.position = _POS
					Layer3.add_child(_BEERCUP)
					layer3_Array.append(_BEERCUP)

				4:

					_BEERCUP.get_parent().remove_child(_BEERCUP)
					_BEERCUP.position = _POS
					Layer4.add_child(_BEERCUP)
					layer4_Array.append(_BEERCUP)
			call_OBJ_pup(_PLATE, _LIST)
func call_OBJ_pup(_PLATE, _LIST):
	var _OBJLIST: Array
	_PLATE._OBJLIST.clear()
	for _OBJID in _LIST:
		if SteamLogic.OBJECT_DIC.has(_OBJID):
			var _OBJ = SteamLogic.OBJECT_DIC[_OBJID]
			_PLATE._OBJLIST.append(_OBJ)

func _Plate_Logic(_Layer, _PLATE, _BEERCUP):


	match _Layer:
		1:
			if layer1_Array.size() < int(float(8) / float(_BEERCUP.Weight)):
				var _CHECK: bool = _PLATE.return_Remove_CUP(_BEERCUP)
				if _CHECK:
					var _POS = PutOnPos_Array[layer1_Array.size()]
					_BEERCUP.position = _POS
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _LIST: Array
						for _OBJ in _PLATE._OBJLIST:
							_LIST.append(_OBJ._SELFID)
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Plate_pup", [_Layer, _BEERCUP._SELFID, _PLATE._SELFID, _POS, _LIST])
					Layer1.add_child(_BEERCUP)
					layer1_Array.append(_BEERCUP)

					Layer1_Weight += _BEERCUP.Weight
					return true
		2:
			if layer2_Array.size() < int(float(8) / float(_BEERCUP.Weight)):
				var _CHECK: bool = _PLATE.return_Remove_CUP(_BEERCUP)
				if _CHECK:
					var _POS = PutOnPos_Array[layer2_Array.size()]
					_BEERCUP.position = _POS
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _LIST: Array
						for _OBJ in _PLATE._OBJLIST:
							_LIST.append(_OBJ._SELFID)
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Plate_pup", [_Layer, _BEERCUP._SELFID, _PLATE._SELFID, _POS, _LIST])
					Layer2.add_child(_BEERCUP)
					layer2_Array.append(_BEERCUP)

					Layer2_Weight += _BEERCUP.Weight
					return true
		3:
			if layer3_Array.size() < int(float(8) / float(_BEERCUP.Weight)):
				var _CHECK: bool = _PLATE.return_Remove_CUP(_BEERCUP)
				if _CHECK:
					var _POS = PutOnPos_Array[layer3_Array.size()]
					_BEERCUP.position = _POS
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _LIST: Array
						for _OBJ in _PLATE._OBJLIST:
							_LIST.append(_OBJ._SELFID)
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Plate_pup", [_Layer, _BEERCUP._SELFID, _PLATE._SELFID, _POS, _LIST])
					Layer3.add_child(_BEERCUP)
					layer3_Array.append(_BEERCUP)

					Layer3_Weight += _BEERCUP.Weight
					return true
		4:
			if layer4_Array.size() < int(float(8) / float(_BEERCUP.Weight)):
				var _CHECK: bool = _PLATE.return_Remove_CUP(_BEERCUP)
				if _CHECK:
					var _POS = PutOnPos_Array[layer4_Array.size()]
					_BEERCUP.position = _POS
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _LIST: Array
						for _OBJ in _PLATE._OBJLIST:
							_LIST.append(_OBJ._SELFID)
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Plate_pup", [_Layer, _BEERCUP._SELFID, _PLATE._SELFID, _POS, _LIST])
					Layer4.add_child(_BEERCUP)
					layer4_Array.append(_BEERCUP)

					Layer4_Weight += _BEERCUP.Weight
					return true
func _PutOn(_Layer, _Player):

	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return true
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _DevID = _Dev._SELFID
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOn_puppet", [_Layer, _PLAYERPATH, _DevID])
	return PutOn_Logic(_Layer, _Player, _Dev)
func PutOn_Logic(_Layer, _Player, _Dev):
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	match _Layer:
		1:
			if layer1_Array.size() < int(float(8) / float(_Dev.Weight)):
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer1_Array.size()]
				Layer1.add_child(_Dev)
				layer1_Array.append(_Dev)
				if SelfDev == "FreezeShelf":
					if _Dev.has_method("call_Freezer_Switch"):
						_Dev.call_Freezer_Switch(true)
					if _Dev.has_method("call_Defrost_Switch"):
						_Dev.call_Defrost_Switch(1)

				Layer1_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				if _Dev.has_method("call_cleanID"):
					_Dev.call_cleanID()
				printerr("放下物品，逻辑:", _Dev.position)
				_Audio.play(0)
				call_TurnAni()
				return "放"
		2:
			if layer2_Array.size() < int(float(8) / float(_Dev.Weight)):
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer2_Array.size()]
				Layer2.add_child(_Dev)
				layer2_Array.append(_Dev)
				if SelfDev == "FreezeShelf":
					if _Dev.has_method("call_Freezer_Switch"):
						_Dev.call_Freezer_Switch(true)
					if _Dev.has_method("call_Defrost_Switch"):
						_Dev.call_Defrost_Switch(1)

				Layer2_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				if _Dev.has_method("call_cleanID"):
					_Dev.call_cleanID()
				_Audio.play(0)
				call_TurnAni()
				printerr("放下物品，逻辑:", _Dev.position)
				return "放"
		3:
			if layer3_Array.size() < int(float(8) / float(_Dev.Weight)):
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer3_Array.size()]
				Layer3.add_child(_Dev)
				layer3_Array.append(_Dev)
				if SelfDev == "FreezeShelf":
					if _Dev.has_method("call_Freezer_Switch"):
						_Dev.call_Freezer_Switch(true)
					if _Dev.has_method("call_Defrost_Switch"):
						_Dev.call_Defrost_Switch(1)

				Layer3_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				if _Dev.has_method("call_cleanID"):
					_Dev.call_cleanID()
				_Audio.play(0)
				call_TurnAni()
				printerr("放下物品，逻辑:", _Dev.position)
				return "放"
		4:
			if layer4_Array.size() < int(float(8) / float(_Dev.Weight)):
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer4_Array.size()]
				Layer4.add_child(_Dev)
				layer4_Array.append(_Dev)
				if SelfDev == "FreezeShelf":
					if _Dev.has_method("call_Freezer_Switch"):
						_Dev.call_Freezer_Switch(true)
					if _Dev.has_method("call_Defrost_Switch"):
						_Dev.call_Defrost_Switch(1)

				Layer4_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				if _Dev.has_method("call_cleanID"):
					_Dev.call_cleanID()
				_Audio.play(0)
				call_TurnAni()
				printerr("放下物品，逻辑:", _Dev.position)
				return "放"

func call_pick(_butID, _Player, _Dev = null):

	match _butID:
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _Player.cur_RayObj != self:
				But_Switch(false, _Player)
				return
			var b1_bool: bool
			var b2_bool: bool
			var b3_bool: bool
			var b4_bool: bool
			if is_instance_valid(_Dev):
				var _CHECKTYPE = _Dev.TypeStr
				if _CHECKTYPE == "Box_M_Paper":
					_CHECKTYPE = _Dev.TypeName
				if Layer1_Item == _CHECKTYPE or Layer1_Item == null:
					b1_bool = true
				if Layer2_Item == _CHECKTYPE or Layer2_Item == null:
					b2_bool = true
				if Layer3_Item == _CHECKTYPE or Layer3_Item == null:
					b3_bool = true
				if Layer4_Item == _CHECKTYPE or Layer4_Item == null:
					b4_bool = true
			else:
				if Layer1_Item != null:
					b1_bool = true
				if Layer2_Item != null:
					b2_bool = true
				if Layer3_Item != null:
					b3_bool = true
				if Layer4_Item != null:
					b4_bool = true

			if _Player.IsStaff:
				return
			if b1_bool:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if b2_bool:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)
			if b3_bool:
				_Y.call_player_in(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)
			if b4_bool:
				_X.call_player_in(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)

		0:
			if Layer1_Item != null:
				var _pick = _pick(1, _Player)
				var _put = call_PutOn( - 1, _Player)
				if _pick != null:
					return _pick
				if _put != null:
					return _put

		1:
			if Layer2_Item != null:
				var _pick = _pick(2, _Player)
				var _put = call_PutOn( - 1, _Player)
				if _pick != null:
					return _pick
				if _put != null:
					return _put
		3:

			if Layer3_Item != null:
				var _pick = _pick(3, _Player)
				var _put = call_PutOn( - 1, _Player)

				if _pick != null:
					return _pick
				if _put != null:
					return _put

		2:
			if Layer4_Item != null:
				var _pick = _pick(4, _Player)
				var _put = call_PutOn( - 1, _Player)
				if _pick != null:
					return _pick
				if _put != null:
					return _put

func _pick(_Layer, _Player):
	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _Dev
	match _Layer:
		1:
			_Dev = layer1_Array.pop_back()

			Layer1_Weight -= _Dev.Weight
			if not layer1_Array.size():
				Layer1_Weight = 0

		2:
			_Dev = layer2_Array.pop_back()

			Layer2_Weight -= _Dev.Weight
			if not layer2_Array.size():
				Layer2_Weight = 0

		3:
			_Dev = layer3_Array.pop_back()

			Layer3_Weight -= _Dev.Weight
			if not layer3_Array.size():
				Layer3_Weight = 0

		4:
			_Dev = layer4_Array.pop_back()

			Layer4_Weight -= _Dev.Weight
			if not layer4_Array.size():
				Layer4_Weight = 0

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_Layer, Layer1_Item, Layer1_Weight,
		Layer2_Item, Layer2_Weight,
		Layer3_Item, Layer3_Weight,
		Layer4_Item, Layer4_Weight,
		_Dev._SELFID, _Player.get_path()])
	GameLogic.Device.call_Player_Pick(_Player, _Dev)

	return "拿"
func _puppet_pick(_Layer, _Layer1_Item, _Layer1_Weight,
		_Layer2_Item, _Layer2_Weight,
		_Layer3_Item, _Layer3_Weight,
		_Layer4_Item, _Layer4_Weight,
		_OBJID, _PLAYERPATH):
	var _Dev
	match _Layer:
		1:
			_Dev = layer1_Array.pop_back()
		2:
			_Dev = layer2_Array.pop_back()
		3:
			_Dev = layer3_Array.pop_back()
		4:
			_Dev = layer4_Array.pop_back()

	Layer1_Weight = _Layer1_Weight

	Layer2_Weight = _Layer2_Weight

	_Layer3_Weight = Layer3_Weight

	Layer4_Weight = _Layer4_Weight
	_CupLogic(true, 1)
	_CupLogic(true, 2)
	_CupLogic(true, 3)
	_CupLogic(true, 4)
	var _Player = get_node(_PLAYERPATH)

	if SteamLogic.OBJECT_DIC.has(_OBJID):
		var _OBJ = SteamLogic.OBJECT_DIC[_OBJID]
		if SelfDev == "FreezeShelf":
			if is_instance_valid(_OBJ):
				if _OBJ.has_method("call_Freezer_Switch"):
					_OBJ.call_Freezer_Switch(false)
				if _OBJ.has_method("call_Defrost_Switch"):
					_OBJ.call_Defrost_Switch(0)
		call_TurnAni()
		call_pick( - 1, _Player, _OBJ)

func call_TurnAni():
	if SelfDev == "FreezeShelf":
		if has_node("AniNode/Act"):
			$AniNode / Act.play("Used")
		if layer1_Array.size() or layer2_Array.size() or layer3_Array.size() or layer4_Array.size():

			if $AniNode / TurnAni.assigned_animation != "On":
				$AniNode / TurnAni.play("On")
			if has_node("AniNode/Timer"):
				$AniNode / Timer.start()
				$AniNode / Timer.set_paused(false)
		else:

			if $AniNode / TurnAni.assigned_animation != "Off":
				$AniNode / TurnAni.play("Off")
			if has_node("AniNode/Timer"):
				$AniNode / Timer.set_paused(true)
func _on_CheckArea_area_entered(_area: Area2D) -> void :

	IsOverlap = true

func call_pick_pup(_LAYERID, _PLATEID, _CUPLIST, _WEIGHT, _LIST):
	if SteamLogic.OBJECT_DIC.has(_PLATEID):
		var _PLATE = SteamLogic.OBJECT_DIC[_PLATEID]
		match _LAYERID:
			0:
				if _CUPLIST:
					for _CUPID in _CUPLIST:
						if SteamLogic.OBJECT_DIC.has(_CUPID):
							var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
							if is_instance_valid(_CUP):
								if _CUP.is_inside_tree():
									_CUP.get_parent().remove_child(_CUP)
							if layer1_Array.has(_CUP):
								layer1_Array.erase(_CUP)
							Layer1_Weight = _WEIGHT

							_PLATE.call_CupOn(_CUP)
			1:
				if _CUPLIST:
					for _CUPID in _CUPLIST:
						if SteamLogic.OBJECT_DIC.has(_CUPID):
							var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
							if is_instance_valid(_CUP):
								if _CUP.is_inside_tree():
									_CUP.get_parent().remove_child(_CUP)
							if layer2_Array.has(_CUP):
								layer2_Array.erase(_CUP)
							Layer2_Weight = _WEIGHT

							_PLATE.call_CupOn(_CUP)
			3:
				if _CUPLIST:
					for _CUPID in _CUPLIST:
						if SteamLogic.OBJECT_DIC.has(_CUPID):
							var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
							if is_instance_valid(_CUP):
								if _CUP.is_inside_tree():
									_CUP.get_parent().remove_child(_CUP)
							if layer3_Array.has(_CUP):
								layer3_Array.erase(_CUP)
							Layer3_Weight = _WEIGHT

							_PLATE.call_CupOn(_CUP)
			2:
				if _CUPLIST:
					for _CUPID in _CUPLIST:
						if SteamLogic.OBJECT_DIC.has(_CUPID):
							var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
							if is_instance_valid(_CUP):
								if _CUP.is_inside_tree():
									_CUP.get_parent().remove_child(_CUP)
							if layer4_Array.has(_CUP):
								layer4_Array.erase(_CUP)
							Layer4_Weight = _WEIGHT

							_PLATE.call_CupOn(_CUP)
		_PLATE._OBJLIST.clear()
		for _CUPID in _LIST:
			if SteamLogic.OBJECT_DIC.has(_CUPID):
				var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
				_PLATE._OBJLIST.append(_CUP)
	GameLogic.Device.PickAudio.play(0)

func call_PlatePutOn(_butID, _Player):

	var _Dev = instance_from_id(_Player.Con.HoldInsId)

	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	match _butID:
		- 1:
			_But_Plate(_Player)

		0, 1, 2, 3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _NUM = _Dev._OBJLIST.size()
			var _R: bool
			if not _NUM:
				var _CUPLIST: Array
				var _WEIGHT: int
				match _butID:
					0:
						var _LAYNUM: int = layer1_Array.size()

						if _LAYNUM:
							for _i in _LAYNUM:
								var _CUP = layer1_Array.pop_back()

								if is_instance_valid(_CUP):
									_CUP.get_parent().remove_child(_CUP)
								Layer1_Weight -= _Dev.Weight

								_Dev.call_CupOn(_CUP)
								_R = true
								_CUPLIST.append(_CUP._SELFID)
								if _Dev._OBJLIST.size() >= 4:
									break
							GameLogic.Device.PickAudio.play(0)
						_WEIGHT = Layer1_Weight
					1:
						var _LAYNUM: int = layer2_Array.size()
						if _LAYNUM:
							for _i in _LAYNUM:
								var _CUP = layer2_Array.pop_back()

								if is_instance_valid(_CUP):
									_CUP.get_parent().remove_child(_CUP)
								Layer2_Weight -= _Dev.Weight

								_Dev.call_CupOn(_CUP)
								_R = true
								_CUPLIST.append(_CUP._SELFID)
								if _Dev._OBJLIST.size() >= 4:
									break
							GameLogic.Device.PickAudio.play(0)
						_WEIGHT = Layer2_Weight
					3:
						var _LAYNUM: int = layer3_Array.size()
						if _LAYNUM:
							for _i in _LAYNUM:
								var _CUP = layer3_Array.pop_back()

								if is_instance_valid(_CUP):
									_CUP.get_parent().remove_child(_CUP)
								Layer3_Weight -= _Dev.Weight

								_Dev.call_CupOn(_CUP)
								_R = true
								_CUPLIST.append(_CUP._SELFID)
								if _Dev._OBJLIST.size() >= 4:
									break
							GameLogic.Device.PickAudio.play(0)
						_WEIGHT = Layer3_Weight
					2:
						var _LAYNUM: int = layer4_Array.size()
						if _LAYNUM:
							for _i in _LAYNUM:
								var _CUP = layer4_Array.pop_back()

								if is_instance_valid(_CUP):
									_CUP.get_parent().remove_child(_CUP)
								Layer4_Weight -= _Dev.Weight

								_Dev.call_CupOn(_CUP)
								_R = true
								_CUPLIST.append(_CUP._SELFID)
								if _Dev._OBJLIST.size() >= 4:
									break
							GameLogic.Device.PickAudio.play(0)
						_WEIGHT = Layer4_Weight
				if _CUPLIST:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _LIST: Array
						for _CUPOBJ in _Dev._OBJLIST:
							_LIST.append(_CUPOBJ._SELFID)
						SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_pup", [_butID, _Dev._SELFID, _CUPLIST, _WEIGHT, _LIST])
			else:

				for _i in _NUM:
					var _j = _NUM - _i - 1
					if _Dev._OBJLIST.size() > _j:
						var _CUP = _Dev._OBJLIST[_j]
						if layer1_Array.size() < int(float(8) / float(_CUP.Weight)):
							_set_pos(_CUP)
							if Layer1_Item != null:
								var _x = _CUP.TypeStr
								if Layer1_Item == _CUP.TypeStr:
									var _CHECK: bool = _Plate_Logic(1, _Dev, _CUP)
									if _CHECK:

										_CupLogic(true, 1)
										_R = true
							else:
								var _CHECK: bool = _Plate_Logic(1, _Dev, _CUP)
								if not _CHECK:
									break
								else:

									_CupLogic(true, 1)
									_R = true
				for _i in _NUM:
					var _j = _NUM - _i - 1
					if _Dev._OBJLIST.size() > _j:
						var _CUP = _Dev._OBJLIST[_j]
						if layer2_Array.size() < int(float(8) / float(_CUP.Weight)):
							_set_pos(_CUP)
							if Layer2_Item != null:
								if Layer2_Item == _CUP.TypeStr:
									var _CHECK: bool = _Plate_Logic(2, _Dev, _CUP)
									if _CHECK:

										_CupLogic(true, 2)
										_R = true
							else:
								var _CHECK: bool = _Plate_Logic(2, _Dev, _CUP)
								if not _CHECK:
									break
								else:

									_CupLogic(true, 2)
									_R = true
				for _i in _NUM:
					var _j = _NUM - _i - 1
					if _Dev._OBJLIST.size() > _j:
						var _CUP = _Dev._OBJLIST[_j]
						if layer3_Array.size() < int(float(8) / float(_CUP.Weight)):
							_set_pos(_CUP)
							if Layer3_Item != null:
								if Layer3_Item == _CUP.TypeStr:
									var _CHECK: bool = _Plate_Logic(3, _Dev, _CUP)
									if _CHECK:

										_CupLogic(true, 3)
										_R = true
							else:
								var _CHECK: bool = _Plate_Logic(3, _Dev, _CUP)
								if not _CHECK:
									break
								else:

									_CupLogic(true, 3)
									_R = true
				for _i in _NUM:
					var _j = _NUM - _i - 1
					if _Dev._OBJLIST.size() > _j:
						var _CUP = _Dev._OBJLIST[_j]
						if layer4_Array.size() < int(float(8) / float(_CUP.Weight)):
							_set_pos(_CUP)
							if Layer4_Item != null:
								if Layer4_Item == _CUP.TypeStr:
									var _CHECK: bool = _Plate_Logic(4, _Dev, _CUP)
									if _CHECK:

										_CupLogic(true, 4)
										_R = true
							else:
								var _CHECK: bool = _Plate_Logic(4, _Dev, _CUP)
								if not _CHECK:
									break
								else:

									_CupLogic(true, 4)
									_R = true

			if _R:
				_But_Plate(_Player)
				_Audio.play(0)

				return true

func _CupLogic(_BOOL: bool, _LAYER: int):
	var _TEX
	var _ITEMNAME
	if _BOOL:

		match _LAYER:
			1:
				_ITEMNAME = Layer1_Item
			2:
				_ITEMNAME = Layer2_Item
			3:
				_ITEMNAME = Layer3_Item
			4:
				_ITEMNAME = Layer4_Item
		match _ITEMNAME:
			"DrinkCup_S", "BeerCup_S", "SodaCan_S":
				_TEX = load("res://Resources/UI/GameUI/ui_pack.sprites/Icon_cuptpye_S.tres")
			"DrinkCup_M", "BeerCup_M", "SodaCan_M":
				_TEX = load("res://Resources/UI/GameUI/ui_pack.sprites/Icon_cuptpye_M.tres")
			"DrinkCup_L", "BeerCup_L", "SodaCan_L":
				_TEX = load("res://Resources/UI/GameUI/ui_pack.sprites/Icon_cuptpye_L.tres")

		if $TexNode.has_node(str(_LAYER)):
			if _TEX:
				$TexNode.get_node(str(_LAYER)).set_texture(_TEX)
				$TexNode.get_node(str(_LAYER)).show()
			elif $TexNode.has_node(str(_LAYER)):
				$TexNode.get_node(str(_LAYER)).hide()
	else:
		if $TexNode.has_node(str(_LAYER)):
			$TexNode.get_node(str(_LAYER)).hide()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_show_pup", [_BOOL, _LAYER, _ITEMNAME])
func call_show_pup(_BOOL, _LAYER, _NAME):
	var _ITEMNAME = _NAME
	if _BOOL:
		var _TEX
		match _ITEMNAME:
			"DrinkCup_S", "BeerCup_S", "SodaCan_S":
				_TEX = load("res://Resources/UI/GameUI/ui_pack.sprites/Icon_cuptpye_S.tres")
			"DrinkCup_M", "BeerCup_M", "SodaCan_M":
				_TEX = load("res://Resources/UI/GameUI/ui_pack.sprites/Icon_cuptpye_M.tres")
			"DrinkCup_L", "BeerCup_L", "SodaCan_L":
				_TEX = load("res://Resources/UI/GameUI/ui_pack.sprites/Icon_cuptpye_L.tres")

		if $TexNode.has_node(str(_LAYER)):
			if _TEX:
				$TexNode.get_node(str(_LAYER)).set_texture(_TEX)
				$TexNode.get_node(str(_LAYER)).show()
			elif $TexNode.has_node(str(_LAYER)):
				$TexNode.get_node(str(_LAYER)).hide()
	else:
		if $TexNode.has_node(str(_LAYER)):
			$TexNode.get_node(str(_LAYER)).hide()
func _on_Timer_timeout():
	GameLogic.Total_Electricity += 0.1
