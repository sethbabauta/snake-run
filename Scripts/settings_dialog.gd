class_name SettingsDialog extends Control


func _on_close_button_pressed() -> void:
	EventBus.TOGGLE_SETTINGS.emit()
