class_name TextTargetPosition extends Node

enum Side {LEFT, RIGHT}

@export var flip_margin = 20.0
@export var label_offset = 32.0

var current_side = Side.RIGHT
var label_target_position: Vector2
var label: Label
var physics_body: Area2D
var camera: Camera2D


func setup(p_label: Label, p_physics_body: Area2D, p_camera: Camera2D) -> void:
	label = p_label
	physics_body = p_physics_body
	camera = p_camera


func _check_for_flip() -> void:
	var viewport_horizontal_size:= float(get_viewport().get_visible_rect().size.x)
	var label_edge: float

	if current_side == Side.RIGHT:
		label_edge = _get_label_right_edge()
	elif current_side == Side.LEFT:
		label_edge = _get_label_left_edge()

	if _get_is_label_past_margin(label_edge, viewport_horizontal_size):
		_flip_side()


func _flip_side() -> void:
	if current_side == Side.RIGHT:
		current_side = Side.LEFT
	elif current_side == Side.LEFT:
		current_side = Side.RIGHT


func _get_is_label_past_margin(
	label_edge: float,
	viewport_horizontal_size: float,
) -> bool:

	var center_x: float = camera.get_screen_center_position().x
	var is_label_past_margin: bool
	if current_side == Side.RIGHT:
		var right_margin_x: float = (
			center_x
			+ (viewport_horizontal_size / 2)
			- flip_margin
		)

		is_label_past_margin = label_edge > right_margin_x

	elif current_side == Side.LEFT:
		var left_margin_x: float = (
			center_x
			- (viewport_horizontal_size / 2)
			+ flip_margin
		)

		is_label_past_margin = label_edge < left_margin_x

	return is_label_past_margin


func _get_label_left_edge() -> float:
	var label_left_edge: float = (
		physics_body.global_position.x
		- label_offset
		- label.size.x
	)
	return label_left_edge


func _get_label_right_edge() -> float:
	var label_right_edge: float = (
		physics_body.global_position.x
		+ label_offset
		+ label.size.x
	)

	return label_right_edge


func get_target_position() -> Vector2:
	_check_for_flip()
	var target_position: Vector2 = physics_body.global_position

	if current_side == Side.RIGHT:
		target_position += Vector2(label_offset, 0)
	elif current_side == Side.LEFT:
		target_position -= (
			Vector2(label.size.x, 0)
		)

	return target_position
