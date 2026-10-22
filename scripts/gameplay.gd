extends Control

@onready var turn_label: Label = $VBoxContainer/TurnLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var character_label: Label = $VBoxContainer/CharacterLabel
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton

var active_player_id := -1


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.secret_character_changed.connect(
		_on_secret_character_changed
	)

	confirm_button.pressed.connect(
		GameManager.submit_correct_guess
	)

	character_label.text = "Waiting for your turn..."

	# Display state that arrived before this scene loaded.
	if not GameManager.latest_public_state.is_empty():
		_on_state_changed(GameManager.latest_public_state)

	if not GameManager.local_secret_character.is_empty():
		_on_secret_character_changed(
			GameManager.local_secret_character
		)

	_update_buttons()

func _on_state_changed(state: Dictionary) -> void:
	active_player_id = int(state["current_turn_peer"])

	var players: Dictionary = state["players"]
	var lines: Array[String] = []

	for id in players:
		var player: Dictionary = players[id]
		lines.append(
			str(player["name"]) + ": " +
			str(player["score"])
		)

	score_label.text = "\n".join(lines)

	var my_id := multiplayer.get_unique_id()

	if my_id == active_player_id:
		turn_label.text = "Your turn!"
	else:
		var active_player: Dictionary = players.get(
			active_player_id, {"name": "Player"}
		)
		turn_label.text = str(active_player["name"]) + "'s turn"

	_update_buttons()


func _on_secret_character_changed(character: String) -> void:
	character_label.text = character
	_update_buttons()


func _update_buttons() -> void:
	var my_id := multiplayer.get_unique_id()
	var connected := (
		multiplayer.multiplayer_peer.get_connection_status()
		== MultiplayerPeer.CONNECTION_CONNECTED
	)

	confirm_button.disabled = (
		not connected or
		my_id == active_player_id
	)

	if my_id == active_player_id:
		character_label.visible = true
	else:
		character_label.visible = false
