extends Node3D

func _ready() -> void:
	SoundManager.play_random_music()
	# 1. Запускаем создание мира через ваш дебаг/менеджер
	Debug.create()
