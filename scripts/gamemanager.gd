extends Node2D
@onready var gamemanager: Node2D = %gamemanager
@onready var label: Label = $"../labels/Label"
@onready var glass: AnimatableBody2D = $"../Node/glass"

var score =0
var invipotion=0
func visi():
	invipotion+=1
	print(invipotion)
	if invipotion > 0 :
		glass.visible=true

func invisi():
	invipotion-=1
	print(invipotion)
	if invipotion == 0 :
		glass.visible=false
	
func add_point():
	score+=1
	print(score)
	label.text = "You collected " + str(score) + " coins."





func _on_glass_visibility_changed() -> void:
	pass # Replace with function body.
