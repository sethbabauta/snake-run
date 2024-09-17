class_name ScreenModePicker extends LeftRightPicker

signal fullscreen_selected(resolution: Vector2i)
signal windowed_selected


func save_function() -> void:
	ConfigFileHandler.save_video_setting("screen_mode", options[index_selected])
	match options[index_selected]:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			fullscreen_selected.emit(DisplayServer.screen_get_size())
		"borderless_fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			fullscreen_selected.emit(DisplayServer.screen_get_size())
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			windowed_selected.emit()
