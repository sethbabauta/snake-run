class_name ScreenModePicker extends LeftRightPicker

signal fullscreen_selected(resolution: Vector2i)
signal windowed_selected


func save_function() -> void:
	ConfigFileHandler.save_video_setting("screen_mode", options[index_selected])
	match options[index_selected]:
		"fullscreen":
			DisplayServerHandler.set_screen_mode(
				DisplayServerHandler.ScreenModes.FULLSCREEN,
			)
			fullscreen_selected.emit(DisplayServer.screen_get_size())
		"borderless_fullscreen":
			DisplayServerHandler.set_screen_mode(
				DisplayServerHandler.ScreenModes.BORDERLESS_FULLSCREEN,
			)
			fullscreen_selected.emit(DisplayServer.screen_get_size())
		"windowed":
			DisplayServerHandler.set_screen_mode(
				DisplayServerHandler.ScreenModes.WINDOWED,
			)
			windowed_selected.emit()
