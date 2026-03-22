extends Node

const DEFAULT_PORT = 8070
const MAX_PEERS = 2

var Player_ID_List: Array

func call_HostCreated():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().network_peer = net
	print("call_HostCreated")
	return true
func call_Join(_HostIP):
	var net = NetworkedMultiplayerENet.new()
	net.create_client(_HostIP, DEFAULT_PORT)
	get_tree().network_peer = net
	print("call_Join")
func _Success(_id):
	print("network_peer_connected ID:", _id)
	Player_ID_List.append(_id)
