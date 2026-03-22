extends CanvasLayer

var _paused: bool

onready var Ani = get_node("AniNode/Ani")

func call_init():
	if GameLogic.InHome_Bool:
		return
	if GameLogic.cur_Day == 1:
		call_show("Tutorial_1")
func call_show(_AniName):
	if not Ani.has_animation(_AniName):
		return
	if not get_tree().is_paused():
		_paused = true
		Ani.play(_AniName)
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().set_pause(true)

		yield(get_tree().create_timer(0.4), "timeout")
		if is_instance_valid(GameLogic.player_1P):
			GameLogic.player_1P.call_control(1)
		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.connect("P1_Control", self, "_control_logic")

		if GameLogic.Player2_bool:
			if is_instance_valid(GameLogic.player_2P):
				GameLogic.player_2P.call_control(1)
			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.connect("P2_Control", self, "_control_logic")
func _control_logic(_ButID, _value, _type):
	match _ButID:
		"A":
			call_hide()
func call_hide():
	if _paused:
		_paused = false
		Ani.play("hide")
func hideAniEnd():
	get_tree().set_pause(false)
	GameLogic.player_1P.call_control(0)
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.player_2P:
		GameLogic.player_2P.call_control(0)
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
