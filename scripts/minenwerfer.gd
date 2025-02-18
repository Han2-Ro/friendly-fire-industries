extends Node3D

@export var mine_scene: PackedScene
@export var speed: float = 10
var distance: float = 5
var incline: float = 1
var mine: Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		launch_mine()

func _physics_process(delta: float) -> void:
	if mine != null and mine.position.x < distance:
		mine.position.x += speed * delta
		mine.position.y = incline / distance * mine.position.x * (distance - mine.position.x) # Parabolic formula
	elif mine != null:
		mine = null

func launch_mine():
	mine = mine_scene.instantiate()
	mine.global_position = global_position
	add_child(mine)
