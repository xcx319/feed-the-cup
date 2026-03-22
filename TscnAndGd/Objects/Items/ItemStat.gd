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

onready var ItemNode = get_parent().get_parent()

func _ready() -> void :

	if ConfigLogic.ItemConfig.has(ItemNode.name):
		p_Stat = ConfigLogic.ItemConfig[ItemNode.name]
		ItemNode.name = p_Stat["FuncType"]

	if ItemNode.has_method("data_SYCN") and p_Stat != null:
		ItemNode.data_SYCN(p_Stat)
	if ItemNode.has_node("LogicNode"):
		if ItemNode.get_node("LogicNode").has_method("config_SYCN"):
			ItemNode.get_node("LogicNode").config_SYCN(p_Stat)
	pass

func call_data_init():
	if ConfigLogic.ItemConfig.has(ItemNode.name):
		p_Stat = ConfigLogic.ItemConfig[ItemNode.name]

	if ItemNode.has_method("data_SYCN") and p_Stat != null:
		ItemNode.data_SYCN(p_Stat)
	if ItemNode.has_node("LogicNode"):
		if ItemNode.get_node("LogicNode").has_method("config_SYCN"):
			ItemNode.get_node("LogicNode").config_SYCN(p_Stat)
	pass
