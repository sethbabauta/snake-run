extends SettingsState


func reset_to_defaults() -> void:
	ConfigFileHandler.set_video_defaults()
	container.load_resolution_settings()
	container.load_screen_mode_settings()
