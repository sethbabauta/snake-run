class_name Dungeon extends Node

const START_LENGTH = 3

@export var game_ui: GBAUI

var current_room: Room
var crown_poison_counter: CrownPoisonCounter
var crown_collected: bool = false
var crown_collected_count: int = 0
var room_manager: RoomManager

@onready var follow_camera: FollowCamera = %FollowCamera
@onready var main_node: Main = %Main
@onready var room_mapper: RoomMapper = %room_mapper
@onready var game_announcer: GameAnnouncer = %GameAnnouncer



func _ready() -> void:
	room_manager = RoomManager.new(self)
	_connect_signals()


func clear_pickups() -> void:
	var pickups_cleared: int = 0
	var clear_pickup_tries: int = 0
	while pickups_cleared == 0 and clear_pickup_tries < 10:
		pickups_cleared += await main_node.clear_pickups()
		clear_pickup_tries += 1


func get_current_room_exclusions() -> Array[String]:
	var exclusions: Array[String] = (
		room_manager.get_current_room_exclusions()
	)

	return exclusions


func level_change_pause(_args: Dictionary) -> void:
	main_node.toggle_timer_freeze()
	game_announcer.announce_message("3 2 1 GO")
	await EventBus.announcement_completed
	EventBus.scripted_event_completed.emit()
	main_node.toggle_timer_freeze()


func load_room(room: Room) -> void:
	room_manager.load_room(room)


func set_current_room_to_start() -> void:
	room_manager.set_current_room_to_start()


func spawn_doors_and_apple() -> void:
	var exclusions: Array[String] = get_current_room_exclusions()
	main_node.spawn_doors(exclusions)
	await get_tree().create_timer(1).timeout
	main_node.queue_object_to_spawn("Apple")


func update_rooms(direction: String) -> void:
	room_manager.update_rooms(direction)

	if direction != "Start":
		main_node.play_scripted_event(level_change_pause)


func _connect_signals() -> void:
	EventBus.crown_collected.connect(_on_crown_pickup)
	EventBus.crown_dropped.connect(_on_crown_dropped)
	EventBus.player_fully_entered.connect(_on_player_fully_entered)
	EventBus.player_moved.connect(_on_player_moved)
	EventBus.player_respawned.connect(_on_player_respawned)
	ScoreKeeper.score_changed.connect(_on_score_changed)


func _crown_scripted_event(_args: Dictionary) -> void:
	main_node.toggle_timer_freeze()
	main_node.audio_library.play_sound("earthquake")
	follow_camera.shake_with_noise()
	await EventBus.shake_completed
	game_announcer.announce_message("ESCAPE WITH YOUR LIFE")
	await EventBus.announcement_completed
	main_node.toggle_timer_freeze()
	EventBus.scripted_event_completed.emit()


func _on_crown_dropped() -> void:
	crown_collected = false


func _on_crown_pickup() -> void:
	crown_collected = true
	crown_collected_count += 1
	if crown_collected_count == 1:
		main_node.play_scripted_event(_crown_scripted_event)


func _on_first_crown_poison(times_poisoned: int) -> void:
	if times_poisoned != 1:
		return

	var snake_go: GameEngine.GameObject = (
		main_node.get_closest_player_controlled(Vector2.ZERO)
	)

	if not is_instance_valid(snake_go):
		return

	game_announcer.start_monologue(
		snake_go.physics_body,
		"is this thing hurting me?? (drop crown with shift)",
	)


func _on_player_moved() -> void:
	if crown_collected:
		var times_poisoned: int = crown_poison_counter.increment_counter()
		_on_first_crown_poison(times_poisoned)


func _on_score_changed(_new_score: int, changed_by: int) -> void:
	current_room.current_room_score += changed_by
	if current_room.get_is_room_complete():
		EventBus.level_completed.emit()


func _on_player_fully_entered() -> void:
	if not current_room:
		return

	if not current_room.get_is_room_complete():
		await EventBus.player_moved
		var exclusions: Array[String] = get_current_room_exclusions()
		main_node.spawn_doors(exclusions)

		# workaround for edge case where player clears lvl then fully enters
		await get_tree().create_timer(5).timeout
		if current_room.get_is_room_complete():
			main_node.clear_doors(exclusions)


func _on_player_respawned() -> void:
	set_current_room_to_start()
	game_announcer.announce_message("DON'T DIE THIS TIME")
	await EventBus.announcement_completed
	game_announcer.announce_message("3 2 1 GO", 1.05)
	await EventBus.announcement_completed
	main_node.toggle_timer_freeze()
