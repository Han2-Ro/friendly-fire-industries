extends StaticBody3D

@export var color: Color = Color.RED

@export var sound_muted: bool = false

var mat: StandardMaterial3D
var is_enabled: bool

signal button_hit

func _ready() -> void:
	# set color
	mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission = color
	mat.emission_energy_multiplier = 8
	$Button/ButtonSwitch.material_override = mat
	
	if sound_muted:
		$Sounds/NoAccessSound.volume_db = -100
		$Sounds/AccessSound.volume_db = -100

func on_hit():
	print("button hit")
	$AnimationPlayer.play("Press")
	is_enabled = !is_enabled
	mat.emission_enabled = is_enabled
	if is_enabled:
		$Sounds/AccessSound.play()
	else:
		$Sounds/NoAccessSound.play()
	
	button_hit.emit()
