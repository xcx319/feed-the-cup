extends Head_Object

onready var typeAni = get_node("AniNode/typeAni")
onready var CanAni = get_node("AniNode/CanAni")
onready var UseAni = get_node("AniNode/Use")
onready var FreshAni = $Effect_flies / Ani

onready var NumLabel = get_node("NumLabel")

onready var ProAni = get_node("ProNode/ProAni")
onready var MixAni = get_node("MixNode/MixAni")
var PlayerList: Array

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

var Freshless_bool: bool
var IsPassDay: bool
var Liquid_Count: int
var Num: int = 10
var IsOpen: bool = false
var CanUse: bool
var ProType: int = 0
var Is_Storage: bool
onready var A_But = get_node("But/A")

onready var HoldBut = get_node("Hold")
onready var X_But = HoldBut.get_node("X")
onready var Audio
onready var AUDIO_OPEN

func call_Broken():
	Freshless_bool = true
	call_Fresh_Logic()
func call_Fresh_Logic():
	if Num < 1:
		FreshAni.play("init")
	if Freshless_bool:
		FreshAni.play("Flies")
	elif IsPassDay:
		FreshAni.play("OverDay")
	else:
		FreshAni.play("init")
func But_Switch(_bool, _Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if get_parent().name in ["layer1", "layer2", "layer3", "layer4"]:
		X_But.hide()
		return
	if _Player.Con.IsHold:

		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		if _Player.Con.HoldInsId == self.get_instance_id():
			if not IsOpen:
				X_But.InfoLabel.text = GameLogic.CardTrans.get_message("BUT-开封")
				X_But.show()
				A_But.hide()
				return
			elif Num <= 0:
				A_But.hide()
				X_But.hide()
			else:

				if not CanUse and ProType == 1:

					A_But.hide()
					X_But.InfoLabel.text = GameLogic.CardTrans.get_message("BUT-捏碎")
					X_But.show()
				else:
					A_But.hide()
					X_But.hide()
				return
		else:
			var _HOLD = instance_from_id(_Player.Con.HoldInsId)
			if _HOLD.get("FuncType") == "DrinkCup" and CanUse:
				A_But.show()
			else:
				A_But.hide()
	else:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		A_But.show()
		if not IsOpen:
			if get_parent().name == "Items":
				X_But.hide()
			else:
				X_But.show()

		elif Num <= 0:

			X_But.hide()
		else:

			X_But.hide()
	.But_Switch(_bool, _Player)
	if not _bool:
		X_But.hide()

func call_Freezer_ColdTimer():
	call_Freezer_Switch(true)
func call_Freezer_Switch(_Switch):
	Is_Storage = _Switch
func _ready() -> void :

	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	IsItem = true

	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Audio = GameLogic.Audio.return_Effect("气泡")
	AUDIO_OPEN = GameLogic.Audio.return_Effect("开罐")

func _DayClosedCheck():
	if not IsOpen:
		return
	var _FreshBool: bool
	match FreshType:
		1:
			if IsOpen:
				_FreshBool = true
		2:
			_FreshBool = true
		3:
			Freshless_bool = true
	if _FreshBool:
		if not Is_Storage:
			Freshless_bool = true
		else:
			if not IsPassDay:
				IsPassDay = true
			else:
				Freshless_bool = true

	var _NODE = get_parent()
	if not is_instance_valid(_NODE):
		return
	if get_parent().name == "Items":
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.ITEM):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.ITEM)

func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()

func call_load(_Info):
	self.name = _Info.NAME
	_SELFID = int(_Info.NAME)
	.call_Ins_Save(_SELFID)
	if not TypeStr:
		call_init(_Info.TSCN)
	Num = _Info.Num
	Liquid_Count = Num
	NumLabel.text = str(Num)
	IsOpen = _Info.IsOpen



	if _Info.has("CanUse"):
		CanUse = _Info.CanUse
	if IsOpen:
		MixAni.play("hide")
		CanAni.play("opened")

	elif IsOpen:
		call_CanUseLogic()
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay


	if _Info.has("Freshless_bool"):
		Freshless_bool = _Info.Freshless_bool

	call_bag_tex_set()
	if CanUse:
		call_CanUse()
	if Num < 1:
		CanAni.play("out")
		MixAni.play("init")
		IsPassDay = false
		Freshless_bool = false
	call_Fresh_Logic()
