extends Node2D

@export var mute: bool = false

func _ready() :
	if not mute:
		play_music()

func play_music():
	if not mute:
		$music.play()

func play_jump() -> void:
	if not mute:
		$jump.play()
func play_transform() -> void:
	if not mute:
		$transform.play()
func play_checkpoint() -> void:
	if not mute:
		$checkpoint.play()
#func play_end_level() -> void:
	#if not mute:
		#$Music.stop()
		#$EndLevel.pay()
