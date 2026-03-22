extends Button

onready var ChallengeInfoLabel = get_node("BG/ScrollContainer/Control/InfoNode/Info")
onready var ChallengeLabel = get_node("BG/ScrollContainer/Control/InfoNode/ChallengeLabel")

onready var NameAni = get_node("Main/AniNode/NameAni")
onready var EvilAni = get_node("Main/AniNode/EvilAni")
onready var BGAni = get_node("Main/AniNode/BGAni")
onready var TypeAni = get_node("Main/AniNode/TypeAni")
onready var ColorAni = get_node("Main/AniNode/ColorAni")

var Card_ID: String setget _card_init
var TYPE: int setget _Challenge_init
var Event_ID: String
var Challenge_ID: String
var Reward_Str: String
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
func call_set():
	_Info_set()

func call_show_select():
	TypeAni.play("normal")
	BGAni.play("init")
	BGAni.play("show_select")
func call_show():
	TypeAni.play("normal")
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
func _Challenge_init(_type: int):
	TYPE = _type

	match TYPE:
		1:
			Challenge_ID = GameLogic.Challenge_1
			if GameLogic.Challenge_1 == "":
				self.hide()
			else:
				self.show()
		2:
			Challenge_ID = GameLogic.Challenge_2
			if GameLogic.Challenge_2 == "":
				self.hide()
			else:
				self.show()
		3:
			Challenge_ID = GameLogic.Challenge_3
			if GameLogic.Challenge_3 == "":
				self.hide()
			else:
				self.show()

	if Challenge_ID != "":
		if GameLogic.Config.EventConfig.has(Challenge_ID):
			var _CardInfo = GameLogic.Config.EventConfig[Challenge_ID]
			var _Rank = _CardInfo.Rank
			var _TYPE = _CardInfo.Type

			if EvilAni.has_animation(_TYPE):
				EvilAni.play(_TYPE)
			ColorAni.play(str(_Rank))

	_Info_set()

func _card_init(_CardID: String):
	Challenge_ID = _CardID

	if GameLogic.Config.EventConfig.has(Challenge_ID):
		var _CardInfo = GameLogic.Config.EventConfig[Challenge_ID]
		var _Rank = _CardInfo.Rank
		var _TYPE = _CardInfo.Type

		if EvilAni.has_animation(_TYPE):
			EvilAni.play(_TYPE)
		ColorAni.play(str(_Rank))
	_Info_set()

func _Info_set():
	if Challenge_ID == "":
		return
	var _TITLE = GameLogic.CardTrans.get_message("信息-代价")
	get_node("BG/ScrollContainer/Control/InfoNode/Challenge").bbcode_text = "[center][shake rate=5 level=8][b]" + _TITLE + "[/b][/shake]"
	if GameLogic.Config.EventConfig.has(Challenge_ID):
		var _ChallengeInfo = GameLogic.CardTrans.get_message(GameLogic.Config.EventConfig[Challenge_ID].ShowInfoID)

		var _Info_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo)
		var _Info = "[shake rate=0 level=0][center]" + _Info_1.format(GameLogic.Info.Info_Name)

		ChallengeInfoLabel.bbcode_text = _Info
		var _ChallName = GameLogic.CardTrans.get_message(GameLogic.Config.EventConfig[Challenge_ID].ShowNameID)
		var _Name = "[shake rate=0 level=0][center]" + _ChallName.format(GameLogic.Info.Info_Name)

		ChallengeLabel.bbcode_text = _Name
	elif GameLogic.Config.CardConfig.has(Challenge_ID):
		var _ChallengeInfo = GameLogic.CardTrans.get_message(GameLogic.Config.CardConfig[Challenge_ID].ShowInfoID)

		var _Info_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo)
		var _Info = "[shake rate=5 level=8][center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center][/shake]"
		ChallengeInfoLabel.bbcode_text = _Info
		var _ChallName = GameLogic.CardTrans.get_message(GameLogic.Config.CardConfig[Challenge_ID].ShowNameID)
		var _Name = "[shake rate=5 level=8][center]" + tr("Cost") + ":" + _ChallName.format(GameLogic.Info.Info_Name) + "[/center][/shake]"
		ChallengeLabel.bbcode_text = _Name
	elif GameLogic.Config.ChallengeConfig.has(Challenge_ID):
		var _ChallengeInfo = GameLogic.CardTrans.get_message(GameLogic.Config.ChallengeConfig[Challenge_ID].ShowInfoID)

		var _Info_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo)
		var _Info = "[shake rate=5 level=8][center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center][/shake]"
		ChallengeInfoLabel.bbcode_text = _Info
		var _ChallName = GameLogic.CardTrans.get_message(GameLogic.Config.ChallengeConfig[Challenge_ID].ShowNameID)
		var _Name = "[shake rate=5 level=8][center]" + tr("Cost") + ":" + _ChallName.format(GameLogic.Info.Info_Name) + "[/center][/shake]"
		ChallengeLabel.bbcode_text = _Name

func _on_mouse_entered() -> void :
	if focus_mode == Control.FOCUS_ALL:
		call_grabfocus()

func _on_focus_exited() -> void :
	call_normal()

func _on_focus_entered() -> void :
	if get_parent().get_parent().has_node("CurChoose"):
		get_parent().get_parent().get_node("CurChoose").call_ShowInfo_Hide()
		call_select()

onready var NetChooseTSCN = preload("res://TscnAndGd/Effects/NetChoose.tscn")

func call_NetChoose(_PLAYER: int):
	var _ChooseTSCN = NetChooseTSCN.instance()
	var _randx = GameLogic.return_RANDOM() % 100 - 50
	var _randy = GameLogic.return_RANDOM() % 60 - 30
	var _POS: Vector2 = Vector2(_randx, _randy)
	var _NUM = $Net.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	_ChooseTSCN.position = _POS
	$Net.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)

	if SteamLogic.IsMultiplay:
		SteamLogic.call_puppet_node_sync(self, "call_NetChoose_puppet", [_PLAYER, _POS])
func call_NetChoose_puppet(_PLAYER, _POS):
	var _ChooseTSCN = NetChooseTSCN.instance()
	_ChooseTSCN.position = _POS
	var _NUM = $Net.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	$Net.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)
