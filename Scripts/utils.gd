extends Node


func roll(die_count: int, sides: int) -> int:
	var result: int = 0
	var rng:= RandomNumberGenerator.new()
	for roll_count in range(die_count):
		result += rng.randi_range(1, sides)
		
	return result
