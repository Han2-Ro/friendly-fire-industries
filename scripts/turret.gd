extends Node3D

func _process(_delta):
	var player = get_parent().find_child("Player")
	var dir = player.global_position - global_position
	
	var barrel = find_child("Cylinder")
	barrel.look_at(global_position + dir, Vector3.UP)
