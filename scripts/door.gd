extends Node3D

@onready var coll = $Area3D/CollisionShape3D

var is_open: bool = false

func toggle_door() -> void:
	print("toggle laser-door")
	# ToDo hide lasers
	if is_open:
		coll.disabled = true
	else:
		coll.disabled = false
	is_open = not is_open

#func toggle_door() -> void:
	#print("toggle door")
	#if is_open:
		#$AnimationPlayer.play_backwards("open_door")
	#else:
		#$AnimationPlayer.play("open_door")
	#is_open = not is_open
