extends Head_Object

var Liquid_Count: int
var WaterType
var WaterCelcius: int = 25
var HasWater: bool
var IsPassDay: bool
var IsBroken: bool
var SQUEEZE_SPEED: float
var TYPE: String

onready var TypeAni = get_node("AniNode/TypeAni")
onready var _Audio
var _PLAYER
var _CUP

export var SCALE: float = 1
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.Con.IsHold:

		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		if self.get_parent().name in ["Items"]:
			A_But.hide()
	else:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)

	.But_Switch(_bool, _Player)
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func _ready() -> void :
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	IsItem = true
	get_node("But").show()
	_Audio = GameLogic.Audio.return_Effect("手榨果汁")
func call_init(_TYPE):
	if _TYPE == "Extra":
		IsItem = true
		return
	TYPE = _TYPE
	_rand_icon(TYPE)
	if TYPE in ["奇亚籽"]:
		return
	.call_init(TYPE)
func _rand_icon(_Name):
	match _Name:
		"布朗尼块":
			TypeAni.play(_Name)
		"黑曲奇块":
			TypeAni.play(_Name)
		"黑曲奇":
			TypeAni.play(_Name)
			get_node("TexNode/Tex").rotation = GameLogic.return_RANDOM() % 360
		"柠檬":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation = GameLogic.return_RANDOM() % 360
			WaterType = "柠檬汁"
			HasWater = true
			Liquid_Count = 1
			SQUEEZE_SPEED = 1
		"橙子":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation = GameLogic.return_RANDOM() % 360
			WaterType = "橙子汁"
			HasWater = true
			Liquid_Count = 2
			SQUEEZE_SPEED = 2
		_:
			TypeAni.play(_Name)
func call_load_TSCN(_TypeStr):

	call_init(_TypeStr)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()

func call_load(_INFO):

	_SELFID = int(_INFO.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	call_load_TSCN(_INFO.TypeStr)
	if _INFO.has("IsBroken"):
		IsBroken = _INFO.IsBroken

	_freshless_logic()
func call_bag_tex_set():

	IsItem = true
	if TypeAni:
		if TypeAni.has_animation(TypeStr):
			TypeAni.play(TypeStr)
		else:
			_rand_icon(TypeStr)
	Weight = GameLogic.TSCNLoad.return_weight(FuncType)

func call_WaterInDrinkCup(_ButID, _CupObj, _Player):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
			if _CupObj:
				if _CupObj.FuncType == "DrinkCup":
					if _CupObj.get_parent().name != "Weapon_note":
						_CupObj.call_CupInfo_Switch(false)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
			if _CupObj:
				if _CupObj.FuncType == "DrinkCup":
					if _CupObj.get_parent().name != "Weapon_note":
						if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
							_CupObj.call_CupInfo_Switch(true)
		0:
			if _CupObj.Liquid_Count >= _CupObj.Liquid_Max:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):

				return
func call_broken():
	IsBroken = true
	_freshless_logic()
func _freshless_logic():
	if has_node("Effect_files"):
		var _ANI = get_node("Effect_flies/Ani")
		if IsBroken:
			_ANI.play("Flies")
		elif IsPassDay:
			_ANI.play("OverDay")
func _on_body_entered(body: Node) -> void :
	if not IsPassDay and not IsBroken:
		var _BOOL = return_MoneyBool(body)
		if _BOOL:
			call_broken()
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
