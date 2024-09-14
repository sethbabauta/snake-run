class_name SettingsDialog extends Control

var state_machine: StateMachine

func _ready() -> void:
	EventBus.settings_toggled.connect(_on_settings_toggled)


func _on_settings_toggled() -> void:
	visible = not visible


func _on_back_button_pressed() -> void:
	EventBus.settings_toggled.emit()
