extends CharacterBody3D

@export var speed = 50
@export var INH_MAX_BOUNCES = 3

var dir: Vector3
var bounce_count: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("new bullet")
	bounce_count = 0
	look_at(get_lookat_point(), Vector3.UP, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# remove offscreen
	if (abs(global_position.x) > 100  or abs(global_position.z) > 100):
		queue_free()
	
	var coll = move_and_collide(dir * speed * delta)
	if coll:
		#print("bounce")
		# check if object is affected by bullet
		if coll.get_collider().has_method("on_hit"):
			coll.get_collider().on_hit()
		
		# bounce or stop
		bounce_count += 1
		if bounce_count > INH_MAX_BOUNCES:
			queue_free()
		
		if is_collider_bouncy(coll.get_collider()):
			var norm = coll.get_normal()
			dir = dir.bounce(norm).normalized()                                   
			
			global_position = coll.get_position()
			
			look_at(get_lookat_point(), Vector3.UP, 0)
		else:
			queue_free()



func get_lookat_point() -> Vector3:
	return global_position + Vector3(dir.x, 0, dir.z)

func is_collider_bouncy(collider: Node3D) -> bool:
	if (collider.has_method("get_collision_layer_value")):
		return collider.get_collision_layer_value(1) and not collider.get_collision_layer_value(2)
	else:
		return false
