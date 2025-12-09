extends Control

var grid:Grid2D
var rng:RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = Grid2D.create(100, 100)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#var move_step:Array = [
	#Vector2i(-1, 0),
	#Vector2i(1, 0),
	#Vector2i(0, -1),
	#Vector2i(0, 1),
	#]
	
var move_step:Array = [
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(0, 1),

	Vector2i(-1, -1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(1, 1),
	]
	
func next_to_land(pos:Vector2i)->bool:
	for i in 4:
		if grid.get_cell_v(pos + move_step[i]) == 1:
			return true
	return false
	
func take_step(pos:Vector2i)->Vector2i:
	while true:
		var move:Vector2i = move_step[rng.randi_range(0, 3)]
		var next_pos = pos + move
		if grid.contains_position_v(next_pos):
			return next_pos
			
	return Vector2i.ZERO
	
func _on_bn_generate_pressed() -> void:
	rng = RandomNumberGenerator.new()
	
	for j in grid.height:
		for i in grid.width:
			grid.set_cell(i, j, 0)
	
	for i in 2:
		var land_seed:Vector2i = Vector2i(rng.randi_range(0, grid.width - 1), rng.randi_range(0, grid.height - 1))
		
		grid.set_cell(land_seed.x, land_seed.y, 1)
	
	for i in 2000:
		var pos:Vector2i = Vector2i(rng.randi_range(0, grid.width - 1), rng.randi_range(0, grid.height - 1))
		while grid.get_cell_v(pos) == 1:
			pos = Vector2i(rng.randi_range(0, grid.width - 1), rng.randi_range(0, grid.height - 1))

		while true:
			pos = take_step(pos)
			if next_to_land(pos):
				grid.set_cell(pos.x, pos.y, 1)
				print("placed ", i)
				break
		
	var data:PackedFloat32Array
	data.resize(grid.width * grid.height)
	for j in grid.height:
		for i in grid.width:
			data[i + j * grid.width] = grid.get_cell(i, j)
	
	var img = Image.create_from_data(grid.width, grid.height, false, Image.FORMAT_RF, data.to_byte_array())
	img.save_png("random_walk.png")
	
	pass # Replace with function body.
