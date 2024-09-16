class_name Main extends Node

@export var follow_camera: Camera2D
@export var gamemode_node: Node

var game_object_factory: GameEngine.GameObjectFactory
var level_factory: LevelFactory
var item_pickup_observer: ItemPickupObserver
var move_timer_notifier: MoveTimerNotifier
var apple_flipper: AppleFlipper
var object_spawner: ObjectSpawner
var input_handler: InputHandler
var world_info: WorldInfo
var query_area: Area2D
var max_simple_size: Vector2
var timer_frozen: bool = false
var is_paused: bool = false
var is_game_started: bool = false

@onready var move_timer: MoveTimer = %MoveTimer
@onready var powerup_1_timer: Timer = %Powerup1Timer
@onready var spawn_timer: Timer = %SpawnTimer
@onready var audio_library: Node2D = %AudioLibrary


func _init() -> void:
	self.game_object_factory = GameEngine.GameObjectFactory.new()
	self.level_factory = LevelFactory.new(self)


func _ready() -> void:
	_connect_signals()
	_setup_utils()

	self.query_area = follow_camera.get_node("CollisionQuery")
	self.max_simple_size = (
		Vector2(360, 360) / Settings.BASE_MOVE_SPEED
	)


func _input(event: InputEvent) -> void:
	input_handler.handle_input(event)


func clear_doors(exclusions: Array = []) -> void:
	object_spawner.clear_doors(exclusions)


func clear_pickups() -> int:
	var pickups_cleared: int = await object_spawner.clear_pickups()

	return pickups_cleared


func cooldown(
	ability_duration: float,
	cooldown_duration: float,
	ability_user: GameEngine.GameObject,
) -> void:
	await get_tree().create_timer(ability_duration).timeout
	var new_event := GameEngine.Event.new("CooldownStart")
	ability_user.fire_event(new_event)

	await get_tree().create_timer(cooldown_duration).timeout
	new_event = GameEngine.Event.new("CooldownEnd")
	ability_user.fire_event(new_event)


func end_game_soon() -> void:
	toggle_timer_freeze()
	EventBus.player_died.emit()
	await get_tree().create_timer(3).timeout

	if not world_info.check_is_player_alive():
		EventBus.game_ended.emit(false)
		return

	EventBus.player_respawned.emit()


func fire_delayed_event(
	target: GameEngine.GameObject,
	event: GameEngine.Event,
	delay_seconds: float,
) -> void:
	await get_tree().create_timer(delay_seconds).timeout
	target.fire_event(event)


func flip_apples(nutritious: bool = false) -> void:
	apple_flipper.flip_apples(nutritious)


func flip_apples_back(nutritious: bool = false) -> void:
	apple_flipper.flip_apples_back(nutritious)


func get_closest_player_controlled(
	position_to_compare: Vector2,
) -> GameEngine.GameObject:
	var closest_object: GameEngine.GameObject = (
		world_info.get_closest_player_controlled(position_to_compare)
	)

	return closest_object


func get_game_objects_of_name(
	search_name: String,
) -> Array[GameEngine.GameObject]:
	var found_game_objects: Array[GameEngine.GameObject] = (
		await world_info.get_game_objects_of_name(search_name)
	)

	return found_game_objects


func get_random_valid_world_position() -> Vector2:
	var position: Vector2 = await world_info.get_random_valid_world_position()

	return position


func get_simple_door_locations(
	exclusions: Array[String] = []
) -> Array[Vector2]:
	var door_positions: Array[Vector2] = world_info.get_simple_door_locations(
		exclusions
	)

	return door_positions


func get_snake_length() -> int:
	var snake_length: int = await world_info.get_snake_length()

	return snake_length


func get_is_object_visible(object: GameEngine.GameObject) -> bool:
	var is_visible: bool = await world_info.get_is_object_visible(object)

	return is_visible


func is_position_taken(
	position: Vector2,
	debug: bool = false,
	debug_from: String = "",
) -> bool:
	var is_taken: bool = await world_info.is_position_taken(
		position,
		debug,
		debug_from,
	)

	return is_taken


func play_scripted_event(
	event_callable: Callable,
	callable_args: Dictionary = {},
) -> void:
	event_callable.call(callable_args)
	await EventBus.scripted_event_completed


func queue_object_to_spawn(
	object_name: String,
	position: Vector2 = await get_random_valid_world_position(),
	force_preferred_position: bool = false,
) -> GameEngine.GameObject:
	var spawned_object: GameEngine.GameObject = (
		await object_spawner.queue_object_to_spawn(
			object_name,
			position,
			force_preferred_position,
		)
	)

	return spawned_object


func spawn_background(offset:= Vector2(0, 0)) -> void:
	object_spawner.spawn_background(offset)


func spawn_barrier(position: Vector2) -> void:
	object_spawner.spawn_barrier(position)


func spawn_doors(exclusions: Array[String] = []) -> void:
	object_spawner.spawn_doors(exclusions)


func spawn_object_instantly(
	object_name: String,
	position: Vector2 = await get_random_valid_world_position(),
) -> GameEngine.GameObject:
	var new_object: GameEngine.GameObject = await (
		object_spawner.spawn_object_instantly(object_name, position)
	)

	return new_object


func spawn_snake_segment(
	head_game_object: GameEngine.GameObject,
	spawn_position: Vector2,
) -> void:
	object_spawner.spawn_snake_segment(
		head_game_object,
		spawn_position,
	)


func spawn_player_snake(
	start_position: Vector2,
	snake_length: int,
	slow: bool = false,
) -> void:
	object_spawner.spawn_player_snake(
		start_position,
		snake_length,
		slow,
	)


func spawn_start_barriers() -> void:
	object_spawner.spawn_start_barriers()


func toggle_timer_freeze(allow_unpause: bool = true) -> void:
	if timer_frozen and not allow_unpause:
		return

	timer_frozen = not timer_frozen
	move_timer.paused = not move_timer.paused


func _connect_signals() -> void:
	spawn_timer.timeout.connect(_spawn_object_from_queue)
	EventBus.game_started.connect(_on_game_start)
	EventBus.pause_requested.connect(_on_pause_requested)


func _on_game_start(_gamemode_name: String) -> void:
	move_timer.start()
	is_game_started = true


func _on_pause_requested() -> void:
	is_paused = not is_paused

	EventBus.game_paused.emit(is_paused)

	if not is_paused:
		gamemode_node.game_announcer.announce_message("3 2 1 GO", 0.25)
		await EventBus.announcement_completed

	if not timer_frozen:
		move_timer.paused = is_paused



func _setup_utils() -> void:
	item_pickup_observer = ItemPickupObserver.new(self, move_timer)
	move_timer_notifier = MoveTimerNotifier.new(move_timer, game_object_factory)
	apple_flipper = AppleFlipper.new(self)
	object_spawner = ObjectSpawner.new(self)
	input_handler = InputHandler.new(game_object_factory)
	world_info = WorldInfo.new(game_object_factory, self)


func _spawn_object_from_queue() -> void:
	object_spawner._spawn_object_from_queue()
