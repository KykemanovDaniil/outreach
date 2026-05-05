extends Node

# Оставил твои оригинальные названия переменных и путей
@onready var env_scene: PackedScene = preload("res://assets/common/environment/world_environment.tscn")
@onready var dir_light_scene: PackedScene = preload("res://assets/common/environment/directoinal_light_3d/directional_light_3d.tscn")
@onready var sky : PackedScene = preload("res://assets/common/environment/sky/sky.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Экономим ресурсы CPU на твоем AMD E2 в меню
	PhysicsServer3D.set_active(false)
	PhysicsServer2D.set_active(false)
	create()

func create() -> void:  
	var scene_path := ""
	if get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path.ends_with("game.tscn"):
		refresh_world()
	else:
		# Чистим мусор при выходе в меню
		_clear_world_nodes()

# Вспомогательная функция для очистки игровых нод в меню
func _clear_world_nodes():
	for n in ["sky", "WorldEnvironment", "dir_light"]:
		var node = get_node_or_null(n)
		if node: node.queue_free()

func refresh_world() -> void:
	_setup_render_distance()
	_setup_environment()
	_setup_sky()
	_setup_light()

func _setup_render_distance() -> void:
	var terrain_nodes := get_tree().get_nodes_in_group("terrain")
	for t in terrain_nodes:
		if "max_view_distance" in t:
			t.max_view_distance = GlobalValues.render_distance * 16
			
	var viewers := get_tree().get_nodes_in_group("visual_block")
	for viewer in viewers:
		if is_instance_valid(viewer) and "view_distance" in viewer:
			viewer.view_distance = GlobalValues.render_distance * 16

func _setup_sky() -> void:
	var scene_path := ""
	if get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path.ends_with("game.tscn"):
	# Ищем существующий, чтобы не плодить 2000 объектов
		var sky_instance = get_node_or_null("sky")
	
		if not GlobalValues.sky:
			if sky_instance: sky_instance.queue_free()
			return

		if not sky_instance:
			sky_instance = sky.instantiate()
			sky_instance.name = "sky"
			add_child(sky_instance)

func _setup_environment() -> void:
	var scene_path := ""
	if get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path.ends_with("game.tscn"):
		var env_instance = get_node_or_null("WorldEnvironment")
		
		if not GlobalValues.environment:
			if env_instance: env_instance.queue_free()
			return
			
		if not env_instance:
			env_instance = env_scene.instantiate()
			env_instance.name = "WorldEnvironment"
			add_child(env_instance)
	
		if env_instance.environment:
			var res = env_instance.environment
			res.glow_enabled = GlobalValues.glow
			res.fog_enabled = GlobalValues.fog
			res.fog_depth_end = GlobalValues.render_distance * 16
			res.fog_depth_begin = (GlobalValues.render_distance * 16) / 4

func _setup_light() -> void:
	# Ищем существующий свет по имени, а не по группе, чтобы не спамить
	var light = get_node_or_null("dir_light")
	
	if not GlobalValues.direction_light:
		if light: light.queue_free()
		return

	if not light:
		light = dir_light_scene.instantiate()
		light.name = "dir_light"
		light.add_to_group("dir_light")
		add_child(light)
	
	if light is DirectionalLight3D:
		light.shadow_enabled = GlobalValues.shadows
