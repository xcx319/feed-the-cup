extends Head_Object
var SelfDev = "BigPot"
var HasWater: bool
var WaterType
var WaterCelcius: int = 25 setget _WaterCelcius_Set
var IsCooking: bool

var CookBaseMult: float = 1
var CookPro: int = 0
var IsFreezer: bool
var IsPassDay: bool
var IsBroken: bool
var Liquid_Max: int = 2
var Liquid_Count: int
var cur_ContentNum: int = 0
var CanContent: bool
var ContentType: String
var CookType: int = 0
onready var WaterAni = $AniNode / WaterAni
onready var PotAni = $AniNode / PotAni
onready var HotAni = $AniNode / HotAni
onready var CelciusAni = $AniNode / CelciusAni
onready var CookAni = $AniNode / CookAni
onready var CookTimeAni = $Cook / AnimationPlayer
onready var FreshAni = $AniNode / Fresh

onready var A_But = $But / A
onready var X_But = $But / X
onready var CelciusBar = $Celcius

onready var ItemNode = $TexNode / InsideNode / Item
onready var ITEMOBJ = null
var cur_TYPE: int
var _TEABAGLIST: Array = ["红茶包", "绿茶包", "乌龙茶包", "花茶包", "枸杞茶包", "白茶包"]

var _PlayerList: Array

func _WaterCelcius_Set(_CelciusAdd):
	IsCooking = true
	WaterCelcius = _CelciusAdd
	if cur_TYPE == 1 and WaterCelcius >= 100:
		cur_TYPE = 2
	if cur_ContentNum > 0:
		match CookType:
			0:
				if WaterCelcius >= 100:

					match CookPro:
						0:
							CookPro = 1
			1:
				if WaterCelcius >= 85 and WaterCelcius < 100:
					match CookPro:
						0:
							CookPro = 1
				pass
			2:
				if WaterCelcius < 85:
					match CookPro:
						0:
							CookPro = 1


func _ready() -> void :

	call_init(SelfDev)
	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():
	if cur_TYPE == 3:
		cur_TYPE = 4
		_Content_To_WaterType()
	if ContentType in ["葡萄"]:
		return
	if ContentType in ["葡萄块"]:
		if not IsFreezer:
			IsBroken = true
		else:
			if not IsPassDay:
				IsPassDay = true
			else:
				IsBroken = true
		if not IsFreezer:
			if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.BIGPOT):
				GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.BIGPOT)
	elif cur_ContentNum > 0 and not CanX:

		if not IsFreezer:
			IsBroken = true
		else:
			if not IsPassDay:
				IsPassDay = true
			else:
				IsBroken = true
		if not IsFreezer:
			if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.BIGPOT):
				GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.BIGPOT)
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
	Liquid_Count = _Info["Liquid_Count"]
	match Liquid_Count:
		1:
			WaterAni.play("Water_1")
			HasWater = true
		2:
			WaterAni.play("Water_2")
			HasWater = true
	cur_ContentNum = _Info["cur_ContentNum"]
	cur_TYPE = _Info["cur_TYPE"]
	if cur_TYPE == 3:
		cur_TYPE = 4
	if _Info.has("ContentType"):
		ContentType = _Info["ContentType"]
		match ContentType:
			"葡萄块":
				PotAni.play("葡萄块")
			"葡萄":
				PotAni.play("葡萄")
				CanX = true
			"芋头块":
				match cur_ContentNum:
					1:
						PotAni.play("鲜芋1")
					2:
						PotAni.play("鲜芋2")
			"西米":
				match cur_ContentNum:
					1:
						PotAni.play("西米1")
					2:
						PotAni.play("西米2")
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay
		IsBroken = _Info.IsBroken
		IsFreezer = _Info.IsFreezer

	if _Info.has("WaterCelcius"):
		WaterCelcius = _Info.WaterCelcius
		if get_parent().name != "SavedNode" or Liquid_Count == 0:
			WaterCelcius = 25
	if _Info.has("ITEMOBJ"):
		if _Info.ITEMOBJ != null:
			var _EXTRAINFO = _Info.ITEMOBJ
			if _EXTRAINFO.has("Liquid_Count"):
				var _BottleObj = GameLogic.TSCNLoad.Bottle_TSCN.instance()
				var _NAME = _EXTRAINFO.NAME
				_BottleObj._SELFID = int(_EXTRAINFO.NAME)
				_BottleObj.name = _NAME
				_BottleObj.position = Vector2.ZERO

				ItemNode.add_child(_BottleObj)
				_BottleObj.call_load(_EXTRAINFO)
				ITEMOBJ = _BottleObj
				CanX = true
			else:
				var _ExtraObj = GameLogic.TSCNLoad.Bag_TSCN.instance()
				var _NAME = _EXTRAINFO.NAME
				_ExtraObj._SELFID = int(_EXTRAINFO.NAME)
				_ExtraObj.name = _NAME
				_ExtraObj.position = Vector2.ZERO
				_ExtraObj.call_Collision_Switch(false)
				ItemNode.add_child(_ExtraObj)
				_ExtraObj.call_load_TSCN(_EXTRAINFO.TypeStr)
				ITEMOBJ = _ExtraObj

	if _Info.has("WaterType"):
		WaterType = _Info.WaterType
		if WaterType == "":
			WaterType = "water"
		var _color8 = GameLogic.Liquid.return_color_set(WaterType)
		if _color8:
			$TexNode / InsideNode / Water.set_modulate(_color8)
	if cur_ContentNum > 0:
		if not ContentType in ["葡萄"]:
			CookAni.play("overcook")

	if Liquid_Count > 0 and WaterType != "water":
		CookAni.play("overcook")
		IsBroken = true
	else:
		IsBroken = false
	_fressless_check()
