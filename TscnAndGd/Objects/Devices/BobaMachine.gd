extends Head_Object
var SelfDev = "BobaMachine"
var HasWater: bool
var WaterType
var WaterCelcius: int = 25
var IsCooking: bool
var IsFreezer: bool
var IsPassDay: bool
var IsBroken: bool

var Liquid_Max: int = 1
var Liquid_Count: int
var cur_ContentNum: int = 0
var CanContent: bool
var ContentType: String
var CookType: int = 0
onready var WaterAni = $AniNode / CookerAni
onready var BobaAni = $AniNode / BobaAni
onready var SteamAni = $AniNode / SteamAni
onready var UseAni = $AniNode / UseAni

onready var FreshAni = $AniNode / Fresh

onready var A_But = $But / A

var cur_TYPE: int
var IsBlackOut: bool

var BasePower: int = 3

func _BlackOut(_Switch):
	IsBlackOut = _Switch

func _ready() -> void :

	call_init(SelfDev)
	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")

	if not GameLogic.is_connected("DayStart", self, "call_puppet"):
		var _con = GameLogic.connect("DayStart", self, "call_puppet")
func call_puppet():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _ARRAY: Array = [Liquid_Count,
		cur_ContentNum,
		WaterAni.assigned_animation,
		BobaAni.assigned_animation,
		ContentType,
		cur_TYPE,
		IsBroken,
		$AniNode / ColorAni.assigned_animation,
		SteamAni.assigned_animation,
		UseAni.assigned_animation,
		]
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_set", [_ARRAY])
func call_puppet_set(_ARRAY):
	Liquid_Count = _ARRAY[0]
	cur_ContentNum = _ARRAY[1]
	if WaterAni.assigned_animation != _ARRAY[2]:
		WaterAni.play(_ARRAY[2])
	if BobaAni.assigned_animation != _ARRAY[3]:
		BobaAni.play(_ARRAY[3])
	ContentType = _ARRAY[4]
	cur_TYPE = _ARRAY[5]
	IsBroken = _ARRAY[6]
	if $AniNode / ColorAni.has_animation(_ARRAY[7]):
		if $AniNode / ColorAni.assigned_animation != _ARRAY[7]:
			$AniNode / ColorAni.play(_ARRAY[7])
	if SteamAni.has_animation(_ARRAY[8]):
		if SteamAni.assigned_animation != _ARRAY[8]:
			SteamAni.play(_ARRAY[8])
	if UseAni.has_animation(_ARRAY[9]):
		if UseAni.assigned_animation != _ARRAY[9]:
			UseAni.play(_ARRAY[9])
	_fressless_check()

func _DayClosedCheck():
	if cur_ContentNum > 0 or Liquid_Count > 0:
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.BOBAMACHINE):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.BOBAMACHINE)
	if Liquid_Count > 0:
		GameLogic.Total_Electricity += BasePower * 8
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
	Liquid_Count = _Info.Liquid_Count
	ContentType = _Info.ContentType
	cur_ContentNum = _Info.cur_ContentNum
	if Liquid_Count > 0:
		WaterAni.play("HasWater")
	if cur_ContentNum > 0:
		BobaAni.play("has")
	if ContentType != "":
		call_ItemColor()
	if cur_ContentNum > 0:
		IsBroken = true
		_fressless_check()

	if Liquid_Count > 0:
		if cur_ContentNum > 0:
			cur_TYPE = 4
		else:
			cur_TYPE = 2
	elif cur_ContentNum > 0:
		if ContentType != "":
			cur_TYPE = 7
		else:
			cur_TYPE = 5
	else:
		cur_TYPE = 0
func _fressless_check():
	if IsBroken:
		FreshAni.play("rot")
	elif IsPassDay:
		FreshAni.play("freshless")
	else:
		FreshAni.play("init")

func return_Water_Logic(_ButID, _DevObj, _Player):


	match _ButID:
		2:
			pass
		0, "A":

			match cur_TYPE:

				5:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_AddSugar()
						return
				0:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if Liquid_Count < Liquid_Max:
						if WaterType != _DevObj.WaterType:
							WaterType = _DevObj.WaterType

							WaterCelcius = _DevObj.WaterCelcius

						if _DevObj.WaterCelcius != WaterCelcius:
							WaterCelcius = (WaterCelcius + _DevObj.WaterCelcius) / 2

						_Water_Logic(1)
						return true
	return false

