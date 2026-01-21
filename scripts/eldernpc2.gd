extends Area2D

var has_given_character := false

func _on_body_entered(body):
	if body.is_in_group("player") and not has_given_character:
		has_given_character = true

		# Unlock Spearman
		if not CheckpointManager.unlocked_characters.has("Spearman"):
			CheckpointManager.unlocked_characters.append("Spearman")
			print("Spearman unlocked by NPC")

		# Change player character
		body.swap_character()
