extends CharacterBody2D
@export var health:int
@onready var animated_sprite = $AnimatedSprite

func _ready():
	add_to_group("enemies")
	# Iniciar con la animación idle
	if animated_sprite != null:
		animated_sprite.play("idle")

func _process(_delta):
	# Si no está en una animación específica (hurt o death), asegurarse de que esté en idle
	if animated_sprite != null and animated_sprite.animation != "hurt" and animated_sprite.animation != "death":
		animated_sprite.play("idle")

func take_damage(damage):
	health -= damage

	if health <= 0:
		start_blinking()
		die()
		return
		
	# Reproducir la animación de daño inmediatamente
	if animated_sprite != null:
		animated_sprite.play("hurt")


	start_blinking()

	# Continuar con la lógica de muerte sin retraso
	
	if health > 0:
	# Esperar a que termine la animación de daño
		await animated_sprite.animation_finished
		animated_sprite.play("idle")
	

func start_blinking():
	# Colores para el parpadeo: rojo suave y color normal
	var blink_color = Color(1, 0.5, 0.5, 1)  # Rojo suave
	var normal_color = Color(1, 1, 1, 1)     # Color normal

	for i in range(6):  # Número de parpadeos (ajusta el número)
		modulate = blink_color
		await get_tree().create_timer(0.1).timeout  # Velocidad del parpadeo
		modulate = normal_color
		await get_tree().create_timer(0.1).timeout
	
	# Asegurarse de que el color vuelva a ser normal
	modulate = normal_color

func die():
	if animated_sprite != null:
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	
	# Eliminar el personaje
	queue_free()
