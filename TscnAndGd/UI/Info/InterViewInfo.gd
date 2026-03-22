extends Control

var DayActionDic: Dictionary
var cur_show: bool
func _ready() -> void :
	pass

func call_init():
	pass

func call_show():
	if get_node("Ani/Ani").assigned_animation != "show":
		if get_parent().INFO:
			if not cur_show:
				cur_show = true
			get_node("DAILY/Label").text = str(get_parent().DailyWage)
			get_node("REACTION/Label").text = str(get_parent().ReactionTime)
			get_node("MOVE/Label").text = str(get_parent().Stat.MoveSpeed)
			DayActionDic = get_parent().DayActionDic
			if DayActionDic.has(0):
				get_node("WORKNUM").call_show(DayActionDic[0].size())
			else:
				get_node("WORKNUM").call_show(0)
			_Skill_Set(get_parent().SkillList)
			get_node("Ani/Ani").play("show")

func call_hide():
	if get_node("Ani/Ani").assigned_animation != "hide":
		get_node("Ani/Ani").play("hide")

func _Skill_Set(_SkillList):
	var _WORK: Array
	var _SKILL: Array
	for _SkillName in _SkillList:
		match int(GameLogic.Config.SkillConfig[_SkillName].Type):
			0:
				_WORK.append(_SkillName)
			1, 2:
				_SKILL.append(_SkillName)
	var _TEXT = GameLogic.CardTrans.get_message("信息-工作列表") + ":"
	for _NAME in _WORK:
		_TEXT += "\n" + "[color=#009600]" + GameLogic.CardTrans.get_message(_NAME) + "[/color]"
	_TEXT += "\n" + GameLogic.CardTrans.get_message("信息-特性列表") + ":"
	for _NAME in _SKILL:
		match int(GameLogic.Config.SkillConfig[_NAME].Type):
			1:
				_TEXT += "\n" + "[color=#009600]" + GameLogic.CardTrans.get_message(_NAME) + "[/color]"
			2:
				_TEXT += "\n" + "[color=#960000]" + GameLogic.CardTrans.get_message(_NAME) + "[/color]"
	get_node("SkillLabel").bbcode_text = _TEXT

	var _SkillNum = _SkillList.size()

	self.rect_position.y = - 220 - 22 * _SkillNum
