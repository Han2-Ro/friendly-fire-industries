extends RayCast3D

var mesh: ImmediateMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.GREEN
	
	var line := MeshInstance3D.new()
	line.mesh = mesh
	line.material_override = material
	add_child(line)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	draw_ray2()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and is_colliding():
		var obj = get_collider().get_parent()
		if (obj.has_method("on_hit")):
			obj.on_hit()

func draw_ray():
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(global_position)
	mesh.surface_add_vertex(global_position + target_position)
	mesh.surface_end()

func draw_ray2():
	mesh.clear_surfaces()
	# Add these points to create a "thick" line using triangles
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var thickness = 0.1 # Adjust this value
	var up = Vector3(0, thickness, 0)
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
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	mesh.surface_add_vertex(end + right)
	mesh.surface_add_vertex(start + right)
	mesh.surface_end()
