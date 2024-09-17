class_name SettingsState extends State

@export var container: VBoxContainer
@export var section_button: Button

var state_manager: VBoxContainer


func enter() -> void:
	container.visible = true


func reset_to_defaults() -> void:
	pass # override
