extends Button

var SteamID: int = 0

var HeadIcon: Image
var GameName: String

onready var LatencyLabel = $Control / Label / LatencyLabel
onready var KickBut = $KickBut
onready var LeaveBut = $LeaveBut
onready var MasterLabel = $MasterLabel

onready var TYPEANI = $TYPE
var IsMaster: bool
func _ready():
	var _con = Steam.connect("avatar_loaded", self, "avatar_loaded")
	var _Latency = SteamLogic.connect("Latency", self, "_LatencyLabel_set")
	LeaveBut.hide()
	SteamLogic.call_Latency()
func call_init(_Dic):
	SteamID = _Dic["id"]
	$NameLabel.text = _Dic["name"]

	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, SteamID)

	if SteamID == SteamLogic.MasterID:

		IsMaster = true
		MasterLabel.text = "房主"
		TYPEANI.play("Master")
		KickBut.hide()
		LeaveBut.hide()
	if SteamID == SteamLogic.STEAM_ID:
		if SteamLogic.LOBBY_IsMaster:
			IsMaster = true
			MasterLabel.text = "房主"
			TYPEANI.play("Master")
			KickBut.hide()

		else:

			TYPEANI.play("Master")
			KickBut.hide()
			LeaveBut.show()
	else:
		TYPEANI.play("Puppet")
		if SteamLogic.LOBBY_IsMaster:
			KickBut.show()
		else:
			KickBut.hide()
	$KickBut / X.visible = false
	$LeaveBut / X.visible = false
func avatar_loaded(_id, size, buffer):
	if _id == SteamID and HeadIcon == null:
		HeadIcon = Image.new()
		var Tex = ImageTexture.new()
		HeadIcon.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
		Tex.create_from_image(HeadIcon)
		$TextureRect.texture = Tex

func _LatencyLabel_set(_STEAMID, _INFO: Array):
	if SteamID != _STEAMID:
		return
	var _Latency: int = _INFO[0]
	var LATENCY = int(float(_Latency) / 1000)
	LatencyLabel.text = str(LATENCY) + " ms"
	if LATENCY <= 255:
		LatencyLabel.modulate = Color8(LATENCY, 255, 0, 255)
	elif LATENCY <= (255 + 255):
		LatencyLabel.modulate = Color8(255, 255 - (LATENCY - 255), 0, 255)
	else:
		LatencyLabel.modulate = Color8(255, 0, 0, 255)

func _on_KickBut_pressed():

	if not SteamLogic.LOBBY_IsMaster:
		_on_LeaveBut_pressed()
		return

	SteamLogic.call_kick_player(SteamID)

	pass

func _on_LeaveBut_pressed():

	SteamLogic.call_LeaveLobby(true, SteamLogic.LOBBY_ID)



func _on_focus_entered():
	self.pressed = true
	$KickBut / X.show()
	$LeaveBut / X.show()

func _on_focus_exited():
	$KickBut / X.hide()
	$LeaveBut / X.hide()
