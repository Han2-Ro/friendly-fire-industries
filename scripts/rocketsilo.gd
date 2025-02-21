extends StaticBody3D

@export var explosive_speed: float = 10
@export var incline: float = 10
@export var targets: Array[Node3D]
@export var seconds_between_shots: float = 3
@export var seconds_being_open: float = 2

@onready var AnimPlayer = $AnimationPlayer
@onready var explodeparticle = preload("res://scenes/particles/explosion.tscn")
@onready var explosive_scene = preload("res://scenes/rocket.tscn")
@onready var  silo_broken = preload("res://scenes/rocket_silo_broken.tscn")
@export var seconds_before_first_shot: float = 2
@onready var launchsoundplayer: AudioStreamPlayer = $launchsoundplayer
var time_since_last_action: float = seconds_between_shots
var i_target: int = 0

var is_open: bool = false
var is_hitable: bool = false
var first_shot: bool = true

func _physics_process(delta: float) -> void:
	time_since_last_action += delta
	
	if is_open and time_since_last_action >= seconds_being_open:
		AnimPlayer.play("Close")
		time_since_last_action = 0
	elif !is_open:
		var wait_time: float = 0
		if first_shot:
			wait_time = seconds_before_first_shot
		else:
			wait_time = seconds_between_shots
		if time_since_last_action >= wait_time:
			AnimPlayer.play("Open")
			time_since_last_action = 0
			
			set_hitable(true)


func launch_explosive():
	if targets.size() == 0:
		printerr(self.name + " in " + get_parent().name + ": No targets.")
		return
	var explosive = explosive_scene.instantiate()
	explosive.target = targets[i_target].global_position
	explosive.speed = explosive_speed
	explosive.incline = incline
	explosive.set_transform(get_transform())
	get_parent().add_child(explosive)
	# cycle targets
	i_target = (i_target + 1) % targets.size()
	launchsoundplayer.play()

func set_hitable(new_hitable: bool):
	is_hitable = new_hitable
	
	# toggle wether to bounce or stop the bullet
	#set_collision_layer_value(1, !is_hitable)
	#set_collision_layer_value(2, is_hitable)

func on_hit():
	if is_hitable:
		print("explosive thrower hit")
		var broken_silo_instance = silo_broken.instantiate()
		broken_silo_instance.global_transform = self.global_transform
		get_parent().add_child(broken_silo_instance)
		
		var explosion_instance = explodeparticle.instantiate()
		explosion_instance.global_transform = self.global_transform
		get_parent().add_child(explosion_instance)
		explosion_instance.explode()
	
		queue_free()
	else:
		print("explosive thrower blocked")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Open":
		launch_explosive()
		is_open = true
		time_since_last_action = 0
		first_shot = false
	else:
		is_open = false
		set_hitable(false)
		time_since_last_action = 0
