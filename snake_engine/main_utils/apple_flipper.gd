class_name AppleFlipper extends RefCounted

var main_node: Main


func _init(p_main_node: Main) -> void:
	main_node = p_main_node


func delete_and_replace(
	object_to_delete: GameEngine.GameObject,
	name_of_replacement: String,
) -> void:
	var object_position: Vector2 = object_to_delete.physics_body.global_position
	object_to_delete.delete_self()
	var new_object := (
		main_node
		.game_object_factory
		.create_object(name_of_replacement, main_node)
	)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": object_position})
	new_object.fire_event(set_position_event)


func flip_apples(nutritious: bool = false) -> void:
	flip_objects("Apple", "SlightlyPoisonousAppleNoRespawn")

	var flip_to: String = "AppleNoRespawn"
	if nutritious:
		flip_to = "NutritiousAppleNoRespawn"

	flip_objects("SlightlyPoisonousApple", flip_to)
	flip_objects("DungeonApple", flip_to)


func flip_apples_back(nutritious: bool = false) -> void:
	var flip_to: String = "AppleNoRespawn"
	if nutritious:
		flip_to = "NutritiousAppleNoRespawn"
	flip_objects(flip_to, "SlightlyPoisonousApple")

	var slightly_poisonous_apples: Array[GameEngine.GameObject] = (
		await main_node.get_game_objects_of_name(
			"SlightlyPoisonousAppleNoRespawn"
		)
	)
	if not slightly_poisonous_apples:
		main_node.queue_object_to_spawn("Apple")
		return

	flip_objects("SlightlyPoisonousAppleNoRespawn", "Apple")


func flip_objects(target_name: String, flip_to: String) -> void:
	var target_objects: Array[GameEngine.GameObject] = (
		await main_node.get_game_objects_of_name(target_name)
	)
	for target_object in target_objects:
		delete_and_replace(target_object, flip_to)
