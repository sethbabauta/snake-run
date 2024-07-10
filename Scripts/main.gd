class_name Main extends Node

@export var follow_camera: Camera2D
@export var gamemode_node: Node

var game_object_factory: GameEngine.GameObjectFactory
var level_factory: LevelFactory
var max_simple_size: Vector2
var query_area: Area2D
var background_tile: PackedScene = load(Settings.GRASS_BACKGROUND_SCENE_PATH)
var spawn_queue: Array[SpawnJob] = []

@onready var move_timer: MoveTimer = %MoveTimer
@onready var powerup_1_timer: Timer = %Powerup1Timer
@onready var spawn_timer: Timer = %SpawnTimer
@onready var audio_library: Node2D = %AudioLibrary


func _init() -> void:
	self.game_object_factory = GameEngine.GameObjectFactory.new()
	self.level_factory = LevelFactory.new(self)


func _ready() -> void:
	move_timer.speed_1.connect(_on_move_timer_speed_1)
	move_timer.speed_2.connect(_on_move_timer_speed_2)
	move_timer.speed_3.connect(_on_move_timer_speed_3)
	move_timer.speed_4.connect(_on_move_timer_speed_4)
	move_timer.speed_5.connect(_on_move_timer_speed_5)
	spawn_timer.timeout.connect(_spawn_object_from_queue)
	EventBus.game_started.connect(_on_game_start)

	self.query_area = follow_camera.get_node("CollisionQuery")
	ScoreKeeper.set_score(gamemode_node.START_LENGTH)
	self.max_simple_size = (get_viewport().get_visible_rect().size / Settings.BASE_MOVE_SPEED)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("turn_up"):
		self._fire_change_direction_event("turn_up")

	if event.is_action_pressed("turn_left"):
		self._fire_change_direction_event("turn_left")

	if event.is_action_pressed("turn_down"):
		self._fire_change_direction_event("turn_down")

	if event.is_action_pressed("turn_right"):
		self._fire_change_direction_event("turn_right")

	if event.is_action_pressed("drop_item"):
		self._fire_drop_item_event()

	if event.is_action_pressed("use_item"):
		self._fire_use_item_event()

	if event.is_action_pressed("pause"):
		pause_or_play()


static func apply_shader_to_physics_body(
	target: GameEngine.GameObject,
	sprite_node_name: String,
	material_name: String,
) -> void:
	var shader_material_path: String = Settings.SHADERS_PATH + material_name
	var shader_material: Material = load(shader_material_path)
	var sprite_node: Sprite2D = target.physics_body.get_node(sprite_node_name)
	sprite_node.material = shader_material


static func apply_shader_to_snake(
	target_head: GameEngine.GameObject,
	material_name: String,
) -> void:
	Main.apply_shader_to_physics_body(target_head, "EquippedItem", material_name)

	var current_snakebody: Components.SnakeBody = target_head.components.get("SnakeBody")
	while current_snakebody != null:
		(
			Main
			. apply_shader_to_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
				material_name,
			)
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


func check_is_player_alive() -> bool:
	var player_positions: Array = game_object_factory.subscribe_lists["player_controlled"]
	var is_player_alive: bool = false
	if player_positions.size() > 0:
		is_player_alive = true

	return is_player_alive


func clear_doors(exclusions: Array = []) -> void:
	var door_locations: Array = get_simple_door_locations(exclusions)
	for door_location in door_locations:
		var door_world_location: Vector2 = Utils.convert_simple_to_world_coordinates(door_location)
		var door_game_object: GameEngine.GameObject = get_game_object_at_position_or_null(
			door_world_location
		)
		if not door_game_object:
			continue

		if door_game_object.name != "Door":
			continue

		door_game_object.delete_self()


func clear_pickup(pickup_name: String) -> int:
	var pickups: Array[GameEngine.GameObject] = await get_game_objects_of_name(pickup_name)
	var pickups_cleared: int = 0
	for pickup in pickups:
		pickup.delete_self()
		pickups_cleared += 1

	return pickups_cleared


func clear_pickups() -> int:
	var pickups_to_clear: Array = [
		"Apple",
		"PoisonApple",
	]

	var pickups_cleared: int = 0
	for pickup_name in pickups_to_clear:
		pickups_cleared += await clear_pickup(pickup_name)

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


func delete_and_replace(
	object_to_delete: GameEngine.GameObject,
	name_of_replacement: String,
) -> void:
	var object_position: Vector2 = object_to_delete.physics_body.global_position
	object_to_delete.delete_self()
	var new_object := self.game_object_factory.create_object(name_of_replacement, self)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": object_position})
	new_object.fire_event(set_position_event)