func call_bag_tex_set():
	IsItem = true
	if typeAni:

		if typeAni.has_animation(TypeStr):
			typeAni.play(TypeStr)
			if TypeStr in ["bag_BlackCookie"]:
				CanAni.play("bag")
		else:
			pass
	Weight = GameLogic.TSCNLoad.return_weight(FuncType)
	if TypeStr in ["bag_BlackCookie"]:
		IsOpen = true
		ProType = 1

func call_player_leave(_Player):
	if PlayerList.has(_Player):
		call_STIR_end(_Player)
func call_puppet_STIR_start(_MIXSPEED, _ISOPEN):
	if TypeStr in ["bag_BlackCookie"]:
		_AUDIO = GameLogic.Audio.return_Effect("捏饼干")
		_AUDIO.play()
	IsOpen = _ISOPEN
	MixAni.playback_speed = _MIXSPEED
	MixAni.play("Mixd")
func return_SQUEEZE_SPEED():
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()

	var _Mult: float = 0
	for _Player in PlayerList:
		_Mult += 1
		if _Player.BuffList.has("技能-手速"):
			_Mult += 0.5
		if _Player.Stat.Skills.has("技能-握力"):
			_Mult += 1
		if not _Player.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("一次性手套"):
				_Mult += 0.5
			if GameLogic.cur_Rewards.has("一次性手套+"):
				_Mult += 1.5
			if GameLogic.cur_Challenge.has("手笨+"):
				_Mult = _Mult * 0.75

		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		if GameLogic.cur_Event == "手速":
			_Mult = 20

	if _Mult <= 0:
		_Mult = 1
	_SPEED = _SPEED * _Mult
	return _SPEED
var _AUDIO = null
func return_STIR_start(_Player):
	if Num <= 0:
		return false
	if not IsOpen:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return true
		if not PlayerList.has(_Player):
			PlayerList.append(_Player)
		MixAni.playback_speed = return_SQUEEZE_SPEED()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_start", [MixAni.playback_speed, IsOpen])

		MixAni.play("Mixd")
		return true
	elif not CanUse and ProType == 1:
		var _NAME = get_parent().name
		if get_parent().name in ["Weapon_note"]:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return true
			if not PlayerList.has(_Player):
				PlayerList.append(_Player)
			MixAni.playback_speed = return_SQUEEZE_SPEED()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_start", [MixAni.playback_speed, IsOpen])
			if TypeStr in ["bag_BlackCookie"]:
				_AUDIO = GameLogic.Audio.return_Effect("捏饼干")
				_AUDIO.play()
			MixAni.play("Mixd")
			return true

	return false

func call_puppet_STIR_end(_PATH):
	if _AUDIO != null:
		_AUDIO.stop()
	var _Player = get_node(_PATH)

	_Player.call_reset_stat()
	if not GameLogic.cur_Challenge.has("手笨"):
		if MixAni.assigned_animation == "Mixd":
			MixAni.stop(false)
			CanMove = true
			return
	if MixAni.get_assigned_animation() == "Mixd":
		MixAni.play("hide")
func call_STIR_end(_Player):
	if _AUDIO != null:
		_AUDIO.stop()

	if PlayerList.has(_Player):
		PlayerList.erase(_Player)
		_Player.call_reset_stat()

	if not PlayerList.size():


		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH])
		if not GameLogic.cur_Challenge.has("手笨"):

			if MixAni.assigned_animation == "Mixd":
				MixAni.stop(false)
				CanMove = true
				return
		if MixAni.get_assigned_animation() == "Mixd":
			MixAni.play("hide")
	if get_parent().name == "Weapon_note" and not IsOpen:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH])

		if not GameLogic.cur_Challenge.has("手笨"):

			if MixAni.assigned_animation == "Mixd":
				MixAni.stop(false)
				CanMove = true
				return
		if MixAni.get_assigned_animation() == "Mixd":
			MixAni.play("hide")
func call_puppet_Mix_Finished():
	if _AUDIO != null:
		_AUDIO.stop()
	if not IsOpen:
		call_Open()
		CanMove = true
	else:
		call_CanUse()
