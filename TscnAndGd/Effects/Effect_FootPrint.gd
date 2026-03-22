extends Area2D

onready var _Sprite = get_node("texture/FootPrint")
var Concentration: int setget _Concentration_Logic
var WaterColor setget _WaterColor_Logic
var TYPE: int = 0
var _CHECKINT: int = 0
func _ready():
	call_init()

func call_CHECK():
	_CHECKINT = - 1

func call_init():
	match TYPE:
		0:
			var _rand = GameLogic.return_RANDOM() % 9 + 1
			var _Path = "res://Resources/Effects/effect_pack.sprites/" + "Stain_pads_" + str(_rand) + ".tres"
			var _Tex = load(_Path)
			_Sprite.set_texture(_Tex)
		1:
			var _rand = GameLogic.return_RANDOM() % 9 + 1
			var _Path = "res://Resources/Effects/effect_pack.sprites/" + "Stain_little_" + str(_rand) + ".tres"
			var _Tex = load(_Path)
			_Sprite.set_texture(_Tex)
			$CollisionShape2D / AnimationPlayer.play("Slime")
	if _CHECKINT > 0:
		$Ani.play("Empty")
func _Concentration_Logic(_Con):
	Concentration = _Con
	var _Base: float = 1
	if WaterColor == Color8(137, 228, 245, 100):

		_Base = 2
	var _Rate: float = float(Concentration) / 3
	if _Rate > 1:
		_Rate = 1

	var _a = get_node("texture").modulate.a

	_a = _a * _Rate
	get_node("texture").modulate.a = _a

func _WaterColor_Logic(_Color: Color):
	WaterColor = _Color
	_Sprite.set_modulate(_Color)

func call_del():
	self.queue_free()

func call_clean(_Switch, _OBJ, _Mult):
	match _Switch:
		true:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_del")

			call_del()
