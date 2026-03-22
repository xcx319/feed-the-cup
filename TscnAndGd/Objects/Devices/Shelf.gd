extends Head_Object

var SelfDev = "Shelf"
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
export var AUTOTYPE: int = 0
var _TURN: bool
var Electricity_Base: float = 1

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

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
	if editor_description == "FreezeShelf":
		SelfDev = "FreezeShelf"
	call_init(SelfDev)
	GuideNode.hide()
	$But.show()
	if get_parent().name == "Updates":
		GuideAni.play("show")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _CON = GameLogic.connect("CloseLight", self, "_DayClosedCheck")

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
		if _Obj.TypeStr in ["Sugar", "FreeSugar", "Choco"]:
			_Obj.Weight = 2
		match _Obj.Weight:
			1, 0:
				for i in 8:
					if i < 4:
						var _x = - 18 + i * 12
						PutOnPos_Array.append(Vector2(_x, - 10))
					else:
						var _x = - 18 + (i - 4) * 12
						PutOnPos_Array.append(Vector2(_x, 5))
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
			if Layer1_Item != _Obj.TypeStr:
				Layer1_Item = _Obj.TypeStr
		2:
			_Obj.position = PutOnPos_Array[layer2_Array.size()]
			Layer2.add_child(_Obj)
			layer2_Array.append(_Obj)

			if Layer2_Item != _Obj.TypeStr:
				Layer2_Item = _Obj.TypeStr
		3:
			_Obj.position = PutOnPos_Array[layer3_Array.size()]
			Layer3.add_child(_Obj)
			layer3_Array.append(_Obj)

			if Layer3_Item != _Obj.TypeStr:
				Layer3_Item = _Obj.TypeStr
		4:
			_Obj.position = PutOnPos_Array[layer4_Array.size()]
			Layer4.add_child(_Obj)
			layer4_Array.append(_Obj)

			if Layer4_Item != _Obj.TypeStr:
				Layer4_Item = _Obj.TypeStr

func call_auto(_NAMELIST, _NUMLIST):
	var _IDLIST: Array
	var _Layer: int = 0
	for _NAME in _NAMELIST:
		var _NUM = _NUMLIST[_Layer]
		_Layer += 1
		for _i in _NUM:

			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_NAME)
			var _Obj = _TSCN.instance()
			_Obj._SELFID = _Obj.get_instance_id()
			_Obj.name = str(_Obj._SELFID)
			_IDLIST.append(_Obj._SELFID)
			_Obj.call_init(_NAME)
			_Obj.IsItem = true
			_ObjLoad(_Obj, _Layer)
			_Obj.call_Ins_Save(_Obj._SELFID)
			if _Obj.has_method("call_bag_tex_set"):
				_Obj.call_bag_tex_set()
			if _Obj.has_method("call_CupType_Set"):
				_Obj.call_CupType_Set()
			match _Layer:
				1:
					Layer1_Weight += _Obj.Weight
				2:
					Layer2_Weight += _Obj.Weight
				3:
					Layer3_Weight += _Obj.Weight
				4:
					Layer4_Weight += _Obj.Weight

	call_TurnAni()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "auto_pup", [_NAMELIST, _NUMLIST, _IDLIST])

func auto_pup(_NAMELIST, _NUMLIST, _IDLIST):
	var _Layer: int = 0
	var _IDNUM: int = 0
	for _NAME in _NAMELIST:
		var _NUM = _NUMLIST[_Layer]
		_Layer += 1
		for _i in _NUM:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_NAME)
			var _Obj = _TSCN.instance()
			_Obj._SELFID = _IDLIST[_IDNUM]
			_IDNUM += 1
			_Obj.name = str(_Obj._SELFID)

			_Obj.call_init(_NAME)
			_Obj.IsItem = true
			_ObjLoad(_Obj, _Layer)
			_Obj.call_Ins_Save(_Obj._SELFID)
			_Obj.call_bag_tex_set()
			match _Layer:
				1:
					Layer1_Weight += _Obj.Weight
				2:
					Layer2_Weight += _Obj.Weight
				3:
					Layer3_Weight += _Obj.Weight
				4:
					Layer4_Weight += _Obj.Weight
	call_TurnAni()
	print(" auto pup 2:", _NAMELIST, _NUMLIST, _IDLIST)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME

	.call_Ins_Save(_SELFID)

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
	if _Info.has("AUTOTYPE"):
		AUTOTYPE = _Info.AUTOTYPE
	call_TurnAni()
	if GameLogic.SPECIALLEVEL_Int:
		if SelfDev == "FreezeShelf":
			GameLogic.NPC.FREEZER.append(self)
		else:
			GameLogic.NPC.SHELF.append(self)

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
				if Layer1_Item != _Dev.TypeStr:
					Layer1_Item = _Dev.TypeStr
				Layer1_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)

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
				if Layer2_Item != _Dev.TypeStr:
					Layer2_Item = _Dev.TypeStr
				Layer2_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				_Audio.play(0)
				call_TurnAni()
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
				if Layer3_Item != _Dev.TypeStr:
					Layer3_Item = _Dev.TypeStr
				Layer3_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				_Audio.play(0)
				call_TurnAni()
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
				if Layer4_Item != _Dev.TypeStr:
					Layer4_Item = _Dev.TypeStr
				Layer4_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				_Audio.play(0)
				call_TurnAni()
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
				Layer1_Item = null
		2:
			_Dev = layer2_Array.pop_back()

			Layer2_Weight -= _Dev.Weight
			if not layer2_Array.size():
				Layer2_Item = null
		3:
			_Dev = layer3_Array.pop_back()

			Layer3_Weight -= _Dev.Weight
			if not layer3_Array.size():
				Layer3_Item = null
		4:
			_Dev = layer4_Array.pop_back()

			Layer4_Weight -= _Dev.Weight
			if not layer4_Array.size():
				Layer4_Item = null
	if SelfDev == "FreezeShelf":
		if _Dev.has_method("call_Freezer_Switch"):
			_Dev.call_Freezer_Switch(false)
		if _Dev.has_method("call_Defrost_Switch"):
			_Dev.call_Defrost_Switch(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_Layer, Layer1_Item, Layer1_Weight,
		Layer2_Item, Layer2_Weight,
		Layer3_Item, Layer3_Weight,
		Layer4_Item, Layer4_Weight,
		_Dev._SELFID, _Player.get_path()])
	GameLogic.Device.call_Player_Pick(_Player, _Dev)
	call_TurnAni()

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
	Layer1_Item = _Layer1_Item
	Layer1_Weight = _Layer1_Weight
	Layer2_Item = _Layer2_Item
	Layer2_Weight = _Layer2_Weight
	Layer3_Item = _Layer3_Item
	_Layer3_Weight = Layer3_Weight
	Layer4_Item = _Layer4_Item
	Layer4_Weight = _Layer4_Weight
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

func _on_Timer_timeout():
	GameLogic.Total_Electricity += 0.1
