extends Control

const LABEL_OFFSET = Vector2(16.0, 0.0)
const BOUNCE_HEIGHT = 16

@export var text_target_position: TextTargetPosition

var camera: Camera2D


func _ready() -> void:
	camera = get_viewport().get_camera_2d()


func display_number(
	value: String,
	affected_body: Area2D,
	is_damage: bool = false,
) -> void:

	var number_label: Label = _create_label(value, is_damage)

	call_deferred("add_child", number_label)

	await number_label.resized

	text_target_position.setup(number_label, affected_body, camera)
	number_label.global_position = text_target_position.get_target_position()
	number_label.pivot_offset = Vector2(number_label.size / 2)

	await _animate_number(number_label)
	number_label.queue_free()


func _animate_number(number_label: Label) -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number_label, "position:y", number_label.position.y - BOUNCE_HEIGHT, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number_label, "position:y", number_label.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number_label, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished


func _create_label(
	value: String,
	is_damage: bool = false,
) -> Label:

	var number_label:= Label.new()

	number_label.text = value
	number_label.z_index = 5
	number_label.label_settings = LabelSettings.new()

	var text_color: String = "#FFF"
	if is_damage:
		text_color = "#B22"

	number_label.label_settings.font_color = text_color
	number_label.label_settings.font_size = 16
	number_label.label_settings.outline_color = "#000"
	number_label.label_settings.outline_size = 1

	return number_label
