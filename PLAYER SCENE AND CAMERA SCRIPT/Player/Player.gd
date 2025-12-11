extends Personaje
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 9 #4.5
var last_direction 
var estado := "reposo"
@onready var sprite_animation : AnimatedSprite3D = $AnimatedSprite3D
@onready var collision_billboard : CollisionShape3D = $CollisionBillboard

signal event_mode

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var key_order: Array[Vector2] = []

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if sprite_animation.billboard == BaseMaterial3D.BILLBOARD_ENABLED:
		#collision_shape_3d.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-30))
		#player_collition.rotation.x = -30
		collision_billboard.disabled = false
	else:
		collision_billboard.disabled = true
		
		
	if not is_on_floor():
		#print(velocity.y)
		velocity.y -= (gravity*3) * delta

	# Handle Jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	move_and_slide()
	# 	velocity.y = JUMP_VELOCITY
		
	check_key("ui_up",Vector2.UP)
	check_key("ui_down",Vector2.DOWN)
	check_key("ui_left",Vector2.LEFT)
	check_key("ui_right",Vector2.RIGHT)


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Vector2.ZERO

	if !key_order.is_empty():
		input_dir = key_order[len(key_order)-1]

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		estado = "corriendo"
		last_direction = direction
		#if globalScript.character_can_move:
		#	velocity.x = direction.x * SPEED
		#	velocity.z = direction.z * SPEED
			#print(global_position)
	else:
		estado = "reposo"
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	player_animation()
	
	
func check_key(key: String, vector: Vector2):
	#if Input.is_action_just_pressed(key) and globalScript.character_can_move:
	#	if !key_order.has(vector):
	#		key_order.append(vector)
	if !Input.is_action_pressed(key):
		if key_order.has(vector):
			key_order.erase(vector)

func player_animation():
	match last_direction:
		Vector3(-1,0,0):
			$AnimatedSprite3D.play(estado + "_izquierda")
		Vector3(1,0,0):
			$AnimatedSprite3D.play(estado + "_derecha")
		Vector3(0,0,1):
			$AnimatedSprite3D.play(estado + "_adelante")
		Vector3(0,0,-1):
			$AnimatedSprite3D.play(estado + "_atras")
		_:
			$AnimatedSprite3D.play("default")

func mover(direccion_parametro:String, distancia: float, accion: String, parallel: bool= false):
	event_mode.emit(accion)
	await super(direccion_parametro, distancia, accion, parallel)
	event_mode.emit('reset')
