extends Node3D

@export var end_screen: Control
@onready var restart_button: Button
@export var levels: Array[PackedScene]

var current_level: Node
var paused := false
var has_level_ended: bool = false

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
	
	end_screen.menu_button.pressed.connect(_on_menu_button_pressed)

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu/main_menu.tscn")
	#set_paused(false)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	set_paused(false)

func _on_next_level_pressed() -> void:
	current_level.queue_free()
	GameState.current_level += 1
	
	# Start playing Music in First Level after Intro
	# TODO: don't hard code
	if GameState.current_level == 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false) # if player presses start to quickly
		GlobalPlayer.play_music_level()

	if GameState.current_level >= levels.size():
		printerr("No more levels: Exiting")
		get_tree().quit()
		return
	current_level = levels[GameState.current_level].instantiate()
	add_child(current_level)
	
	has_level_ended = false
	end_screen.hide()

func _on_level_end(success: bool) -> void:
	print(success)
	has_level_ended = true
	end_screen.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Quit"):
		get_tree().quit()
	
	if not has_level_ended and event.is_action_pressed("Pause"):
		if paused:
			print("unpause")
			end_screen.hide()
			set_paused(false)
		else:
			print("pause")
			end_screen.reset()
			end_screen.show()
			set_paused(true)

func set_paused(is_paused: bool) -> void:
	Engine.time_scale = not is_paused
	paused = is_paused

func reset_game():
	pass