func _fressless_check():
	if IsBroken:
		FreshAni.play("rot")
	elif IsPassDay:
		FreshAni.play("freshless")
	else:
		FreshAni.play("init")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_fressless_puppet", [IsBroken, IsPassDay])
func call_fressless_puppet(_BROKEN, _PASSDAY):
	IsPassDay = _PASSDAY
	IsBroken = _BROKEN
	if IsBroken:
		FreshAni.play("rot")
	elif IsPassDay:
		FreshAni.play("freshless")
	else:
		FreshAni.play("init")
func call_ColdTimer():

	IsCooking = false
	match ContentType:
		"绿茶包", "白茶包":
			$ColdTimer.wait_time = 0.4 * GameLogic.return_Multiplier()
		_:
			if WaterCelcius >= 85:
				$ColdTimer.wait_time = 6 * GameLogic.return_Multiplier()
			else:
				$ColdTimer.wait_time = 3 * GameLogic.return_Multiplier()
	$ColdTimer.start(0)
	if Liquid_Count:
		call_Cook_Logic()

var IsDefrost: bool
var CanX: bool
func call_Defrost_Logic():
	if cur_ContentNum > 0 and Liquid_Count > 0 and CanX:
		if is_instance_valid(ITEMOBJ):
			if ITEMOBJ.get("IsFrozen"):

				X_But.show()
				if ITEMOBJ.has_method("call_Defrost_Switch"):
					ITEMOBJ.call_Defrost_Switch(2)

func call_Defrost_puppet(_PLAYERPATH, _OBJPATH):
	var _Player = get_node(_PLAYERPATH)
	var _HoldObj = get_node(_OBJPATH)

	if _HoldObj.get_parent().name == "Weapon_note":
		_Player.Stat.call_carry_off()
	elif _HoldObj.get_parent().name == "ObjNode":
		_HoldObj.get_parent().get_parent().OnTableObj = null
	_HoldObj.get_parent().remove_child(_HoldObj)
	_HoldObj.position = Vector2.ZERO
	_HoldObj.call_Collision_Switch(false)
	ItemNode.add_child(_HoldObj)
	ITEMOBJ = _HoldObj
	cur_ContentNum = 1
	CanX = true
	_HoldObj.But_Switch(false, _Player)
	But_Switch(true, _Player)

	PotAni.play("加入瓶子")
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)
	call_Defrost_Logic()

