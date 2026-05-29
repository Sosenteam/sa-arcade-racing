extends Node3D
@onready var idle:AudioStreamPlayer3D = $idle
@onready var fast:AudioStreamPlayer3D = $fast
@onready var impact_heavy:Array[AudioStreamPlayer3D] = [$impact_heavy1, $impact_heavy2]
@onready var impact_medium:Array[AudioStreamPlayer3D] = [$impact_medium1, $impact_medium2,$impact_medium3,$impact_medium4]
@onready var impact_light:Array[AudioStreamPlayer3D] = [$impact_light1,$impact_light2,$impact_light3,$impact_light4,$impact_light5]
		
		
var smoothed_engine_force:float = 0;
var engine_force_smoothing_factor:float = 1.5;
var previous_speed:float = 0;

func _ready() -> void:
	idle.play();
	fast.play();




func _process(delta: float) -> void:
	var engine_force:float = get_parent().engine_force
	smoothed_engine_force = lerp(smoothed_engine_force, engine_force, engine_force_smoothing_factor * delta)
	
	idle.pitch_scale = clamp((smoothed_engine_force / 6000) + 0.2 , 1, 1.25)
	idle.volume_linear = (2 - clamp(smoothed_engine_force / 100000, 0.1, 3)) / 6
	
	fast.pitch_scale = clamp((smoothed_engine_force / 17950) + 0.2 , 1, 1.5)
	fast.volume_linear = clamp(smoothed_engine_force / 20000 - 0.2, 0, 3) / 4
	
	var current_speed = get_parent().linear_velocity.length()
	var acceleration = abs(current_speed - previous_speed) / delta;
	
	if(acceleration > 1000):
		print("heavy " + str(acceleration))
		impact_heavy.pick_random().play()
	elif(acceleration > 275):
		print("medium " + str(acceleration))
		impact_medium.pick_random().play()
	elif(acceleration > 75):
		print("light " + str(acceleration))
		impact_light.pick_random().play()
	
	previous_speed = current_speed
	
	#print("engine force: " + str(engine_force))
	
	
