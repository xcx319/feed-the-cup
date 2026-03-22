extends Control

func call_type(_Type: int):
	get_node("TypeAni").play(str(_Type))

func call_Str(_Str: String):
	get_node("Label").call_Tr_TEXT(_Str)

func call_icon():
	get_node("NinePatchRect").hide()
	get_node("Label").hide()
