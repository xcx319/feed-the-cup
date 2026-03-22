extends Head_Object

var _ReadyStr: String
onready var UseAni = $AniNode / UseAni
onready var typeAni = get_node("AniNode/TypeAni")
onready var HoldBut = get_node("Hold")
onready var HoldY_But = HoldBut.get_node("Y")
onready var FreshAni = $Effect_flies / Ani
onready var OpenAni = $AniNode / OpenAni
var Freshless_bool: bool
var IsPassDay: bool
var Is_Storage: bool
var IsOpen: bool = false
var Liquid_Count: int = 40
var Liquid_Max: int = 40
var WaterType
var BeerOBJ
var _PlayerOBJ
var HasWater: bool
var WaterCelcius: int = 25
var SWITCH: bool = false
var CanPass: bool = false
var _WOODENLIST: Array = ["拉格", "艾尔", "皮尔森"]
var Pop: int = 0
func call_new():
	CanPass = true

	get_node("Label/Ani").play("New")
	if GameLogic.cur_Rewards.has("合理堆放") or GameLogic.cur_Rewards.has("合理堆放+"):
		get_node("Label/Timer").wait_time = 60
	get_node("Label/Timer").start(0)
func call_move():
	if CanPass:
		CanPass = false
		get_node("Label/Timer").stop()
		_Timer_End()
func _Timer_End():
	if get_node("Label/Ani").assigned_animation != "hide":
		get_node("Label/Ani").play("hide")
	CanPass = false
func call_pup(_LIQUID):
	Liquid_Count = _LIQUID
	$UseAudio.play(0)
	if is_instance_valid(BeerOBJ):

		if BeerOBJ.Liquid_Count >= BeerOBJ.Liquid_Max:
			if BeerOBJ.LIQUID_DIR.has("啤酒泡"):
				if BeerOBJ.LIQUID_DIR["啤酒泡"] == 0:
					call_Switch(false)
			else:
				call_Switch(false)
	if Liquid_Count == 0:
		call_Switch(false)
	call_Liquid_set()
	if SWITCH:
		UseAni.play("init")
		UseAni.play("Use")
func call_finish():

	if is_instance_valid(BeerOBJ):
		$UseAudio.play(0)
		if BeerOBJ.Liquid_Count >= BeerOBJ.Liquid_Max:
			if BeerOBJ.LIQUID_DIR.has("啤酒泡"):
				if BeerOBJ.LIQUID_DIR["啤酒泡"] == 0:
					call_Switch(false)
					return
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		Liquid_Count -= 1
		BeerOBJ.Beer_In_Logic(self)
		GameLogic.Liquid.call_WaterStain(BeerOBJ.global_position, 1, WaterType, _PlayerOBJ)
		if BeerOBJ.Liquid_Count >= BeerOBJ.Liquid_Max:
			if BeerOBJ.LIQUID_DIR.has("啤酒泡"):
				if BeerOBJ.LIQUID_DIR["啤酒泡"] == 0:
					call_Switch(false)
			else:
				call_Switch(false)
		if Liquid_Count == 0:
			call_Switch(false)
	call_Liquid_set()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_pup", [Liquid_Count])
func call_Switch(_SWITCH: bool, _OBJ = null, _Player = null):

	if _OBJ != null:
		BeerOBJ = _OBJ
	if _Player != null:
		_PlayerOBJ = _Player
	SWITCH = _SWITCH
	var A_But = get_node("But/A")
	if SWITCH:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
	else:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	if SWITCH:
		UseAni.play("Use")

	else:
		UseAni.play("init")
		BeerOBJ = null

		_PlayerOBJ = null
func call_WaterInDrinkCup(_ButID, _HoldObj, _Player, _POPNUM: int = 0):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
				if Liquid_Count > 0 and IsOpen:
					But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			Pop = _POPNUM
			if get_parent().name in ["Items"]:
				return
			if not IsOpen or Liquid_Count <= 0 or _HoldObj.Top != "":
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if _HoldObj.IsStale:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if is_instance_valid(_PlayerOBJ):
				if _PlayerOBJ == _Player:
					if SWITCH:
						call_Switch(false)
						return
				else:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
					return
			if is_instance_valid(BeerOBJ):
				return

			if Liquid_Count > 0:
				if not SWITCH:
					if is_instance_valid(_HoldObj):
						if _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
							if _HoldObj.LIQUID_DIR.has("啤酒泡"):
								if _HoldObj.LIQUID_DIR["啤酒泡"] == 0:

									return
					call_Switch(true, _HoldObj, _Player)
					return true


func call_Freezer_Switch(_Switch):
	Is_Storage = _Switch
