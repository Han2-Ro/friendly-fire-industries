extends StaticBody3D

@export var color: Color = Color.RED

signal button_hit

func _ready() -> void:
	# set color
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission = color
	
	$MeshInstance3D.material_override = mat

func on_hit():
	print("button hit")
	button_hit.emit()
