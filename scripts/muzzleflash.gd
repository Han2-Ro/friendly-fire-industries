extends Node3D


@onready var debris_mf: GPUParticles3D = $DebrisMF
@onready var fire_mf: GPUParticles3D = $FireMF
@onready var shot_sound: AudioStreamPlayer3D = $shotSound



func shoot():
	debris_mf.emitting = true
	fire_mf.emitting = true
	shot_sound.play()
	await get_tree().create_timer(2.0).timeout
