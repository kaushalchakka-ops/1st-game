extends Area2D

# Variable to track if the player is standing near the lever
var player_in_range = false
var is_active = false # To check if we already pulled the lever

@onready var animated_sprite = $AnimatedSprite2D
@onready var label = $Label

func _ready():
	# Start with the "off" animation
	#if animated_sprite.sprite_frames.has_animation("off"):
		#animated_sprite.play("off")
	#
	# Connect signals using code (or you can do it via the Node tab)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	# Check if player is near AND presses the interact key (e.g., "roll" or a new "interact" key)
	# You can reuse "roll" (Z) if you want, or map a new key like "X"
	if player_in_range and not is_active and event.is_action("press") and event.is_pressed() and not event.is_echo():  
		activate_lever()

func activate_lever():
	is_active = true
	#label.hide() # Hide the text once activated
	
	# Visual feedback: switch lever to "on" position
	if animated_sprite.sprite_frames.has_animation("on"):
		animated_sprite.play("on")
		#  animated_sprite.pause()
	# --- SAVE THE CHECKPOINT ---
	CheckpointManager.set_checkpoint(global_position)
	print("Lever Pulled! Checkpoint Saved.")

# --- Signal Functions ---
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		#if not is_active: # Only show text if lever isn't pulled yet
			#label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		#label.hide()