func _Mix_Finished() -> void :
	if _AUDIO != null:
		_AUDIO.stop()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if not CanUse and ProType == 1:

			A_But.hide()
			X_But.InfoLabel.text = GameLogic.CardTrans.get_message("BUT-捏碎")
			X_But.show()
		else:
			A_But.hide()
			X_But.hide()
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_Mix_Finished")
	if not IsOpen:
		call_Open()

		for i in PlayerList.size():
			var _Player = PlayerList[i]

			if _Player.has_method("call_reset_stat"):
				_Player.call_reset_stat()
				But_Switch(true, _Player)
		PlayerList.clear()
		CanMove = true
	else:

		for i in PlayerList.size():
			var _Player = PlayerList[i]

			if _Player.has_method("call_reset_stat"):
				_Player.call_reset_stat()
				But_Switch(true, _Player)
		PlayerList.clear()
		call_CanUse()

func call_Open():
	if not IsOpen:
		MixAni.play("hide")
		IsOpen = true
	CanAni.play("opened")
	AUDIO_OPEN.play(0)
	if GameLogic.Config.ItemConfig.has(TypeStr):
		var _Sell = int(GameLogic.Config.ItemConfig[TypeStr].Sell)
		call_Open_Money(_Sell)
	call_CanUseLogic()
func call_CanUseLogic():
	match FuncTypePara:



		"栗子":
			ProType = 1
			ProAni.play("1")
		"奇亚籽", "果冻":
			ProType = 2
			ProAni.play("2")
		"燕麦":
			ProType = 3
			ProAni.play("3")
		_:
			CanUse = true
			ProAni.play("init")
func call_CanUse():
	CanUse = true
	if TypeStr in ["bag_BlackCookie"]:
		typeAni.play("bag_BlackCookie_broken")
		MixAni.play("hide")
		$Hold.hide()
	else:
		ProAni.play("finish")
		MixAni.play("hide")
func call_AddWater():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_AddWater")
	if not CanUse and ProType == 2:
		call_CanUse()
func call_add_extra_puppet(_CUPPATH, _PLAYERPATH, _NUM):
	var _CupObj = get_node(_CUPPATH)
	var _Player = get_node(_PLAYERPATH)

	Num = _NUM
	NumLabel.text = str(Num)
	UseAni.play("use")
	Audio.play(0)
	if not Num:
		CanAni.play("out")
		MixAni.play("init")
		if Holding:
			if SteamLogic.IsMultiplay:
				if _Player.cur_Player == SteamLogic.STEAM_ID:
					GameLogic.Tutorial.call_DropInTrashbin(true)
			else:
				GameLogic.Tutorial.call_DropInTrashbin(true)

func call_AddAll():
	Num = 0
	UseAni.play("use")
	Audio.play(0)
	CanAni.play("out")
	MixAni.play("init")
	if TypeStr in ["bag_BlackCookie"]:
		typeAni.play("bag_BlackCookie_Empty")
