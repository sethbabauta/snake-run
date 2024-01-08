class_name Components extends GameEngine


class Movable extends Component:
	const VALID_DIRECTIONS: Array = ["N", "S", "E", "W"]
	var speed: int = 0
	var direction: String = "N"

	func _init(game_object: GameObject = null) -> void:
		super(game_object)
		self.game_object.factory_from.subscribe(game_object, "movable")


	func _move_forward() -> void:
		match self.direction:
			"N":
				self.game_object.physics_body.global_translate(
						Vector2.UP * Main.BASE_MOVE_SPEED
				)
			"S":
				self.game_object.physics_body.global_translate(
						Vector2.DOWN * Main.BASE_MOVE_SPEED
				)
			"E":
				self.game_object.physics_body.global_translate(
						Vector2.RIGHT * Main.BASE_MOVE_SPEED
				)
			"W":
				self.game_object.physics_body.global_translate(
						Vector2.LEFT * Main.BASE_MOVE_SPEED
				)

		var new_event:= Event.new("MovedForward", {"direction": self.direction})
		self.game_object.queue_event_job(self.game_object, new_event)


	func _change_direction(event: Event) -> void:
		if event.parameters.get("direction") in self.VALID_DIRECTIONS:
			self.direction = event.parameters.get("direction")


	func _try_change_direction(event: Event) -> void:
		var new_event:= Event.new("ChangeDirection", event.parameters.duplicate(true))
		new_event.parameters["current_direction"] = self.direction
		self.game_object.queue_event_job(self.game_object, new_event)


	func fire_event(event: Event) -> Event:
		if event.id == "MoveForward":
			self._move_forward()
		if event.id == "ChangeDirection":
			self._change_direction(event)
		if event.id == "TryChangeDirection":
			self._try_change_direction(event)

		return event


class Nutritious extends Component:

	func _eat_nutritious(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		if eater:
			var new_event:= Event.new("Grow", {"amount": 1})
			eater.fire_event(new_event)

		self.game_object.main_node.spawn_apple()
		self.game_object.delete_self()


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._eat_nutritious(event)

		return event


class PhysicsBody extends Component:
	var physics_body_scene: PackedScene = load(Main.PHYSICS_OBJECT_PATH)
	var physics_body_node: PhysicsObject


	func _init(game_object: GameObject = null) -> void:
		super(game_object)
		self.physics_body_node = self.physics_body_scene.instantiate()


	func first_time_setup() -> void:
		self.game_object.physics_body = self.physics_body_node
		self.game_object.main_node.add_child(self.physics_body_node)
		self.physics_body_node.game_object = self.game_object


	func _check_eat() -> void:
		if self.physics_body_node.has_overlapping_areas():
			var areas: Array = self.physics_body_node.get_overlapping_areas().duplicate(true)
			var new_event:= Event.new("Eat", {"eater": self.game_object})
			for area in areas:
				area.game_object.fire_event(new_event)


	func _grow() -> void:
		self.game_object.main_node.spawn_player_body(self.game_object)


	func fire_event(event: Event) -> Event:
		if event.id == "MovedForward":
			self._check_eat()
		if event.id == "Grow":
			self._grow()

		return event


class PlayerControlled extends Component:
	var last_direction_moved: String = "0"


	func _init(game_object: GameObject = null) -> void:
		super(game_object)
		self.game_object.factory_from.subscribe(
				game_object, "player_controlled"
		)


	func change_direction(event: Event) -> void:
		var new_direction: String
		match event.parameters.get("input"):
			"turn_up":
				new_direction = "N"
			"turn_left":
				new_direction = "W"
			"turn_down":
				new_direction = "S"
			"turn_right":
				new_direction = "E"

		if not _is_opposite_direction(
				self.last_direction_moved,
				new_direction,
		):
			event.parameters["direction"] = new_direction
		else:
			event.parameters["direction"] = "0"


	func save_direction(event: Event) -> void:
		self.last_direction_moved = event.parameters.get("direction")


	func _is_opposite_direction(
			current_direction: String,
			new_direction: String,
	) -> bool:

		if current_direction == "N" and new_direction == "S":
			return true
		if current_direction == "S" and new_direction == "N":
			return true
		if current_direction == "E" and new_direction == "W":
			return true
		if current_direction == "W" and new_direction == "E":
			return true
		return false


	func fire_event(event: Event) -> Event:
		if event.id == "ChangeDirection":
			self.change_direction(event)
		if event.id == "MovedForward":
			self.save_direction(event)

		return event


class Poisonous extends Component:

	func _end_game() -> void:
		self.game_object.main_node.get_tree().quit()

	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._end_game()

		return event


class Render extends Component:
	var texture: String = ""
	var sprite_node: Sprite2D


	func first_time_setup() -> void:
		self.sprite_node = self.game_object.physics_body.get_node("PhysicsObjectSprite")
		self.sprite_node.texture = load(self.texture)


	func fire_event(event: Event) -> Event:
		if event.id == "SetPosition":
			self.game_object.physics_body.global_position = (
					event.parameters.get("position")
			)

		return event


class SnakeBody extends Component:
	var next_body: GameObject = null
	var prev_body: GameObject = null
	var prev_location: Vector2


	static func connect_bodies(
			next_body: GameObject,
			prev_body: GameObject,
	) -> void:

		var next_body_snakebody: SnakeBody = next_body.components.get("SnakeBody")
		var prev_body_snakebody: SnakeBody = prev_body.components.get("SnakeBody")
		if next_body_snakebody and prev_body_snakebody:
			next_body_snakebody.prev_body = prev_body
			prev_body_snakebody.next_body = next_body


	func get_tail_game_object() -> GameObject:
		if not self.prev_body:
			return self.game_object

		var prev_snake_body: SnakeBody = self.prev_body.components.get("SnakeBody")
		return prev_snake_body.get_tail_game_object()


	func _follow_next_body() -> void:
		if self.next_body:
			var next_snake_body: SnakeBody = self.next_body.components.get("SnakeBody")
			self.prev_location = self.game_object.physics_body.global_position
			self.game_object.physics_body.global_position = next_snake_body.prev_location

		if self.prev_body:
			self.game_object.queue_event_job(
					self.prev_body,
					Event.new("FollowNextBody"),
			)


	func _move_forward() -> void:
		self.prev_location = self.game_object.physics_body.global_position

		if self.prev_body:
			self.game_object.queue_event_job(prev_body, Event.new("FollowNextBody"))


	func fire_event(event: Event) -> Event:
		if event.id == "FollowNextBody":
			self._follow_next_body()
		if event.id == "MoveForward":
			self._move_forward()

		return event
