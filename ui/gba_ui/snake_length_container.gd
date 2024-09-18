extends MarginContainer

@export var number_label: Label


func update_label(snake_length: int) -> void:
	number_label.text = str(snake_length)
