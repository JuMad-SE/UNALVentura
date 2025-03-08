extends CanvasLayer

func _ready():
	hide()  # Ocultar al inicio

func _on_reiniciar_pressed():
	GameManager.restart_game()

func _on_menu_pressed():
	GameManager.return_to_main_menu()
