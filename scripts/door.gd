extends Node3D

@export var color: Color = Color.RED

@onready var laser_bars = $"Laser-Bars"
@onready var bullet_collision: StaticBody3D = $StaticBody3D
@onready var player_collision: Area3D = $"Player-Area3D"

var is_open: bool = false

func _ready() -> void:
	# set color
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission_energy_multiplier = 7
	mat.emission = color
	
	$"Laser-Emitters/LaserEmitters-Far/LaserEmittersColor".material_override = mat
	$"Laser-Emitters/LaserEmitters-Near/LaserEmittersColor".material_override = mat
	$"Laser-Bars/Top".material_override = mat
	$"Laser-Bars/Mid".material_override = mat
	$"Laser-Bars/Bot".material_override = mat

func toggle_door() -> void:
	print("toggle laser-door")
	
	if is_open:
		laser_bars.visible = true
		bullet_collision.disabled = false
		player_collision.disabled = false
	else:
		laser_bars.visible = false
		bullet_collision.disabled = true
		player_collision.disabled = true
	is_open = not is_open

#func toggle_door() -> void:
	#print("toggle door")
	#if is_open:
		#$AnimationPlayer.play_backwards("open_door")
	#else:
		#$AnimationPlayer.play("open_door")
	#is_open = not is_open
