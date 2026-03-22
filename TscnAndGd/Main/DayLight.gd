extends Light2D

var Weather
var _Time
var _A: int
var _color: Color

func _ready() -> void :
	GameLogic.GameUI.connect("TimeChange", self, "_DayLight_Set")
	self.show()

func _DayLight_Set():
	_Time = GameLogic.GameUI.CurTime

	if _Time > 9 and _Time < 18:
		_A = 0
	elif _Time > 18:
		_A += 5
	elif _Time > 5 and _Time < 9:
		_A -= 5
	if _A < 0:
		_A = 0
	if _A > 225:
		_A = 225

	self.color.a8 = _A
