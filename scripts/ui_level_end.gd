extends Control

@export var status_label: Label
@export var next_level_button: Button
@onready var hover_audio_player: AudioStreamPlayer = $HoverAudioPlayer
@onready var click_audio_player: AudioStreamPlayer = $ClickAudioPlayer

@onready var menu_button: Button = $MenuButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.level_end.connect(_on_level_end)
	reset()


func _on_level_end(success: bool) -> void:
	if status_label != null:
		status_label.text = "Success" if success else "Fail"
	if next_level_button != null:
		next_level_button.visible = success

func reset():
	next_level_button.visible = false
	status_label.text = "In Progress"

func _on_visibility_changed() -> void:
	var hint: Panel = get_tree().root.find_child("UiHint", true, false)
	if hint:
		if visible:
			hint.hide()
		else:
			hint.show()
	
func play_on_mouse_entered() -> void:
	hover_audio_player.play()
	
func play_on_mouse_click() -> void:
	click_audio_player.play()
