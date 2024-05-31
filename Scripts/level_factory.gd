class_name LevelFactory extends Resource

var tiles: Array = [
	BlueprintToLevel.new("Barrier", Vector2i(0, 0)),
	BlueprintToLevel.new("Apple", Vector2i(1, 0)),
	BlueprintToLevel.new("SlightlyPoisonousApple", Vector2i(2, 0)),
	BlueprintToLevel.new("CrownItem", Vector2i(3, 0)),
	BlueprintToLevel.new("ExtraLifeItem", Vector2i(0, 1)),
	BlueprintToLevel.new("SingleUseAppleFlipper", Vector2i(1, 1)),
	BlueprintToLevel.new("PoisonResistanceItem", Vector2i(2, 1)),
]
var main_node: Main


func _init(p_main_node: Main) -> void:
	self.main_node = p_main_node


func setup_level(
	tile_map: TileMap,
	spawn_offset_coordinates_simple: Vector2,
) -> void:
	main_node.spawn_background(spawn_offset_coordinates_simple)
	for tile in self.tiles:
		tile.tile_coordinates = tile_map.get_used_cells_by_id(0, 1, tile.atlas_coordinates)
		spawn_tiles(tile, spawn_offset_coordinates_simple)



func spawn_tiles(
	tile: BlueprintToLevel,
	spawn_offset_coordinates: Vector2,
) -> void:
	for coordinate in tile.tile_coordinates:
		var simple_position: Vector2 = spawn_offset_coordinates + Vector2(coordinate)
		var spawn_position: Vector2 = Utils.convert_simple_to_world_coordinates(simple_position)
		self.main_node.spawn_and_place_object(tile.blueprint_name, spawn_position)


class BlueprintToLevel:
	var blueprint_name: String
	var atlas_coordinates: Vector2i
	var tile_coordinates: Array

	func _init(p_blueprint_name: String, p_atlas_coordinates: Vector2i) -> void:
		self.blueprint_name = p_blueprint_name
		self.atlas_coordinates = p_atlas_coordinates
