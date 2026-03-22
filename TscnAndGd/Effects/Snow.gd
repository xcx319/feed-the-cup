extends Particles2D

onready var _SNOWTSCN = preload("res://TscnAndGd/Effects/SnowOBJ.tscn")
var STARTBOOL: bool
var SNOWNUM: int = 0
func _ready():
	self.amount = 10
	if not GameLogic.is_connected("DayStart", self, "call_Start"):
		var _CON = GameLogic.connect("DayStart", self, "call_Start")
	if not GameLogic.GameUI.is_connected("TimeChange", self, "call_timer"):
		var _check = GameLogic.GameUI.connect("TimeChange", self, "call_timer")
func call_timer():
	if not STARTBOOL:
		return
	var _FLOORLIST = self.get_node("SNOW").get_used_cells()

	_FLOORLIST.shuffle()

	var _SNOWDIC: Dictionary
	var _Num: int = 0
	for _FLOOR in _FLOORLIST:
		_Num += 1
		SNOWNUM += 1
		var _randx = float(GameLogic.return_RANDOM() % 101 - 50)
		var _randy = float(GameLogic.return_RANDOM() % 101 - 50)
		var _pointV2 = _FLOOR * 100 + Vector2(50, 50)
		_pointV2.x += _randx
		_pointV2.y += _randy
		var _Type = GameLogic.return_RANDOM() % 4 + 1
		var _FLIP = GameLogic.return_RANDOM() % 2
		var _NAME = "S" + str(SNOWNUM)
		_SNOWDIC[_Num] = [_pointV2, _Type, _FLIP, _NAME]
		if _Num >= 2 * GameLogic.return_Multiplier_Division():
			break
	var _SNOWNUM = 2
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_show", [_SNOWDIC, _SNOWNUM])
	call_SHOW(_SNOWDIC, _SNOWNUM)

func call_start_puppet():
	self.amount = 100 * GameLogic.return_Multiplier()

func call_Start():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.curLevelList.has("难度-下雪") or GameLogic.cur_levelInfo.GamePlay.has("难度-下雪"):
		STARTBOOL = true
	if not STARTBOOL:
		return
	elif SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_start_puppet")
	self.amount = 100 * GameLogic.return_Multiplier()


	var _FLOORLIST = self.get_node("SNOW").get_used_cells()
	_FLOORLIST.shuffle()
	call_Snow_init(_FLOORLIST)
func call_Snow_init(_FLOORLIST):
	var _SNOWDIC: Dictionary
	var _Num: int = 0
	for _FLOOR in _FLOORLIST:
		_Num += 1
		SNOWNUM += 1
		for _i in 2:

			var _randx = float(GameLogic.return_RANDOM() % 101 - 50)
			var _randy = float(GameLogic.return_RANDOM() % 101 - 50)
			var _pointV2 = _FLOOR * 100 + Vector2(50, 50)
			_pointV2.x += _randx
			_pointV2.y += _randy
			var _Type = GameLogic.return_RANDOM() % 4 + 1
			var _FLIP = GameLogic.return_RANDOM() % 2
			var _NAME = "S" + str(SNOWNUM)
			_SNOWDIC[_Num] = [_pointV2, _Type, _FLIP, _NAME]
		if _Num >= 25 * GameLogic.return_Multiplier_Division():
			break
	var _SNOWNUM = 6
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_show", [_SNOWDIC, _SNOWNUM])
	call_SHOW(_SNOWDIC, _SNOWNUM)
func call_SHOW(_SNOWDIC, _NUM):
	var _KEYList = _SNOWDIC.keys()
	for _KEY in _KEYList:
		var _SNOW = _SNOWTSCN.instance()
		_SNOW.position = _SNOWDIC[_KEY][0]
		_SNOW.NUM = _NUM
		_SNOW.Type = _SNOWDIC[_KEY][1]
		_SNOW.name = _SNOWDIC[_KEY][3]
		var _FLIP = _SNOWDIC[_KEY][2]
		if _FLIP == 1:
			_SNOW.FlipH = true
		if GameLogic.NPC.LevelNode.has_node("YSort/Updates"):
			GameLogic.NPC.LevelNode.get_node("YSort/Updates").add_child(_SNOW)
func call_puppet_show(_SNOWDIC, _SNOWNUM):
	call_SHOW(_SNOWDIC, _SNOWNUM)
