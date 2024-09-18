class_name VolumeTextEdit extends LineEdit

@export var bus_name: String = "Master"
@export var slider: HSlider


func _ready() -> void:
	focus_exited.connect(_on_focus_exited)
	load_value_from_settings()


func _input(event: InputEvent) -> void:
	if (
		has_focus()
		and event is InputEventKey
		and event.is_pressed()
		and event.is_action("ui_text_submit")
	):
		get_viewport().set_input_as_handled()
		_on_focus_exited()


func load_value_from_settings() -> void:
	var audio_settings: Dictionary = ConfigFileHandler.load_settings(
		ConfigFileHandler.ConfigSections.AUDIO
	)
	var setting_key: String = bus_name + "_volume"
	text = _convert_volume_to_int(audio_settings.get(setting_key))


func _convert_volume_to_int(value: float) -> String:
	return str(int(value * 100))


func _on_focus_exited() -> void:
	if not text.is_valid_int():
		text = _convert_volume_to_int(slider.value)
		return

	var new_value: float = float(text)
	if new_value != 0:
		new_value = new_value / 100

	ConfigFileHandler.save_audio_volume_setting(
		bus_name,
		new_value,
	)
	slider.value = new_value
