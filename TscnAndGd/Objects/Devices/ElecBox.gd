extends StaticBody2D

var _List: Array
onready var But_A = $But / A
var CanUse: bool = false
onready var aniPlayer = $AniNode / OpenAni
func _ready():
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

func _BlackOut(_Switch):
	match _Switch:
		true:

			$WarningNode.FixPoint = 0
			$WarningNode.call_NeedFix()
			CanUse = true
			$ElecAudio / AnimationPlayer.play("BlackOut")
		false:
			if CanUse == true:
				$ElecAudio / AnimationPlayer.play("Fix")
				CanUse = false
				$WarningNode.call_NeedFix_End()
func _on_Area2D_body_entered(_body):
	if _body.has_method("_PlayerNode"):

		_List.append(_body)
		call_OpenAni()
func _on_Area2D_body_exited(_body):
	if _List.has(_body):
		_List.erase(_body)
	call_OpenAni()

func call_OpenAni():
	if _List.size() > 0:
		if $AniNode / OpenAni.assigned_animation != "open":
			$AniNode / OpenAni.play("open")
	else:
		if $AniNode / OpenAni.assigned_animation == "open":
			$AniNode / OpenAni.play("close")
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 2:
			if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				But_A.call_player_out(_Player.cur_Player)
		- 1:
			if CanUse:
				if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					But_A.call_player_in(_Player.cur_Player)

		0, "A":
			if CanUse:
				if _value in [1, - 1]:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						GameLogic.Con.call_vibration(_Player.cur_Player, 0.7, 0.7, 0.1)
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						var _PLAYERPATH = _Player.get_path()
						SteamLogic.call_master_node_sync(self, "call_master_logic", [_PLAYERPATH])
					var _FIXED = $WarningNode.call_Fix_ElecBox(_Player)
					if _FIXED:
						CanUse = false

					return true
func call_master_logic(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	var _FIXED = $WarningNode.call_Fix_ElecBox(_Player)
	if _FIXED:
		CanUse = false
