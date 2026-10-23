extends Control

@onready var circleTransition: ColorRect = $CircleTransition

func _ready() -> void:
	var mat := circleTransition.material as ShaderMaterial

	mat.set_shader_parameter("screen_width", get_viewport_rect().size.x)
	mat.set_shader_parameter("screen_height", get_viewport_rect().size.y)
	mat.set_shader_parameter("circle_size", 0.0)

	circleTransition.visible = true

	await get_tree().create_timer(0.2).timeout

	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			mat.set_shader_parameter("circle_size", value),
		0.0,
		1.05,
		1.0
	)
	
	

func _on_play_button_pressed() -> void:
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
	
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_github_pressed() -> void:
	OS.shell_open("https://github.com/Haydara1/Heads-Up")
