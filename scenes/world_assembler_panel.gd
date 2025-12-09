extends VBoxContainer

signal generate_world

@export var world_assembler:WorldAssemblerManifest

func update_creator_list():
	for child in %creator_list.get_children():
		child.queue_free()
	
	if world_assembler:
		%spin_width.value = world_assembler.width
		%spin_height.value = world_assembler.height
		
		for i in world_assembler.generator_paths.size():
			var path:String = world_assembler.generator_paths[i]
			var item:ContinentCreatorEntry = preload("res://scenes/continent_creator_entry.tscn").instantiate()
			item.path = path
			item.move_up.connect(func():
				if i > 0:
					var p0:String = world_assembler.generator_paths[i - 1]
					var p1:String = world_assembler.generator_paths[i]
					
					world_assembler.generator_paths[i - 1] = p1
					world_assembler.generator_paths[i] = p0
					update_creator_list()
				)
			item.move_down.connect(func():
				if i < world_assembler.generator_paths.size() - 1:
					var p0:String = world_assembler.generator_paths[i]
					var p1:String = world_assembler.generator_paths[i + 1]
					
					world_assembler.generator_paths[i] = p1
					world_assembler.generator_paths[i + 1] = p0
					update_creator_list()
				)
			item.delete.connect(func():
				world_assembler.generator_paths.erase(i)
				update_creator_list()
				)
			
			%creator_list.add_child(item)

#func entry_move_up(index:int):
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_creator_list()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_file_dialog_load_files_selected(paths: PackedStringArray) -> void:
	if !world_assembler:
		return
	
	for path in paths:
		world_assembler.generator_paths.append(path)
	
	update_creator_list()


func _on_bn_add_entry_pressed() -> void:
	%FileDialog_load.show()


func _on_spin_width_value_changed(value: float) -> void:
	world_assembler.width = value


func _on_spin_height_value_changed(value: float) -> void:
	world_assembler.height = value

func _on_spin_seed_value_changed(value: float) -> void:
	world_assembler.seed = value


func _on_bn_generate_pressed() -> void:
	generate_world.emit()
	pass # Replace with function body.
