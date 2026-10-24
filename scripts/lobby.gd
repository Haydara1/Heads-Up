extends Control

@onready var name_input: LineEdit = $CenterContainer/VBoxContainer/NameInput
@onready var ip_input: LineEdit = $CenterContainer/VBoxContainer/IPInput
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel

@onready var circleTransition: ColorRect = $CircleTransition

func _ready() -> void:
	var mat := circleTransition.material as ShaderMaterial

	mat.set_shader_parameter("screen_width", get_viewport_rect().size.x)
	mat.set_shader_parameter("screen_height", get_viewport_rect().size.y)
	mat.set_shader_parameter("circle_size", 0.0)
	
	circleTransition.visible = true
	
	NetworkManager.connection_status.connect(_on_status)
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	
	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			mat.set_shader_parameter("circle_size", value),
		0.0,
		1.05,
		1.0
	)
	

func _on_host_button_pressed() -> void:
	# Begin transition
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
	
	var error := NetworkManager.host_game(name_input.text)

	if error != OK:
		get_tree().change_scene_to_file("res://scenes/error.tscn")
		return

	var tree := get_tree()
	if tree == null:
		push_error("SceneTree is unavailable in lobby.gd")
		return


	tree.change_scene_to_file(
		"res://scenes/connected_lobby.tscn")


func _on_join_button_pressed() -> void:
	# Begin transition
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
	
	
	var error := NetworkManager.join_game(
		ip_input.text,
		name_input.text
	)

	if error != OK:
		status_label.text = "Could not connect: " + str(error)
		get_tree().change_scene_to_file("res://scenes/error.tscn")

func _on_status(message: String) -> void:
	status_label.text = message

func _on_lobby_updated(_players: Dictionary) -> void:
	if multiplayer.multiplayer_peer.get_connection_status() \
	== MultiplayerPeer.CONNECTION_CONNECTED:
		get_tree().change_scene_to_file("res://scenes/connected_lobby.tscn")

# Disable join button if IP text is empty
func _on_ip_input_text_changed(new_text: String) -> void:
	if new_text != "":
		$CenterContainer/VBoxContainer/JoinButton.disabled = false
	else:
		$CenterContainer/VBoxContainer/JoinButton.disabled = true
