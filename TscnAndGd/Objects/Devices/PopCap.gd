extends Head_Object
var SelfDev = "PopCap"

var ContentDic: Dictionary = {}
var Liquid_Max: int = 40
var Liquid_Count: int
var cur_Liquid: int
var WaterType: String
var NeedWater: bool
var HasWater: bool
var IsPassDay: bool
var WaterCelcius: int = 25
var PowerMult: float = 1

var NeedWaterNum: int = 5
var _COLOR: Color = Color8(137, 228, 245, 100)
var TYPE: int = 0
var CanContant: bool = true
var _GasChargeBool: bool
var GasNum: int = 0
var Pop: int
onready var LiquidNode = $TexNode / Liquid
onready var LiquidAni = $TexNode / Liquid / TextureProgress / AnimationPlayer
onready var VBox = $TexNode / UI / VBoxContainer
onready var UIAni = $TexNode / UI / AnimationPlayer

onready var ICONAni = $TexNode / IconNode / AnimationPlayer
onready var PopAni = $TexNode / Liquid / TextureProgress / PopAni
onready var RunAni = $AniNode / RunAni
onready var UpgradeAni = $AniNode / Upgrade
var CHECK_DIC: Dictionary = {
	"气泡水": {"water": 1},
	"可乐": {"water": 5, "pop_cola": 1},
	"柠汽": {"water": 4, "pop_lime": 1},
	"蓝汽": {"water": 3, "pop_blueorange": 1},
	"薄汽": {"water": 2, "pop_mint": 1},
	"荔汽": {"water": 1, "pop_lychee": 1},
	"柠可": {"water": 5, "pop_cola": 1, "pop_lime": 1},
	"炸弹": {"water": 2, "pop_cola": 1, "pop_lime": 3},
	"薄可": {"water": 5, "pop_cola": 2, "pop_mint": 1},
	"醒脑": {"water": 3, "pop_cola": 1, "pop_mint": 2},
	"蓝可": {"water": 6, "pop_cola": 1, "pop_blueorange": 1},
	"变异": {"water": 3, "pop_cola": 1, "pop_blueorange": 3},
	"荔可": {"water": 4, "pop_cola": 2, "pop_lychee": 1},
	"爱恋": {"water": 3, "pop_cola": 2, "pop_lychee": 3},
	"青柠蓝柑": {"water": 2, "pop_blueorange": 1, "pop_lime": 1},
	"薄荷青柠": {"water": 2, "pop_mint": 1, "pop_lime": 2},
	"荔枝蓝柑": {"water": 3, "pop_lychee": 3, "pop_blueorange": 2},
	"薄荷荔枝": {"water": 2, "pop_mint": 2, "pop_lychee": 3},
}

func _ready() -> void :
	set_physics_process(false)
	$TexNode / UI.hide()
	call_init(SelfDev)

	call_deferred("_collision_check")
	var _check = GameLogic.GameUI.connect("TimeChange", self, "_PopTimeLogic")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _CON = GameLogic.connect("Reward", self, "Update_Check")
func _DayClosedCheck():
	GasNum = 0
	pass
func Update_Check():
	var _Mult: float = 1
	if GameLogic.cur_Rewards.has("软饮机升级"):
		Liquid_Max = 50
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("软饮机升级+"):

		Liquid_Max = 60
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")

func call_Pop_puppet(_GASNUM):
	GasNum = _GASNUM
	call_Pop_Set()

func call_GasChange(_CHANGENUM: int):
	GasNum += _CHANGENUM
	if GasNum > 100:
		GasNum = 100
	call_Pop_Set()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Pop_puppet", [GasNum])
var _TIMENUM: int = 0
func _PopTimeLogic():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not _GasChargeBool:
		if GasNum > 0:
			if get_parent().name in ["Obj_X", "Obj_Y"]:
				var _MACHINE = get_parent().get_parent().get_parent()
				if is_instance_valid(_MACHINE.LayerB_Obj):
					GameLogic.Total_Electricity += 0.1 * PowerMult
					var _GASBOTTLE = _MACHINE.LayerB_Obj
					if _GASBOTTLE.GasNum > 0:
						if GameLogic.cur_Rewards.has("可乐机升级+"):
							if _TIMENUM < 2:
								_TIMENUM += 1
								return
							else:
								_TIMENUM = 0
						_GASBOTTLE.call_Used()
						return
					else:
						if GameLogic.cur_Rewards.has("可乐机升级+"):
							if _TIMENUM < 2:
								_TIMENUM += 1
								return
							else:
								_TIMENUM = 0
						call_GasChange( - 1)
						_GASBOTTLE.call_Num_Set()
						return
			call_GasChange( - 1)
	else:
		if GasNum > 0:
			if get_parent().name in ["Obj_X", "Obj_Y"]:
				var _MACHINE = get_parent().get_parent().get_parent()
				if is_instance_valid(_MACHINE.LayerB_Obj):
					GameLogic.Total_Electricity += 0.1 * PowerMult
