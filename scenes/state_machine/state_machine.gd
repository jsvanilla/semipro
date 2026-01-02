@tool
extends StatePlayerBase
class_name StateMachine

@export var initial_state:StateMachineState

var cur_state:StateMachineState

func switch_to_state(next_state:StateMachineState)->void:
	if cur_state:
		cur_state._state_exiting()
	
	cur_state = next_state
	
	if cur_state:
		cur_state._state_entering()
	

func _state_input(event:InputEvent)->void:
	if cur_state:
		cur_state._state_input(event)

func _state_process(delta:float)->void:
	if cur_state:
		cur_state._state_process(delta)

func _state_physics_process(delta:float)->void:
	if cur_state:
		cur_state._state_physics_process(delta)

func begin():
	switch_to_state(initial_state)
	

func _on_child_entered_tree(node: Node) -> void:
	if node is StateMachineState:
		node.state_machine = self


func _on_child_exiting_tree(node: Node) -> void:
	if node is StateMachineState:
		node.state_machine = null
