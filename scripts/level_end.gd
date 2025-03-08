extends Area2D

@onready var collision_shape = $CollisionShape2D

signal level_completed

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		emit_signal("level_completed")
		collision_shape.set_deferred("disabled", true)
