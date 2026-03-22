extends Head_Object
var SelfDev = "WorkBench"

var CanPutDev: bool = true
export var Tex: int = 1
export var SPECIAL: int = 0
var TableItemOffset = Vector2(0, - 70)
onready var Name = self.editor_description

onready var _ShapeOffset = get_node("CollisionShape2D").position
onready var ObjNode = $ObjNode
onready var RayL = get_node("RayL")
onready var RayR = get_node("RayR")
onready var L_Single = get_node("TexNode/Single/L")
onready var R_Single = get_node("TexNode/Single/R")
onready var L_Show = get_node("TexNode/Connect/L")
onready var R_Show = get_node("TexNode/Connect/R")
onready var TypeAni = get_node("TexNode/TypeAni")

onready var GuideNode = get_node("GuideNode")
onready var GuideAni = get_node("GuideNode/Ani")

var _Show: bool
func But_Switch(_bool, _Player):

	if _Player.cur_RayObj != self:
		_bool = false
		call_OutLine(false)
		if is_instance_valid(OnTableObj):
			if OnTableObj.has_method("call_OutLine"):
				call_OutLine(false)
	.But_Switch(_bool, _Player)
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("OutLineAni").play("show")
		false:
			get_node("OutLineAni").play("init")
func _ready() -> void :
	call_init(SelfDev)
	call_deferred("call_connect_check")
	GuideNode.hide()
	if get_parent().name == "Updates":
		GuideAni.play("show")
	TypeAni.play(str(Tex))
	get_node("ObjNode").set_use_parent_material(true)


func call_Box_OnTable(_ButID, _CupObj, _Player):
	if is_instance_valid(OnTableObj):
		if OnTableObj.get("FuncType") == "Box":
			if OnTableObj.has_method("call_PickFruitInCup"):
				OnTableObj.call_PickFruitInCup(_ButID, _CupObj, _Player)

func call_guide_hide():
	GuideNode.hide()
func call_guide_show():
	GuideNode.show()

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("Tex"):
		Tex = int(_Info.Tex)
		TypeAni.play(str(Tex))
	if _Info.Table:
		var _TableData = _Info.Table
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_TableData.TSCN)
		if _TSCN == null:
			return
		var _Dev = _TSCN.instance()
		_Dev.position = _TableData.pos
		_Dev.name = _TableData.NAME
		ObjNode.add_child(_Dev)
		_Dev.call_load(_TableData)
		OnTableObj = _Dev
	if _Info.has("SPECIAL"):
		if _Info.SPECIAL == 1:
			SPECIAL = _Info.SPECIAL
			GameLogic.NPC.WORKBENCH.append(self)

func call_connect_check():
	L_Single.show()
	R_Single.show()
	L_Show.hide()
	R_Show.hide()
	if RayL.is_inside_tree():
		RayL.force_raycast_update()
		if RayL.is_colliding():
			var collider_L_1 = RayL.get_collider()
			if collider_L_1.editor_description in ["WorkBench", "WorkBench_Immovable"]:
				if collider_L_1.visible:
					L_Show.show()
					L_Single.hide()
		RayR.force_raycast_update()
		if RayR.is_colliding():
			var collider_R_1 = RayR.get_collider()
			if collider_R_1.editor_description in ["WorkBench", "WorkBench_Immovable"]:
				if collider_R_1.visible:
					R_Show.show()
					R_Single.hide()

func call_OnTable(_Obj):

	if _Obj == null:
		OnTableObj = null
	elif _Obj.get_parent().get_parent() == self:
		OnTableObj = _Obj

func _on_CheckArea_area_entered(_area: Area2D) -> void :

	IsOverlap = true

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
