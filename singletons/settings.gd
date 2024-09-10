extends Node

const BASE_MOVE_SPEED = 32.0

# general paths
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
