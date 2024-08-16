extends Control

const TEXT_MOVEMENT_SPEED = 3
const TEXT_TYPE_SPEED = 1
const TIME_AFTER_REVEALED = 5.0

@export var monologue_label: Label

var physics_body: Area2D
var end_timer_started: bool = false


func _physics_process(delta: float) -> void:
	if not physics_body:
		return

	_follow_physics_body()


func finish_monologue() -> void:
	monologue_label.visible = false
	physics_body = null
	monologue_label.text = ""
	end_timer_started = false


func start_monologue(monologuer: Area2D, speech: String) -> void:
	physics_body = monologuer
	monologue_label.text = speech
	monologue_label.global_position = physics_body.global_position
	monologue_label.visible_ratio = 0
	monologue_label.visible = true

	_reveal_text()


func _follow_physics_body() -> void:
	var move_direction: Vector2 = monologue_label.global_position.direction_to(
		physics_body.global_position
	)
	monologue_label.global_position += TEXT_MOVEMENT_SPEED * move_direction


func _reveal_text() -> void:
	var max_characters: int = monologue_label.text.length()
	var type_effect: Tween = create_tween()

	type_effect.tween_property(
		monologue_label,
		"visible_characters",
		max_characters,
		2.0,
	).set_trans(Tween.TRANS_SINE)

	await type_effect.finished
	await get_tree().create_timer(TIME_AFTER_REVEALED).timeout

	finish_monologue()
