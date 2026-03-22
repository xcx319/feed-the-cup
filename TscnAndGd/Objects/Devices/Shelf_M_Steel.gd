extends Head_Object

var SelfDev = "FruitShelf"
var TableItemOffset = Vector2(0, - 70)

var PutOnPos_Array: Array

var layer1_Array: Array = []
var Layer1_Item: String = ""
var layer2_Array: Array = []
var Layer2_Item: String = ""
var layer3_Array: Array = []
var Layer3_Item: String = ""
var layer4_Array: Array = []
var Layer4_Item: String = ""
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

func _But_Show(_Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	if _Player.cur_RayObj != self:
		_A.call_player_out(_Player.cur_Player)
		_B.call_player_out(_Player.cur_Player)
		_Y.call_player_out(_Player.cur_Player)
		_X.call_player_out(_Player.cur_Player)
		return
	if not _Player.Con.IsHold:
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	_ButShowLogic(_Player, _Dev)
func _ButShowLogic(_Player, _Dev):
	if _Dev.IsItem:
		var b1_bool: bool
		var b2_bool: bool
		var b3_bool: bool
		var b4_bool: bool
		var _CHECKTYPE = _Dev.TypeStr
		if _CHECKTYPE == "Box_M_Paper":
			_CHECKTYPE = _Dev.TypeName
		if Layer1_Item == _CHECKTYPE or Layer1_Item == "":
			b1_bool = true
		if Layer2_Item == _CHECKTYPE or Layer2_Item == "":
			b2_bool = true
		if Layer3_Item == _CHECKTYPE or Layer3_Item == "":
			b3_bool = true
		if Layer4_Item == _CHECKTYPE or Layer4_Item == "":
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

func _set_pos(_Fruit):
	PutOnPos_Array.clear()

	match int(_Fruit.Weight):
		20:
			PutOnPos_Array = [Vector2( - 30, - 20),
				Vector2( - 15, - 20),
				Vector2(0, - 20),
				Vector2(15, - 20),
				Vector2(30, - 20),
				Vector2( - 30, - 7),
				Vector2( - 15, - 7),
				Vector2(0, - 7),
				Vector2(15, - 7),
				Vector2(30, - 7),
				Vector2( - 30, 6),
				Vector2( - 15, 6),
				Vector2(0, 6),
				Vector2(15, 6),
				Vector2(30, 6),
				Vector2( - 30, 20),
				Vector2( - 15, 20),
				Vector2(0, 20),
				Vector2(15, 20),
				Vector2(30, 20)]
		12:
			PutOnPos_Array = [
				Vector2( - 30, - 20),
				Vector2( - 10, - 20),
				Vector2(10, - 20),
				Vector2(30, - 20),
				Vector2( - 30, 0),
				Vector2( - 10, 0),
				Vector2(10, 0),
				Vector2(30, 0),
				Vector2( - 30, 20),
				Vector2( - 10, 20),
				Vector2(10, 20),
				Vector2(30, 20)]
		10:
			PutOnPos_Array = [
				Vector2( - 10, - 20),
				Vector2(10, - 20),
				Vector2(30, - 20),
				Vector2( - 30, 0),
				Vector2( - 10, 0),
				Vector2(10, 0),
				Vector2(30, 0),
				Vector2( - 30, 20),
				Vector2( - 10, 20),
				Vector2(10, 20)]
		6:
			PutOnPos_Array = [
				Vector2( - 17, - 10),
				Vector2(17, - 10),
				Vector2( - 17, 0),
				Vector2(17, 0),
				Vector2( - 17, 10),
				Vector2(17, 10)]
		5:
			PutOnPos_Array = [
				Vector2(0, - 20),
				Vector2(0, - 10),
				Vector2(0, 0),
				Vector2(0, 10),
				Vector2(0, 20)
			]
		4:
			PutOnPos_Array = [
				Vector2( - 15, - 5),
				Vector2(15, - 5),
				Vector2( - 15, 5),
				Vector2(15, 5)]
		2:
			PutOnPos_Array = [Vector2( - 20, 0),
				Vector2(20, 0)]
		_:
			pass

func _ObjLoad_Layer(_Obj, _Layer):
	match _Layer:
		1:

			Layer1.add_child(_Obj)
			layer1_Array.append(_Obj)

		2:

			Layer2.add_child(_Obj)
			layer2_Array.append(_Obj)


		3:

			Layer3.add_child(_Obj)
			layer3_Array.append(_Obj)


		4:

			Layer4.add_child(_Obj)
			layer4_Array.append(_Obj)


func _ObjLoad_Pos(_Obj, _Layer):
	_set_pos(_Obj)
	match _Layer:
		1:
			_Obj.position = PutOnPos_Array[layer1_Array.size() - 1]
			Layer1_Item = _Obj.TypeStr
		2:
			_Obj.position = PutOnPos_Array[layer2_Array.size() - 1]
			Layer2_Item = _Obj.TypeStr
		3:
			_Obj.position = PutOnPos_Array[layer3_Array.size() - 1]
			Layer3_Item = _Obj.TypeStr
		4:
			_Obj.position = PutOnPos_Array[layer4_Array.size() - 1]
			Layer4_Item = _Obj.TypeStr
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

			_ObjLoad_Layer(_Obj, 1)
			_Obj.call_load(_ObjInfo)
			_ObjLoad_Pos(_Obj, 1)

			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
			Layer1_Weight += _Obj.return_DropCount()

	if _Info.Layer2_Array.size():
		for _ObjInfo in _Info.Layer2_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			if _Info.has("NAME"):
				_Obj.name = _Info.NAME

			else:
				_Obj.name = str(get_instance_id())

			_ObjLoad_Layer(_Obj, 2)
			_Obj.call_load(_ObjInfo)
			_ObjLoad_Pos(_Obj, 2)
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
			Layer2_Weight += _Obj.return_DropCount()
	if _Info.Layer3_Array.size():
		for _ObjInfo in _Info.Layer3_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			if _Info.has("NAME"):
				_Obj.name = _Info.NAME

			else:
				_Obj.name = str(get_instance_id())

			_ObjLoad_Layer(_Obj, 3)
			_Obj.call_load(_ObjInfo)
			_ObjLoad_Pos(_Obj, 3)
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
			Layer3_Weight += _Obj.return_DropCount()
	if _Info.Layer4_Array.size():
		for _ObjInfo in _Info.Layer4_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			if _Info.has("NAME"):
				_Obj.name = _Info.NAME

			else:
				_Obj.name = str(get_instance_id())

			_ObjLoad_Layer(_Obj, 4)
			_Obj.call_load(_ObjInfo)
			_ObjLoad_Pos(_Obj, 4)
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
			Layer4_Weight += _Obj.return_DropCount()

	if GameLogic.SPECIALLEVEL_Int:
		GameLogic.NPC.FRUITSHELF.append(self)

	call_TurnAni()
func call_auto(_NAMELIST, _NUMLIST):
	var _IDLIST: Array
	var _Layer: int = 0
	for _NAME in _NAMELIST:
		var _NUM = _NUMLIST[_Layer]
		_Layer += 1
		for _i in _NUM:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("水果")
			var _Obj = _TSCN.instance()
			_Obj._SELFID = _Obj.get_instance_id()
			_Obj.name = str(_Obj._SELFID)
			_IDLIST.append(_Obj._SELFID)
			_Obj._load(_NAME)
			_Obj.IsItem = true
			_ObjLoad_Layer(_Obj, _Layer)
			_Obj.call_Ins_Save(_Obj._SELFID)
			_Obj.call_bag_tex_set()
			_ObjLoad_Pos(_Obj, _Layer)
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
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("水果")
			var _Obj = _TSCN.instance()
			_Obj._SELFID = _IDLIST[_IDNUM]
			_IDNUM += 1
			_Obj.name = str(_Obj._SELFID)

			_Obj._load(_NAME)
			_Obj.IsItem = true
			_ObjLoad_Layer(_Obj, _Layer)
			_Obj.call_Ins_Save(_Obj._SELFID)
			_Obj.call_bag_tex_set()
			_ObjLoad_Pos(_Obj, _Layer)
			match _Layer:
				1:
					Layer1_Weight += _Obj.Weight
				2:
					Layer2_Weight += _Obj.Weight
				3:
					Layer3_Weight += _Obj.Weight
				4:
					Layer4_Weight += _Obj.Weight
	print(" auto pup:", _NAMELIST, _NUMLIST, _IDLIST)
func _FruitOn_puppet(_ButID, _PLAYERPATH, _DevID):
	var _Player = get_node(_PLAYERPATH)
	if SteamLogic.OBJECT_DIC.has(_DevID):
		var _Dev = SteamLogic.OBJECT_DIC[_DevID]
		return call_FruitOn_Logic(_ButID, _Player, _Dev)
func _BoxFruit_puppet(_ButID, _NUM, _PLAYERPATH, _FRUITID, _DevID):
	var _Player = get_node(_PLAYERPATH)
	if SteamLogic.OBJECT_DIC.has(_FRUITID):
		var _FRUITCHECK = SteamLogic.OBJECT_DIC[_FRUITID]
		if SteamLogic.OBJECT_DIC.has(_DevID):
			var _Dev = SteamLogic.OBJECT_DIC[_DevID]
			return call_BoxOn_Logic(_ButID, _NUM, _Player, _FRUITCHECK, _Dev)
func call_Fruit_PutOn(_ButID, _Player, _Dev):
	if _ButID == - 1:

		if _Dev.TypeStr in ["Box_M_Paper"]:
			if _Dev.Type in ["Fruit"]:
				if _Dev.ItemOBJ_Array.size():
					var _FRUIT = _Dev.ItemOBJ_Array.back()
					if _FRUIT.Weight < 0:
						return
				else:
					But_Switch(false, _Player)
					return
		_But_Show(_Player)
	else:
		if GameLogic.Device.return_CanUse_bool(_Player):
			return
		var _TYPE = _Dev.FuncType
		if _TYPE in ["Fruit"]:

			var _CHECK: bool = false
			match _ButID:
				0:
					if Layer1_Item != "":
						if Layer1_Item == _Dev.TypeStr and layer1_Array.size() < _Dev.Weight:
							_CHECK = true
					else:
						_CHECK = true
				1:
					if Layer2_Item != "":
						if Layer2_Item == _Dev.TypeStr and layer2_Array.size() < _Dev.Weight:
							_CHECK = true
					else:
						_CHECK = true
				3:
					if Layer3_Item != "":
						if Layer3_Item == _Dev.TypeStr and layer3_Array.size() < _Dev.Weight:
							_CHECK = true
					else:
						_CHECK = true
				2:
					if Layer4_Item != "":
						if Layer4_Item == _Dev.TypeStr and layer4_Array.size() < _Dev.Weight:
							_CHECK = true
					else:
						_CHECK = true
			if not _CHECK:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NoUse()
				return true
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "_FruitOn_puppet", [_ButID, _Player.get_path(), _Dev._SELFID])
			return call_FruitOn_Logic(_ButID, _Player, _Dev)

		elif _TYPE in ["Box"]:
			if _Dev.Type in ["Fruit"]:
				var _FruitNAME = _Dev.TypeName
				var _NUM = _Dev.ItemOBJ_Array.size()
				if _NUM <= 0:
					return
				var _FRUITCHECK = _Dev.ItemOBJ_Array.back()
				if _FRUITCHECK.Weight < 0:
					return
				var _CHECK: bool = false
				match _ButID:
					0:
						if Layer1_Item != "":
							if Layer1_Item == _FRUITCHECK.TypeStr:
								_CHECK = true
						else:
							_CHECK = true
					1:
						if Layer2_Item != "":
							if Layer2_Item == _FRUITCHECK.TypeStr:
								_CHECK = true
						else:
							_CHECK = true
					3:
						if Layer3_Item != "":
							if Layer3_Item == _FRUITCHECK.TypeStr:
								_CHECK = true
						else:
							_CHECK = true
					2:
						if Layer4_Item != "":
							if Layer4_Item == _FRUITCHECK.TypeStr:
								_CHECK = true
						else:
							_CHECK = true
				if not _CHECK:
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "_BoxFruit_puppet", [_ButID, _NUM, _Player.get_path(), _FRUITCHECK._SELFID, _Dev._SELFID])
				return call_BoxOn_Logic(_ButID, _NUM, _Player, _FRUITCHECK, _Dev)
