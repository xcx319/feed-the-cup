extends Control

var ID
var _NAME: String

func _ready():
	$BG / NinePatchRect.hide()
func call_ReCheck(_BOARDINFO):
	$BG / Control / Rank.text = str(_BOARDINFO.global_rank)
func call_illegal(_SCORE, _ID, _DETAIL):
	$BG / Control / Point.text = str(_SCORE)
	ID = _ID
	_NAME = Steam.getFriendPersonaName(_ID)
	if _NAME == "":
		$Timer.start(0)
	$BG / Control / Name.text = _NAME
	var _LEVEL = _DETAIL[0]
	var _DEVIL = int(_DETAIL[1]) + 1
	var _NUM = _DETAIL[2]
	var _PERFECT = _DETAIL[3]
	var _GOOD = _DETAIL[4]
	var _BAD = _DETAIL[5]
	var _LEVELTYPE = _LEVEL / 10
	var _LEVELID = _LEVEL % 10
	if _NUM < 5:
		$BG / Control / PlayerNum.text = str(_NUM)
	else:
		$BG / Control / PlayerNum.text = str("COOP")
	$BG / Control / Level.text = str(_LEVELTYPE) + " - " + str(_LEVELID)
	$BG / Control / Devil.text = str(_DEVIL)
	$BG / Control / Perfect.text = str(_PERFECT)
	$BG / Control / Good.text = str(_GOOD)
	$BG / Control / Bad.text = str(_BAD)
	$BG / Control / Illegal / AnimationPlayer.play("非法经营")

func call_init(_RANK, _SCORE, _ID, _DETAIL):
	var _OURID = SteamLogic.STEAM_ID
	if int(_ID) == _OURID:

		var _CHECKPOINT = _DETAIL[9]

		if _SCORE > _CHECKPOINT * 10:
			call_illegal(_SCORE, _ID, _DETAIL)
			return

	$BG / Control / Rank.text = str(_RANK)
	$BG / Control / Point.text = str(_SCORE)
	ID = _ID
	if SteamLogic.STEAM_BOOL:
		_NAME = Steam.getFriendPersonaName(_ID)
	if _NAME == "":
		$Timer.start(0)
	$BG / Control / Name.text = _NAME
	var _LEVEL = _DETAIL[0]
	var _DEVIL = int(_DETAIL[1]) + 1
	var _NUM = _DETAIL[2]
	var _PERFECT = _DETAIL[3]
	var _GOOD = _DETAIL[4]
	var _BAD = _DETAIL[5]
	var _LEVELTYPE = _LEVEL / 10
	var _LEVELID = _LEVEL % 10
	match _NUM:
		- 2:
			$BG / Control / PlayerNum.text = str("COOP")
		_:
			$BG / Control / PlayerNum.text = str(_NUM)

	$BG / Control / Level.text = str(_LEVELTYPE) + " - " + str(_LEVELID)
	$BG / Control / Devil.text = str(_DEVIL)
	if _DEVIL <= 0:
		$BG / Control / Devil.text = "SPECIAL"
	$BG / Control / Perfect.text = str(_PERFECT)
	$BG / Control / Good.text = str(_GOOD)
	$BG / Control / Bad.text = str(_BAD)
	match _RANK:
		1:
			$BG / NinePatchRect.self_modulate = Color8(255, 255, 0, 255)
			$BG / NinePatchRect.show()
		2:
			$BG / NinePatchRect.self_modulate = Color8(140, 140, 140, 255)
			$BG / NinePatchRect.show()
		3:
			$BG / NinePatchRect.self_modulate = Color8(255, 160, 0, 255)
			$BG / NinePatchRect.show()
		_:
			$BG / NinePatchRect.hide()
	var _CHECK = _DETAIL.size()

func call_reset():
	$BG / Control / Rank.text = GameLogic.CardTrans.get_message("信息-无")
	$BG / Control / Point.text = str("-")
	if SteamLogic.STEAM_BOOL:
		$BG / Control / Name.text = Steam.getFriendPersonaName(SteamLogic.STEAM_ID)
	$BG / Control / PlayerNum.text = "-"
	$BG / Control / Level.text = GameLogic.CardTrans.get_message("信息-今日无记录")
	$BG / Control / Devil.text = str("-")
	$BG / Control / Perfect.text = str(0)
	$BG / Control / Good.text = str(0)
	$BG / Control / Bad.text = str(0)

func _on_Timer_timeout():
	if _NAME == "":
		_NAME = Steam.getFriendPersonaName(ID)
		$Timer.start(0)
	else:
		$BG / Control / Name.text = _NAME
