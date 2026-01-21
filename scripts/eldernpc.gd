extends Area2D

var has_given_weapon = false 
var player_in_range = false

@onready var bubble = $PanelContainer
@onready var label = $PanelContainer/Label

func _ready():
	# Standard signal connections for the Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	bubble.hide()

func _on_body_entered(body):
	if body.is_in_group("player"): # body.is_in_group("player") is set in player.gd
		player_in_range = true
		bubble.show()

func _on_body_exited(_body):
	player_in_range = false
	bubble.hide()

func _input(_event):
	# Check for interaction regardless of whether an enemy is alive
	if Input.is_action_just_pressed("interact") and player_in_range:
		speak()

func speak():
	if not has_given_weapon:
		label.text = "Hero, your blade is too short. Take this spear for better reach!"
		
		# Typewriter effect
		label.visible_characters = 0
		var tween = create_tween()
		tween.tween_property(label, "visible_characters", label.text.length(), 1.0)
		
		# 1. Unlock Spearman in the global manager
		if not CheckpointManager.unlocked_characters.has("Spearman"):
			CheckpointManager.unlocked_characters.append("Spearman")
		
		# 2. Get the player and trigger the swap logic
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.can_attack = true # Unlocks combat
			if player.has_method("swap_character"):
				player.swap_character() # Swaps to the Spearman unit
		
		has_given_weapon = true