func call_FruitOn_Logic(_ButID, _Player, _Dev):
	_Player.WeaponNode.remove_child(_Dev)
	_Player.Stat.call_carry_off()
	_set_pos(_Dev)
	match _ButID:
		0:
			var _put = _FruitOn(1, _Dev)
			call_pick( - 1, _Player)
			return _put
		1:
			var _put = _FruitOn(2, _Dev)
			call_pick( - 1, _Player)
			return _put
		2:
			var _put = _FruitOn(4, _Dev)
			call_pick( - 1, _Player)
			return _put
		3:
			var _put = _FruitOn(3, _Dev)
			call_pick( - 1, _Player)
			return _put
func call_BoxOn_Logic(_ButID, _NUM, _Player, _FRUITCHECK, _Dev):
	_set_pos(_FRUITCHECK)
	var _return
	match _ButID:
		0:
			for _i in _NUM:
				var _FRUIT = _Dev.ItemOBJ_Array.back()
				if layer1_Array.size() < int(_FRUIT.Weight):
					_Dev.ItemOBJ_Array.erase(_FRUIT)
					_Dev.ItemNode.remove_child(_FRUIT)
					if not _Dev.ItemOBJ_Array:
						_Dev.HasItem = false
					_return = _FruitOn(1, _FRUIT)
			_Dev.call_Check(_Player)
			call_Fruit_PutOn( - 1, _Player, _Dev)
			return _return
		1:
			for _i in _NUM:
				var _FRUIT = _Dev.ItemOBJ_Array.back()
				if layer2_Array.size() < int(_FRUIT.Weight):
					_Dev.ItemOBJ_Array.erase(_FRUIT)
					_Dev.ItemNode.remove_child(_FRUIT)
					if not _Dev.ItemOBJ_Array:
						_Dev.HasItem = false
					_return = _FruitOn(2, _FRUIT)
			_Dev.call_Check(_Player)
			call_Fruit_PutOn( - 1, _Player, _Dev)
			return _return
		3:
			for _i in _NUM:
				var _FRUIT = _Dev.ItemOBJ_Array.back()
				if layer3_Array.size() < int(_FRUIT.Weight):
					_Dev.ItemOBJ_Array.erase(_FRUIT)
					_Dev.ItemNode.remove_child(_FRUIT)
					if not _Dev.ItemOBJ_Array:
						_Dev.HasItem = false
					_return = _FruitOn(3, _FRUIT)
			_Dev.call_Check(_Player)
			call_Fruit_PutOn( - 1, _Player, _Dev)
			return _return
		2:
			for _i in _NUM:
				var _FRUIT = _Dev.ItemOBJ_Array.back()
				if layer4_Array.size() < int(_FRUIT.Weight):
					_Dev.ItemOBJ_Array.erase(_FRUIT)
					_Dev.ItemNode.remove_child(_FRUIT)
					if not _Dev.ItemOBJ_Array:
						_Dev.HasItem = false
					_return = _FruitOn(4, _FRUIT)
			_Dev.call_Check(_Player)
			call_Fruit_PutOn( - 1, _Player, _Dev)
			return _return

