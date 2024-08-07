extends DungeonState


func _init() -> void:
	EventBus.level_completed.connect(_on_level_completed)


func _on_level_completed() -> void:
	is_complete = true
