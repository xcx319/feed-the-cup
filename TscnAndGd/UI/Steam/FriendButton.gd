extends Button

var SteamID: int = 0
var OnLineStatus: int = 0
var HeadIcon: Image
var FriendGameInfo: Dictionary
var GameName: String

onready var TYPEANI = $TYPE
onready var InviteWaitTimer = $Invite / Timer
onready var InviteBut = $Invite
onready var JoinBut = $Control / Join
onready var LOBBYMEMBERLABEL = $Control / Label / MEMBER

signal _InviteID(_SteamID)

func _ready():
	var _con = Steam.connect("avatar_loaded", self, "avatar_loaded")

func call_init(_Dic, _FriendGameInfo):
	FriendGameInfo = _FriendGameInfo
	SteamID = _Dic["id"]
	$NameLabel.text = _Dic["name"]
	OnLineStatus = _Dic["status"]
	_SetStatus()
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, SteamID)
	if FriendGameInfo.has("id"):
		match FriendGameInfo["id"]:
			2336220:
				$StatusLabel.text = GameLogic.CardTrans.get_message("信息-游玩杯杯")
				var _LOBBYID = int(FriendGameInfo["lobby"])
				var _LOBBYOWNER = Steam.getLobbyOwner(_LOBBYID)
				var _LOBBYMEMBERMAX = 4

				var _LOBBYMEMBERNUM: int = int(Steam.getLobbyData(_LOBBYID, "NUM"))
				if _LOBBYMEMBERNUM == 0:
					_LOBBYMEMBERNUM = 1
				var _LOBBYDATA = Steam.requestLobbyData(int(_LOBBYID))

				LOBBYMEMBERLABEL.text = str(_LOBBYMEMBERNUM) + "/" + str(_LOBBYMEMBERMAX)
				if _LOBBYID == SteamLogic.LOBBY_ID:
					TYPEANI.play("INLOBBY")
				else:
					TYPEANI.play("CANJOIN")

					if _LOBBYID != 0 and Steam.getAppID() == FriendGameInfo["id"]:
						if _LOBBYMEMBERNUM >= 4:
							JoinBut.disabled = true
						else:
							JoinBut.disabled = false
					else:

						JoinBut.disabled = true
			2400400:

				$StatusLabel.text = GameLogic.CardTrans.get_message("信息-游玩杯杯DEMO")
				var _LOBBYID = int(FriendGameInfo["lobby"])
				var _LOBBYOWNER = Steam.getLobbyOwner(_LOBBYID)
				var _LOBBYMEMBERMAX = 4
				var _LOBBYMEMBERNUM: int = int(Steam.getLobbyData(_LOBBYID, "NUM"))
				if _LOBBYMEMBERNUM == 0:
					_LOBBYMEMBERNUM = 1
				var _LOBBYDATA = Steam.requestLobbyData(int(_LOBBYID))

				LOBBYMEMBERLABEL.text = str(_LOBBYMEMBERNUM) + "/" + str(_LOBBYMEMBERMAX)
				if _LOBBYID == SteamLogic.LOBBY_ID:
					TYPEANI.play("INLOBBY")
				else:
					TYPEANI.play("CANJOIN")

					if _LOBBYID != 0 and Steam.getAppID() == FriendGameInfo["id"]:
						if _LOBBYMEMBERNUM >= 4:
							JoinBut.disabled = true
						else:
							JoinBut.disabled = false
					else:

						JoinBut.disabled = true
			_:
				$StatusLabel.text = GameLogic.CardTrans.get_message("信息-游玩其他")
				TYPEANI.play("NOLOBBY")
	else:
		TYPEANI.play("NOLOBBY")
	$Invite / A.visible = false
	$Control / Join / X.visible = false
func avatar_loaded(_id, size, buffer):
	if _id == SteamID and HeadIcon == null:
		HeadIcon = Image.new()
		var Tex = ImageTexture.new()
		HeadIcon.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
		Tex.create_from_image(HeadIcon)
		$TextureRect.texture = Tex

func _SetStatus():

	match OnLineStatus:
		0:
			$StatusLabel.text = GameLogic.CardTrans.get_message("信息-离线")
		1:
			$StatusLabel.text = GameLogic.CardTrans.get_message("信息-在线")
		3, 4:
			$StatusLabel.text = GameLogic.CardTrans.get_message("信息-离开")
		_:
			print(SteamID, "角色情况：", OnLineStatus)

func _on_Control_pressed():

	emit_signal("_InviteID", SteamID)

func _on_Join_pressed():
	if JoinBut.disabled:
		return
	if Steam.getAppID() != FriendGameInfo["id"]:
		return
	JoinBut.disabled = true
	var _LOBBYID = FriendGameInfo["lobby"]
	if int(_LOBBYID):
		var _VERSION = Steam.getLobbyData(_LOBBYID, "VERSION")
		if _VERSION == GameLogic.Save.VERSION:
			SteamLogic._join_Lobby(_LOBBYID)
		else:
			SteamLogic.JOIN.call_VERSION_ANI(_VERSION)

func _on_Invite_pressed():
	if InviteBut.disabled:
		return
	InviteBut.disabled = true
	InviteWaitTimer.start(0)
	emit_signal("_InviteID", SteamID)

func _on_InviteTimer_timeout():
	InviteBut.disabled = false

func _on_focus_entered():
	self.pressed = true
	$Invite / A.show()
	$Control / Join / X.show()

func _on_focus_exited():
	$Invite / A.visible = false
	$Control / Join / X.visible = false
