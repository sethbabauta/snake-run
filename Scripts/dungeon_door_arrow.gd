class_name DungeonArrow extends Control

@onready var middle_c: AudioStreamPlayer = %MiddleC
@onready var e_note: AudioStreamPlayer = %ENote
@onready var g_note: AudioStreamPlayer = %GNote
@onready var high_c: AudioStreamPlayer = %HighC


func play_middle_c() -> void:
	middle_c.play()


func play_e_note() -> void:
	e_note.play()


func play_g_note() -> void:
	g_note.play()


func play_high_c() -> void:
	high_c.play()
