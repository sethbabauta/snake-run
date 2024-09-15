class_name ResolutionPicker extends LeftRightPicker

var resolutions: Array[Resolution]


func save_function() -> void:
	ConfigFileHandler.save_video_setting("resolution", options[index_selected])
	var current_resolution: Resolution = resolutions[index_selected]
	var resolution_as_vector2i:= Vector2i(
		current_resolution.width,
		current_resolution.height,
	)
	DisplayServer.window_set_size(resolution_as_vector2i)
