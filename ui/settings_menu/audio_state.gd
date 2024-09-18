extends SettingsState


func reset_to_defaults() -> void:
	ConfigFileHandler.set_audio_defaults()
	container.load_value_from_settings()
