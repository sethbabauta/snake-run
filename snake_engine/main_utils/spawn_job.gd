class_name SpawnJob extends RefCounted

var object_to_spawn: GameEngine.GameObject
var preferred_position: Vector2
var force_preferred_position: bool
var retries: int = 0

const MAX_RETRIES = 3

func _init(
	p_object_to_spawn: GameEngine.GameObject,
	p_preferred_position: Vector2,
	p_force_preferred_position: bool = false,
) -> void:
	object_to_spawn = p_object_to_spawn
	preferred_position = p_preferred_position
	force_preferred_position = p_force_preferred_position


func can_retry() -> bool:
	return retries < MAX_RETRIES


func try_requeue_job(spawn_queue: Array[SpawnJob]) -> void:
	if not can_retry():
		var warning: String = (
			"Attempted to requeue job with max retries."
		)
		push_warning(warning)
		return

	spawn_queue.append(self)
	retries += 1
