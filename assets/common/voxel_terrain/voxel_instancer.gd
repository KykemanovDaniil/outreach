extends VoxelInstancer

@export var mob_scene : PackedScene  # Перетащи сюда сцену моба в инспекторе
@export var spawn_radius : float = 40.0
@export var spawn_chance : float = 0.3
@export var max_mobs : int = 15
@export var spawn_interval : float = 3.0

var _timer: Timer
var _terrain: VoxelTerrain

func _ready() -> void:
	_terrain = get_parent() as VoxelTerrain
	
	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_try_spawn)

func _try_spawn() -> void:
	# 1. Лимит через группу
	if get_tree().get_nodes_in_group("mobs").size() >= max_mobs:
		return
		
	if randf() > spawn_chance:
		return

	# 2. Поиск точки (с типизацией)
	var cam: Camera3D = get_viewport().get_camera_3d()
	if not cam or not _terrain: 
		return
	
	var random_point: Vector3 = cam.global_position + Vector3(
		randf_range(-spawn_radius, spawn_radius),
		30.0,
		randf_range(-spawn_radius, spawn_radius)
	)
	
	# 3. Рейкаст (с типизацией)
	var vt: VoxelTool = _terrain.get_voxel_tool()
	var hit: VoxelRaycastResult = vt.raycast(random_point, Vector3.DOWN, 60.0)
	
	if hit:
		var final_pos: Vector3 = Vector3(hit.position) + Vector3(0.5, 1.0, 0.5)
		_spawn_mob_node(final_pos)

func _spawn_mob_node(pos: Vector3) -> void:
	if not mob_scene:
		return
		
	var mob: Node3D = mob_scene.instantiate() as Node3D
	# Добавляем в корень сцены, чтобы моб не двигался вместе с инстансером
	get_tree().current_scene.add_child(mob)
	mob.global_position = pos
	mob.rotation.y = randf_range(0, TAU) # TAU это 360 градусов в радианах
	
	# Убедись, что в скрипте самого моба есть add_to_group("mobs") 
	# или добавь его здесь:
	mob.add_to_group("mobs")
