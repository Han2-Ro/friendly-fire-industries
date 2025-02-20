extends Node3D
class_name Mine

var target: Vector3
var speed: float
var distance: float
var incline: float
var x: float = 0
@onready var kill_area: Area3D = $KillArea
@onready var explodeparticle = preload("res://scenes/particles/explosion.tscn")

func _ready() -> void:
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
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	explosion_instance.explode()
	var bodies = kill_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("on_hit"):
			body.on_hit()
	queue_free()
