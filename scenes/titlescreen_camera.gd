extends Camera3D

var timer:float = 0;
var radius:float = 0;
var period:float = PI/(2 * 30)
@export var center_of_rot:Node3D;

func _ready() -> void:	
	radius = global_position.distance_to(center_of_rot.global_position)

func _process(delta: float) -> void:
	timer += delta
	
	global_position = center_of_rot.global_position + (Vector3.FORWARD * sin(timer * period) * radius + Vector3.RIGHT * cos(timer * period) * radius)
	look_at(center_of_rot.global_position)
	rotate_object_local(Vector3.RIGHT, -0.5)
