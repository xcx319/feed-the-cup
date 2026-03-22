extends Sprite

func call_Tex():
	var _rand = GameLogic.return_RANDOM() % 9 + 1
	var _TRESNAME = "res://Resources/Effects/effect_pack.sprites/Stain_pads_"
	var _Path = _TRESNAME + str(_rand) + ".tres"
	var _Tex = load(_Path)
	set_texture(_Tex)

func call_Rotation():
	var _Ro = GameLogic.return_RANDOM() % 60 - 30
	rotation_degrees = _Ro

func call_del():
	if self.is_inside_tree():
		self.queue_free()

func call_Player(_Player):
	if not self.is_inside_tree():
		return
	if $Player.has_animation(str(_Player)):
		call_Tex()
		call_Rotation()
		$Player.play(str(_Player))
		$AnimationPlayer.play("init")
