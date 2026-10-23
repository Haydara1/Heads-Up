extends Node

const PORT := 7000
const MAX_CLIENTS := 7

signal lobby_updated(players: Dictionary)
signal connection_status(message: String)

var players: Dictionary = {}
var player_name := "Player"

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(username: String) -> Error:
	player_name = username

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer
	players[1] = {"name": player_name, "score": 0}
	lobby_updated.emit(players.duplicate(true))
	return OK

func join_game(ip: String, username: String) -> Error:
	player_name = username

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip.strip_edges(), PORT)
	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer
	connection_status.emit("Connecting...")
	return OK

func _on_connected() -> void:
	register_player.rpc_id(1, player_name)
	connection_status.emit("Connected!")

func _on_connection_failed() -> void:
	connection_status.emit("Connection failed.")
	disconnect_game()

func _on_server_disconnected() -> void:
	connection_status.emit("Host disconnected.")
	disconnect_game()

func _on_peer_connected(_id: int) -> void:
	pass

func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server():
		return

	players.erase(id)
	broadcast_lobby.rpc(players)

@rpc("any_peer", "call_remote", "reliable")
func register_player(username: String) -> void:
	if not multiplayer.is_server():
		return

	var id := multiplayer.get_remote_sender_id()

	# Basic input validation.
	username = username.strip_edges()
	if username.is_empty() or username.length() > 20:
		return

	players[id] = {"name": username, "score": 0}

	# Send the complete lobby to every peer, including the host.
	broadcast_lobby.rpc(players)

@rpc("authority", "call_local", "reliable")
func broadcast_lobby(updated_players: Dictionary) -> void:
	players = updated_players.duplicate(true)
	lobby_updated.emit(players)

func disconnect_game() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	lobby_updated.emit(players)


func get_local_ip() -> String:
	for address in IP.get_local_addresses():
		# Look for a typical local IPv4 address
		if address.begins_with("192.168.") \
		or address.begins_with("10.") \
		or address.begins_with("172."):
			return address

	return IP.get_local_addresses()[0]
