extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
var player_in_range = false
var player_ref: Node = null
var player_inside := false
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true
		player_ref = body
	if body.is_in_group("player"): # body.is_in_group("player") is set in player.gd
		player_in_range = true
		heart()
func heart():
		if player_ref:
			player_ref.new_heart()
			queue_free()
