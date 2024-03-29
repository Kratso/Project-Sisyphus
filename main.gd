extends Node3D

@export var tile_straight: PackedScene
@export var tile_corner: PackedScene
@export var tile_empty: PackedScene
@export var tile_start: PackedScene
@export var tile_end: PackedScene

@export var map_length: int = 16
@export var map_height: int = 9
# Called when the node enters the scene tree for the first time.

var _pathGen: PathGenerator

func _ready():
	_pathGen = PathGenerator.new(map_length, map_height)
	_display_path()
	_complete_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _display_path():
	var _path:Array[Vector2i] = _pathGen.generate_path()

	while _path.size() < 35:
		print("faked out")
		_path = _pathGen.generate_path()
	print(_path)

# HOW THE SCORING WORKS
#
#		+1
#	+8		+2
#		+4
#

	for element in _path:
		var tile_score: int = _pathGen.get_tile_score(element)
		var tile: Node3D
		var tile_rotation: Vector3 = Vector3.ZERO
		match tile_score:
			10:
				tile = tile_straight.instantiate()
				tile_rotation = Vector3(0,90,0)
			8:
				tile = tile_end.instantiate()
				tile_rotation = Vector3(0,90,0)
			2:
				tile = tile_start.instantiate()
				tile_rotation = Vector3(0,-90,0)
			5,4,1:
				tile = tile_straight.instantiate()
			12:
				tile = tile_corner.instantiate()
				tile_rotation = Vector3(0,90,0)
			9:
				tile = tile_corner.instantiate()
			3:
				tile = tile_corner.instantiate()
				tile_rotation = Vector3(0,-90,0)
			6:
				tile = tile_corner.instantiate()
				tile_rotation = Vector3(0,180,0)
			_:
				tile = tile_empty.instantiate()
		add_child(tile)
		tile.global_position = Vector3(element.x, 0, element.y)
		tile.global_rotation_degrees = tile_rotation
		print(element, tile_score, tile_rotation)

func _complete_grid():
	for i in range(map_length):
		for j in range(map_height):
			if not _pathGen.get_path().has(Vector2i(i,j)):
				var tile: Node3D = tile_empty.instantiate()
				add_child(tile)
				tile.global_position = Vector3(i,0,j)
