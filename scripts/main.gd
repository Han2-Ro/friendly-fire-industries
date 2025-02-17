extends Node3D

@export var endScreen: Control
@onready var restartButton: Button

func _ready() -> void:
	EventBus.player_finished.connect(_on_player_finished)
	EventBus.player_killed.connect(_on_player_killed)
	if endScreen == null:
		printerr("No end screen")
		return
	restartButton = endScreen.find_child("RestartButton")
	if restartButton == null:
		printerr("No restart button")
		return
	restartButton.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_player_finished() -> void:
	endScreen.show()

func _on_player_killed() -> void:
	endScreen.show()
