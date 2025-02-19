extends StaticBody3D

signal button_hit

func on_hit():
	print("button hit")
	button_hit.emit()
