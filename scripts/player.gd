extends CharacterBody2D

# --- SETTINGS ---
const SPEED = 130.0 
const JUMP_VELOCITY = -400.0 
const ROLL_SPEED = 250.0 
const DEATH_Y = 3000.0     # The Y level where you die 

# --- VARIABLES ---
var is_dead := false 
var is_rolling := false 
var is_in_wind := false    # Tracks if currently in a WindArea 
var is_on_ice := false     # Tracks if currently on Ice
var start_position: Vector2 

# --- NODES ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D 
@onready var gamemanager: Node2D = %gamemanager 

func _ready():
	start_position = global_position 
	add_to_group("player") # Required for checkpoints and ice areas to find the player 

func _physics_process(delta: float) -> void:
	if is_dead:
		return 

 	# --- MANUAL RESPAWN ---
	# Ensure "manual_respawn" is mapped to the 'R' key in your Input Map
	if Input.is_action_just_pressed("respawn"):
		respawn()

	# 1. Add Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta 

	# 2. Handle Roll Input
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		start_roll() 

	# 3. Movement Logic
	if is_rolling:
		var roll_dir = -1 if animated_sprite_2d.flip_h else 1 
		velocity.x = roll_dir * ROLL_SPEED 
	else:
		# Handle Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY 

		var direction := Input.get_axis("left", "right") 

		# Handle Sprite Flipping and Animations
		if direction != 0:
			animated_sprite_2d.flip_h = direction < 0 
			if is_on_floor():
				animated_sprite_2d.play("run") 
		elif is_on_floor():
			animated_sprite_2d.play("idle") 
		
		if not is_on_floor():
			animated_sprite_2d.play("jump") 

		# --- SMART PHYSICS LOGIC (ICE, WIND, & NORMAL) ---
		if direction:
			if is_on_ice:
				# SLIPPERY ACCELERATION: Takes time to reach full speed on ice
				velocity.x = move_toward(velocity.x, direction * SPEED, 4.0)
			else:
				# NORMAL ACCELERATION: Snappy movement on regular ground 
				velocity.x = move_toward(velocity.x, direction * SPEED, 20.0) 
		else:
			if is_on_ice or is_in_wind:
				# LOW FRICTION: Slips in the direction of motion while on ice/wind 
				velocity.x = move_toward(velocity.x, 0, 2.0)
			else:
				# HIGH FRICTION: Stops instantly on normal ground (No slipping) 
				velocity.x = move_toward(velocity.x, 0, SPEED) 

	move_and_slide() 

	# Check for falling off the map 
	if global_position.y > DEATH_Y:
		respawn() 

func start_roll():
	is_rolling = true 
	animated_sprite_2d.play("roll") 
	await get_tree().create_timer(0.5).timeout 
	is_rolling = false 

func respawn():
	if is_dead: return 
	is_dead = true 
	is_rolling = false 
	velocity = Vector2.ZERO # Stop all movement upon death 
	
	# Move to the position stored in CheckpointManager 
	if CheckpointManager.checkpoint_position != Vector2.ZERO: 
		global_position = CheckpointManager.checkpoint_position 
	else:
		global_position = start_position 
		
	global_position.y -= 20 # Spawn slightly above the ground to avoid clipping 
	await get_tree().physics_frame 
	is_dead = false
