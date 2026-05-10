extends Node3D

# Загружаем скрипт тиков (укажите правильный путь к файлу)
const random_ticks = preload("res://assets/common/voxel_terrain/random_ticks/random_ticks.gd")

func _ready() -> void:
	SoundManager.play_random_music()
	
	# 1. Запускаем создание мира
	Debug.create()
	
	# 2. Активируем Random Ticks
	# Создаем узел и добавляем его в сцену
	var ticks_node = random_ticks.new()
	ticks_node.name = "random_ticks"
	add_child(ticks_node)
