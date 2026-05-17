extends WorldEnvironment

@export var day_length: float = 125.0
@export var time_gradient: Gradient

var sky_material: Material

func _ready() -> void:
	# 1. Проверяем, настроено ли небо в WorldEnvironment
	if not environment or not environment.sky:
		push_error("Ошибка: В WorldEnvironment не настроен Sky (Небо)!")
		set_process(false)
		return
		
	sky_material = environment.sky.sky_material
	if not sky_material:
		push_error("Ошибка: У Sky отсутствует SkyMaterial!")
		set_process(false)
		return

	# 2. Если градиент не задан в инспекторе, создаем его программно, чтобы не было ошибки
	if not time_gradient:
		_create_default_gradient()

func _process(delta: float) -> void:
	# Глобальное время может быть не инициализировано в синглтоне
	if not ("time" in GlobalValues):
		push_error("Ошибка: В скрипте GlobalValues нет переменной time!")
		set_process(false)
		return

	# Рассчитываем время суток [0.0; 24.0)
	var time_step: float = (24.0 / day_length) * delta
	GlobalValues.time = fmod(GlobalValues.time + time_step, 24.0)
	
	# Получаем позицию на градиенте (от 0.0 до 1.0)
	var gradient_position: float = GlobalValues.time / 24.0
	var current_sky_color: Color = time_gradient.sample(gradient_position)
	
	# Безопасное изменение цвета (работает и с Procedural, и с Panorama, и с Physical небом)
	if "sky_top_color" in sky_material:
		sky_material.set("sky_top_color", current_sky_color)
	if "sky_horizon_color" in sky_material:
		sky_material.set("sky_horizon_color", current_sky_color)

# Функция генерации базовых цветов, если инспектор пустой
func _create_default_gradient() -> void:
	time_gradient = Gradient.new()
	time_gradient.clear_points()
	time_gradient.add_point(0.0, Color("0a0a14"))   # 00:00 Ночь
	time_gradient.add_point(0.25, Color("f64343"))  # 06:00 Рассвет
	time_gradient.add_point(0.5, Color("7eccfa"))   # 12:00 День
	time_gradient.add_point(0.75, Color("f64343"))  # 18:00 Закат
	time_gradient.add_point(1.0, Color("0a0a14"))   # 24:00 Ночь
