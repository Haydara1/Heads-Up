
extends Control

@onready var turn_label: Label = $VBoxContainer/TurnLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var word_label: Label = $VBoxContainer/CharacterLabel
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.words_changed.connect(_on_words_changed)
	confirm_button.pressed.connect(GameManager.submit_confirmation)

	word_label.text = "Waiting for words..."
	confirm_button.disabled = true

	GameManager.request_sync_for_local_player()

	if not GameManager.latest_state.is_empty():
		_on_state_changed(GameManager.latest_state)

	_on_words_changed(GameManager.latest_words)


func _on_state_changed(state: Dictionary) -> void:
	var players: Dictionary = state.get("players", {})
	var confirmed: Array = state.get("confirmed_order", [])
	var my_id := multiplayer.get_unique_id()

	var lines: Array[String] = []

	for id in players:
		var player: Dictionary = players[id]
		lines.append(
			str(player.get("name", "Player"))
			+ ": "
			+ str(player.get("score", 0))
			+ " points"
		)

	score_label.text = "\n".join(lines)

	if not bool(state.get("running", false)):
		turn_label.text = "Round finished!"
	elif confirmed.has(my_id):
		turn_label.text = "Confirmed! Waiting for everyone else..."
	else:
		turn_label.text = "Guess your word, then confirm!"

	confirm_button.disabled = (
		not bool(state.get("running", false))
		or confirmed.has(my_id)
	)


func _on_words_changed(words: Dictionary) -> void:
	var players: Dictionary = GameManager.latest_state.get(
		"players",
		NetworkManager.players
	)

	var my_id := multiplayer.get_unique_id()
	var lines: Array[String] = []

	for id in players:
		var player: Dictionary = players[id]
		var player_id := int(id)
		var displayed_word := str(words.get(player_id, ""))

		if player_id == my_id:
			displayed_word = "??? (your word)"
		elif displayed_word.is_empty():
			displayed_word = "Waiting..."

		lines.append(
			str(player.get("name", "Player"))
			+ ": "
			+ displayed_word
		)

	word_label.text = "\n".join(lines)
