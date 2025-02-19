extends PathFollow3D

@export var speed = 3

@onready var rotation_stange = $Player/player_base/player_rotationstange
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var muzzleflash = $Player/player_base/player_rotationstange/player_body/player_barrel/Muzzleflash
@onready var player_barrel: MeshInstance3D = $Player/player_base/player_rotationstange/player_body/player_barrel
@onready var player_body: MeshInstance3D = $Player/player_base/player_rotationstange/player_body


var last_cursor_pos: Vector3

func _ready() -> void:
	EventBus.level_end.connect(_on_level_end)

func _physics_process(delta: float) -> void:
	look_at_cursor()
	progress += speed * delta
	if (progress_ratio >= 1.0):
		EventBus.level_end.emit(true)

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
		cursor_position_on_plane.y = rotation_stange.global_position.y
		rotation_stange.look_at(cursor_position_on_plane, Vector3.UP, 0)
		last_cursor_pos = cursor_position_on_plane

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
		
func shoot():
	muzzleflash.shoot()
	var instance = bullet_scene.instantiate()
	var direction = last_cursor_pos - rotation_stange.global_position
	direction.y = 0
	direction = direction.normalized()
	instance.dir = direction
	instance.INH_MAX_BOUNCES = $Player/player_base/player_rotationstange/RayCast3D.MAX_BOUNCES
	get_parent().get_parent().add_child(instance)
	instance.global_position = rotation_stange.global_position + direction
	
	var recoil_distance = 0.05
	var recoil_duration = 0.05
	
	player_body.translate_object_local(Vector3(0, 0, recoil_distance))
	await get_tree().create_timer(recoil_duration).timeout
	player_body.translate_object_local(Vector3(0, 0, -recoil_distance))
		
func _on_level_end(_success: bool) -> void:
	queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("block_player"):
		EventBus.level_end.emit(false)
