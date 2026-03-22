extends Button

export (int) var buyMax = 10
var cur_type: String
var cur_num: int
var cur_sell: int setget sell_set
var cur_sellCount: int
onready var NumAni = get_node("NumNode/NumAni")
onready var NumShow = get_node("NumNode/NumLabel")
onready var SellLabel = get_node("SellNode/SellLabel")
onready var GameUI = get_parent().get_parent().get_parent().get_parent().get_parent()

onready var Left = get_node("NumNode/L")
onready var Right = get_node("NumNode/R")
onready var X = get_node("NumNode/X")
onready var Y = get_node("NumNode/Y")





func _Num_Show_Switch(_switch):
	match _switch:
		true:
			NumAni.play("show")
		false:
			NumAni.play("hide")
	pass

func _on_self_toggled(button_pressed: bool) -> void :
	_Num_Show_Switch(button_pressed)

func sell_set(_value):
	cur_sell = int(_value)
	SellLabel.text = str(cur_sell)

func number_show():
	NumShow.text = "X" + str(cur_num)
	pass

func cur_num_set():
	if cur_num > buyMax:
		cur_num = buyMax
	elif cur_num < 0:
		cur_num = 0
	number_show()
	GameUI.Order_SellCount -= cur_sellCount
	cur_sellCount = cur_num * cur_sell

	GameUI.Order_SellCount += cur_sellCount
	GameUI.sellCount_ShowLogic()

func _on_MultPlus_pressed() -> void :
	cur_num += 5
	cur_num_set()
func _on_Plus_pressed() -> void :
	cur_num += 1
	cur_num_set()
func _on_Reduce_pressed() -> void :
	cur_num -= 1
	cur_num_set()
func _on_MultReduce_pressed() -> void :
	cur_num -= 5
	cur_num_set()