func call_Pop_Set():
	if get_parent().name in ["Obj_X", "Obj_Y"]:
		var _MACHINE = get_parent().get_parent().get_parent()
		_MACHINE.call_PopLogic()
	if GasNum == 0:
		Pop = 0
		PopAni.play("init")

	elif GasNum <= 25:
		Pop = 1
		if PopAni.assigned_animation != "pop1":
			PopAni.play("pop1")

	elif GasNum <= 55:
		Pop = 2
		if PopAni.assigned_animation != "pop2":
			PopAni.play("pop2")

	elif GasNum <= 100:
		Pop = 3
		if PopAni.assigned_animation != "pop3":
			PopAni.play("pop3")

func call_fan_switch(_SWITCH: bool):
	match _SWITCH:
		true:
			if Liquid_Count > 0 and Pop > 0:
				RunAni.play("run")
			else:
				RunAni.play("init")

		false:
			RunAni.play("init")
func L_set(_Value: int):
	cur_Liquid = _Value

func call_Color_Logic(_WATERNAME, _NUM):
	var _LIQUIDNAME = _WATERNAME

	if GameLogic.Config.LiquidConfig.has(_WATERNAME):
		Liquid_Count += _NUM
		call_ContentDic(_WATERNAME, _NUM)
		if _WATERNAME == "water" and WaterType != "":
			_LIQUIDNAME = WaterType
			var _NEWCOLOR = GameLogic.Liquid.return_color_set(WaterType)
			LiquidNode.modulate = _NEWCOLOR
			_COLOR = LiquidNode.modulate
		else:
			var _KEYS = ContentDic.keys()
			var _COUNT: int = 0
			for _WATER in _KEYS:
				_COUNT += 1
				var _NEWCOLOR = GameLogic.Liquid.return_color_set(_WATER)
				var _WATERNUM = ContentDic[_WATER]
				if _COUNT == 1:

					if _WATER == "water" and _KEYS.size() > 1:
						_NEWCOLOR = Color8(1, 1, 1, 0.75)
						_COLOR = _NEWCOLOR
					else:

						_COLOR = _NEWCOLOR
				else:
					if ContentDic[_WATER] > 0:
						var _CHECK_1: float = float(ContentDic[_WATER]) / float(Liquid_Count)
					if _WATER == "water" and _KEYS.size() > 1:


						_COLOR.a = _COLOR.a * 0.75
					else:


						var _COLORCHECK_2: Color = (_COLOR + _NEWCOLOR) / 2
						_COLOR = _COLORCHECK_2
			LiquidNode.modulate = _COLOR






