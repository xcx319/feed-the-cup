extends Node2D

var ApronLook: bool
func call_Running(_TYPE: int):
	ApronLook = true
	var _ANINAME = "号码牌" + str(_TYPE)
	if has_node("ApronType"):
		if get_node("ApronType").has_animation(_ANINAME):
			if get_node("ApronType").assigned_animation != _ANINAME:
				get_node("ApronType").play(_ANINAME)

func call_Running_end():
	ApronLook = false
	get_node("ApronType").play("0")
	call_ApronShow()
func call_GasPackbag():
	if has_node("PackbagType"):
		if get_node("PackbagType").assigned_animation != "气罐":
			get_node("PackbagType").play("气罐")
func call_Icebag():
	if has_node("PackbagType"):
		if get_node("PackbagType").assigned_animation != "冰盒":
			get_node("PackbagType").play("冰盒")

func call_EquipInit(_PLAYERID, _AVATARID, _INFO: Dictionary = {}):
	var _HeadID: int = 0
	var _FaceID: int = 0
	var _BodyID: int = 0
	var _FootID: int = 0
	var _AccessoryList: Array = []
	if _INFO.size():
		_HeadID = _INFO["Head"]
		_FaceID = _INFO["Face"]
		_BodyID = _INFO["Body"]
		_FootID = _INFO["Foot"]
		_AccessoryList.append(_INFO["Accessory_1"])
		_AccessoryList.append(_INFO["Accessory_2"])
		_AccessoryList.append(_INFO["Accessory_3"])
	call_EquipHead(_PLAYERID, _AVATARID, _HeadID)
	call_EquipFace(_PLAYERID, _AVATARID, _FaceID)
	call_EquipBody(_PLAYERID, _AVATARID, _BodyID)
	call_EquipFoot(_PLAYERID, _AVATARID, _FootID)
	call_EquipAccessory(_PLAYERID, _AVATARID, _AccessoryList)

func call_EquipHead(_PLAYERID, _AVATARID, _EQUIPID: int = 0):
	if _EQUIPID == 0 and _PLAYERID in [1, 2]:
		var _ID: int = GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Head"]
		_EQUIPID = _ID
		if not SteamLogic._EQUIPDIC.has(_ID):
			_EQUIPID = 0

	match _EQUIPID:
		0:
			if has_node("DecoHatType"):
				var _ANI = get_node("DecoHatType")
				if not _ANI.assigned_animation in ["兔耳发夹", "兔耳发夹+", "耳罩", "耳罩+", "发套", "发套+"]:
					_ANI.play("0")
		_:
			if GameLogic.Config.CostumeConfig.has(str(_EQUIPID)):
				var _ANINAME = GameLogic.Config.CostumeConfig[str(_EQUIPID)].ANI
				if has_node("DecoHatType"):
					var _ANI = get_node("DecoHatType")
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)

func call_EquipFace(_PLAYERID, _AVATARID, _EQUIPID: int = 0):
	if _EQUIPID == 0 and _PLAYERID in [1, 2]:
		var _ID: int = GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Face"]
		_EQUIPID = _ID
		if not SteamLogic._EQUIPDIC.has(_ID):
			_EQUIPID = 0

	match _EQUIPID:
		0:
			if has_node("MaskType"):
				var _ANI = get_node("MaskType")
				if not _ANI.assigned_animation in ["口罩", "口罩+", "防沫口罩", "防沫口罩+"]:
					_ANI.play("0")
		_:
			if GameLogic.Config.CostumeConfig.has(str(_EQUIPID)):
				var _ANINAME = GameLogic.Config.CostumeConfig[str(_EQUIPID)].ANI
				if has_node("MaskType"):
					var _ANI = get_node("MaskType")
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
func call_EquipBody(_PLAYERID, _AVATARID, _EQUIPID: int = 0):
	if _EQUIPID == 0 and _PLAYERID in [1, 2]:
		var _ID: int = GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Body"]
		_EQUIPID = _ID
		if not SteamLogic._EQUIPDIC.has(_ID):
			_EQUIPID = 0

	match _EQUIPID:
		0:
			if has_node("ApronType"):
				var _ANI = get_node("ApronType")
				if not _ANI.assigned_animation in ["粉围裙", "粉围裙+",
				"红围裙", "红围裙+",
				"绿围裙", "绿围裙+",
				"黄围裙", "黄围裙+", ]:
					_ANI.play("0")
		_:
			if GameLogic.Config.CostumeConfig.has(str(_EQUIPID)):
				var _ANINAME = GameLogic.Config.CostumeConfig[str(_EQUIPID)].ANI
				if has_node("ApronType"):
					var _ANI = get_node("ApronType")
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
func call_EquipHand(_PLAYERID, _AVATARID, _EQUIPID: int = 0):
	if _EQUIPID == 0 and _PLAYERID in [1, 2]:
		var _ID: int = GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Hand"]
		_EQUIPID = _ID
		if not SteamLogic._EQUIPDIC.has(_ID):
			_EQUIPID = 0

	match _EQUIPID:
		0:
			if has_node("CloveType"):
				var _ANI = get_node("CloveType")
				if not _ANI.assigned_animation in ["一次性手套", "一次性手套+", "尖爪手套", "尖爪手套+"]:
					_ANI.play("0")
		_:
			if GameLogic.Config.CostumeConfig.has(str(_EQUIPID)):
				var _ANINAME = GameLogic.Config.CostumeConfig[str(_EQUIPID)].ANI
				if has_node("CloveType"):
					var _ANI = get_node("CloveType")
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)


