extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(on_entered)

func on_entered(area: Area3D) -> void:
	if area.is_in_group("mine"):
		EventBus.level_end.emit(false)
