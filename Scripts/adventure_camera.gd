extends Camera2D

@export var main_node: Main
@export var gamemode_node: Node
var player_head: GameEngine.GameObject

func _ready() -> void:
	gamemode_node.GAME_START.connect(_on_game_start)


func _on_game_start() -> void:
	player_head = main_node.get_closest_player_controlled(Vector2(0, 0))


func _on_timer_timeout() -> void:
	self.global_position = player_head.physics_body.global_position
