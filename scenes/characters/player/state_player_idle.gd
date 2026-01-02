extends StatePlayerBase
class_name StatePlayerIdle

@export var state_walk:StateMachineState

func _state_entering(_params:Dictionary = {}):
	player.velocity = Vector3.ZERO

	pass

func _state_physics_process(delta:float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	var input_joy_main = Vector2(Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down"))
	
	if input_joy_main.length_squared() > player.joy_dead_zone:
		state_machine.switch_to_state(state_walk)

	update_animation()

	player.move_and_slide()
		

func update_animation():
	
	
	pass
