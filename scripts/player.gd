extends PathFollow3D

@export var speed: float = 3
@export var ammo: int = 3
@export var slowmotion_uses: int = 3

@onready var rotation_stange = $Player/player_base/player_rotationstange
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var muzzleflash = $Player/player_base/player_rotationstange/player_body/player_barrel/Muzzleflash
@onready var player_barrel: MeshInstance3D = $Player/player_base/player_rotationstange/player_body/player_barrel
@onready var player_body: MeshInstance3D = $Player/player_base/player_rotationstange/player_body
@onready var no_ammo_player: AudioStreamPlayer = $NoAmmoPlayer
@onready var player_kaputt = preload("res://scenes/player_kaputt.tscn")
@onready var explodeparticle = preload("res://scenes/particles/explosion.tscn")
@onready var ui: UIPlayer = $UI

var last_cursor_pos: Vector3
var slowmotion_pressed: bool = false
var slowmotion_time_left: float = 0
var slowmotion_duration: float = 5

func _ready() -> void:
	EventBus.level_end.connect(_on_level_end)
	ui.setup_ammo(ammo)
	ui.setup_time(slowmotion_uses)
	Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	if (Engine.time_scale != 0): # don't aim when paused
		look_at_cursor()
	progress += speed * delta
	if (progress_ratio >= 1.0):
		EventBus.level_end.emit(true)
	if (slowmotion_time_left > 0):
		slowmotion_time_left -= delta / Engine.time_scale
	elif (slowmotion_pressed):
		Engine.time_scale = 1

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
	if event.is_action_pressed("shoot") and Engine.time_scale != 0: # don't shoot when paused
		if (ammo > 0):
			ammo -= 1
			ui.update_ammo(ammo)
			shoot()
		else:
			print("Out of ammo")
			no_ammo_player.play()
	
	handle_timescale(event)
	
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func handle_timescale(event: InputEvent):
	var speedup = 4
	var slow_down = 0.1
	var timescale = Engine.time_scale
	#print("timescale: ", timescale, " slowmotion: ", slowmotion_pressed)

	if event.is_action_pressed("fast_forward", true) and timescale != slow_down:
		timescale = speedup
	if event.is_action_pressed("slow_motion", true) and !slowmotion_pressed and slowmotion_uses > 0: # has prio & don't tirgger when already active
		slowmotion_uses -= 1
		ui.update_time(slowmotion_uses)
		slowmotion_pressed = true
		timescale = slow_down
		slowmotion_time_left = slowmotion_duration
		ui.slowmotion_start(slowmotion_duration)
	if event.is_action_released("fast_forward") and timescale != slow_down:
		timescale = 1
	if event.is_action_released("slow_motion"):
		slowmotion_pressed = false
		ui.slowmotion_reset()
		timescale = 1
	Engine.time_scale = timescale
	
		
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

func on_hit():
	EventBus.level_end.emit(false)

func _on_level_end(_success: bool) -> void:
	if not _success:
		death()
	queue_free()
func death():
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	explosion_instance.explode()
	print("death")
	var broken_player_instance = player_kaputt.instantiate()
	broken_player_instance.global_transform = player_body.global_transform
	get_parent().add_child(broken_player_instance)
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("block_player"):
		if area.get_parent().has_method("on_hit"):
			area.get_parent().on_hit()
		EventBus.level_end.emit(false)
