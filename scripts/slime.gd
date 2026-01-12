extends Node2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2

# Called when the node enters the scene tree for the first time.
var direction=1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_cast_2d.is_colliding():
		direction=-1
	if ray_cast_2d_2.is_colliding():
		direction=1
	position.x +=direction* 60*delta
