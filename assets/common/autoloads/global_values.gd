extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Сиды для генерации
var world_seed : int = 0
var cave_seed : int = 0
var tree_seed : int = 0
var cloud_seed : int = 0

var world_type : String = "basic"

var chunk_size : int = 32
var chunk_volume = pow(chunk_size, 3)

var fog_range : int = SaveSystem.get_val("options", "fog_range", 4)

var random_tick_speed: int = 6

var render_distance : int = SaveSystem.get_val("options", "render_distance", 4)
var update_distance : int = SaveSystem.get_val("options", "update_distance", 2)

var clouds : bool = SaveSystem.get_val("options", "clouds", true)
var shadows : bool = false
var fog : bool = true
var glow : bool = SaveSystem.get_val("options", "glow", false)
var post_processing : bool = SaveSystem.get_val("options", "post_processing", true)
var direction_light : bool = false
var environment : bool = true

# Геймплейные переменные
var current_block : int = 1 # Лучше поставить 1 (камень/земля), чтобы не ставить "воздух" (0)

var fov : int = SaveSystem.get_val("options", "fov", 75)

var max_fov : int = 145
var min_fov : int = 1

# V-Sync
var v_sync : bool = SaveSystem.get_val("options", "v_sync", true)

var music_volume : float = SaveSystem.get_val("audio", "music_volume", 1.0)
var sfx_volume : float = SaveSystem.get_val("audio", "sfx_volume", 1.0)

func _ready() -> void:
	# Применяем V-Sync сразу при запуске игры
	var mode = DisplayServer.VSYNC_ENABLED if v_sync else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)
	
	# Можно также вызвать начальную настройку графики, если Debug уже готов
	# К этому моменту остальные системы (Debug) могут быть еще не загружены, 
	# поэтому лучше вызывать применение графики в первом кадре игры.
