extends Control

@onready var name_input: LineEdit = $CenterContainer/VBoxContainer/NameInput
@onready var ip_input: LineEdit = $CenterContainer/VBoxContainer/IPInput
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel

func _ready() -> void:
	NetworkManager.connection_status.connect(_on_status)
	NetworkManager.lobby_updated.connect(_on_lobby_updated)

func _on_host_button_pressed() -> void:
	var error := NetworkManager.host_game(name_input.text)

	if error != OK:
		status_label.text = "Could not create room: " + str(error)
		return

	var tree := get_tree()
	if tree == null:
		push_error("SceneTree is unavailable in lobby.gd")
		return

	tree.change_scene_to_file(
		"res://scenes/connected_lobby.tscn")
func _on_join_button_pressed() -> void:
	var error := NetworkManager.join_game(
		ip_input.text,
		name_input.text
	)

	if error != OK:
		status_label.text = "Could not connect: " + str(error)

func _on_status(message: String) -> void:
	status_label.text = message

func _on_lobby_updated(_players: Dictionary) -> void:
	if multiplayer.multiplayer_peer.get_connection_status() \
	== MultiplayerPeer.CONNECTION_CONNECTED:
		get_tree().change_scene_to_file("res://scenes/connected_lobby.tscn")
