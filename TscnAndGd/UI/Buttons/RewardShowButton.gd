extends Button

export var _SHOWBOOL: bool = false

var ID: String setget _But_Set

func _But_Set(_ID: String):
	ID = _ID

	if GameLogic.Config.CardConfig.has(_ID):
		var INFO = GameLogic.Config.CardConfig[_ID]
		var _ChallName = GameLogic.CardTrans.get_message(INFO.ShowNameID)

		var _ChallengeInfo = GameLogic.CardTrans.get_message(INFO.ShowInfoID)

		var _TEXT_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo)
		var _TEXT = "[center]" + _TEXT_1.format(GameLogic.Info.Info_Name) + "[/center]"

		var _RankAniName = "Reward_" + str(INFO.Rank)
		get_node("NinePatchRect/RankAni").play(_RankAniName)
		if int(INFO.SpecialAni) > 0:
			get_node("NinePatchRect/SpecialAni").play(INFO.SpecialAni)
		if INFO.UnlockType == "升级":
			get_node("NinePatchRect/PlusAni").play("+")

		var _TexPath = "res://Resources/UI/Scrolls/ui_scroll_pack.sprites/" + INFO.Icon + ".tres"
		var _Tex = load(_TexPath)
		get_node("NinePatchRect/Control/Icon").set_texture(_Tex)
	elif GameLogic.Config.ChallengeConfig.has(_ID):
		var INFO = GameLogic.Config.ChallengeConfig[_ID]
		var _ChallName = GameLogic.CardTrans.get_message(INFO.ShowNameID)

		var _ChallengeInfo = GameLogic.CardTrans.get_message(INFO.ShowInfoID)

		var _TEXT_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo)
		var _TEXT = "[center]" + _TEXT_1.format(GameLogic.Info.Info_Name) + "[/center]"

		var _RankAniName = "Challenge_" + str(INFO.Rank)
		get_node("NinePatchRect/RankAni").play(_RankAniName)
		var _TexPath = "res://Resources/UI/Scrolls/ui_scroll_pack.sprites/" + INFO.Icon + ".tres"
		var _Tex = load(_TexPath)
		get_node("NinePatchRect/Control/Icon").set_texture(_Tex)

func _on_mouse_entered() -> void :
	if _SHOWBOOL:
		return
	self.pressed = true
	self.grab_focus()
	match self.has_focus():
		true:
			var _NODE = get_parent().get_parent().get_parent()

			if _NODE.has_method("call_ShowInfo"):
				_NODE.call_ShowInfo(ID, self.rect_global_position)
		false:
			var _NODE = get_parent().get_parent().get_parent()
			if _NODE.has_method("call_ShowInfo"):
				_NODE.call_ShowInfo_Hide()
func _on_focus_entered() -> void :
	if _SHOWBOOL:
		return
	self.pressed = true
	match self.pressed:
		true:
			var _NODE = get_parent().get_parent().get_parent()
			if _NODE.has_method("call_ShowInfo"):
				_NODE.call_ShowInfo(ID, self.rect_global_position)
		false:
			var _NODE = get_parent().get_parent().get_parent()
			if _NODE.has_method("call_ShowInfo"):
				_NODE.call_ShowInfo_Hide()
func _on_focus_exited() -> void :

	pass

func _on_Button_toggled(button_pressed):
	if _SHOWBOOL:
		return
	match button_pressed:
		true:
			var _NODE = get_parent().get_parent().get_parent()
			if _NODE.has_method("call_ShowInfo"):
				_NODE.call_ShowInfo(ID, self.rect_global_position)
		false:
			var _NODE = get_parent().get_parent().get_parent()
			if _NODE.has_method("call_ShowInfo"):
				_NODE.call_ShowInfo_Hide()
