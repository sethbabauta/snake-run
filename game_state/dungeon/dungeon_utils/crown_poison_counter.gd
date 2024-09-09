class_name CrownPoisonCounter extends RefCounted

const CROWN_POISON_RATE = 20

var current_interval: int = 0
var times_poisoned: int = 0
var main_node: Main


func _init(p_main_node: Main) -> void:
	main_node = p_main_node


func increment_counter(amount: int = 1) -> int:
	current_interval += amount
	if current_interval >= CROWN_POISON_RATE:
		current_interval = 0
		var new_event := GameEngine.Event.new(
			"IngestPoison",
			{"poison_level": 1},
		)
		main_node.game_object_factory.notify_subscribers(
			new_event,
			"player_controlled",
		)
		times_poisoned += 1

	return times_poisoned
