extends CharacterBody2D

# --- SETTINGS ---
const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const ROLL_SPEED = 250.0   
const DEATH_Y = 3000.0     # The Y level where you die [cite: 2]

# --- VARIABLES ---
var is_dead := false
var is_rolling := false    
var is_in_wind := false    # NEW: Tracks if we should allow sliding/wind push
var start_position: Vector2

# --- NODES ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gamemanager: Node2D = %gamemanager

func _ready():
	start_position = global_position # [cite: 2]
	add_to_group("player") # Ensures the wind area can find this node

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. Add Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta # [cite: 2]

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
			velocity.y = JUMP_VELOCITY # [cite: 3]

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

		# --- SMART FRICTION LOGIC ---
		if direction:
			# Normal movement acceleration
			velocity.x = move_toward(velocity.x, direction * SPEED, 20.0) 
		else:
			if is_in_wind:
				# LOW FRICTION: Allows the wind to push you [cite: 4]
				velocity.x = move_toward(velocity.x, 0, 5.0)
			else:
				# HIGH FRICTION: Stops the "slipping" instantly on normal ground
				velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide() # [cite: 4]

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
	velocity = Vector2.ZERO
	
	if CheckpointManager.checkpoint_position != Vector2.ZERO:
		global_position = CheckpointManager.checkpoint_position
	else:
		global_position = start_position
		
	global_position.y -= 20
	await get_tree().physics_frame
	is_dead = false
