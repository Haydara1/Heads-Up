
extends Control

@onready var pack_option: OptionButton = $CenterContainer/VBoxContainer/PackOption
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var players_label: Label = $CenterContainer/VBoxContainer/PlayersLabel
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton


func _ready() -> void:
	# Available packs must match GameManager.PACKS.
	pack_option.clear()

	for pack_name in GameManager.packs.keys():
		pack_option.add_item(str(pack_name))

	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	
	_on_lobby_updated(NetworkManager.players)

	# Only the host can start the game.
	play_button.disabled = not multiplayer.is_server()


func _on_play_button_pressed() -> void:
	if not multiplayer.is_server():
		return

	var pack_name := pack_option.get_item_text(
		pack_option.selected
	)

	GameManager.start_game(pack_name)



func _on_lobby_updated(players: Dictionary) -> void:
	var lines: Array[String] = []

	for id in players:
		var player: Dictionary = players[id]
		lines.append(
			str(player.get("name", "Player"))
			+ " — "
			+ str(player.get("score", 0))
			+ " points"
		)

	players_label.text = "\n".join(lines)
