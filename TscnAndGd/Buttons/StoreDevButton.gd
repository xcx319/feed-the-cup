extends Button

var All_buy_bool: bool
var _pressed: bool
export var ButType: int
var _click_Audio
var cur_Dev: String
var Num: int
var cur_Pressed: bool
var _ObjList: Array
var _LastObj

var IsOverlap: bool

var ObjName: String

onready var NameLabel = get_node("NameLabel")
onready var InfoLabel = get_node("InfoLabel")
onready var MoneyLabel = get_node("CountSell/MoneyLabel")
onready var MoneyNode = get_node("CountSell")

onready var _HoldBut = get_node("A")
onready var _AllBuyLabel = get_node("AllBuyLabel")
onready var _NoBuyLabel = get_node("NoBuyLabel")
onready var _Slider = get_node("HSlider")

func _ready() -> void :
	_AllBuyLabel.hide()
	_NoBuyLabel.hide()
	call_deferred("_audio_set")
	set_process(false)
func _audio_set():

	match ButType:
		GameLogic.Audio.BUTTYPE.APPLY:
			_click_Audio = GameLogic.Audio.But_Apply
		GameLogic.Audio.BUTTYPE.BACK:
			_click_Audio = GameLogic.Audio.But_Back
		GameLogic.Audio.BUTTYPE.SWITCHON:
			_click_Audio = GameLogic.Audio.But_SwitchOn
		GameLogic.Audio.BUTTYPE.SWITCHOFF:
			_click_Audio = GameLogic.Audio.But_SwitchOff
		GameLogic.Audio.BUTTYPE.EASYCLICK:
			_click_Audio = GameLogic.Audio.But_EasyClick
		GameLogic.Audio.BUTTYPE.CLICK:
			_click_Audio = GameLogic.Audio.But_Click
func call_button_down():
	if _HoldBut.visible:

		_pressed = true
		on_pressed()
		_HoldBut.call_holding(true)
func call_button_up():
	if _HoldBut.visible:
		_pressed = false
		_HoldBut.call_holding(false)
func on_pressed():
	_click_Audio.play(0)

func call_init():


	_ObjList.clear()
	for i in GameLogic.cur_Level_Update.size():
		var _Obj = GameLogic.cur_Level_Update[i]
		if _Obj.SelfDev == cur_Dev:
			_ObjList.append(_Obj)
			Num = Num + 1
	call_HSlider_init()
	if not All_buy_bool:
		_HoldBut.call_show()
	else:
		MoneyNode.hide()
	call_pressed_set()

func call_HSlider_init():
	_Slider.max_value = Num
	_Slider.tick_count = Num
	var _Info = GameLogic.Config.DeviceConfig[cur_Dev]
	NameLabel.text = _Info.ShowNameID
	InfoLabel.text = _Info.ShowInfoID
	MoneyLabel.text = _Info.Sell
	if GameLogic.cur_Update.size():
		for i in GameLogic.cur_Update.size():
			var _BuyName = GameLogic.cur_Update[i]
			for y in GameLogic.cur_Level_Update.size():
				var _Obj = GameLogic.cur_Level_Update[y]
				if _Obj.SelfDev == cur_Dev:
					if _BuyName == _Obj.name:
						if _Slider.value < _Slider.max_value:
							_Slider.value += 1
						else:
							All_buy_bool = true
							_AllBuyLabel.show()
							MoneyNode.hide()
						break

func call_pressed_set():


	if self.pressed and not All_buy_bool and not IsOverlap:
		_HoldBut.show()
	else:
		_HoldBut.hide()
	if IsOverlap:
		_NoBuyLabel.show()
	else:
		_NoBuyLabel.hide()
