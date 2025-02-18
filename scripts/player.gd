extends Node3D

@export var speed = 3
@export var goal_distance = 30

@onready var rotation_stange = $Player/player_base/player_rotationstange

func _ready() -> void:
	EventBus.level_end.connect(_on_level_end)
	

func _process(delta: float) -> void:
	position.x += speed * delta
	if (position.x > goal_distance): # TODO: How to do it for more complex path
		EventBus.level_end.emit(true)

func _physics_process(_delta: float) -> void:
	look_at_cursor()

func look_at_cursor():
	var camera := get_viewport().get_camera_3d()
	var target_plane := Plane(Vector3(0, 1, 0), position.y)
	
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_position)
	var dir = camera.project_ray_normal(mouse_position)
	if (dir.z == 0):
		return ;
		
	var cursor_position_on_plane = target_plane.intersects_ray(from, dir)
	if (cursor_position_on_plane != null):
		rotation_stange.look_at(cursor_position_on_plane, Vector3.UP, 0)

func _on_level_end(_success: bool) -> void:
	queue_free()