func call_EquipFoot(_PLAYERID, _AVATARID, _EQUIPID: int = 0):
	if _EQUIPID == 0 and _PLAYERID in [1, 2]:
		var _ID: int = GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID]["Foot"]
		_EQUIPID = _ID
		if not SteamLogic._EQUIPDIC.has(_ID):
			_EQUIPID = 0

	match _EQUIPID:
		0:
			if has_node("ShoeType"):
				var _ANI = get_node("ShoeType")
				if not _ANI.assigned_animation in ["人字拖", "人字拖+", "学生拖鞋", "学生拖鞋+",
				"小白鞋", "小白鞋+", "防滑鞋", "防滑鞋+"]:
					_ANI.play("0")
		_:
			if GameLogic.Config.CostumeConfig.has(str(_EQUIPID)):
				var _ANINAME = GameLogic.Config.CostumeConfig[str(_EQUIPID)].ANI
				if has_node("ShoeType"):
					var _ANI = get_node("ShoeType")
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
func _EquipAccessory(_EQUIPList: Array):

	if has_node("NeckType"):
		var _ANI = get_node("NeckType")
		if not _ANI.assigned_animation in ["公交卡", "公交卡+"]:
			_ANI.play("0")
	if has_node("PackbagType"):
		var _ANI = get_node("PackbagType")
		if not _ANI.assigned_animation in ["小翅膀", "小翅膀+"]:
			_ANI.play("0")
	if has_node("ScarfType"):
		var _ANI = get_node("ScarfType")
		if not _ANI.assigned_animation in ["小蜜蜂", "小蜜蜂+", "耳麦", "耳麦+"]:
			_ANI.play("0")
	if has_node("CardType"):
		var _ANI = get_node("CardType")
		if not _ANI.assigned_animation in ["工作名牌", "工作名牌+"]:
			_ANI.play("0")
	if has_node("EffectType"):
		var _ANI = get_node("EffectType")
		_ANI.play("0")
	if has_node("WatchType"):
		var _ANI = get_node("WatchType")
		if not _ANI.assigned_animation in ["手表", "手表+"]:
			_ANI.play("0")
	for _EQUIPID in _EQUIPList:
		if GameLogic.Config.CostumeConfig.has(str(_EQUIPID)):
			var _ANINAME = GameLogic.Config.CostumeConfig[str(_EQUIPID)].ANI
			var _NAME = self.name
			if has_node("WatchType"):
				var _ANI = get_node("WatchType")
				if _ANI.has_animation(_ANINAME):
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
			if has_node("EffectType"):
				var _ANI = get_node("EffectType")
				if _ANI.has_animation(_ANINAME):
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
			if has_node("PackbagType"):
				var _ANI = get_node("PackbagType")
				if _ANI.has_animation(_ANINAME):
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
			if has_node("NeckType"):
				var _ANI = get_node("NeckType")
				if _ANI.has_animation(_ANINAME):
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
			if has_node("ScarfType"):
				var _ANI = get_node("ScarfType")
				if _ANI.has_animation(_ANINAME):
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
			if has_node("CardType"):
				var _ANI = get_node("CardType")
				if _ANI.has_animation(_ANINAME):
					if _ANI.assigned_animation != _ANINAME:
						_ANI.play(_ANINAME)
