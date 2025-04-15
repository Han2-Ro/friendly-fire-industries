extends Control

@onready var options_menu: Control = $"../OptionsMenu"
@onready var main_menu_ui: Control = $"."
@onready var hover_audio_player: AudioStreamPlayer = $HoverAudioPlayer
@onready var click_audio_player: AudioStreamPlayer = $ClickAudioPlayer
@onready var continue_button: Button = $VBoxContainer/continue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_ui.visible = true
	options_menu.visible = true
	continue_button.visible = GameState.current_level != 0
	GlobalPlayer.stop()

func _on_start_pressed() -> void:
	play_on_mouse_click()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	GameState.current_level = 0

func _on_options_pressed() -> void:
	play_on_mouse_click()
	if options_menu.visible:
		options_menu.visible = false
	else:
		options_menu.visible = true
	

func _on_quit_pressed() -> void:
	play_on_mouse_click()
	get_tree().quit()


func _on_options_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#options_menu.visible = true
		#
	#else:
		#options_menu.visible = false
	pass

func play_on_mouse_entered() -> void:
	hover_audio_player.play()
	
func play_on_mouse_click() -> void:
	click_audio_player.play()


func _on_continue_pressed() -> void:
	play_on_mouse_click()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
