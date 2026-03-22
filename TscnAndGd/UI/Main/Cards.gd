extends Control

onready var CardBut = preload("res://TscnAndGd/UI/Buttons/CardButton.tscn")

var cur_use: bool
func call_ShowInfo_Hide():
	get_node("CurChoose").call_ShowInfo_Hide()
func call_GrabFocus():

	if get_node("CurChoose/Reward/Grid").get_child_count():
		get_node("CurChoose/Reward/Grid").get_child(0).grab_focus()
	elif get_node("CurChoose/Challenge/Grid").get_child_count():
		get_node("CurChoose/Challenge/Grid").get_child(0).grab_focus()
func call_release_focus():

	for _But in get_node("CurChoose/Reward/Grid").get_children():
		if _But.is_pressed():
			_But.set_pressed(false)

			return
	for _But in get_node("CurChoose/Challenge/Grid").get_children():
		if _But.is_pressed():
			_But.set_pressed(false)
			return
func call_down():

	if not get_focus_owner():
		return
	var _CurType = get_focus_owner().get_parent().get_parent().name
	if _CurType == "Reward":
		if get_node("CurChoose/Challenge/Grid").get_child_count():
			get_node("CurChoose/Challenge/Grid").get_child(0).grab_focus()
			return true
	return false
func call_up():
	if not is_instance_valid(get_focus_owner()):
		return
	var _CurType = get_focus_owner().get_parent().get_parent().name
	if _CurType == "Challenge":
		if get_node("CurChoose/Reward/Grid").get_child_count():
			get_node("CurChoose/Reward/Grid").get_child(0).grab_focus()

			return true
	return false
func call_init():
	if has_node("DayControl"):
		get_node("DayControl").call_init()

	get_node("CurChoose").call_init()

	if GameLogic.cur_Event:
		get_node("1").Card_ID = GameLogic.cur_Event
		get_node("1").call_show()
		get_node("1").show()
	else:
		get_node("1").hide()

func _on_Back_pressed() -> void :
	get_parent().call_CardOff()
