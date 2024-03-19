extends Camera2D

signal LEVEL_CHANGED
signal PLAYER_FULLY_ENTERED

@export var main_node: Main
@export var gamemode_node: Node
var player_head: GameEngine.GameObject
var snake_tail: GameEngine.GameObject
var snake_tail_visible: bool = true

# TODO: Clean this up
var level_positions = {
	"Room30.tscn": Vector2(320, 320),
	"Room20.tscn": Vector2(-320, 320),
	"Room31.tscn": Vector2(320, -320),
	"Room21.tscn": Vector2(-320, -320),
	"Room32.tscn": Vector2(320, -960),
	"Room22.tscn": Vector2(-320, -960),
	"Room00.tscn": Vector2(320, 960),
}
var current_level = "Room30.tscn"


func _ready() -> void:
	gamemode_node.GAME_START.connect(_on_game_start)


# TODO: Clean this up
func snap_to_nearest_level() -> void:
	var player_position: Vector2 = player_head.physics_body.global_position
	var closest_distance: float = Vector2(320, 320).distance_squared_to(player_position)
	var closest_level_center: Vector2 = Vector2(320, 320)
	var closest_level_idx = 0
	for level_idx in self.level_positions.size():
		var current_distance = self.level_positions.values()[level_idx].distance_squared_to(
			player_position
		)
		if current_distance < closest_distance:
			closest_distance = current_distance
			closest_level_center = self.level_positions.values()[level_idx]
			closest_level_idx = level_idx

	self.global_position = closest_level_center
	self.current_level = self.level_positions.keys()[closest_level_idx]


func _on_game_start() -> void:
	player_head = main_node.get_closest_player_controlled(Vector2(0, 0))
	snake_tail = player_head.components.get("SnakeBody").get_tail_game_object()


# TODO: Clean this up
func _on_move_timer_speed_5() -> void:
	var snake_heads: Array = self.main_node.get_game_objects_of_name("PlayerSnakeHead")
	var snake_heads_slow: Array = self.main_node.get_game_objects_of_name("PlayerSnakeHeadSlow")
	snake_heads += snake_heads_slow

	snake_tail = player_head.components.get("SnakeBody").get_tail_game_object()
	if not snake_tail_visible and main_node.is_object_visible(snake_tail):
		PLAYER_FULLY_ENTERED.emit()
		snake_tail_visible = true

	if not snake_heads:
		snap_to_nearest_level()
		LEVEL_CHANGED.emit(self.current_level)
		snake_tail_visible = false
