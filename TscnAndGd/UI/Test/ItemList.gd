extends ItemList

var _CHALLENGELIST: Array
var _REWARDLIST: Array

var _TYPE: int = 0

func _ready():
	call_deferred("call_init")

func call_init():

	_CHALLENGELIST = GameLogic.Config.ChallengeConfig.keys()
	_REWARDLIST = GameLogic.Config.CardConfig.keys()
func call_Challenge_show():



	if _TYPE != 0:
		call_hide()
	_TYPE = 2
	for _i in _CHALLENGELIST.size():
		var _NAME = _CHALLENGELIST[_i]
		var _TexPath = "res://Resources/UI/Scrolls/ui_scroll_pack.sprites/" + GameLogic.Config.ChallengeConfig[_NAME].Icon + ".tres"
		var _Tex = load(_TexPath)
		add_item(_NAME, _Tex, true)
	for _ID in GameLogic.cur_Challenge:
		var _IDX = _CHALLENGELIST.find(_ID)
		select(_IDX)
	self.show()
func call_Reward_show():
	if _TYPE != 0:
		call_hide()
	_TYPE = 1
	for _i in _REWARDLIST.size():
		var _NAME = _REWARDLIST[_i]
		var _TexPath = "res://Resources/UI/Scrolls/ui_scroll_pack.sprites/" + GameLogic.Config.CardConfig[_NAME].Icon + ".tres"
		var _Tex = load(_TexPath)
		add_item(_NAME, _Tex, true)
	for _ID in GameLogic.cur_Rewards:
		var _IDX = _REWARDLIST.find(_ID)
		select(_IDX)
	self.show()

func call_hide():
	match _TYPE:
		1:
			var _LIST = get_selected_items()
			GameLogic.cur_Rewards.clear()
			for _IDX in _LIST:
				var _NAME = _REWARDLIST[_IDX]
				GameLogic.cur_Rewards.append(_NAME)
		2:
			var _LIST = get_selected_items()
			GameLogic.cur_Challenge.clear()
			for _IDX in _LIST:
				var _NAME = _CHALLENGELIST[_IDX]
				GameLogic.cur_Challenge[_NAME] = GameLogic.Config.ChallengeConfig[_NAME]
	_TYPE = 0
	self.clear()
	self.hide()
