extends Area2D

# --- NODES ---
# These must match the names in your Scene Tree exactly
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var break_timer: Timer = $BreakTimer
@onready var solid_floor: CollisionShape2D = $StaticBody2D/CollisionShape2D

# --- SETTINGS ---
@export var fall_delay: float = 0.8
@export var respawn_delay: float = 3.0

func _ready():
	# Connect signals via code to ensure they work
	body_entered.connect(_on_body_entered)
	break_timer.timeout.connect(_on_ice_broken)
	
	# Configure the timer
	break_timer.wait_time = fall_delay
	break_timer.one_shot = true

func _on_body_entered(body):
	# Check if the player stepped on the block
	if body.is_in_group("player"):
		if break_timer.is_stopped():
			break_timer.start()
			start_cracking_effect()

func start_cracking_effect():
	# NEW: Play the frame animation you created in SpriteFrames
	sprite.play("cracking")
	
	# Keep your existing fade effect
	var tween = create_tween() 
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0.4), fall_delay)
func _on_ice_broken():
	# 1. Hide the block
	sprite.hide()
	
	# 2. Disable the collision so the player falls
	# Use set_deferred to avoid physics errors during collision
	solid_floor.set_deferred("disabled", true)
	
	# 3. Wait for the respawn duration
	await get_tree().create_timer(respawn_delay).timeout
	respawn_ice()

func respawn_ice():
	# 4. Bring the block back
	sprite.show()
	sprite.modulate = Color(1, 1, 1, 1) # Reset transparency
	solid_floor.set_deferred("disabled", false)
