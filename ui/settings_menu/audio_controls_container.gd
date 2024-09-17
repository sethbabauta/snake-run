extends VBoxContainer

@export var master_slider: VolumeSlider
@export var music_slider: VolumeSlider
@export var sfx_slider: VolumeSlider
@export var master_text_edit: VolumeTextEdit
@export var music_text_edit: VolumeTextEdit
@export var sfx_text_edit: VolumeTextEdit


func load_value_from_settings() -> void:
	master_slider.load_value_from_settings()
	music_slider.load_value_from_settings()
	sfx_slider.load_value_from_settings()
	master_text_edit.load_value_from_settings()
	music_text_edit.load_value_from_settings()
	sfx_text_edit.load_value_from_settings()
