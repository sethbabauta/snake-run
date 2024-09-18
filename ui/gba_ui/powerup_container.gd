extends MarginContainer

@export var container: HBoxContainer
@export var number_label: Label


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	container.visible = false


func update_label(sec_remaining: int) -> void:
	number_label.text = str(sec_remaining)


func _on_game_started(gamemode_name: String) -> void:
	if gamemode_name == "Snakeo" or gamemode_name == "Dungeon":
		container.visible = true
