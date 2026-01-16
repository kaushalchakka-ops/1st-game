extends Area2D

# Use @onready to ensure these nodes are loaded before the script tries to use them
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var break_timer: Timer = $BreakTimer
@onready var solid_floor: CollisionShape2D = $StaticBody2D/CollisionShape2D

@export var fall_delay: float = 0.8
@export var respawn_delay: float = 3.0

func _ready():
	# Connect the signals in code to be safe
	body_entered.connect(_on_body_entered)
	break_timer.timeout.connect(_on_ice_broken)
	break_timer.wait_time = fall_delay
	break_timer.one_shot = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		if break_timer.is_stopped():
			break_timer.start()
			start_cracking_effect()

func start_cracking_effect():
	# If you have an animation named "cracking"
	if sprite.sprite_frames.has_animation("cracking"):
		sprite.play("cracking")
	
	# Keep the visual fade we added
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0.4), fall_delay)
func _on_ice_broken():
	# Hide the sprite and disable the floor so player falls
	sprite.hide()
	# set_deferred is required when changing physics during a collision
	solid_floor.set_deferred("disabled", true)
	
	# Wait for the respawn duration
	await get_tree().create_timer(respawn_delay).timeout
	respawn_ice()

func respawn_ice():
	sprite.show()
	sprite.modulate = Color(1, 1, 1, 1) # Reset transparency
	solid_floor.set_deferred("disabled", false)
