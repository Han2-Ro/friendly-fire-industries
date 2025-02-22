extends CharacterBody3D
class_name Rocket

@export var sound_muted: bool = false

@onready var kill_area: Area3D = $KillArea
@onready var explodeparticle = preload("res://scenes/particles/explosion.tscn")
@onready var model = $Rocket
@onready var particles = $FireParticles
@onready var audio_flight: AudioStreamPlayer  = $Flight
@onready var audio_landing: AudioStreamPlayer = $Landing

var target: Vector3
var speed: float
var distance: float
var incline: float
var x: float = 0
var already_landed: bool = false

var old_pos: Vector3

func _ready() -> void:
	old_pos = global_position
	distance = global_position.distance_to(target)
	move(0.001)
	
	if sound_muted:
		audio_flight.volume_db = -100
		audio_landing.volume_db = -100

func _process(delta: float) -> void:
	if position.y > target.y:
		move(delta)
	
	if position.y <= target.y and not already_landed:
		already_landed = true
		
		print("showing radius")
		$AnimationPlayer.play("show_radius")
		
		audio_flight.stop()
		audio_landing.play()
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
	if (at.dot(Vector3.UP) > 0.001) and old_pos != at:
		look_at(at, Vector3.UP, 0)
	old_pos = global_position

func on_hit():
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	if sound_muted:
		explosion_instance.find_child("ExplosionSound").volume_db = -100
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