func call_EquipAccessory(_PLAYERID, _AVATARID, _EQUIPLIST: Array = []):
	var _ACCLIST: Array
	if not _EQUIPLIST.size():
		for _i in 3:
			var _ACCNAME = "Accessory_" + str(_i + 1)
			var _ID = GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID][_ACCNAME]
			if SteamLogic._EQUIPDIC.has(_ID):
				_ACCLIST.append(_ID)
			else:
				GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID][_ACCNAME] = 0
	else:
		_ACCLIST = _EQUIPLIST
	_EquipAccessory(_ACCLIST)

func call_Overseek():
	if has_node("HatType"):
		if SteamLogic.DAYTYPE == "Halloween":
			if get_node("DecoHatType").assigned_animation != "南瓜帽":
				get_node("DecoHatType").play("南瓜帽")
		elif SteamLogic.DAYTYPE == "Chris":
			if get_node("DecoHatType").assigned_animation != "圣诞帽":
				get_node("DecoHatType").play("圣诞帽")
		else:
			call_show()
		if SteamLogic.DAYTYPE == "NewYear":
			if get_node("ScarfType").assigned_animation != "新年围巾":
				get_node("ScarfType").play("新年围巾")
			else:
				call_show()

		if SteamLogic.DAYTYPE == "Valentine":
			if get_node("CloveType").assigned_animation != "爱心手套":
				get_node("CloveType").play("爱心手套")
			else:
				call_show()
func call_Goblin():
	if has_node("HatType"):
		if SteamLogic.DAYTYPE == "Halloween":
			if get_node("DecoHatType").assigned_animation != "南瓜帽":
				get_node("DecoHatType").play("南瓜帽")
		elif SteamLogic.DAYTYPE == "Chris":
			if get_node("DecoHatType").assigned_animation != "圣诞帽":
				get_node("DecoHatType").play("圣诞帽")
		elif SteamLogic.DAYTYPE == "NewYear":
			if get_node("ScarfType").assigned_animation != "新年围巾":
				get_node("ScarfType").play("新年围巾")

		elif SteamLogic.DAYTYPE == "Valentine":
			if has_node("CloveType"):
				if get_node("CloveType").assigned_animation != "爱心手套":
					get_node("CloveType").play("爱心手套")
		else:
			if has_node("HatType"):
				if get_node("HatType").assigned_animation != "哥布林员工帽":
					get_node("HatType").play("哥布林员工帽")

	if has_node("CloveType"):
		if get_node("CloveType").assigned_animation != "哥布林手套":
			get_node("CloveType").play("哥布林手套")
	if SteamLogic.DAYTYPE == "Chris":
		if has_node("DecoHatType"):
			if get_node("DecoHatType").assigned_animation != "圣诞帽":
				get_node("DecoHatType").play("圣诞帽")

