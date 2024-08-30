extends Node

signal announcement_completed
signal ate_item(item_name: String, eater: String)
signal ate_poison(poison_amount: int)
signal crown_collected
signal crown_dropped
signal game_ended(won: bool)
signal game_paused(is_paused: bool)
signal game_started(gamemode_name: String)
signal level_completed
signal level_changed(direction: String)
signal pause_requested
signal player_died
signal player_fully_entered
signal player_moved
signal player_respawned
signal powerup_1_activated
signal scripted_event_completed
signal settings_toggled
signal shake_completed
