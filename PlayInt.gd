extends RayCast3D

@onready var label = $"../Ui/Label"

var using = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var obj = self.get_collider()
	
	if self.is_colliding() and obj.is_in_group("Interact"):
		label.set_text("Interagir (E)")
		label.visible = true
	elif self.is_colliding() and obj.is_in_group("Pickable") and using == false:
		label.set_text("Pegar (LMB)")
		label.visible = true
	else:
		label.visible = false

func _on_player_using() -> void:
	using = true

func _on_player_not_using() -> void:
	using = false
