extends Node3D

@export var tile_straight: PackedScene
@export var tile_corner: PackedScene
@export var tile_crossroad: PackedScene
@export var tile_empty: Array[PackedScene]
@export var tile_start: PackedScene
@export var tile_end: PackedScene
@export var tile_enemy: PackedScene

@export var basic_enemy: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	_complete_grid()
	
	await get_tree().create_timer(2).timeout
	
	for i in range(20):
		await get_tree().create_timer(2).timeout
		print("Instantiating enemy")
		var enemy = basic_enemy.instantiate()
		add_child(enemy)
		enemy.add_to_group("enemies")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _complete_grid():
	for i in range(PathGenSingleton._grid_length):
		for j in range(PathGenSingleton._grid_height):
			if not PathGenSingleton.get_path_route().has(Vector2i(i, j)):
				var tile: Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(i, 0, j)
	for i in range(PathGenSingleton.get_path_route().size()):
		var tile_score = PathGenSingleton.get_tile_score(i)
		
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		
		match tile_score:
			10:
				tile = tile_straight.instantiate()
				tile_rotation = Vector3(0, 90, 0)
			8:
				tile = tile_end.instantiate()
				tile_rotation = Vector3(0, 90, 0)
			2:
				tile = tile_start.instantiate()
				tile_rotation = Vector3(0, -90, 0)
			5, 4, 1:
				tile = tile_straight.instantiate()
			12:
				tile = tile_corner.instantiate()
				tile_rotation = Vector3(0, 90, 0)
			9:
				tile = tile_corner.instantiate()
			3:
				tile = tile_corner.instantiate()
				tile_rotation = Vector3(0, -90, 0)
			6:
				tile = tile_corner.instantiate()
				tile_rotation = Vector3(0, 180, 0)
			15:
				tile = tile_crossroad.instantiate()
			_:
				tile = tile_empty.pick_random().instantiate()
		add_child(tile)
		tile.global_position = Vector3(PathGenSingleton.get_path_tile(i).x, 0, PathGenSingleton.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation
