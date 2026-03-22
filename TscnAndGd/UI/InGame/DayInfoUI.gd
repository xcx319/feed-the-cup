extends Control

var cur_pressed: bool

var cur_TYPE: String
var cur_UI
var SteamCheck: bool
onready var CardUI_TSCN = preload("res://TscnAndGd/UI/InGame/CardUI.tscn")
onready var ANI = get_node("Ani")
func _ready() -> void :
	call_deferred("call_init")
func call_connect_switch(_Switch: bool):
	match _Switch:
		true:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				for _MEMBER in SteamLogic.LOBBY_MEMBERS:
					if _MEMBER.steam_id == SteamLogic.STEAM_ID:

						_MEMBER.Check = true

			if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				var _checkP2 = GameLogic.Con.connect("P2_Control", self, "_control_logic")
		false:
			if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				var _checkP1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				var _checkP2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
func _control_logic(_but, _value, _type):

	SteamCheck = true
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

		if not SteamCheck:
			for _MEMBER in SteamLogic.LOBBY_MEMBERS:
				if not _MEMBER.Check:


					return
			SteamCheck = true

	if _value != 1 and _value != - 1:
		cur_pressed = false

	if _value == 1 or _value == - 1:

		match _but:
			"A":

				if not cur_pressed:
					cur_pressed = true


					_ApplyLogic()
func call_Steam_ApplyLogic(_Type):
	cur_TYPE = _Type

	GameLogic.Audio.But_Apply.play(0)
	if SteamLogic.LOBBY_levelData.has("cur_Menu"):
		GameLogic.cur_Menu = SteamLogic.LOBBY_levelData.cur_Menu

	_on_Apply_pressed()
func _ApplyLogic():

	GameLogic.Audio.But_Apply.play(0)
	_on_Apply_pressed()

func call_init():

	if not GameLogic.SPECIALLEVEL_Int:
		GameLogic.cur_Event = ""
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(1)
	if is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(1)
	if has_node("DayControl"):
		get_node("DayControl").call_init()
	ANI.play("auto")
	GameLogic.Can_ESC = false
	GameLogic.GameUI.call_UI_init()
	GameLogic.GameUI.DayEndUI.call_init()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_Master_Switch(true)
	SteamLogic.call_SetRich()
func _on_Apply_pressed() -> void :

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		cur_TYPE = get_node("DayControl").cur_TYPE
		if cur_TYPE in ["随机"]:
			var _LIST = ["无", "配方", "事件"]
			var _RAND = GameLogic.return_randi() % _LIST.size()
			var _CHECK = _LIST[_RAND]
			cur_TYPE = _CHECK

	GameLogic.GameUI.DayEndUI.call_init()

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Steam_ApplyLogic", [cur_TYPE])
	match cur_TYPE:
		"无":
			var LevelNode = get_tree().get_root().get_node("Level")
			if LevelNode.has_method("_LEVELSTAT_LOGIC"):
				LevelNode._LEVELSTAT_LOGIC(2)
			self.queue_free()
		"配方":
			if GameLogic.cur_Day > 1:
				GameLogic.cur_MenuNum += 1
				var _LEVELINFO = GameLogic.cur_levelInfo
				var _Max = int(_LEVELINFO.MenuMax)
				if GameLogic.cur_MenuNum > _Max:
					GameLogic.cur_MenuNum = _Max
			call_Menu_Init()
		"事件1", "事件2", "事件3", "事件", "升级", "升级1", "升级2", "升级3":
			call_Scroll_Init()
		"小料":
			if GameLogic.cur_Day > 1:
				GameLogic.cur_ExtraNum += 1
			call_Menu_Init()

		"地铁":
			call_RewardUI_Init()
			pass
		_:
			if cur_TYPE == "":
				cur_TYPE = "事件"
			call_Scroll_Init()

func call_RewardUI_Init():
	ANI.play("hide")

	GameLogic.cur_Gift = 20
	if SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		GameLogic.cur_Gift = 1
	GameLogic.GameUI.get_node("RewardUI")._CheckLogic()
	SteamLogic.call_send_LevelInfo()

func call_Menu_Init():
	if is_instance_valid(cur_UI):
		cur_UI.call_init()
		ANI.play("hide")
		call_connect_switch(false)
		return
	cur_UI = null
	var _TSCN = load("res://TscnAndGd/UI/InGame/MenuUI.tscn")
	cur_UI = _TSCN.instance()
	get_parent().add_child(cur_UI)
	cur_UI.call_init()
	ANI.play("hide")
	call_connect_switch(false)
func call_UI_show():

	if cur_UI:
		if is_instance_valid(cur_UI):
			cur_UI.call_show()
	cur_UI = null
	self.queue_free()
func call_Scroll_Init():
	if get_parent().has_node("CardUI"):

		return

	cur_UI = CardUI_TSCN.instance()
	cur_UI.name = "CardUI"
	get_parent().add_child(cur_UI)

	ANI.play("hide")
