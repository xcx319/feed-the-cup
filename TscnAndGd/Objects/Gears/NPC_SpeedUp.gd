extends Area2D

export var SPEEDUPMULT: float = 1

func _on_NPC_body_entered(_body):
	if _body.has_node("Player/SpecialNode/PlayerSpecialEffect"):
		var _RUNNODE = _body.get_node("Player/SpecialNode/PlayerSpecialEffect")
		if _RUNNODE.IsRunning:
			_body.Stat.Ins_Skill_2_Mult = SPEEDUPMULT
			_body.Stat._speed_change_logic()
	elif _body.has_method("call_order"):
		_body.Stat.Ins_Skill_2_Mult = SPEEDUPMULT

		_body.Stat._speed_change_logic()
func _on_NPC_body_exited(_body):
	if _body.has_node("Player/SpecialNode/PlayerSpecialEffect"):
		var _RUNNODE = _body.get_node("Player/SpecialNode/PlayerSpecialEffect")

		_body.Stat.Ins_Skill_2_Mult = 1
		_body.Stat._data_instance()
	elif _body.has_method("call_order"):
		_body.Stat.Ins_Skill_2_Mult = 1
		_body.Stat._data_instance()
