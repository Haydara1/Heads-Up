extends Node

signal state_changed(state: Dictionary)
signal secret_character_changed(character: String)

const TURN_DURATION := 60

var characters: Array[String] = [
	"Batman",
	"Spider-Man",
	"Sherlock Holmes",
	"Harry Potter",
	"Mario",
	"Superman",
    "Pikachu"
]

var turn_order: Array[int] = []
var turn_index := 0
var current_turn_peer := -1
var time_left := TURN_DURATION
var running := false

# Only the host stores the authoritative character assignments.
var secret_characters: Dictionary = {}

var latest_public_state: Dictionary = {}
var local_secret_character := ""

func start_game() -> void:
	if not multiplayer.is_server():
		return

	turn_order.clear()
	secret_characters.clear()

	for id in NetworkManager.players.keys():
		turn_order.append(int(id))

	turn_order.sort()

	if turn_order.size() < 2:
		return

	for id in turn_order:
		NetworkManager.players[id]["score"] = 0
		secret_characters[id] = characters.pick_random()

	turn_index = 0
	current_turn_peer = turn_order[turn_index]
	time_left = TURN_DURATION
	running = true

	_send_current_character()
	_broadcast_state()


func submit_correct_guess() -> void:
	# The active player cannot confirm their own guess.
	if not running:
		return

	if multiplayer.is_server():
		return

	confirm_guess.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func confirm_guess() -> void:
	if not multiplayer.is_server() or not running:
		return

	var sender_id := multiplayer.get_remote_sender_id()

	# Only another player can confirm the active player's guess.
	if sender_id == current_turn_peer:
		return

	if not turn_order.has(sender_id):
		return

	_mark_guess_correct()


func _mark_guess_correct() -> void:
	if not multiplayer.is_server():
		return

	if not running:
		return

	NetworkManager.players[current_turn_peer]["score"] += 1

	_next_turn()


func _next_turn() -> void:
	if turn_order.is_empty():
		return

	turn_index = (turn_index + 1) % turn_order.size()
	current_turn_peer = turn_order[turn_index]

	time_left = TURN_DURATION

	_send_current_character()
	_broadcast_state()


func _send_current_character() -> void:
	if not secret_characters.has(current_turn_peer):
		return

	var character: String = secret_characters[current_turn_peer]

	if current_turn_peer == 1:
		receive_secret_character(character)
	else:
		receive_secret_character.rpc_id(
			current_turn_peer,
			character
		)


func _broadcast_state() -> void:
	var state := {
		"players": NetworkManager.players.duplicate(true),
		"current_turn_peer": current_turn_peer,
		"time_left": int(ceil(time_left)),
		"running": running
	}

	receive_public_state.rpc(state)


func _process(delta: float) -> void:
	if not multiplayer.is_server() or not running:
		return

	time_left -= delta

	if time_left <= 0.0:
		_next_turn()


@rpc("authority", "call_local", "reliable")
func receive_public_state(state: Dictionary) -> void:
	latest_public_state = state.duplicate(true)
	state_changed.emit(latest_public_state)


@rpc("authority", "call_remote", "reliable")
func receive_secret_character(character: String) -> void:
	local_secret_character = character
	secret_character_changed.emit(character)