func call_Defrost(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if cur_ContentNum == 0 and not _HoldObj.get("IsOpen"):
				But_Switch(true, _Player)
		0, "A":
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if cur_ContentNum == 0 and not _HoldObj.get("IsOpen"):

				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAYERPATH = _Player.get_path()
					var _OBJPATH = _HoldObj.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Defrost_puppet", [_PLAYERPATH, _OBJPATH])
				if _HoldObj.get_parent().name == "Weapon_note":
					_Player.Stat.call_carry_off()
				elif _HoldObj.get_parent().name == "ObjNode":
					_HoldObj.get_parent().get_parent().OnTableObj = null
				_HoldObj.get_parent().remove_child(_HoldObj)
				_HoldObj.position = Vector2.ZERO
				_HoldObj.call_Collision_Switch(false)
				ItemNode.add_child(_HoldObj)
				ITEMOBJ = _HoldObj
				cur_ContentNum = 1
				CanX = true
				_HoldObj.But_Switch(false, _Player)
				But_Switch(true, _Player)

				PotAni.play("加入瓶子")
				var _AUDIO = GameLogic.Audio.return_Effect("气泡")
				_AUDIO.play(0)
				call_Defrost_Logic()

				return true

			elif ContentType == "":
				return
			elif _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_NoBoil()
				return
		2:
			if ContentType in ["葡萄"] and CanX:
				call_Grape_Peel(_Player)


				pass
			elif CanX:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if _Player.Con.IsHold:
					return
				GameLogic.Device.call_Player_Pick(_Player, ITEMOBJ)
				if ITEMOBJ.has_method("call_Defrost_Switch"):
					ITEMOBJ.call_Defrost_Switch(0)
				But_Switch(true, _Player)
				ITEMOBJ = null
				cur_ContentNum = 0
				CanX = false

func call_Pot_In(_ButID, _PotObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if cur_ContentNum < Liquid_Count and CanContent and not _PotObj.get("Used"):
				But_Switch(true, _Player)
		0, "A":
			match Liquid_Count:
				0:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_WaterNotEnough()
					return
				_:
					if _PotObj.get("IsBroken"):
						return
					var _c = _PotObj.FuncTypePara
					if _PotObj.FuncTypePara in ["西米"]:
						if cur_TYPE in [2, 3]:


							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							if cur_ContentNum < Liquid_Count and not _PotObj.get("Used"):
								if ContentType != "":
									if ContentType != _PotObj.FuncTypePara:
										return
								CookType = 0
								Call_Content_Logic(_PotObj.FuncTypePara)

								if get_parent().name == "SavedNode":
									pass
								_PotObj.call_used()
					elif _PotObj.FuncTypePara in _TEABAGLIST:
						var _CanADD: bool = false
						match _PotObj.FuncTypePara:
							"花茶包", "枸杞茶包":
								if cur_TYPE in [1, 2]:
									if WaterCelcius < 85:
										_CanADD = true
										CookType = 2
									else:
										if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
											_Player.call_Say_TooHot()
											return
							"红茶包", "乌龙茶包":
								if cur_TYPE in [1, 2]:

									if WaterCelcius >= 100:
										_CanADD = true
										CookType = 0
									else:
										if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
											_Player.call_Say_NoBoil()
											return
								if cur_TYPE in [0]:
									if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
										_Player.call_Say_WaterNotEnough()
										return
							"绿茶包", "白茶包":

								if cur_TYPE in [1, 2]:
									if WaterCelcius >= 85 and WaterCelcius < 100:
										_CanADD = true
										CookType = 1
									elif WaterCelcius < 85:
										if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
											_Player.call_Say_NoBoil()
											return
									elif WaterCelcius >= 100:
										if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
											_Player.call_Say_TooHot()
											return
						if _CanADD:
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							if Liquid_Count == 2 and cur_ContentNum == 0:
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									var _PLAYERPATH = _Player.get_path()
									var _OBJPATH = _PotObj.get_path()
									SteamLogic.call_puppet_id_sync(_SELFID, "call_TeaBag_puppet", [_PLAYERPATH, _OBJPATH])
								if _PotObj.get_parent().name == "Weapon_note":
									_Player.Stat.call_carry_off()
								elif _PotObj.get_parent().name == "ObjNode":
									_PotObj.get_parent().get_parent().OnTableObj = null
								_PotObj.get_parent().remove_child(_PotObj)
								_PotObj.position = Vector2.ZERO
								_PotObj.call_Collision_Switch(false)
								ItemNode.add_child(_PotObj)
								ITEMOBJ = _PotObj
								Call_Content_Logic(_PotObj.FuncTypePara)
								return true
							elif Liquid_Count < 2:
								if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
									_Player.call_Say_WaterNotEnough()
									return
							else:
								return
					elif _PotObj.FuncType in ["WorkBoard"]:
						if _PotObj.ItemType in ["芋头块"]:
							var _CanADD: bool = false
							if ContentType != "":
								if ContentType != _PotObj.ItemType:
									return
							if not cur_TYPE in [2, 3]:
								if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
									_Player.call_Say_NoUse()
								return
							if WaterCelcius >= 100:
								CookType = 0
								_CanADD = true
							else:
								if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
									_Player.call_Say_NoBoil()
									return
							if _CanADD:
								if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
									return
								if cur_ContentNum < Liquid_Count:
									CookType = 0
									Call_Content_Logic(_PotObj.ItemType)
									if _PotObj.IsBroken:
										IsBroken = true
									if _PotObj.IsPassDay:
										IsPassDay = true
									_fressless_check()
									_PotObj.call_clear()
func call_TeaBag_puppet(_PLAYERPATH, _OBJPATH):
	var _Player = get_node(_PLAYERPATH)
	var _PotObj = get_node(_OBJPATH)
	if _PotObj.get_parent().name == "Weapon_note":
		_Player.Stat.call_carry_off()
	elif _PotObj.get_parent().name == "ObjNode":
		_PotObj.get_parent().get_parent().OnTableObj = null
	_PotObj.get_parent().remove_child(_PotObj)
	_PotObj.position = Vector2.ZERO
	_PotObj.call_Collision_Switch(false)
	ItemNode.add_child(_PotObj)
	ITEMOBJ = _PotObj
func return_Water_Logic(_ButID, _DevObj, _Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if ContentType in ["葡萄块", "葡萄"]:
		return
	match _ButID:
		0, "A":

			match cur_TYPE:


				0, 1, 2:
					if Liquid_Count < Liquid_Max:
						if WaterType != _DevObj.WaterType:
							WaterType = _DevObj.WaterType

							WaterCelcius = _DevObj.WaterCelcius

						if _DevObj.WaterCelcius != WaterCelcius:
							WaterCelcius = (WaterCelcius + _DevObj.WaterCelcius) / 2
						CelciusBar.value = WaterCelcius

						_Water_Logic(1)
						return true
					else:
						return false
	return false

func call_Water_Out(_OutNum):
	_Water_Logic(Liquid_Count * - 1)
func call_Drop():
	if HasWater:
		call_Water_Out(Liquid_Count)

func call_Content_puppet(_TYPE, _NUM, _CELCIUS, _TimerMult):
	ContentType = _TYPE
	cur_ContentNum = _NUM
	WaterCelcius = _CELCIUS
	if cur_ContentNum == 2:
		CookTimeAni.play("init")
		CookTimeAni.play("cook")
	CookTimeAni.playback_speed = _TimerMult
	_Content_Ani()
func Call_Content_Logic(_TYPENAME):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if ContentType != _TYPENAME:
		ContentType = _TYPENAME
		if CookPro == 0:
			CookPro = 1
	match Liquid_Count:
		1:
			if cur_ContentNum == 0:
				cur_ContentNum = 1

		2:
			if cur_ContentNum == 1:
				cur_ContentNum = 2
				CookTimeAni.play("init")
				CookTimeAni.play("cook")

			elif cur_ContentNum == 0:
				cur_ContentNum = 1
	var _TimerMult: float = 1
	if ContentType in _TEABAGLIST:
		_TimerMult = 0.5
	if ContentType in ["芋头块"]:
		_TimerMult = 0.5
	if ContentType in ["花茶包"]:
		_TimerMult = 0.4
	if ContentType in ["枸杞茶包"]:
		_TimerMult = 0.3
	_TimerMult = _TimerMult / GameLogic.return_Multiplier()
	CookTimeAni.playback_speed = _TimerMult
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Content_puppet", [ContentType, cur_ContentNum, WaterCelcius, _TimerMult])
	call_Cook_Logic()
	_Content_Ani()
func _Content_Ani():
	var _ANINAME: String = ""
	if ContentType in _TEABAGLIST:
		match cur_ContentNum:
			1:
				_ANINAME = "加入茶包_1"
				var _AUDIO = GameLogic.Audio.return_Effect("气泡")
				_AUDIO.play(0)
	else:
		match ContentType:
			"芋头块":
				match cur_ContentNum:
					1:
						if Liquid_Count == 0:
							_ANINAME = "鲜芋-1"
						else:
							_ANINAME = "加入芋头块_1"
						var _AUDIO = GameLogic.Audio.return_Effect("气泡")
						_AUDIO.play(0)
					2:
						_ANINAME = "加入芋头块_2"
						var _AUDIO = GameLogic.Audio.return_Effect("气泡")
						_AUDIO.play(0)
			"西米":
				match cur_ContentNum:
					1:
						if Liquid_Count == 0:
							_ANINAME = "西米-1"
						else:
							_ANINAME = "加入西米_1"
						var _AUDIO = GameLogic.Audio.return_Effect("气泡")
						_AUDIO.play(0)
					2:
						_ANINAME = "加入西米_2"
						var _AUDIO = GameLogic.Audio.return_Effect("气泡")
						_AUDIO.play(0)
	match cur_ContentNum:
		0:
			PotAni.play("init")
		_:
			if PotAni.has_animation(_ANINAME):
				PotAni.play(_ANINAME)
	match cur_TYPE:
		0:
			CelciusAni.play("init")
			CookAni.play("init")
			CookTimeAni.play("init")
func call_Water_puppet(_WATERTYPE, _TYPE, _LIQUID, _CELCIUS, _WATERANINAME):
	if WaterType != _WATERTYPE:
		WaterType = _WATERTYPE

	WaterCelcius = _CELCIUS
	cur_TYPE = _TYPE
	Liquid_Count = _LIQUID
	if Liquid_Count == 0:
		WaterCelcius = 25
		WaterType = ""
		HasWater = false
		if cur_ContentNum == 0:
			IsPassDay = false
			IsBroken = false
		_fressless_check()
	WaterAni.play(_WATERANINAME)
	call_WaterCelcius_change()
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
func _Water_Logic(_Water: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	Liquid_Count += _Water
	if Liquid_Count > Liquid_Max:
		Liquid_Count = Liquid_Max
	if Liquid_Count < 0:
		Liquid_Count = 0

	var _WATERNAME: String = "init"
	match Liquid_Count:
		0:
			WaterCelcius = 25

			WaterType = ""
			HasWater = false
			if cur_ContentNum == 0:
				IsPassDay = false
				IsBroken = false
			if _Water == - 1:
				_WATERNAME = "Water_1_Out"
				WaterAni.play("Water_1_Out")
				var _AUDIO = GameLogic.Audio.return_Effect("倒入水槽")
				_AUDIO.play(0)
			elif _Water == - 2:
				_WATERNAME = "WaterOut_2"
				WaterAni.play("WaterOut_2")
				var _AUDIO = GameLogic.Audio.return_Effect("倒入水槽")
				_AUDIO.play(0)
			else:
				_WATERNAME = "init"
				WaterAni.play("init")
			_fressless_check()
		1:

			if _Water == - 1:
				_WATERNAME = "WaterOut_2"
				WaterAni.play("WaterOut_2")
				var _AUDIO = GameLogic.Audio.return_Effect("倒入水槽")
				_AUDIO.play(0)
				HasWater = false
			else:
				_WATERNAME = "Water_1"
				WaterAni.play("Water_1")
				var _AUDIO = GameLogic.Audio.return_Effect("倒水")
				_AUDIO.play(0)
				HasWater = true
			if cur_TYPE == 0:
				cur_TYPE = 1
		2:
			HasWater = true
			_WATERNAME = "Water_2"
			WaterAni.play("Water_2")
			var _AUDIO = GameLogic.Audio.return_Effect("倒水")
			_AUDIO.play(0)
			if cur_TYPE == 0:
				cur_TYPE = 1

	call_WaterCelcius_change()
	call_Cook_Logic()
	call_Defrost_Logic()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_puppet", [WaterType, cur_TYPE, Liquid_Count, WaterCelcius, _WATERNAME])
func call_WaterCelcius_change():


	if WaterCelcius < 85:
		CelciusBar.max_value = 85
		CelciusBar.min_value = 25

	if WaterCelcius >= 85:
		CelciusBar.max_value = 100
		CelciusBar.min_value = 85
	CelciusBar.value = WaterCelcius

	if WaterCelcius >= 100:
		WaterCelcius = 100
		HotAni.play("hot")
	elif WaterCelcius >= 85:
		HotAni.play("hot")

	else:
		match ContentType:
			"西米", "芋头块":
				if cur_ContentNum > 0 and cur_ContentNum < Liquid_Count:
					CanContent = true
				else:
					CanContent = false
			_:
				if cur_ContentNum > 0:
					CanContent = false
				else:
					CanContent = true
		HotAni.play("init")
	call_Cook_Logic()
func call_Fresh_Logic():
	if cur_ContentNum == 0 and Liquid_Count == 0:
		IsBroken = false
		IsPassDay = false
		cur_TYPE = 0

	_fressless_check()
func call_clean_puppet():
	cur_ContentNum = 0
	call_content_out()
	call_Fresh_Logic()
func call_clean():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_clean_puppet")
	cur_ContentNum = 0
	call_content_out()
	call_Fresh_Logic()
func call_content_out():
	if cur_ContentNum > 0:
		cur_ContentNum -= 1

	call_Cook_Logic()
	for _NODE in ItemNode.get_children():
		ItemNode.remove_child(_NODE)
		_NODE.queue_free()
	ITEMOBJ = null
	_Content_Ani()
	call_Fresh_Logic()
func call_Cook_Logic():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	if IsBroken:
		return
	if cur_ContentNum <= 0 and Liquid_Count == 0:

		ContentType = ""
		cur_TYPE = 0
		CookPro = 0
	elif Liquid_Count == 0 and cur_ContentNum > 0:
		if ContentType in ["葡萄", "葡萄块"]:
			return
		if ContentType in ["西米", "芋头块", "鲜芋"]:
			if ContentType == "芋头块":
				ContentType = "鲜芋"
			if CookPro == 2:
				cur_TYPE = 6
			else:
				CookPro = 3
		else:
			if ContentType != "":
				CookPro = 3
			else:
				cur_TYPE = 0
				CookPro = 0




	match CookType:
		0:
			match CookPro:
				0:
					CookAni.play("init")
					CookTimeAni.play("init")
				1:
					if IsCooking:
						if cur_ContentNum > 0 and Liquid_Count > 0:
							if CookAni.assigned_animation != "cook":
								CookAni.play("cook")
								cur_TYPE = 3
							CookTimeAni.play("cook")
						else:
							CookTimeAni.stop(false)
							if Liquid_Count > 0:
								CookAni.play("overcook")

					else:
						CookTimeAni.stop(false)
				2:
					if IsCooking:
						if cur_ContentNum > 0 and Liquid_Count > 0:
							if CookAni.assigned_animation != "cookfinish":
								CookAni.play("cookfinish")
								cur_TYPE = 4
								_Content_To_WaterType()
							CookTimeAni.play("cookfinish")
						else:
							CookTimeAni.stop(false)
							if Liquid_Count > 0:
								CookAni.play("finish")
					else:
						CookTimeAni.stop(false)
						if Liquid_Count > 0:
							if CookAni.assigned_animation == "cookfinish":
								CookAni.play("finish")
				3:
					cur_TYPE = 5

		1:
			match CookPro:
				0:
					CookAni.play("init")
					CookTimeAni.play("init")
				1:
					if cur_ContentNum > 0 and Liquid_Count > 0:
						if WaterCelcius >= 100:
							CookPro = 3
							call_Cook_Logic()
							return

						if CookAni.assigned_animation != "cook":
							CookAni.play("cook")
							cur_TYPE = 3
						CookTimeAni.play("cook")
					else:
						if Liquid_Count > 0:
							CookAni.play("overcook")
						CookTimeAni.stop(false)
				2:
					if cur_ContentNum > 0 and Liquid_Count > 0:

						if CookAni.assigned_animation != "cookfinish":
							CookAni.play("cookfinish")
							cur_TYPE = 4
						CookTimeAni.play("cookfinish")
					else:
						if Liquid_Count > 0:
							CookAni.play("finish")
						CookTimeAni.stop(false)
				3:
					cur_TYPE = 5

		2:
			match CookPro:
				0:
					CookAni.play("init")
					CookTimeAni.play("init")
				1:
					if cur_ContentNum > 0 and Liquid_Count > 0:
						if WaterCelcius >= 85:
							CookPro = 3
							call_Cook_Logic()
							return

						if CookAni.assigned_animation != "cook":
							CookAni.play("cook")
							cur_TYPE = 3
						CookTimeAni.play("cook")
					else:
						if Liquid_Count > 0:
							CookAni.play("overcook")
						CookTimeAni.stop(false)
				2:
					if cur_ContentNum > 0 and Liquid_Count > 0:

						if CookAni.assigned_animation != "cookfinish":
							CookAni.play("cookfinish")
							cur_TYPE = 4
						CookTimeAni.play("cookfinish")
					else:
						if Liquid_Count > 0:
							CookAni.play("finish")
						CookTimeAni.stop(false)
				3:
					cur_TYPE = 5

	match cur_TYPE:
		5:
			CookAni.play("overcook")
			CookTimeAni.play("init")
		6:
			CookAni.play("finish")
			CookTimeAni.play("init")

	_CookAni()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CookAni_puppet",
		[cur_TYPE, CookPro, ContentType, CelciusAni.assigned_animation,
		CookAni.assigned_animation,
		CookTimeAni.assigned_animation,
		CookTimeAni.is_playing(),
		CookTimeAni.playback_speed,
		])
func call_Water_Color():
	if cur_TYPE in [5, 6]:
		return
	if WaterType == "":
		WaterType = "water"
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	if _color8:
		$TexNode / InsideNode / Water.set_modulate(_color8)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_WaterColor_puppet", [WaterType])
func call_WaterColor_puppet(_WATERTYPE):
	WaterType = _WATERTYPE
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	if _color8:
		$TexNode / InsideNode / Water.set_modulate(_color8)
func call_CookAni_puppet(_TYPE, _PRO, _CONTENT, _CelciusAni, _CookAni, _CookTimeAni, _CookTimeAniBool, _SPEED):

	cur_TYPE = _TYPE
	CookPro = _PRO
	ContentType = _CONTENT
	CookTimeAni.playback_speed = _SPEED
	if CelciusAni.assigned_animation != _CelciusAni:
		CelciusAni.play(_CelciusAni)
	if CookAni.assigned_animation != _CookAni:
		CookAni.play(_CookAni)
	if _CookTimeAniBool:
		if CookTimeAni.has_animation(_CookTimeAni):
			CookTimeAni.play(_CookTimeAni)
	else:
		CookTimeAni.stop(false)
	call_Water_Color()
func _CookAni():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not cur_TYPE in [5, 6]:
		if WaterCelcius < 85:
			if CelciusAni.assigned_animation != "cold":
				CelciusAni.play("cold")
		elif WaterCelcius < 100:
			if CelciusAni.assigned_animation != "hot":
				CelciusAni.play("hot")
		elif WaterCelcius >= 100:
			if CelciusAni.assigned_animation != "boiling":
				CelciusAni.play("boiling")

	match cur_TYPE:
		0:
			if CelciusAni.assigned_animation != "init":
				CelciusAni.play("init")
	call_Water_Color()

func _Content_To_WaterType():
	match ContentType:
		"花茶包":
			WaterType = "tealeaf_flower"
		"枸杞茶包":
			WaterType = "tealeaf_wolfberry"
		"红茶包":
			WaterType = "tealeaf_red"
		"绿茶包":
			WaterType = "tealeaf_green"
		"乌龙茶包":
			WaterType = "tealeaf_oolong"
		"白茶包":
			WaterType = "tealeaf_white"
	call_Water_Color()
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	if _bool:
		if not _Player.Con.IsHold:
			if CanX:
				X_But.show()
			if ContentType in ["葡萄"]:
				X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_1)
			elif ContentType in ["葡萄块"]:
				X_But.hide()
			else:
				X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_Str)
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		else:
			X_But.hide()
			if cur_ContentNum < Liquid_Count and CanContent and Liquid_Count > 0:

				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
			else:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)


	.But_Switch(_bool, _Player)

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func _on_ColdTimer_timeout():
	if not IsCooking:
		$ColdTimer.stop()
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		$ColdTimer.stop()
		return

	if cur_TYPE in [4, 5, 6]:

		$ColdTimer.stop()
		return
	call_Cook_Logic()