func call_WaterInDrinkCup(_ButID, _HoldObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
				if HasWater:
					But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if not get_parent().name in ["Obj_X", "Obj_Y"]:

				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NeedRack()
				return
			if _HoldObj.get("IsDirty"):
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NeedWash()
				return
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max and Liquid_Count > 0:
				if TYPE > 0:

					if _HoldObj.Liquid_Count + 1 >= _HoldObj.Liquid_Max:
						But_Switch(false, _Player)
					else:
						if not get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
							if has_method("But_Switch"):
								But_Switch(true, _Player)

					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return

					GameLogic.Liquid.call_WaterStain(_HoldObj.global_position, 1, WaterType, _Player)
					_HoldObj.call_Water_AllIn(self)
					return true
func call_AllIn_puppet(_ID, _CUPID):
	var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
	var _SELF = SteamLogic.OBJECT_DIC[_ID]
	_CUP.call_Water_AllIn(_SELF)
func call_ContentDic(_WATERNAME: String, _NUM: int):
	var _CONTANTKEY = ContentDic.keys()
	var _HASBOOL: bool
	for _KEY in _CONTANTKEY:
		if _KEY == _WATERNAME:
			ContentDic[_KEY] += _NUM
			_HASBOOL = true
			break
	if not _HASBOOL:

		ContentDic[_WATERNAME] = _NUM
	call_Liquid_Logic()

func call_UI_clear():
	var _LIST = VBox.get_children()
	for _NODE in _LIST:
		_NODE.hide()
func call_UI_Logic():
	call_UI_clear()
	var _CONTANTKEY = ContentDic.keys()
	var _NUM: int = 0
	for _WaterType in _CONTANTKEY:
		_NUM += 1
		if GameLogic.Config.LiquidConfig.has(_WaterType):


			var _IconName = GameLogic.Config.LiquidConfig[_WaterType].IconName
			var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
			var _Icon = load(_path)
			if VBox.has_node(str(_NUM)):
				var _NODE = VBox.get_node(str(_NUM))
				_NODE.text = str(ContentDic[_WaterType])
				if _NODE.has_node("Icon"):
					var _ICONNODE = _NODE.get_node("Icon")
					_ICONNODE.set_texture(_Icon)
					_NODE.get_node("AnimationPlayer").play("init")
					_NODE.show()
	if NeedWater and not HasWater:
		UIAni.play("show")
		if VBox.has_node(str(_NUM)):
			var _path = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_water_all.tres"
			var _Icon = load(_path)
			var _NODE = VBox.get_node(str(_NUM + 1))

			_NODE.text = str(NeedWaterNum)
			if _NODE.has_node("Icon"):
				var _ICONNODE = _NODE.get_node("Icon")
				_ICONNODE.set_texture(_Icon)
				_NODE.get_node("AnimationPlayer").play("NeedWater")
				_NODE.show()
	elif NeedWater and HasWater:
		UIAni.play("hide")

func call_Liquid_Logic():
	var _CONTANTKEY = ContentDic.keys()
	var _CHECK_KEYS = CHECK_DIC.keys()
	var _CHECKLIQUIDBOOL: bool
	for _CHECK in _CHECK_KEYS:
		var _DIC = CHECK_DIC[_CHECK]
		var _LIST: Array = _DIC.keys()
		var _CHECKLIST: Array
		var _TOTAL: int = 0
		var _TOTALLIQUID: int = 0
		for _KEY in _LIST:


			if not HasWater and _KEY == "water":
				continue
			else:
				_TOTAL += _DIC[_KEY]
				if ContentDic.has(_KEY):
					_TOTALLIQUID += ContentDic[_KEY]
				_CHECKLIST.append(_KEY)
		if _CHECKLIST.size() == _CONTANTKEY.size():
			var _CHECKBOOL: bool = true
			for _CONTENT in _CONTANTKEY:
				if _DIC.has(_CONTENT):
					var _CHECKMULT = (ContentDic[_CONTENT] * _TOTAL) / _TOTALLIQUID
					if _CHECKMULT != _DIC[_CONTENT]:

						_CHECKBOOL = false
			if not _CHECKBOOL:
				continue

			var _CHECKLiquid: bool = true
			var _COUNTNOWATER: int = 0
			for _LIQUIDNAME in _CHECKLIST:
				if not _CONTANTKEY.has(_LIQUIDNAME):
					_CHECKLiquid = false
				else:



					_COUNTNOWATER += _DIC[_LIQUIDNAME]
			if _CHECKLiquid:

				WaterType = _CHECK
				if _COUNTNOWATER > 0:
					if _LIST.has("water"):
						NeedWater = true
						if not HasWater:
							NeedWaterNum = int(round(Liquid_Count * _DIC["water"] / _COUNTNOWATER))
						elif WaterType == "气泡水":
							NeedWaterNum = 10
					_CHECKLIQUIDBOOL = true
					break
				else:
					NeedWaterNum = Liquid_Max

			else:
				WaterType = ""
				NeedWaterNum = 0
	if NeedWaterNum + Liquid_Count > Liquid_Max and not HasWater:
		_CHECKLIQUIDBOOL = false
		NeedWaterNum = 0
		WaterType = ""
		NeedWater = false

	if _CHECKLIQUIDBOOL:
		if GameLogic.Config.LiquidConfig.has(WaterType):

			var _IconName = GameLogic.Config.LiquidConfig[WaterType].IconName
			var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
			var _Icon = load(_path)
			$TexNode / UI / FinishView / Icon.set_texture(_Icon)
			$TexNode / UI / FinishView.show()
			$TexNode / IconNode / Icon.set_texture(_Icon)
			$TexNode / IconNode / Icon / LiquidLabel.text = str(Liquid_Count)
			if not HasWater and NeedWater:
				ICONAni.play("init")
				TYPE = 0
			elif HasWater and NeedWater:
				ICONAni.play("HasWater")
				TYPE = 1
			elif not NeedWater:
				ICONAni.play("HasWater")
				TYPE = 1
	else:
		WaterType = ""
		$TexNode / UI / FinishView.hide()
		ICONAni.play("init")
	call_UI_Logic()
func _physics_process(_delta):

	if LiquidAni.assigned_animation == "init":
		cur_Liquid = 0
	elif LiquidAni.assigned_animation in ["show", "50", "60"]:
		var _CHECK = LiquidAni.current_animation_position

	if cur_Liquid > Liquid_Count:
		if not LiquidAni.is_playing():
			match Liquid_Max:
				50:
					LiquidAni.play_backwards("50")
				60:
					LiquidAni.play_backwards("60")
				_:
					LiquidAni.play_backwards("show")

	elif cur_Liquid < Liquid_Count:
		if not LiquidAni.is_playing():
			match Liquid_Max:
				50:
					LiquidAni.play("50")
				60:
					LiquidAni.play("60")
				_:

					LiquidAni.play("show")

	elif cur_Liquid == Liquid_Count:
		if LiquidAni.is_playing():
			LiquidAni.stop(false)
		set_physics_process(false)

func call_Water_puppet(_WATERTYPE, _NEEDNUM, _COUNT):
	Liquid_Count = _COUNT
	HasWater = true
	call_Color_Logic(_WATERTYPE, _NEEDNUM)
	set_physics_process(true)

func call_Water_In(_ButID, _WaterTank):
	match _ButID:

		0:

			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			if NeedWaterNum > 0 and not HasWater:

				var _WATERTYPE = _WaterTank.get("WaterType")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_puppet", [_WATERTYPE, NeedWaterNum, Liquid_Count])
				HasWater = true
				call_Color_Logic(_WATERTYPE, NeedWaterNum)
				set_physics_process(true)

	pass
func call_Liquid_In(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)

		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if not CanContant:
				return
			if not _HoldObj.IsOpen:
				return
			if _HoldObj.get("Freshless_bool"):
				return
			if _HoldObj.Liquid_Count >= 5 and Liquid_Count < 40 and not HasWater:

				var _WATERTYPE = _HoldObj.get("WaterType")

				call_Color_Logic(_WATERTYPE, 5)

				if _HoldObj.has_method("call_Num_Out"):
					_HoldObj.call_Num_Out(5)
				set_physics_process(true)

	pass

func But_Switch(_bool, _Player):

	if _bool:
		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			$TexNode / UI.show()
	else:
		$TexNode / UI.hide()
	.But_Switch(_bool, _Player)

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

func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	ContentDic = _Info.ContentDic
	Liquid_Count = _Info.Liquid_Count
	WaterType = _Info.WaterType
	NeedWater = _Info.NeedWater
	HasWater = _Info.HasWater
	NeedWaterNum = _Info.NeedWaterNum
	_COLOR = _Info._COLOR
	TYPE = _Info.TYPE
	CanContant = _Info.CanContant
	GasNum = _Info.GasNum

	call_Liquid_Logic()

	LiquidNode.modulate = _COLOR

	if Liquid_Count > 0:
		set_physics_process(true)

	Update_Check()

func call_Drop():
	if Liquid_Count > 0:
		call_Water_Out(Liquid_Count)

func call_Water_Out_puppet(_LIQUID):
	var Audio_Water = GameLogic.Audio.return_Effect("倒水")
	Audio_Water.play(0)
	var _OutNum = Liquid_Count - _LIQUID

	Liquid_Count = _LIQUID

	$TexNode / IconNode / Icon / LiquidLabel.text = str(Liquid_Count)
	if Liquid_Count <= 0:
		Liquid_Count = 0
		HasWater = false
		NeedWater = false
		WaterType = ""
		ContentDic.clear()
		ICONAni.play("init")
		call_UI_clear()
		PopAni.play("init")
		Pop = 0
		GasNum = 0
		RunAni.play("init")
		UIAni.play("show")
		$TexNode / UI / FinishView.hide()

	set_physics_process(true)
func call_Water_Out(_OutNum):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var Audio_Water = GameLogic.Audio.return_Effect("倒水")
	Audio_Water.play(0)
	Liquid_Count -= _OutNum
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(int(self.name), "call_Water_Out_puppet", [Liquid_Count])

	$TexNode / IconNode / Icon / LiquidLabel.text = str(Liquid_Count)
	if Liquid_Count <= 0:
		Liquid_Count = 0
		HasWater = false
		NeedWater = false
		WaterType = ""
		ContentDic.clear()
		ICONAni.play("init")
		call_UI_clear()
		PopAni.play("init")
		Pop = 0
		GasNum = 0
		RunAni.play("init")
		UIAni.play("show")
		$TexNode / UI / FinishView.hide()

	set_physics_process(true)

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)


func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
