extends Node


const BASE_MOVE_SPEED = 32.0

# general paths
const SETTINGS_FILE_PATH = "user://settings.ini"
const BLUEPRINTS_PATH = "res://data/object_blueprints.txt"
const DEATH_MESSAGES_PATH = "res://data/death_messages.txt"
const LEVEL_CLEARED_MESSAGES_PATH = "res://data/level_cleared_messages.txt"
const SPRITES_PATH = "res://sprites/"
const SHADERS_PATH = "res://shaders/"
const PHYSICS_OBJECT_PATH = "res://snake_engine/base_objects/physics_object.tscn"

const GRASS_BACKGROUND_SCENE_PATH = (
	"res://snake_engine/base_objects/grass_background.tscn"
)
const GRASS_BACKGROUND_PATHS = [
	"res://sprites/grass_background1.png",
	"res://sprites/grass_background2.png",
	"res://sprites/grass_background3.png",
	"res://sprites/grass_background4.png",
]

# game state paths
const LOGO_SCENE = "res://game_state/logo/logo.tscn"

const MENU_SCENE = "res://game_state/menu/menu.tscn"

const CLASSIC_SCENE = "res://game_state/classic/classic.tscn"

const SNAKEO_SCENE = "res://game_state/snakeo/snakeo.tscn"

const DUNGEON_SCENE = "res://game_state/dungeon/dungeon.tscn"
const DUNGEON_WIN_SCREEN = "res://game_state/dungeon/dungeon_win_screen.tscn"

const DEATH_SCREEN = "res://ui/death_screens/death_screen.tscn"


# settings options
func get_screen_mode_options() -> Array[String]:
	var screen_mode_options: Array[String] = [
		"fullscreen",
		"borderless_fullscreen",
		"windowed",
	]

	return screen_mode_options

func get_resolution_options() -> Array[Resolution]:
	var resolutions: Array[Resolution] = [
		Resolution.new(480, 270, "16:9"),
		Resolution.new(640, 480, "4:3"),
		Resolution.new(720, 480, "3:2"),
		Resolution.new(720, 576, "5:4"),
		Resolution.new(800, 600, "4:3"),
		Resolution.new(960, 540, "16:9"),
		Resolution.new(1024, 768, "4:3"),
		Resolution.new(1152, 864, "4:3"),
		Resolution.new(1280, 720, "16:9"),
		Resolution.new(1280, 768, "5:3"),
		Resolution.new(1280, 800, "8:5"),
		Resolution.new(1280, 960, "4:3"),
		Resolution.new(1280, 1024, "5:4"),
		Resolution.new(1440, 810, "16:9"),
		Resolution.new(1440, 900, "8:5"),
		Resolution.new(1440, 1080, "4:3"),
		Resolution.new(1600, 900, "16:9"),
		Resolution.new(1680, 1050, "8:5"),
		Resolution.new(1920, 1080, "16:9"),
	]

	return resolutions
