extends CharacterBody3D
class_name PlayerBody

@onready var state_machine:StateMachine = %state_machine

@export var joy_dead_zone:float = .2
@export var camera_mount_point:Node3D

var facing_dir:Vector3 = Vector3(0, 0, 1)
#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5

func _ready() -> void:
	state_machine.begin()

func _input(event: InputEvent) -> void:
	state_machine._state_input(event)

func _process(delta: float) -> void:
	state_machine._state_process(delta)

func _physics_process(delta: float) -> void:
	state_machine._state_physics_process(delta)
	
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
