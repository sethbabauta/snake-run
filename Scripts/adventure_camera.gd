class_name FollowCamera extends Camera2D

const INITIAL_SHAKE_STRENGTH = 100.0
const NOISE_PERIOD = 2
const ROOM_LENGTH = 640
const RESPAWN_POINT = Vector2(320, 320)
const SHAKE_DECAY_RATE = 2.0
const SHAKE_SPEED = 5.0

@export var main_node: Main
@export var gamemode_node: Node

var player_head: GameEngine.GameObject
var noise_idx: float = 0.0
var shake_strength: float = 0.0
var old_shake_strength: float = 0.0

@onready var noise = FastNoiseLite.new()
@onready var rng = RandomNumberGenerator.new()


"""
Screen shake code comes from theshaggydev on Github:
https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-3/screen-shake
"""


func _ready() -> void:
	EventBus.game_started.connect(_on_game_start)
	EventBus.player_respawned.connect(_on_respawn)
	main_node.move_timer.speed_5.connect(_on_move_timer_speed_5)

	rng.randomize()
	noise.seed = rng.randi()
	noise.frequency = NOISE_PERIOD


func _process(delta: float) -> void:
	if shake_strength <= 0:
		return

	old_shake_strength = shake_strength
	shake_strength = Utils.decay_to_zero(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	if shake_strength == 0.0 and old_shake_strength != 0.0:
		EventBus.shake_completed.emit()

	offset = _get_shake_offset(delta, SHAKE_SPEED, shake_strength)


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


func shake_with_noise() -> void:
	shake_strength = INITIAL_SHAKE_STRENGTH


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


func _get_shake_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_idx += delta * speed
	return Vector2(
		noise.get_noise_2d(1, noise_idx) * strength,
		noise.get_noise_2d(100, noise_idx) * strength,
	)


func _on_game_start(_gamemode_name: String) -> void:
	player_head = main_node.get_closest_player_controlled(Vector2.ZERO)


func _on_move_timer_speed_5() -> void:
	var snake_heads: Array = self.main_node.get_game_objects_of_name("PlayerSnakeHead")
	var snake_heads_slow: Array = self.main_node.get_game_objects_of_name("PlayerSnakeHeadSlow")
	snake_heads += snake_heads_slow

	if not snake_heads:
		var cardinal_direction: String = get_direction_from_camera()
		snap_to_direction(cardinal_direction)
		EventBus.level_changed.emit(cardinal_direction)


func _on_respawn() -> void:
	player_head = main_node.get_closest_player_controlled(Vector2.ZERO)
	global_position = RESPAWN_POINT
	EventBus.level_changed.emit("Start")
