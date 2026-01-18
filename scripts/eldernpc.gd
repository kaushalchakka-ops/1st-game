extends Area2D

# Fix: Declare variables at the top
var has_given_weapon = false 
var player_in_range = false

@onready var bubble = $PanelContainer
@onready var label = $PanelContainer/Label

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	bubble.hide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		bubble.show()

func _on_body_exited(_body):
	player_in_range = false
	bubble.hide()

func _input(_event):
	# Fix: Use Input global instead of the event parameter
	if Input.is_action_just_pressed("interact") and player_in_range:
		speak()

func speak():
	if not has_given_weapon:
		label.text = "
		Take this blade! Use Left Click to attack."
		
		# TYPEWRITER EFFECT: Gradually show characters
		label.visible_characters = 0
		var tween = create_tween()
		tween.tween_property(label, "visible_characters", label.text.length(), 1.0)
		
		var player = get_tree().get_first_node_in_group("player")
		player.can_attack = true 
		has_given_weapon = true
