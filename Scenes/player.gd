extends CharacterBody2D

@export var move_speed:float
@export var health:float = 40
@export var jump_speed:float
@export var attack_damage:int = 50  # Daño que hace cada ataque
@onready var animated_sprite = $AnimatedSprite
@onready var attack_area = $AttackArea # Área de colisión para el ataque (deberás crearla)
@export var invulnerability_duration:float = 1.0  # Duración de la inmunidad en segundos

var is_invulnerable = false
var is_facing_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false

func _ready():
	add_to_group("player")
	# Conectar la señal animation_finished
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Inicialmente desactivar el área de ataque
	attack_area.monitoring = false

func _physics_process(delta):
	jump(delta)
	move_x()
	flip()
	update_animations()
	move_and_slide()
	
	
func take_damage(attack_damage):
	# Solo recibir daño si no está en estado de inmunidad
	if is_invulnerable:
		return

	health -= attack_damage
	
	if health <= 0:
		die()
		return
	
	# Activar la inmunidad temporal
	is_invulnerable = true
	start_blinking()

	# Usar un Timer para restaurar la vulnerabilidad
	await get_tree().create_timer(invulnerability_duration).timeout
	is_invulnerable = false
	modulate = Color(1, 1, 1, 1)  # Asegurarse de que el color vuelva a ser normal


func start_blinking():
	# Efecto de parpadeo durante la inmunidad
	var blink_color = Color(1, 0.5, 0.5, 1)  # Rojo suave
	var normal_color = Color(1, 1, 1, 1)     # Color normal

	for i in range(10):  # Ajusta para más o menos parpadeos
		modulate = blink_color
		await get_tree().create_timer(0.1).timeout
		modulate = normal_color
		await get_tree().create_timer(0.1).timeout
	
	modulate = normal_color
	

func die():
	velocity = Vector2.ZERO  # Detener todo movimiento
	set_physics_process(false)  # Desactivar el procesamiento físico
	collision_layer = 0  # Desactivar colisiones 
	collision_mask = 0
	
	animated_sprite.play("death")
	
	# Esperar a que termine la animación antes de eliminar
	await animated_sprite.animation_finished
	# Una vez terminada la animación, eliminar el objeto
	queue_free()

	
	
func update_animations():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		animated_sprite.play("attack")
		is_attacking = true
		# Activar el área de ataque cuando comienza la animación de ataque
		attack_area.monitoring = true
	
	# Si está atacando, no cambiar la animación
	if is_attacking:
		return
	
	if velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func _on_animation_finished():
	# Esta función se llamará cuando termine cualquier animación
	if animated_sprite.animation == "attack":
		is_attacking = false
		# Desactivar el área de ataque cuando termina la animación
		attack_area.monitoring = false
		# Volver a la animación correspondiente
		if velocity.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

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
		# Cuando el personaje se voltea, también voltear la posición del área de ataque
		attack_area.position.x *= -1

# Esta función será llamada cuando el área de ataque detecte un cuerpo
func _on_attack_area_body_entered(body):
	if body.is_in_group("enemies") and is_attacking:
		# Verificar si el cuerpo tiene el método "take_damage"
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
