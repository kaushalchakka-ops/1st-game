extends Node2D
@onready var gamemanager: Node2D = %gamemanager
@onready var label: Label = $"../labels/Label"
var score =0
func add_point():
	score+=1
	print(score)
	label.text = "You collected " + str(score) + " coins."
