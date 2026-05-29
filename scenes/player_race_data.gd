class_name PlayerRaceData extends Node

var player_name:StringName
var score:int = 0
var car_id:int = 0

func _init(entered_name:StringName, car_id:int) -> void:
	self.player_name = entered_name
	self.car_id = car_id
	
