extends Node3D
class_name Mine

var target: Node3D
var speed: float
var distance: float
var incline: float
var x: float = 0

func _ready() -> void:
	distance = global_position.distance_to(target.global_position)
	move_mine(0.01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	translate(dir * speed * delta)
	position.y = incline / distance * x * (distance - x) # Parabolic formula
