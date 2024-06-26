extends Node
class_name PathGenerator

const path_config: PathGeneratorConfig = preload ("res://resources/basic_path_resource.res")

var _loop_count: int

var _grid_height: int
var _grid_length: int
var _path: Array[Vector2i]

func _init():
	_grid_height = path_config.map_height
	_grid_length = path_config.map_length
	generate_path(path_config.add_loops)
	var it_counter: int = 1
	while ((_path.size() < path_config.min_path_size) 
		or (_path.size() > path_config.max_path_size) 
		or (path_config.add_loops and _loop_count < path_config.min_loops) 
		or (path_config.add_loops and _loop_count > path_config.max_loops)):
		generate_path(path_config.add_loops)
		print("Iterating ", it_counter)
		it_counter += 1

func get_path_route() -> Array[Vector2i]:
	return _path

func generate_path(add_loops: bool=false):
	_path.clear()
	_loop_count = 0
	randomize()
	
	var x: int = 0
	var y: int = int(_grid_height / 2)
	
	while x < _grid_length:
		if not _path.has(Vector2i(x, y)):
				_path.append(Vector2i(x, y))
				
		var choice: int = randi_range(0, 2)
		
		if choice == 0 or x % 2 == 0 or x == _grid_length - 1:
			x += 1
		elif choice == 1 and y < _grid_height - 1 and not _path.has(Vector2i(x, y + 1)):
			y += 1
		elif choice == 2 and y > 1 and not _path.has(Vector2i(x, y - 1)):
			y -= 1
			
	if (add_loops):
		_add_loops()
			
	return _path

func get_tile_score(tileIndex: int) -> int:
	var score: int = 0
	
	var x = _path[tileIndex].x
	var y = _path[tileIndex].y
	
	score += 1 if _path.has(Vector2i(x, y - 1)) else 0
	score += 2 if _path.has(Vector2i(x + 1, y)) else 0
	score += 4 if _path.has(Vector2i(x, y + 1)) else 0
	score += 8 if _path.has(Vector2i(x - 1, y)) else 0
	
	return score

func _add_loops():
	var loops_generated: bool = true
	
	while loops_generated:
		loops_generated = false
		for i in range(_path.size()):
			var loop: Array[Vector2i] = _is_loop_option(i)
			# if size > 0, then a loop is found
			if loop.size() > 0:
				loops_generated = true
				for j in range(loop.size()):
					_path.insert(i + 1 + j, loop[j])
					
