class_name ResolutionPicker extends LeftRightPicker

var resolutions: Array[Resolution]


func center_window() -> void:
	var screen_center: Vector2i = (
		DisplayServer.screen_get_position()
		+ DisplayServer.screen_get_size() / 2
		+ Vector2i(0, 50) # offset so that top window bar is always visible
	)
	var window: Window = get_window()
	var window_size = window.get_size_with_decorations()
	window.set_position(screen_center - window_size / 2)


func save_function() -> void:
	var current_resolution: Resolution = resolutions[index_selected]
	var settings_string: String = Resolution.resolution_to_settings_string(
		current_resolution
	)
	ConfigFileHandler.save_video_setting("resolution", settings_string)
	var resolution_as_vector2i:= Vector2i(
		current_resolution.width,
		current_resolution.height,
	)
	DisplayServer.window_set_size(resolution_as_vector2i)
	center_window()
