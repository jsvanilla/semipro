@abstract
@tool
extends Node
class_name StateMachineState

@export var state_machine:StateMachine

#func get_state_machine()->StateMachine:
	#return get_parent()


func _state_entering(_params:Dictionary = {}):
	pass

func _state_exiting():
	pass

func _state_input(_event: InputEvent) -> void:
	pass

func _state_process(_delta:float)->void:
	pass

func _state_physics_process(_delta:float)->void:
	pass
