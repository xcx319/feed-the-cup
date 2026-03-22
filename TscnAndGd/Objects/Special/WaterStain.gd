extends Area2D

var TYPE: int = 1
var WaterType: String setget _WaterType_Set
var WaterColor
var Num: float = 0 setget _Num_Change

var NumMax: float = 7
onready var WaterSprite = get_node("Sprite")
onready var CleanTimer = get_node("CleanTimer")
var _MOPNODE
var _TIME: float
func _ready():

	_Num_Change(1)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	_TIME = 0.1 * GameLogic.return_Multiplier()
	CleanTimer.wait_time = _TIME
	self.add_to_group("WaterStain")
func _DayClosedCheck():

	var _LEVELINFO = GameLogic.cur_levelInfo

	if not _LEVELINFO.GamePlay.has("难度-污渍水渍") and not GameLogic.curLevelList.has("难度-污渍水渍"):
		return
	if Num > 5:
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.STAIN):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.STAIN)
func call_clean(_Switch, _OBJ, _Mult):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	match _Switch:
		true:
			CleanTimer.wait_time = _TIME * _Mult
			_MOPNODE = _OBJ
			if CleanTimer.is_stopped():
				CleanTimer.start(0)
		false:
			_MOPNODE = null
			CleanTimer.stop()
func _on_CleanTimer_timeout():
	CleanTimer.wait_time = 0.3
	if is_instance_valid(_MOPNODE):
		if _MOPNODE.has_method("call_add_stain"):
			_MOPNODE.call_add_stain()
		if _MOPNODE.has_method("call_clean_logic"):
			_MOPNODE.call_clean_logic()

	_Num_Change( - 1)

func call_init():
	match TYPE:
		1:
			NumMax = 10
			var _rand = GameLogic.return_RANDOM() % 9 + 1
			var _Path = "res://Resources/Effects/effect_pack.sprites/" + "Stain_drop_" + str(_rand) + ".tres"
			var _Tex = load(_Path)
			$Sprite.rotation_degrees = rand_range(0, 360)
			WaterSprite.set_texture(_Tex)
			get_node("CollisionShape2D/Ani").play("2")

		0:
			NumMax = 7
			var _rand = GameLogic.return_RANDOM() % 9 + 1
			var _Path = "res://Resources/Effects/effect_pack.sprites/" + "Stain_drop_" + str(_rand) + ".tres"
			var _Tex = load(_Path)
			$Sprite.rotation_degrees = rand_range(0, 360)
			WaterSprite.set_texture(_Tex)
			get_node("CollisionShape2D/Ani").play("2")

func _WaterType_Set(_Type):
	WaterType = _Type
	if GameLogic.Config.LiquidConfig.has(WaterType):
		TYPE = int(GameLogic.Config.LiquidConfig[WaterType].StainType)
	else:
		TYPE = 1
		call_init()
		return

	call_init()
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	WaterSprite.set_modulate(_color8)
	WaterColor = _color8

func call_puppet_Num_Change(_NUM, _TYPE: int = 0):
	Num = _NUM
	if Num > NumMax:
		Num = NumMax
	elif Num <= 0:
		Num = 0

	if _TYPE > 0:
		if Num >= 5:
			match TYPE:
				0:
					$Icon / AnimationPlayer.play("Stain")
				_:
					$Icon / AnimationPlayer.play("Water")
		else:
			$Icon / AnimationPlayer.play("init")
	var _Rat: float = (Num + 3) / 5
	if self.scale != Vector2(_Rat, _Rat):
		self.scale = Vector2(_Rat, _Rat)
	set_physics_process(true)
func _Num_Change(_Add):
	Num += _Add

	if Num > NumMax:
		Num = NumMax
	elif Num <= 0:
		Num = 0
		call_del()
	var _LEVELINFO = GameLogic.cur_levelInfo

	var _TYPE: int = 0
	if GameLogic.curLevelList.has("难度-污渍水渍") or _LEVELINFO.GamePlay.has("难度-污渍水渍"):
		if Num >= 5:
			match TYPE:
				0:
					$Icon / AnimationPlayer.play("Stain")
					_TYPE = 1
				_:
					$Icon / AnimationPlayer.play("Water")
					_TYPE = 2
		else:
			$Icon / AnimationPlayer.play("init")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Num_Change", [Num, _TYPE])
	var _Rat: float = (Num + 3) / 5
	if self.scale != Vector2(_Rat, _Rat):
		self.scale = Vector2(_Rat, _Rat)

func call_del():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_del")
	if is_in_group("WaterStain"):
		remove_from_group("WaterStain")
	self.queue_free()

func call_puppet_Color_Mixed(_modulate_Mix):
	WaterSprite.set_modulate(_modulate_Mix)
	WaterColor = _modulate_Mix

func _Color_Mixed(_WaterColor):

	var _modulate_Mix: Color
	if WaterColor != _WaterColor:
		if WaterColor == Color8(137, 228, 245, 100):
			WaterColor = _WaterColor
			WaterColor.a8 = 100
		elif _WaterColor == Color8(137, 228, 245, 100):
			_WaterColor = WaterColor
			_WaterColor.a8 = 100
		_modulate_Mix = (WaterColor + _WaterColor) / 2
		WaterSprite.set_modulate(_modulate_Mix)
		WaterColor = _modulate_Mix
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_Color_Mixed", [_modulate_Mix])

func _on_Area2D_area_entered(_Area):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _Area.has_method("_Num_Change"):
		if _Area.TYPE != TYPE:
			return
		if Num == _Area.Num:
			var _selfID = self.get_instance_id()
			var _AreaID = _Area.get_instance_id()

			if _selfID < _AreaID:
				_Num_Change(_Area.Num)
				_Color_Mixed(_Area.WaterColor)
				_Area.call_del()
				pass
		elif Num > _Area.Num:

			if _Area.Num <= 5:
				_Num_Change(_Area.Num)
				_Area.call_del()

func _on_WaterStain_body_entered(_body):
	if _body.has_method("_PlayerNode"):
		if not WaterColor:
			return
		_body.FootWaterColor = WaterColor
		if _body.FootPrint < Num:
			if _body.Stat.Skills.has("技能-河狸基础"):
				_body.FootPrint = Num * 10
				_body.call_FootPrint_Logic()
			else:
				_body.FootPrint = Num
		match TYPE:
			2:
				_body.Stat.call_slip_in(Num)
				_body.Stat.call_stick_in(Num)
			1:
				_body.Stat.call_slip_in(Num)
			0:
				_body.Stat.call_stick_in(Num)

func _on_WaterStain_body_exited(_body):
	if _body.has_method("_PlayerNode"):
		match TYPE:
			2:
				_body.Stat.call_slip_end()
				_body.Stat.call_stick_end()
			1:
				_body.Stat.call_slip_end()
			0:
				_body.Stat.call_stick_end()
