class_name Components extends GameEngine


class ActiveCamoAbility:
	extends Component
	var ability_duration: float
	var cooldown_duration: float
	var on_cooldown: bool = false
	var ability_active: bool = false

	func fire_event(event: Event) -> Event:
		if event.id == "GetPosition":
			self._hide_position_if_active(event)
		if event.id == "UseItem":
			self._activate_camo()
		if event.id == "CooldownStart":
			self._start_cooldown()
		if event.id == "CooldownEnd":
			self._end_cooldown()
		if event.id == "DropItem":
			self._remove_effects()

		return event

	func _end_cooldown() -> void:
		self.on_cooldown = false
		Main.remove_shader_from_physics_body(self.game_object, "EquippedItem")

	func _hide_position_if_active(event: Event) -> void:
		if self.ability_active:
			Event.dequeue_after_effect(event, "GivePosition")

	func _remove_effects() -> void:
		if self.ability_active:
			Main.remove_shader_from_snake(self.game_object)

	func _start_cooldown() -> void:
		self.ability_active = false
		self.on_cooldown = true
		Main.remove_shader_from_snake(self.game_object)
		(
			Main
			. apply_shader_to_physics_body(
				self.game_object,
				"EquippedItem",
				"gray_material.tres",
			)
		)

	func _activate_camo() -> void:
		if not self.on_cooldown:
			self.ability_active = true
			(
				self
				. game_object
				. main_node
				. cooldown(
					self.ability_duration,
					self.cooldown_duration,
					self.game_object,
				)
			)
			(
				Main
				. apply_shader_to_snake(
					self.game_object,
					"transparent_material.tres",
				)
			)


class AIControlledSimple:
	extends Component

	func fire_event(event: Event) -> Event:
		if event.id == "MoveForward":
			self._ask_for_position(event)
		if event.id == "GivePosition":
			self._ponder_direction_change(event)

		return event

	func _ask_for_position(event: Event) -> void:
		var closest_object: GameEngine.GameObject = (
			self
			. game_object
			. main_node
			. get_closest_player_controlled(self.game_object.physics_body.global_position)
		)
		var new_event := Event.new("GetPosition", {"asker": self.game_object})
		Event.queue_after_effect(closest_object, new_event, event)

	func _ponder_direction_change(event: Event) -> void:
		var target_position: Vector2 = event.parameters.get("position")

		if target_position:
			var current_position: Vector2 = self.game_object.physics_body.global_position
			var direction: String = Utils.get_farthest_direction(current_position, target_position)

			var new_event := Event.new("ChangeDirection", {"direction": direction})
			Event.queue_after_effect(self.game_object, new_event, event)


class AppleFlipAbility:
	extends Component
	var flip_seconds: int = 10


	func fire_event(event: Event) -> Event:
		if event.id == "UseItem":
			self._flip_apples()

		return event


	func _flip_apples() -> void:
		var main_node: Main = game_object.main_node

		if main_node.powerup_1_timer.is_stopped():
			main_node.flip_apples(true)


class AppleFlipTimed:
	extends Component
	var flip_seconds: int = 10

	func fire_event(event: Event) -> Event:
		if event.id == "KillSelf":
			_temporarily_flip_apples()

		return event

	func _temporarily_flip_apples() -> void:
		var main_node: Main = game_object.main_node

		if main_node.powerup_1_timer.is_stopped():
			main_node.flip_apples()

		EventBus.powerup_1_activated.emit(flip_seconds)
		main_node.powerup_1_timer.start(flip_seconds)
		await main_node.powerup_1_timer.timeout

		main_node.flip_apples_back()


