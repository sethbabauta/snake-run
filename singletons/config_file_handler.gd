extends Node

enum ConfigSections {AUDIO, VIDEO}

var config = ConfigFile.new()


func _ready() -> void:
	if !FileAccess.file_exists(Settings.SETTINGS_FILE_PATH):
		set_config_defaults()
	else:
		config.load(Settings.SETTINGS_FILE_PATH)


func save_audio_setting(key: String, value) -> void:
	var settings_section_string: String = (
		_get_section_setting_string(ConfigSections.AUDIO)
	)
	config.set_value(settings_section_string, key, value)
	config.save(Settings.SETTINGS_FILE_PATH)


func save_audio_volume_setting(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
	var key_name: String = bus_name + "_volume"
	save_audio_setting(key_name, value)


func save_video_setting(key: String, value) -> void:
	var settings_section_string: String = (
		_get_section_setting_string(ConfigSections.VIDEO)
	)
	config.set_value(settings_section_string, key, value)
	config.save(Settings.SETTINGS_FILE_PATH)


func set_audio_defaults() -> void:
	config.set_value("audio", "Master_volume", 1)
	config.set_value("audio", "music_volume", 1)
	config.set_value("audio", "sfx_volume", 1)


func set_config_defaults() -> void:
	set_audio_defaults()
	set_video_defaults()
	config.save(Settings.SETTINGS_FILE_PATH)


func set_video_defaults() -> void:
	config.set_value("video", "screen_mode", "fullscreen")
	config.set_value("video", "resolution", "1920x1080")


func load_settings(settings_section: ConfigSections) -> Dictionary:
	var settings_section_string: String = (
		_get_section_setting_string(settings_section)
	)
	var settings: Dictionary = {}
	for key in config.get_section_keys(settings_section_string):
		settings[key] = config.get_value(settings_section_string, key)

	return settings


func _get_section_setting_string(settings_section: ConfigSections) -> String:
	var settings_section_string: String
	match settings_section:
		ConfigSections.AUDIO:
			settings_section_string = "audio"
		ConfigSections.VIDEO:
			settings_section_string = "video"

	return settings_section_string
