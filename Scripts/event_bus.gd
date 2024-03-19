extends Node

signal game_paused(is_paused: bool)
signal game_started(gamemode_name: String)
signal settings_toggled
signal powerup_1_activated
signal level_changed
signal player_fully_entered
signal ate_item(item_name: String, eater: String)
