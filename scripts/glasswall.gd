extends StaticBody2D

@onready var collision := $CollisionShape2D

func _ready():
	CombatManager.all_enemies_dead.connect(open_wall)

func open_wall():
	print("Opening glass wall")
	queue_free()
