extends MarginContainer

@export var container: VBoxContainer


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	container.visible = false


func _on_game_started(gamemode_name: String) -> void:
	if gamemode_name == "Dungeon":
		container.visible = true
