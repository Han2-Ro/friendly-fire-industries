extends CharacterBody3D

@export var speed = 5

@onready var explodeparticle = preload("res://characters/common/explosion.tscn")
@onready var kill_area: Area3D = $KillArea
@onready var drone_broken = preload("res://characters/enemies/drone/drone_broken.tscn")
var player: Node3D

func _ready() -> void:
	player = get_parent().find_child("Player")

func _physics_process(delta: float) -> void:
	if player != null:
		look_at(player.global_position, Vector3.UP)
		velocity = (player.global_position - global_position).normalized() * speed
		if global_position.distance_to(player.position) < 1.5:
			on_hit()
	move_and_slide()

func on_hit():
	var explosion_instance = explodeparticle.instantiate()
	explosion_instance.global_transform = self.global_transform
	get_parent().add_child(explosion_instance)
	explosion_instance.explode()

	var bodies = kill_area.get_overlapping_bodies()
	print(self, "destroying: ", bodies)
	for body in bodies:
		if body.has_method("on_hit"):
			get_tree().create_timer(.1).timeout.connect(body.on_hit)
	
	var broken_drone_instance = drone_broken.instantiate()
	broken_drone_instance.global_transform = self.global_transform
	get_parent().add_child(broken_drone_instance)
	
	queue_free()
