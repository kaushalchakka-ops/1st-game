extends Control

# Replace this with the actual path to your level scene
@export var game_scene_path : String = "res://chapter_2.tscn"



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)


func _on_button_2_pressed() -> void:
	get_tree().quit()
