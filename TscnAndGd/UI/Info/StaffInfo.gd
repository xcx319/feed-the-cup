extends Control

onready var SliderNode = get_node("SliderNode/HSlider")
onready var InfoAni = get_node("Ani/Ani")
var DayActionDic: Dictionary
var cur_show: bool
func _ready() -> void :
	pass

func call_init():
	pass
func call_show():
	if get_parent().INFO:
		if not cur_show:
			cur_show = true
		var _INFO = get_parent().INFO
		get_node("DAILY/Label").text = str(_INFO.DailyWage)
		get_node("REACTION/Label").text = str(_INFO.ReactionTime)
		get_node("MOVE/Label").text = str(_INFO.MoveSpeed)
		DayActionDic = _INFO.DayActionDic
		_Skill_Set(_INFO.SkillList)
		InfoAni.play("show")

func call_hide():
	InfoAni.play_backwards("show")

func _Slider_Init():

	var _Num = GameLogic.cur_Staff.size()
	SliderNode.tick_count = _Num
	SliderNode.max_value = _Num

func call_InfoShow_Switch(_Switch: bool):
	match _Switch:
		true:
			_Slider_Init()

			InfoAni.play("show")
			cur_show = true
		false:
			InfoAni.play_backwards("show")
			cur_show = false

func _Skill_Set(_SkillList):
	var _SKillVBox = get_node("SkillVBox")
	for _Label in _SKillVBox.get_children():
		_Label.queue_free()
	var _LabelNode = load("res://TscnAndGd/UI/Info/SkillLabel.tscn")
	for _SkillName in _SkillList:
		var _Label = _LabelNode.instance()
		_Label.text = GameLogic.CardTrans.get_message(_SkillName)

		_SKillVBox.add_child(_Label)
		match int(GameLogic.Config.SkillConfig[_SkillName].Type):
			1:
				_Label.add_color_override("font_color", Color(0, 0.58, 0, 1))

			2:
				_Label.add_color_override("font_color", Color(0.58, 0, 0, 1))
func _Avatar_Set(_INFO):
	var _AvatarTSCN = GameLogic.Config.StaffConfig[str(_INFO.AvatarID)].TSCN
	var _TSCN = GameLogic.TSCNLoad.return_character(_AvatarTSCN)
	var _Avatar = _TSCN.instance()
	get_node("CPos").add_child(_Avatar)

	_Avatar.call_HeadType(str(_INFO.AvatarType))

func _Work_Set(_Max):
	var _WorkNode = get_node("WorkControl/WorkVBox")
	for _Node in _WorkNode.get_children():
		_Node.queue_free()
	for _ActName in DayActionDic.keys():
		var _StaffWorkBut = GameLogic.TSCNLoad.StaffWorkBut_TSCN.instance()
		_WorkNode.add_child(_StaffWorkBut)
		_StaffWorkBut.ActionMax = int(_Max)
		_StaffWorkBut.Name = str(_ActName)
		_StaffWorkBut.cur_Work = DayActionDic[_ActName]

func call_grabfocus():
	var _WorkNode = get_node("WorkControl/WorkVBox")
	if _WorkNode.get_child_count():
		var _FirstBut = _WorkNode.get_child(0)
		_FirstBut.grab_focus()
