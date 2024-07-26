extends GameState


func enter() -> void:
	_change_scene(Settings.LOGO_SCENE)


func update() -> void:
	if get_runtime() > 3.0:
		is_complete = true
