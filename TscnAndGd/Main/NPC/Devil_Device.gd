extends Button

onready var Ani = $AnimationPlayer
onready var MoneyLabel = $Node2D / MoneyLabel
onready var MoneyAni = $Node2D / MoneyLabel / AnimationPlayer

var MONEY: int
var ID: String
func call_init(_TYPE):
	if Ani.has_animation(_TYPE):
		Ani.play(_TYPE)
	ID = _TYPE

	if GameLogic.Config.CardConfig.has(ID):
		var _INFO = GameLogic.Config.CardConfig[ID]
		MONEY = int(_INFO.Cost)

		var _MULT: float = 0
		if not GameLogic.SPECIALLEVEL_Int:
			if GameLogic.Save.gameData.HomeDevList.has("茶几"):
				_MULT += 0.05

			if GameLogic.Save.gameData.HomeDevList.has("杂物箱"):
				_MULT += 0.05

			if GameLogic.Save.gameData.HomeDevList.has("浇水工具"):
				_MULT += 0.05

			if GameLogic.Save.gameData.HomeDevList.has("清洁套装"):
				_MULT += 0.05

		if _MULT > 0:
			MONEY = int(float(MONEY) * (1 - _MULT))
		MoneyLabel.text = str(MONEY)

func call_MoneyAni():
	if GameLogic.cur_money < MONEY:
		MoneyAni.play("Disable")
