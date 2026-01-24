extends Control

# References to your containers from your scene tree
@onready var main_menu_container = $CenterContainer
@onready var level_select_container = $CenterContainer2
const STORY_START_POS = Vector2(-478,-97)
const PARKOUR_START_POS = Vector2(2300, -287)
func _ready():
	# Start with only the main menu visible
	main_menu_container.show()
	level_select_container.hide()

# --- MAIN MENU BUTTONS ---


func _on_button_3_pressed() -> void:
	CheckpointManager.checkpoint_position = STORY_START_POS
	get_tree().change_scene_to_file("res://game.tscn")


func _on_button_4_pressed() -> void:
	CheckpointManager.checkpoint_position = PARKOUR_START_POS
	get_tree().change_scene_to_file("res://game.tscn")


func _on_button_pressed() -> void:
	main_menu_container.hide()
	level_select_container.show()



func _on_button_2_pressed() -> void:
	get_tree().quit()