var _DEVILINIT_BOOL: bool = false
func call_Devil(_RANDOM):
	if _DEVILINIT_BOOL:
		return
	_DEVILINIT_BOOL = true
	if SteamLogic.DAYTYPE == "NewYear":
		if has_node("ScarfType"):
			if get_node("ScarfType").assigned_animation != "新年围巾":
				get_node("ScarfType").play("新年围巾")
	elif has_node("MaskType"):
		var _RAND = _RANDOM % 4
		match _RAND:
			0:
				pass
			1:
				if get_node("MaskType").assigned_animation != "口罩":
					get_node("MaskType").play("口罩")
			2:
				if get_node("MaskType").assigned_animation != "防沫口罩":
					get_node("MaskType").play("防沫口罩")
			3:
				if get_node("MaskType").assigned_animation != "防毒面具":
					get_node("MaskType").play("防毒面具")
	if has_node("ShoeType"):
		var _RAND = _RANDOM % 5
		match _RAND:
			0:
				pass
			1:
				if get_node("ShoeType").assigned_animation != "学生拖鞋":
					get_node("ShoeType").play("学生拖鞋")
			2:
				if get_node("ShoeType").assigned_animation != "人字拖":
					get_node("ShoeType").play("人字拖")
			3:
				if get_node("ShoeType").assigned_animation != "小白鞋":
					get_node("ShoeType").play("小白鞋")
			4:
				if get_node("ShoeType").assigned_animation != "防滑靴":
					get_node("ShoeType").play("防滑靴")
	if SteamLogic.DAYTYPE == "Chris":
		if has_node("DecoHatType"):
			if get_node("DecoHatType").assigned_animation != "圣诞帽":
				get_node("DecoHatType").play("圣诞帽")
	elif SteamLogic.DAYTYPE == "Halloween":
		if get_node("DecoHatType").assigned_animation != "南瓜帽":
			get_node("DecoHatType").play("南瓜帽")
	else:
		var _rand = _RANDOM % 8
		match _rand:
			0:
				pass
			1:
				if has_node("HatType"):
					if get_node("HatType").assigned_animation != "哥布林员工帽":
						get_node("HatType").play("哥布林员工帽")
			2:
				if has_node("DecoHatType"):
					if get_node("DecoHatType").assigned_animation != "耳罩":
						get_node("DecoHatType").play("耳罩")
			3:
				if has_node("DecoHatType"):
					if get_node("DecoHatType").assigned_animation != "兔耳发卡":
						get_node("DecoHatType").play("兔耳发卡")
			4:
				if has_node("DecoHatType"):
					if get_node("DecoHatType").assigned_animation != "发套":
						get_node("DecoHatType").play("发套")
			5:
				if has_node("SpeakerType"):
					if get_node("SpeakerType").assigned_animation != "小蜜蜂":
						get_node("SpeakerType").play("小蜜蜂")
			6:
				if has_node("SpeakerType"):
					if get_node("SpeakerType").assigned_animation != "耳麦":
						get_node("SpeakerType").play("耳麦")
			7:
				if has_node("PackbagType"):
					if get_node("PackbagType").assigned_animation != "小翅膀":
						get_node("PackbagType").play("小翅膀")
	if SteamLogic.DAYTYPE == "Valentine":
		if has_node("CloveType"):
			if get_node("CloveType").assigned_animation != "爱心手套":
				get_node("CloveType").play("爱心手套")
	elif has_node("CloveType"):
		var _RAND = _RANDOM % 7
		match _RAND:
			0:
				pass
			1:
				if get_node("CloveType").assigned_animation != "一次性手套":
					get_node("CloveType").play("一次性手套")
			2:
				if get_node("CloveType").assigned_animation != "工作手套":
					get_node("CloveType").play("工作手套")
			3:
				if get_node("CloveType").assigned_animation != "绝缘手套":
					get_node("CloveType").play("绝缘手套")
			4:
				if get_node("CloveType").assigned_animation != "尖爪手套":
					get_node("CloveType").play("尖爪手套")
			5:
				if get_node("CloveType").assigned_animation != "橡胶手套":
					get_node("CloveType").play("橡胶手套")
			6:
				if get_node("CloveType").assigned_animation != "防烫手套":
					get_node("CloveType").play("防烫手套")
	if has_node("ApronType"):
		var _RAND = _RANDOM % 5
		match _RAND:
			0:
				pass
			1:
				if get_node("ApronType").assigned_animation != "粉围裙":
					get_node("ApronType").play("粉围裙")
			2:
				if get_node("ApronType").assigned_animation != "绿围裙":
					get_node("ApronType").play("绿围裙")
			3:
				if get_node("ApronType").assigned_animation != "黄围裙":
					get_node("ApronType").play("黄围裙")
			4:
				if get_node("ApronType").assigned_animation != "红围裙":
					get_node("ApronType").play("红围裙")

func call_Mask(_BOOL):
	if GameLogic.LoadingUI.IsLevel:
		if not _BOOL:
			if has_node("HatType"):
				if GameLogic.cur_Rewards.has("员工帽"):
					if get_node("HatType").assigned_animation != "员工帽":
						get_node("HatType").play("员工帽")
				elif GameLogic.cur_Rewards.has("员工帽+"):
					if get_node("HatType").assigned_animation != "员工帽+":
						get_node("HatType").play("员工帽+")

				else:
					if get_node("HatType").assigned_animation in ["员工帽", "员工帽+"]:
						get_node("HatType").play("0")
		elif get_node("HatType").assigned_animation in ["员工帽", "员工帽+"]:
			get_node("HatType").play("0")

func call_show():

	if not GameLogic.LoadingUI.IsLevel:
		return

	call_MaskShow()
	call_ShoeShow()
	call_HatShow()
	call_ApronShow()
	call_PackbagShow()
	call_NeckShow()

func call_MaskShow():
	if has_node("MaskType"):

		if GameLogic.cur_Rewards.has("防沫口罩"):
			if get_node("MaskType").assigned_animation != "防沫口罩":
				get_node("MaskType").play("防沫口罩")
		if GameLogic.cur_Rewards.has("防沫口罩+"):
			if get_node("MaskType").assigned_animation != "防沫口罩+":
				get_node("MaskType").play("防沫口罩+")
		if GameLogic.cur_Rewards.has("防毒面具"):
			if get_node("MaskType").assigned_animation != "防毒面具":
				get_node("MaskType").play("防毒面具")
		if GameLogic.cur_Rewards.has("防毒面具+"):
			if get_node("MaskType").assigned_animation != "防毒面具+":
				get_node("MaskType").play("防毒面具+")
