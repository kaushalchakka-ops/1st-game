extends Area2D

signal spearman_unlocked

@onready var bubble = $PanelContainer
@onready var label = $PanelContainer/Label
var player_in_range = false
var player_ref: Node = null
var player_inside := false
func _on_body_entered(body):
	if body.name == "player":
		player_inside = true
		player_ref = body
	if body.is_in_group("player"): # body.is_in_group("player") is set in player.gd
		player_in_range = true
		bubble.show()

func _on_body_exited(body):
	if body.name == "player":
		player_inside = false
		player_ref = null

	bubble.hide()
func _ready():
	# Standard signal connections for the Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	bubble.hide()


func _input(_event):
	# Check for interaction regardless of whether an enemy is alive
	if Input.is_action_just_pressed("interact") and player_in_range:
		speak()

func speak():
		label.text = "
		Hero, now you can switch between character. Number keys are used to switch between characters"
		
		# Typewriter effect
		label.visible_characters = 0
		var tween = create_tween()
		tween.tween_property(label, "visible_characters", label.text.length(), 1.0)
		if player_ref:
			player_ref.enable_switch()
