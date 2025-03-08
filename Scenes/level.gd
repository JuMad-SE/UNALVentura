extends Node2D

@onready var victory_point = $LevelEnd

func _ready() -> void:
	victory_point.connect("level_completed",GameManager.complete_level)
