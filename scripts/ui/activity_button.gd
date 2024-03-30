extends Button

@export var activity_button_icon: Texture2D
@export var activity_draggable: PackedScene
@export var _error_mat: Material

var _is_dragging: bool = false
var _draggable: Node3D
var _cam: Camera3D
var RAYCAST_LENGTH:float = 100
var _is_valid_location: bool = false
var _last_valid_location: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	icon = activity_button_icon
	_draggable = activity_draggable.instantiate()
	add_child(_draggable)
	_draggable.visible = false
	_cam = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if _is_dragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var space_state = _draggable.get_world_3d().direct_space_state
			var mouse_pos = get_viewport().get_mouse_position()
			var origin = _cam.project_ray_origin(mouse_pos)
			var end = origin + _cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			query.collide_with_areas = true
			var ray_result = space_state.intersect_ray(query)
			if ray_result.size() > 0 :
				var collider = ray_result.get("collider")
				if collider.get_groups()[0] == "empty":
					print(collider.get_groups())
					_draggable.visible = true
					_is_valid_location = true
					clear_child_mesh_error(_draggable)
					_last_valid_location = Vector3(collider.global_position.x, 0.2, collider.global_position.z)
				else:
					_is_valid_location = false
					set_child_mesh_error(_draggable)
				_draggable.global_position = Vector3(collider.global_position.x, 0.2, collider.global_position.z)
			else:
				_draggable.visible = false

func set_child_mesh_error(node: Node):
	for child in node.get_children():
		if child is MeshInstance3D:
			set_mesh_error(child)
		if child is Node and child.get_child_count() > 0:
			set_child_mesh_error(child)

func set_mesh_error(mesh: MeshInstance3D):
	for surface in mesh.mesh.get_surface_count():
		mesh.set_surface_override_material(surface, _error_mat) 

func clear_child_mesh_error(node: Node):
	for child in node.get_children():
		if child is MeshInstance3D:
			clear_mesh_error(child)
		if child is Node and child.get_child_count() > 0:
			clear_child_mesh_error(child)

func clear_mesh_error(mesh: MeshInstance3D):
	for surface in mesh.mesh.get_surface_count():
		mesh.set_surface_override_material(surface, null)

func _on_button_down():
	_is_dragging = true
	

func _on_button_up():
	_is_dragging = false
	print(_is_valid_location, _last_valid_location)
	_draggable.visible = false
	if _is_valid_location:
		print("????")
		var activity = activity_draggable.instantiate()
		add_child(activity)
		activity.global_position = _last_valid_location
