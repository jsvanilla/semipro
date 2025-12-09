extends Resource
class_name BorderBuilder

enum BorderCellType { NONE, FILL, #0
	EDGE_N, EDGE_S, EDGE_W, EDGE_E, #2
	EDGE_N_TURN_W, EDGE_N_TURN_E, #6
	EDGE_S_TURN_W, EDGE_S_TURN_E, #8
	EDGE_W_TURN_N, EDGE_W_TURN_S, #10
	EDGE_E_TURN_N, EDGE_E_TURN_S, #12
	CONCAVE_NW, CONCAVE_NE, CONCAVE_SW, CONCAVE_SE, #14
	CONVEX_NW, CONVEX_NE, CONVEX_SW, CONVEX_SE, #18
}

## return true if cell is solid, false iif in erosion space
var solid_test:Callable

#var default_cell_type:Variant
var src_grid:Grid2D

func calc_border_cell(src_i:int, src_j:int, quad:Quadrant.Type):
	var co_nw:Vector2i
	match(quad):
		Quadrant.Type.NW:
			co_nw = Vector2i(src_i - 1, src_j - 1)
		Quadrant.Type.NE:
			co_nw = Vector2i(src_i, src_j - 1)
		Quadrant.Type.SW:
			co_nw = Vector2i(src_i - 1, src_j)
		Quadrant.Type.SE:
			co_nw = Vector2i(src_i, src_j)
	
	var g_nw:WorldMapCell = src_grid.get_cell(co_nw.x, co_nw.y)
	var g_ne:WorldMapCell = src_grid.get_cell(co_nw.x + 1, co_nw.y)
	var g_sw:WorldMapCell = src_grid.get_cell(co_nw.x, co_nw.y + 1)
	var g_se:WorldMapCell = src_grid.get_cell(co_nw.x + 1, co_nw.y + 1)
	
	#var cell_nw:bool = solid_test.call(g_nw.terrain if g_nw else default_cell_type)
	#var cell_ne:bool = solid_test.call(g_ne.terrain if g_ne else default_cell_type)
	#var cell_sw:bool = solid_test.call(g_sw.terrain if g_sw else default_cell_type)
	#var cell_se:bool = solid_test.call(g_se.terrain if g_se else default_cell_type)
	#var cell_nw:bool = solid_test.call(src_grid.get_cell_with_default(co_nw.x + 1, co_nw.y, default_cell_type))
	#var cell_ne:bool = solid_test.call(src_grid.get_cell_with_default(co_nw.x + 1, co_nw.y, default_cell_type))
	#var cell_sw:bool = solid_test.call(src_grid.get_cell_with_default(co_nw.x, co_nw.y + 1, default_cell_type))
	#var cell_se:bool = solid_test.call(src_grid.get_cell_with_default(co_nw.x + 1, co_nw.y + 1, default_cell_type))
	var cell_nw:bool = solid_test.call(src_grid.get_cell(co_nw.x, co_nw.y))
	var cell_ne:bool = solid_test.call(src_grid.get_cell(co_nw.x + 1, co_nw.y))
	var cell_sw:bool = solid_test.call(src_grid.get_cell(co_nw.x, co_nw.y + 1))
	var cell_se:bool = solid_test.call(src_grid.get_cell(co_nw.x + 1, co_nw.y + 1))
	
	if quad == Quadrant.Type.NW:
		if !cell_se:
			var mask:int = (0b1 if cell_nw else 0) | (0b10 if cell_ne else 0) | (0b100 if cell_sw else 0)
			match mask:
				0:
					return BorderCellType.NONE
				1:
					return BorderCellType.CONVEX_NW
				2:
					return BorderCellType.EDGE_N_TURN_W
				3:
					return BorderCellType.EDGE_N
				4:
					return BorderCellType.EDGE_W_TURN_N
				5:
					return BorderCellType.EDGE_W
				6:
					return BorderCellType.CONCAVE_NW
				7:
					return BorderCellType.CONCAVE_NW
	elif quad == Quadrant.Type.NE:
		if !cell_sw:
			var mask:int = (0b1 if cell_nw else 0) | (0b10 if cell_ne else 0) | (0b100 if cell_se else 0)
			match mask:
				0:
					return BorderCellType.NONE
				1:
					return BorderCellType.EDGE_N_TURN_E
				2:
					return BorderCellType.CONVEX_NE
				3:
					return BorderCellType.EDGE_N
				4:
					return BorderCellType.EDGE_E_TURN_N
				5:
					return BorderCellType.CONCAVE_NE
				6:
					return BorderCellType.EDGE_E
				7:
					return BorderCellType.CONCAVE_NE
	elif quad == Quadrant.Type.SW:
		if !cell_ne:
			var mask:int = (0b1 if cell_nw else 0) | (0b10 if cell_sw else 0) | (0b100 if cell_se else 0)
			match mask:
				0:
					return BorderCellType.NONE
				1:
					return BorderCellType.EDGE_W_TURN_S
				2:
					return BorderCellType.CONVEX_SW
				3:
					return BorderCellType.EDGE_W
				4:
					return BorderCellType.EDGE_S_TURN_W
				5:
					return BorderCellType.CONCAVE_SW
				6:
					return BorderCellType.EDGE_S
				7:
					return BorderCellType.CONCAVE_SW
	elif quad == Quadrant.Type.SE:
		if !cell_nw:
			var mask:int = (0b1 if cell_ne else 0) | (0b10 if cell_sw else 0) | (0b100 if cell_se else 0)
			match mask:
				0:
					return BorderCellType.NONE
				1:
					return BorderCellType.EDGE_E_TURN_S
				2:
					return BorderCellType.EDGE_S_TURN_E
				3:
					return BorderCellType.CONCAVE_SE
				4:
					return BorderCellType.CONVEX_SE
				5:
					return BorderCellType.EDGE_E
				6:
					return BorderCellType.EDGE_S
				7:
					return BorderCellType.CONCAVE_SE
				
	return BorderCellType.FILL


func build()->Grid2D:
	var result:Grid2D = Grid2D.new(src_grid.width * 2, src_grid.height * 2)

	
	for src_j in src_grid.height:
		for src_i in src_grid.width:
			result.set_cell(src_i * 2, src_j * 2, calc_border_cell(src_i, src_j, Quadrant.Type.NW))
			result.set_cell(src_i * 2 + 1, src_j * 2, calc_border_cell(src_i, src_j, Quadrant.Type.NE))
			result.set_cell(src_i * 2, src_j * 2 + 1, calc_border_cell(src_i, src_j, Quadrant.Type.SW))
			result.set_cell(src_i * 2 + 1, src_j * 2 + 1, calc_border_cell(src_i, src_j, Quadrant.Type.SE))
	
	return result
