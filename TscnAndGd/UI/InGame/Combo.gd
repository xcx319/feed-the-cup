extends Control

onready var ComboAni = get_node("ComboAni")
onready var MaxAni = $MaxAni

onready var ComboHBOX = get_node("NinePatchRect/ScrollContainer/HBoxContainer")
onready var ComboSetAni = get_node("ComboSetAni")
var COMBO_bit
var COMBO_ten
var COMBO_hun
var _ComboNum: int

func _ready() -> void :
	_combo_init()

func call_init():
	ComboAni.play("init")

func _combo_init():
	COMBO_bit = ComboHBOX.get_node("1")

	COMBO_ten = ComboHBOX.get_node("10")

	COMBO_hun = ComboHBOX.get_node("100")

	COMBO_hun.hide()
	COMBO_ten.hide()

func call_DayStart():
	_ComboNum = 0
	if GameLogic.cur_Combo > 0:
		GameLogic.cur_Combo = 0
	ComboAni.play("init")

func call_combo(_num):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _ComboNum == _num:
		return
	_ComboNum = _num
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_Combo_Logic", [_num])
	_Combo_Logic(_num)
func _Combo_Logic(_num):
	var _MAX: int = 99
	if GameLogic.cur_Rewards.has("取票器"):
		_MAX += 50
	elif GameLogic.cur_Rewards.has("取票器+"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("连击达人"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("飞来横财"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("准时达"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("极限手段"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("冰点连击"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("爆炸灯笼"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("跳跃连击"):
		_MAX += 100
	if GameLogic.cur_Rewards.has("高压不断连"):
		_MAX += 100
	if _num >= _MAX:
		if MaxAni.assigned_animation != "Max":
			MaxAni.play("Max")
	else:
		MaxAni.play("init")

	if _num < 2:
		if ComboAni.assigned_animation == "combo" or ComboAni.assigned_animation == "show":
			ComboAni.play("break")
	else:
		if ComboAni.assigned_animation == "init" or ComboAni.assigned_animation == "break":
			ComboAni.play("show")
		else:
			ComboAni.play("combo")

	if _num < 10:
		ComboSetAni.play("1")
		COMBO_bit.call_Combo(_num)
	elif _num < 100:
		ComboSetAni.play("10")
		var _ten = int(_num / 10)
		var _bit = _num - (_ten * 10)
		COMBO_bit.call_Combo(_bit)
		COMBO_ten.call_Combo(_ten)
	else:
		ComboSetAni.play("100")
		if _num > 999:
			_num = 999
		var _hun = int(_num / 100)
		var _tenNum = _num - (_hun * 100)
		var _ten = int(_tenNum / 10)
		var _bit = _tenNum - (_ten * 10)
		COMBO_bit.call_Combo(_bit)
		COMBO_ten.call_Combo(_ten)
		COMBO_hun.call_Combo(_hun)
