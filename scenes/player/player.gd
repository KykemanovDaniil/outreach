extends Camera3D

@export var inventory_scene : PackedScene
@export var options_scene : PackedScene

const Util = preload("res://assets/common/util.gd")

@export var speed := 10.0
@export var acceleration := 8.0
@export var friction := 6.0
@export var sensitivity := 0.15
@export var click_range := 25.0

var _velocity := Vector3.ZERO
var _mouse_input := Vector2.ZERO
var _vt: RefCounted 
var _cursor : MeshInstance3D = null

func _ready() -> void:
	# Инициализация курсора (сетки) как в оригинальном коде
	var mesh := Util.create_wirecube_mesh(Color(0.0, 0.0, 0.0, 1.0))
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.set_scale(Vector3(1,1,1)*1.01)
	_cursor = mesh_instance
	
	# Добавляем курсор в сцену
	get_parent().add_child.call_deferred(_cursor)
	
	# Спавн игрока
	if GlobalValues.world_type == "debug_world":
		global_position = Vector3(0, 5, 0)
	else:
		var rng = RandomNumberGenerator.new()
		rng.seed = GlobalValues.world_seed
		var spawn_x = rng.randi_range(-1000, 1000)
		var spawn_z = rng.randi_range(-1000, 1000)
		var spawn_y = rng.randi_range(60, 85)
		global_position = Vector3(spawn_x, spawn_y, spawn_z)

	fov = GlobalValues.fov
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var terrain := get_node_or_null("../VoxelTerrain")
	if terrain:
		_vt = terrain.get_voxel_tool()
		_vt.channel = VoxelBuffer.CHANNEL_TYPE

# Функция получения блока с явным указанием типа, чтобы не было ошибки infer type
func _get_pointed_voxel() -> VoxelRaycastResult:
	if _vt == null: 
		return null
	var origin := global_transform.origin
	var forward := -global_transform.basis.z.normalized()
	var hit : VoxelRaycastResult = _vt.raycast(origin, forward, click_range)
	return hit

func _input(event: InputEvent) -> void:
	var e_pressed = event.is_action_pressed("e")
	var esc_pressed = event.is_action_pressed("esc")

	if e_pressed or esc_pressed:
		if WindowManager.window_stack.is_empty():
			if e_pressed:
				WindowManager.open_window(inventory_scene)
			elif esc_pressed:
				WindowManager.open_window(options_scene)
		else:
			WindowManager.close_last_window()
		
		get_viewport().set_input_as_handled()
		return
	
	if get_tree().paused:
		return
	
	if event is InputEventMouseMotion:
		_mouse_input += event.relative
	
	if _vt:
		if event.is_action_pressed("left_click"):
			_modify_voxel(true)
		elif event.is_action_pressed("right_click"):
			_modify_voxel(false)

func _modify_voxel(is_mining: bool) -> void:
	var hit := _get_pointed_voxel()
	if not hit: 
		return

	if is_mining:
		_vt.set_voxel(hit.position, 0)
	else:
		var b_id : int = GlobalValues.current_block if "current_block" in GlobalValues else 1
		_vt.set_voxel(hit.previous_position, b_id)

func _process(delta: float) -> void:
	# Отображение курсора (сетки)
	if _vt and _cursor:
		var hit := _get_pointed_voxel()
		if hit != null:
			_cursor.show()
			_cursor.set_position(hit.position)
		else:
			_cursor.hide()

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	# 1. Поворот
	fov = GlobalValues.fov
	var rot_multi := deg_to_rad(sensitivity * (fov / GlobalValues.max_fov))
	rotation.y -= _mouse_input.x * rot_multi
	rotation.x = clamp(rotation.x - _mouse_input.y * rot_multi, -1.5, 1.5)
	_mouse_input = Vector2.ZERO

	# 2. Расчет направлений
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var forward := Vector3(global_transform.basis.z.x, 0, global_transform.basis.z.z).normalized()
	var right := Vector3(global_transform.basis.x.x, 0, global_transform.basis.x.z).normalized()
	var vertical := Input.get_axis("shift", "space")
	var move_dir := (forward * input_dir.y + right * input_dir.x + Vector3.UP * vertical).normalized()
	
	# 3. Движение
	var target_vel := move_dir * speed
	var weight := acceleration if move_dir.length() > 0 else friction
	_velocity = _velocity.lerp(target_vel, weight * delta)
	
	global_position += _velocity * delta
