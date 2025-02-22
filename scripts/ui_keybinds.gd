extends Control

@onready var slowmo: RichTextLabel = $Slowmo
@onready var reset: RichTextLabel = $Reset

func _ready() -> void:
	EventBus.hint_status_changed.connect(_on_hint_status_changed)
	_on_hint_status_changed()

func _on_hint_status_changed() ->void:
	var hint_status = GameState.hint_status
	
	if hint_status > 1:
		slowmo.show()
	if hint_status > 2:
		reset.show()
