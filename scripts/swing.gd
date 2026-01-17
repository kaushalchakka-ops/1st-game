extends Area2D

var player_on_rope: CharacterBody2D = null
var can_grab = true



# FIX: Manually update player position instead of reparenting
# Add this at the top with your other variables
# Replace your current @onready line with this:
@onready var grab_point = get_node_or_null("GrabPoint")
func grab(player):
	player_on_rope = player
	player.is_swinging = true

	# NEW: Stop the player's movement so they don't "kick" the rope
	player.velocity = Vector2.ZERO 
	
	# Snap immediately to the bottom point
	if grab_point != null:
		player.global_position = grab_point.global_position
# Get a reference to the RigidBody2D (the part that actually moves)
@onready var rope_body: RigidBody2D = get_parent() 

func _ready():
	body_entered.connect(_on_body_entered)
	# Lower this value (e.g., from 200 to 50) to start the swing slower
	rope_body.apply_central_impulse(Vector2(50, 0))

func _physics_process(_delta):
	# Keep the player stuck to the moving rope point
	if player_on_rope != null:
		player_on_rope.global_position = grab_point.global_position 
	
	# OPTIONAL: To keep the swing going forever without stopping:
	if abs(rope_body.angular_velocity) < 0.5:
		var push_dir = 1 if rope_body.rotation < 0 else -1
		rope_body.apply_torque_impulse(push_dir * 500)

func _on_body_entered(body):
	if body.is_in_group("player") and player_on_rope == null and can_grab:
		grab(body)


func release():
	if player_on_rope == null: 
		return 

	var p = player_on_rope 
	player_on_rope = null 
	
	p.is_swinging = false 
	
	# NEW: Add the rope's current speed to the player's jump
	var rope_velocity = rope_body.linear_velocity
	p.velocity = Vector2(rope_velocity.x, p.JUMP_VELOCITY) 

	can_grab = false 
	await get_tree().create_timer(0.5).timeout 
	can_grab = true
func _input(event):
	if player_on_rope and Input.is_action_just_pressed("jump"):
		release()
