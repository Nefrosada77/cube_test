extends MeshInstance3D

var port_op = false

func _on_button_body_porta_ab() -> void:
	if port_op:
		pass
	else:
		port_op = true
		while position.y < 4.5:
			translate(Vector3(0,0.025,0))
			await get_tree().create_timer(0.01).timeout
