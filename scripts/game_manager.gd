extends Node2D

var current_player: Node = null
var respawn_point: Vector2
var deaths: int = 0

func _ready():
	respawn_point = Vector2(100,100)

func register_player(player: Node):
	current_player = player
	respawn_point = player.global_position

func respawn_player():
	if current_player:
		current_player.global_position = respawn_point
		current_player.respawn()
		
		deaths += 1
		
	else:
		push_error("No hay jugador registrado")
