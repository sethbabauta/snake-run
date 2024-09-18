extends Node

enum ScreenModes {FULLSCREEN, BORDERLESS_FULLSCREEN, WINDOWED}


func center_window() -> void:
	var screen_center: Vector2i = (
		DisplayServer.screen_get_position()
		+ DisplayServer.screen_get_size() / 2
		+ Vector2i(0, 50) # offset so that top window bar is always visible
	)
	var window: Window = get_window()
	var window_size = window.get_size_with_decorations()
	window.set_position(screen_center - window_size / 2)


func set_resolution_from_settings_string(settings_string: String) -> void:
	var resolution:Resolution = Resolution.settings_string_to_resolution(
		settings_string
	)
	DisplayServer.window_set_size(Vector2i(
		resolution.width,
		resolution.height,
	))
	center_window()


func set_screen_mode(new_screen_mode: ScreenModes) -> void:
	match new_screen_mode:
		ScreenModes.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		ScreenModes.BORDERLESS_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		ScreenModes.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)


func set_screen_mode_from_settings_string(settings_string: String) -> void:
	match settings_string:
		"fullscreen":
			set_screen_mode(ScreenModes.FULLSCREEN)
		"borderless_fullscreen":
			set_screen_mode(ScreenModes.BORDERLESS_FULLSCREEN)
		"windowed":
			set_screen_mode(ScreenModes.WINDOWED)
