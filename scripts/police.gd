extends CharacterBody2D

# Parámetros exportables para ajustar fácilmente el comportamiento
@export var health: int = 100
@export var patrol_speed: float = 50.0
@export var chase_speed: float = 100.0
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var lose_interest_range: float = 300.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0  # Tiempo entre ataques
@export var distance_movement:int = 100

# Referencias a nodos
@onready var animated_sprite = $AnimatedSprite
@onready var patrol_timer = $PatrolTimer
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var attack_area = $AttackArea
@onready var damagePolice = $damagePolice

# Variables para el patrullaje
var patrol_positions = []
var current_patrol_index = 0
var patrol_direction = 1
var waiting_at_patrol_point = false  # Nueva variable para controlar el estado de espera

# Variables de estado
enum State { PATROL, CHASE, ATTACK, HURT, DEATH }
var current_state = State.PATROL
var player = null
var isdead = false
var can_attack = true
var is_facing_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("enemies")
	
	# Inicializar el temporizador de patrullaje
	if !patrol_timer:
		patrol_timer = Timer.new()
		patrol_timer.wait_time = 2.0
		patrol_timer.one_shot = true
		add_child(patrol_timer)
	
	# Inicializar el temporizador de enfriamiento de ataque
	if !attack_cooldown_timer:
		attack_cooldown_timer = Timer.new()
		attack_cooldown_timer.wait_time = attack_cooldown
		attack_cooldown_timer.one_shot = true
		add_child(attack_cooldown_timer)
	
	# Conectar señales
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	
	# Configurar posiciones de patrullaje
	# Usamos la posición actual como punto central
	var center_position = global_position
	patrol_positions = [
		Vector2(center_position.x - distance_movement, center_position.y),
		Vector2(center_position.x + distance_movement, center_position.y)
	]
	
	# Iniciar animación idle
	animated_sprite.play("idle")
	
func _physics_process(delta):
	# No procesar lógica si está muerto o herido
	if current_state == State.DEATH:
		return
	
	# Buscar al jugador si no lo tenemos
	if !player:
		player = get_tree().get_first_node_in_group("player")
	
		# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Detener la caída cuando toca el suelo
	
	match current_state:
		State.PATROL:
			patrol_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state()
		State.HURT:
			# No hacer nada en estado herido, esperar a que la animación termine
			pass
	
	# Aplicar movimiento
	move_and_slide()
	
	# Actualizar la dirección del sprite
	update_facing()

func patrol_state(_delta):
	# Verificar si el jugador está en rango de detección
	if player and global_position.distance_to(player.global_position) < detection_range:
		change_state(State.CHASE)
		return
	
	# Si ya estamos esperando, no hacer nada hasta que el temporizador termine
	if waiting_at_patrol_point:
		return
	
	# Si llegamos a un punto de patrulla, cambiamos de dirección
	if global_position.distance_to(patrol_positions[current_patrol_index]) < 10:
		waiting_at_patrol_point = true  # Indicar que estamos esperando
		velocity.x = 0
		animated_sprite.play("idle")
		patrol_timer.start()
	else:
		# Moverse hacia el punto de patrulla actual
		var direction = (patrol_positions[current_patrol_index] - global_position).normalized()
		velocity.x = direction.x * patrol_speed
		if isdead == false : 
			animated_sprite.play("walk")
		else: 
			animated_sprite.play("death")

func chase_state(_delta):
	if !player:
		change_state(State.PATROL)
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Si el jugador está demasiado lejos, volver a patrullar
	if distance_to_player > lose_interest_range:
		change_state(State.PATROL)
		return
	
	# Si el jugador está en rango de ataque, atacar
	if distance_to_player < attack_range and can_attack:
		change_state(State.ATTACK)
		return
	
	# Moverse hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * chase_speed
	animated_sprite.play("run") 

func attack_state():
	velocity.x = 0
	animated_sprite.play("attack")  # Asumiendo que tienes una animación "attack"
	can_attack = false
	attack_cooldown_timer.start()
	
	# Activar el área de ataque
	if attack_area:
		attack_area.monitoring = true
	
	# Esperar a que termine la animación de ataque
	await animated_sprite.animation_finished
	
	# Desactivar el área de ataque
	if attack_area:
		attack_area.monitoring = false
	
	# Volver a perseguir al jugador
	change_state(State.CHASE)
	

func take_damage(damage):
	health -= damage
	
	if health <= 0:
		change_state(State.DEATH)
		return
	
	# Cambiar al estado herido
	change_state(State.HURT)
	
	# Reproducir animación de daño
	animated_sprite.play("hurt")
	damagePolice.play()
	start_blinking()
	
	# Esperar a que termine la animación
	await animated_sprite.animation_finished
	
	# Volver a perseguir o patrullar
	if player and global_position.distance_to(player.global_position) < detection_range:
		change_state(State.CHASE)
	else:
		change_state(State.PATROL)

func die():
	isdead = true
	velocity = Vector2.ZERO  # Detener todo movimiento
	set_physics_process(false)  # Desactivar el procesamiento físico
	collision_layer = 0  # Desactivar colisiones 
	collision_mask = 0
	animated_sprite.stop()
	animated_sprite.play("death")
	
	# Esperar a que termine la animación antes de eliminar
	await animated_sprite.animation_finished
	# Una vez terminada la animación, eliminar el objeto
	queue_free()

func start_blinking():
	var blink_color = Color(1, 0.5, 0.5, 1)
	var normal_color = Color(1, 1, 1, 1)
	
	for i in range(6):
		modulate = blink_color
		await get_tree().create_timer(0.1).timeout
		modulate = normal_color
		await get_tree().create_timer(0.1).timeout
	
	modulate = normal_color

func change_state(new_state):
	current_state = new_state
	
	if new_state == State.DEATH:
		die()
	
	# Resetear variables específicas de estado si es necesario
	if new_state == State.PATROL:
		waiting_at_patrol_point = false

func update_facing():
	var should_face_right = velocity.x > 0
	
	if should_face_right != is_facing_right:
		scale.x *= -1
		is_facing_right = should_face_right

func _on_patrol_timer_timeout():
	print("Patrol timer timeout - changing patrol point")
	# Cambiar al siguiente punto de patrulla
	current_patrol_index = (current_patrol_index + 1) % patrol_positions.size()
	# Resetear la variable de espera para permitir el movimiento
	waiting_at_patrol_point = false
	# Reiniciar el movimiento inmediatamente
	var direction = (patrol_positions[current_patrol_index] - global_position).normalized()
	velocity.x = direction.x * patrol_speed
	if isdead == false : 
		animated_sprite.play("walk")
	else: 
		animated_sprite.play("death")

func _on_attack_cooldown_timeout():
	can_attack = true

# Esta función será llamada cuando el área de ataque del policía golpee al jugador
func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and current_state == State.ATTACK:
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
