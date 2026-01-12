extends Area2D


@onready var gamemanager: Node2D = %gamemanager


func _on_body_entered(body: Node2D) -> void:
	gamemanager.add_point()
	queue_free()
