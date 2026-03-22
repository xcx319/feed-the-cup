extends VBoxContainer

var Skill: Array
func _Skill_logic(_Skill: Array):
	Skill = _Skill
	if Skill:
		for i in Skill.size():
			if GameLogic.Config.CardConfig.has(Skill[i]):
				var _Label = Label.new()
				_Label.rect_min_size = Vector2(0, 21)
				_Label.align = Label.ALIGN_CENTER
				_Label.valign = Label.VALIGN_CENTER
				_Label.autowrap = true
				_Label.clip_text = true
				_Label.text = GameLogic.Config.CardConfig[Skill[i]].ShowNameID
				_Label.modulate = Color8(0, 255, 0, 255)
				self.add_child(_Label)
