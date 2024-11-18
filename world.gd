extends Node3D



func _on_grav_changer_rot_x() -> void:
	while rotation.x < deg_to_rad(90):
		await get_tree().create_timer(0.1).timeout
		rotate_x(deg_to_rad(1))
