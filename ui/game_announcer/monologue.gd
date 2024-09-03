extends Control

const TEXT_MOVEMENT_SPEED = 4.0
const TEXT_TYPE_SPEED = 1
const TIME_AFTER_REVEALED = 5.0

@export var monologue_label: Label
@export var text_target_position: TextTargetPosition

var physics_body: Area2D
var end_timer_started: bool = false
var camera: Camera2D
var label_target_position: Vector2


func _ready() -> void:
	camera = get_viewport().get_camera_2d()


func _physics_process(delta: float) -> void:
	if not physics_body:
		return

	_follow_physics_body(delta)


func finish_monologue() -> void:
	monologue_label.visible = false
	physics_body = null
	monologue_label.text = ""
	end_timer_started = false


func start_monologue(monologuer: Area2D, speech: String) -> void:
	physics_body = monologuer
	monologue_label.text = speech
	monologue_label.global_position = (
		physics_body.global_position
		+ physics_body.get_canvas_transform().origin
	)
	monologue_label.visible_ratio = 0
	monologue_label.visible = true

	text_target_position.setup(monologue_label, physics_body, camera)

	_reveal_text()


func _follow_physics_body(delta: float) -> void:
	label_target_position = text_target_position.get_target_position()

	monologue_label.global_position = monologue_label.global_position.lerp(
		label_target_position, delta * TEXT_MOVEMENT_SPEED
	)


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
