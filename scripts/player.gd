extends CharacterBody2D

# --- SETTINGS ---
const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const ROLL_SPEED = 250.0   # Speed while rolling
const DEATH_Y = 3000.0     # The Y level where you die (keep this high!)

# --- VARIABLES ---
var is_dead := false
var is_rolling := false    # New variable to track rolling state
var start_position: Vector2

# --- NODES ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gamemanager: Node2D = %gamemanager

func _ready():
	start_position = global_position

func _physics_process(delta: float) -> void:
	# 1. If dead, stop everything
	if is_dead:
		return

	# 2. Add Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 3. Handle Roll Input
	# We can only roll if we are on the floor and not already rolling
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		start_roll()

	# 4. Movement Logic
	# If we are rolling, we ignore normal movement inputs
	if is_rolling:
		# Keep moving forward in the direction the sprite is facing
		var direction = -1 if animated_sprite_2d.flip_h else 1
		velocity.x = direction * ROLL_SPEED
	else:
		# --- NORMAL MOVEMENT (Only happens if NOT rolling) ---
		
		# Handle Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get Input Direction
		var direction := Input.get_axis("left", "right")

		# Handle Sprite Flipping
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true

		# Handle Animations
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("jump")

		# Apply Velocity
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# 5. Move and check for death
	move_and_slide()

	if global_position.y > DEATH_Y:
		respawn()

# --- CUSTOM FUNCTIONS ---

func start_roll():
	is_rolling = true
	animated_sprite_2d.play("roll") # Make sure you have an animation named "roll"
	
	# Wait for 0.5 seconds (or however long your roll animation is)
	await get_tree().create_timer(0.5).timeout
	
	# Stop rolling
	is_rolling = false

func respawn():
	if is_dead: return
	
	is_dead = true
	is_rolling = false # Reset roll status on death
	velocity = Vector2.ZERO
	
	if CheckpointManager.checkpoint_position != Vector2.ZERO:
		global_position = CheckpointManager.checkpoint_position
	else:
		global_position = start_position
		
	global_position.y -= 20
	
	await get_tree().physics_frame
	is_dead = false
