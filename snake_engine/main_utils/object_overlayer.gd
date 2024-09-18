class_name ObjectOverlayer extends RefCounted


static func apply_shader_to_physics_body(
	target: GameEngine.GameObject,
	sprite_node_name: String,
	material_name: String,
) -> void:
	var shader_material_path: String = Settings.SHADERS_PATH + material_name
	var shader_material: Material = load(shader_material_path)
	var sprite_node: Sprite2D = target.physics_body.get_node(sprite_node_name)
	sprite_node.material = shader_material


static func apply_shader_to_snake(
	target_head: GameEngine.GameObject,
	material_name: String,
) -> void:
	ObjectOverlayer.apply_shader_to_physics_body(
		target_head,
		"EquippedItem",
		material_name,
	)

	var current_snakebody: Components.SnakeBody = target_head.components.get(
		"SnakeBody"
	)
	while current_snakebody != null:
		(
			ObjectOverlayer
			. apply_shader_to_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
				material_name,
			)
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


static func overlay_sprite_on_game_object(
	sprite_path: String,
	target: GameEngine.GameObject,
	sprite_node_name: String,
	z_idx: int = 1,
	offset := Vector2(0, 0)
) -> void:
	var new_sprite := Sprite2D.new()
	new_sprite.texture = load(sprite_path)
	new_sprite.z_index = z_idx
	new_sprite.name = sprite_node_name
	target.physics_body.equipped_items.add_child(new_sprite)
	new_sprite.position += offset


static func remove_overlay_sprite_from_physics_body(
	target: GameEngine.GameObject,
	sprite_node_name: String,
) -> void:
	var equipped_items: Array[Node] = target.physics_body.equipped_items.get_children()
	for item in equipped_items:
		if item.name != sprite_node_name:
			continue

		target.physics_body.equipped_items.remove_child(item)
		item.queue_free()


static func remove_shader_from_physics_body(
	target: GameEngine.GameObject,
	sprite_node_name: String,
) -> void:
	var sprite_node: Sprite2D = target.physics_body.get_node_or_null(sprite_node_name)
	if sprite_node:
		sprite_node.material = null


static func remove_shader_from_snake(
	target_head: GameEngine.GameObject,
) -> void:
	ObjectOverlayer.remove_shader_from_physics_body(target_head, "EquippedItem")

	var current_snakebody: Components.SnakeBody = target_head.components.get(
		"SnakeBody",
	)

	while current_snakebody != null:
		(
			ObjectOverlayer
			. remove_shader_from_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
			)
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")
