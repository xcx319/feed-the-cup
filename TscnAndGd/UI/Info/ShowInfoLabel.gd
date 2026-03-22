extends Control

onready var Ani = get_node("Ani")
onready var TypeAni = get_node("TypeAni")
onready var InfoLabel = get_node("Control/RichTextLabel")
func _ready() -> void :
	pass

func call_net(_Type: String, _Info: String, _SteamID: int):
	TypeAni.play(str(_Type))
	match _Type:
		"3":
			var _INFOTEXT = GameLogic.CardTrans.get_message(_Info)
			var _NAME = ""
			if _SteamID != 0:
				_NAME = Steam.getFriendPersonaName(_SteamID)
			InfoLabel.bbcode_text = "[shake rate=0 level=0][center]" + _NAME + " " + _INFOTEXT + "[/center][/shake]"
func call_init(_Type: String, _Info: String, _NUM: String = "", _MaxBool: bool = false):
	TypeAni.play(str(_Type))
	var _LABELTEXT = GameLogic.CardTrans.get_message("Count") + " : " + str(_NUM)
	if _MaxBool:
		_LABELTEXT += " Max"
	if _NUM != "":
		$Control / Label.text = _LABELTEXT

	match _Type:
		"1":
			if GameLogic.Config.CardConfig.has(_Info):
				var _Name = GameLogic.CardTrans.get_message(GameLogic.Config.CardConfig[_Info].ShowNameID)
				InfoLabel.bbcode_text = "[shake rate=0 level=0][center]" + _Name + "[/center][/shake]"

			elif GameLogic.Config.EventConfig.has(_Info):
				var _Name = GameLogic.CardTrans.get_message(GameLogic.Config.EventConfig[_Info].ShowNameID)
				InfoLabel.bbcode_text = "[shake rate=0 level=0][center]" + _Name + "[/center][/shake]"

		"2":
			if GameLogic.Config.ChallengeConfig.has(_Info):
				var _Name = GameLogic.CardTrans.get_message(GameLogic.Config.ChallengeConfig[_Info].ShowNameID)
				InfoLabel.bbcode_text = "[shake rate=4.5 level=10][center]" + GameLogic.CardTrans.get_message("Cost") + ":" + _Name + " " + GameLogic.CardTrans.get_message("术语_技能发动") + "[/center][/shake]"
			else:
				var _Name = _Info
				InfoLabel.bbcode_text = "[shake rate=4.5 level=10][center]" + GameLogic.CardTrans.get_message("Cost") + ":" + _Name + " " + GameLogic.CardTrans.get_message("术语_技能发动") + "[/center][/shake]"
		"3":
			if GameLogic.Config.CardConfig.has(_Info):
				var _Name = GameLogic.CardTrans.get_message(GameLogic.Config.CardConfig[_Info].ShowNameID)
				InfoLabel.bbcode_text = "[shake rate=0 level=0][center]" + _Name + "[/center][/shake]"
func call_del():
	self.get_parent().remove_child(self)
	self.queue_free()
