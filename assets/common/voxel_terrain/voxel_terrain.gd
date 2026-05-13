extends VoxelTerrain # или VoxelLodTerrain

const WORLDS = {
	"basic": preload("res://assets/common/generation/basic/basic.tres"),
	"flat": preload("res://assets/common/generation/flat/flat.tres"),
	"sky_blocks": preload("res://assets/common/generation/sky_blocks/sky_blocks.tres"),
	"basic_plus": preload("res://assets/common/generation/basic_plus/basic_plus.tres"),
	"debug_world": preload("res://assets/common/generation/debug_world/debug_world.tres")
}

var optimize_timer : float = 0.0
const OPTIMIZE_INTERVAL : float = 3.0 
var last_fps_state : int = -1 

# АВТОМАТИЧЕСКОЕ ОПРЕДЕЛЕНИЕ ЯДЕР
# На твоем AMD A9 это вернет 2.
@onready var system_threads : int = OS.get_processor_count()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	generator = WORLDS.get(GlobalValues.world_type, WORLDS["basic"])
	
	# Устанавливаем дистанцию один раз
	if "view_distance" in self:
		set("view_distance", GlobalValues.render_distance)
	
	# Начальная безопасная настройка
	_apply_optimization(1, 1, 2)
	
	
	
	
	


func _process(delta: float) -> void:
	optimize_timer += delta
	if optimize_timer >= OPTIMIZE_INTERVAL:
		optimize_timer = 0.0
		_dynamic_thread_optimization()

func _dynamic_thread_optimization() -> void:
	var fps = Engine.get_frames_per_second()
	
	var current_state = 0 # Лагает
	if fps > 50: current_state = 2 # Летит
	elif fps > 25: current_state = 1 # Нормально
	
	if current_state == last_fps_state:
		return
	last_fps_state = current_state

	match current_state:
		0: # КРИТИЧЕСКИ: Оставляем только 1 поток, чтобы спасти FPS
			_apply_optimization(1, 1, 2)
		1: # НОРМА: Оптимальное количество ядер
			# Если ядер 2, берем 1. Если ядер 8, берем 4-6.
			var safe_threads = max(1, system_threads - 1)
			_apply_optimization(safe_threads, 2, 4)
		2: # МАКСИМУМ: Используем всё, что есть
			_apply_optimization(system_threads, 4, 8)

func _apply_optimization(threads: int, m_limit: int, d_limit: int) -> void:
	# Установка потоков генерации
	if "max_block_generation_threads" in self:
		set("max_block_generation_threads", threads)
	
	# Установка лимитов обновления кадров
	set("max_mesh_updates_per_frame", m_limit)
	set("max_data_updates_per_frame", d_limit)
	
	# print("Auto-Optimization: Threads=", threads, " MeshLimit=", m_limit)
