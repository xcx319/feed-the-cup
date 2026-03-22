extends Node2D

var Can_Pressed: bool
onready var CurCamera = get_node("Camera2D")
var CanPass: bool
func _ready():
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	call_deferred("call_init")
func call_init():
	get_node("START").show_player(1)
	CurCamera.current = true
	if not GameLogic.Save.gameData.has("OpenCG"):
		CanPass = false
		get_node("START").visible = false
	else:
		CanPass = true
		get_node("START").visible = true

	$HomeInfo.hide()

func _control_logic(_but, _value, _type):

	match _but:
		"START":
			if CanPass:
				if _value != 1 or not CanESC:
					return
				if get_node("START").visible:
					if get_node("AniParts").assigned_animation != "END":
						GameLogic.Audio.But_Apply.play(0)
						_GameStart()
				else:
					GameLogic.Audio.But_Click.play(0)
					get_node("START").show()
		_:
			if CanPass:
				if not get_node("START").visible and _but != "A":
					get_node("START").show()
	if not Can_Pressed:
		return
	match _but:
		"A":
			call_next()
func Auto_Play():

	if get_node("AniParts").assigned_animation == "4":
		get_node("AniParts").play(str(5))
func call_next():
	var _CurAni = int(get_node("AniParts").assigned_animation) + 1
	if not CanPass and _CurAni < 5:
		return
	if _CurAni < 5:
		if not CanPass:
			return
		_CurAni = 5
		get_node("AnimationPlayer").stop()
		GameLogic.Audio.But_Apply.play(0)
	if get_node("AniParts").has_animation(str(_CurAni)):
		get_node("AniParts").play(str(_CurAni))
		GameLogic.Audio.But_Apply.play(0)
	else:
		get_node("AniParts").play("END")
		GameLogic.Audio.But_Apply.play(0)

func call_play():
	get_node("AnimationPlayer").play("init")

func call_start_from(_Ani: String):
	if get_node("AniParts").has_animation(_Ani):
		get_node("AniParts").play(_Ani)

var CanESC: bool = true
func _GameStart():
	CanESC = false

	if get_parent().get_parent().has_method("_OpenCG_End"):
		get_parent().get_parent()._OpenCG_End()
		self.queue_free()
	elif get_parent().has_method("_on_Play_pressed"):
		get_parent()._on_Play_pressed()
		self.queue_free()
func _OpenCG_End():

	GameLogic.LoadingUI.TutorialLoad()
	self.queue_free()
func call_END():
	if not GameLogic.Save.gameData.has("OpenCG"):
		GameLogic.Save.gameData["OpenCG"] = true

	_OpenCG_End()

func can_pressed():
	Can_Pressed = true
func can_not_pressed():
	Can_Pressed = false
