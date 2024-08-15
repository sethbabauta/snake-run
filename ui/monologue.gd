extends Control

signal fully_revealed

const TEXT_MOVEMENT_SPEED = 100
const TEXT_TYPE_SPEED = 1
const TIME_AFTER_REVEALED = 3.0

@export var monologue_label: Label

var physics_body: Area2D
var end_timer_started: bool = false


func _init() -> void:
	fully_revealed.connect(_on_fully_revealed)


func _physics_process(delta: float) -> void:
	if not physics_body:
		return

	_follow_physics_body()
	_reveal_text()


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


func _follow_physics_body() -> void:
	var move_direction: Vector2 = monologue_label.global_position.direction_to(
		physics_body.global_position
	)
	monologue_label.global_position += TEXT_MOVEMENT_SPEED * move_direction


func _on_fully_revealed() -> void:
	await get_tree().create_timer(TIME_AFTER_REVEALED)
	finish_monologue()


func _reveal_text() -> void:
	if monologue_label.visible_ratio == 1 and not end_timer_started:
		fully_revealed.emit()
		end_timer_started = true
		return

	if monologue_label.visible_ratio == 1:
		return

	monologue_label.visible_ratio += TEXT_TYPE_SPEED
