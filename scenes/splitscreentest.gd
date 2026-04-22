extends Node3D

func _ready() -> void:
	$Splitscreen.add_camera($first)
	$Splitscreen.add_camera($second)
	$Splitscreen.add_camera($third)
