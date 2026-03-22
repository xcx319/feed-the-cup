extends Head_Object
var SelfDev = "CreamMachine"

var CreamBool: bool
var CreamTYPE: int = 0
var MixFinishBool: bool
var OverBool: bool
var CanEnd: bool
var Liquid_Count: int = 0
var Liquid_Max: int = 10
var WaterType: String
var IsPassDay: bool
var IsBroken: bool
var IsOpen: bool
onready var WarningNode = get_node("WarningNode")
var IsBlackOut: bool = false
func But_Switch(_bool, _Player):
	if _Player.Con.IsHold:
		var _OBJ = instance_from_id(_Player.Con.HoldInsId)
		var _Func = _OBJ.get("FuncType")
		var A_But = $But / A
		if _Func in ["Cooker", "Bottle"]:

			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			A_But.show()
		else:
			A_But.hide()
	elif CanMove:
		var A_But = $But / A
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		A_But.show()
	else:
		var A_But = $But / A
		A_But.hide()


	if CreamTYPE > 0 and Liquid_Count > 0:
		var X_But = $But / X
		if Liquid_Count > 0:
			X_But.show()
			if IsOpen:
				X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_1)
			else:
				X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_Str)
	else:
		var X_But = $But / X
		X_But.hide()
	if WarningNode.NeedFix:
		$But / Y.show()
	else:
		$But / Y.hide()

	.But_Switch(_bool, _Player)
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	if IsBlackOut:
		call_Mix(false)
func _DayClosedCheck():
	if Liquid_Count > 0:
		if not IsPassDay:
			IsPassDay = true
		else:
			IsBroken = true
func _collision_check():
	if not self.is_inside_tree():
		return
	var _parentName = get_parent().name
	if _parentName == "Devices":
		call_Collision_Switch(true)
	elif _parentName == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
func _ready() -> void :
	call_init(SelfDev)
	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("CreamBool"):
		CreamBool = _Info.CreamBool
		if CreamBool:
			$AniNode / WaterAni.play("Cream")
	if _Info.has("CreamTYPE"):
		$AniNode / MixAni.playback_speed = 1
		CreamTYPE = _Info.CreamTYPE
		match CreamTYPE:
			1:
				$AniNode / MixAni.play("芝士")
			2:
				$AniNode / MixAni.play("海盐")
	if _Info.has("MixFinishBool"):
		MixFinishBool = _Info.MixFinishBool
	if _Info.has("OverBool"):
		OverBool = _Info.OverBool
	if _Info.has("Liquid_Count"):
		Liquid_Count = _Info.Liquid_Count
	if Liquid_Count > 0 or CreamTYPE > 0:
		IsBroken = true
	call_PassDay()
func call_PassDay():
	if IsBroken:

		$Effect_flies / Ani.play("Flies")
	elif IsPassDay:
		$Effect_flies / Ani.play("OverDay")
	else:
		$Effect_flies / Ani.play("init")
func call_Mix_end():
	$AniNode / MixAni.playback_speed = 1
	MixFinishBool = true
	$AniNode / MixAni.play("over")
func call_Over_puppet():
	OverBool = true
	$TexNode / UiPoptipWrong.show()
	IsBroken = true
func call_Over():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Over_puppet")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	OverBool = true
	$TexNode / UiPoptipWrong.show()
	IsBroken = true
func call_Drop():

	call_Mix(false)
	OverBool = false
	$TexNode / UiPoptipWrong.hide()
	$AniNode / MixAni.play("init")
	CreamBool = false
	CreamTYPE = 0
	MixFinishBool = false
	Liquid_Count = 0
	$AniNode / WaterAni.play("Cream_Out")
	WaterType = ""
	IsPassDay = false
	IsBroken = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Drop")
	call_PassDay()
func call_Mix(_SWITCH: bool):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix", [_SWITCH])
	if WarningNode.NeedFix:
		if not _SWITCH:
			$AniNode / Loop.play("End")
			$AniNode / MixAni.stop(false)
			IsOpen = false
		return

	match _SWITCH:
		true:
			IsOpen = true
			$AniNode / Loop.play("Start")
			CanMove = false
		false:
			IsOpen = false

			$AniNode / Loop.play("End")
			$AniNode / MixAni.stop(false)
func call_End():
	CanMove = true

func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if WarningNode.return_Fixing(_Player):
		But_Switch(true, _Player)
func call_Fixing_Ani(_Player):
	$AniNode / Fix.play("init")
	$AniNode / Fix.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not CreamTYPE:
				return
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)

		3:
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return

				call_Fix_Logic(_Player)
				return
		2:
			if IsBlackOut or WarningNode.NeedFix:
				return
			if IsOpen and not MixFinishBool:
				if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					_Player.call_Say_Making()
					return
				return
			if not IsOpen and MixFinishBool:
				if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					_Player.call_Say_NoAdd()
					return
				return
			if CreamTYPE > 0 and CreamBool:
				if CanMove:
					if OverBool:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					call_Mix(true)
					But_Switch(true, _Player)
					return true
				elif MixFinishBool:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					call_Mix(false)
					But_Switch(true, _Player)
					return true
				else:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
					return
