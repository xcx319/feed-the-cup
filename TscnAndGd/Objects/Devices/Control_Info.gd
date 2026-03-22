extends Node2D

export var Info_1: String
export var Info_2: String
export var Info_3: String
export var Info_4: String
onready var selfNode = get_parent()
onready var ButInfoAni = get_node("TexNode/ButInfoAni")
onready var AButAni = get_node("TexNode/AButAni")
onready var XButAni = get_node("TexNode/XButAni")
onready var But1 = get_node("TexNode/Button1")
onready var But2 = get_node("TexNode/Button2")
onready var But3 = get_node("TexNode/Button3")
onready var But4 = get_node("TexNode/Button4")
func _ready() -> void :
	pass

func ButChoose_Switch(_butID, A_bool, B_bool, X_bool, Y_Bool):
	But1.visible = A_bool
	But2.visible = B_bool
	But3.visible = X_bool
	But4.visible = Y_Bool

	if _butID == - 1:
		ButInfo_Switch(_butID, "All")

func ButInfo_Switch(_butID, _but):

	if not selfNode.Holding:
		if _butID == - 1:
			call_but_switch(true)

			selfNode.cur_ButInfo = _but
		elif _butID == - 2:
			call_but_switch(false)
		else:
			if selfNode.cur_ButInfo == null:

				call_but_init()
			else:

				call_but_switch(false)
				selfNode.cur_ButInfo = null

	else:
		call_but_switch(false)
		selfNode.cur_ButInfo = null

func call_but_switch(_switch):

	if _switch:
		ButInfoAni.play("show")
	else:
		if ButInfoAni.assigned_animation == "show":
			ButInfoAni.play("hide")

		else:
			ButInfoAni.play("init")

func call_but_show():
	ButInfoAni.play("show")
func call_but_hide():
	ButInfoAni.play("hide")
func call_but_init():
	ButInfoAni.play("init")

func call_show_X_Hold():
	XButAni.play("X_Hold")
