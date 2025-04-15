extends MeshInstance3D

@onready var parent = $".."

var cone_height = Vector3(0, .65, 0)

func _ready() -> void:
	mesh = ImmediateMesh.new()

func _physics_process(delta: float) -> void:
	#calculate_plane()
	pass

func calculate_plane():
	vision_cone(Vector3(1.0, 0.0, 0.0), 2 * PI)

func vision_cone(dir: Vector3, angle: float):
	dir = dir.rotated(Vector3.UP, angle/2)
	dir = dir.normalized()

	mesh.clear_surfaces()
	const step = PI / 50
	var i = -angle / 2
	
	var hit_pos = to_local(ray_cast(to_global(position + cone_height), dir, parent.tracking_distance))
	var start = hit_pos
	var prev_hit_pos = hit_pos
	
	# from -angle/2 to angle/2
	while i < angle/2:
		dir = dir.rotated(Vector3.UP, step)
		i += step
		
		prev_hit_pos = hit_pos
		hit_pos = to_local(ray_cast(to_global(position + cone_height), dir, parent.tracking_distance))
		draw_triangle(	position + cone_height, \
						hit_pos , \
						prev_hit_pos)


func draw_triangle(vert1: Vector3, vert2: Vector3, vert3: Vector3):
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh.surface_set_uv(Vector2(0.5, 0.5))
	mesh.surface_add_vertex(vert1)
	mesh.surface_set_uv(get_uv(vert2))
	mesh.surface_add_vertex(vert2)
	mesh.surface_set_uv(get_uv(vert3))
	mesh.surface_add_vertex(vert3)
	mesh.surface_end()

func get_uv(vert: Vector3) -> Vector2:
	var vec = vert - position
	#print(vec.length())
	var dist = vec.length() / parent.tracking_distance
	vec = vec.normalized()
	return Vector2(vec.x, vec.z) * dist / 2 + Vector2(0.5, 0.5)

func ray_cast(origin: Vector3, dir: Vector3, length: float):
	var end = origin + dir * length
	var ray_query = PhysicsRayQueryParameters3D.create(origin, end, 3)
	# TODO exclude player?
	var result = get_world_3d().direct_space_state.intersect_ray(ray_query)
	if result.is_empty():
		return origin + (dir * length)
	else:
		var pos = result.position
		#return Vector3(pos.x, 0, pos.z)
		return pos
