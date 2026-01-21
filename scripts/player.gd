extends CharacterBody2D

# --- SETTINGS ---
const SPEED = 130.0 
const JUMP_VELOCITY = -400.0 
const ROLL_SPEED = 250.0 
const DEATH_Y = 3000.0     

# --- VARIABLES ---
var is_dead := false 
var is_rolling := false 
var is_attacking := false   
var can_attack := false     # Unlocked by the Elder NPC
var is_in_wind := false    
var is_on_ice := false     
var is_swinging := false
var start_position: Vector2

# --- NODES ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D 
@onready var attack_area: Area2D = $AttackArea 

#func _ready():
	#start_position = global_position 
	#add_to_group("player")
	#if attack_area:
		#attack_area.monitoring = false 
func _ready():
	add_to_group("player")
	start_position = global_position # Save the original editor position [cite: 5]
	
	# If a mode was selected in the menu, teleport there immediately
	if CheckpointManager.checkpoint_position != Vector2.ZERO:
		global_position = CheckpointManager.checkpoint_position
func _physics_process(delta: float) -> void:
	if is_dead:
		return 

	# --- MANUAL RESPAWN ---
	if Input.is_action_just_pressed("respawn"):
		respawn()
# 1. Add Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta 

	# 2. Handle State Check (Swing Rope)
	if is_swinging:
		velocity = Vector2.ZERO 
		animated_sprite_2d.play("jump")
		return 

	# 3. Handle Combat Input
	if Input.is_action_just_pressed("attack") and can_attack and not is_attacking:
		perform_attack()

	# 4. Movement Logic (Only if not attacking)
	if not is_attacking:
		if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
			start_roll() 
		
		if is_rolling:
			var roll_dir = -1 if animated_sprite_2d.flip_h else 1 
			velocity.x = roll_dir * ROLL_SPEED 
		else:
			handle_movement()

	move_and_slide() 

	# 5. Death Zone Check
	if global_position.y > DEATH_Y:
		respawn() 

func handle_movement():
	# Jump Logic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 
		animated_sprite_2d.play("jump")

	var direction := Input.get_axis("left", "right") 

	# Sprite Orientation & Animations
	if direction != 0:
		animated_sprite_2d.flip_h = direction < 0 
		if attack_area:
			attack_area.scale.x = -1 if direction < 0 else 1
		
		if is_on_floor():
			animated_sprite_2d.play("run") 
	elif is_on_floor():
		animated_sprite_2d.play("idle") 
	
	if not is_on_floor() and not is_swinging:
		animated_sprite_2d.play("jump") 

	# Physics (Ice / Wind / Friction)
	var accel = 4.0 if is_on_ice else 20.0
	var friction = 2.0 if (is_on_ice or is_in_wind) else SPEED
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)

func perform_attack():
	is_attacking = true
	velocity.x = 0 # Stop movement during the swing
	animated_sprite_2d.play("attack")
	
	if attack_area:
		attack_area.monitoring = true
	
	# Wait for the animation to finish before allowing movement
	await animated_sprite_2d.animation_finished
	
	if attack_area:
		attack_area.monitoring = false
	is_attacking = false

func start_roll():
	is_rolling = true 
	animated_sprite_2d.play("roll") 
	await get_tree().create_timer(0.5).timeout 
	is_rolling = false 

func respawn():
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)

	if CheckpointManager.checkpoint_position != Vector2.ZERO:
		global_position = CheckpointManager.checkpoint_position
	else:
		global_position = start_position

	await get_tree().physics_frame
	set_physics_process(true)
	is_dead = false
func _on_attack_area_area_entered(area: Area2D) -> void:
	# Check if the area we hit belongs to an enemy
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(1) # Deals 1 damage per hit
func take_damage():
	# You can add a 'hit' animation here later
	respawn() # Teleports player back to the checkpoint
# Add these to your variable section
var current_character = "Knight"

func swap_character():
	CheckpointManager.current_character_index += 1
	if CheckpointManager.current_character_index >= CheckpointManager.unlocked_characters.size():
		CheckpointManager.current_character_index = 0

	var char_name = CheckpointManager.unlocked_characters[
		CheckpointManager.current_character_index
	]

	print("Unlocked:", CheckpointManager.unlocked_characters)
	print("Character Swapped to:", char_name)

	animated_sprite_2d.play(char_name + "_idle")
