extends Node2D

export (String, "L", "R") var TYPE: String
export (int, 1, 2, 3) var TEX: int = 1

onready var SitNode = get_node("SitNode")
var IsSitting: bool
var _SittingNPC
var OrderBool: bool
var IsOrder: bool

func _ready():
	if not GameLogic.is_connected("DayStart", self, "call_init"):
		var _CON = GameLogic.connect("DayStart", self, "call_init")

func call_NPC_order():
	if IsOrder:
		return
	IsOrder = true
	get_parent().call_NPC_order(_SittingNPC)
func call_leaving_puppet(_POS):
	IsSitting = false
	OrderBool = false
	IsOrder = false
	get_parent().call_Order_Del(_SittingNPC)
	if name == "L":
		get_parent().call_PickUp_Del("L")
	if name == "R":
		get_parent().call_PickUp_Del("R")
	if SitNode.has_node(_SittingNPC.get_path()):
		SitNode.remove_child(_SittingNPC)
	_SittingNPC.position = _POS
	_SittingNPC.IsSit = false
	if get_tree().get_root().has_node("Level/YSort/NPCs"):
		get_tree().get_root().get_node("Level/YSort/NPCs").add_child(_SittingNPC)
	_SittingNPC = null
func call_leaving(_Pos: Vector2):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_leaving_puppet", [_Pos])
	IsSitting = false
	OrderBool = false
	IsOrder = false
	get_parent().call_Order_Del(_SittingNPC)
	if name == "L":
		get_parent().call_PickUp_Del("L")
	if name == "R":
		get_parent().call_PickUp_Del("R")
	if SitNode.has_node(_SittingNPC.get_path()):
		SitNode.remove_child(_SittingNPC)
	_SittingNPC.position = _Pos
	if get_tree().get_root().has_node("Level/YSort/NPCs"):
		get_tree().get_root().get_node("Level/YSort/NPCs").add_child(_SittingNPC)
	_SittingNPC = null
func call_sitting(_NPC):
	_SittingNPC = _NPC
	IsSitting = true
	_NPC.get_parent().remove_child(_NPC)
	_NPC.position = Vector2.ZERO
	match self.name:
		"L":
			_NPC.get_node("Avatar").FACE = _NPC.get_node("Avatar").face_right
		"R":
			_NPC.get_node("Avatar").FACE = _NPC.get_node("Avatar").face_left
	SitNode.add_child(_NPC)

func call_init():
	IsSitting = false
	OrderBool = false
	IsOrder = false
	if is_instance_valid(_SittingNPC):
		_SittingNPC.queue_free()

	_Tex_Init()
	_Type_Init()
	if not GameLogic.Order.cur_SeatList.has(self):
		GameLogic.Order.cur_SeatList.append(self)
func _Type_Init():
	match TYPE:
		"L":
			get_node("TypeAni").play("L")
		"R":
			get_node("TypeAni").play("R")
func _Tex_Init():
	if has_node("Ani"):
		get_node("Ani").play(str(TEX))
