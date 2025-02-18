extends Node3D

@export var mine_scene: PackedScene
@export var mine_speed: float = 10
@export var incline: float = 1
@export var targets: Array[Node3D]
@export var seconds_between_shots: float = 3
var time_since_last_shot: float = 0
var i_target: int = 0

func _physics_process(delta: float) -> void:
	time_since_last_shot += delta
	if time_since_last_shot >= seconds_between_shots:
		launch_mine()
		time_since_last_shot = 0

func launch_mine():
	print("minenwerfer:", global_position)
	if targets.size() == 0:
		printerr("Minenwerfer: No targets.")
		return
	var mine := mine_scene.instantiate() as Mine
	mine.target = targets[i_target]
	mine.speed = mine_speed
	mine.incline = incline
	add_child(mine)
	i_target += 1
	if i_target >= targets.size():
		i_target = 0
