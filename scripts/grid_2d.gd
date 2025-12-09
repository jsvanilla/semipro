@tool
extends Resource
class_name Grid2D

@export var width:int
@export var height:int
@export var tiles:Array

func _init(_width:int = 0, _height:int = 0):
	self.width = _width
	self.height = _height
	tiles.resize(width * height)
	
	for i in tiles.size():
		tiles[i] = WorldMapCell.new()


static func create(width:int = 0, height:int = 0)->Grid2D:
	return Grid2D.new(width, height)
			
func get_rect()->Rect2i:
	return Rect2i(0, 0, width, height)

func get_cell_v(p:Vector2i)->Variant:
	return get_cell(p.x, p.y)

func get_cell(x:int, y:int)->Variant:
	if x < 0 || y < 0 || x >= width || y >= height:
		return null
	return tiles[x + y * width]

func get_cell_with_default_v(p:Vector2i, default:Variant)->Variant:
	return get_cell_with_default(p.x, p.y, default)

func get_cell_with_default(x:int, y:int, default:Variant)->Variant:
	if x < 0 || y < 0 || x >= width || y >= height:
		return default
	return tiles[x + y * width]

func set_cell(x:int, y:int, value):
	if x < 0 || y < 0 || x >= width || y >= height:
		return null
	tiles[x + y * width] = value

func contains_position_v(pos:Vector2i)->bool:
	return pos.x >= 0 && pos.y >= 0 && pos.x < width && pos.y < height
	

func blit(peer:Grid2D, pos:Vector2i, src_rect:Rect2i):
	src_rect = src_rect.intersection(peer.get_rect())
	var dest_rect = Rect2i(pos, src_rect.size)
	dest_rect = dest_rect.intersection(get_rect())
	
	for j in dest_rect.size.y:
		for i in dest_rect.size.x:
			var dest_cell = get_cell_v(Vector2i(i, j) + pos)
			var src_cell = peer.get_cell_v(Vector2i(i, j) + src_rect.position)
			dest_cell.copy_tile(src_cell)
