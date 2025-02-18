extends Target
class_name Mine

var target: Node3D
var target_pos: Vector3
var speed: float
var distance: float
var incline: float
var x: float = 0

func _ready() -> void:
	target_pos = target.global_position
	distance = global_position.distance_to(target.global_position)
	move_mine(0.001)

func _process(delta: float) -> void:
	if position.y > 0:
		move_mine(delta)
	if position.y < 0:
		global_position = target.global_position

func move_mine(delta: float):
	var dir = (target.global_position - global_position)
	dir.y = 0
	dir = dir.normalized()
	x += speed * delta
	global_position += (dir * speed * delta)
	position.y = incline / distance * (x + 0.25) * (distance - x) # Parabolic formula

func on_hit():
	print("mine hit")
	queue_free()
