extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var sens = 0.002

@onready var label := $Pesc/Camera3D/Ui/Label
@onready var pesc := $Pesc
@onready var camera := $Pesc/Camera3D
@onready var interaction := $Pesc/Camera3D/Interaction
@onready var hand := $Pesc/Camera3D/hand

var picked_object
var pull_power = 4

signal using
signal not_using

func _unhandled_input(event: InputEvent) -> void:
	#Checar se o mouse está visivel;  DEIXAR AQUI;
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
	#CAPTURA O MOUSE DEPOIS DE CLICAR NA TELA;
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#DEIXA O MOUSE VISIVEL QUANDO CLICAR "ESC";
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#CHECAR MOUSE SENDO CAPTURADO;
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			#ROTACIONAR CAMERA QUANDO MOUSE SER ROTACIONADO
			rotate_y(-event.relative.x * sens)
			camera.rotate_x(-event.relative.y * sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40),deg_to_rad(60))
		if Input.is_action_just_pressed("PickUp"):
			if picked_object == null:
				pick_object()
			elif picked_object != null:
				unpick_object()
		if Input.is_action_just_pressed("interact"):
			interact()
		if Input.is_action_just_pressed("Throw"):
			if picked_object != null:
				var knockback = picked_object.position - position
				picked_object.apply_central_impulse(knockback * 2.5)
				unpick_object()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Esq", "Dir", "Frente", "Tras")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, pesc.rotation.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if picked_object != null:
		var a = picked_object.global_position
		var b = hand.global_position
		picked_object.set_linear_velocity((b-a)*pull_power)

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider.is_in_group("Pickable"):
		using.emit()
		picked_object = collider

func unpick_object():
	if picked_object != null:
		not_using.emit()
		picked_object = null
	
func interact():
	var obj = interaction.get_collider()
	
	if interaction.is_colliding() and obj.is_in_group("Interact"):
		obj.interact()
