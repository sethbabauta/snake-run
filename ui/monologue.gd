extends Control

enum Side {LEFT, RIGHT}

const TEXT_MOVEMENT_SPEED = 4.0
const TEXT_TYPE_SPEED = 1
const TIME_AFTER_REVEALED = 25.0
const FLIP_MARGIN = 20.0
const LABEL_OFFSET = 32.0

@export var monologue_label: Label

var physics_body: Area2D
var end_timer_started: bool = false
var camera: Camera2D
var current_side = Side.RIGHT
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
	monologue_label.global_position = physics_body.global_position
	monologue_label.visible_ratio = 0
	monologue_label.visible = true

	_reveal_text()


func _check_for_flip() -> void:
	var viewport_horizontal_size: float = float(get_viewport().size.x)
	var label_edge: float

	if current_side == Side.RIGHT:
		label_edge = _get_label_right_edge()
	elif current_side == Side.LEFT:
		label_edge = _get_label_left_edge()

	if _get_is_label_past_margin(label_edge, viewport_horizontal_size):
		_flip_label_side()


func _flip_label_side() -> void:
	if current_side == Side.RIGHT:
		print("flipping to the left")
		current_side = Side.LEFT
	elif current_side == Side.LEFT:
		print("flipping to the right")
		current_side = Side.RIGHT


func _follow_physics_body(delta: float) -> void:
	_check_for_flip()
	label_target_position = _get_target_position()

	monologue_label.global_position = monologue_label.global_position.lerp(
		label_target_position, delta * TEXT_MOVEMENT_SPEED
	)


func _get_is_label_past_margin(
	label_edge: float,
	viewport_horizontal_size: float,
) -> bool:

	var center_x: float = (
		get_viewport().get_camera_2d().get_screen_center_position().x
	)
	if current_side == Side.RIGHT:
		var right_margin_x: float = (
			center_x
			- (viewport_horizontal_size / 2)
			+ FLIP_MARGIN
		)

		return label_edge < right_margin_x

	elif current_side == Side.LEFT:
		var left_margin_x: float = (
			center_x
			+ (viewport_horizontal_size / 2)
			- FLIP_MARGIN
		)

		return label_edge > left_margin_x


	# if somehow current side is broken just return false
	return false


func _get_label_left_edge() -> float:
	var label_left_edge: float = (
		physics_body.global_position.x
		- LABEL_OFFSET
		- monologue_label.size.x
	)
	return label_left_edge


func _get_label_right_edge() -> float:
	var label_right_edge: float = (
		physics_body.global_position.x
		+ LABEL_OFFSET
		+ monologue_label.size.x
	)
	return label_right_edge


func _get_target_position() -> Vector2:
	var target_position: Vector2 = physics_body.global_position

	if current_side == Side.RIGHT:
		target_position += Vector2(LABEL_OFFSET, 0)
	elif current_side == Side.LEFT:
		target_position -= (
			Vector2(LABEL_OFFSET, 0)
			- Vector2(monologue_label.size.x, 0)
		)

	return target_position


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
