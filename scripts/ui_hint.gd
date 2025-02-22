extends Panel

@export_range(1, 3) var hint_status_level: int = 1

func _ready() -> void:
	if GameState.hint_status < hint_status_level:
		GameState.hint_status = hint_status_level
		EventBus.hint_status_changed.emit()
