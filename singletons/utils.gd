extends Node

var rng := RandomNumberGenerator.new()


func array_subtract(array_a: Array, array_b: Array) -> Array:
	var result: Array = array_a.duplicate(true)
	for element in array_a:
		if array_b.has(element):
			result.erase(element)

	return result


func await_multiple_signals(all_signals: Array[Signal]) -> void:
	pass


func convert_simple_to_world_coordinates(coordinates: Vector2) -> Vector2:
	var new_coordinates: Vector2 = (
		(coordinates.round() * Settings.BASE_MOVE_SPEED)
		+ (Vector2.ONE * (Settings.BASE_MOVE_SPEED / 2.0))
	)

	return new_coordinates


func convert_world_to_simple_coordinates(coordinates: Vector2) -> Vector2:
	var new_coordinates := (
		(coordinates.round() - (Vector2.ONE * (Settings.BASE_MOVE_SPEED / 2.0))).snapped(
			Vector2.ONE * Settings.BASE_MOVE_SPEED
		)
		/ Settings.BASE_MOVE_SPEED
	)

	return new_coordinates


func decay_to_zero(
	from: float,
	to: float,
	weight: float,
	cutoff: float = 0.2,
) -> float:
	var result: float = lerp(from, to, weight)
	if result < cutoff:
		result = 0.0

	return result


func get_farthest_direction(vector_from: Vector2, vector_to: Vector2) -> String:
	var x_difference: float = vector_to.x - vector_from.x
	var y_difference: float = vector_to.y - vector_from.y
	if abs(x_difference) > abs(y_difference):
		if x_difference > 0:
			return "E"
		return "W"

	if y_difference > 0:
		return "S"
	return "N"


func roll(die_count: int, sides: int) -> int:
	var result: int = 0
	for roll_count in range(die_count):
		result += self.rng.randi_range(1, sides)

	return result


class SignalTracker:
	var signal_to_wait_for: Signal
	var has_emitted: bool

	func _init(p_signal_to_wait_for: Signal, p_has_emitted: bool = false) -> void:
		signal_to_wait_for = p_signal_to_wait_for
		has_emitted = p_has_emitted