func call_Cooker_In(_ButID, _OBJ, _Player):

	match _ButID:
		- 2:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				But_Switch(false, _Player)
		- 1:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				$But / A.InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_2)
				But_Switch(true, _Player)
		0:
			if cur_TYPE == 4 and _ButID == 0:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_DropWater()
				return

			var _NAME = _OBJ.get("FuncTypePara")
			match _NAME:
				"boba":
					if _OBJ.get("Used"):
						return
					match cur_TYPE:
						0:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_WaterNotEnough()
								return
						1:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoBoil()
								return
						2:
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							cur_TYPE = 3
							WaterCelcius = 0
							_OBJ.call_used()
							BobaAni.play("in")
							var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
							_AUDIO.play()
							cur_ContentNum = 1
							call_ItemColor()
							if self.get_parent().name in ["ObjNode"]:
								call_Logic()
						_:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
								return
				"白糖":
					if _OBJ.get("Used"):
						return
					match cur_TYPE:
						0:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_WaterNotEnough()
								return

						5:
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
								_AUDIO.play()
								return
							var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
							_AUDIO.play()
							cur_TYPE = 6
							WaterCelcius = 0
							ContentType = "原味珍珠"
							_OBJ.call_used()
							call_Logic()
						_:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
								return
				"黑糖":
					if _OBJ.get("Used"):
						return
					match cur_TYPE:
						0:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_WaterNotEnough()
								return

						5:
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
								_AUDIO.play()
								return
							var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
							_AUDIO.play()
							cur_TYPE = 6
							WaterCelcius = 0
							ContentType = "黑糖珍珠"
							_OBJ.call_used()
							call_Logic()
						_:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
								return


func _Cook_in_puppet(_TYPE):
	match _TYPE:
		"boba":
			cur_TYPE = 3
			WaterCelcius = 0
			BobaAni.play("in")
			var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
			_AUDIO.play()
			call_ItemColor()
		"白糖":
			var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
			_AUDIO.play()
			cur_TYPE = 6
			WaterCelcius = 0
			ContentType = "原味珍珠"
			call_Logic()
		"黑糖":
			var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
			_AUDIO.play()
			cur_TYPE = 6
			WaterCelcius = 0
			ContentType = "黑糖珍珠"
			call_Logic()
func _Water_Logic(_Water: int):
	Liquid_Count += _Water
	if Liquid_Count > Liquid_Max:
		Liquid_Count = Liquid_Max
	if Liquid_Count < 0:
		Liquid_Count = 0

	var _WATERNAME: String = "init"
	match Liquid_Count:
		0:
			pass
		1:
			match cur_TYPE:
				0:
					GameLogic.Total_Electricity += BasePower
					cur_TYPE = 1
					WaterAni.play("WaterIn")
					call_puppet()

func _WaterIn_puppet(_COUNT, _TYPE):
	Liquid_Count = _COUNT
	cur_TYPE = _TYPE
	WaterAni.play("WaterIn")
func call_Wait():
	if $WarningNode.NeedFix:
		WaterAni.play("Fix")
		return
	if IsBlackOut:
		WaterAni.play("Fix")
		return
	match cur_TYPE:
		1:
			IsCooking = false
			WaterAni.play("Wait")
			SteamAni.play("init")
			call_puppet()
		3:
			IsCooking = false
			WaterAni.play("Wait")
			SteamAni.play("play")
			call_puppet()

func call_Logic():
	if $WarningNode.NeedFix:
		WaterAni.play("Fix")
		return
	if IsBlackOut:
		WaterAni.play("Fix")
		return
	match cur_TYPE:

		1, 3:
			IsCooking = true
			WaterAni.play("Cooking")
			call_puppet()
		6:
			IsCooking = true
			WaterAni.play("Cooking")
			call_puppet()

func call_Logic_puppet(_TYPE):
	cur_TYPE = _TYPE
	match cur_TYPE:

		1, 3:
			IsCooking = true
			WaterAni.play("Cooking")
		6:
			IsCooking = true
			WaterAni.play("Cooking")
func call_WaterCelcius_puppet(_TYPE, _CELCIUS):
	cur_TYPE = _TYPE
	WaterCelcius = _CELCIUS
	_CelciusLogic()
