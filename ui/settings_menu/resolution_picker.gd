class_name ResolutionPicker extends LeftRightPicker

var resolutions: Array[Resolution]


func save_function() -> void:
	var current_resolution: Resolution = resolutions[index_selected]
	var settings_string: String = Resolution.resolution_to_settings_string(
		current_resolution
	)
	ConfigFileHandler.save_video_setting("resolution", settings_string)
	DisplayServerHandler.set_resolution_from_settings_string(settings_string)
