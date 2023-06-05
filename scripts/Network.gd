extends Node


signal player_registered(id)
signal player_unregistered(id)
const PORT: int = 4639
const MAX_CLIENTS: int = 8

var my_player: Dictionary = {
	"name": "default_name"
}
var other_players: Dictionary = {}


func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")


func init_server(info: Dictionary):
	# Setup UPNP
	var upnp = UPNP.new()
	var err = upnp.discover()
	if err == OK:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			upnp.get_gateway().add_port_mapping(PORT, PORT, "VoxelFun Multiplayer", "UDP")
			upnp.get_gateway().add_port_mapping(PORT, PORT, "VoxelFun Multiplayer", "TCP")
	else:
		push_error("UPNP error: %d" % err)
	# Setup multiplayer
	my_player = info
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_CLIENTS)
	get_tree().network_peer = peer


func init_client(info: Dictionary, address: String):
	my_player = info
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(address, PORT)
	get_tree().network_peer = peer


remote func register_player(id: int, info: Dictionary):
	other_players[id] = info
	emit_signal("player_registered", id)


func _on_peer_connected(id: int):
	rpc_id(id, "register_player", get_tree().get_network_unique_id(), my_player)


func _on_peer_disconnected(id: int):
	# warning-ignore:return_value_discarded
	other_players.erase(id)
	emit_signal("player_unregistered", id)
