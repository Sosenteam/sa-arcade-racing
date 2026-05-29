extends Node3D

@export var car_controller:PackedScene
@export var car_camera:PackedScene
@export var car_sounds:PackedScene
@export var lap_counter:PackedScene

@onready var checkpoints_parent:Node3D = $sa.get_node("checkpoints")
var player_checkpoints:Dictionary[StringName, int];
var player_laps:Dictionary[StringName, int];
var highest_checkpoint:int = 0;
var laps_to_finish = 3;

func _ready() -> void:
	race_init([PlayerRaceData.new("Poop", 7)])
	
	var checkpoints = checkpoints_parent.get_children()
	var idx = 1;
	for checkpoint:Area3D in checkpoints:
		checkpoint.name = str(idx)
		checkpoint.body_entered.connect(hit_checkpoint.bind(checkpoint))
		idx+=1
	highest_checkpoint = idx - 1

func race_init(player_data:Array[PlayerRaceData]):
	for i in range(len(player_data)):
		var spawned_car = Cars.all_cars[player_data[i].car_id].instantiate()
		var spawned_camera:CarCamera = car_camera.instantiate()
		var spawned_soundplayer = car_sounds.instantiate()
		var spawned_lapcounter = lap_counter.instantiate()
		
		spawned_car.add_child(spawned_soundplayer);
		add_child(spawned_car)
		spawned_car.add_child(spawned_camera)
		spawned_car.get_node("CarController").player_name = player_data[i].player_name
		player_checkpoints[player_data[i].player_name] = 1
		player_laps[player_data[i].player_name] = 1
		
		$Splitscreen.add_camera(spawned_car.get_node("CarCamera"), spawned_lapcounter)
		
func hit_checkpoint(car:Node3D, checkpoint:Area3D):
	if car is VehicleBody3D:
		var player_name = car.get_node("CarController").player_name
		var new_checkpoint = int(checkpoint.name)
		
		var player_current_checkpoint = player_checkpoints[player_name]
		
		if(player_current_checkpoint == highest_checkpoint and new_checkpoint == 1):
			player_checkpoints[player_name] = 1
			print("finished lap")
			
			if(player_laps[player_name] == laps_to_finish):
				print("win")
			else:
				player_laps[player_name] += 1;
				
			# update ui
		else:
			if(abs(player_current_checkpoint - new_checkpoint) <= 1):
				player_checkpoints[player_name] = new_checkpoint
				print(player_name + " " + str(new_checkpoint))
			else:
				print("Missed checkpoint")
