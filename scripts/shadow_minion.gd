extends CharacterBody2D

var health = 3
@onready var sprite = $AnimatedSprite2D

func take_damage(amount):
	health -= amount
	if health > 0:
		sprite.play("hit")
		await sprite.animation_finished
		sprite.play("idle")
	else:
		die()

func _ready():
	CombatManager.register_enemy()

func die():
	CombatManager.enemy_killed()
	queue_free()
