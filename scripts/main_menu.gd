extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_github_pressed() -> void:
	OS.shell_open("https://github.com/Haydara1/Heads-Up")
