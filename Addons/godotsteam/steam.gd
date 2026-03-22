extends Node

onready var Steam = preload("res://addons/godotsteam/godotsteam.gdns").new()

func _init() -> void :

	OS.set_environment("SteamAppId", str(2336220))
	OS.set_environment("SteamGameId", str(2336220))

var IS_OWNED: bool = false
var IS_ONLINE: bool = false
var IS_FREE_WEEKEND: bool = false
var STEAM_ID: int = 0
var STEAM_NAME: String = ""

func _ready() -> void :

	var INIT: Dictionary = Steam.steamInit(false)
	print("[STEAM] Did Steam initialize?: " + str(INIT))
	if INIT["status"] != 1:

		print("[STEAM] Failed to initialize Steam. " + str(INIT["verbal"]) + " Shutting down...")


	IS_ONLINE = Steam.loggedOn()


	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()


	IS_OWNED = Steam.isSubscribed()
	IS_FREE_WEEKEND = Steam.isSubscribedFromFreeWeekend()

func _process(_delta: float) -> void :

	Steam.run_callbacks()
