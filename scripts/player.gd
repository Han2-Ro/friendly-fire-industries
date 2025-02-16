extends MeshInstance3D

@export var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta
	look_at_cursor()

func look_at_cursor():
	var camera := get_viewport().get_camera_3d()
	var target_plane_mouse := Plane(Vector3(0, .5, 0), 0)
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var dir = camera.project_ray_normal(mouse_position)
	var cursor_position_on_plane = target_plane_mouse.intersects_ray(from, dir)
	look_at(cursor_position_on_plane, Vector3.UP, 0)
