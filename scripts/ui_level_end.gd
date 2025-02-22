extends Control

@export var status_label: Label
@export var next_level_button: Button

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
