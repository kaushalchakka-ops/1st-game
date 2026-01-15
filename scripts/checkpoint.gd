extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		CheckpointManager.set_checkpoint(global_position)
