extends Node3D

func _ready() -> void:
	$Button.on_hit()
	$Button.on_hit()
	$Turret.on_hit()
	$Rocket.on_hit()
	$Rocket2.target = $Rocket2.global_position
