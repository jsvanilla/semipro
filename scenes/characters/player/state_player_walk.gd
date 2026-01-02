extends StatePlayerBase
class_name StatePlayerWalk

@export var state_idle:StateMachineState
@export var walk_speed:float = 10

func _state_physics_process(_delta:float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * _delta
		
	var input_joy_main = Vector2(Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down"))
	
	if input_joy_main.length_squared() < player.joy_dead_zone:
		state_machine.switch_to_state(state_idle)
		return
	
	var view_ref_point:Node3D = player.camera_mount_point
	if !view_ref_point:
		view_ref_point = player
	
	var move_dir:Vector3 = view_ref_point.basis.x * input_joy_main.x + view_ref_point.basis.z * input_joy_main.y
	player.facing_dir = move_dir.normalized()
	
	player.velocity = move_dir * walk_speed
	
	update_animation()
	player.move_and_slide()

func update_animation():
	pass
