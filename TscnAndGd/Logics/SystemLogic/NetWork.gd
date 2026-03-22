extends Node












var isHost = false
const DEFAULT_PORT = 8070

const MAX_PEERS = 4

var player_name = "playerName"

var players = {}
var players_ready = []

puppet var data = {}
puppet var checkServer = false

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()

signal game_error(what)
signal dataload_succeeded()

signal _player_disconnected(id)

signal _new_player_ready()

signal info_newplayer_connect()
signal info_newplayer_join(_name)
signal info_player_disconnect(_name)

var _server = null
var _isSomeBodyPuzzle = 0

func _ready():
	var _connect
	_connect = get_tree().connect("network_peer_connected", self, "_player_connected")
	_connect = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_connect = get_tree().connect("connected_to_server", self, "_connected_ok")
	_connect = get_tree().connect("connection_failed", self, "_connected_fail")
	_connect = get_tree().connect("server_disconnected", self, "_server_disconnected")
	_connect = self.connect("player_list_changed", self, "_player_list_remote")

func return_host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()

	var err = host.create_server(DEFAULT_PORT, MAX_PEERS)
	if err != OK:


		print("服务器创建失败", err)
	else:

		get_tree().set_network_peer(host)
		print("服务器创建成功。")
		register_player(1, player_name)
	return err

func join_game(ip, new_player_name):
	player_name = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	print("加入服务器。")

puppet func _net_getData(master_Data):

	emit_signal("dataload_succeeded")
	pass

puppet func _puppet_player_list_changed(newPlayers):
	players = newPlayers
	players_ready = players.keys()
	emit_signal("_new_player_ready")

func _player_disconnected(id):
	print("_player_disconnected")
	emit_signal("_player_disconnected", id)
	if players.has(id):
		unregister_player(id)

	pass

func _connected_ok():

	print("_connected_ok。")
	emit_signal("connection_succeeded")

func _connected_fail():
	print("_connected_fail。")
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")

puppet func _server_disconnected():
	print("_server_disconnected")

	var root = get_tree().get_root()
	if root.has_node("world"):

		var _check = get_tree().change_scene("res://TscnAndGd/UI/LoadingUI.tscn")
		root.get_node("world").queue_free()

	emit_signal("game_error", "Server disconnected")

remote func _player_connected(id):

	print("玩家正在连接，玩家id：", id)
	emit_signal("info_newplayer_connect")


	pass
remote func register_player(id, new_player_name):
	players[id] = new_player_name
	print("玩家列表：", players)
	emit_signal("player_list_changed")
	emit_signal("info_newplayer_join", new_player_name)
func unregister_player(id):
	var _name = players[id]
	emit_signal("info_player_disconnect", _name)
	players.erase(id)
	emit_signal("player_list_changed")
	print("玩家断开 更新玩家列表：", players)
master func _player_list_remote():

	players_ready = players.keys()
	for i in players_ready.size():
		var playerID = players_ready[i]
		if playerID != get_tree().get_network_unique_id():
			rpc_id(playerID, "_puppet_player_list_changed", players)
		pass
puppet func _puppet_loadingSuccessed():
	var id = get_tree().get_network_unique_id()
	print("_puppet_loadingSuccessed", id)

	rpc_id(1, "register_player", id, player_name)
	rpc("_remote_PeerLoadingSuccessed", id)

remote func _remote_PeerLoadingSuccessed(id):
	print("_master_PeerLoadingSuccessed", id)


	var YSort_Player = get_tree().get_root().get_node("world/YSort/player")
	if YSort_Player.has_node(str(get_tree().get_network_unique_id())):
		var player = YSort_Player.get_node(str(get_tree().get_network_unique_id()))
		player._remote_PlayerInfo_sync(id)

puppet func _call_playerinfosync(id):
	var YSort_Player = get_tree().get_root().get_node("world/YSort/player")
	var player = YSort_Player.get_node(str(get_tree().get_network_unique_id()))
	player._master_PlayerInfo_sync(id)
