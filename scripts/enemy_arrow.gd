extends Area2D

@export var speed := 500
var direction: Vector2

func _ready():
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
	queue_free()
