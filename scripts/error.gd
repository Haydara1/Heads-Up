extends Control

@onready var circleTransition : ColorRect = $CircleTransition


# Called when the node enters the scene tree for the first time.
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


func _on_main_menu_button_pressed() -> void:
	$CenterContainer/VBoxContainer/MainMenuButton.disabled = true
	
	var mat := circleTransition.material as ShaderMaterial
	
	await get_tree().create_timer(0.2).timeout

	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			mat.set_shader_parameter("circle_size", value),
		1.05,
		0.0,
		1.0
	)
	
	await tween.finished
	
	get_tree().change_scene_to_file("res://scenes/Main-menu.tscn")
