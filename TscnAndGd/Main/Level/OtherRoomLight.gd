extends Node2D

var CloseLight_Bool: bool
var Rand: float

func _ready() -> void :
	var _check = GameLogic.GameUI.connect("TimeChange", self, "_CloseLight_Logic")
	Rand = float(GameLogic.return_RANDOM() % 5 + 1) / 10

func _CloseLight_Logic():
	if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime + Rand:
		if not CloseLight_Bool:
			CloseLight_Bool = true
			self.visible = false
			if GameLogic.GameUI.is_connected("TimeChange", self, "_CloseLight_Logic"):
				GameLogic.GameUI.disconnect("TimeChange", self, "_CloseLight_Logic")
