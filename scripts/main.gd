extends Node

func _ready():
	generate_nodes()

func generate_nodes() -> void:
	var game_object_factory = GameEngine.GameObjectFactory.new()
	var physical_object = game_object_factory.create_object("PhysicalObject")
	print(physical_object.components.Physics)
	var physical_object_sprite_node = Sprite2D.new()
	var physical_object_render_component = physical_object.components.get("Render")

	if physical_object_render_component:
		physical_object_sprite_node.texture = physical_object_render_component.texture

	add_child(physical_object_sprite_node)
