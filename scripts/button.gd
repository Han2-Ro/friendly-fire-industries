extends StaticBody3D

@export var color: Color = Color.RED

var mat: StandardMaterial3D

signal button_hit

func _ready() -> void:
	# set color
	mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission = color
	
	$Button/ButtonSwitch.material_override = mat

func on_hit():
	print("button hit")
	$AnimationPlayer.play("Press")
	mat.emission_enabled = !mat.emission_enabled
	button_hit.emit()
