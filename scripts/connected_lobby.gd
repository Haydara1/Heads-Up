
extends Control

@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var players_label: Label = $CenterContainer/VBoxContainer/PlayersLabel
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var pack_list : ItemList = $CenterContainer/VBoxContainer/PackList

@onready var circleTransition: ColorRect = $CircleTransition


func _ready() -> void:
	var mat := circleTransition.material as ShaderMaterial

	mat.set_shader_parameter("screen_width", get_viewport_rect().size.x)
	mat.set_shader_parameter("screen_height", get_viewport_rect().size.y)
	mat.set_shader_parameter("circle_size", 0.0)
	
	circleTransition.visible = true
	
	var scrollbar = pack_list.get_v_scroll_bar()
	scrollbar.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scrollbar.add_theme_stylebox_override("grabber", StyleBoxEmpty.new())
	scrollbar.add_theme_stylebox_override("grabber_highlight", StyleBoxEmpty.new())
	scrollbar.add_theme_stylebox_override("grabber_pressed", StyleBoxEmpty.new())
	
	# Wait until the GameManager has loaded the packs.
	if GameManager.packs.is_empty():
		GameManager.load_packs()
	
	pack_list.clear()
	
	for pack_name in GameManager.packs.keys():
		pack_list.add_item(str(pack_name), null, true)
		
	
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	
	_on_lobby_updated(NetworkManager.players)
	
	# Only the host can start the game.
	play_button.visible = multiplayer.is_server()
	
	play_button.disabled = GameManager.players_in_game.size() > 1
	
	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			mat.set_shader_parameter("circle_size", value),
		0.0,
		1.05,
		1.0
	)



func _on_start_button_pressed() -> void:
	var selected_names: Array[String] = []

	for index in pack_list.get_selected_items():
		selected_names.append(pack_list.get_item_text(index))

	if selected_names.is_empty():
		return

	if not multiplayer.is_server():
		return

	var mat := circleTransition.material as ShaderMaterial
	
	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			mat.set_shader_parameter("circle_size", value),
		1.05,
		0,
		0.8
	)
	
	await tween.finished

	GameManager.start_game(selected_names)



func _on_lobby_updated(players: Dictionary) -> void:
	var lines: Array[String] = []
	
	play_button.disabled = GameManager.players_in_game.size() > 1
	
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
