extends Node2D

var CanPass: bool
var Can_Pressed: bool
func _ready():
	GameLogic.Audio.call_BGM_play("直营店教学")

	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	call_deferred("call_init")
func call_init():

	if not GameLogic.Save.gameData.has("OpenCG"):
		CanPass = false

	else:
		CanPass = true

func Mix_Finished():
	get_node("AllAni").play("20")
	var _ORANGE = get_node("YSort/Players/Bear/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note/OrangeinHand")
	_ORANGE.get_node("MixNode/MixAni").play("hide")
var NO_A_ARRAY = ["10", "11", "12", "13", "14", "15", "16", "17", "19", "24", "36", "开盖"]
var NO_A_SHOW_ARRAY = ["7", "8", "10", "11", "12", "13", "14", "15", "16", "17", "19", "20", "24", "25", "开盖", "28", "30", "32", "33", "35", "36"]
func _control_logic(_but, _value, _type):

	match _but:
		"START":

			if _value == 1:
				GameLogic.GameUI.call_esc(_value)
				return

	if not Can_Pressed:
		return
	match _but:
		"A":
			if get_node("AllAni").assigned_animation in NO_A_ARRAY:
				return
			GameLogic.Audio.But_Apply.play(0)
			call_next()
			Can_Pressed = false
		"X":
			if get_node("AllAni").assigned_animation in ["12", "14", "16", "24"]:
				GameLogic.Audio.But_Apply.play(0)
				call_next()
				Can_Pressed = false
				return
			if get_node("AllAni").assigned_animation in ["19", "开盖"] and _value == 1:
				get_node("AllAni").play("开盖")
				var _ORANGE = get_node("YSort/Players/Bear/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note/OrangeinHand")
				_ORANGE.get_node("MixNode/MixAni").play("Mixd")
			elif get_node("AllAni").assigned_animation == "开盖" and _value == 0:
				get_node("AllAni").stop(true)
				var _ORANGE = get_node("YSort/Players/Bear/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note/OrangeinHand")
				_ORANGE.get_node("MixNode/MixAni").play("init")
			elif get_node("AllAni").assigned_animation in ["10", "11", "13", "15", "17"]:
				GameLogic.Audio.But_Apply.play(0)
				call_next()
				Can_Pressed = false
		"Y":
			if get_node("AllAni").assigned_animation in ["36"]:
				GameLogic.Audio.But_Apply.play(0)
				call_next()
				Can_Pressed = false
				return
func call_next():
	var _CurAni = int(get_node("AllAni").assigned_animation) + 1

	if get_node("AllAni").has_animation(str(_CurAni)):
		can_not_pressed()
		get_node("AllAni").play(str(_CurAni))
	else:
		if not GameLogic.Save.levelData.has("Level_bool"):
			GameLogic.Save.levelData["Level_bool"] = false

			GameLogic.call_NewGame()
			GameLogic.call_HomeLoad()
		else:
			if GameLogic.Save.levelData.Level_bool:
				GameLogic.call_load()
		if not GameLogic.Save.gameData.has("OpenCG"):
			GameLogic.Save.gameData["OpenCG"] = true
		GameLogic.Tutorial.Skip_OPENCG = true
		GameLogic.call_save()
		GameLogic.call_HomeLoad()

func can_pressed():
	Can_Pressed = true
	if get_node("AllAni").assigned_animation in NO_A_SHOW_ARRAY:
		$YSort / Players / Devil / TalkPop / SayLabel / NinePatchRect / A.visible = false
		return
	$YSort / Players / Devil / TalkPop / SayLabel / NinePatchRect / A.visible = true
func can_not_pressed():
	Can_Pressed = false
	$YSort / Players / Devil / TalkPop / SayLabel / NinePatchRect / A.visible = false
func _OpenLight():
	pass
