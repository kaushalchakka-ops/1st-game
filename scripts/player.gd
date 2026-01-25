extends CharacterBody2D

# --- SETTINGS ---
var SPEED = 130.0 
const JUMP_VELOCITY = -400.0 
const ROLL_SPEED = 250.0 
const DEATH_Y = 3000.0     

# --- VARIABLES ---
var is_dead := false 
var is_rolling := false 
var is_attacking := false   
var can_attack := false  
var is_in_wind := false    
var is_on_ice := false     
var is_swinging := false
var is_defending=false
var start_position: Vector2
var arrow_scene = preload("res://Arrow.tscn")
# --- NODES ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D 
@onready var attack_area: Area2D = $AttackArea 
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D

var form := ""
var is_spearman=false
var is_defender=false
var is_archer=false
func play_anim(anim: String):
	$AnimatedSprite2D.play(form  + anim)

func transform_to_spearman():
	form = "Spearman"
	is_spearman=true
	play_anim("idle")
	collision_shape_2d.scale=Vector2(3,1)

func transform_to_defender():
	form="Defender"
	is_defender=true
	$AttackArea/CollisionShape2D.scale = Vector2(1, 1)
func transform_to_archer():
	form="Archer"
	is_archer=true
	$AttackArea/CollisionShape2D.scale = Vector2(0.1, 0.1)
func transform_to_normal():
	form = ""
	play_anim("idle")
	$AttackArea/CollisionShape2D.scale = Vector2(1, 1)
	
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
	if is_switch==true:
		if Input.is_action_just_pressed("1"):
			if is_spearman==true:
				form="Spearman"
		if Input.is_action_just_pressed("2"):
			if is_defender==true:
				form="Defender"
		if Input.is_action_just_pressed("3"):
			if is_archer==true:
				form="Archer"
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
		if(form=="Defender"):
			animated_sprite_2d.scale=Vector2(0.25,0.25)
			animated_sprite_2d.position=Vector2(0,-9)
			animated_sprite_2d.play(form+"idle")
		if(form=="Archer"):
			animated_sprite_2d.scale=Vector2(0.25,0.25)
			animated_sprite_2d.position=Vector2(0,-9)
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
			if(form=="Defender"):
				animated_sprite_2d.scale=Vector2(0.25,0.25)
				animated_sprite_2d.position=Vector2(0,-9)
			if(form=="Archer"):
				animated_sprite_2d.scale=Vector2(0.25,0.25)
				animated_sprite_2d.position=Vector2(0,-9)
			animated_sprite_2d.play(form+"run")


	elif is_on_floor():
		if(form=="Spearman"): 
			animated_sprite_2d.scale = Vector2(0.25, 0.25)
			animated_sprite_2d.position=Vector2(0,-21)
		if(form=="Defender") and is_defending==false:
			animated_sprite_2d.scale=Vector2(0.25,0.25)
			animated_sprite_2d.position=Vector2(0,-9)
		if(form=="Archer"):
			animated_sprite_2d.scale=Vector2(0.25,0.25)
			animated_sprite_2d.position=Vector2(0,-9)
		if Input.is_action_pressed("defend") and(form=="Defender"):
			is_defending = true
			animated_sprite_2d.scale=Vector2(0.25,0.25)
			animated_sprite_2d.position=Vector2(0,-9)
			SPEED=90
			animated_sprite_2d.play("Defenderdefend")
			$CollisionShape2D.disabled=true
			return
		else:
			is_defending = false
			SPEED=130
		animated_sprite_2d.play(form+"idle")
		$CollisionShape2D.disabled=false
	
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
		animated_sprite_2d.position=Vector2(0,-7)
	if(form=="Defender"):
		animated_sprite_2d.scale=Vector2(0.25,0.25)
		animated_sprite_2d.position=Vector2(0,-7)
	if(form=="Archer"):
		animated_sprite_2d.scale=Vector2(0.25,0.25)
		animated_sprite_2d.position=Vector2(0,-7)
		shoot_arrow()
		return
	is_attacking = true
	velocity.x = 0 
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
	elif(form=="Defender"):
		animated_sprite_2d.scale=Vector2(0.25,0.25)
		animated_sprite_2d.position=Vector2(0,-9)
		animated_sprite_2d.play(form+"idle")
	elif(form=="Archer"):
		animated_sprite_2d.scale=Vector2(0.25,0.25)
		animated_sprite_2d.position=Vector2(0,-9)
		animated_sprite_2d.play(form+"idle")
	else:
		animated_sprite_2d.play("roll") 
	await get_tree().create_timer(0.5).timeout 
	is_rolling = false 

func respawn():
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	if hearts==true:
		play_health=3
	if CheckpointManager.checkpoint_position != Vector2.ZERO:
		global_position = CheckpointManager.checkpoint_position
	else:
		global_position = start_position

	await get_tree().physics_frame
	set_physics_process(true)
	is_dead = false
func _on_attack_area_area_entered(area: Area2D) -> void:
	if attack==true:
		if area.name == "Hurtbox":
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(1) # Deals 1 damage per hit
			attack=false
func shoot_arrow():
	is_attacking = true
	animated_sprite_2d.play("Archerattack") 
	while animated_sprite_2d.animation == "Archerattack" and animated_sprite_2d.frame < 3:
		await get_tree().process_frame
	spawn_projectile()
	await animated_sprite_2d.animation_finished
	is_attacking = false

func spawn_projectile():
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = global_position
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	arrow.direction = direction_to_mouse
	arrow.rotation = direction_to_mouse.angle()
	if mouse_pos.x < global_position.x:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
func take_damage():
	respawn()
var current_character = "Knight"
var play_health=3
var hearts=false
func enable_heart():
	hearts=true
	if play_health==3:
		$Hearts0.visible=true
		$Hearts1.visible=true
		$Hearts2.visible=true
func heart_visibile():
	if play_health==0:
		play_health=3
		$Hearts0.visible=true
		$Hearts1.visible=true
		$Hearts2.visible=true
		respawn()
	if play_health==3:
		$Hearts0.visible=true
		$Hearts1.visible=true
		$Hearts2.visible=true
	if play_health==2:
		$Hearts0.visible=true
		$Hearts1.visible=true
		$Hearts2.visible=false
	elif play_health==1:
		$Hearts0.visible=true
		$Hearts1.visible=false
		$Hearts2.visible=false
func player_damage():
	if is_defending==false:
		if hearts==true:
			play_health-=1
			heart_visibile()
		else:
			respawn()
var is_switch=false
func new_heart():
	if play_health<3:
		play_health+=1
		heart_visibile()
func enable_switch():
	is_switch=true
	
