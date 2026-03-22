extends Head_Object
var SelfDev = "FreezeShelf"
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

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _But_Show(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
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



		if b1_bool:
			_A.call_player_in(_Player.cur_Player)
		else:
			_A.call_player_out(_Player.cur_Player)
		if b2_bool:
			_B.call_player_in(_Player.cur_Player)
		else:
			_B.call_player_out(_Player.cur_Player)
		if b3_bool:
			_X.call_player_in(_Player.cur_Player)
		else:
			_X.call_player_out(_Player.cur_Player)
		if b4_bool:
			_Y.call_player_in(_Player.cur_Player)
		else:
			_Y.call_player_out(_Player.cur_Player)
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _bool:
		_But_Show(_Player)
	.But_Switch(_bool, _Player)
func _ready() -> void :
	call_init(SelfDev)
	GuideNode.hide()
	if get_parent().name == "Updates":
		GuideAni.play("show")
func call_guide_hide():
	GuideNode.hide()
func call_guide_show():
	GuideNode.show()
func _set_pos(_Obj):
	PutOnPos_Array.clear()

	if _Obj.IsItem:
		match _Obj.Weight:
			1:
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
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.Layer1_Array.size():
		for _ObjInfo in _Info.Layer1_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			_Obj.call_init(_ObjInfo.TSCN)
			_ObjLoad(_Obj, 1)
			_Obj.call_load(_ObjInfo)
	if _Info.Layer2_Array.size():
		for _ObjInfo in _Info.Layer2_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			_Obj.call_init(_ObjInfo.TSCN)
			_ObjLoad(_Obj, 2)
			_Obj.call_load(_ObjInfo)

	if _Info.Layer3_Array.size():
		for _ObjInfo in _Info.Layer3_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			_Obj.call_init(_ObjInfo.TSCN)
			_ObjLoad(_Obj, 3)
			_Obj.call_load(_ObjInfo)

	if _Info.Layer4_Array.size():
		for _ObjInfo in _Info.Layer4_Array:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			_Obj.call_init(_ObjInfo.TSCN)
			_ObjLoad(_Obj, 4)
			_Obj.call_load(_ObjInfo)

func call_PutOn(_butID, _Player):

	if _butID == - 1:
		_But_Show(_Player)
	if _butID == 0:
		if layer1_Array.size() < 8:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			_set_pos(_Dev)
			if Layer1_Item != null:
				if Layer1_Item == _Dev.TypeStr:
					_PutOn(1, _Player)
			else:
				_PutOn(1, _Player)
	elif _butID == 1:
		if layer2_Array.size() < 8:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			_set_pos(_Dev)
			if Layer2_Item != null:
				if Layer2_Item == _Dev.TypeStr:
					_PutOn(2, _Player)
			else:
				_PutOn(2, _Player)
	elif _butID == 2:
		if layer3_Array.size() < 8:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			_set_pos(_Dev)
			if Layer3_Item != null:
				if Layer3_Item == _Dev.TypeStr:
					_PutOn(3, _Player)
			else:
				_PutOn(3, _Player)
	elif _butID == 3:
		if layer4_Array.size() < 8:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			_set_pos(_Dev)
			if Layer4_Item != null:
				if Layer4_Item == _Dev.TypeStr:
					_PutOn(4, _Player)
			else:
				_PutOn(4, _Player)

func _PutOn(_Layer, _Player):

	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	match _Layer:
		1:
			if layer1_Array.size() < 8:
				var _Dev = instance_from_id(_Player.Con.HoldInsId)
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer1_Array.size()]
				Layer1.add_child(_Dev)
				layer1_Array.append(_Dev)
				if Layer1_Item != _Dev.TypeStr:
					Layer1_Item = _Dev.TypeStr
				_Dev.But_Switch(false, _Player)
				return 0
		2:
			if layer2_Array.size() < 8:
				var _Dev = instance_from_id(_Player.Con.HoldInsId)
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer2_Array.size()]
				Layer2.add_child(_Dev)
				layer2_Array.append(_Dev)
				if Layer2_Item != _Dev.TypeStr:
					Layer2_Item = _Dev.TypeStr
				_Dev.But_Switch(false, _Player)
				return 0
		3:
			if layer3_Array.size() < 8:
				var _Dev = instance_from_id(_Player.Con.HoldInsId)
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer3_Array.size()]
				Layer3.add_child(_Dev)
				layer3_Array.append(_Dev)
				if Layer3_Item != _Dev.TypeStr:
					Layer3_Item = _Dev.TypeStr
				_Dev.But_Switch(false, _Player)
				return 0
		4:
			if layer4_Array.size() < 8:
				var _Dev = instance_from_id(_Player.Con.HoldInsId)
				_Player.WeaponNode.remove_child(_Dev)
				_Player.Stat.call_carry_off()
				_Dev.position = PutOnPos_Array[layer4_Array.size()]
				Layer4.add_child(_Dev)
				layer4_Array.append(_Dev)
				if Layer4_Item != _Dev.TypeStr:
					Layer4_Item = _Dev.TypeStr
				_Dev.But_Switch(false, _Player)
				return 0
	call_pick( - 1, _Player)
func call_pick(_butID, _Player):
	match _butID:
		- 1:

			pass
		0:
			if Layer1_Item != null:
				_pick(1, _Player)
				call_PutOn( - 1, _Player)
		1:
			if Layer2_Item != null:
				_pick(2, _Player)
				call_PutOn( - 1, _Player)
		2:
			if Layer3_Item != null:
				_pick(3, _Player)
				call_PutOn( - 1, _Player)
		3:
			if Layer4_Item != null:
				_pick(4, _Player)
				call_PutOn( - 1, _Player)

func _pick(_Layer, _Player):
	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	var _Dev
	match _Layer:
		1:
			_Dev = layer1_Array.pop_back()
			Layer1.remove_child(_Dev)
			if not layer1_Array.size():
				Layer1_Item = null
		2:
			_Dev = layer2_Array.pop_back()
			Layer2.remove_child(_Dev)
			if not layer2_Array.size():
				Layer2_Item = null
		3:
			_Dev = layer3_Array.pop_back()
			Layer3.remove_child(_Dev)
			if not layer3_Array.size():
				Layer3_Item = null
		4:
			_Dev = layer4_Array.pop_back()
			Layer4.remove_child(_Dev)
			if not layer4_Array.size():
				Layer4_Item = null
	_Dev.position = Vector2.ZERO
	_Player.WeaponNode.add_child(_Dev)
	_Player.Con.IsHold = true
	_Player.Stat.call_carry_on(_Dev.CarrySpeed)
	_Player.Con.HoldInsId = _Dev.get_instance_id()
	_Dev.Holding = true
	_Dev.Holder = _Player

func ButInfo_Switch(_butID, _but):

	pass

func _on_CheckArea_area_entered(_area: Area2D) -> void :
	IsOverlap = true
