extends Node

var p_Stat
var p_canmove: bool
var p_size: Vector2
var p_floor: bool
var p_wall: bool

var p_functype
var p_funcnum
var p_candrop
var p_hastable
enum FUNCTYPE{
	FT_Save_Normal,
	FT_Save_Low,
	FT_Save_freeze,
	FT_Water_Normal,
	FT_Water_Hot,
	FT_Water_Purify,
	FT_Order,
	FT_PickUp,
	FT_Rubbish,
	FT_DrinkCup,
	FT_Con_Liquid,
	FT_Con_Sugar,
	FT_Con_Ice,
	FT_Con_Cream,
	FT_Con_CheezeTop,
	FT_Con_PoderTop,
}

onready var DeviceNode = get_parent().get_parent()

func _ready() -> void :

	pass
func _data_logic():
	if GameLogic.Config.DeviceConfig.has(self.editor_description):
		p_Stat = GameLogic.Config.DeviceConfig[self.editor_description]

	if DeviceNode.has_method("data_SYCN") and p_Stat != null:
		DeviceNode.data_SYCN(p_Stat)
