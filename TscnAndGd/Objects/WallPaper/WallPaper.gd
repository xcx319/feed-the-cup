extends Node2D

var playerlist = ["1", "2", str(SteamLogic.STEAM_ID)]
var cur_playerList: Array

onready var aniPlayer = $AniNode / AnimationPlayer

func _on_player_entered(body: Node) -> void :
	if aniPlayer.has_animation("hide"):
		if body.name in playerlist:
			cur_playerList.append(body)
			if cur_playerList.size():
				aniPlayer.play("hide")

func _on_player_exited(body: Node) -> void :
	if aniPlayer.has_animation("hide"):
		if body.name in playerlist:
			if cur_playerList.has(body):
				cur_playerList.erase(body)
			if not cur_playerList.size():
				aniPlayer.play_backwards("hide")
