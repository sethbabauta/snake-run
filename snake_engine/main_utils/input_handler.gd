class_name InputHandler extends RefCounted

var game_object_factory: GameEngine.GameObjectFactory


func _init(p_game_object_factory: GameEngine.GameObjectFactory) -> void:
	game_object_factory = p_game_object_factory


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("turn_up"):
		_fire_change_direction_event("turn_up")

	if event.is_action_pressed("turn_left"):
		_fire_change_direction_event("turn_left")

	if event.is_action_pressed("turn_down"):
		_fire_change_direction_event("turn_down")

	if event.is_action_pressed("turn_right"):
		_fire_change_direction_event("turn_right")

	if event.is_action_pressed("drop_item"):
		_fire_drop_item_event()

	if event.is_action_pressed("use_item"):
		_fire_use_item_event()

	if event.is_action_pressed("pause"):
		EventBus.pause_requested.emit()


func _fire_change_direction_event(input_name: String) -> void:
	var new_event := GameEngine.Event.new("TryChangeDirection", {"input": input_name})
	game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_drop_item_event() -> void:
	var new_event := GameEngine.Event.new("DropItem")
	new_event.parameters["from"] = "player_command"
	game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_use_item_event() -> void:
	var new_event := GameEngine.Event.new("UseItem")
	game_object_factory.notify_subscribers(new_event, "player_controlled")
