extends Control
class_name UIPlayer

@export var ammo_available_icon: Texture2D
@export var ammo_unavailable_icon: Texture2D
@export var time_available_icon: Texture2D
@export var time_unavailable_icon: Texture2D
@export var icon_offset: int = 50
@onready var slowmotion_bar: Panel = $SlowMotion
var bar_width: float
var bar_pos_x: float
var duration: float = 2
@onready var ammo_icons: Array[TextureRect] = [$BulletIcon]
@onready var time_icons: Array[TextureRect] = [$TimeIcon]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bar_width = slowmotion_bar.size.x
	bar_pos_x = slowmotion_bar.position.x
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
	setup_display(n, ammo_icons)

func update_ammo(n: int) -> void:
	update_display(n, ammo_icons, ammo_available_icon, ammo_unavailable_icon)

func setup_time(n: int) -> void:
	setup_display(n, time_icons)

func update_time(n: int) -> void:
	update_display(n, time_icons, time_available_icon, time_unavailable_icon)

func setup_display(n: int, array: Array[TextureRect]) -> void:
	for i in range(1, n):
		array.append(array[0].duplicate())
		array[i].global_position.y += i * -icon_offset
		add_child(array[i])

func update_display(new_ammo: int, array: Array[TextureRect], available_icon: Texture2D, unavailable_icon: Texture2D) -> void:
	print("update_display: ", new_ammo)
	for i in range(0, new_ammo):
		array[i].texture = available_icon
	for i in range(new_ammo, array.size()):
		array[i].texture = unavailable_icon
