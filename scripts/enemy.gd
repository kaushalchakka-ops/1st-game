#extends CharacterBody2D
#
#signal enemy_defeated 
#
#@onready var sprite = $AnimatedSprite2D
#var health = 5
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#
#func take_damage(amount):
	#health -= amount
	#if health > 0:
		#sprite.play("hit")
		#await sprite.animation_finished
		#sprite.play("idle")
	#else:
		#die()
#
#func die():
	#enemy_defeated.emit() 
	#queue_free()
#
## Add this to the CorruptedGuard script
#func _physics_process(delta):
	#var player = get_tree().get_first_node_in_group("player")
	#if player:
		#var dist = global_position.distance_to(player.global_position)
		## If player is in 'aggro' range, move toward them
		#if dist < 200 and dist > 50:
			#var dir = (player.global_position - global_position).normalized()
			#velocity.x = dir.x * 80 # Slower than player speed
		#elif dist <= 50:
			#perform_lunge()
	#move_and_slide()
	#
#
#func perform_lunge():
	## Quick burst of speed toward player
	#pass
#
## This should ONLY trigger when touching the PLAYER
#func _on_hurtbox_body_entered(body):
	#if body.has_method("take_damage"):
		#body.take_damage()
	#print("Hit:", body.name)
extends CharacterBody2D

signal enemy_defeated
# --- PATROL SETTINGS ---
@export var min_x: float = 2600.0  # The leftmost point the enemy can go
@export var max_x: float = 2850.0 # The rightmost point the enemy can go

@onready var sprite = $AnimatedSprite2D
var health = 5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	# 2. Movement Logic with Boundary Checks
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		var target_x = player.global_position.x
		
		# Only chase if player is within the X-range and in aggro distance
		if target_x > min_x and target_x < max_x and dist < 200:
			var dir = sign(target_x - global_position.x)
			velocity.x = dir * 80 
			sprite.flip_h = dir < 0
		else:
			# If player is outside range, stop at the boundary
			velocity.x = move_toward(velocity.x, 0, 20)
			
	# 3. Hard Boundary Clamp (Safety)
	# This forces the enemy to stay inside the coordinates even if pushed
	global_position.x = clamp(global_position.x, min_x, max_x)

	move_and_slide()

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
