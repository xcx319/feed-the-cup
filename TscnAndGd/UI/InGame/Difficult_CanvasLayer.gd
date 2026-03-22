extends CanvasLayer

func _ready():
	self.hide()
	var _check = GameLogic.curLevelList
	if GameLogic.LoadingUI.IsLevel:
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.has("DevilList"):
			var _CHECKLIST: Array
			for _i in GameLogic.cur_Devil:
				_CHECKLIST.append(_LEVELINFO.DevilList[_i])
			if _CHECKLIST.has("难度-订单遮挡"):
				self.show()
				return

		if GameLogic.curLevelList.has("难度-订单遮挡"):
			self.show()
		elif _LEVELINFO.has("GamePlay"):
			if _LEVELINFO.GamePlay.has("难度-订单遮挡"):
				self.show()
