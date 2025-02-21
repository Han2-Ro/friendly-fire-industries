extends Node3D
class_name Rocket

@onready var kill_area: Area3D = $KillArea
@onready var explodeparticle = preload("res://scenes/particles/explosion.tscn")
@onready var model = $Rocket
@onready var particles = $FireParticles

var target: Vector3 = global_position
var speed: float
var distance: float
var incline: float
var x: float = 0
var radius_visible: bool = false

var old_pos: Vector3

func _ready() -> void:
	old_pos = global_position
	distance = global_position.distance_to(target)
	move(0.001)

func _process(delta: float) -> void:
	if position.y > 0:
		move(delta)
	if position.y <= 0 and not radius_visible:
		print("showing radius")
		radius_visible = true
		$AnimationPlayer.play("show_radius")
	if position.y < 0:
		particles.amount_ratio = .15
		global_position = target
		#rotation_degrees.x = -90

func move(delta: float):
	var dir = (target - global_position)
	dir.y = 0
	dir = dir.normalized()
	x += speed * delta
	global_position += (dir * speed * delta)
	position.y = incline / distance * (x + 0.25) * (distance - x) # Parabolic formula
	
	#rotate
	var flight_dir = (global_position - old_pos).normalized()
	var at = global_position + flight_dir
	if (at.dot(Vector3.UP) > 0.001) or position == at:
		look_at(at, Vector3.UP, 0)
	old_pos = global_position

func on_hit():
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	explosion_instance.explode()
	var bodies = kill_area.get_overlapping_bodies()
	print(self, "destroying: ", bodies)
	for body in bodies:
		if body.has_method("on_hit"):
			if body == self:
				print("skipping self")
				continue
			print("destroying frfr: ", body)
			get_tree().create_timer(.15).timeout.connect(body.on_hit)
	queue_free()
