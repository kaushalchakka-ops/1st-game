extends Node

signal all_enemies_dead

var enemies_alive := 0

func register_enemy():
	enemies_alive += 1

func enemy_killed():
	enemies_alive -= 1
	print("Enemies left:", enemies_alive)

	if enemies_alive <= 0:
		emit_signal("all_enemies_dead")
