class_name UIState extends State

@export var dialog: Control


func enter() -> void:
	if dialog:
		dialog.visible = true
