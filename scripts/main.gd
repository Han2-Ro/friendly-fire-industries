extends Node3D

@export var end_screen: Control
@onready var restart_button: Button
@export var levels: Array[PackedScene]
var current_level: Node
var paused := false
func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	EventBus.next_level.connect(_on_next_level_pressed)
	current_level = levels[GameState.current_level].instantiate()
	add_child(current_level)
	EventBus.level_end.connect(_on_level_end)
	if end_screen == null:
		printerr("No end screen")
		return
	end_screen.hide()
	restart_button = end_screen.find_child("RestartButton")
	#TODO: Unify button access
	if restart_button == null:
		printerr("No restart button")
		return
	restart_button.pressed.connect(_on_restart_pressed)
	end_screen.next_level_button.pressed.connect(_on_next_level_pressed)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_next_level_pressed() -> void:
	current_level.queue_free()
	GameState.current_level += 1
	if GameState.current_level >= levels.size():
		printerr("No more levels: Exiting")
		get_tree().quit()
		return
	current_level = levels[GameState.current_level].instantiate()
	add_child(current_level)
	end_screen.hide()

func _on_level_end(success: bool) -> void:
	print(success)
	end_screen.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Quit"):
		get_tree().quit()
	if event.is_action_pressed("Pause"):
		if paused:
			end_screen.hide()
			Engine.time_scale = 1
			paused = false
		else:
			end_screen.show()
			paused = true
			Engine.time_scale = 0
		
