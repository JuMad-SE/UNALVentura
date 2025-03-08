extends CanvasLayer

func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		$ColorRect.visible = not $ColorRect.visible
		$Label.visible = not $Label.visible
		$Botones.visible = not $Botones.visible
	

func _on_continuar_pressed():
	get_tree().paused = false
	$ColorRect.visible = false
	$Label.visible = false
	$Botones.visible = false



func _on_respawn_pressed():
	get_tree().paused = false
	GameManager.restart_game()
	
	


func _on_salir_pressed():
	get_tree().quit()
