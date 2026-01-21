extends Node

var checkpoint_position: Vector2 = Vector2.ZERO

func set_checkpoint(pos: Vector2):
	checkpoint_position = pos
	print("Checkpoint SET:", pos)
# Track unlocked characters and current selection
var unlocked_characters = ["Knight"] 
var current_character_index = 0