func call_ShoeShow():
	if has_node("ShoeType"):

		if GameLogic.cur_Rewards.has("学生拖鞋"):
			if get_node("ShoeType").assigned_animation != "学生拖鞋":
				get_node("ShoeType").play("学生拖鞋")
		if GameLogic.cur_Rewards.has("学生拖鞋+"):
			if get_node("ShoeType").assigned_animation != "学生拖鞋+":
				get_node("ShoeType").play("学生拖鞋+")
		if GameLogic.cur_Rewards.has("冥思"):
			if get_node("ShoeType").assigned_animation != "人字拖":
				get_node("ShoeType").play("人字拖")
		if GameLogic.cur_Rewards.has("冥思+"):
			if get_node("ShoeType").assigned_animation != "人字拖+":
				get_node("ShoeType").play("人字拖+")
		if GameLogic.cur_Rewards.has("小白鞋"):
			if get_node("ShoeType").assigned_animation != "小白鞋":
				get_node("ShoeType").play("小白鞋")
		if GameLogic.cur_Rewards.has("小白鞋+"):
			if get_node("ShoeType").assigned_animation != "小白鞋+":
				get_node("ShoeType").play("小白鞋+")
		if GameLogic.cur_Rewards.has("防滑靴"):
			if get_node("ShoeType").assigned_animation != "防滑靴":
				get_node("ShoeType").play("防滑靴")
		if GameLogic.cur_Rewards.has("防滑靴+"):
			if get_node("ShoeType").assigned_animation != "防滑靴+":
				get_node("ShoeType").play("防滑靴+")
func call_HatShow():

	if has_node("DecoHatType"):
		if GameLogic.cur_Rewards.has("耳罩"):
			if get_node("DecoHatType").assigned_animation != "耳罩":
				get_node("DecoHatType").play("耳罩")
		if GameLogic.cur_Rewards.has("耳罩+"):
			if get_node("DecoHatType").assigned_animation != "耳罩+":
				get_node("DecoHatType").play("耳罩+")
		if GameLogic.cur_Rewards.has("兔耳发卡"):
			if get_node("DecoHatType").assigned_animation != "兔耳发卡":
				get_node("DecoHatType").play("兔耳发卡")
		if GameLogic.cur_Rewards.has("兔耳发卡+"):
			if get_node("DecoHatType").assigned_animation != "兔耳发卡+":
				get_node("DecoHatType").play("兔耳发卡+")
		if GameLogic.cur_Rewards.has("加班洗脑"):
			if get_node("DecoHatType").assigned_animation != "发套":
				get_node("DecoHatType").play("发套")
		if GameLogic.cur_Rewards.has("加班洗脑+"):
			if get_node("DecoHatType").assigned_animation != "发套+":
				get_node("DecoHatType").play("发套+")
	if has_node("SpeakerType"):
		if GameLogic.cur_Rewards.has("小蜜蜂"):
			if get_node("SpeakerType").assigned_animation != "小蜜蜂":
				get_node("SpeakerType").play("小蜜蜂")
		if GameLogic.cur_Rewards.has("小蜜蜂+"):
			if get_node("SpeakerType").assigned_animation != "小蜜蜂+":
				get_node("SpeakerType").play("小蜜蜂+")
		if GameLogic.cur_Rewards.has("耳麦"):
			if get_node("SpeakerType").assigned_animation != "耳麦":
				get_node("SpeakerType").play("耳麦")
		if GameLogic.cur_Rewards.has("耳麦+"):
			if get_node("SpeakerType").assigned_animation != "耳麦+":
				get_node("SpeakerType").play("耳麦+")
	if has_node("CloveType"):
		if GameLogic.cur_Rewards.has("一次性手套"):
			if get_node("CloveType").assigned_animation != "一次性手套":
				get_node("CloveType").play("一次性手套")
		if GameLogic.cur_Rewards.has("一次性手套+"):
			if get_node("CloveType").assigned_animation != "一次性手套+":
				get_node("CloveType").play("一次性手套+")
		if GameLogic.cur_Rewards.has("工作手套"):
			if get_node("CloveType").assigned_animation != "工作手套":
				get_node("CloveType").play("工作手套")
		if GameLogic.cur_Rewards.has("工作手套+"):
			if get_node("CloveType").assigned_animation != "工作手套+":
				get_node("CloveType").play("工作手套+")

		if GameLogic.cur_Rewards.has("尖爪手套"):
			if get_node("CloveType").assigned_animation != "尖爪手套":
				get_node("CloveType").play("尖爪手套")
		if GameLogic.cur_Rewards.has("尖爪手套+"):
			if get_node("CloveType").assigned_animation != "尖爪手套+":
				get_node("CloveType").play("尖爪手套+")
		if GameLogic.cur_Rewards.has("。。"):
			if get_node("CloveType").assigned_animation != "橡胶手套":
				get_node("CloveType").play("橡胶手套")
		if GameLogic.cur_Rewards.has("。。+"):
			if get_node("CloveType").assigned_animation != "橡胶手套+":
				get_node("CloveType").play("橡胶手套+")
		if GameLogic.cur_Rewards.has("防烫手套"):
			if get_node("CloveType").assigned_animation != "防烫手套":
				get_node("CloveType").play("防烫手套")
		if GameLogic.cur_Rewards.has("防烫手套+"):
			if get_node("CloveType").assigned_animation != "防烫手套+":
				get_node("CloveType").play("防烫手套+")
