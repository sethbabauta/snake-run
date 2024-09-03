class_name MoveTimerNotifier extends RefCounted

var move_timer: MoveTimer
var game_object_factory: GameEngine.GameObjectFactory

func _init(
	p_move_timer: MoveTimer,
	p_game_object_factory: GameEngine.GameObjectFactory,
) -> void:
	move_timer = p_move_timer
	game_object_factory = p_game_object_factory

	move_timer.speed_1.connect(_on_move_timer_speed_1)
	move_timer.speed_2.connect(_on_move_timer_speed_2)
	move_timer.speed_3.connect(_on_move_timer_speed_3)
	move_timer.speed_4.connect(_on_move_timer_speed_4)
	move_timer.speed_5.connect(_on_move_timer_speed_5)


func _on_move_timer_speed_1() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	game_object_factory.notify_subscribers(new_event, "movable1")


func _on_move_timer_speed_2() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	game_object_factory.notify_subscribers(new_event, "movable2")


func _on_move_timer_speed_3() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	game_object_factory.notify_subscribers(new_event, "movable3")


func _on_move_timer_speed_4() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	game_object_factory.notify_subscribers(new_event, "movable4")


func _on_move_timer_speed_5() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	game_object_factory.notify_subscribers(new_event, "movable5")
