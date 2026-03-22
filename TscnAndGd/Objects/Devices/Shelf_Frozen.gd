extends Head_Object

var SelfDev = "Freezer"
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
			call_DoorAni(true)
		false:
			get_node("AniNode/OutLineAni").play("init")
			call_DoorAni(false)
func call_DoorAni(_Switch: bool):
	match _Switch:
		true:
			$AniNode / DoorL.play("open")
			$AniNode / DoorR.play("open")
		false:
			$AniNode / DoorL.play("close")
			$AniNode / DoorR.play("close")

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
	if is_instance_valid(_Dev):
		if _Dev.get("IsFrozen"):
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

	$But.show()

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

func _set_pos(_Obj):
	PutOnPos_Array.clear()

	if _Obj.IsItem:
		if _Obj.TypeStr in ["Sugar", "Choco"]:
			_Obj.Weight = 2
		match _Obj.Weight:
			1, 0:
				for i in 8:
					if i < 4:
						var _x = - 24 + i * 20
						PutOnPos_Array.append(Vector2(_x, - 10))
					else:
						var _x = - 24 + (i - 4) * 20
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
	call_TurnAni()
	if GameLogic.SPECIALLEVEL_Int:
		GameLogic.NPC.FROZEN.append(self)
		print("测试 FROZEN：", GameLogic.NPC.FROZEN)
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
					call_pick( - 1, _Player)
					return _put
			else:
				var _put = _PutOn(1, _Player)
				call_pick( - 1, _Player)
				return _put
	elif _butID == 1:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer2_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer2_Item != null:
				if Layer2_Item == _Dev.TypeStr:
					var _put = _PutOn(2, _Player)
					call_pick( - 1, _Player)
					return _put
			else:
				var _put = _PutOn(2, _Player)
				call_pick( - 1, _Player)
				return _put
	elif _butID == 3:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer3_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer3_Item != null:
				if Layer3_Item == _Dev.TypeStr:
					var _put = _PutOn(3, _Player)
					call_pick( - 1, _Player)
					return _put
			else:
				var _put = _PutOn(3, _Player)
				call_pick( - 1, _Player)
				return _put
	elif _butID == 2:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer4_Array.size() < int(float(8) / float(_Dev.Weight)):
			_set_pos(_Dev)
			if Layer4_Item != null:
				if Layer4_Item == _Dev.TypeStr:
					var _put = _PutOn(4, _Player)
					call_pick( - 1, _Player)
					return _put
			else:
				var _put = _PutOn(4, _Player)
				call_pick( - 1, _Player)
				return _put

func _PutOn(_Layer, _Player):

	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	if not _Dev.get("IsFrozen"):

		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Player.call_Say_NoUse()
		return
	match _Layer:
		1:
			if layer1_Array.size() < int(float(8) / float(_Dev.Weight)):
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer1_Array.size()]
				Layer1.add_child(_Dev)
				layer1_Array.append(_Dev)
				if SelfDev == "Freezer":
					if _Dev.has_method("call_Frozen_Switch"):
						_Dev.call_Frozen_Switch(true)

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
				if SelfDev == "Freezer":
					if _Dev.has_method("call_Frozen_Switch"):
						_Dev.call_Frozen_Switch(true)
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
				if SelfDev == "Freezer":
					if _Dev.has_method("call_Frozen_Switch"):
						_Dev.call_Frozen_Switch(true)
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
				if SelfDev == "Freezer":
					if _Dev.has_method("call_Frozen_Switch"):
						_Dev.call_Frozen_Switch(true)
				if Layer4_Item != _Dev.TypeStr:
					Layer4_Item = _Dev.TypeStr
				Layer4_Weight += _Dev.Weight
				_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_Info_Switch"):
					_Dev.call_Info_Switch(false)
				_Audio.play(0)
				call_TurnAni()
				return "放"

func call_pick(_butID, _Player):

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
	if _Dev.has_method("call_Frozen_Switch"):
		_Dev.call_Frozen_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _Dev)
	call_TurnAni()

	return "拿"

func call_TurnAni():

	if layer1_Array.size() or layer2_Array.size() or layer3_Array.size() or layer4_Array.size():

		if $AniNode / TurnAni.assigned_animation != "On":
			$AniNode / TurnAni.play("On")
	else:

		if $AniNode / TurnAni.assigned_animation != "Off":
			$AniNode / TurnAni.play("Off")
func _on_CheckArea_area_entered(_area: Area2D) -> void :

	IsOverlap = true

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
			_Obj.call_bag_tex_set()
			if _Obj.has_method("call_Frozen_init"):
				_Obj.call_Frozen_init()
			if _Obj.has_method("call_Frozen_Switch"):
				_Obj.call_Frozen_Switch(true)
			match _Layer:
				1:
					Layer1_Weight += _Obj.Weight
				2:
					Layer2_Weight += _Obj.Weight
				3:
					Layer3_Weight += _Obj.Weight
				4:
					Layer4_Weight += _Obj.Weight

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
			if _Obj.has_method("call_Frozen_init"):
				_Obj.call_Frozen_init()
			if _Obj.has_method("call_Frozen_Switch"):
				_Obj.call_Frozen_Switch(true)
			match _Layer:
				1:
					Layer1_Weight += _Obj.Weight
				2:
					Layer2_Weight += _Obj.Weight
				3:
					Layer3_Weight += _Obj.Weight
				4:
					Layer4_Weight += _Obj.Weight
	print(" auto pup 3:", _NAMELIST, _NUMLIST, _IDLIST)