func But_Hold(_Player):

	if not is_instance_valid(get_parent()):
		return
	if get_parent().name == "Weapon_note":
		HoldY_But.show_player(_Player.cur_Player)
		HoldBut.show()
	else:
		HoldBut.hide()
		HoldY_But.call_clean()
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			if has_node("AniNode/OutLineAni"):
				get_node("AniNode/OutLineAni").play("show")

		false:
			if has_node("AniNode/OutLineAni"):
				get_node("AniNode/OutLineAni").play("init")
	pass
func call_Broken():
	var _FreshBool: bool

	match FreshType:
		1:

			_FreshBool = true
		2, 3:
			if not Is_Storage:
				_FreshBool = true
		4:
			Freshless_bool = true

	if _FreshBool:
		if IsPassDay and not Freshless_bool:
			Freshless_bool = true
		elif not IsPassDay:
			IsPassDay = true
	_freshless_logic()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if get_parent().name in ["Items"]:
		return
	if _Player.Con.IsHold:

		var A_But = get_node("But/A")
		if SWITCH:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
		else:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	else:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	if not IsOpen:
		if TypeStr in _WOODENLIST:
			$But / X.show()
		else:
			$But / X.hide()
	else:
		$But / X.hide()
	.But_Switch(_bool, _Player)

func _ready() -> void :
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	IsItem = true
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	GameLogic.NPC.BEERLIST.append(self)
func _DayClosedCheck():
	if not self.is_inside_tree():
		return

	if get_parent().name == "Items":
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.BARREL):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.BARREL)
	call_Broken()



func _WaterLogic():
	if Liquid_Count:
		if TypeStr in _WOODENLIST:
			if IsOpen:
				HasWater = true
		else:
			HasWater = true

func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()
	WaterType = TypeStr
	_WaterLogic()
	call_Liquid_set()

func _freshless_logic():
	if not Liquid_Count:
		FreshAni.play("init")
	else:
		if Freshless_bool:
			FreshAni.play("Flies")
		elif IsPassDay:
			FreshAni.play("OverDay")
		else:
			FreshAni.play("init")

func call_CarrySpeed():
	CarrySpeed = 0.6 + 0.4 * (Liquid_Max - Liquid_Count) / Liquid_Max

func call_Liquid_set():

	$TexNode / UI / UseTex / Label.text = str(Liquid_Count)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	if not TypeStr:
		call_init(_Info.TSCN)

	if _Info.has("IsOpen"):
		IsOpen = _Info.IsOpen

	if _Info.has("Liquid_Count"):
		Liquid_Count = _Info.Liquid_Count

	WaterType = TypeStr
	_freshless_logic()
	call_Liquid_set()
	call_CarrySpeed()
	call_bag_tex_set()

func call_bag_tex_set():

	IsItem = true
	if typeAni:
		if typeAni.has_animation(TypeStr):
			typeAni.play(TypeStr)
		call_OpenAni()
func call_Barrel_tex(_NAME):
	if typeAni.has_animation(_NAME):
		typeAni.play(_NAME)
	if _NAME in _WOODENLIST:
		OpenAni.play("Show")
func call_OpenAni():
	if IsOpen:
		if TypeStr in _WOODENLIST:
			OpenAni.play("Open")
		else:
			call_InMachine(IsOpen)
	_WaterLogic()

func call_broken():
	Freshless_bool = true

	call_bag_tex_set()
	_freshless_logic()
func _on_body_entered(body: Node) -> void :

	GameLogic.Device.call_touch(body, self, true)

func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func call_Use(_ButID, _Player):

	match _ButID:
		2:
			if get_parent().name in ["Items"]:
				return
			if TypeStr in _WOODENLIST:
				if not IsOpen:
					_Player.call_DeviceAni(self, 1, false)
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

						SteamLogic.call_puppet_id_sync(_SELFID, "Open_pup", [Liquid_Count])
					_OpenLogic()
					But_Switch(true, _Player)

var _OPENPLAYER = null

func Open_pup(_LIQUID: int):
	Liquid_Count = _LIQUID
	_OpenLogic()
func _OpenLogic():


	IsOpen = true
	if TypeStr in _WOODENLIST:

		OpenAni.play("OpenAni")
		_WaterLogic()
	call_Liquid_set()
func call_InMachine(_BOOL: bool):
	IsOpen = _BOOL
	match IsOpen:
		true:
			OpenAni.play("In")
		false:
			OpenAni.play("init")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_InMachine", [IsOpen])
func call_OpenFinish():
	pass

func _Use_Finish():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		UseAni.play("init")
		return
	if is_instance_valid(BeerOBJ):
		UseAni.play("Use")
	pass
