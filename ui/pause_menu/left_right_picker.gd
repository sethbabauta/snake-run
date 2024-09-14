class_name LeftRightPicker extends HBoxContainer

@export var left_button: Button
@export var right_button: Button
@export var display_label: Label

var options: Array[String] = []
var index_selected: int = 0


func cycle_left() -> void:
	index_selected -= 1
	if index_selected < 0:
		index_selected = options.size() - 1

	display_label.text = options[index_selected]


func cycle_right() -> void:
	index_selected += 1
	if index_selected >= options.size():
		index_selected = 0

	display_label.text = options[index_selected]



func set_options(new_options: Array[String]) -> void:
	options = new_options
	index_selected = 0
	display_label.text = options[index_selected]


func _on_left_button_pressed() -> void:
	cycle_left()


func _on_right_button_pressed() -> void:
	cycle_right()
