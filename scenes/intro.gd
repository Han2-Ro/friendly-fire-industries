extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false) # if player presses start to quickly
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	EventBus.next_level.emit()
