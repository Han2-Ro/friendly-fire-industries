extends Node3D

@export var rotation_speed: float = 100.0
@export var rotation_speed_awake: float = 50.0
@export var tracking_distance: float = 10.0
@export var tracking_angle: float = 45.0
@export var death_timer: float = 3.0
var end_angle: float = 0.0
var player: Node3D
var barrel: Node3D
var targeting: bool = false

@onready var health_bar = $SubViewport/HealthBar3d
@onready var timer = $Timer
@onready var vision_cone = $TurretLowPoly/Cylinder/VisionCone
@onready var broken_turret = preload("res://scenes/turret_kaputt_model.tscn")
@onready var explodeparticle = preload("res://scenes/Particles/explosion.tscn")
@onready var muzzleflash = $TurretLowPoly/Cylinder/Muzzleflash
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var ray_cast_3d: RayCast3D = $TurretLowPoly/RayCast3D
@onready var turret_low_poly: Node3D = $TurretLowPoly


func _ready():
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	player = get_parent().find_child("Player")
	barrel = find_child("Cylinder", true, false)
	set_visioncone()
	#print("tracking_angle: ", tracking_angle)
	
	
func set_visioncone():
	vision_cone.scale = Vector3(tracking_distance * 2, tracking_distance * 2, 1)
	var cone_material = ShaderMaterial.new()
	cone_material.shader = load("res://shader/vision_cone.gdshader")
	vision_cone.material_override = cone_material
	
	cone_material.set_shader_parameter("cone_angle", tracking_angle)
	cone_material.set_shader_parameter("min_angle", end_angle)
	cone_material.set_shader_parameter("current_angle", tracking_angle * 2.0)
	
func _process(delta):
	
	if player == null or !target_player(delta):
		rotate_turret(barrel, delta)
		
	if timer.time_left > 0:
		health_bar.value = (1 - (timer.time_left / death_timer)) * 100
	
	update_vision_cone(delta)
	if is_instance_valid(player):
		var local_target = ray_cast_3d.to_local(player.global_position)
		ray_cast_3d.target_position = local_target
		ray_cast_3d.force_raycast_update()

# tries to track the player and returns false if the player is out of range
func target_player(delta) -> bool:
	var dir = player.global_position - global_position
	dir.y = 0
	var barrel_forward = -barrel.global_transform.basis.z.normalized()
	var angle = rad_to_deg(acos(barrel_forward.dot(dir.normalized())))
	#print(is_player_visible())
	if dir.length() <= tracking_distance and angle <= tracking_angle and is_player_visible(): # when player is in range and angle
		rotate_at_player(barrel, dir, delta)
		
		if not targeting: # start kill countdown
			start_countdown(death_timer)
			targeting = true
		return true
	else:
		if targeting:
			targeting = false
			stop_countdown()
		return false

func rotate_at_player(barrel, direction, delta):

	#barrel.look_at(global_position + direction, Vector3.UP)
	
	var target_rot = barrel.global_transform.looking_at(global_position + direction, Vector3.UP)
	var current_rot = barrel.global_transform
	
	var interpolated_rot = current_rot.interpolate_with(target_rot, rotation_speed_awake * delta)
	
	barrel.global_transform = interpolated_rot
	
func rotate_turret(barrel, delta):
	barrel.rotate_y(deg_to_rad(rotation_speed * delta))
	
func start_countdown(dt):
	timer.start(dt)
	health_bar.value = 0
	
func stop_countdown():
	timer.stop()
	
	
func _on_timer_timeout():
	shoot()

func shoot():
	if not targeting:
		return
	print("kill")
	muzzleflash.shoot()
	var recoil_distance = 0.2
	var recoil_duration = 0.05
	
	
	
	var instance = bullet_scene.instantiate()
	var direction =  -barrel.global_transform.basis.z.normalized()
	direction.y = 0
	direction = direction.normalized()
	instance.dir = direction
	instance.INH_MAX_BOUNCES = 0
	get_parent().get_parent().add_child(instance)
	instance.global_position = barrel.global_position + direction
	
	barrel.translate_object_local(Vector3(0, 0, recoil_distance))
	
	await get_tree().create_timer(recoil_duration).timeout
	
	barrel.translate_object_local(Vector3(0, 0, -recoil_distance))
	
func on_hit():
	stop_countdown()
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	explosion_instance.explode()
	
	var broken_turret_instance = broken_turret.instantiate()
	broken_turret_instance.global_transform = barrel.global_transform
	get_parent().add_child(broken_turret_instance)
	queue_free()
	
func update_vision_cone(delta: float):
	var material = vision_cone.material_override
	if targeting and timer.time_left > 0:
		var fraction = 1.0 - (timer.time_left / death_timer)
		var start_angle = tracking_angle * 2.0
		var new_angle = lerp(start_angle, end_angle, fraction)
		material.set_shader_parameter("current_angle", new_angle)
	else:
		material.set_shader_parameter("current_angle", tracking_angle * 2.0)

func is_player_visible() -> bool:
	if ray_cast_3d.is_colliding():
		var collider: Node3D = ray_cast_3d.get_collider()
		if collider:
			return collider.get_collision_layer_value(24)
		return false
	return false
