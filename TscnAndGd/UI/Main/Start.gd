extends Control

onready var logoUI = $Logo
onready var logeSprite = $Logo / Sprite
onready var logeAni = $Logo / Sprite / Ani

var cur_pressed: bool
var _Check: bool
func _control_logic(_but, _value, _type):

	if _value == 0:
		cur_pressed = false
	if cur_pressed:
		return
	match _but:
		"A", "B", "START":
			if _value == 1:
				cur_pressed = true
				_on_Button_pressed()

func _ready():

	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	logoshow()





func logoshow():

	set_process(false)


	pass

func logoshowend():

	if not GameLogic.Save.levelData.has("Level_bool"):
		GameLogic.Save.levelData["Level_bool"] = false

		GameLogic.call_NewGame()
		GameLogic.call_HomeLoad()

	_OpenCG_End()



func _OpenCG_End():

	if _Check:
		return
	_Check = true
	logeSprite.visible = false
	GameLogic.LoadingUI.mainUILoad()

	self.queue_free()
func _on_Button_pressed() -> void :
	if not logeAni.get_current_animation():
		logeAni.play("show")
		return

	if logeAni.assigned_animation == "show":
		logeAni.play("OpenCG")
	elif logeAni.assigned_animation == "OpenCG":
		_OpenCG_End()

func call_OpenCG():
	if has_node("OpenCG"):
		get_node("OpenCG").call_play()
	else:
		_on_Button_pressed()
