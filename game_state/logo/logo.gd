extends Control

var input_detected: Signal


func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(event) and input_detected:
		input_detected.emit()
