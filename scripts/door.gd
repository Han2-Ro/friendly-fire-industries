extends Node3D

@export var color: Color = Color.RED

var is_open: bool = false

func _ready() -> void:
	# set color
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission_energy_multiplier = 5
	mat.emission = color
	
	$"Laser-Emitters/LaserEmitters-Far/LaserEmittersColor".material_override = mat
	$"Laser-Emitters/LaserEmitters-Near/LaserEmittersColor".material_override = mat
	$"Laser-Bars/Top".material_override = mat
	$"Laser-Bars/Mid".material_override = mat
	$"Laser-Bars/Bot".material_override = mat

func toggle_door() -> void:
	print("toggle laser-door")
	
	var coll = $Area3D/CollisionShape3D
	if is_open:
		$"Laser-Bars".visible = true
		coll.disabled = false
	else:
		$"Laser-Bars".visible = false
		coll.disabled = true
	is_open = not is_open

#func toggle_door() -> void:
	#print("toggle door")
	#if is_open:
		#$AnimationPlayer.play_backwards("open_door")
	#else:
		#$AnimationPlayer.play("open_door")
	#is_open = not is_open
