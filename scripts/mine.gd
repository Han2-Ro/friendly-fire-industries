extends Node3D
class_name Mine

var target: Vector3
var speed: float
var distance: float
var incline: float
var x: float = 0
@onready var explodeparticle = preload("res://scenes/Particles/explosion.tscn")

func _ready() -> void:
	print("mine ready")
	distance = global_position.distance_to(target)
	move_mine(0.001)

func _process(delta: float) -> void:
	if position.y > 0:
		move_mine(delta)
	if position.y < 0:
		global_position = target

func move_mine(delta: float):
	var dir = (target - global_position)
	dir.y = 0
	dir = dir.normalized()
	x += speed * delta
	global_position += (dir * speed * delta)
	position.y = incline / distance * (x + 0.25) * (distance - x) # Parabolic formula

func on_hit():
	print("mine hit")
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	explosion_instance.explode()
	queue_free()