func end_game_soon() -> void:
	move_timer.paused = true
	await get_tree().create_timer(3).timeout

	if not check_is_player_alive():
		gamemode_node.end_game()
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
	flip_objects("Apple", "SlightlyPoisonousAppleNoRespawn")

	var flip_to: String = "AppleNoRespawn"
	if nutritious:
		flip_to = "NutritiousAppleNoRespawn"

	flip_objects("SlightlyPoisonousApple", flip_to)



func flip_apples_back(nutritious: bool = false) -> void:
	var flip_to: String = "AppleNoRespawn"
	if nutritious:
		flip_to = "NutritiousAppleNoRespawn"
	flip_objects(flip_to, "SlightlyPoisonousApple")

	var slightly_poisonous_apples: Array[GameEngine.GameObject] = await get_game_objects_of_name(
		"SlightlyPoisonousAppleNoRespawn"
	)
	if not slightly_poisonous_apples:
		queue_object_to_spawn("Apple")
		return

	flip_objects("SlightlyPoisonousAppleNoRespawn", "Apple")


func flip_objects(target_name: String, flip_to: String) -> void:
	var target_objects: Array[GameEngine.GameObject] = await get_game_objects_of_name(target_name)
	for target_object in target_objects:
		delete_and_replace(target_object, flip_to)


func get_closest_player_controlled(
	position_to_compare: Vector2,
) -> GameEngine.GameObject:
	var player_positions: Array = self.game_object_factory.subscribe_lists["player_controlled"]
	var closest_object: GameEngine.GameObject
	var shortest_distance: float

	for current_game_object in player_positions:
		var current_distance: float = current_game_object.physics_body.global_position.distance_to(
			position_to_compare
		)

		if not shortest_distance:
			shortest_distance = current_distance
			closest_object = current_game_object
			continue

		if shortest_distance > current_distance:
			shortest_distance = current_distance
			closest_object = current_game_object

	return closest_object


func get_game_object_at_position_or_null(position: Vector2) -> Variant:
	if not self.query_area.has_overlapping_areas():
		return null

	var found_game_object: GameEngine.GameObject
	for area in query_area.get_overlapping_areas():
		if area.global_position.is_equal_approx(position):
			found_game_object = area.game_object

	return found_game_object


func get_game_objects_of_name(search_name: String) -> Array[GameEngine.GameObject]:
	var visible_game_objects: Array[GameEngine.GameObject] = await get_visible_game_objects()
	var found_game_objects: Array[GameEngine.GameObject] = []
	if not visible_game_objects:
		return found_game_objects

	for object in visible_game_objects:
		if object.name == search_name:
			found_game_objects.append(object)

	return found_game_objects


func get_random_valid_world_position() -> Vector2:
	var position := Vector2.ONE

	for try_count in range(1000):
		position = self.get_random_world_position()
		if not await is_position_taken(position):
			break

	return position


func get_random_world_position() -> Vector2:
	var rng := RandomNumberGenerator.new()
	var position := Vector2(
		rng.randi_range(0, self.max_simple_size.x - 1.0),
		rng.randi_range(0, self.max_simple_size.y - 1.0),
	)
	var camera_offset: Vector2 = (
		Utils.convert_world_to_simple_coordinates(self.follow_camera.global_position)
		- Vector2(10, 10)
	)
	position += camera_offset
	position = Utils.convert_simple_to_world_coordinates(position)

	return position


func get_simple_door_locations(exclusions: Array[String] = []) -> Array:
	var camera_coordinates: Vector2 = follow_camera.global_position
	var simple_camera_coordinates: Vector2 = Utils.convert_world_to_simple_coordinates(
		camera_coordinates
	)
	var door_positions_north: Array = [
		simple_camera_coordinates + Vector2(0, -10),
		simple_camera_coordinates + Vector2(-1, -10),
	]
	var door_positions_south: Array = [
		simple_camera_coordinates + Vector2(0, 9),
		simple_camera_coordinates + Vector2(-1, 9),
	]
	var door_positions_east: Array = [
		simple_camera_coordinates + Vector2(9, 0),
		simple_camera_coordinates + Vector2(9, -1),
	]
	var door_positions_west: Array = [
		simple_camera_coordinates + Vector2(-10, 0),
		simple_camera_coordinates + Vector2(-10, -1),
	]

	var door_positions: Array = []
	if "N" not in exclusions:
		door_positions += door_positions_north
	if "S" not in exclusions:
		door_positions += door_positions_south
	if "E" not in exclusions:
		door_positions += door_positions_east
	if "W" not in exclusions:
		door_positions += door_positions_west

	return door_positions


