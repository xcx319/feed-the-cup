extends Head_Object
onready var ButShow = get_node("Button/A")

var cur_Used: bool = false

func _ready():
	if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		self.queue_free()

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
