extends Control

@onready var hover_audio_player: AudioStreamPlayer = $HoverAudioPlayer
@onready var click_audio_player: AudioStreamPlayer = $ClickAudioPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.current_level = 0

func _on_main_menu_button_pressed() -> void:
	play_on_mouse_click()
	get_tree().change_scene_to_file("res://scenes/levels/main_menu/main_menu.tscn")

func play_on_mouse_entered() -> void:
	hover_audio_player.play()
	
func play_on_mouse_click() -> void:
	click_audio_player.play()
