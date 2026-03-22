extends Control

onready var _FriendButTSCN = preload("res://TscnAndGd/UI/Steam/FriendButton.tscn")

func call_Load():
	var _Array = Steam.getUserSteamFriends()

	for _Friend in _Array:
		var _FriendBUT = _FriendButTSCN.instance()
		$Scroll / VBox.add_child(_FriendBUT)
		_FriendBUT.call_init(_Friend)
		_FriendBUT.connect("_InviteID", self, "_InviteLogic")

func _InviteLogic(_id):

	SteamLogic.call_invite(_id)
	pass
