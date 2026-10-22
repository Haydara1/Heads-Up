
extends Node

signal state_changed(state: Dictionary)
signal word_changed(word: String)

const GAME_SCENE := "res://scenes/gameplay.tscn"

# The host chooses one of these packs in the lobby.
const PACKS := {
	"General": [
		"Batman",
		"Spider-Man",
		"Sherlock Holmes",
		"Harry Potter",
		"Mario",
		"Superman",
        "Pikachu"
	],
	"Animals": [
		"Lion",
		"Elephant",
		"Penguin",
		"Giraffe",
		"Dolphin",
        "Kangaroo"
	]
}

var players_in_game: Array[int] = []
var secret_words: Dictionary = {}

var current_turn_peer := -1
var selected_pack := "General"
var running := false
var turn_resolved := false

# Keep the latest information so the UI can retrieve it
# even if the game starts before the scene finishes loading.
var latest_state: Dictionary = {}
var latest_word := ""


# Called by the host's Start Game button.
func start_game(pack_name: String = "General") -> void:
	if not multiplayer.is_server():
		return

	if NetworkManager.players.size() < 2:
		print("Need at least two players.")
		return

	if not PACKS.has(pack_name):
		print("Unknown pack: ", pack_name)
		return

	selected_pack = pack_name
	players_in_game.clear()
	secret_words.clear()

	for id in NetworkManager.players.keys():
		players_in_game.append(int(id))

	players_in_game.sort()

	var pack: Array = PACKS[selected_pack]

	for id in players_in_game:
		secret_words[id] = pack.pick_random()
		NetworkManager.players[id]["score"] = 0

	current_turn_peer = players_in_game[0]
	running = true
	turn_resolved = false

	# Change scenes on the host and all connected clients.
	change_to_game.rpc()

	_broadcast_state()
	_send_words()


# Everyone changes to the gameplay scene together.
@rpc("authority", "call_local", "reliable")
func change_to_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


# Called when a player presses the Correct button.
func submit_correct_guess() -> void:
	if not running or turn_resolved:
		return

	var my_id := multiplayer.get_unique_id()

	# The host is also a player and can confirm guesses.
	if multiplayer.is_server():
		_handle_confirmation(my_id)
	else:
		confirm_guess.rpc_id(1)


# Clients ask the host to validate their confirmation.
@rpc("any_peer", "call_remote", "reliable")
func confirm_guess() -> void:
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	_handle_confirmation(sender_id)


func _handle_confirmation(sender_id: int) -> void:
	if not running or turn_resolved:
		return

	# The active player cannot confirm their own guess.
	if sender_id == current_turn_peer:
		return

	# Only players in this game can confirm.
	if not players_in_game.has(sender_id):
		return

	if not NetworkManager.players.has(current_turn_peer):
		return

	turn_resolved = true
	NetworkManager.players[current_turn_peer]["score"] += 1

	_next_turn()


func _next_turn() -> void:
	var index := players_in_game.find(current_turn_peer)
	turn_resolved = false

	current_turn_peer = players_in_game[
		(index + 1) % players_in_game.size()
	]

	_broadcast_state()
	_send_words()


# Public information: scores and whose turn it is.
func _broadcast_state() -> void:
	var state := {
		"players": NetworkManager.players.duplicate(true),
		"current_turn_peer": current_turn_peer,
		"running": running
	}

	# Update the host locally and all clients remotely.
	receive_state(state)
	receive_state.rpc(state)


# Send the current word to everyone EXCEPT the active player.
func _send_words() -> void:
	var word: String = secret_words[current_turn_peer]

	for id in players_in_game:
		var word_for_player := word

		if id == current_turn_peer:
			word_for_player = ""

		_send_word_to_peer(id, word_for_player)


func _send_word_to_peer(id: int, word: String) -> void:
	if id == 1:
		receive_word(word)
	else:
		receive_word.rpc_id(id, word)


# Called by the gameplay scene after it loads.
func request_sync_for_local_player() -> void:
	if multiplayer.is_server():
		_send_sync(1)
	else:
		request_sync.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func request_sync() -> void:
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	_send_sync(sender_id)


func _send_sync(id: int) -> void:
	if not running or not players_in_game.has(id):
		return

	var state := {
		"players": NetworkManager.players.duplicate(true),
		"current_turn_peer": current_turn_peer,
		"running": running
	}

	if id == 1:
		receive_state(state)
	else:
		receive_state.rpc_id(id, state)

	var word: String = secret_words[current_turn_peer]

	if id == current_turn_peer:
		word = ""

	_send_word_to_peer(id, word)


@rpc("authority", "call_remote", "reliable")
func receive_state(state: Dictionary) -> void:
	latest_state = state.duplicate(true)

	# Important: clients must know the game is running.
	running = bool(state.get("running", false))
	current_turn_peer = int(state.get("current_turn_peer", -1))

	state_changed.emit(latest_state)


@rpc("authority", "call_remote", "reliable")
func receive_word(word: String) -> void:
	latest_word = word
	word_changed.emit(word)
