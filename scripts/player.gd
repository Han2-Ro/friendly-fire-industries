extends MeshInstance3D

@export var speed = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta

func _physics_process(_delta: float) -> void:
	look_at_cursor()

func look_at_cursor():
	var camera := get_viewport().get_camera_3d()
	var target_plane := Plane(Vector3(0, 1, 0), position.y)
	
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var dir = camera.project_ray_normal(mouse_position)
	if (dir.z == 0):
		return;
		
	var cursor_position_on_plane = target_plane.intersects_ray(from, dir)
	#print(str(from) + " : " + str(dir))
	if (cursor_position_on_plane != null):
		look_at(cursor_position_on_plane, Vector3.UP, 0)
	else:
		look_at(global_position + Vector3(0,10,0), Vector3.UP, 0)