func _is_loop_option(index: int) -> Array[Vector2i]:
	var x: int = _path[index].x
	var y: int = _path[index].y
	var return_path: Array[Vector2i]
	
	if (x < _grid_length - 1 and y > 1
		and _tile_loc_free(x, y - 3) and _tile_loc_free(x + 1, y - 3) and _tile_loc_free(x + 2, y - 3)
		and _tile_loc_free(x - 1, y - 2) and _tile_loc_free(x, y - 2) and _tile_loc_free(x + 1, y - 2) and _tile_loc_free(x + 2, y - 2) and _tile_loc_free(x + 3, y - 2)
		and _tile_loc_free(x - 1, y - 1) and _tile_loc_free(x, y - 1) and _tile_loc_free(x + 1, y - 1) and _tile_loc_free(x + 2, y - 1) and _tile_loc_free(x + 3, y - 1)
		and _tile_loc_free(x + 1, y) and _tile_loc_free(x + 2, y) and _tile_loc_free(x + 3, y)
		and _tile_loc_free(x + 1, y + 1) and _tile_loc_free(x + 2, y + 1)):
		return_path = [Vector2i(x + 1, y), Vector2i(x + 2, y), Vector2i(x + 2, y - 1), Vector2i(x + 2, y - 2), Vector2i(x + 1, y - 2), Vector2i(x, y - 2), Vector2i(x, y - 1)]

		if _path[index - 1].y > y:
			return_path.reverse()
			
		_loop_count += 1
		return_path.append(Vector2i(x, y))
	
	elif (x > 2 and y > 1
			and _tile_loc_free(x, y - 3) and _tile_loc_free(x - 1, y - 3) and _tile_loc_free(x - 2, y - 3)
			and _tile_loc_free(x - 1, y) and _tile_loc_free(x - 2, y) and _tile_loc_free(x - 3, y)
			and _tile_loc_free(x + 1, y - 1) and _tile_loc_free(x, y - 1) and _tile_loc_free(x - 2, y - 1) and _tile_loc_free(x - 3, y - 1)
			and _tile_loc_free(x + 1, y - 2) and _tile_loc_free(x, y - 2) and _tile_loc_free(x - 1, y - 2) and _tile_loc_free(x - 2, y - 2) and _tile_loc_free(x - 3, y - 2)
			and _tile_loc_free(x - 1, y + 1) and _tile_loc_free(x - 2, y + 1)):
		return_path = [Vector2i(x, y - 1), Vector2i(x, y - 2), Vector2i(x - 1, y - 2), Vector2i(x - 2, y - 2), Vector2i(x - 2, y - 1), Vector2i(x - 2, y), Vector2i(x - 1, y)]

		if _path[index - 1].x > x:
			return_path.reverse()

		_loop_count += 1
		return_path.append(Vector2i(x, y))

	elif (x < _grid_length - 1 and y < _grid_height - 2
			and _tile_loc_free(x, y + 3) and _tile_loc_free(x + 1, y + 3) and _tile_loc_free(x + 2, y + 3)
			and _tile_loc_free(x + 1, y - 1) and _tile_loc_free(x + 2, y - 1)
			and _tile_loc_free(x + 1, y) and _tile_loc_free(x + 2, y) and _tile_loc_free(x + 3, y)
			and _tile_loc_free(x - 1, y + 1) and _tile_loc_free(x, y + 1) and _tile_loc_free(x + 2, y + 1) and _tile_loc_free(x + 3, y + 1)
			and _tile_loc_free(x - 1, y + 2) and _tile_loc_free(x, y + 2) and _tile_loc_free(x + 1, y + 2) and _tile_loc_free(x + 2, y + 2) and _tile_loc_free(x + 3, y + 2)):
		return_path = [Vector2i(x + 1, y), Vector2i(x + 2, y), Vector2i(x + 2, y + 1), Vector2i(x + 2, y + 2), Vector2i(x + 1, y + 2), Vector2i(x, y + 2), Vector2i(x, y + 1)]

		if _path[index - 1].y < y:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x, y))

	elif (x > 2 and y < _grid_height - 2
			and _tile_loc_free(x, y + 3) and _tile_loc_free(x - 1, y + 3) and _tile_loc_free(x - 2, y + 3)
			and _tile_loc_free(x - 1, y - 1) and _tile_loc_free(x - 2, y - 1)
			and _tile_loc_free(x - 1, y) and _tile_loc_free(x - 2, y) and _tile_loc_free(x - 3, y)
			and _tile_loc_free(x + 1, y + 1) and _tile_loc_free(x, y + 1) and _tile_loc_free(x - 2, y + 1) and _tile_loc_free(x - 3, y + 1)
			and _tile_loc_free(x + 1, y + 2) and _tile_loc_free(x, y + 2) and _tile_loc_free(x - 1, y + 2) and _tile_loc_free(x - 2, y + 2) and _tile_loc_free(x - 3, y + 2)):
		return_path = [Vector2i(x, y + 1), Vector2i(x, y + 2), Vector2i(x - 1, y + 2), Vector2i(x - 2, y + 2), Vector2i(x - 2, y + 1), Vector2i(x - 2, y), Vector2i(x - 1, y)]

		if _path[index - 1].x > x:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x, y))
	
	return return_path
	
## Returns true if there is a path tile at the x,y coordinate.
func _tile_loc_free(x: int, y: int) -> bool:
	return not _path.has(Vector2i(x, y))

## Returns the number of loops currently in the path.
func get_loop_count() -> int:
	return _loop_count

## Returns the Vector2i path tile at the given index.
func get_path_tile(index: int) -> Vector2i:
	return _path[index]
