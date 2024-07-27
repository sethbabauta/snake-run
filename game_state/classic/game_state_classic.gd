extends GameState

var classic_state_machine:= StateMachine.new()

func _init() -> void:
	EventBus.game_ended.connect(_on_game_ended)


func enter() -> void:
	_change_scene(Settings.CLASSIC_SCENE)


func _on_game_ended(won: bool) -> void:
	if not won:
		_change_scene(Settings.CLASSIC_DEATH_SCREEN)
