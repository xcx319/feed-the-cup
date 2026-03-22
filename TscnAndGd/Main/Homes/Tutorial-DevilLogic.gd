extends Area2D

var cur_bool: bool
func _ready():
	self.add_to_group("Tutorial_Devils")
	if get_parent().name == "Devil-Latter":
		if not GameLogic.is_connected("CanStart", self, "_Latter_Hide"):
			var _con = GameLogic.connect("CanStart", self, "_Latter_Hide")
func _Latter_Hide():
	if get_parent().name == "Devil-Latter":
		if GameLogic.Can_Start:

			if get_parent().has_node("Ani"):
				if get_parent().get_node("Ani").assigned_animation == "show":
					get_parent().get_node("Ani").play("hide")
func call_hide():
	if not cur_bool:
		if get_parent().has_node("Ani"):
			if get_parent().get_node("Ani").assigned_animation == "show":
				get_parent().get_node("Ani").play("hide")

func _on_Area2D_body_entered(_body):
	if _body.has_method("_PlayerNode"):
		if _body.cur_Player in [1, SteamLogic.STEAM_ID]:
			cur_bool = true
			if get_parent().name == "Devil-Latter":
				if GameLogic.cur_level:
					return
			if get_parent().name == "Devil-Car":
				if not GameLogic.cur_level:
					return
			get_tree().call_group("Tutorial_Devils", "call_hide")
			if get_parent().has_node("Ani"):
				if get_parent().get_node("Ani").assigned_animation != "show":
					get_parent().get_node("Ani").play("show")

func _on_Area2D_body_exited(_body):
	if _body.has_method("_PlayerNode"):
		if _body.cur_Player in [1, SteamLogic.STEAM_ID]:
			cur_bool = false
