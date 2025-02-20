extends Control
class_name UIPlayer

@export var ammo_available_icon: Texture2D
@export var ammo_unavailable_icon: Texture2D
@export var icon_offset: int = 50
var max_ammo: int = 6
@onready var slowmotion_bar: Panel = $SlowMotion
var bar_width: float
var bar_pos_x: float
var duration: float = 2
@onready var ammo_icons: Array[TextureRect] = [$BulletIcon]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bar_width = size.x
	bar_pos_x = position.x
	slowmotion_bar.size.x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (slowmotion_bar.size.x > 0):
		slowmotion_bar.size.x -= delta * bar_width / duration / Engine.time_scale
		slowmotion_bar.position.x += delta * bar_width / duration / Engine.time_scale / 2

func slowmotion_reset():
	slowmotion_bar.size.x = 0

func slowmotion_start(duration: float = 2):
	slowmotion_bar.size.x = bar_width
	slowmotion_bar.position.x = bar_pos_x
	self.duration = duration

func setup_ammo(n: int) -> void:
	max_ammo = n
	for i in range(1, n):
		ammo_icons.append(ammo_icons[0].duplicate())
		ammo_icons[i].global_position.y += i * -icon_offset
		add_child(ammo_icons[i])

func update_ammo(new_ammo: int) -> void:
	print("update_ammo: ", new_ammo)
	for i in range(0, new_ammo):
		ammo_icons[i].texture = ammo_available_icon
	for i in range(new_ammo, max_ammo):
		ammo_icons[i].texture = ammo_unavailable_icon