func call_PutOn(_butID, _Player):

	if _butID == - 1:
		_But_Show(_Player)

	elif _butID == 0:
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if layer4_Array.size() < int(_Dev.Weight):

			_set_pos(_Dev)
			if Layer1_Item != "":
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
		if layer2_Array.size() < int(_Dev.Weight):
			_set_pos(_Dev)
			if Layer2_Item != "":
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
		if layer3_Array.size() < int(_Dev.Weight):
			_set_pos(_Dev)
			if Layer3_Item != "":
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
		if layer4_Array.size() < int(_Dev.Weight):
			_set_pos(_Dev)
			if Layer4_Item != "":
				if Layer4_Item == _Dev.TypeStr:
					var _put = _PutOn(4, _Player)
					call_pick( - 1, _Player)
					return _put
			else:
				var _put = _PutOn(4, _Player)
				call_pick( - 1, _Player)
				return _put
func call_FruitOn_puppet(_Layer, _FruitID):
	if SteamLogic.OBJECT_DIC.has(_FruitID):
		var _Fruit = SteamLogic.OBJECT_DIC[_FruitID]
		_FruitOn(_Layer, _Fruit)
func _FruitOn(_Layer, _Fruit):

	var _Audio = GameLogic.Audio.return_Effect(_Fruit.AudioPut)
	match _Layer:
		1:
			if layer1_Array.size() >= _Fruit.Weight:
				return
			_Fruit.position = PutOnPos_Array[layer1_Array.size()]
			Layer1.add_child(_Fruit)
			layer1_Array.append(_Fruit)
			if Layer1_Item != _Fruit.TypeStr:
				Layer1_Item = _Fruit.TypeStr
			Layer1_Weight += _Fruit.Weight
			_Audio.play(0)
			return "放"
		2:
			if layer2_Array.size() >= _Fruit.Weight:
				return
			_Fruit.position = PutOnPos_Array[layer2_Array.size()]
			Layer2.add_child(_Fruit)
			layer2_Array.append(_Fruit)
			if Layer2_Item != _Fruit.TypeStr:
				Layer2_Item = _Fruit.TypeStr
			Layer2_Weight += _Fruit.Weight
			_Audio.play(0)
			return "放"
		3:
			if layer3_Array.size() >= _Fruit.Weight:
				return
			_Fruit.position = PutOnPos_Array[layer3_Array.size()]
			Layer3.add_child(_Fruit)
			layer3_Array.append(_Fruit)
			if Layer3_Item != _Fruit.TypeStr:
				Layer3_Item = _Fruit.TypeStr
			Layer3_Weight += _Fruit.Weight
			_Audio.play(0)
			return "放"
		4:
			if layer4_Array.size() >= _Fruit.Weight:
				return
			_Fruit.position = PutOnPos_Array[layer4_Array.size()]
			Layer4.add_child(_Fruit)
			layer4_Array.append(_Fruit)
			if Layer4_Item != _Fruit.TypeStr:
				Layer4_Item = _Fruit.TypeStr
			Layer4_Weight += _Fruit.Weight
			_Audio.play(0)
			return "放"
