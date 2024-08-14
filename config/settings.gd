extends Node

const BASE_MOVE_SPEED = 32

# general paths
const BLUEPRINTS_PATH = "res://config/object_blueprints.txt"
const SPRITES_PATH = "res://sprites/"
const SHADERS_PATH = "res://shaders/"
const LEVELS_PATH = "res://levels/legacy_levels/"
const PHYSICS_OBJECT_PATH = "res://scenes/physics_object.tscn"

const GRASS_BACKGROUND_SCENE_PATH = "res://scenes/grass_background.tscn"
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
const CLASSIC_DEATH_SCREEN = "res://game_state/classic/classic_death_screen.tscn"

const SNAKEO_SCENE = "res://game_state/snakeo/snakeo.tscn"
const SNAKEO_DEATH_SCREEN = "res://game_state/snakeo/snakeo_death_screen.tscn"

const DUNGEON_SCENE = "res://game_state/dungeon/dungeon.tscn"
const DUNGEON_DEATH_SCREEN = "res://game_state/dungeon/dungeon_death_screen.tscn"
const DUNGEON_WIN_SCREEN = "res://game_state/dungeon/dungeon_win_screen.tscn"
