extends Control
@onready var slider_volumen = $Botones/SliderVolumen  # Referencia a tu HSlider

func _ready():
	# Aseguramos que el slider tenga los valores correctos
	slider_volumen.min_value = 0.0
	slider_volumen.max_value = 1.0
	slider_volumen.step = 0.01
	
	# Configura el slider con el valor actual
	slider_volumen.value = MusicController.get_volume()
	
	# Si es la primera vez, establecemos a la mitad
	if abs(slider_volumen.value - 0.5) < 0.01:
		MusicController.set_volume(0.5)  # Esto establecerá el volumen a -50dB
	
	slider_volumen.connect("value_changed", Callable(self, "_on_volume_changed"))

func _on_volume_changed(value):
	MusicController.set_volume(value)

func _on_atras_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
