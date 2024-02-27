extends Node2D

var physics_body: PhysicsObject
var main_node: Main

func _ready() -> void:
	self.physics_body = $PhysicsObject
	self.main_node = get_node_or_null("../Main")
