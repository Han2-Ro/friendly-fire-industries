extends Target

@export var rotation_speed: float = 100.0
@export var rotation_speed_awake: float = 50.0
@export var tracking_distance: float = 10.0
@export var tracking_angle: float = 45.0
@export var death_timer: float = 3

var player: Node3D
var barrel: Node3D
var targeting: bool = false

@onready var health_bar = $SubViewport/HealthBar3d
@onready var timer = $Timer

func _ready():
	super._ready()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	player = get_parent().find_child("Player")
	barrel = find_child("Cylinder")
	

func _process(delta):
	if player == null or !target_player(delta):
		rotate_turret(barrel, delta)
		
	if timer.time_left > 0:
		health_bar.value = (1 - (timer.time_left / death_timer)) * 100


# tries to track the player and returns false if the player is out of range
func target_player(delta) -> bool:
	var dir = player.global_position - global_position
	dir.y = 0
	var barrel_forward = -barrel.global_transform.basis.z.normalized()
	var angle = rad_to_deg(acos(barrel_forward.dot(dir.normalized())))
		
	if dir.length() <= tracking_distance and angle <= tracking_angle: # when player is in range and angle
		rotate_at_player(barrel, dir, delta)
		
		if targeting == false: # start kill countdown
			start_countdown(death_timer)
			targeting = true
		return true
	else:
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
	print("kill")
	EventBus.player_killed.emit()
	
func on_hit():
	stop_countdown()
	queue_free()
