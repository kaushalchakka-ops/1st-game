extends Area2D

var speed = 300
var direction = Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	# Check if we hit an enemy directly or through their Hurtbox
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1) # Deals 1 damage
		queue_free() # Destroy arrow on hit
func _on_area_entered(area):
	# If your enemy uses an Area2D named "Hurtbox"
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(1)
		queue_free()
