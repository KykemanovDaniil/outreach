extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Сиды для генерации
var world_seed : int = 0
var cave_seed : int = 0
var tree_seed : int = 0
var cloud_seed : int = 0

var world_type : String = "basic"

# Нагружаем значения из системы сохранений
var render_distance : int = SaveSystem.get_val("Graphics", "render_distance", 4)
var clouds : bool = SaveSystem.get_val("Graphics", "clouds", true)
var shadows : bool = false
var fog : bool = true
var glow : bool = SaveSystem.get_val("Graphics", "glow", false)
var environment : bool = true
var direction_light : bool = false

# Геймплейные переменные
var current_block : int = 1 # Лучше поставить 1 (камень/земля), чтобы не ставить "воздух" (0)

var fov : int = SaveSystem.get_val("Graphics", "fov", 75)

var max_fov : int = 145
var min_fov : int = 1

# V-Sync
var v_sync : bool = SaveSystem.get_val("Graphics", "v_sync", true)

var music_volume : float = 1.0#SaveSystem.get_val("Graphics", "music_volume", 1.0)
var sfx_volume : float = 1.0#SaveSystem.get_val("Graphics", "sfx_volume", 1.0)

func _ready() -> void:
	# Применяем V-Sync сразу при запуске игры
	var mode = DisplayServer.VSYNC_ENABLED if v_sync else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)
	
	# Можно также вызвать начальную настройку графики, если Debug уже готов
	# К этому моменту остальные системы (Debug) могут быть еще не загружены, 
	# поэтому лучше вызывать применение графики в первом кадре игры.
