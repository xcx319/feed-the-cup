extends Node2D

var BaseBallBool: bool

onready var BaseBallTSCN = preload("res://TscnAndGd/Objects/Gears/BaseBall.tscn")

onready var TopPos: Vector2
onready var BottomPos: Vector2

func _ready():
	var _LEVELINFO = GameLogic.cur_levelInfo
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _CHECK = GameLogic.curLevelList
	if GameLogic.curLevelList.has("难度-棒球"):
		BaseBallBool = true
	elif _LEVELINFO.has("GamePlay"):
		var _CHECK1 = _LEVELINFO.GamePlay
		if _LEVELINFO.GamePlay.has("难度-棒球"):
			BaseBallBool = true

	if BaseBallBool:
		if not GameLogic.GameUI.is_connected("TimeChange", self, "_TimeChange_Logic"):
			var _check = GameLogic.GameUI.connect("TimeChange", self, "_TimeChange_Logic")
	TopPos = get_parent().get_node("CameraPos2D/LeftTop").position
	BottomPos = get_parent().get_node("CameraPos2D/RightBottom").position


func _TimeChange_Logic():
	var _NUM: int = 2
	for _i in _NUM:
		if GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
			var _BaseBall = BaseBallTSCN.instance()
			var _STARTTYPE = GameLogic.return_RANDOM() % 4
			var _StartPos: Vector2
			var _EndPos: Vector2
			var _Vector: Vector2

			match _STARTTYPE:
				0:
					_StartPos.x = TopPos.x - GameLogic.return_RANDOM() % 200
					var _Y: int = int(BottomPos.y) - int(TopPos.y)
					_StartPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_EndPos.x = BottomPos.x
					_EndPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_Vector = (_EndPos - _StartPos).normalized()
				1:
					_StartPos.x = BottomPos.x + GameLogic.return_RANDOM() % 200
					var _Y: int = int(BottomPos.y) - int(TopPos.y)
					_StartPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_EndPos.x = TopPos.x - 50
					_EndPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_Vector = (_EndPos - _StartPos).normalized()
				2:
					_StartPos.y = TopPos.y - GameLogic.return_RANDOM() % 200
					var _X: int = int(BottomPos.x) - int(TopPos.x)
					_StartPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_EndPos.y = BottomPos.y + 50
					_EndPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_Vector = (_EndPos - _StartPos).normalized()
				3:
					_StartPos.y = BottomPos.y + GameLogic.return_RANDOM() % 200
					var _X: int = int(BottomPos.x) - int(TopPos.x)
					_StartPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_EndPos.y = TopPos.y - 50
					_EndPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_Vector = (_EndPos - _StartPos).normalized()

			var _SPEED = GameLogic.return_RANDOM() % 400 + 200
			var _RANDNUM: int = int(float(_SPEED) / 3)
			var _RANDCHECK: int = GameLogic.return_RANDOM() % _RANDNUM

			var _NAME: String = str(_BaseBall.get_instance_id())
			var _Rotation = int(float(_SPEED) / 20)

			_BaseBall.name = _NAME
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_baseball_puppet", [_NAME, _StartPos, _Vector, _SPEED, _Rotation])
			_BaseBall.position = _StartPos
			_BaseBall.input_vector = _Vector

			_BaseBall.SPEED = _SPEED
			_BaseBall.Rotation = _Rotation
			get_parent().Ysort_Update.add_child(_BaseBall)

func call_baseball_puppet(_NAME, _Pos, _Vec, _SPEED, _Rotation):
	var _BaseBall = BaseBallTSCN.instance()
	_BaseBall.name = _NAME
	_BaseBall.position = _Pos
	_BaseBall.input_vector = _Vec
	_BaseBall.SPEED = _SPEED
	_BaseBall.Rotation = _Rotation
	get_parent().Ysort_Update.add_child(_BaseBall)
