# Archivo: PauseMenu.gd
extends Control

# Marcar la escena como pausable
func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Escuchar la tecla "P" para mostrar/ocultar el menú
func _input(event):
	if event.is_action_pressed("pause"): 
		print("yhola")
		toggle_pause()

func toggle_pause():
	if visible:
		resume_game()
	else:
		pause_game()

func pause_game():
	visible = true
	get_tree().paused = true

func resume_game():
	visible = false
	get_tree().paused = false

func _on_continuar_pressed():
	resume_game()

func _on_opciones_pressed():
	# Aquí puedes mostrar las opciones directamente o cargar la escena de opciones
	# Si quieres cargar la escena de opciones mientras estás en pausa:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/options.tscn")

func _on_salir_pressed():
	# Volver al menú principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
