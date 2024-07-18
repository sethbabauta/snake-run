class_name AudioLibrary extends Node2D


func play_sound(sound_name: String) -> void:
	var sound: AudioStreamPlayer = get_node_or_null(sound_name)
	if not sound:
		push_warning("No sound found by the name " + sound_name)

	sound.play()
