extends Node2D

signal collision(collider, position)

onready var raycast1 := $RayCast2D
onready var raycast2 := $RayCast2D2
onready var area := $Area2D
onready var collision := $Area2D/CollisionShape2D
onready var collision_radius : float = collision.shape.radius

var enabled := false setget set_enabled
var collide_with_player := false setget set_collide_with_player
var player_hurtbox


func set_enabled(value: bool) -> void:
	enabled = value
	collision.set_deferred("disabled", not value)


func set_collide_with_player(value: bool) -> void:
	collide_with_player = value
	if value:
		raycast1.remove_exception(player_hurtbox)
		raycast2.remove_exception(player_hurtbox)
	else:
		raycast1.add_exception(player_hurtbox)
		raycast2.add_exception(player_hurtbox)


func move(g_position: Vector2) -> bool:
	var is_colliding := false
	global_position = area.global_position
	var move_direction := g_position - global_position
	if enabled:
		var tangent_direction := move_direction.tangent().normalized()
		raycast1.position = collision_radius * tangent_direction
		raycast2.position = - collision_radius * tangent_direction
		raycast1.cast_to = move_direction
		raycast2.cast_to = move_direction
		raycast1.force_raycast_update()
		raycast2.force_raycast_update()
		var collider = raycast1.get_collider()
		if collider:
			move_direction = raycast1.get_collision_point() - raycast1.global_position
			is_colliding = true
		else:
			collider = raycast2.get_collider()
			if collider:
				move_direction = raycast2.get_collision_point() - raycast2.global_position
				is_colliding = true
	area.position = move_direction
	return is_colliding


func initialize() -> void:
	self.collide_with_player = false
	self.enabled = true
	var identity_transform = Transform2D.IDENTITY
	transform = identity_transform
	raycast1.transform = identity_transform
	raycast2.transform = identity_transform
	area.transform = identity_transform
	raycast1.cast_to = Vector2.ZERO
	raycast2.cast_to = Vector2.ZERO


func _on_Area2D_area_entered(entered_area: Area2D) -> void:
	if (entered_area.get_parent() != owner) && (entered_area != player_hurtbox or collide_with_player):
		emit_signal("collision", entered_area, area.global_position)


func _on_Area2D_body_entered(body: Node) -> void:
	emit_signal("collision", body, area.global_position)
