extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.current_level = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu/main_menu.tscn")
