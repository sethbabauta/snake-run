class_name ItemPickupObserver extends RefCounted

var poison_turn_counter: PoisonTurnCounter
var score_turn_counter: ScoreTurnCounter
var extra_life_turn_counter: ExtraLifeTurnCounter
var apple_flipper_turn_counter: AppleFlipperTurnCounter
var poison_resistance_turn_counter: PoisonResistanceTurnCounter
var main_node: Main


func _init(p_main_node: Main, move_timer: MoveTimer) -> void:
	main_node = p_main_node
	poison_turn_counter = PoisonTurnCounter.new(move_timer.speed_3)
	score_turn_counter = ScoreTurnCounter.new(move_timer.speed_3)
	extra_life_turn_counter = ExtraLifeTurnCounter.new(move_timer.speed_3)
	apple_flipper_turn_counter = AppleFlipperTurnCounter.new(move_timer.speed_3)
	poison_resistance_turn_counter = PoisonResistanceTurnCounter.new(
		move_timer.speed_3
	)

	_connect_signals()


func _connect_signals() -> void:
	ScoreKeeper.score_changed.connect(_on_score_changed)
	EventBus.ate_poison.connect(_on_ate_poison)
	EventBus.ate_item.connect(_on_ate_item)


func _on_ate_item(item_name: String, _eater: String) -> void:
	if not main_node.is_game_started:
		return

	var extra_hang_time: float = 0.5
	var snake_go: GameEngine.GameObject = (
		main_node.get_closest_player_controlled(Vector2.ZERO)
	)

	if not is_instance_valid(snake_go):
		return

	if item_name == "ExtraLifeItem":
		extra_life_turn_counter.try_notify(
			snake_go,
			1,
			main_node.gamemode_node.game_announcer,
			false,
			extra_hang_time,
		)
	elif item_name == "SingleUseAppleFlipperItem":
		apple_flipper_turn_counter.try_notify(
			snake_go,
			0,
			main_node.gamemode_node.game_announcer,
			false,
			extra_hang_time + 0.5,
		)
	elif item_name == "PoisonResistanceItem":
		poison_resistance_turn_counter.try_notify(
			snake_go,
			0,
			main_node.gamemode_node.game_announcer,
			false,
			extra_hang_time,
		)


func _on_ate_poison(poison_amount: int) -> void:
	if not main_node.is_game_started:
		return

	var snake_go: GameEngine.GameObject = (
		main_node.get_closest_player_controlled(Vector2.ZERO)
	)

	if not is_instance_valid(snake_go):
		return

	poison_turn_counter.try_notify(
		snake_go,
		poison_amount,
		main_node.gamemode_node.game_announcer,
	)


func _on_score_changed(_new_score: int, changed_by: int) -> void:
	if not main_node.is_game_started:
		return

	var snake_go: GameEngine.GameObject = (
		main_node.get_closest_player_controlled(Vector2.ZERO)
	)

	if not is_instance_valid(snake_go):
		return

	score_turn_counter.try_notify(
		snake_go,
		changed_by,
		main_node.gamemode_node.game_announcer,
	)
