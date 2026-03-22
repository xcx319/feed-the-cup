extends Node

var watertype: Array

func _ready() -> void :
	call_deferred("_Watertype_init")
func _Watertype_init():
	if not GameLogic.Config.LiquidConfig:
		return
	watertype = GameLogic.Config.LiquidConfig.keys()

func return_color_set(_type):

	if watertype.has(_type):
		var _color = GameLogic.Config.LiquidConfig[_type]
		if _color:
			return Color8(int(_color["R"]), int(_color["G"]), int(_color["B"]), int(_color["A"]))
	else:

		return Color8(255, 255, 255, 255)


func call_WaterStain(_ObjPos, _Liquid, _WaterType, _Player, _TYPE: int = 0):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if _Liquid == 0:
		return
	if is_instance_valid(_Player):
		if _Player.Stat.Skills.has("技能-小心"):

			return
	var _randWaterStain: int
	var _LIQUIDMULT: float = 3
	if _TYPE == 1:
		_LIQUIDMULT = 1
		_randWaterStain = GameLogic.return_randi() % int(_Liquid / 2) + (_Liquid / 2)
	elif _Liquid > 3:
		_randWaterStain = GameLogic.return_randi() % int(float(_Liquid) / _LIQUIDMULT)
	elif _Liquid == 1:
		_randWaterStain = GameLogic.return_randi() % int(_Liquid + 1)
	else:
		_randWaterStain = GameLogic.return_randi() % int(_Liquid)

	for _i in _randWaterStain:
		_ObjPos.x += GameLogic.return_RANDOM() % 50 - 25
		_ObjPos.y += GameLogic.return_RANDOM() % 50 - 25
		call_WaterStain_Logic(_ObjPos, _WaterType)


func call_WaterStain_Logic(_POS, _WaterType):
	var _WaterStain_TSCN = GameLogic.TSCNLoad.WaterStain_TSCN.instance()
	var _NAME = str(_WaterStain_TSCN.get_instance_id())
	_WaterStain_TSCN.name = _NAME
	_WaterStain_TSCN.position = _POS
	GameLogic.Staff.LevelNode.Ysort_Update.add_child(_WaterStain_TSCN)
	_WaterStain_TSCN.WaterType = _WaterType
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_WaterStain", [_NAME, _POS, _WaterType])

func call_puppet_WaterStain(_NAME, _WaterStainPos, _WaterType):
	var _WaterStain_TSCN = GameLogic.TSCNLoad.WaterStain_TSCN.instance()
	_WaterStain_TSCN.name = _NAME
	_WaterStain_TSCN.position = _WaterStainPos
	GameLogic.Staff.LevelNode.Ysort_Update.add_child(_WaterStain_TSCN)
	_WaterStain_TSCN.WaterType = _WaterType
	pass