func call_Out(_ButID, _PortObj, _Player):
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
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if MixFinishBool and Liquid_Count > 0:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					GameLogic.Con.call_vibration(_Player.cur_Player, 0.4, 0, 0.1)
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _return = _PortObj.call_Water_In(_ButID, self)
				if _return > 0:
					call_Drop()
					GameLogic.Liquid.call_WaterStain(_Player.global_position, _return, WaterType, _Player)
					But_Switch(true, _Player)
					return true
func call_In(_ButID, _HoldObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			But_Switch(true, _Player)

		2:
			return call_MachineControl(_ButID, _Player)
		0:
			if _HoldObj.get("Freshless_bool"):
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			var _TYPESTR = _HoldObj.get("TypeStr")

			match _TYPESTR:
				"ice_cream":
					if not CreamBool:
						if _HoldObj.Liquid_Count == 10 and _HoldObj.get("IsOpen"):

							if _HoldObj.has_method("call_Num_Out"):
								if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
									GameLogic.Con.call_vibration(_Player.cur_Player, 0.4, 0.4, 0.1)
								if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
									return
								_HoldObj.call_Num_Out(10)
								Liquid_Count = 10
								IsPassDay = _HoldObj.get("IsPassDay")
								call_Cream_Switch(true)
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_id_sync(_SELFID, "call_In_puppet", [0, _HoldObj._SELFID])
								But_Switch(true, _Player)
								return "倒入Cream"
				"bag_cheeze":
					if not CreamTYPE:
						if not _HoldObj.get("Used"):
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								GameLogic.Con.call_vibration(_Player.cur_Player, 0.4, 0.4, 0.1)
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							_HoldObj.call_used()
							IsPassDay = _HoldObj.get("IsPassDay")
							call_Cream_Type(1)
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_id_sync(_SELFID, "call_In_puppet", [1, _HoldObj._SELFID])
							But_Switch(true, _Player)
							return "放入芝士"
				"bag_salt":
					if not CreamTYPE:
						if not _HoldObj.get("Used"):
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								GameLogic.Con.call_vibration(_Player.cur_Player, 0.4, 0.4, 0.1)
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							_HoldObj.call_used()
							IsPassDay = _HoldObj.get("IsPassDay")
							call_Cream_Type(2)
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_id_sync(_SELFID, "call_In_puppet", [2, _HoldObj._SELFID])
							But_Switch(true, _Player)
							return "放入海盐"
func call_In_puppet(_TYPE: int, _OBJID):
	var _HoldObj = SteamLogic.OBJECT_DIC[_OBJID]
	match _TYPE:
		0:
			Liquid_Count = 10
			_HoldObj.call_Num_Out(10)
			call_Cream_Switch(true)
		1:
			_HoldObj.call_used()
			call_Cream_Type(1)
		2:
			_HoldObj.call_used()
			call_Cream_Type(2)
	IsPassDay = _HoldObj.get("IsPassDay")
	call_PassDay()
func call_Cream_Type(_TYPE: int):
	if CreamTYPE == 0:
		$AniNode / MixAni.playback_speed = 1
		match _TYPE:
			1:
				$AniNode / MixAni.play("芝士_加入")
				WaterType = "芝士奶盖"
				CreamTYPE = 1
			2:
				$AniNode / MixAni.play("海盐_加入")
				WaterType = "海盐奶盖"
				CreamTYPE = 2
	call_PassDay()
func call_Ani_End(_TYPE: int):

	pass
func call_Loop_Times():
	GameLogic.Total_Electricity += 0.1
	if WarningNode.return_Fix():
		call_Mix(false)

func call_Loop():
	GameLogic.Total_Electricity += 0.2
	$AniNode / Loop.play("Loop")
	var _TIME: float = 1
	if GameLogic.cur_Challenge.has("电压不稳"):
		_TIME -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_TIME -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_TIME -= 0.4
	var _ANI = $AniNode / MixAni
	_ANI.playback_speed = _TIME
	match CreamTYPE:
		1:
			_ANI.play("芝士_搅拌")
		2:
			_ANI.play("海盐_搅拌")
func call_Cream_Switch(_SWITCH: bool):
	CreamBool = _SWITCH
	if CreamBool:
		if $AniNode / WaterAni.assigned_animation != "Cream_In":
			$AniNode / WaterAni.play("Cream_In")
	else:
		if $AniNode / WaterAni.assigned_animation == "Cream_In":
			$AniNode / WaterAni.play("Cream_Out")
	call_PassDay()
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
