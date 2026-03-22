extends Head_Object
var SelfDev = "EggRollPot"

var HasContent
var ContentType: String
var WaterCelcius: int = 25
var HasWater: bool
var CanMix: bool
var MixPlayer
var Liquid_Count: int
var Liquid_Max: int = 12
var WaterType
var IsBroken: bool
var IsPassDay: bool
var IsMixing: bool

onready var WaterANI = $AniNode / WaterAni
onready var CookANI = $AniNode / UseAni
onready var A_But = $But / A
onready var X_But = $But / X

onready var MixANI = $MixNode / MixAni
onready var FreshANI = $Effect_flies / Ani

var CanInList: Array = ["蛋卷白", "蛋卷黑"]

func _ready() -> void :
	call_init(SelfDev)
	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	call_MoveLogic()
func call_MoveLogic():
	if IsMixing:
		CanMove = false
	else:
		CanMove = true
func _DayClosedCheck():
	if HasWater or HasContent:
		if WaterType in ["water"] and not HasContent:
			return

		IsBroken = true
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.EGGROLLPOT):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.EGGROLLPOT)
func _collision_check():
	var _parentName = get_parent().name
	if _parentName == "Devices":
		call_Collision_Switch(true)
	elif _parentName == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	self.position = _Info.pos
	if _Info.has("HasWater"):
		HasWater = _Info.HasWater
		HasContent = _Info.HasContent
		ContentType = _Info.ContentType
	if HasWater:
		Liquid_Count = Liquid_Max
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay
	if _Info.has("IsBroken"):
		IsBroken = _Info.IsBroken

	if _Info.has("WaterType"):
		WaterType = _Info.WaterType
		if WaterType in ["water"]:
			call_water_puppet()
	if HasWater and WaterType in ["water"]:
		WaterANI.play("water_in")
	if HasContent:
		if WaterType in ["蛋卷白", "蛋卷黑"]:
			call_Type_init()
		else:
			match ContentType:
				"蛋卷白":
					CookANI.play("white_in")
				"蛋卷黑":
					CookANI.play("black_in")
		IsMixing = false
	if HasWater or HasContent:
		if WaterType in ["water"] and not HasContent:
			pass
		else:

			MixANI.play("init")


	_freshless_logic()
func call_Type_init():
	match WaterType:
		"蛋卷白":
			CookANI.play("white_mix_end")
		"蛋卷黑":
			CookANI.play("black_mix_end")
	if WaterANI.has_animation(str(Liquid_Count)):
		WaterANI.play(str(Liquid_Count))
func _freshless_logic():
	if not HasWater and not HasContent:
		IsBroken = false
		IsPassDay = false
	if IsBroken:
		FreshANI.play("Flies")
	elif IsPassDay:
		FreshANI.play("OverDay")
	else:
		FreshANI.play("init")
func call_Cooker_Logic():
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _bool:
		if _Player.Con.IsHold:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		else:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	if CanMix and get_parent().name == "Weapon_note" and _bool == false:
		_bool = true
		X_But.show()
		A_But.hide()
	else:
		X_But.hide()
		A_But.show()
	.But_Switch(_bool, _Player)

func call_Content_In(_ButID, _PotObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _PotObj.get("Used"):
				return
			if not HasContent:
				if _PotObj.FuncTypePara in CanInList:
					if _PotObj.get("Freshless_bool"):

						return
					But_Switch(true, _Player)
		0, "A":
			if not HasContent:
				if _PotObj.FuncTypePara in CanInList:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if _PotObj.get("Freshless_bool"):

						return
					if _PotObj.get("Used"):
						return
					call_Content_Logic(_PotObj.FuncTypePara, _PotObj.IsPassDay)
					_PotObj.call_used()

func call_Content_Logic(_TYPE, _IsPassDay):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Content_Logic", [_TYPE, _IsPassDay])
	if _IsPassDay:
		IsPassDay = true
	HasContent = true
	ContentType = _TYPE
	_freshless_logic()
	match _TYPE:
		"蛋卷白":
			CookANI.play("white_in")
		"蛋卷黑":
			CookANI.play("black_in")

	IsMixing = false
	var _AUDIO = GameLogic.Audio.return_Effect("轻微掉落")
	_AUDIO.play(0)
	call_Mix_Check()
func call_Mix_Check():
	if HasContent and HasWater and not IsMixing:
		CanMix = true
		if MixANI.assigned_animation in ["init", "hide"]:
			MixANI.play("show")
	else:
		CanMix = false

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func call_Drop():
	if HasWater or HasContent:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Drop")

		HasContent = false
		HasWater = false
		IsBroken = false
		IsPassDay = false
		IsMixing = false
		WaterType = ""
		CanMix = false
		Liquid_Count = 0
		CookANI.play("init")

		WaterANI.play("empty")
		MixANI.play("init")
		var _AUDIO = GameLogic.Audio.return_Effect("倒入水槽")
		_AUDIO.play(0)
		_freshless_logic()
func call_SQUEEZE_SPEED_puppet(_SPEED, _ANIPOS):
	return


func call_Use_Machine():
	Liquid_Count -= 4
	if WaterANI.has_animation(str(Liquid_Count)):
		WaterANI.play(str(Liquid_Count))
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Use_puppet", [Liquid_Count])
	if Liquid_Count <= 0:
		HasContent = false
		HasWater = false
		IsBroken = false
		IsPassDay = false
	_freshless_logic()
func call_Use_puppet(_L):
	Liquid_Count = _L
	if WaterANI.has_animation(str(Liquid_Count)):
		WaterANI.play(str(Liquid_Count))
	if Liquid_Count <= 0:
		HasContent = false
		HasWater = false
		IsBroken = false
		IsPassDay = false
	_freshless_logic()
func return_SQUEEZE_SPEED():
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()


	var _Mult: float = 1
	if is_instance_valid(MixPlayer):
		if MixPlayer.BuffList.has("技能-手速"):
			_Mult += 1
		if MixPlayer.Stat.Skills.has("技能-熟练"):
			_Mult += 1
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		if not MixPlayer.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("工作手套"):
				_Mult += 1
			if GameLogic.cur_Rewards.has("工作手套+"):
				_Mult += 2
		if GameLogic.cur_Event == "手速":
			_Mult = 5

	if _Mult <= 0:
		_Mult = 1
	_SPEED = _SPEED * _Mult

	return _SPEED
func return_STIR_start(_Player):
	var _x = get_parent().name
	if get_parent().name != "Weapon_note":

		return
	if CanMix:

		if is_instance_valid(MixPlayer):
			return
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		MixPlayer = _Player
		CookANI.playback_speed = return_SQUEEZE_SPEED()

		match ContentType:
			"蛋卷白":
				CookANI.play("white_mix")
			"蛋卷黑":
				CookANI.play("black_mix")

		IsMixing = true
		call_MoveLogic()

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PlayerPath = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_start", [CookANI.playback_speed, ContentType, IsMixing, _PlayerPath])
		return true
	return false
func call_puppet_STIR_start(_MIXSPEED, _TYPE, _ISMIX, _PlayerPath):
	IsMixing = _ISMIX
	CookANI.playback_speed = _MIXSPEED
	ContentType = _TYPE
	match ContentType:
		"蛋卷白":
			CookANI.play("white_mix")
		"蛋卷黑":
			CookANI.play("black_mix")
	call_MoveLogic()
	var _Player = get_node(_PlayerPath)
	if is_instance_valid(_Player):
		MixPlayer = _Player
		_Player.Con.call_ArmState(GameLogic.NPC.STATE.STIR)
func call_STIR_end(_Player):

	if MixPlayer == _Player:
		MixPlayer = null

		CookANI.stop(false)
		IsMixing = false
		call_MoveLogic()

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH, MixANI.current_animation_position, MixANI.playback_speed])
func call_puppet_STIR_end(_PATH, _TIME, _SPEED):
	var _Player = get_node(_PATH)
	if is_instance_valid(_Player):
		_Player.call_reset_stat_puppet()
	CookANI.stop(false)
	IsMixing = false
	call_MoveLogic()

