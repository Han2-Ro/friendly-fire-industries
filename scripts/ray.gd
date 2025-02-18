extends RayCast3D

var mesh: ImmediateMesh
var line: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.GREEN
	
	line = MeshInstance3D.new()
	line.mesh = mesh
	line.material_override = material
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	draw_ray_quad()
	
	# Only continue if colliding
	if (!is_colliding()):
		return
	
	if (is_collider_bouncy(get_collider())):
		bounce(global_position, get_collision_point(), get_collision_normal())

func is_collider_bouncy(collider: Node3D) -> bool:
	if (collider.has_method("get_collision_layer_value")):
		return collider.get_collision_layer_value(1) and not collider.get_collision_layer_value(2)
	else:
		return false

func bounce(old_pos: Vector3, hit_pos: Vector3, norm: Vector3):
	var prev_dir = hit_pos - old_pos
	prev_dir = prev_dir.normalized()
	var new_dir = prev_dir.bounce(norm)
	var target = hit_pos + new_dir.normalized() * 100
	
	var query = PhysicsRayQueryParameters3D.create(hit_pos + norm * 0.001, target, collision_mask)
	query.collide_with_areas = true
		
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if (result.is_empty()):
		draw_bounce(to_local(hit_pos), to_local(target))
	else:
		draw_bounce(to_local(hit_pos), to_local(result["position"]))
		# recurse if bouncy
		if (is_collider_bouncy(result["collider"])):
			bounce(hit_pos, result["position"], result["normal"])

func draw_bounce(start: Vector3, end: Vector3):
	var dir = (end - start).normalized()
	var perp = Vector3(-dir.z, 0, dir.x)
	
	var thickness = 0.1 / 3 
	var right = perp * thickness
#
	## Create a rectangular prism along the line
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	mesh.surface_add_vertex(start + right)
	mesh.surface_add_vertex(start - right)
	mesh.surface_add_vertex(end - right)
	mesh.surface_add_vertex(end + right)
	mesh.surface_add_vertex(start + right)
	mesh.surface_end()

func draw_ray_simple():
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(global_position)
	mesh.surface_add_vertex(global_position + target_position)
	mesh.surface_end()

func draw_ray_quad():
	mesh.clear_surfaces()
	# Add these points to create a "thick" line using triangles
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var thickness = 0.1 / 3 
	#var up = Vector3(0, thickness, 0)
	var right = Vector3(thickness, 0, 0)
	
	var start = position
	var end
	if (is_colliding()):
		#print(get_collision_point())
		end = to_local(get_collision_point())
	else:
		end = start + target_position

	# Create a rectangular prism along the line
	mesh.surface_add_vertex(start + right)
	mesh.surface_add_vertex(start - right)
	mesh.surface_add_vertex(end - right)
	mesh.surface_add_vertex(end + right)
	mesh.surface_add_vertex(start + right)
	mesh.surface_end()
