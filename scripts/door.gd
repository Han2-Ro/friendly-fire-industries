extends Node3D

var is_open: bool = false

func toggle_door() -> void:
	print("toggle door")
	if is_open:
		$AnimationPlayer.play_backwards("open_door")
	else:
		$AnimationPlayer.play("open_door")
	is_open = not is_open