func _Mix_Finished():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PATH = MixPlayer.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix_end_puppet", [_PATH])
	match ContentType:
		"蛋卷白":
			WaterType = "蛋卷白"
			CookANI.play("white_mix_end")
		"蛋卷黑":
			WaterType = "蛋卷黑"
			CookANI.play("black_mix_end")

	CanMix = false
	But_Switch(false, MixPlayer)
	call_STIR_end(MixPlayer)

	Liquid_Count = Liquid_Max
	MixANI.play("init")


func call_Mix_end_puppet(_PATH):
	var _PLAYER = get_node(_PATH)
	match ContentType:
		"蛋卷白":
			WaterType = "蛋卷白"
			CookANI.play("white_mix_end")
		"蛋卷黑":
			WaterType = "蛋卷黑"
			CookANI.play("black_mix_end")

	CanMix = false

	Liquid_Count = 12
	MixANI.play("init")
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
	But_Switch(false, _PLAYER)
func call_player_leave(_PLAYER):
	if MixPlayer == _PLAYER:
		call_STIR_end(MixPlayer)

func call_Water_Out(_NUM):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_Out_puppet")
	Liquid_Count = 0
	HasWater = false
	HasContent = false
	IsBroken = false
	IsPassDay = false
	_freshless_logic()
	WaterANI.play("empty")

	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
func call_Water_Out_puppet():
	Liquid_Count = 0
	HasWater = false
	HasContent = false
	WaterANI.play("empty")

	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func call_Water_In(_ButID, _DevOBJ, _Player):
	match _ButID:
		- 2:
			_DevOBJ.call_WaterInPort( - 2, self, _Player)

		- 1:

			_DevOBJ.call_WaterInPort( - 1, self, _Player)

		0:
			if not HasWater:

				if _DevOBJ.get_node("WarningNode").NeedFix:
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					_DevOBJ.call_WaterInPort( - 1, self, _Player)
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "call_water_puppet")
				_DevOBJ.call_Water_Out(10)
				call_water_puppet()
				_DevOBJ.call_WaterInPort( - 1, self, _Player)
				return true
		3:
			if HasWater or HasContent:
				var _return = _DevOBJ.call_WaterDrop(_ButID, self, _Player)
				_DevOBJ.call_WaterInPort( - 1, self, _Player)
				return _return
func call_water_puppet():
	HasWater = true
	WaterCelcius = 25
	Liquid_Count = 10
	WaterType = "water"
	WaterANI.play("water_in")
	call_Mix_Check()

func call_Sugar_In(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not HasContent:
				match _HoldObj.FuncTypePara:
					"黑糖", "白糖":
						But_Switch(true, _Player)
		0:
			if not HasContent:
				match _HoldObj.FuncTypePara:
					"黑糖":
						if _HoldObj.Used:
							return
						CookANI.play("黑糖_加入")
						HasContent = true
						ContentType = _HoldObj.FuncTypePara
						_HoldObj.call_used()

						call_Sugar_In( - 2, _HoldObj, _Player)
					"白糖":
						if _HoldObj.Used:
							return
						CookANI.play("白糖_加入")
						HasContent = true
						ContentType = _HoldObj.FuncTypePara
						_HoldObj.call_used()

						call_Sugar_In( - 2, _HoldObj, _Player)
					_:
						return
