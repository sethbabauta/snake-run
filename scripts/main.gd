extends Node


func _ready():
	generate_nodes()


func generate_nodes() -> void:
	var game_object_factory:= GameEngine.GameObjectFactory.new()
	var physical_object: GameEngine.GameObject = game_object_factory.create_object("PhysicalObject")
	print("texture: ", physical_object.components.Render.texture, " params: ", physical_object.components.Render.params)
	var physical_object_sprite_node:= Sprite2D.new()
	physical_object_sprite_node.position = Vector2(600, 300)
	var physical_object_render_component: Components.Render = physical_object.components.get("Render")

	if physical_object_render_component:
		physical_object_sprite_node.texture = load(physical_object_render_component.texture)

	add_child(physical_object_sprite_node)
