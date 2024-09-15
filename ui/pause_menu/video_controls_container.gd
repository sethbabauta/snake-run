extends VBoxContainer

@export var screen_mode_picker: LeftRightPicker
@export var resolution_picker: ResolutionPicker


func _ready() -> void:
	var screen_mode_options: Array[String] = Settings.get_screen_mode_options()
	screen_mode_picker.set_options(screen_mode_options)

	var resolutions: Array[Resolution] = Settings.get_resolution_options()
	var resolution_options: Array[String] = (
		Resolution.resolution_array_to_string_array(resolutions)
	)
	resolution_picker.set_options(resolution_options)
	resolution_picker.resolutions = resolutions
