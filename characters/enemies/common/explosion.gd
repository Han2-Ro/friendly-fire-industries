extends Node3D


@onready var debris: GPUParticles3D = $Debris
@onready var fire: GPUParticles3D = $Fire
@onready var smoke: GPUParticles3D = $Smoke
@onready var explosion_sound: AudioStreamPlayer3D = $ExplosionSound

func explode():
	debris.emitting = true
	fire.emitting = true
	smoke.emitting = true
	explosion_sound.play()
