class_name LeftRightPicker extends HBoxContainer

@export var left_button: Button
@export var right_button: Button
@export var display_label: Label
@export var delayed_save: bool = false

var options: Array[String]
var index_selected: int = 0
var save_id_factory:= IDFactory.new("LRPicker")

@onready var delay_timer: Timer = $DelayTimer


func cycle_left() -> void:
	index_selected -= 1
	if index_selected < 0:
		index_selected = options.size() - 1

	set_display_label(options[index_selected])
	save_setting()


func cycle_right() -> void:
	index_selected += 1
	if index_selected >= options.size():
		index_selected = 0

	set_display_label(options[index_selected])
	save_setting()


func save_function() -> void:
	pass # override this to actually save


func save_setting() -> void:
	var current_index: int = index_selected
	var save_id: IDCounter = save_id_factory.create_new_id()

	if delayed_save:
		delay_timer.start()
		await delay_timer.timeout

	if (
		current_index == index_selected
		and save_id_factory.is_id_current(save_id)
	):
		save_function()


func set_display_label(option_selected: String) -> void:
	display_label.text = option_selected.capitalize()


func set_option(new_option: String) -> bool:
	var option_index: int = options.find(new_option)
	if option_index == -1:
		return false

	index_selected = option_index
	set_display_label(options[index_selected])
	save_function()

	return true


func set_option_by_index(new_option_index: int) -> void:
	index_selected = new_option_index
	set_display_label(options[index_selected])
	save_setting()


func set_options(new_options: Array[String]) -> void:
	options = new_options
	index_selected = 0
	set_display_label(options[index_selected])


func disable_buttons() -> void:
	left_button.disabled = true
	right_button.disabled = true


func enable_buttons() -> void:
	left_button.disabled = false
	right_button.disabled = false


func _on_left_button_pressed() -> void:
	cycle_left()


func _on_right_button_pressed() -> void:
	cycle_right()
