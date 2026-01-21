extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Update the global checkpoint to this exact spot
		CheckpointManager.checkpoint_position = global_position
		print("Checkpoint updated to new section!")
