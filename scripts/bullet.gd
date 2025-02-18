extends CharacterBody3D

@export var speed = 50
@export var MAX_BOUNCES = 100

var dir: Vector3
var bounce_count: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bounce_count = 0
	
	look_at(get_lookat_point(), Vector3.UP, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# remove offscreen
	if (abs(global_position.x) > 100  or abs(global_position.z) > 100 or bounce_count > MAX_BOUNCES):
		queue_free()
	
	var coll = move_and_collide(dir * speed * delta)
	if coll:
		dir = dir.bounce(coll.get_normal()).normalized()
		
		look_at(get_lookat_point(), Vector3.UP, 0)
	
	#print(dir)

func get_lookat_point() -> Vector3:
	return global_position + Vector3(dir.x, 0, dir.z)
