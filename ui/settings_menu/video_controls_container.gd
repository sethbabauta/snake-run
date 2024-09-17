extends VBoxContainer

@export var screen_mode_picker: ScreenModePicker
@export var resolution_picker: ResolutionPicker


func _ready() -> void:
	_setup_resolution_picker()
	_setup_screen_mode_picker()


func load_resolution_settings() -> void:
	var video_settings: Dictionary = ConfigFileHandler.load_settings(
		ConfigFileHandler.ConfigSections.VIDEO
	)
	var settings_string: String = video_settings["resolution"]
	var loaded_resolution: Resolution = (
		Resolution.settings_string_to_resolution(settings_string)
	)
	var loaded_option: String = loaded_resolution.get_as_string()
	resolution_picker.set_option(loaded_option)


func load_screen_mode_settings() -> void:
	var video_settings: Dictionary = ConfigFileHandler.load_settings(
		ConfigFileHandler.ConfigSections.VIDEO
	)
	var loaded_option: String = video_settings["screen_mode"]
	if loaded_option == "fullscreen" or loaded_option == "borderless_fullscreen":
		screen_mode_picker.fullscreen_selected.emit(DisplayServer.screen_get_size())
	screen_mode_picker.set_option(loaded_option)


func _on_fullscreen_selected(resolution: Vector2i) -> void:
	var resolutions: Array[Resolution] = Settings.get_resolution_options()
	var index: int = Resolution.search_array_with_vector2i(resolution, resolutions)
	resolution_picker.set_option_by_index(index)
	resolution_picker.disable_buttons()


func _on_windowed_selected() -> void:
	resolution_picker.enable_buttons()
	resolution_picker.save_function()


func _setup_resolution_picker() -> void:
	var resolutions: Array[Resolution] = Settings.get_resolution_options()
	var resolution_options: Array[String] = (
		Resolution.resolution_array_to_string_array(resolutions)
	)
	resolution_picker.set_options(resolution_options)
	resolution_picker.resolutions = resolutions

	load_resolution_settings()


func _setup_screen_mode_picker() -> void:
	var screen_mode_options: Array[String] = Settings.get_screen_mode_options()
	screen_mode_picker.set_options(screen_mode_options)

	screen_mode_picker.fullscreen_selected.connect(_on_fullscreen_selected)
	screen_mode_picker.windowed_selected.connect(_on_windowed_selected)

	load_screen_mode_settings()
