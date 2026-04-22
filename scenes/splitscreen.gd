extends Control

var viweport_scene:PackedScene = preload("res://scenes/splitscreen_viewport.tscn")
var cameras:Array
var camera_positions:Array

func add_camera(nodeToFollow:Node3D) -> void:
	var instance = viweport_scene.instantiate();
	cameras.append(instance.get_child(0).get_child(0));
	camera_positions.append(nodeToFollow);
	
	$Grid.add_child(instance);
	update_splitscreen();
	
func update_splitscreen() -> void:
	var numViewports = len(cameras)
	if numViewports == 1:
		$Grid.columns = 1
	else:
		$Grid.columns = 2

func _process(delta: float) -> void:
	for i in range(len(cameras)):
		cameras[i].position = camera_positions[i].position
		cameras[i].rotation = camera_positions[i].rotation
