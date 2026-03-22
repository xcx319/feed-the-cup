extends CanvasLayer

onready var CardGrid = $Control / Info / BG / Scroll / Grid
onready var ChooseAni = $Control / Info / Control / AnimationPlayer
onready var _CARDBUT = preload("res://TscnAndGd/UI/Buttons/RewardChooseButton.tscn")
onready var ApplyBut = $Control / ButControl / ApplyBut
func call_ESC_true():
	GameLogic.Can_ESC = true
func call_show():
	GameLogic.Can_ESC = false
	_TYPE = 1
	if $Ani.assigned_animation != "show":
		$Ani.play("show")
	call_CARDSHOW()
func call_hide():
	if $Ani.assigned_animation != "hide":
		$Ani.play("hide")

var _TYPE: int = 1

func call_L():
	if _TYPE > 1:
		_TYPE -= 1
		call_CARDSHOW()
func call_R():
	if _TYPE < 9:
		_TYPE += 1
		call_CARDSHOW()
func call_CARDSHOW():
	call_clean_Grid()
	ChooseAni.play(str(_TYPE))
	call_CARD_Set(str(_TYPE))
func call_CARD_Set(_NAMEID: String):
	var _NORMALCARDLIST: Array
	var _SPECIALCARDLIST: Array
	var _KEYS = GameLogic.Config.CardConfig.keys()
	for _i in _KEYS.size():
		var _NAME = _KEYS[_i]

		var _INFO = GameLogic.Config.CardConfig[_NAME]
		if _INFO.UnlockType != "关闭":

			var _RANK = _INFO.Rank
			var _SPANI = _INFO.SpecialAni
			if _RANK == _NAMEID and _SPANI == "0":
				_NORMALCARDLIST.append(_NAME)
			elif _RANK == _NAMEID and _SPANI == _NAMEID:
				if _INFO.UnlockValue != "0":
					_SPECIALCARDLIST.insert(1, _NAME)
				else:
					_SPECIALCARDLIST.insert(0, _NAME)
			elif _RANK == _NAMEID and _SPANI != _NAMEID:
				_SPECIALCARDLIST.append(_NAME)
			elif _RANK != _NAMEID and _SPANI == _NAMEID:
				_SPECIALCARDLIST.append(_NAME)

	for _CARDNAME in _NORMALCARDLIST:
		var _BUTTSCN = _CARDBUT.instance()
		_BUTTSCN.IsShow = true
		CardGrid.add_child(_BUTTSCN)
		_BUTTSCN.ID = _CARDNAME

	for _CARDNAME in _SPECIALCARDLIST:
		var _BUTTSCN = _CARDBUT.instance()
		_BUTTSCN.IsShow = true
		CardGrid.add_child(_BUTTSCN)
		_BUTTSCN.ID = _CARDNAME
	call_GrabFocus()
func call_GrabFocus():
	yield(get_tree().create_timer(0.1), "timeout")
	CardGrid.get_child(0).grab_focus()
	call_INFO_Switch(_INFOSWITCH)
func call_clean_Grid():
	var _BUTLIST = CardGrid.get_children()
	for _BUT in _BUTLIST:
		_BUT.queue_free()

func call_closed():
	get_parent().call_closed()
	pass

func _on_1_pressed():
	_TYPE = 1
	call_CARDSHOW()
func _on_2_pressed():
	_TYPE = 2
	call_CARDSHOW()
func _on_3_pressed():
	_TYPE = 3
	call_CARDSHOW()
func _on_4_pressed():
	_TYPE = 4
	call_CARDSHOW()
func _on_5_pressed():
	_TYPE = 5
	call_CARDSHOW()
func _on_6_pressed():
	_TYPE = 6
	call_CARDSHOW()
func _on_7_pressed():
	_TYPE = 7
	call_CARDSHOW()
func _on_8_pressed():
	_TYPE = 8
	call_CARDSHOW()
func _on_9_pressed():
	_TYPE = 9
	call_CARDSHOW()

var _INFOSWITCH: bool
func call_INFO_Switch(_SWITCH: bool):
	var _BUTLIST = CardGrid.get_children()
	for _BUT in _BUTLIST:
		_BUT.call_INFO_Switch(_SWITCH)

func _on_But_pressed():
	_INFOSWITCH = not _INFOSWITCH
	call_INFO_Switch(_INFOSWITCH)
