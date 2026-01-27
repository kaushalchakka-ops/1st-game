extends CharacterBody2D

@export var attack_range = 300.0
@export var shoot_cooldown = 5.0
@export var arrow_scene = load("res://enemy_arrow.tscn") # Create this in Step 2

var can_shoot = true

@onready var sprite = $AnimatedSprite2D
@onready var timer = $AttackTimer
@onready var shoot_point = $Marker2D

func _ready():
	add_to_group("enemy")
	timer.wait_time = shoot_cooldown
	timer.one_shot = true

func _physics_process(delta):
	# Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		
		# Look at player
		sprite.flip_h = player.global_position.x < global_position.x
		
		# Shoot if in range and cooldown is over
		if dist <= attack_range and can_shoot:
			shoot_at_player(player)
	
	move_and_slide()

func shoot_at_player(player):
	can_shoot = false
	sprite.play("attack") # Play the bow draw animation
	
	# Wait for the animation frame where the bow releases (sync)
	# Adjust '2' to the frame number where the arrow should fly
	while sprite.animation == "attack" and sprite.frame < 1:
		await get_tree().process_frame
		
	# Spawn Arrow
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	
	arrow.global_position = shoot_point.global_position
	# Aim at player
	var dir = (player.global_position - global_position).normalized()
	arrow.direction = dir
	arrow.rotation = dir.angle()
	
	timer.start() # Start 5-second wait

func _on_attack_timer_timeout() -> void:
	can_shoot = true
	sprite.play("idle")
