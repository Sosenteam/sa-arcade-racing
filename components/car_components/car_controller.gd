class_name CarController extends Node

# Car Variables
@onready var car:VehicleBody3D = $".."
# Wheels
@onready var wheel_fr = $"../WheelFrontRight"
@onready var wheel_fl = $"../WheelFrontLeft"
@onready var wheel_br = $"../WheelBackRight"
@onready var wheel_bl = $"../WheelBackLeft"

@export var player_device = 0 #What Controller to Listen to

@export var max_steering_angle = PI/8
@export var braking_multiplier = 20
@export var acceleration_multiplier = 10000
var player_name:StringName

var keyboard_enabled = false # Turn off for export?
var accelerator_engine_force:float = 0;
var currentsteerinput:float = 0;
var is_reversing = false;
var car_flip_upright_threshold = 45;

func _process(delta: float) -> void:
	if is_reversing:
		car.engine_force = -0.75 * acceleration_multiplier
	else:
		car.engine_force = accelerator_engine_force

var upright_i := 0.0

func apply_upright_torque(delta: float) -> void:
	var car_up = car.global_basis.y.normalized()
	var world_up = Vector3.UP

	var angle = car_up.angle_to(world_up)
	var threshold = deg_to_rad(car_flip_upright_threshold)

	if angle < threshold:
		upright_i = 0.0
		return

	var correction_axis = car_up.cross(world_up).normalized()

	var kp = 210
	var ki = 90.0
	var kd = 6.0

	var max_i = 8.0
	var max_torque = 400.0

	# Integral grows while flipped
	upright_i += (angle - threshold) * delta
	upright_i = clamp(upright_i, 0.0, max_i)

	var spring_torque = correction_axis * angle * kp
	var integral_torque = correction_axis * upright_i * ki
	var damping_torque = -car.angular_velocity * kd

	var torque = spring_torque + integral_torque + damping_torque
	torque = torque.limit_length(max_torque)

	car.apply_torque(torque)

func _physics_process(delta: float) -> void:
	apply_upright_torque(delta)

func _input(event: InputEvent) -> void:
	if keyboard_enabled && event is InputEventAction:
		non_controller_input(event)
	if event.device != player_device:
		return
	if event is InputEventJoypadMotion:
		if(event.axis == 0): #Left Stick Horizontal
			currentsteerinput = -event.axis_value
			car.steering = -event.axis_value*max_steering_angle
		if event.axis == 4: ## Brake
			car.brake = event.axis_value*braking_multiplier
		elif event.axis == 5: ## Accelerate
			accelerator_engine_force = event.axis_value*acceleration_multiplier
		#print("axis ",event.axis,"button value ",event.axis_value)
	if event is InputEventJoypadButton:
		print("button ",event.button_index, "button value ",event.pressed)
		if(event.button_index == 1):
			is_reversing = event.pressed
		
		if(event.pressed):
			if(event.button_index == 2):
				if(car.get_contact_count() >= 1):
					car.apply_impulse(Vector3.UP * 10000)
					car.apply_impulse(-car.basis.z * -accelerator_engine_force * 0.25)
					car.apply_impulse(car.basis.x * currentsteerinput * 8000)
					car.apply_torque_impulse(Vector3(randfn(0, 1), randfn(0, 1), randfn(0, 1)).normalized() * 1000)
		
		pass
	
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
	
	
