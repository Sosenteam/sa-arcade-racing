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

@export var max_steering_angle = PI/4
@export var braking_multiplier = 20
@export var acceleration_multiplier = 10000

var keyboard_enabled = true # Turn off for export?


func _input(event: InputEvent) -> void:
	if keyboard_enabled:
		non_controller_input(event)
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
	
func non_controller_input(event: InputEvent):
	# Steering
	if(Input.is_action_pressed("steer_right")&&Input.is_action_pressed("steer_left")):
		car.steering = 0
	elif(Input.is_action_pressed("steer_right")):
		car.steering = max_steering_angle*-0.75
	elif(Input.is_action_pressed("steer_left")):
		car.steering = max_steering_angle*0.75
	else:
		car.steering = 0
	

	# Acceleration
	if event.is_action_pressed("accelerate"):
		car.engine_force = acceleration_multiplier
	if event.is_action_released("accelerate"):
		car.engine_force = 0
	# Braking
	if event.is_action_pressed("brake"):
		car.brake = braking_multiplier
	if event.is_action_released("brake"):
		car.brake = 0
	
	
