
extends Control

@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var players_label: Label = $CenterContainer/VBoxContainer/PlayersLabel
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var pack_list : ItemList = $CenterContainer/VBoxContainer/PackList

func _ready() -> void:
	pack_list.select_mode = ItemList.SELECT_MULTI
	
	# Wait until the GameManager has loaded the packs.
	if GameManager.packs.is_empty():
		GameManager.load_packs()
	
	pack_list.clear()
	
	for pack_name in GameManager.packs.keys():
		pack_list.add_item(str(pack_name))
		
	# Select the first pack by default.
	if pack_list.item_count > 0:
		pack_list.select(0)
	
	print("Available packs: ", GameManager.packs.keys())
	print("Items in PackList: ", pack_list.item_count)
	
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	
	_on_lobby_updated(NetworkManager.players)
	
	# Only the host can start the game.
	play_button.disabled = not multiplayer.is_server()


func _on_start_button_pressed() -> void:
	var selected_names: Array[String] = []

	for index in pack_list.get_selected_items():
		selected_names.append(pack_list.get_item_text(index))

	if selected_names.is_empty():
		print("Please select at least one pack.")
		return

	print("Selected packs: ", selected_names)

	if not multiplayer.is_server():
		return

	GameManager.start_game(selected_names)



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


func _on_pack_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if pack_list.is_selected(index):
		pack_list.deselect(index)
	else:
		pack_list.select(index, false)