func get_snake_length() -> int:
	var snake_length: int = 0

	if not get_tree():
		return snake_length

	await get_tree().create_timer(0.05).timeout
	var snake_heads: Array[GameEngine.GameObject] = await get_game_objects_of_name("PlayerSnakeHead")

	if snake_heads:
		var snake_component: Components.SnakeBody = snake_heads[0].components.get("SnakeBody")
		snake_length = snake_component.get_length_from_here()

	return snake_length


func get_taken_positions() -> Array:
	var taken_positions: Array = []
	await get_tree().physics_frame
	if self.query_area.has_overlapping_areas():
		for area in query_area.get_overlapping_areas():
			taken_positions.append(area.global_position)

	return taken_positions


func get_visible_game_objects() -> Array[GameEngine.GameObject]:
	var game_objects: Array[GameEngine.GameObject] = []
	await get_tree().physics_frame
	if not self.query_area.has_overlapping_areas():
		return game_objects

	for area in query_area.get_overlapping_areas():
		game_objects.append(area.game_object)

	return game_objects


func get_is_object_visible(object: GameEngine.GameObject) -> bool:
	var visible_objects: Array = await get_visible_game_objects()
	var is_visible: bool = false

	if object in visible_objects:
		is_visible = true

	return is_visible


func is_position_taken(position: Vector2, debug: bool = false, debug_from: String = "") -> bool:
	var taken_positions: Array = await get_taken_positions()
	var is_taken: bool = true

	if position not in taken_positions:
		is_taken = false

	if debug:
		print("debug from: ", debug_from, ", searched position: ", position, ", is taken: ", is_taken, ", taken positions: ", taken_positions)

	return is_taken


static func overlay_sprite_on_game_object(
	sprite_path: String,
	target: GameEngine.GameObject,
	sprite_node_name: String,
	z_idx: int = 1,
	offset := Vector2(0, 0)
) -> void:
	var new_sprite := Sprite2D.new()
	new_sprite.texture = load(sprite_path)
	new_sprite.z_index = z_idx
	new_sprite.name = sprite_node_name
	target.physics_body.add_child(new_sprite)
	new_sprite.position += offset


func pause_or_play() -> void:
	move_timer.paused = not move_timer.paused
	EventBus.game_paused.emit(move_timer.paused)


func play_scripted_event(
	event_callable: Callable,
	callable_args: Dictionary = {},
) -> void:
	move_timer.paused = true
	event_callable.call(callable_args)
	await EventBus.scripted_event_completed
	move_timer.paused = false


func queue_object_to_spawn(
	object_name: String,
	position: Vector2 = await get_random_valid_world_position(),
	force_preferred_position: bool = false,
) -> GameEngine.GameObject:
	var new_object := self.game_object_factory.create_object(object_name, self)
	var new_spawn_job := SpawnJob.new(new_object, position, force_preferred_position)
	spawn_queue.append(new_spawn_job)

	return new_object


static func remove_overlay_sprite_from_physics_body(
	target: GameEngine.GameObject,
	sprite_node_name: String,
) -> void:
	var sprite_node: Sprite2D = target.physics_body.get_node_or_null(sprite_node_name)
	if sprite_node:
		sprite_node.queue_free()


static func remove_shader_from_physics_body(
	target: GameEngine.GameObject,
	sprite_node_name: String,
) -> void:
	var sprite_node: Sprite2D = target.physics_body.get_node_or_null(sprite_node_name)
	if sprite_node:
		sprite_node.material = null


static func remove_shader_from_snake(
	target_head: GameEngine.GameObject,
) -> void:
	Main.remove_shader_from_physics_body(target_head, "EquippedItem")

	var current_snakebody: Components.SnakeBody = target_head.components.get("SnakeBody")
	while current_snakebody != null:
		(
			Main
			. remove_shader_from_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
			)
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


func spawn_background(offset: Vector2 = Vector2(0, 0)) -> void:
	for x in range(self.max_simple_size.x):
		for y in range(self.max_simple_size.y):
			self._spawn_background_tile(Vector2(x, y) + offset)


func spawn_barrier(position: Vector2) -> void:
	var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
	var barrier := self.game_object_factory.create_object("Barrier", self)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": world_position})
	barrier.fire_event(set_position_event)


