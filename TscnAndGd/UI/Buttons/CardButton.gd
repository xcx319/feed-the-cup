extends Button

onready var CardInfoLabel = get_node("BG/ScrollContainer/Control/InfoNode/Info")
onready var ChallengeInfoLabel = get_node("BG/ScrollContainer/Control/InfoNode/ChallengeInfo")
onready var ChallengeLabel = get_node("BG/ScrollContainer/Control/InfoNode/ChallengeLabel")
onready var CardNameLabel = get_node("BG/ScrollContainer/Control/InfoNode/Name")

onready var NameAni = get_node("Main/AniNode/NameAni")
onready var EvilAni = get_node("Main/AniNode/EvilAni")
onready var BGAni = get_node("Main/AniNode/BGAni")
onready var TypeAni = get_node("Main/AniNode/TypeAni")
onready var ColorAni = get_node("Main/AniNode/ColorAni")

var Card_ID: String setget _card_init
var Challenge_ID: String

var CardName: String
var CardInfo: String
var CardRank: int
var CardType: String
var ChallengeInfo: String

func _ready() -> void :
	set_process(false)

func call_grabfocus():

	self.grab_focus()
func call_select():
	GameLogic.Audio.But_EasyClick.play(0)
	TypeAni.play("select")

func call_normal():
	TypeAni.play("normal")

func call_show_select():
	TypeAni.play("normal")
	BGAni.play("init")
	BGAni.play("show_select")
func call_show():
	TypeAni.play("normal")
	BGAni.play("init")
	BGAni.play("show")

func call_hide():
	TypeAni.play("init")
	BGAni.play("init")
	call_set_process(false)

func call_choose(_bool: bool):
	match _bool:
		true:
			BGAni.play("choose")
			if self.has_focus():
				self.release_focus()
			Challenge_ID = ""
		false:
			call_set_process(false)

			if self.has_focus():
				self.release_focus()
			BGAni.play("burn")
			Challenge_ID = ""
func call_set_process(_switch: bool):
	match _switch:
		true:
			focus_mode = Control.FOCUS_ALL
		false:
			focus_mode = Control.FOCUS_NONE
	set_process(_switch)

func _card_init(_CardID: String):
	Card_ID = _CardID
	var _CardInfo = GameLogic.Config.CardConfig[Card_ID]
	CardName = GameLogic.CardTrans.get_message(_CardInfo.ShowNameID)

	CardInfo = GameLogic.CardTrans.get_message(_CardInfo.ShowInfoID)

	CardRank = int(_CardInfo.Rank)
	if CardRank in [1, 2, 3]:
		ColorAni.play(str(CardRank))

	CardType = _CardInfo.MainType
	EvilAni.play(CardType)
	CardNameLabel.text = CardName
	var _UpdateCheck = _CardInfo.UnlockType
	if _UpdateCheck == "升级":
		NameAni.play("+")
	else:
		NameAni.play("init")
	_Info_set()
	_ChallengeInfo_set()
func _Info_set():

	var _Info_1 = GameLogic.Info.return_ColorInfo(CardInfo)
	var _Info = "[center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center]"

	CardInfoLabel.bbcode_text = _Info
func _ChallengeInfo_set():
	if not Challenge_ID:

		if GameLogic.Config.CardConfig[Card_ID].UnlockType == "升级":
			var _BaseCard = str(GameLogic.Config.CardConfig[Card_ID].UnlockValue)
			if GameLogic.cur_Rewards.has(_BaseCard):
				Challenge_ID = GameLogic.cur_Rewards[_BaseCard]

		else:
			match Card_ID:
				GameLogic.Card_1:
					Challenge_ID = GameLogic.Challenge_1
				GameLogic.Card_2:
					Challenge_ID = GameLogic.Challenge_2
				GameLogic.Card_3:
					Challenge_ID = GameLogic.Challenge_3

	var _ChallengeInfo = GameLogic.CardTrans.get_message(GameLogic.Config.ChallengeConfig[Challenge_ID].ShowInfoID)
	var _Info_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo)

	var _Info = "[center][shake rate=5 level=8]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/shake][/center]"

	ChallengeInfoLabel.bbcode_text = _Info
	var _ChallName = GameLogic.CardTrans.get_message(GameLogic.Config.ChallengeConfig[Challenge_ID].ShowNameID)
	var _Name = "[center][shake rate=5 level=8]" + tr("Cost") + ":" + _ChallName + "[/shake]" + "[/center]"
	ChallengeLabel.bbcode_text = _Name

func _on_mouse_entered() -> void :

	if focus_mode == Control.FOCUS_ALL:
		call_grabfocus()

func _on_focus_exited() -> void :
	call_normal()

func _on_focus_entered() -> void :
	call_select()
