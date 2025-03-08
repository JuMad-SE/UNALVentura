extends CharacterBody2D

@export var move_speed:float
@export var jump_speed:float
@onready var animated_sprite = $AnimatedSprite
@onready var sonidoPasos = $"../AudioStreamPlayer2"
var is_facing_right = true
var gravity  = ProjectSettings.get_setting("physics/2d/default_gravity")
var respawn_point: Vector2

#----------Variables de vida------------------------
var is_dead:= false

func _ready() -> void:
	GameManager.register_player(self)
	respawn_point = global_position
	is_dead = false
	
func _physics_process(delta):
	jump(delta)
	move_x()
	flip()
	update_animations()
	move_and_slide()
	
	if global_position.y > 500 and !is_dead:
		die()
	
	if GameManager.level_complete:
		return

func update_animations():
	if not is_on_floor():
		if velocity.y <0 :
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return			
		
	if velocity.x:
		animated_sprite.play("run")
		if not sonidoPasos.playing:
			sonidoPasos.play()
		
	else:
		animated_sprite.play("idle")
		if sonidoPasos.playing:
			sonidoPasos.stop()

#---------------Funciones de movimiento--------------------------

func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed
		
	if not is_on_floor():
		velocity.y += gravity*delta

func move_x():
	var input_axis = Input.get_axis("move_left","move_right")
	velocity.x = input_axis * move_speed

func flip():
	if (is_facing_right and velocity.x<0) or (not is_facing_right and velocity.x>0):
		scale.x *= -1
		is_facing_right = not is_facing_right

#-----------Funciones de control de vida---------------------

func respawn():
	is_dead = false
	set_physics_process(true)
	get_tree().call_group("death_ui","hide")

func die():
	is_dead = true
	set_physics_process(false)
	
	get_tree().call_group("death_ui","show")