func call_Celcius_puppet(_Celcius):
	WaterCelcius = _Celcius
	call_WaterCelcius_change()

func call_cook_end():
	if CookPro == 1:
		CookPro = 2
	_Content_To_WaterType()
	call_Cook_Logic()
func call_cookfinish_end():
	if CookPro == 2:
		CookPro = 3
	call_Cook_Logic()

func call_Fruit_In(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			if HasWater or ContentType != "":
				return
			if _HoldObj.get("IsBroken"):
				return
			match _HoldObj.get("TypeStr"):
				"葡萄":

					call_Grape_In()
					_HoldObj.call_del()
					_Player.Stat.call_carry_off()
					But_Switch(true, _Player)
					return true
	pass

func call_Grape_In():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Grape_In")
	PotAni.play("葡萄")
	ContentType = "葡萄"
	cur_ContentNum += 1
	cur_TYPE = 7
	CanX = true
func call_Grape_Peel(_PLAYER):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _PLAYERPATH = _PLAYER.get_path()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Grape_Peel_Logic", [_PLAYERPATH])

	call_Grape_Peel_Logic(_PLAYERPATH)
func call_Grape_Peel_Logic(_PLAYERPATH):
	var _PLAYER = get_node(_PLAYERPATH)
	CanX = false
	PotAni.play("葡萄去皮")
	if not _PlayerList.has(_PLAYER):
		_PlayerList.append(_PLAYER)
	_PLAYER.call_Working_Start()

func call_Grape_finish():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Grape_finish_puppet")
	call_Grape_finish_puppet()
func call_Grape_finish_puppet():
	ContentType = "葡萄块"
	var _NUM = _PlayerList.size()
	for _i in _NUM:
		var _PLAYER = _PlayerList.pop_front()
		_PLAYER._on_OrderTimer_timeout()
	X_But.hide()

func call_Fruit_Out(A_Box, _Player):
	var _return = A_Box.call_PutInBox(0, self, _Player)

	if _return:
		But_Switch(true, _Player)
		var _AUDIO = GameLogic.Audio.return_Effect("气泡")
		_AUDIO.play(0)
	return _return
	pass
