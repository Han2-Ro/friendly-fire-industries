extends Control
@onready var main_menu_ui: Control = $"../MainMenuUi"
@onready var options_menu: Control = $"."

var master_bus = AudioServer.get_bus_index("Master")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(master_bus, GameState.global_volume)
	$VBoxContainer/Volume.set_value_no_signal(GameState.global_volume)
	$VBoxContainer/Fullscreen.set_pressed_no_signal(GameState.fullscreen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus,value)
	GameState.global_volume = value
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus,true)
	else:
		AudioServer.set_bus_mute(master_bus,false)


func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(3840,2160))
		1:
			DisplayServer.window_set_size(Vector2i(2560,1440))
		2:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		3:
			DisplayServer.window_set_size(Vector2i(1600,900))
		4:
			DisplayServer.window_set_size(Vector2i(1280,720))


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	GameState.fullscreen = toggled_on
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
