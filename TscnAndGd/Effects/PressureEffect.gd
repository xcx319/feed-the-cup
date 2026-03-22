extends Node2D

var Num: int
var Skill: Array
onready var PreSetAni = get_node("PreSetAni")
onready var PressureLabel = get_node("PressureLabel")

onready var SkillVBox = get_node("SkillVBox")

func _ready() -> void :
	PressureLabel.text = str(Num)
	if Num >= 0:
		PreSetAni.play("+")
	if Num < 0:
		PreSetAni.play("-")

func call_del():
	self.queue_free()

func _Skill_logic():
	SkillVBox._Skill_logic(Skill)
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
				SkillVBox.add_child(_Label)