func _PutOn_puppet(_Layer, _PlayerPath, _DevID):

	var _Player = get_node(_PlayerPath)
	if SteamLogic.OBJECT_DIC.has(_DevID):
		var _Dev = SteamLogic.OBJECT_DIC[_DevID]
		var _return = PutOn_Logic(_Layer, _Player, _Dev)
		call_pick( - 1, _Player)
		return _return
func _PutOn(_Layer, _Player):

	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	var _return = PutOn_Logic(_Layer, _Player, _Dev)
	call_pick( - 1, _Player)
	return _return
func PutOn_Logic(_Layer, _Player, _Dev):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "_PutOn_puppet", [_Layer, _Player.get_path(), _Dev._SELFID])

	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	var _c = _Dev.TypeStr
	match _Layer:
		1:
			if layer1_Array.size() < int(_Dev.Weight):
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
			if layer2_Array.size() < int(_Dev.Weight):
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
			if layer3_Array.size() < int(_Dev.Weight):
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
			if layer4_Array.size() < int(_Dev.Weight):
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
			if Layer1_Item != "":
				b1_bool = true
			if Layer2_Item != "":
				b2_bool = true
			if Layer3_Item != "":
				b3_bool = true
			if Layer4_Item != "":
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
			if Layer1_Item != "":
				var _pick = _pick(1, _Player)
				var _put = call_PutOn( - 1, _Player)
				if _pick != null:
					return _pick
				if _put != null:
					return _put

		1:
			if Layer2_Item != "":
				var _pick = _pick(2, _Player)
				var _put = call_PutOn( - 1, _Player)
				if _pick != null:
					return _pick
				if _put != null:
					return _put
		3:

			if Layer3_Item != "":
				var _pick = _pick(3, _Player)
				var _put = call_PutOn( - 1, _Player)

				if _pick != null:
					return _pick
				if _put != null:
					return _put

		2:
			if Layer4_Item != "":
				var _pick = _pick(4, _Player)
				var _put = call_PutOn( - 1, _Player)
				if _pick != null:
					return _pick
				if _put != null:
					return _put
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
		_ButShowLogic(_Player, _OBJ)
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
				Layer1_Item = ""
		2:
			_Dev = layer2_Array.pop_back()

			Layer2_Weight -= _Dev.Weight
			if not layer2_Array.size():
				Layer2_Item = ""
		3:
			_Dev = layer3_Array.pop_back()

			Layer3_Weight -= _Dev.Weight
			if not layer3_Array.size():
				Layer3_Item = ""
		4:
			_Dev = layer4_Array.pop_back()

			Layer4_Weight -= _Dev.Weight
			if not layer4_Array.size():
				Layer4_Item = ""
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

