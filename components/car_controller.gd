class_name CarController extends Node

# Car Variables
@onready var car = $".."
@onready var hitbox = $"../CollisionShape3D"
@onready var body = $"../Body"
# Wheels
@onready var wheel_fr = $"../WheelFrontRight"
@onready var wheel_fl = $"../WheelFrontLeft"
@onready var wheel_br = $"../WheelBackRight"
@onready var wheel_bl = $"../WheelBackLeft"

@export var player_device = 0 #What Controller to Listen to

@export var max_steering_angle = PI/3
@export var braking_multiplier = 20
@export var acceleration_multiplier = 30


func _input(event: InputEvent) -> void:
	if event.device != player_device:
		return
	if event is InputEventJoypadMotion:
		if(event.axis == 0): #Left Stick Horizontal
			car.steering = event.axis_value*max_steering_angle
	if event is InputEventJoypadButton:
		if event.button_index == 6: ## Brake
			car.brake = event.pressure*braking_multiplier
		elif event.button_index == 7: ## Accelerate
			car.engine_force = event.pressure*acceleration_multiplier
			
