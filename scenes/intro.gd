extends Control

@onready var hover_player: AudioStreamPlayer = $hoverPlayer
@onready var click_player: AudioStreamPlayer = $clickPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("textanim")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false) # if player presses start to quickly
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	click_player.play()
	EventBus.next_level.emit()


func _on_button_mouse_entered() -> void:
	hover_player.play()
