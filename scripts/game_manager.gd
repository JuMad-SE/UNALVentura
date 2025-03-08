extends Node2D

var current_player: Node = null
var respawn_point: Vector2
var deaths: int = 0
var level_complete: bool = false
var victoryUI

func _ready():
	respawn_point = Vector2(100,100)

func register_player(player: Node):
	current_player = player
	print(current_player)
	respawn_point = player.global_position

func respawn_player():
	if current_player:
		current_player.global_position = respawn_point
		current_player.respawn()
		
		deaths += 1
		
	else:
		push_error("No hay jugador registrado")

func complete_level():
	level_complete = true
	show_victory_screen()
	get_tree().paused = true

func show_victory_screen():
	victoryUI = get_tree().get_first_node_in_group("victory_ui")
	victoryUI.show()

func restart_game():
	level_complete = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func return_to_main_menu():
	print('menu')
	
	
