extends Node


var rng:= RandomNumberGenerator.new()


func convert_simple_to_world_coordinates(coordinates: Vector2) -> Vector2:
	var new_coordinates: Vector2 = (
			(coordinates.round() * Settings.BASE_MOVE_SPEED)
			+ (Vector2.ONE * (Settings.BASE_MOVE_SPEED / 2))
	)

	return new_coordinates


func convert_world_to_simple_coordinates(coordinates: Vector2) -> Vector2:
	var new_coordinates:= (
			(coordinates.round() - (Vector2.ONE * (Settings.BASE_MOVE_SPEED / 2)))
			.snapped(Vector2.ONE * Settings.BASE_MOVE_SPEED) / Settings.BASE_MOVE_SPEED
	)

	return new_coordinates


func get_farthest_direction(vector_from: Vector2, vector_to: Vector2) -> String:
	var x_difference: int = vector_to.x - vector_from.x
	var y_difference: int = vector_to.y - vector_from.y
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


func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout


class AbilityTimer:
	signal ABILITY_FINISHED
	signal COOLDOWN_FINISHED
	var ability_duration: float
	var cooldown_duration: float


	func _init(
			p_ability_duration: float = 0.0,
			p_cooldown_duration: float = 0.0,
	) -> void:
		self.ability_duration = p_ability_duration
		self.cooldown_duration = p_cooldown_duration


	func cooldown() -> void:
		print("test1")
		await Utils.wait(ability_duration)
		ABILITY_FINISHED.emit()

		await Utils.wait(cooldown_duration)
		COOLDOWN_FINISHED.emit()
