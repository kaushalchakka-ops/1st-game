extends Area2D

@export var wind_force: float = 400.0 
@export var wind_direction: Vector2 = Vector2.RIGHT 

func _ready():
	# Connect signals to tell the player they are in the wind
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies() # [cite: 1]
	for body in bodies:
		if body.is_in_group("player") and not body.is_dead:
			body.velocity.x += wind_direction.x * wind_force * delta # [cite: 1]

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.is_in_wind = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.is_in_wind = false
