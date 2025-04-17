extends Node3D

func on_hit():
	get_parent().on_hit()
