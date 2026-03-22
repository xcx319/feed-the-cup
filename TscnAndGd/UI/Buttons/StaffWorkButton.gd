extends Control

var ActionMax: int
var Name: String setget _NameSet
var cur_Work: Array setget _WorkSet
func _ready() -> void :
	pass
func _NameSet(_Name: String):
	Name = _Name
	get_node("WORKNAME").text = Name
func _WorkSet(_WorkDic):
	cur_Work = _WorkDic
	call_WorkSet()
func call_WorkSet():
	var _HBOX = get_node("HBox")
	for _Node in _HBOX.get_children():
		_Node.queue_free()
	var _WorkSize = cur_Work.size()
	for _i in ActionMax:
		var _ICON = GameLogic.TSCNLoad.StudyIcon_TSCN.instance()
		_ICON.name = str(_i + 1)
		_HBOX.add_child(_ICON)
		if _WorkSize >= (_i + 1):
			_ICON.get_node("1/Ani").play("True")
func call_show(_Num: int):

	var _NODE = get_node("HBox").get_children()
	var _i = 0
	for _Node in _NODE:
		if _i < _Num:
			_Node.get_node("1/Ani").play("True")
		else:
			_Node.get_node("1/Ani").play("init")
		_i += 1
