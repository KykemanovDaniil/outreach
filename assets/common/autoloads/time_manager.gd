extends Node

@export var day_length : float = 125.0
var time : float = 12.0
var time_step : float
var sky : ProceduralSkyMaterial

func _ready() -> void:
	# Даем время на загрузку всех сцен
	await get_tree().process_frame
	
	# Ищем узел во всем дереве сцены более агрессивно
	var env_node = get_tree().root.find_child("WorldEnvironment", true, false)
	
	# Если не нашел, попробуем поискать по типу (на случай если он переименован)
	if not env_node:
		var env_nodes = get_tree().get_nodes_in_group("environment") # Если добавишь в группу
		if env_nodes.size() == 0:
			# Последняя попытка: перебор всех узлов
			for node in get_tree().root.get_children():
				if node is WorldEnvironment:
					env_node = node
					break

	if env_node and env_node.environment and env_node.environment.sky:
		# Дублируем ресурсы, чтобы не было лагов при записи в .tres
		env_node.environment = env_node.environment.duplicate()
		env_node.environment.sky = env_node.environment.sky.duplicate()
		sky = env_node.environment.sky.sky_material.duplicate()
		env_node.environment.sky.sky_material = sky
		print("WorldEnvironment найден, небо инициализировано!")
	else:
		push_error("WorldEnvironment все еще не найден! Проверь, что он есть в сцене, которую ты запускаешь.")

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.25 
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	time_step = (24.0 / day_length) * timer.wait_time

func _on_timer_timeout() -> void:
	time += time_step
	if time >= 24.0: time -= 24.0
	
	if not sky: return

	# Твоя логика переходов
	if time >= 17.0 and time <= 19.0:
		var t = (time - 17.0) / 2.0
		sky.sky_top_color = Color("7eccfa").lerp(Color("f64343"), t)
	elif time > 19.0 and time <= 21.0:
		var t = (time - 19.0) / 2.0
		sky.sky_top_color = Color("f64343").lerp(Color("0a0a14"), t)
	elif time > 21.0 or time < 5.0:
		sky.sky_top_color = Color("0a0a14")
