extends Node
var music_player = AudioStreamPlayer.new()
var current_track = null
var volume_db = -20.0  # Valor inicial a -20dB
var min_volume_db = -80.0  # Volumen mínimo
var max_volume_db = 0.0   # Volumen máximo (0dB)


func _ready():
	add_child(music_player)
	music_player.bus = "Master"
	load_settings()
	
	# Agregar una señal para detectar cuando la música termina
	music_player.finished.connect(_on_music_finished)

func play_music(track_path):
	if current_track == track_path and music_player.playing:
		return
	
	current_track = track_path
	var music = load(track_path)
	music_player.stream = music
	music_player.volume_db = volume_db
	music_player.play()

# Esta función se llamará automáticamente cuando la música termine
func _on_music_finished():
	# Si la música ha terminado, la reiniciamos
	if current_track != null:
		music_player.play()

# Función mejorada para verificar y reiniciar la música
func ensure_music_playing():
	if current_track != null and not music_player.playing:
		music_player.play()

func set_volume(value):
	# Usamos una curva exponencial para mapear mejor la percepción auditiva humana
	# Para que el punto medio sea exactamente -50dB
	if value <= 0:
		volume_db = min_volume_db
	elif value >= 1:
		volume_db = max_volume_db
	else:
		# Calculamos el valor de -50dB cuando value = 0.5
		# y -80dB cuando value = 0, y 0dB cuando value = 1
		if value < 0.5:
			# Mapear de 0-0.5 a -80dB a -50dB
			volume_db = lerp(min_volume_db, -50.0, value * 2.0)
		else:
			# Mapear de 0.5-1 a -50dB a 0dB
			volume_db = lerp(-50.0, max_volume_db, (value - 0.5) * 2.0)
	
	music_player.volume_db = volume_db
	save_settings()
	
func get_volume():
	# Invertimos la conversión para obtener el valor correcto del slider
	if volume_db <= min_volume_db:
		return 0.0
	elif volume_db >= max_volume_db:
		return 1.0
	elif volume_db <= -50.0:
		# Convertimos de -80dB a -50dB a un valor entre 0 y 0.5
		return inverse_lerp(min_volume_db, -50.0, volume_db) * 0.5
	else:
		# Convertimos de -50dB a 0dB a un valor entre 0.5 y 1
		return 0.5 + inverse_lerp(-50.0, max_volume_db, volume_db) * 0.5
	
func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "volume", volume_db)
	config.save("user://audio_settings.cfg")
	
func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	if err == OK:
		volume_db = config.get_value("audio", "volume", -20.0)  # Cambiado a -20.0 para ser consistente
	else:
		volume_db = -20.0  # Valor predeterminado si no hay configuración
	
	music_player.volume_db = volume_db

# Opcionalmente, puedes agregar este método para comprobar periódicamente
func _process(_delta):
	# Verificar si la música debería estar sonando pero no lo está
	if current_track != null and not music_player.playing:
		music_player.play()