func call_ApronShow():
	if ApronLook:
		return
	if has_node("ApronType"):
		if GameLogic.cur_Rewards.has("极限好评"):
			if get_node("ApronType").assigned_animation != "红围裙":
				get_node("ApronType").play("红围裙")
		if GameLogic.cur_Rewards.has("极限好评+"):
			if get_node("ApronType").assigned_animation != "红围裙+":
				get_node("ApronType").play("红围裙+")
		if GameLogic.cur_Rewards.has("快出声望"):
			if get_node("ApronType").assigned_animation != "绿围裙":
				get_node("ApronType").play("绿围裙")
		if GameLogic.cur_Rewards.has("快出声望+"):
			if get_node("ApronType").assigned_animation != "绿围裙+":
				get_node("ApronType").play("绿围裙+")
		if GameLogic.cur_Rewards.has("跳单声望"):
			if get_node("ApronType").assigned_animation != "粉围裙":
				get_node("ApronType").play("粉围裙")
		if GameLogic.cur_Rewards.has("跳单声望+"):
			if get_node("ApronType").assigned_animation != "粉围裙+":
				get_node("ApronType").play("粉围裙+")
		if GameLogic.cur_Rewards.has("COMBO声望"):
			if get_node("ApronType").assigned_animation != "黄围裙":
				get_node("ApronType").play("黄围裙")
		if GameLogic.cur_Rewards.has("COMBO声望+"):
			if get_node("ApronType").assigned_animation != "黄围裙+":
				get_node("ApronType").play("黄围裙+")
func call_PackbagShow():
	if has_node("PackbagType"):
		if GameLogic.cur_Rewards.has("小翅膀"):
			if get_node("PackbagType").assigned_animation != "小翅膀":
				get_node("PackbagType").play("小翅膀")
		if GameLogic.cur_Rewards.has("小翅膀+"):
			if get_node("PackbagType").assigned_animation != "小翅膀+":
				get_node("PackbagType").play("小翅膀+")
func call_NeckShow():
	if has_node("NeckType"):
		if GameLogic.cur_Rewards.has("提前上班"):
			if get_node("NeckType").assigned_animation != "公交卡":
				get_node("NeckType").play("公交卡")
		if GameLogic.cur_Rewards.has("提前上班+"):
			if get_node("NeckType").assigned_animation != "公交卡+":
				get_node("NeckType").play("公交卡+")
	if has_node("WatchType"):
		if GameLogic.cur_Rewards.has("自愿加班"):
			if get_node("WatchType").assigned_animation != "手表":
				get_node("WatchType").play("手表")
		if GameLogic.cur_Rewards.has("自愿加班+"):
			if get_node("WatchType").assigned_animation != "手表+":
				get_node("WatchType").play("手表+")
	if has_node("CardType"):
		if GameLogic.cur_Rewards.has("工作名牌"):
			if get_node("CardType").assigned_animation != "工作名牌":
				get_node("CardType").play("工作名牌")
		if GameLogic.cur_Rewards.has("工作名牌+"):
			if get_node("CardType").assigned_animation != "工作名牌+":
				get_node("CardType").play("工作名牌+")
