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
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D

#func _ready():
	#start_position = global_position 
	#add_to_group("player")
	#if attack_area:
		#attack_area.monitoring = false 
var form := ""

func play_anim(anim: String):
	$AnimatedSprite2D.play(form  + anim)

func transform_to_spearman():
	form = "Spearman"
	play_anim("idle")
	collision_shape_2d.scale=Vector2(3,1)

func transform_to_normal():
	form = ""
	play_anim("idle")
	
func _ready():
	add_to_group("player")
	start_position = global_position # Save the original editor position [cite: 5]
	
	# If a mode was selected in the menu, teleport there immediately
	if CheckpointManager.checkpoint_position != Vector2.ZERO:
		global_position = CheckpointManager.checkpoint_position
func _physics_process(delta: float) -> void:
	if is_dead:
		return 
	if(form==""):
		animated_sprite_2d.scale = Vector2(1,1)

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
		if(form=="Spearman"):
			animated_sprite_2d.scale = Vector2(0.25, 0.25)
			animated_sprite_2d.position=Vector2(0,-21)
			animated_sprite_2d.play(form+"idle")
		else:
			animated_sprite_2d.play("jump")
	var direction := Input.get_axis("left", "right") 

	# Sprite Orientation & Animations
	if direction != 0:
		animated_sprite_2d.flip_h = direction < 0 
		if attack_area:
			attack_area.scale.x = -1 if direction < 0 else 1
		
		if is_on_floor():
			if(form=="Spearman"): 
				animated_sprite_2d.scale = Vector2(0.25, 0.25)
				animated_sprite_2d.position=Vector2(0,-13)
			animated_sprite_2d.play(form+"run")


	elif is_on_floor():
		if(form=="Spearman"): 
			animated_sprite_2d.scale = Vector2(0.25, 0.25)
			animated_sprite_2d.position=Vector2(0,-21)
		animated_sprite_2d.play(form+"idle") 
	
	#if not is_on_floor() and not is_swinging:
		#animated_sprite_2d.play("jump") 

	# Physics (Ice / Wind / Friction)
	var accel = 4.0 if is_on_ice else 20.0
	var friction = 2.0 if (is_on_ice or is_in_wind) else SPEED
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
var attack=false
func perform_attack():
	if(form=="Spearman"):
		animated_sprite_2d.scale = Vector2(0.25, 0.25)
		animated_sprite_2d.position=Vector2(0,22)
	is_attacking = true
	velocity.x = 0 # Stop movement during the swing
	animated_sprite_2d.play(form+"attack")
	attack=true
	if attack_area:
		attack_area.monitoring = true
	
	# Wait for the animation to finish before allowing movement
	await animated_sprite_2d.animation_finished
	
	if attack_area:
		attack_area.monitoring = false
	is_attacking = false

func start_roll():
	is_rolling = true 
	if(form=="Spearman"):
		animated_sprite_2d.scale = Vector2(0.25, 0.25)
		animated_sprite_2d.position=Vector2(0,-21)
		animated_sprite_2d.play(form+"idle")
	else:
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
	if attack==true:
		if area.name == "Hurtbox":
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(1) # Deals 1 damage per hit
			attack=false
func take_damage():
	# You can add a 'hit' animation here later
	respawn() # Teleports player back to the checkpoint
# Add these to your variable section
var current_character = "Knight"
