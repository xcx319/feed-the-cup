extends Control

var cur_used: bool
export var ICONNUM: int = 4726
export var CUPNUM: int = 123
var MaxICON: int = 5000
var MaxCUP: int = 100
var CUP_PER: float
var ICON_PER: float
var CUR_CUP: int
var CUR_ICON: int
var ICON_CAL: int
var MinPos: Vector2 = Vector2(0, - 1000)
var MaxPos: Vector2 = Vector2(1000, - 1000)

onready var COIN_TSCN = preload("res://TscnAndGd/Effects/Rigid_Coin.tscn")
onready var LittleCup_TSCN = preload("res://TscnAndGd/Effects/Rigid_LittleCup.tscn")
onready var DropNode = $DropNode
onready var COIN_HBOX = $INFOShow / BG / CoinAccount / Scroll / HBOX
onready var CUP_HBOX = $INFOShow / BG / GuestAccount / CUPScroll / HBOX
var _Count: float = 0
var _AUDIO
signal Finished()
func call_finished():
	emit_signal("Finished")

func call_show():
	call_init()
	_COIN_SHOW()
	_CUP_SHOW()
	if get_tree().paused:
		get_tree().paused = false
	GameLogic.Can_ESC = false
	cur_used = true
func call_init():
	if ICONNUM >= 10000000:
		ICONNUM = 9999999
	if CUPNUM == 0:
		CUP_PER = 0
	else:
		CUP_PER = 100 / float(CUPNUM)
	if ICONNUM == 0:
		ICON_PER = 0
	else:
		ICON_PER = 100 / float(ICONNUM)
	_AUDIO = GameLogic.Audio.return_Effect("硬币一个清脆")

var _QUICK_BOOL: bool
var _QUICK_CHECK: bool
func call_create_quick():
	if _QUICK_BOOL:
		create_coin()
		create_coin()
		create_coin()
		create_coin()
		if not _QUICK_CHECK:
			_QUICK_CHECK = true
			call_NumSpeed()
	else:
		if _QUICK_CHECK:
			_QUICK_CHECK = false
			call_NumSpeed()
func call_NumSpeed():
	for _NODE in COIN_HBOX.get_children():
		_NODE.call_Speed_Switch(_QUICK_BOOL)
func _process(_delta):
	if not cur_used:
		return
	_Count += _delta
	if _Count > 0.01:
		_Count = 0
		create_coin()
		call_create_quick()

func _AUDIO_Logic():

	var _RAND = GameLogic.return_RANDOM() % 10 + 1
	$Audio.get_node(str(_RAND)).play(0)
func create_coin():

	if MaxICON == 0:

		set_process(false)
		return

	_AUDIO_Logic()
	if CUR_ICON < 100:
		CUR_ICON += 1
	elif CUR_ICON < 500:
		CUR_ICON += 5
	elif CUR_ICON < 1000:
		CUR_ICON += 10
	else:
		CUR_ICON += 10

	if CUR_CUP < 10:

		ICON_CAL += 1
	elif CUR_CUP < 50:

		ICON_CAL += 5
	elif CUR_CUP < 100:

		ICON_CAL += 10
	else:

		ICON_CAL += 100

	if CUR_ICON <= ICONNUM and CUR_ICON < MaxICON:
		_COIN_CREATE()

	if ICON_CAL * ICON_PER >= CUP_PER:
		ICON_CAL = 0
		if CUR_CUP < 10:
			CUR_CUP += 1
		elif CUR_CUP < 50:
			CUR_CUP += 2
		elif CUR_CUP < 100:
			CUR_CUP += 3
		else:
			CUR_CUP += 4

		if CUR_CUP <= CUPNUM and CUR_CUP <= MaxCUP:
			_CUP_CREATE()
	if CUR_ICON > ICONNUM or CUR_ICON > MaxICON:
		if CUR_CUP < 10:
			CUR_CUP += 1
		elif CUR_CUP < 50:
			CUR_CUP += 2
		elif CUR_CUP < 100:
			CUR_CUP += 3
		else:
			CUR_CUP += 4
		if CUR_CUP <= CUPNUM and CUR_CUP <= MaxCUP:
			_CUP_CREATE()
		elif CUR_CUP > CUPNUM or CUR_CUP > MaxCUP:
			set_process(false)

			if ICONNUM > 0:
				yield(get_tree().create_timer(3), "timeout")
				$DevilHandAni.play("play")
			else:
				call_start()
				$DevilHandAni.play("NoCoin")

func _COIN_CREATE():
	var _Coin = COIN_TSCN.instance()
	_Coin.position = Vector2((GameLogic.return_RANDOM() % 1000), - 1000 - GameLogic.return_RANDOM() % 500)
	DropNode.add_child(_Coin)
func _CUP_CREATE():
	var _CUP = LittleCup_TSCN.instance()
	_CUP.position = Vector2((0 + GameLogic.return_RANDOM() % 1920), - 1000 - GameLogic.return_RANDOM() % 500)
	DropNode.add_child(_CUP)

func _COIN_SHOW():

	var _ThouThou = COIN_HBOX.get_node("1000000")
	var _HunThou = COIN_HBOX.get_node("100000")
	var _TenThou = COIN_HBOX.get_node("10000")
	var _Thou = COIN_HBOX.get_node("1000")
	var _Hun = COIN_HBOX.get_node("100")
	var _Ten = COIN_HBOX.get_node("10")
	var _Bit = COIN_HBOX.get_node("1")
	_Bit.connect("decimal", _Ten, "call_play")
	_Ten.connect("decimal", _Hun, "call_play")
	_Hun.connect("decimal", _Thou, "call_play")
	_Thou.connect("decimal", _TenThou, "call_play")
	_TenThou.connect("decimal", _HunThou, "call_play")
	_HunThou.connect("decimal", _ThouThou, "call_play")
	_Ten.connect("finish", _Bit, "call_EndUI")
	_Hun.connect("finish", _Ten, "call_EndUI")
	_Thou.connect("finish", _Hun, "call_EndUI")
	_TenThou.connect("finish", _Thou, "call_EndUI")
	_HunThou.connect("finish", _TenThou, "call_EndUI")
	_ThouThou.connect("finish", _HunThou, "call_EndUI")
	_ThouThou.call_show_10(ICONNUM)
	_HunThou.call_show_10(ICONNUM)
	_TenThou.call_show_10(ICONNUM)
	_Thou.call_show_10(ICONNUM)
	_Hun.call_show_10(ICONNUM)
	_Ten.call_show_10(ICONNUM)
	_Bit.call_show_10(ICONNUM)

func _CUP_SHOW():
	var _CUPHun = CUP_HBOX.get_node("100")
	var _CUPTen = CUP_HBOX.get_node("10")
	var _CUPBit = CUP_HBOX.get_node("1")

	_CUPBit.connect("decimal", _CUPTen, "call_play")
	_CUPTen.connect("decimal", _CUPHun, "call_play")

	_CUPTen.connect("finish", _CUPBit, "call_EndUI")
	_CUPHun.connect("finish", _CUPTen, "call_EndUI")

	_CUPHun.call_show_10(CUPNUM)
	_CUPTen.call_show_10(CUPNUM)
	_CUPBit.call_show_10(CUPNUM)

func call_start():
	COIN_HBOX.get_node("1").visible = true
	COIN_HBOX.get_node("1").call_play()
	CUP_HBOX.get_node("1").visible = true
	CUP_HBOX.get_node("1").call_play()

func _on_body_entered(_body):
	if _body.name == "CoinCan":
		return
	_body.queue_free()
