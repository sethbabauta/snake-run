extends LeftRightPicker


func save_function() -> void:
	ConfigFileHandler.save_video_setting("screen_mode", options[index_selected])
