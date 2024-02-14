class_name Demo extends Node

signal GAME_START

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main
@export var demo_label: Label
@export var move_timer: MoveTimer

const START_LENGTH = 5
const APPLE_AMOUNT = 3

var poison_apples: Array = []
var player: GameEngine.GameObject


func _ready():
	self.main_node._spawn_background()

	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, self.START_LENGTH)

	await get_tree().create_timer(0.1).timeout

	for idx in range(APPLE_AMOUNT):
		self.poison_apples.append(main_node.spawn_and_place_object("PoisonApple"))

	self.update_label()
	self.player = main_node.get_closest_player_controlled(self.poison_apples[0].physics_body.global_position)
	self.GAME_START.emit()


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func update_label() -> void:
	if self.poison_apples.size() == 0:
		return

	if str(self.poison_apples[0].physics_body) != "<Freed Object>":
		var display_components: String = "poison apple components: "
		for component_name in self.poison_apples[0].components:
			display_components += (component_name + ", ")

		demo_label.text = display_components


func _on_button_pressed():
	for apple in self.poison_apples:
		if str(apple.physics_body) != "<Freed Object>":
			apple.add_component("Movable", { "speed": "1", "direction": "N", "priority": "99" })
			apple.add_component("AIControlledSimple", { "priority": "101" })


func _on_move_timer_timeout() -> void:
	self.update_label()


func _on_button_2_pressed() -> void:
	var new_event:= GameEngine.Event.new("ChangeSpeed", {"speed": 5})
	self.player.fire_event(new_event)


func _on_button_3_pressed() -> void:
	var new_event:= GameEngine.Event.new("ChangeSpeed", {"speed": 1})
	self.player.fire_event(new_event)
