class_name IDFactory extends RefCounted

var current_id: int = 0
var factory_name: String


func _init(p_factory_name: String) -> void:
	factory_name = p_factory_name


func create_new_id() -> IDCounter:
	current_id += 1
	var new_id:= IDCounter.new(current_id)

	return new_id


func is_id_current(id_to_check: IDCounter) -> bool:
	var is_current: bool = id_to_check.id == current_id

	return is_current
