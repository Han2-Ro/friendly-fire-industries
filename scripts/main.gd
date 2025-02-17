extends Node3D

@export var endScreen: Control
@onready var restartButton: Button

func _ready() -> void:
	EventBus.level_end.connect(_on_level_end)
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

func _on_level_end(success: bool) -> void:
	print(success)
	endScreen.show()
