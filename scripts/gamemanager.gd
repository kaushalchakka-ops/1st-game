extends Node2D 
@onready var label: Label = $"../labels/Label"
@onready var glass: AnimatableBody2D = $"../glass_Level/glass"
@onready var glass_platform: AnimatableBody2D = $"../glass_Level/glass_platform"

var score =0
var invipotion=0
func visi():
	invipotion+=1
	print(invipotion)
	if invipotion > 0 :
		glass.visible=true
		glass_platform.visible=true
		

func invisi():
	invipotion-=1
	print(invipotion)
	if invipotion == 0 :
		glass.visible=false
		glass_platform.visible=false
	
func add_point():
	score+=1
	print(score)
	label.text = "You collected " + str(score) + " coins."
