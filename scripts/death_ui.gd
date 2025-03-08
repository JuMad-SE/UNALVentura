extends CanvasLayer

func _ready():
	hide()	

func _on_respawn_pressed() -> void:
	GameManager.respawn_player()
	get_tree().paused = false
	get_tree().call_group("player", "respawn")
