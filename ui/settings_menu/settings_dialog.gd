class_name SettingsDialog extends Control

signal back_pressed

var state_machine:= StateMachine.new()

# containers
@export var containers: Control

# states
@export var video: SettingsState
@export var audio: SettingsState


func _ready() -> void:
	set_state(video)


func hide_all() -> void:
	for container in containers.get_children():
		container.visible = false


func set_state(next_state: SettingsState) -> void:
	hide_all()
	state_machine.set_state(next_state, true)


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_video_section_button_pressed() -> void:
	set_state(video)


func _on_audio_section_button_pressed() -> void:
	set_state(audio)


func _on_reset_button_pressed() -> void:
	state_machine.state.reset_to_defaults()
