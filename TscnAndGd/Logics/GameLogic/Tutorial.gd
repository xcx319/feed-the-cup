extends Node

var Tutorial_Bool: bool = true
var NeedSell: bool
var CheckList: Array
var LEVEL2_CHECK: bool
var NEWDIFFICULT: bool
var Skip_OPENCG: bool
signal DropTrashbag(_Switch)
signal DropInTrashbin(_Switch)
signal Closed()
signal AddSugar()
signal AddIn()

func call_AddIn():
	emit_signal("AddIn")

func call_AddSugar():
	emit_signal("AddSugar")

func call_Check_Level2():
	if GameLogic.Level_Data.size() == 1:
		if not LEVEL2_CHECK:
			GameLogic.GameUI.Tutorial_Devil.call_TutorialFinished()
	elif GameLogic.Level_Data.size() == 2:
		if not NEWDIFFICULT:
			if GameLogic.Level_Data["社区店1"].cur_Devil == 0:
				GameLogic.GameUI.Tutorial_Devil.call_NewDifficult()
func call_Drop_end():
	emit_signal("DropTrashbag", false)
	emit_signal("DropInTrashbin", false)

func call_DrapTrashbag(_Switch):

	match _Switch:
		true:
			if Tutorial_Bool:
				emit_signal("DropTrashbag", _Switch)

		false:
			emit_signal("DropTrashbag", _Switch)
func call_DropInTrashbin(_Switch):
	match _Switch:
		true:
			if Tutorial_Bool:
				emit_signal("DropInTrashbin", _Switch)
		false:
			emit_signal("DropInTrashbin", _Switch)
func call_closed():
	if Tutorial_Bool:
		emit_signal("Closed")

func call_Tutorial_Check():

	pass
