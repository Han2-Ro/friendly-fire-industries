extends Node3D

var is_open: bool = false

func open_door() -> void:
	if is_open:
		return
	$AnimationPlayer.play("open_door")
	is_open = true
