extends GameState

signal input_detected

var logo_scene: Control

func enter() -> void:
	logo_scene = _change_scene(Settings.LOGO_SCENE)
	logo_scene.input_detected = input_detected
	input_detected.connect(_on_input_detected)


func exit() -> void:
	super()
	input_detected.disconnect(_on_input_detected)


func update() -> void:
	if get_runtime() > 3.0:
		is_complete = true


func _on_input_detected() -> void:
	is_complete = true
