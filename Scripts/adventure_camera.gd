class_name FollowCamera extends Camera2D

const ROOM_LENGTH = 640

@export var main_node: Main
@export var gamemode_node: Node

var player_head: GameEngine.GameObject


func _ready() -> void:
	EventBus.game_started.connect(_on_game_start)
	main_node.move_timer.speed_5.connect(_on_move_timer_speed_5)


func get_direction_from_camera() -> String:
	var direction_to: Vector2 = global_position.direction_to(player_head.physics_body.global_position)
	var direction_to_abs: Vector2 = direction_to.abs()
	if direction_to_abs.x > direction_to_abs.y:
		if direction_to.x > 0:
			return "E"
		return "W"
	if direction_to.y > 0:
		return "S"
	return "N"


func snap_to_direction(cardinal_direction: String) -> void:
	match cardinal_direction:
		"N":
			global_position.y -= ROOM_LENGTH
		"S":
			global_position.y += ROOM_LENGTH
		"E":
			global_position.x += ROOM_LENGTH
		"W":
			global_position.x -= ROOM_LENGTH


func _on_game_start(_gamemode_name: String) -> void:
	player_head = main_node.get_closest_player_controlled(Vector2(0, 0))


func _on_move_timer_speed_5() -> void:
	var snake_heads: Array = self.main_node.get_game_objects_of_name("PlayerSnakeHead")
	var snake_heads_slow: Array = self.main_node.get_game_objects_of_name("PlayerSnakeHeadSlow")
	snake_heads += snake_heads_slow

	if not snake_heads:
		var cardinal_direction: String = get_direction_from_camera()
		snap_to_direction(cardinal_direction)
		EventBus.level_changed.emit(cardinal_direction)
