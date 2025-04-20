extends PathFollow3D

@export var speed: float = 1.5
@export var ammo: int = 3
@export var slowmotion_uses: int = 3

@onready var rotation_stange = $Player/player_base/player_rotationstange
@onready var bullet_scene = preload("res://characters/player/bullet/bullet.tscn")
@onready var muzzleflash = $Player/player_base/player_rotationstange/player_body/player_barrel/Muzzleflash
@onready var player_barrel: MeshInstance3D = $Player/player_base/player_rotationstange/player_body/player_barrel
@onready var player_body: MeshInstance3D = $Player/player_base/player_rotationstange/player_body
@onready var no_ammo_player: AudioStreamPlayer = $NoAmmoPlayer
@onready var player_kaputt = preload("res://characters/player/player_kaputt.tscn")
@onready var explodeparticle = preload("res://characters/common/explosion.tscn")
@onready var ui: UIPlayer = $UI
@onready var ray: RayCast3D = $Player/player_base/player_rotationstange/RayCast3D

var last_cursor_pos: Vector3
var slowmotion_pressed: bool = false
var slowmotion_time_left: float = 0
var slowmotion_duration: float = 5
var lock_on_target: Node3D = null

func _ready() -> void:
	EventBus.level_end.connect(_on_level_end)
	ui.setup_ammo(ammo)
	ui.setup_time(slowmotion_uses)
	Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	if (Engine.time_scale != 0): # don't aim when paused
		if is_instance_valid(lock_on_target):
			look_at_lock_on_target()
		else:
			look_at_cursor()
	progress += speed * delta
	if (progress_ratio >= 1.0):
		EventBus.level_end.emit(true)
	
	# slowmotion timer
	if (slowmotion_time_left > 0):
		if (Engine.time_scale != 0):
			slowmotion_time_left -= delta / Engine.time_scale
	elif (slowmotion_pressed and slowmotion_time_left != -100):
		print("slowmotion timeout")
		Engine.time_scale = 1
		slowmotion_time_left = -100

func look_at_cursor():
	var camera := get_viewport().get_camera_3d()
	var target_plane := Plane(Vector3(0, 1, 0), player_barrel.global_position.y)
	
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

func look_at_lock_on_target():
	var target_pos := lock_on_target.position
	target_pos.y = player_barrel.global_position.y
	rotation_stange.look_at(target_pos, Vector3.UP, 0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and Engine.time_scale != 0: # don't shoot when paused
		if (ammo > 0):
			ammo -= 1
			ui.update_ammo(ammo)
			shoot()
		else:
			print("Out of ammo")
			no_ammo_player.play()
	elif event.is_action_pressed("lock_on") and ray.is_colliding() and ray.get_collider().has_method("on_hit"):
		lock_on_target = ray.get_collider()
	elif event.is_action_released("lock_on"):
		lock_on_target = null
		
	
	handle_timescale(event)
	
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

#terrible if statements that almost work
func handle_timescale(event: InputEvent):
	var speedup = 4
	var slow_down = 0.1
	var timescale = Engine.time_scale
	#print("timescale: ", timescale, " slowmotion: ", slowmotion_pressed)

	if OS.is_debug_build() and event.is_action_pressed("fast_forward", true) and timescale == 1:
		timescale = speedup
	
	if event.is_action_pressed("slow_motion", true) and !slowmotion_pressed and slowmotion_uses > 0 and timescale != 0: # has prio & don't tirgger when already active
		slowmotion_uses -= 1
		ui.update_time(slowmotion_uses)
		slowmotion_pressed = true
		timescale = slow_down
		slowmotion_time_left = slowmotion_duration
		ui.slowmotion_start(slowmotion_duration)
	if OS.is_debug_build() and event.is_action_released("fast_forward") and timescale == speedup:
		print("fast_forward release")
		timescale = 1
	if event.is_action_released("slow_motion") and slowmotion_pressed:
		print("slowmotion release")
		slowmotion_pressed = false
		ui.slowmotion_reset()
		if (timescale != 0):
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
	instance.global_position = rotation_stange.global_position + direction * 0.2
	
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
	if area.get_parent().has_method("on_hit"):
		area.get_parent().on_hit()
	EventBus.level_end.emit(false)
