extends Node2D

var cur_Used: bool
var P1_bool: bool
var P2_bool: bool
onready var Ani = get_node("Ani")
onready var GuideAni = get_node("GuideAni")
onready var ButShow = get_node("Button/A")
onready var UINode = get_node("CanvasLayer")
onready var CardUI
onready var Collision = get_node("Area2D/CollisionShape2D")
func _ready() -> void :
	call_deferred("call_init")
	var _check = GameLogic.connect("CallChallenge", self, "_Logic")
	var _TimeCheck = GameLogic.connect("OpenStore", self, "_StartCheck")
	_UI_init()
func _StartCheck():
	if cur_Used:
		return
	if GameLogic.GameUI.CurTime >= GameLogic.cur_OpenTime:
		_control_logic("A", 1, - 1)

func _Logic(_Switch: bool):
	match _Switch:
		true:
			Ani.play("hide")
			ButShow.hide()
		false:
			_Used_Switch(true)
func _del():
	self.queue_free()
func _Used_Switch(_Switch: bool):
	match _Switch:
		true:
			cur_Used = false
		false:
			cur_Used = true
func _UI_init():
	match GameLogic.GlobalData.LoadingType:
		1:
			_CardUI_Load()

func _CardUI_Load():

	var _UILoad = load("res://TscnAndGd/UI/InGame/CardUI.tscn")
	CardUI = _UILoad.instance()
	UINode.add_child(CardUI)
func _control_logic(_but, _value, _type):

	if cur_Used:
		return
	if _value == 1 or _value == - 1:

		match _but:
			"A":
				match GameLogic.GlobalData.LoadingType:
					0:
						_CardUI_Load()
				var _Audio = GameLogic.Audio.return_Effect("气泡")
				_Audio.play(0)
				CardUI.call_show()


				if is_instance_valid(GameLogic.player_1P):
					GameLogic.player_1P.call_control(1)
				if GameLogic.Player2_bool:
					if is_instance_valid(GameLogic.player_2P):
						GameLogic.player_2P.call_control(1)
				_Used_Switch(false)
				get_tree().set_pause(true)
func call_init():
	Ani.play("show")
func _on_Area2D_body_entered(body: Node) -> void :
	var _ID = body.cur_Player
	match _ID:
		1:
			if not P1_bool and not P2_bool:
				ButShow.call_player_in(_ID)
			P1_bool = true
			GameLogic.Con.connect("P1_Control", self, "_control_logic")
		2:
			if not P1_bool and not P2_bool:
				ButShow.call_player_in(_ID)
			P2_bool = true
			GameLogic.Con.connect("P2_Control", self, "_control_logic")

func _on_Area2D_body_exited(body: Node) -> void :
	var _ID = body.cur_Player
	match _ID:
		1:
			P1_bool = false
			if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
			if not P1_bool and not P2_bool:
				ButShow.call_player_out(_ID)
		2:
			P2_bool = false
			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
			if not P1_bool and not P2_bool:
				ButShow.call_player_out(_ID)
