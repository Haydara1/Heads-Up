
extends Control

@onready var turn_label: Label = $VBoxContainer/TurnLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var word_label: Label = $VBoxContainer/CharacterLabel
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.word_changed.connect(_on_word_changed)

	confirm_button.pressed.connect(
		GameManager.submit_correct_guess
	)

	word_label.text = "Waiting for game..."
	confirm_button.disabled = true

	# Ask for the latest game state and word.
	GameManager.request_sync_for_local_player()

	# Also display data that arrived before this scene loaded.
	if not GameManager.latest_state.is_empty():
		_on_state_changed(GameManager.latest_state)

	_on_word_changed(GameManager.latest_word)


func _on_state_changed(state: Dictionary) -> void:
	var players: Dictionary = state["players"]
	var active_id := int(state["current_turn_peer"])
	var my_id := multiplayer.get_unique_id()

	var lines: Array[String] = []

	for id in players:
		var player: Dictionary = players[id]
		lines.append(
			str(player["name"]) + ": " +
			str(player["score"])
		)

	score_label.text = "\n".join(lines)

	if my_id == active_id:
		turn_label.text = "Your turn! Guess your word."
	else:
		var active_player: Dictionary = players.get(
			active_id,
			{"name": "Player"}
		)
		turn_label.text = str(active_player["name"]) + "'s turn"

	confirm_button.disabled = (
		not state["running"] or my_id == active_id
	)


func _on_word_changed(word: String) -> void:
	if word.is_empty():
		word_label.text = "Guess the word!"
	else:
		word_label.text = word
