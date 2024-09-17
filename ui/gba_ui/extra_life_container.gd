extends MarginContainer

@export var number_label: Label
@export var container: HBoxContainer

var extra_life_count: int = 0


func _ready() -> void:
	EventBus.extra_life_collected.connect(_on_extra_life_collected)
	EventBus.extra_life_expended.connect(_on_extra_life_expended)
	container.visible = false


func _on_extra_life_collected() -> void:
	extra_life_count += 1
	_update_label()


func _on_extra_life_expended() -> void:
	extra_life_count -= 1
	_update_label()


func _update_label() -> void:
	if extra_life_count <= 0:
		container.visible = false
		return

	container.visible = true
	number_label.text = "+" + str(extra_life_count)
