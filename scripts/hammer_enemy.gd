extends CharacterBody2D

# ------------------ VARIABLES ------------------
@export var speed := 80
@export var gravity := 1200
@export var attack_damage := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $Area2D
@onready var attack_timer: Timer = $AttackTimer

var player: Node2D
var can_attack := true
var is_attacking := false
var direction := 0

# ------------------ READY ------------------
func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

	if not attack_area:
		push_error("AttackArea missing!")
	if not attack_timer:
		push_error("AttackTimer missing!")

# ------------------ PHYSICS ------------------
func _physics_process(delta):
	if not player:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# If attacking → do not move
	if is_attacking:
		move_and_slide()
		return

	# Chase player
	direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed

	sprite.flip_h = direction < 0
	sprite.play("run")

	move_and_slide()
	
	
# ------------------ ATTACK DETECTION ------------------


# ------------------ START ATTACK ------------------
func start_attack():
	can_attack = false
	is_attacking = true
	velocity.x = 0

	sprite.play("attack")
	$AnimationPlayer.play("attack")
	attack_timer.start()

# ------------------ DAMAGE (CALL FROM ANIMATION FRAME) ------------------
func hit_player():
	if not attack_area:
		return

	for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.respawn()

# ------------------ RESET AFTER ATTACK ------------------
func _on_attack_timer_timeout():
	is_attacking = false
	can_attack = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_attack:
		start_attack()
@export var max_health := 3
var health := max_health
func take_damage(amount):
	health -= amount
	print("Enemy HP:", health)

	if health <= 0:
		die()

# ---------------- DIE ----------------
func die():
	queue_free()
