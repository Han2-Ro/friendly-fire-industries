extends Node3D
class_name Target

var in_ray: bool
var area: Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area = find_child("Area3D") as Area3D
	print(area)
	area.area_entered.connect(_on_area_3d_area_entered)
	area.area_exited.connect(_on_area_3d_area_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and in_ray:
		on_hit()

func _on_area_3d_area_entered(area: Area3D) -> void:
	print("area entered")
	if area.is_in_group("ray"):
		in_ray = true


func _on_area_3d_area_exited(area: Area3D) -> void:
	print("area exited")
	if area.is_in_group("ray"):
		in_ray = false

func on_hit():
	print("target hited")
