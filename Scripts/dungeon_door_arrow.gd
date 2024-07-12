class_name DungeonArrow extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var texture_rect: TextureRect = %TextureRect
@onready var beep: AudioStreamPlayer = %Beep


func _ready() -> void:
	texture_rect.visible = false


func play_arrow_animation() -> void:
	animation_player.play("dungeon_door_arrow")


func play_beep() -> void:
	beep.play()
