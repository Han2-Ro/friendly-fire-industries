extends Node3D

func _ready() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, true)
	
	$Button.on_hit()
	$Button.on_hit()
	$Turret.on_hit()
	$Rocket.on_hit()
	
	await get_tree().create_timer(1.2).timeout
	AudioServer.set_bus_mute(master_bus, false)
