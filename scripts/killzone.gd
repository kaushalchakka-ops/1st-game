extends Area2D

@onready var timer: Timer = $Timer
var checkpoint_manager
var player
@onready var gamemanager: Node2D = %gamemanager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkpoint_manager = get_parent().get_node("checkpointmanager")
	player=get_parent().get_node("player")

#func _on_timer_timeout() -> void:
	#Engine.time_scale =1.0
	#get_tree().reload_current_scene()

func _on_body_entered(body):
		if body.is_in_group("player") and body.has_method("respawn"):
			body.respawn() # Triggers the logic in player.g
	#if body.is_in_group("player"):
		#body.respawn()


#func _on_body_entered(body: Node2D) -> void:
		#print("you have died")
		#if body.has_method("respawn"):
			#body.respawn()
		##Engine.time_scale =0.5
		##killPlayer()
		###timer.start()
		##
#func killPlayer():
	## Make sure this matches the variable name in your manager script
	#player.global_position = gamemanager.respawn_position 
	#
	## Reset velocity so the player doesn't keep falling/moving after teleporting
	#player.velocity = Vector2.ZERO
