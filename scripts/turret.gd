extends Node3D

@export var rotation_speed: float = 100.0
@export var rotation_speed_awake : float = 50.0
@export var tracking_distance: float = 10.0
@export var tracking_angle: float = 45.0

var rotating: bool = true

func _process(delta):
	var player = get_parent().find_child("Player")	
	var barrel = find_child("Cylinder")
	
	var dir = player.global_position - global_position
	var barrel_forward = -barrel.global_transform.basis.z.normalized()
	var angle = rad_to_deg(acos(barrel_forward.dot(dir.normalized())))
		
	if dir.length() <= tracking_distance and angle <= tracking_angle: #when player is in range and angle
		rotating = false
		track_player(barrel, dir, delta)
	else:
		rotating = true
		
	if rotating:
		rotate_turret(barrel, delta)
func track_player(barrel, direction, delta):
	
	#barrel.look_at(global_position + direction, Vector3.UP)
	
	var target_rot = barrel.global_transform.looking_at(global_position + direction, Vector3.UP)
	var current_rot = barrel.global_transform 
	
	var interpolated_rot = current_rot.interpolate_with(target_rot, rotation_speed_awake * delta)
	
	barrel.global_transform = interpolated_rot
	
func rotate_turret(barrel, delta):
	barrel.rotate_y(deg_to_rad(rotation_speed * delta))
