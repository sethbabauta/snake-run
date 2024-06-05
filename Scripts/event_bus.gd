extends Node

signal announcement_completed
signal ate_item(item_name: String, eater: String)
signal crown_collected
signal game_paused(is_paused: bool)
signal game_started(gamemode_name: String)
signal level_changed(direction: String)
signal player_fully_entered
signal player_moved
signal player_respawned
signal powerup_1_activated
signal scripted_event_completed
signal settings_toggled
signal shake_completed
