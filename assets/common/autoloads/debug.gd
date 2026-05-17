extends Node

@onready var env_scene: PackedScene = preload("res://assets/common/environment/world_environment.tscn")
@onready var clouds : PackedScene = preload("res://assets/common/environment/clouds/clouds.tscn")
@onready var post_processing : PackedScene = preload("res://assets/common/materials/post_processing/post_processing.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	create()

func create() -> void:  
	refresh_world()

# Вспомогательная функция для очистки игровых нод в меню
func _clear_world_nodes():
	for n in ["clouds", "PostProcessing"]:
		var node = get_node_or_null(n)
		if node: node.queue_free()

func refresh_world() -> void:
	_setup_render_distance()
	_setup_environment()
	_setup_clouds()
	_setup_post_processing()

func _setup_post_processing() -> void:
	var pp_instance = get_node_or_null("PostProcessing")
	
	# Допустим, в GlobalValues у тебя есть переменная dither_enabled
	# Если такой нет, можно просто проверять GlobalValues.environment
	if not GlobalValues.post_processing: 
		if pp_instance: pp_instance.queue_free()
		return
		
	if not pp_instance:
		pp_instance = post_processing.instantiate()
		pp_instance.name = "PostProcessing"
		add_child(pp_instance)

func _setup_render_distance() -> void:
	var terrain_nodes := get_tree().get_nodes_in_group("terrain")
	for t in terrain_nodes:
		if "max_view_distance" in t:
			t.max_view_distance = GlobalValues.render_distance * GlobalValues.chunk_size
			
	var viewers := get_tree().get_nodes_in_group("visual_block")
	for viewer in viewers:
		if is_instance_valid(viewer) and "view_distance" in viewer:
			viewer.view_distance = GlobalValues.render_distance * GlobalValues.chunk_size

func _setup_clouds() -> void:
	var scene_path := ""
	if get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path.ends_with("game.tscn"):
	# Ищем существующий, чтобы не плодить 2000 объектов
		var clouds_instance = get_node_or_null("clouds")
	
		if not GlobalValues.clouds:
			if clouds_instance: clouds_instance.queue_free()
			return

		if not clouds_instance:
			clouds_instance = clouds.instantiate()
			clouds_instance.name = "clouds"
			add_child(clouds_instance)

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
			res.fog_enabled = GlobalValues.fog
			res.fog_depth_end = GlobalValues.render_distance * GlobalValues.chunk_size
			res.fog_depth_begin = (GlobalValues.render_distance * GlobalValues.chunk_size) / GlobalValues.fog_range
