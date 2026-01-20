extends CharacterBody2D

signal enemy_defeated 

@onready var sprite = $AnimatedSprite2D
var health = 5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func take_damage(amount):
	health -= amount
	if health > 0:
		sprite.play("hit")
		await sprite.animation_finished
		sprite.play("idle")
	else:
		die()

func die():
	enemy_defeated.emit() 
	queue_free()

# Add this to the CorruptedGuard script
func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		# If player is in 'aggro' range, move toward them
		if dist < 200 and dist > 50:
			var dir = (player.global_position - global_position).normalized()
			velocity.x = dir.x * 80 # Slower than player speed
		elif dist <= 50:
			perform_lunge()
	move_and_slide()
	

func perform_lunge():
	# Quick burst of speed toward player
	pass

# This should ONLY trigger when touching the PLAYER
func _on_hurtbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
	print("Hit:", body.name)
