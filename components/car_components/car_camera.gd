class_name CarCamera extends Node3D

@onready var car: VehicleBody3D = $".."
# Grab the child target node that we will apply the shake to
@onready var shake_target: Node3D = $shaker

var fov = 80
var car_offset_z: float = 3.25
var car_offset_y: float = 2.5
var car_rotation_offset:Vector3 = Vector3(-0.35, 0, 0)

var position_lerp_weight = 20

var camera_fov_sensitivity = 0.5
var previous_speed: float = 0
var smoothed_speed:float = 0;
var speed_smoothing_weight = 20;
var speed_shake_slope = 0.001
var acceleration_shake_slope = 0.1

# --- SHAKE SETTINGS ---
var trauma: float = 0.0
var trauma_from_speed:float = 0;
@export var trauma_decay: float = 1.0  # How fast the shake stops fading
@export var max_shake_offset: Vector3 = Vector3(0.5, 0.5, 0.5) # Max distance it can shake
@export var max_shake_roll: float = 0.1 # Max rotation twist (in radians)

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	var current_speed = car.linear_velocity.length()
	
	smoothed_speed = lerp(smoothed_speed, current_speed, speed_smoothing_weight * delta)
	fov = clamp(lerp(70, 100, (current_speed / 30) * (current_speed / 30) * (current_speed / 30)), 70, 100)
	
	var acceleration = abs(current_speed - previous_speed) / delta;
	
	trauma_from_speed = speed_shake_slope * smoothed_speed
	
	if acceleration > 1000:
		add_shake((acceleration - 1000) * acceleration_shake_slope)
	
	var car_angle_from_above = atan2(car.global_basis.z.z, car.basis.z.x)
	
	var forward = Vector3(
		cos(car_angle_from_above),
		0,
		sin(car_angle_from_above)
	)

	var target_pos = car.position - forward * car_offset_z
	target_pos.y = car.position.y + car_offset_y

	position = position.lerp(target_pos, position_lerp_weight * delta)
	
	rotation = (Vector3.UP * -(car_angle_from_above + PI/2)) + car_rotation_offset
	
	# --- SHAKE DECAY LOGIC ---
	if trauma > 0 or trauma_from_speed:
		# Constantly reduce the trauma over time
		trauma = max(trauma - trauma_decay * delta, 0)
		_apply_shake()
	elif shake_target:
		# Snap the target back to perfectly center when not shaking
		shake_target.position = Vector3.ZERO
		shake_target.rotation = Vector3.ZERO
	
	previous_speed = current_speed

# --- THE SHAKE FUNCTION ---
func add_shake(intensity: float) -> void:
	trauma = clamp(trauma + intensity, 0.0, 1.0)

func _apply_shake() -> void:
	if not shake_target: 
		return
		
	var shake_amount = trauma * trauma + trauma_from_speed
	
	# Apply random local offsets to the child target
	shake_target.position.x = max_shake_offset.x * shake_amount * randf_range(-1, 1)
	shake_target.position.y = max_shake_offset.y * shake_amount * randf_range(-1, 1)
	shake_target.position.z = max_shake_offset.z * shake_amount * randf_range(-1, 1)
	
	# Apply random roll 
	shake_target.rotation.z = max_shake_roll * shake_amount * randf_range(-1, 1)
