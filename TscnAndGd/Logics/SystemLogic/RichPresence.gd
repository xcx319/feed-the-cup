extends Node

var RICHDIC: Dictionary = {
	0: "#StatusWithoutScore",
	1: "#StatusWithScore",
	2: "#Status_AtMainMenu",
	3: "#Status_WaitingForMatch",
	4: "#Status_Winning",
	5: "#Status_Losing",
	6: "#Status_Tied"
}
func call_SetRich():











	if not SteamLogic.STEAM_BOOL:
		return
	if GameLogic.LoadingUI.IsMain:

		var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_AtMainMenu")
		var _DIS: bool = Steam.setRichPresence("#Status_AtMainMenu", "#Status_AtMainMenu")

	elif GameLogic.LoadingUI.IsLevel:
		var _DAY: String = "#Status_Day" + str(GameLogic.cur_Day)
		if GameLogic.cur_Day == 0:
			_DAY = "#Status_Day1"
		var _DISPLAY: bool = Steam.setRichPresence("steam_display", _DAY)
		var _GROUP: bool = Steam.setRichPresence("steam_player_group", str(SteamLogic.LOBBY_ID))
		var _SIZE: bool = Steam.setRichPresence("steam_player_group_size", str(SteamLogic.LOBBY_MEMBERS.size()))


	elif GameLogic.LoadingUI.IsHome:
		if SteamLogic.LOBBY_ID == 0:
			var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_Solo")
			return
		var _GROUP: bool = Steam.setRichPresence("steam_player_group", str(SteamLogic.LOBBY_ID))
		var _SIZE: bool = Steam.setRichPresence("steam_player_group_size", str(SteamLogic.LOBBY_MEMBERS.size()))
		if SteamLogic.CanJoin and SteamLogic.LOBBY_IsMaster and SteamLogic.LOBBY_MEMBERS.size() < 4:

			var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_MasterWaiting")

		elif SteamLogic.CanJoin and SteamLogic.LOBBY_IsMaster and SteamLogic.SLOT_2 != 0 and SteamLogic.SLOT_3 != 0 and SteamLogic.SLOT_4 != 0:

			var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_MasterFull")

		elif SteamLogic.CanJoin and not SteamLogic.LOBBY_IsMaster and SteamLogic.LOBBY_MEMBERS.size() < 4:

			var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_Waiting")

		elif SteamLogic.CanJoin and not SteamLogic.LOBBY_IsMaster and SteamLogic.LOBBY_MEMBERS.size() == 4:

			var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_Full")

		elif not SteamLogic.CanJoin and SteamLogic.LOBBY_IsMaster:
			var _DISPLAY: bool = Steam.setRichPresence("steam_display", "#Status_Solo")
