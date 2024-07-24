class_name GameStateLogo extends GameState


func update() -> void:
	if get_runtime() > 3.0:
		is_complete = true
