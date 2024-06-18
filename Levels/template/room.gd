class_name Room extends Resource

@export var score_threshold: int
@export var tile_map: PackedScene
@export var layout_x: int
@export var layout_y: int

var current_room_score: int = 0


func _to_string() -> String:
	var as_string: String = "(%s,%s) %s/%s" % [str(layout_x), str(layout_y),str(current_room_score), str(score_threshold)]
	return as_string


static func get_world_coordinates(layout_coordinates: Vector2) -> Vector2:
	var simple_coordinates: Vector2 = layout_coordinates * 20
	return Utils.convert_simple_to_world_coordinates(simple_coordinates)


func get_is_room_complete() -> bool:
	return current_room_score >= score_threshold
