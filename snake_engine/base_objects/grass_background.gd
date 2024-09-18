extends Sprite2D


func _ready() -> void:
	self.texture = load(Settings.GRASS_BACKGROUND_PATHS.pick_random())
