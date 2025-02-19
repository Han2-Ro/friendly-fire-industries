extends Control

var max_ammo: int = 5
@export var ammo_available_icon: Texture2D
@export var ammo_unavailable_icon: Texture2D
@export var icon_offset: int = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.ammo_changed.connect(update_ammo)
	var ammo_icon: TextureRect = $BulletIcon
	for i in range(1, max_ammo):
		print(i)
		var new_ammo: TextureRect = ammo_icon.duplicate()
		new_ammo.global_position.y += i * -icon_offset
		add_child(new_ammo)

func update_ammo(new_ammo: int) -> void:
	for child in get_children():
		if child is TextureRect:
			if child.get_index() < new_ammo:
				child.texture = ammo_available_icon
			else:
				child.texture = ammo_unavailable_icon