func call_TurnAni():
	if SelfDev == "FreezeShelf":
		if has_node("AniNode/Act"):
			$AniNode / Act.play("Used")
		if layer1_Array.size() or layer2_Array.size() or layer3_Array.size() or layer4_Array.size():

			if $AniNode / TurnAni.assigned_animation != "On":
				$AniNode / TurnAni.play("On")
		else:

			if $AniNode / TurnAni.assigned_animation != "Off":
				$AniNode / TurnAni.play("Off")
func _on_CheckArea_area_entered(_area: Area2D) -> void :

	IsOverlap = true

func call_put_in_cup(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_A.show()
			_B.show()
			_X.show()
			_Y.show()
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			var TypeStr = _HoldObj.get("TypeStr")
			if TypeStr in ["DrinkCup_S", "DrinkCup_M", "DrinkCup_L", "SodaCan_S", "SodaCan_M", "SodaCan_L"]:
				if Layer1_Item in ["桑葚", "草莓", "橙子", "柠檬", "百香果", "鸡蛋"]:
					_A.show()
				else:
					_A.hide()
				if Layer2_Item in ["桑葚", "草莓", "橙子", "柠檬", "百香果", "鸡蛋"]:
					_B.show()
				else:
					_B.hide()
				if Layer3_Item in ["桑葚", "草莓", "橙子", "柠檬", "百香果", "鸡蛋"]:
					_Y.show()
				else:
					_Y.hide()
				if Layer4_Item in ["桑葚", "草莓", "橙子", "柠檬", "百香果", "鸡蛋"]:
					_X.show()
				else:
					_X.hide()
			But_Switch(true, _Player)
		0, 1, 2, 3:

			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			var _FruitList: Array = ["桑葚", "草莓", "橙子", "柠檬", "百香果", "鸡蛋"]
			var _CheckLayer: int = 0
			match _ButID:
				0:
					if Layer1_Item in _FruitList:
						_CheckLayer = 1
				1:
					if Layer2_Item in _FruitList:
						_CheckLayer = 2
				3:
					if Layer3_Item in _FruitList:
						_CheckLayer = 3
				2:
					if Layer4_Item in _FruitList:
						_CheckLayer = 4
			match _CheckLayer:
				1:
					if layer1_Array.size():
						if Layer1_Item in ["橙子", "柠檬"]:
							if _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
								if _HoldObj.LIQUID_DIR.has("啤酒泡"):
									if _HoldObj.LIQUID_DIR["啤酒泡"] == 0:
										return
								else:
									return
							var _FRUIT = layer1_Array.pop_back()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
								Layer2_Item, Layer2_Weight,
								Layer3_Item, Layer3_Weight,
								Layer4_Item, Layer4_Weight,
								_FRUIT._SELFID, _Player.get_path()])
							if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):

								return true
						elif Layer1_Item in ["百香果", "鸡蛋"]:
							var _CheckExtra: int = 0
							if _HoldObj.Extra_1 == "":
								_CheckExtra = 1
							elif _HoldObj.Extra_2 == "" and _HoldObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M", "BeerCup_M", "BeerCup_L"]:
								_CheckExtra = 2
							elif _HoldObj.Extra_3 == "" and _HoldObj.TYPE in ["DrinkCup_L", "SuperCup_M", "BeerCup_L"]:
								_CheckExtra = 3
							elif _HoldObj.get("Extra_4") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 4
							elif _HoldObj.get("Extra_5") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 5
							if _CheckExtra > 0:
								var _FRUIT = layer1_Array.pop_back()
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
									Layer2_Item, Layer2_Weight,
									Layer3_Item, Layer3_Weight,
									Layer4_Item, Layer4_Weight,
									_FRUIT._SELFID, _Player.get_path()])
								if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):
									return true
						elif Layer1_Item in ["桑葚", "草莓"]:
							var _CHECK = _HoldObj.return_add_Extra(Layer1_Item)
							if _CHECK:
								var _FRUIT = layer1_Array.pop_back()
								Layer1.remove_child(_FRUIT)
								_FRUIT.call_del()
								if not layer1_Array.size():
									Layer1_Item = ""
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "call_InCup_puppet", [1])
								return "加小料"
				2:
					if layer2_Array.size():
						if Layer2_Item in ["橙子", "柠檬"]:
							if _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
								if _HoldObj.LIQUID_DIR.has("啤酒泡"):
									if _HoldObj.LIQUID_DIR["啤酒泡"] == 0:
										return
								else:
									return
							var _FRUIT = layer2_Array.pop_back()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
								Layer2_Item, Layer2_Weight,
								Layer3_Item, Layer3_Weight,
								Layer4_Item, Layer4_Weight,
								_FRUIT._SELFID, _Player.get_path()])
							if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):

								return true
						elif Layer2_Item in ["百香果", "鸡蛋"]:
							var _CheckExtra: int = 0
							if _HoldObj.Extra_1 == "":
								_CheckExtra = 1
							elif _HoldObj.Extra_2 == "" and _HoldObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M", "BeerCup_M", "BeerCup_L"]:
								_CheckExtra = 2
							elif _HoldObj.Extra_3 == "" and _HoldObj.TYPE in ["DrinkCup_L", "SuperCup_M", "BeerCup_L"]:
								_CheckExtra = 3
							elif _HoldObj.get("Extra_4") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 4
							elif _HoldObj.get("Extra_5") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 5
							if _CheckExtra > 0:
								var _FRUIT = layer2_Array.pop_back()
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
									Layer2_Item, Layer2_Weight,
									Layer3_Item, Layer3_Weight,
									Layer4_Item, Layer4_Weight,
									_FRUIT._SELFID, _Player.get_path()])
								if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):
									return true
						elif Layer2_Item in ["桑葚", "草莓"]:
							var _CHECK = _HoldObj.return_add_Extra(Layer2_Item)
							if _CHECK:
								var _FRUIT = layer2_Array.pop_back()
								Layer2.remove_child(_FRUIT)
								_FRUIT.call_del()
								if not layer2_Array.size():
									Layer2_Item = ""
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "call_InCup_puppet", [2])
								return "加小料"
				3:
					if layer3_Array.size():
						if Layer3_Item in ["橙子", "柠檬"]:
							if _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
								if _HoldObj.LIQUID_DIR.has("啤酒泡"):
									if _HoldObj.LIQUID_DIR["啤酒泡"] == 0:
										return
								else:
									return
							var _FRUIT = layer3_Array.pop_back()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
								Layer2_Item, Layer2_Weight,
								Layer3_Item, Layer3_Weight,
								Layer4_Item, Layer4_Weight,
								_FRUIT._SELFID, _Player.get_path()])
							if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):

								return true

						elif Layer3_Item in ["百香果", "鸡蛋"]:
							var _CheckExtra: int = 0
							if _HoldObj.Extra_1 == "":
								_CheckExtra = 1
							elif _HoldObj.Extra_2 == "" and _HoldObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M", "BeerCup_M", "BeerCup_L"]:
								_CheckExtra = 2
							elif _HoldObj.Extra_3 == "" and _HoldObj.TYPE in ["DrinkCup_L", "SuperCup_M", "BeerCup_L"]:
								_CheckExtra = 3
							elif _HoldObj.get("Extra_4") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 4
							elif _HoldObj.get("Extra_5") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 5
							if _CheckExtra > 0:
								var _FRUIT = layer3_Array.pop_back()
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
									Layer2_Item, Layer2_Weight,
									Layer3_Item, Layer3_Weight,
									Layer4_Item, Layer4_Weight,
									_FRUIT._SELFID, _Player.get_path()])
								if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):
									return true
						elif Layer3_Item in ["桑葚", "草莓"]:
							var _CHECK = _HoldObj.return_add_Extra(Layer3_Item)
							if _CHECK:
								var _FRUIT = layer3_Array.pop_back()
								Layer3.remove_child(_FRUIT)
								_FRUIT.call_del()
								if not layer3_Array.size():
									Layer3_Item = ""
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "call_InCup_puppet", [3])
								return "加小料"
				4:
					if layer4_Array.size():
						if Layer4_Item in ["橙子", "柠檬"]:
							if _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
								if _HoldObj.LIQUID_DIR.has("啤酒泡"):
									if _HoldObj.LIQUID_DIR["啤酒泡"] == 0:
										return
								else:
									return
							var _FRUIT = layer4_Array.pop_back()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
								Layer2_Item, Layer2_Weight,
								Layer3_Item, Layer3_Weight,
								Layer4_Item, Layer4_Weight,
								_FRUIT._SELFID, _Player.get_path()])
							if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):
								return true
						elif Layer4_Item in ["百香果", "鸡蛋"]:
							var _CheckExtra: int = 0
							if _HoldObj.Extra_1 == "":
								_CheckExtra = 1
							elif _HoldObj.Extra_2 == "" and _HoldObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M", "BeerCup_M", "BeerCup_L"]:
								_CheckExtra = 2
							elif _HoldObj.Extra_3 == "" and _HoldObj.TYPE in ["DrinkCup_L", "SuperCup_M", "BeerCup_L"]:
								_CheckExtra = 3
							elif _HoldObj.get("Extra_4") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 4
							elif _HoldObj.get("Extra_5") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 5
							if _CheckExtra > 0:
								var _FRUIT = layer4_Array.pop_back()
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "_puppet_pick", [_CheckLayer, Layer1_Item, Layer1_Weight,
									Layer2_Item, Layer2_Weight,
									Layer3_Item, Layer3_Weight,
									Layer4_Item, Layer4_Weight,
									_FRUIT._SELFID, _Player.get_path()])
								if _FRUIT.call_WaterInDrinkCup(0, _HoldObj, _Player):
									return true
						elif Layer4_Item in ["桑葚", "草莓"]:
							var _CHECK = _HoldObj.return_add_Extra(Layer4_Item)
							if _CHECK:
								var _FRUIT = layer4_Array.pop_back()
								Layer4.remove_child(_FRUIT)
								_FRUIT.call_del()
								if not layer4_Array.size():
									Layer4_Item = ""
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "call_InCup_puppet", [4])
								return "加小料"

func call_InCup_puppet(_LAYER):
	var _Audio = GameLogic.Audio.return_Effect("气泡")
	_Audio.play(0)
	match _LAYER:
		1:
			if layer1_Array.size():
				var _FRUIT = layer1_Array.pop_back()
				Layer1.remove_child(_FRUIT)
				_FRUIT.call_del()
				if not layer1_Array.size():
					Layer1_Item = ""
				return "加小料"
		2:
			if layer2_Array.size():

				var _FRUIT = layer2_Array.pop_back()
				Layer2.remove_child(_FRUIT)
				_FRUIT.call_del()
				if not layer2_Array.size():
					Layer2_Item = ""

				return "加小料"
		3:
			if layer3_Array.size():

				var _FRUIT = layer3_Array.pop_back()
				Layer3.remove_child(_FRUIT)
				_FRUIT.call_del()
				if not layer3_Array.size():
					Layer3_Item = ""

				return "加小料"
		4:
			if layer4_Array.size():

				var _FRUIT = layer4_Array.pop_back()
				Layer4.remove_child(_FRUIT)
				_FRUIT.call_del()
				if not layer4_Array.size():
					Layer4_Item = ""

				return "加小料"