func call_WaterCelcius():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if $WarningNode.NeedFix:
		WaterAni.play("Fix")
		return
	if IsBlackOut:
		WaterAni.play("Fix")
		return
	WaterCelcius += 5 * GameLogic.return_Multiplier()

	_CelciusLogic()
func _CelciusLogic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	match cur_TYPE:
		1:
			if WaterCelcius >= 85:
				WaterCelcius = 85
				cur_TYPE = 2
				GameLogic.Total_Electricity += float(BasePower)
				WaterAni.play("Wait_In")
				SteamAni.play("play")
		3:
			if WaterCelcius >= 85:
				WaterCelcius = 85
				cur_TYPE = 4
				GameLogic.Total_Electricity += float(BasePower)
				WaterAni.play("Wait_In")
				SteamAni.play("play")
		6:
			if WaterCelcius >= 85:
				WaterCelcius = 85
				cur_TYPE = 7
				GameLogic.Total_Electricity += float(BasePower)
				WaterAni.play("Finish")
				SteamAni.play("play")
				call_ItemColor()
	call_puppet()

func _CelciusLogic_puppet(_TYPE, _CEL):
	cur_TYPE = _TYPE
	WaterCelcius = _CEL
	match cur_TYPE:
		1:
			if WaterCelcius >= 85:
				WaterCelcius = 85
				cur_TYPE = 2

				WaterAni.play("Wait_In")
				SteamAni.play("play")
		3:
			if WaterCelcius >= 85:
				WaterCelcius = 85
				cur_TYPE = 4

				WaterAni.play("Wait_In")
				SteamAni.play("play")
		6:
			if WaterCelcius >= 85:
				WaterCelcius = 85
				cur_TYPE = 7

				WaterAni.play("Finish")
				SteamAni.play("play")
				call_ItemColor()
func call_ItemColor():
	if $AniNode / ColorAni.has_animation(ContentType):
		$AniNode / ColorAni.play(ContentType)
	else:
		$AniNode / ColorAni.play("init")
func call_Trash():
	if cur_ContentNum > 0:

		cur_ContentNum = 0

		SteamAni.play("init")
		BobaAni.play("init")
		cur_TYPE = 0
		IsBroken = false
		IsPassDay = false
		_fressless_check()
		ContentType = ""
		call_ItemColor()
		call_puppet()
func call_Trash_puppet():
	cur_ContentNum = 0
	SteamAni.play("init")
	BobaAni.play("init")
	cur_TYPE = 0
	IsBroken = false
	IsPassDay = false
	_fressless_check()
	ContentType = ""
	call_ItemColor()
func call_Drop():

	match cur_TYPE:
		1, 2:
			cur_TYPE = 0
			Liquid_Count = 0
			WaterAni.play("WaterOut")
			SteamAni.play("init")
		4:
			cur_TYPE = 5
			Liquid_Count = 0
			WaterAni.play("WaterOut")
			SteamAni.play("play")
	call_puppet()
func call_content_out():

	match cur_TYPE:
		7:
			var _AUDIO = GameLogic.Audio.return_Effect("气泡")
			_AUDIO.play()
			cur_TYPE = 0
			IsCooking = false
			ContentType = ""
			cur_ContentNum = 0
			WaterAni.play("init")
			SteamAni.play("init")
			BobaAni.play("init")
			IsBroken = false
			IsPassDay = false
			_fressless_check()
			call_puppet()

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
func But_Switch(_Switch, _Player):
	$But / Y.hide()
	match _Switch:
		true:
			$But.show()
			if not _Player.Con.IsHold:
				$But / A.InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_1)
			if $WarningNode.NeedFix:
				if _Switch:
					$But / Y.show()
					return
		false:
			$But.hide()
			$But / Y.hide()

	.But_Switch(_Switch, _Player)
func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				return
			But_Switch(false, _Player)

		- 1:
			if not _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				return
			But_Switch(true, _Player)

		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if not _Player.Con.IsHold:
					call_Fix_Logic(_Player)
				return
func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if $WarningNode.return_Fixing(_Player):
		But_Switch(true, _Player)

func call_Fixing_Ani(_Player):
	$AniNode / UseAni.play("init")
	$AniNode / UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