class Crown:
	extends Component

	func _init(p_name: String, p_game_object: GameObject = null) -> void:
		super(p_name, p_game_object)
		Main.overlay_sprite_on_game_object(
			Settings.SPRITES_PATH + "get_text.png",
			game_object,
			"getIndicator",
			3,
			Vector2(0, 0),
		)


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			_gain_crown(event)

		return event

	func _gain_crown(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		var new_event := (
			Event
			. new(
				"SendSprite",
				{"to": eater, "name": "EquippedItem", "offset": Vector2(0, -32)},
			)
		)
		Event.queue_after_effect(game_object, new_event, event)

		eater.add_component("Royalty", {})
		EventBus.crown_collected.emit()


class DeathSpawner:
	extends Component
	var names_as_string: String
	var names_of_objects: PackedStringArray = []

	func fire_event(event: Event) -> Event:
		if event.id == "KillSelf":
			self._spawn_objects()

		return event

	func _spawn_objects() -> void:
		names_of_objects = names_as_string.split(",")
		for names_of_object in names_of_objects:
			self.game_object.main_node.queue_object_to_spawn(names_of_object)


class Debugger:
	extends Component

	func fire_event(event: Event) -> Event:
		#var to_print: String = "Debugger Component"
		#print(to_print)

		return event


class Delicious:
	extends Component

	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._feed_delicious()

		return event

	func _feed_delicious() -> void:
		ScoreKeeper.add_to_score(1)


class EquipabbleItem:
	extends Component
	var components_as_string: String = ""
	var components_to_inherit: PackedStringArray = []

	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._bequeath_components(event)
			self._make_eater_equip_item(event)
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
				self.game_object.components[component_name].initial_parameters
			)
			eater.add_component(component_name, component_parameters)

	func _make_eater_equip_item(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")

		var new_event := GameEngine.Event.new("DropItem")
		self.game_object.fire_event(new_event)

		new_event = (
			Event
			. new(
				"EquipItem",
				{"item_name": self.game_object.name},
			)
		)
		Event.queue_after_effect(eater, new_event, event)

		new_event = (
			Event
			. new(
				"SendSprite",
				{"to": eater, "name": "EquippedItem"},
			)
		)
		Event.queue_after_effect(self.game_object, new_event, event)

	func _relinquish_components() -> void:
		for component_name in self.components_to_inherit:
			self.game_object.queue_remove_component(component_name)
		Main.remove_overlay_sprite_from_physics_body(self.game_object, "EquippedItem")


class ExtraLife:
	extends Component


	func fire_event(event: Event) -> Event:
		if event.id == "Die":
			_spawn_new_player(event)

		return event


	func _spawn_new_player(event: Event) -> void:
		var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(
			Vector2(9, 9)
		)
		var start_length: int = game_object.main_node.gamemode_node.START_LENGTH
		game_object.main_node.spawn_player_snake(start_position, start_length)
		game_object.remove_component("ExtraLife")


class ExtraLifeItem:
	extends Component


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			_gain_extra_life(event)

		return event


	func _gain_extra_life(event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		eater.add_component("ExtraLife", {})


class InventorySlot:
	extends Component
	var item_name: String = ""

	func fire_event(event: Event) -> Event:
		if event.id == "EquipItem":
			self._equip_item(event)
		if event.id == "DropItem":
			self._drop_item()
		if event.id == "ConsumeItem":
			_destroy_item()

		return event


	func _destroy_item() -> void:
		self.item_name = ""


	func _drop_item() -> void:
		if self.item_name:
			var drop_position: Vector2 = self._get_drop_position()
			self.game_object.main_node.queue_object_to_spawn(item_name, drop_position)
			self.item_name = ""

	func _equip_item(event: Event) -> void:
		self.item_name = event.parameters.get("item_name")

	func _get_drop_position() -> Vector2:
		var snake_body: Components.SnakeBody = self.game_object.components.get("SnakeBody")
		var tail: GameEngine.GameObject = snake_body.get_tail_game_object()
		return tail.physics_body.global_position


class Movable:
	extends Component
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

		var new_event := Event.new("MovedForward", {"direction": self.direction})
		Event.queue_after_effect(self.game_object, new_event, event)

	func _try_change_direction(event: Event) -> void:
		var new_event := Event.new("ChangeDirection", event.parameters.duplicate(true))
		new_event.parameters["current_direction"] = self.direction
		Event.queue_after_effect(self.game_object, new_event, event)


class Nutritious:
	extends Component

	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._feed_nutrition(event)

		return event

	func _feed_nutrition(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		if eater:
			var new_event := Event.new("Grow", {"amount": 1})
			eater.fire_event(new_event)


class PhysicsBody:
	extends Component
	var physics_body_scene: PackedScene = load(Settings.PHYSICS_OBJECT_PATH)
	var physics_body_node: PhysicsObject

	func _init(p_name: String, p_game_object: GameObject = null) -> void:
		super(p_name, p_game_object)
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
		if event.id == "GetPosition":
			self._give_position(event)

		return event

	func first_time_setup() -> void:
		self.game_object.physics_body = self.physics_body_node
		self.game_object.main_node.add_child(self.physics_body_node)
		self.physics_body_node.game_object = self.game_object

	func _check_eat() -> void:
		if self.physics_body_node.has_overlapping_areas():
			var areas: Array = self.physics_body_node.get_overlapping_areas().duplicate(true)
			var new_event := Event.new("Eat", {"eater": self.game_object})

			for area in areas:
				area.game_object.fire_event(new_event)

	func _get_eaten(event: Event) -> void:
		var kill_self_event := Event.new("KillSelf")
		Event.queue_after_effect(self.game_object, kill_self_event, event)
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		EventBus.ate_item.emit(game_object.name, eater.name)

	func _give_position(event: Event) -> void:
		var asker: GameEngine.GameObject = event.parameters.get("asker")
		var new_event := (
			Event
			. new(
				"GivePosition",
				{
					"position": self.game_object.physics_body.global_position,
				}
			)
		)
		Event.queue_after_effect(asker, new_event, event)

	func _ingest_poison(event: Event):
		if event.parameters["poison_level"] > 0:
			var kill_self_event := Event.new("KillSelf")
			Event.queue_after_effect(self.game_object, kill_self_event, event)

	func _kill_self() -> void:
		self.game_object.delete_self()


class PlayerControlled:
	extends Component
	var last_direction_moved: String = "0"
	var next_direction_queued: String = "0"
	var has_moved: bool = true

	func _init(p_name: String, p_game_object: GameObject = null) -> void:
		super(p_name, p_game_object)
		self.game_object.factory_from.subscribe(p_game_object, "player_controlled")

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

		if event.parameters.get("direction"):
			new_direction = event.parameters.get("direction")

		if not has_moved:
			next_direction_queued = new_direction
			return

		if not _is_opposite_direction(
			self.last_direction_moved,
			new_direction,
		):
			event.parameters["direction"] = new_direction
			has_moved = false
		else:
			event.parameters["direction"] = "0"

	func _end_game() -> void:
		game_object.main_node.end_game_soon()

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
		var die_event := Event.new("Die")
		Event.queue_after_effect(self.game_object, die_event, event)

	func _save_direction(event: Event) -> void:
		last_direction_moved = event.parameters.get("direction")
		has_moved = true
		EventBus.player_moved.emit()

		if next_direction_queued != "0":
			(
				Event
				. queue_after_effect(
					game_object,
					Event.new("ChangeDirection", {"direction": next_direction_queued}),
					event,
				)
			)
			next_direction_queued = "0"


class Poisonous:
	extends Component
	var poison_level: int = 1000

	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._send_poison(event)

		return event

	func _send_poison(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		if eater:
			var new_event := (
				Event
				. new(
					"IngestPoison",
					{"poison_level": poison_level},
				)
			)
			eater.fire_event(new_event)


class PoisonResistance:
	extends Component
	var resist_amount: int = 1

	func fire_event(event: Event) -> Event:
		if event.id == "IngestPoison":
			self._resist_poison(event)

		return event

	func _resist_poison(event: Event) -> void:
		var poison_level: int = event.parameters.get("poison_level")
		poison_level -= resist_amount
		if poison_level < 0:
			poison_level = 0

		event.parameters["poison_level"] = poison_level


class Render:
	extends Component
	var texture: String = ""
	var sprite_node: Sprite2D
	var z_idx: int

	func fire_event(event: Event) -> Event:
		if event.id == "SetPosition":
			_set_position(event)
		if event.id == "SendSprite":
			_overlay_sprite_on_target(event)

		return event

	func first_time_setup() -> void:
		sprite_node = game_object.physics_body.get_node("PhysicsObjectSprite")
		sprite_node.texture = load(texture)
		sprite_node.z_index = z_idx

	func _overlay_sprite_on_target(event: Event) -> void:
		var target: GameEngine.GameObject = event.parameters.get("to")
		var sprite_node_name: String = event.parameters.get("name")
		var offset := Vector2(0, 0)
		if event.parameters.get("offset"):
			offset = event.parameters.get("offset")
		Main.overlay_sprite_on_game_object(texture, target, sprite_node_name, 3, offset)


	func _set_position(event: Event) -> void:
		game_object.physics_body.global_position = (event.parameters.get("position"))
		game_object.physics_body.visible = true


class Royalty:
	extends Component


	func fire_event(event: Event) -> Event:
		if event.id == "CheckCrown":
			_end_game()

		return event


	func _end_game() -> void:
		game_object.main_node.gamemode_node.end_game(true)


class SingleUseItem:
	extends Component
	var components_as_string: String = ""
	var components_to_inherit: PackedStringArray = []

	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			self._bequeath_components(event)
			self._make_eater_equip_item(event)
		if event.id == "ConsumeItem":
			self._relinquish_components()
		if event.id == "UseItem":
			_consume_item(event)

		return event

	func first_time_setup() -> void:
		components_to_inherit = components_as_string.split(",")
		components_to_inherit.append("SingleUseItem")

	func _bequeath_components(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")
		for component_name in self.components_to_inherit:
			var component_parameters: Dictionary = (
				self.game_object.components[component_name].initial_parameters
			)
			eater.add_component(component_name, component_parameters)


	func _consume_item(event: Event) -> void:
		var new_event := GameEngine.Event.new("ConsumeItem")
		Event.queue_after_effect(game_object, new_event, event)


	func _make_eater_equip_item(event: Event) -> void:
		var eater: GameEngine.GameObject = event.parameters.get("eater")

		var new_event := GameEngine.Event.new("DropItem")
		self.game_object.fire_event(new_event)

		new_event = (
			Event
			. new(
				"EquipItem",
				{"item_name": self.game_object.name},
			)
		)
		Event.queue_after_effect(eater, new_event, event)

		new_event = (
			Event
			. new(
				"SendSprite",
				{"to": eater, "name": "EquippedItem"},
			)
		)
		Event.queue_after_effect(self.game_object, new_event, event)

	func _relinquish_components() -> void:
		for component_name in self.components_to_inherit:
			self.game_object.queue_remove_component(component_name)
		Main.remove_overlay_sprite_from_physics_body(self.game_object, "EquippedItem")


class SnakeBody:
	extends Component
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
		new_next_body: GameObject,
		new_prev_body: GameObject,
	) -> void:
		var next_body_snakebody: SnakeBody = new_next_body.components.get("SnakeBody")
		var prev_body_snakebody: SnakeBody = new_prev_body.components.get("SnakeBody")
		if next_body_snakebody and prev_body_snakebody:
			next_body_snakebody.prev_body = new_prev_body
			prev_body_snakebody.next_body = new_next_body

	func get_length_from_here() -> int:
		if not prev_body:
			return 1

		var prev_snake_body: SnakeBody = self.prev_body.components.get("SnakeBody")

		return 1 + prev_snake_body.get_length_from_here()

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
			(
				Event
				. queue_after_effect(
					self.prev_body,
					Event.new("FollowNextBody"),
					event,
				)
			)

	func _grow() -> void:
		var tail: GameEngine.GameObject = get_tail_game_object()
		var spawn_location: Vector2 = tail.physics_body.global_position
		var direction: Vector2 = game_object.physics_body.global_position.direction_to(
			prev_location
		)
		game_object.main_node.spawn_snake_segment(
			game_object,
			spawn_location + direction,
		)


	func _move_forward(event: Event) -> void:
		self.prev_location = self.game_object.physics_body.global_position

		if self.prev_body:
			Event.queue_after_effect(prev_body, Event.new("FollowNextBody"), event)

	func _pass_poison(event: Event) -> void:
		var poison_level: int = event.parameters.get("poison_level")

		# pass poison event to tail
		if self.prev_body:
			Event.dequeue_after_effect(event, "KillSelf")
			var new_event := (
				Event
				. new(
					"IngestPoison",
					{"poison_level": poison_level},
				)
			)
			Event.queue_after_effect(self.prev_body, new_event, event)
			return

		if poison_level > 0 and self.next_body:
			var new_event := (
				Event
				. new(
					"IngestPoison",
					{"poison_level": poison_level - 1},
				)
			)
			Event.queue_after_effect(self.next_body, new_event, event)


class SpeedIncrease:
	extends Component
	var increase_amount: int = 1

	func on_add():
		var new_event := (
			Event
			. new(
				"IncreaseSpeed",
				{"amount": self.increase_amount},
			)
		)
		self.game_object.fire_event(new_event)

	func on_remove():
		var new_event := (
			Event
			. new(
				"DecreaseSpeed",
				{"amount": self.increase_amount},
			)
		)
		self.game_object.fire_event(new_event)


class SpeedDecrease:
	extends Component
	var decrease_amount: int = 1

	func on_add():
		var new_event := (
			Event
			. new(
				"DecreaseSpeed",
				{"amount": self.decrease_amount},
			)
		)
		self.game_object.fire_event(new_event)

	func on_remove():
		var new_event := (
			Event
			. new(
				"IncreaseSpeed",
				{"amount": self.decrease_amount},
			)
		)
		self.game_object.fire_event(new_event)


class SpeedDecreaseAbility:
	extends Component
	var decrease_amount: int = 1
	var ability_duration: float = 1.0
	var cooldown_duration: float = 10.0
	var on_cooldown: bool = false
	var ability_active: bool = false

	func fire_event(event: Event) -> Event:
		if event.id == "UseItem":
			self._decrease_speed(event)
		if event.id == "CooldownStart":
			self._start_cooldown(event)
		if event.id == "CooldownEnd":
			self._end_cooldown()
		if event.id == "DropItem":
			self._remove_effects(event)

		return event

	func _decrease_speed(event: Event) -> void:
		if not self.on_cooldown:
			self.ability_active = true
			var new_event := (
				Event
				. new(
					"DecreaseSpeed",
					{"amount": self.decrease_amount},
				)
			)
			Event.queue_after_effect(self.game_object, new_event, event)
			(
				self
				. game_object
				. main_node
				. cooldown(
					self.ability_duration,
					self.cooldown_duration,
					self.game_object,
				)
			)

	func _end_cooldown() -> void:
		self.on_cooldown = false
		Main.remove_shader_from_physics_body(self.game_object, "EquippedItem")

	func _remove_effects(event: Event) -> void:
		if self.ability_active:
			var new_event := (
				Event
				. new(
					"IncreaseSpeed",
					{"amount": self.decrease_amount},
				)
			)
			Event.queue_after_effect(self.game_object, new_event, event)

	func _start_cooldown(event: Event) -> void:
		self.on_cooldown = true
		self.ability_active = false
		(
			Main
			. apply_shader_to_physics_body(
				self.game_object,
				"EquippedItem",
				"gray_material.tres",
			)
		)

		var new_event := (
			Event
			. new(
				"IncreaseSpeed",
				{"amount": self.decrease_amount},
			)
		)
		Event.queue_after_effect(self.game_object, new_event, event)


class SpeedIncreaseAbility:
	extends Component
	var increase_amount: int = 1
	var ability_duration: float = 1.0
	var cooldown_duration: float = 10.0
	var on_cooldown: bool = false
	var ability_active: bool = false

	func fire_event(event: Event) -> Event:
		if event.id == "UseItem":
			self._increase_speed(event)
		if event.id == "CooldownStart":
			self._start_cooldown(event)
		if event.id == "CooldownEnd":
			self._end_cooldown()
		if event.id == "DropItem":
			self._remove_effects(event)

		return event

	func _end_cooldown() -> void:
		self.on_cooldown = false
		Main.remove_shader_from_physics_body(self.game_object, "EquippedItem")

	func _remove_effects(event: Event) -> void:
		if self.ability_active:
			var new_event := (
				Event
				. new(
					"DecreaseSpeed",
					{"amount": self.increase_amount},
				)
			)
			Event.queue_after_effect(self.game_object, new_event, event)

	func _start_cooldown(event: Event) -> void:
		self.on_cooldown = true
		self.ability_active = false
		(
			Main
			. apply_shader_to_physics_body(
				self.game_object,
				"EquippedItem",
				"gray_material.tres",
			)
		)

		var new_event := (
			Event
			. new(
				"DecreaseSpeed",
				{"amount": self.increase_amount},
			)
		)
		Event.queue_after_effect(self.game_object, new_event, event)

	func _increase_speed(event: Event) -> void:
		if not self.on_cooldown:
			self.ability_active = true
			var new_event := (
				Event
				. new(
					"IncreaseSpeed",
					{"amount": self.increase_amount},
				)
			)
			Event.queue_after_effect(self.game_object, new_event, event)
			(
				self
				. game_object
				. main_node
				. cooldown(
					self.ability_duration,
					self.cooldown_duration,
					self.game_object,
				)
			)


class Stairs:
	extends Component


	func fire_event(event: Event) -> Event:
		if event.id == "Eat":
			_check_for_crown(event)

		return event


	func _check_for_crown(event: Event) -> void:
		Event.dequeue_after_effect(event, "KillSelf")

		var eater: GameEngine.GameObject = event.parameters.get("eater")
		if eater:
			var new_event := Event.new("CheckCrown")
			eater.fire_event(new_event)
