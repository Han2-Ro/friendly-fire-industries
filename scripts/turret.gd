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

func _ready():
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	player = get_parent().find_child("Player")
	barrel = find_child("Cylinder", true, false)
	vision_cone.scale = Vector3(tracking_distance * 2, tracking_distance * 2, 1)
	var cone_material = ShaderMaterial.new()
	cone_material.shader = load("res://shader/vision_cone.gdshader")
	vision_cone.material_override = cone_material
	
	cone_material.set_shader_parameter("cone_angle", tracking_angle)
	cone_material.set_shader_parameter("min_angle", end_angle)
	cone_material.set_shader_parameter("current_angle", tracking_angle)
	print("tracking_angle: ", tracking_angle)

func _process(delta):
	if player == null or !target_player(delta):
		rotate_turret(barrel, delta)
		
	if timer.time_left > 0:
		health_bar.value = (1 - (timer.time_left / death_timer)) * 100
	
	if targeting and timer.time_left > 0:
		# Wie viel vom Timer ist schon abgelaufen?
		var fraction = 1.0 - (timer.time_left / death_timer)
		
		# Zwischen Startwinkel (tracking_angle * 2) und Minwinkel (z.B. 5.0) interpolieren
		var start_angle = tracking_angle * 2.0
		
		var new_angle = lerp(start_angle, end_angle, fraction)
		
		# Shader updaten
		var mat = vision_cone.material_override
		if mat:
			mat.set_shader_parameter("current_angle", new_angle)
	else:
		# Falls der Timer abgelaufen ist oder wir gerade nicht targeten:
		# Winkel wieder auf Standard zurücksetzen
		if not targeting:
			var mat2 = vision_cone.material_override
			if mat2:
				mat2.set_shader_parameter("current_angle", tracking_angle * 2.0)


# tries to track the player and returns false if the player is out of range
func target_player(delta) -> bool:
	var dir = player.global_position - global_position
	dir.y = 0
	var barrel_forward = -barrel.global_transform.basis.z.normalized()
	var angle = rad_to_deg(acos(barrel_forward.dot(dir.normalized())))
		
	if dir.length() <= tracking_distance and angle <= tracking_angle: # when player is in range and angle
		rotate_at_player(barrel, dir, delta)
		update_vision_cone(true, delta)
		if targeting == false: # start kill countdown
			start_countdown(death_timer)
			targeting = true
		return true
	else:
		if targeting:
			targeting = false
		update_vision_cone(false, delta) # Neue Zeile
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
	#EventBus.level_end.emit(false)
	
func shoot():
	print("kill")
	muzzleflash.shoot()
	var recoil_distance = 0.2
	var recoil_duration = 0.05
	
	barrel.translate_object_local(Vector3(0, 0, recoil_distance))
	
	await get_tree().create_timer(recoil_duration).timeout
	
	barrel.translate_object_local(Vector3(0, 0, -recoil_distance))
	
	var instance = bullet_scene.instantiate()
	var direction =  -barrel.global_transform.basis.z.normalized()
	direction.y = 0
	direction = direction.normalized()
	instance.dir = direction
	instance.INH_MAX_BOUNCES = 0
	get_parent().get_parent().add_child(instance)
	instance.global_position = barrel.global_position + direction
	
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
	
func update_vision_cone(player_detected: bool, delta: float):
	var material = vision_cone.material_override
	var current_angle = material.get_shader_parameter("current_angle")
	
	if player_detected:
		# Verkleinere den Winkel wenn Spieler erkannt
		current_angle = move_toward(current_angle, 10.0, delta * 90.0)
	else:
		# Setze den Winkel zurück
		current_angle = move_toward(current_angle, tracking_angle, delta * 90.0)
	
	material.set_shader_parameter("current_angle", current_angle)
