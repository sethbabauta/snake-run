class_name Components extends GameEngine


class AIControlledSimple extends Component:


	func fire_event(event: Event) -> Event:
		if event.id == "MoveForward":
			self._ponder_direction_change(event)

		return event


	func _ponder_direction_change(event: Event) -> void:
		var closest_object: GameEngine.GameObject = (
				self.game_object.main_node.get_closest_player_controlled(
						self.game_object.physics_body.global_position
				)
		)

		var current_position: Vector2 = self.game_object.physics_body.global_position
		var target_position: Vector2 = closest_object.physics_body.global_position
		var direction: String = (
				Utils.get_farthest_direction(current_position, target_position)
		)

		var new_event:= Event.new("ChangeDirection")
		new_event.parameters["direction"] = direction
		Event.queue_after_effect(self.game_object, new_event, event)


class DeathSpawner extends Component:
	var name_of_object: String


	func fire_event(event: Event) -> Event:
		if event.id == "KillSelf":
			self._spawn_object()

		return event


	func _spawn_object() -> void:
		self.game_object.main_node.spawn_and_place_object(name_of_object)


class Debugger extends Component:


	func fire_event(event: Event) -> Event:
		var to_print: String = "Debugger Component"
		#print(to_print)

		return event


class EquipabbleItem extends Component:
	var components_as_string: String = ""
	var components_to_inherit: PackedStringArray = []


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._bequeath_components(event)
		if event.id == "DropItem":
			self._relinquish_components()

		return event


	func first_time_setup() -> void:
		components_to_inherit = components_as_string.split(",")
		components_to_inherit.append("EquipabbleItem")


	func _bequeath_components(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		for component_name in self.components_to_inherit:
			var component_parameters: Dictionary = (
					self.game_object.components[component_name]
					.initial_parameters
			)
			eater.add_component(component_name, component_parameters)

		var new_event:= Event.new(
				"EquipItem",
				{"item_name": self.game_object.name},
		)
		Event.queue_after_effect(eater, new_event, event)


	func _relinquish_components() -> void:
		for component_name in self.components_to_inherit:
			self.game_object.queue_remove_component(component_name)


class InventorySlot extends Component:
	var item_name: String = ""


	func fire_event(event: Event) -> Event:
		if event.id == "EquipItem":
			self._equip_item(event)
		if event.id == "DropItem":
			self._drop_item()

		return event


	func _drop_item() -> void:
		if self.item_name:
			self.game_object.main_node.spawn_and_place_object(item_name)
			self.item_name = ""


	func _equip_item(event: Event) -> void:
		self.item_name = event.parameters.get("item_name")


class Movable extends Component:
	const VALID_DIRECTIONS: Array = ["N", "S", "E", "W"]
	var speed: int = 3
	var direction: String = "N"


	func fire_event(event: Event) -> Event:
		if event.id == "MoveForward":
			self._move_forward(event)
		if event.id == "ChangeDirection":
			self._change_direction(event)
		if event.id == "TryChangeDirection":
			self._try_change_direction(event)
		if event.id == "ChangeSpeed":
			var new_speed: int = event.parameters.get("speed")
			self._set_speed(new_speed)
		if event.id == "IncreaseSpeed":
			self._increase_speed(event)
		if event.id == "DecreaseSpeed":
			self._decrease_speed(event)

		return event


	func first_time_setup() -> void:
		var subscribe_list_name: String = "movable%d" % self.speed
		self.game_object.factory_from.subscribe(self.game_object, subscribe_list_name)


	func _change_direction(event: Event) -> void:
		if event.parameters.get("direction") in self.VALID_DIRECTIONS:
			self.direction = event.parameters.get("direction")


	func _decrease_speed(event: Event) -> void:
		var amount: int = event.parameters.get("amount")
		if amount:
			self._set_speed(self.speed - amount)


	func _increase_speed(event: Event) -> void:
		var amount: int = event.parameters.get("amount")
		if amount:
			self._set_speed(self.speed + amount)


	func _set_speed(new_speed: int) -> void:
		var subscribe_list_name: String = "movable%d" % self.speed
		self.game_object.factory_from.unsubscribe(self.game_object, subscribe_list_name)

		if new_speed > 5:
			new_speed = 5

		if new_speed < 1:
			new_speed = 1

		if new_speed >= 1:
			self.speed = new_speed

		subscribe_list_name = "movable%d" % self.speed
		self.game_object.factory_from.subscribe(self.game_object, subscribe_list_name)


	func _move_forward(event: Event) -> void:
		match self.direction:
			"N":
				self.game_object.physics_body.global_translate(
						Vector2.UP * Settings.BASE_MOVE_SPEED
				)
			"S":
				self.game_object.physics_body.global_translate(
						Vector2.DOWN * Settings.BASE_MOVE_SPEED
				)
			"E":
				self.game_object.physics_body.global_translate(
						Vector2.RIGHT * Settings.BASE_MOVE_SPEED
				)
			"W":
				self.game_object.physics_body.global_translate(
						Vector2.LEFT * Settings.BASE_MOVE_SPEED
				)

		var new_event:= Event.new("MovedForward", {"direction": self.direction})
		Event.queue_after_effect(self.game_object, new_event, event)


	func _try_change_direction(event: Event) -> void:
		var new_event:= Event.new("ChangeDirection", event.parameters.duplicate(true))
		new_event.parameters["current_direction"] = self.direction
		Event.queue_after_effect(self.game_object, new_event, event)


class Nutritious extends Component:


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._feed_nutrition(event)

		return event


	func _feed_nutrition(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		if eater:
			var new_event:= Event.new("Grow", {"amount": 1})
			eater.fire_event(new_event)


class PhysicsBody extends Component:
	var physics_body_scene: PackedScene = load(Settings.PHYSICS_OBJECT_PATH)
	var physics_body_node: PhysicsObject


	func _init(name: String, game_object: GameObject = null) -> void:
		super(name, game_object)
		self.physics_body_node = self.physics_body_scene.instantiate()


	func fire_event(event: Event) -> Event:
		if event.id == "MovedForward":
			self._check_eat()
		if event.id == "Eat":
			self._get_eaten(event)
		if event.id == "KillSelf":
			self._kill_self()
		if event.id == "IngestPoison":
			self._ingest_poison(event)

		return event


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


	func _get_eaten(event: Event) -> void:
		var kill_self_event:= Event.new("KillSelf")
		Event.queue_after_effect(self.game_object, kill_self_event, event)


	func _ingest_poison(event: Event):
		if event.parameters["poison_level"] > 0:
			var kill_self_event:= Event.new("KillSelf")
			Event.queue_after_effect(self.game_object, kill_self_event, event)


	func _kill_self() -> void:
		self.game_object.delete_self()


class PlayerControlled extends Component:
	var last_direction_moved: String = "0"


	func _init(name: String, game_object: GameObject = null) -> void:
		super(name, game_object)
		self.game_object.factory_from.subscribe(
				game_object, "player_controlled"
		)


	func fire_event(event: Event) -> Event:
		if event.id == "ChangeDirection":
			self._change_direction(event)
		if event.id == "MovedForward":
			self._save_direction(event)
		if event.id == "Grow":
			self._grow_score()
		if event.id == "KillSelf":
			self._queue_death(event)
		if event.id == "Die":
			self._end_game()

		return event


	func _change_direction(event: Event) -> void:
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


	func _end_game() -> void:
		self.game_object.main_node.gamemode_node.end_game()


	func _grow_score() -> void:
		ScoreKeeper.add_to_score(1)


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


	func _queue_death(event: Event) -> void:
		var die_event:= Event.new("Die")
		Event.queue_after_effect(self.game_object, die_event, event)


	func _save_direction(event: Event) -> void:
		self.last_direction_moved = event.parameters.get("direction")


class Poisonous extends Component:
	var poison_level: int = 1000


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._send_poison(event)

		return event


	func _send_poison(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		if eater:
			var new_event:= Event.new(
					"IngestPoison",
					{"poison_level": poison_level},
			)
			eater.fire_event(new_event)


class Render extends Component:
	var texture: String = ""
	var sprite_node: Sprite2D
	var z_idx: int


	func fire_event(event: Event) -> Event:
		if event.id == "SetPosition":
			self.game_object.physics_body.global_position = (
					event.parameters.get("position")
			)

		return event


	func first_time_setup() -> void:
		self.sprite_node = self.game_object.physics_body.get_node("PhysicsObjectSprite")
		self.sprite_node.texture = load(self.texture)
		self.sprite_node.z_index = z_idx


class SnakeBody extends Component:
	var next_body: GameObject = null
	var prev_body: GameObject = null
	var prev_location: Vector2


	func fire_event(event: Event) -> Event:
		if event.id == "FollowNextBody":
			self._follow_next_body(event)
		if event.id == "MoveForward":
			self._move_forward(event)
		if event.id == "Grow":
			self._grow()
		if event.id == "KillSelf":
			self._disconnect_bodies()
		if event.id == "IngestPoison":
			self._pass_poison(event)

		return event


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


	func _disconnect_bodies() -> void:
		if self.next_body:
			var next_body_snakebody: SnakeBody = self.next_body.components.get("SnakeBody")
			next_body_snakebody.prev_body = null
		if self.prev_body:
			var prev_body_snakebody: SnakeBody = self.prev_body.components.get("SnakeBody")
			prev_body_snakebody.next_body = null


	func _follow_next_body(event: Event) -> void:
		if self.next_body:
			var next_snake_body: SnakeBody = self.next_body.components.get("SnakeBody")
			self.prev_location = self.game_object.physics_body.global_position
			self.game_object.physics_body.global_position = next_snake_body.prev_location

		if self.prev_body:
			Event.queue_after_effect(
					self.prev_body,
					Event.new("FollowNextBody"),
					event,
			)


	func _grow() -> void:
		self.game_object.main_node.spawn_snake_segment(self.game_object, Vector2.ZERO)


	func _move_forward(event: Event) -> void:
		self.prev_location = self.game_object.physics_body.global_position

		if self.prev_body:
			Event.queue_after_effect(prev_body, Event.new("FollowNextBody"), event)


	func _pass_poison(event: Event) -> void:
		var poison_level: int = event.parameters["poison_level"]

		# pass poison event to tail
		if self.prev_body:
			Event.dequeue_after_effect(event, "KillSelf")
			var new_event:= Event.new(
					"IngestPoison",
					{"poison_level": poison_level},
			)
			Event.queue_after_effect(self.prev_body, new_event, event)
			return

		if poison_level > 0 and self.next_body:
			var new_event:= Event.new(
					"IngestPoison",
					{"poison_level": poison_level-1},
			)
			Event.queue_after_effect(self.next_body, new_event, event)


class SpeedIncrease extends Component:
	var increase_amount: int = 1


	func on_add():
		var new_event:= Event.new(
				"IncreaseSpeed",
				{"amount": self.increase_amount},
		)
		self.game_object.fire_event(new_event)


	func on_remove():
		var new_event:= Event.new(
				"DecreaseSpeed",
				{"amount": self.increase_amount},
		)
		self.game_object.fire_event(new_event)


class SpeedIncreaseAbility extends Component:
	var increase_amount: int = 1


	func fire_event(event: Event) -> Event:
		if event.id == "UseItem":
			self._temporarily_increase_speed()

		return event


	func _temporarily_increase_speed() -> void:
		pass