func call_add_extra(_ButID, _Player, _CupObj):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)
		0:

			if FuncTypePara in ["黑曲奇完整"]:
				return
			if _CupObj.Top != "":
				return
			if FuncTypePara in ["糖渍樱桃"]:
				if Num > 0 and not Freshless_bool and CanUse:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if not _CupObj.Condiment_1:
						_CupObj.call_add_condiment("糖渍樱桃")
						UseAni.play("use")
						Audio.play(0)
						Num -= 1
						NumLabel.text = str(Num)
						if Num <= 0:
							CanAni.play("out")
						if IsPassDay:
							_CupObj.call_add_PassDay()
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _CUPPATH = _CupObj.get_path()
							var _PLAYERPATH = _Player.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_add_extra_puppet", [_CUPPATH, _PLAYERPATH, Num])
						return true
				return
			if Num > 0 and not Freshless_bool and CanUse:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _num: int = 0
				var _TYPE = _CupObj.TYPE
				match _TYPE:
					"EggRoll_white", "EggRoll_black":
						var _ADDBOOL: bool = false
						if _CupObj.Liquid_Count > 0 and _CupObj.Liquid_Count <= 2:
							if _CupObj.Extra_1 == "":
								_CupObj.Extra_1 = FuncTypePara
								Num -= 1
								NumLabel.text = str(Num)
								_ADDBOOL = true
						elif _CupObj.Liquid_Count > 2 and _CupObj.Liquid_Count <= 4:
							if _CupObj.Extra_2 == "":
								_CupObj.Extra_2 = FuncTypePara
								Num -= 1
								NumLabel.text = str(Num)
								_ADDBOOL = true
						elif _CupObj.Liquid_Count > 4 and _CupObj.Liquid_Count <= 6:
							if _CupObj.Extra_3 == "":
								_CupObj.Extra_3 = FuncTypePara
								Num -= 1
								NumLabel.text = str(Num)
								_ADDBOOL = true
						if _ADDBOOL:
							UseAni.play("use")
							Audio.play(0)
							Liquid_Count = Num
							if not Num:
								CanAni.play("out")
								MixAni.play("init")
								if Holding:
									if SteamLogic.IsMultiplay:
										if _Player.cur_Player == SteamLogic.STEAM_ID:
											GameLogic.Tutorial.call_DropInTrashbin(true)
									else:
										GameLogic.Tutorial.call_DropInTrashbin(true)
							if IsPassDay:
								_CupObj.call_add_PassDay()
							_CupObj.call_add_extra()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _CUPPATH = _CupObj.get_path()
								var _PLAYERPATH = _Player.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_add_extra_puppet", [_CUPPATH, _PLAYERPATH, Num])
							GameLogic.Tutorial.call_AddIn()
						return
					"DrinkCup_S", "SodaCan_S", "BeerCup_S":
						_num = 1
						if _CupObj.Extra_1 != "":
							return
					"DrinkCup_M", "SodaCan_M", "BeerCup_M":
						_num = 2
						if _CupObj.Extra_2 != "":
							return
					"DrinkCup_L", "SodaCan_L", "BeerCup_L":
						_num = 3
						if _CupObj.Extra_3 != "":
							return
					"SuperCup_M":
						_num = 5
						if _CupObj.Extra_5 != "":
							return
				if _CupObj.Extra_1 == "":
					_CupObj.Extra_1 = FuncTypePara
					Num -= 1
					NumLabel.text = str(Num)
				elif _CupObj.Extra_2 == "" and _num > 1:
					_CupObj.Extra_2 = FuncTypePara
					Num -= 1
					NumLabel.text = str(Num)
				elif _CupObj.Extra_3 == "" and _num > 2:
					_CupObj.Extra_3 = FuncTypePara
					Num -= 1
					NumLabel.text = str(Num)
				elif _CupObj.get("Extra_4") == "" and _num > 3:
					_CupObj.Extra_4 = FuncTypePara
					Num -= 1
					NumLabel.text = str(Num)
				elif _CupObj.get("Extra_5") == "" and _num > 4:
					_CupObj.Extra_5 = FuncTypePara
					Num -= 1
					NumLabel.text = str(Num)
				UseAni.play("use")
				Audio.play(0)
				Liquid_Count = Num
				if not Num:
					CanAni.play("out")
					MixAni.play("init")
					if Holding:
						if SteamLogic.IsMultiplay:
							if _Player.cur_Player == SteamLogic.STEAM_ID:
								GameLogic.Tutorial.call_DropInTrashbin(true)
						else:
							GameLogic.Tutorial.call_DropInTrashbin(true)
				if IsPassDay:
					_CupObj.call_add_PassDay()
				_CupObj.call_add_extra()
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _CUPPATH = _CupObj.get_path()
					var _PLAYERPATH = _Player.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_add_extra_puppet", [_CUPPATH, _PLAYERPATH, Num])
				GameLogic.Tutorial.call_AddIn()
				return true
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	if not IsOpen and not Freshless_bool:
		var _BOOL = return_MoneyBool(body)
		if _BOOL:
			call_Broken()
	GameLogic.Device.call_touch(body, self, false)

func CanMove_Switch(_bool: bool):
	CanMove = _bool

func call_Info_Switch(_Switch: bool):
	match _Switch:
		true:
			if FuncTypePara in ["黑曲奇完整"]:

				return
			$MixNode.show()
			if Num > 0 and CanUse:
				$NumLabel.show()
		false:
			$MixNode.hide()
			$NumLabel.hide()