func spawn_doors(exclusions: Array[String] = []) -> void:
	var door_positions: Array = get_simple_door_locations(exclusions)

	for position in door_positions:
		var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
		if not await is_position_taken(world_position):
			queue_object_to_spawn("Door", world_position, true)


func spawn_object_instantly(
	object_name: String,
	position: Vector2 = await get_random_valid_world_position(),
) -> GameEngine.GameObject:
	var new_object := self.game_object_factory.create_object(object_name, self)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": position})
	new_object.fire_event(set_position_event)

	return new_object


func spawn_snake_segment(
	head_game_object: GameEngine.GameObject,
	spawn_position: Vector2,
) -> void:
	var head_snake_body: Components.SnakeBody = head_game_object.components.get("SnakeBody")
	var tail: GameEngine.GameObject = head_snake_body.get_tail_game_object()

	var new_snake_body_obj: GameEngine.GameObject = await queue_object_to_spawn(
		"SnakeBody", spawn_position, true
	)

	Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)


func spawn_player_snake(start_position: Vector2, snake_length: int, slow: bool = false) -> void:
	var spawn_position: Vector2 = start_position
	var snake_type: String = "PlayerSnakeHead"
	if slow:
		snake_type = "PlayerSnakeHeadSlow"
	var snake_head := await queue_object_to_spawn(snake_type, spawn_position)

	for snake_body_idx in range(snake_length - 1):
		spawn_position = spawn_position + (Vector2.DOWN * Settings.BASE_MOVE_SPEED)
		self.spawn_snake_segment(snake_head, spawn_position)


func _fire_change_direction_event(input_name: String) -> void:
	var new_event := GameEngine.Event.new("TryChangeDirection", {"input": input_name})
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_drop_item_event() -> void:
	var new_event := GameEngine.Event.new("DropItem")
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_use_item_event() -> void:
	var new_event := GameEngine.Event.new("UseItem")
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _on_game_start(_gamemode_name: String) -> void:
	move_timer.start()


func _on_move_timer_speed_1() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable1")


func _on_move_timer_speed_2() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable2")


func _on_move_timer_speed_3() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable3")


func _on_move_timer_speed_4() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable4")


func _on_move_timer_speed_5() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable5")


func _spawn_background_tile(position: Vector2) -> void:
	var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
	var current_tile: Sprite2D = self.background_tile.instantiate()
	self.add_child(current_tile)
	current_tile.global_position = world_position


func _spawn_object_from_queue() -> void:
	if not spawn_queue:
		return

	var current_spawn_job: SpawnJob = spawn_queue.pop_front()
	var position: Vector2 = current_spawn_job.preferred_position
	var object_to_spawn: GameEngine.GameObject = current_spawn_job.object_to_spawn
	if await is_position_taken(position) and not current_spawn_job.force_preferred_position:
		position = await get_random_valid_world_position()

	if await is_position_taken(position) and not current_spawn_job.force_preferred_position:
		var warning: String = (
			"Attempted to spawn "
			+ object_to_spawn._to_string()
			+ " at position "
			+ str(position)
		)
		push_warning(warning)
		return

	var set_position_event := GameEngine.Event.new("SetPosition", {"position": position})
	object_to_spawn.fire_event(set_position_event)


func spawn_start_barriers() -> void:
	self.spawn_barrier(Vector2(0, 0))
	self.spawn_barrier(Vector2(self.max_simple_size.x - 1, 0))
	self.spawn_barrier(Vector2(0, self.max_simple_size.y - 1))
	self.spawn_barrier(Vector2(self.max_simple_size.x - 1, self.max_simple_size.y - 1))

	for coordinate in range(1, self.max_simple_size.x - 1):
		self.spawn_barrier(Vector2(coordinate, 0))
		self.spawn_barrier(Vector2(coordinate, self.max_simple_size.y - 1))
		self.spawn_barrier(Vector2(0, coordinate))
		self.spawn_barrier(Vector2(self.max_simple_size.x - 1, coordinate))


class SpawnJob:
	var object_to_spawn: GameEngine.GameObject
	var preferred_position: Vector2
	var force_preferred_position: bool

	func _init(
		p_object_to_spawn: GameEngine.GameObject,
		p_preferred_position: Vector2,
		p_force_preferred_position: bool = false,
	) -> void:
		object_to_spawn = p_object_to_spawn
		preferred_position = p_preferred_position
		force_preferred_position = p_force_preferred_position
