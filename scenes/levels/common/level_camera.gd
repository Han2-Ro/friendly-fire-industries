extends Camera3D

func _ready() -> void:
	if OS.get_name() == "Web":
		$DirectionalLight3D.light_energy = 0.2
