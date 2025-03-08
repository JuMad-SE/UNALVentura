extends Node2D

@onready var victory_point = $LevelEnd
@onready var victoryUI = $VictoryUi

func _ready() -> void:
	victory_point.connect("level_completed",GameManager.complete_level)
	victoryUI.process_mode = Node.PROCESS_MODE_ALWAYS
