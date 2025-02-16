extends MeshInstance3D
class_name Target

var in_ray: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and in_ray:
		on_hit()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("ray"):
		in_ray = true


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("ray"):
		in_ray = false

func on_hit():
	print("target hited")
