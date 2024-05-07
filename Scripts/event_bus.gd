extends Node

signal ate_item(item_name: String, eater: String)
signal crown_collected
signal game_paused(is_paused: bool)
signal game_started(gamemode_name: String)
signal level_changed(direction: String)
signal player_fully_entered
signal powerup_1_activated
signal settings_toggled
