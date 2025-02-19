extends Node3D

var ray_length = 20
var mesh: ImmediateMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.GREEN
	var cone = MeshInstance3D.new()
	cone.mesh = mesh
	cone.material_override = material
	cone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	add_child(cone)
	
	#draw_triangle(Vector3(10,1,0),Vector3(10,1,10),Vector3(10,1,10))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	vision_cone(Vector3(1.0, 0.0, 0.0).rotated(Vector3.UP, get_parent_node_3d().rotation.y), PI/2)
	#print(Vector3(1.0, 0.0, 0.0).rotated(Vector3.UP, get_parent_node_3d().rotation.y))


func vision_cone(dir: Vector3, angle: float):
	dir = dir.rotated(Vector3.UP, angle/2)
	dir = dir.normalized()

	mesh.clear_surfaces()
	var space_state = get_world_3d().direct_space_state
	const step = 0.6
	var i = -angle / 2
	
	var hit_pos = ray_cast(global_position, dir, ray_length, space_state) - global_position
	
	# from -angle/2 to angle/2
	while i < angle/2:
		dir = dir.rotated(Vector3.UP, step)
		i += step
		
		var prev_hit_pos = hit_pos
		hit_pos = ray_cast(global_position, dir, ray_length, space_state) - global_position
		draw_triangle(	position.rotated(Vector3.UP, -get_parent_node_3d().rotation.y) + Vector3(0,1,0), \
						hit_pos.rotated(Vector3.UP, -get_parent_node_3d().rotation.y) + Vector3(0,1,0) + Vector3(0,1,0), \
						prev_hit_pos.rotated(Vector3.UP, -get_parent_node_3d().rotation.y) + Vector3(0,1,0) + Vector3(0,1,0))


func draw_triangle(vert1: Vector3, vert2: Vector3, vert3: Vector3):
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh.surface_add_vertex(vert1)
	mesh.surface_add_vertex(vert2)
	mesh.surface_add_vertex(vert3)
	mesh.surface_end()


func ray_cast(origin: Vector3, dir: Vector3, length: float, space_state):
	var end = (origin + dir) * ray_length
	#print(dir)
	var ray_query = PhysicsRayQueryParameters3D.create(origin, end, 3) # flooooooooooooooooo warum geht das nich
	var result = space_state.intersect_ray(ray_query)
	if result.is_empty():
		return origin + (dir * length)
	else:
		print(result)
		return result.position
