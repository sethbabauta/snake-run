class_name VolumeSlider extends HSlider

@export var bus_name: String = "Master"
@export var text_edit: LineEdit


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	load_value_from_settings()


func load_value_from_settings() -> void:
	var audio_settings: Dictionary = ConfigFileHandler.load_settings(
		ConfigFileHandler.ConfigSections.AUDIO
	)
	var setting_key: String = bus_name + "_volume"
	value = audio_settings.get(setting_key)


func _on_value_changed(new_value: float) -> void:
	ConfigFileHandler.save_audio_volume_setting(
		bus_name,
		new_value,
	)
	text_edit.text = str(int(new_value * 100))

