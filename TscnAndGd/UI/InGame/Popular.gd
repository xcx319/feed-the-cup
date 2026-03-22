extends HBoxContainer

func _ready() -> void :
	var _check = GameLogic.connect("PopularSYCN", self, "Popular_Set")

func Popular_Set():


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PopularLogic")
	call_PopularLogic()
func call_PopularLogic():
	var _StarList = self.get_children()
	if GameLogic.cur_StoreStar <= 2:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i == 0:
				_Node.get_node("TextureProgress").value = GameLogic.cur_StoreStar
			else:
				_Node.get_node("TextureProgress").value = 0
	elif GameLogic.cur_StoreStar <= 4:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 1:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 1:
				_Node.get_node("TextureProgress").value = GameLogic.cur_StoreStar - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif GameLogic.cur_StoreStar <= 6:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 2:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 2:
				var _VALUE = 1
				match GameLogic.cur_StoreStar:
					6:
						_VALUE = 2
				_Node.get_node("TextureProgress").value = _VALUE
			else:
				_Node.get_node("TextureProgress").value = 0
	elif GameLogic.cur_StoreStar <= 8:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 3:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 3:
				var _VALUE = 1
				match GameLogic.cur_StoreStar:
					8:
						_VALUE = 2
				_Node.get_node("TextureProgress").value = _VALUE
			else:
				_Node.get_node("TextureProgress").value = 0
	elif GameLogic.cur_StoreStar <= 10:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 4:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 4:
				var _VALUE = 1
				match GameLogic.cur_StoreStar:
					10:
						_VALUE = 2
				_Node.get_node("TextureProgress").value = _VALUE
			else:
				_Node.get_node("TextureProgress").value = 0
