
extends Node

signal state_changed(state: Dictionary)
signal words_changed(words: Dictionary)

const GAME_SCENE := "res://scenes/gameplay.tscn"
const LOBBY_SCENE := "res://scenes/connected_lobby.tscn"

const PACKS := {
	"General": [
		"Batman", "Spider-Man", "Sherlock Holmes",
		"Harry Potter", "Mario", "Superman", "Pikachu"
	],
	"Animals": [
		"Lion", "Elephant", "Penguin",
		"Giraffe", "Dolphin", "Kangaroo"
	]
}

var players_in_game: Array[int] = []
var secret_words: Dictionary = {}
var confirmed_order: Array[int] = []

var selected_pack := "General"
var running := false

var latest_state: Dictionary = {}
var latest_words: Dictionary = {}


# Called by the host from the connected lobby.
func start_game(pack_name: String = "General") -> void:
	if not multiplayer.is_server():
		return

	if NetworkManager.players.size() < 2:
		return

	if not PACKS.has(pack_name):
		return

	selected_pack = pack_name
	players_in_game.clear()
	secret_words.clear()
	confirmed_order.clear()

	for id in NetworkManager.players.keys():
		players_in_game.append(int(id))

	players_in_game.sort()

	var pack: Array = PACKS[selected_pack]

	for id in players_in_game:
		secret_words[id] = pack.pick_random()

		# Preserve scores from previous rounds.
		if not NetworkManager.players[id].has("score"):
			NetworkManager.players[id]["score"] = 0

	running = true

	change_to_game.rpc()
	_broadcast_state()
	_send_words_to_everyone()


@rpc("authority", "call_local", "reliable")
func change_to_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


# Each player presses Confirm when they have guessed their own word.
func submit_confirmation() -> void:
	if not running:
		return

	var my_id := multiplayer.get_unique_id()

	if multiplayer.is_server():
		_handle_confirmation(my_id)
	else:
		request_confirmation.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func request_confirmation() -> void:
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	_handle_confirmation(sender_id)


func _handle_confirmation(id: int) -> void:
	if not running:
		return

	if not players_in_game.has(id):
		return

	# Prevent duplicate confirmations.
	if confirmed_order.has(id):
		return

	# First player gets N-1, second gets N-2, etc.
	var points := players_in_game.size() - 1 - confirmed_order.size()
	NetworkManager.players[id]["score"] += points
	confirmed_order.append(id)

	_broadcast_state()

	# Everyone has confirmed: return to the lobby.
	if confirmed_order.size() == players_in_game.size():
		running = false
		_broadcast_state()
		return_to_lobby.rpc()


func _broadcast_state() -> void:
	var state := {
		"players": NetworkManager.players.duplicate(true),
		"confirmed_order": confirmed_order.duplicate(),
		"running": running,
		"selected_pack": selected_pack
	}

	receive_state(state)
	receive_state.rpc(state)


func _words_for_player(viewer_id: int) -> Dictionary:
	var visible_words: Dictionary = {}

	for id in players_in_game:
		if id == viewer_id:
			visible_words[id] = ""
		else:
			visible_words[id] = secret_words[id]

	return visible_words


func _send_words_to_everyone() -> void:
	for id in players_in_game:
		_send_words_to_player(id)


func _send_words_to_player(id: int) -> void:
	var words := _words_for_player(id)

	if id == 1:
		receive_words(words)
	else:
		receive_words.rpc_id(id, words)


func request_sync_for_local_player() -> void:
	if multiplayer.is_server():
		_send_sync(1)
	else:
		request_sync.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func request_sync() -> void:
	if not multiplayer.is_server():
		return

	_send_sync(multiplayer.get_remote_sender_id())


func _send_sync(id: int) -> void:
	if not running or not players_in_game.has(id):
		return

	var state := {
		"players": NetworkManager.players.duplicate(true),
		"confirmed_order": confirmed_order.duplicate(),
		"running": running,
		"selected_pack": selected_pack
	}

	if id == 1:
		receive_state(state)
	else:
		receive_state.rpc_id(id, state)

	_send_words_to_player(id)


@rpc("authority", "call_remote", "reliable")
func receive_state(state: Dictionary) -> void:
	latest_state = state.duplicate(true)
	running = bool(state.get("running", false))

	var updated_players: Dictionary = state.get("players", {})
	NetworkManager.players = updated_players.duplicate(true)

	state_changed.emit(latest_state)
	NetworkManager.lobby_updated.emit(NetworkManager.players)


@rpc("authority", "call_remote", "reliable")
func receive_words(words: Dictionary) -> void:
	latest_words = words.duplicate(true)
	words_changed.emit(latest_words)


@rpc("authority", "call_local", "reliable")
func return_to_lobby() -> void:
	get_tree().change_scene_to_file(LOBBY_SCENE)
