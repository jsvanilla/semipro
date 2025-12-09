@tool
extends HBoxContainer
class_name ContinentCreatorEntry

signal move_up
signal move_down
signal delete

@export var path:String:
	set(v):
		path = v
		
		if is_node_ready():
			%Label.text = path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = path
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bn_up_pressed() -> void:
	move_up.emit()


func _on_bn_down_pressed() -> void:
	move_down.emit()


func _on_bn_delete_pressed() -> void:
	delete.emit()
