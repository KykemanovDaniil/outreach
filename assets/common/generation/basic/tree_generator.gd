extends RefCounted

const Structure = preload("./structure.gd")

# Параметры для настройки "красоты"
var trunk_len_min := 8
var trunk_len_max := 16
var log_type := 1
var leaves_type := 2
var channel := 0 

# Объект рандома, который будет зависеть от сида
var _rng := RandomNumberGenerator.new()

# Функция генерации теперь принимает порядковый номер варианта дерева
func generate(variant_index: int) -> Object:
	# Устанавливаем сид на основе глобального tree_seed и индекса варианта
	_rng.seed = GlobalValues.tree_seed + variant_index
	
	var voxels := {}
	
	# 1. Параметры дерева (используем _rng вместо глобального rand)
	var trunk_len := _rng.randi_range(trunk_len_min, trunk_len_max)
	var branch_start_y := int(trunk_len * 0.3)
	
	# 2. Ствол
	for y in trunk_len:
		voxels[Vector3i(0, y, 0)] = log_type
	
	# 3. Ветки и лиственные шапки
	var num_branches := int(trunk_len * 0.8)
	for i in num_branches:
		var y = _rng.randi_range(branch_start_y, trunk_len - 1)
		
		var height_factor = float(y - branch_start_y) / float(trunk_len - branch_start_y)
		var max_branch_len = (trunk_len / 3.0) * (1.1 - height_factor)
		
		var branch_len := _rng.randi_range(2, int(max_branch_len + 2))
		var angle := _rng.randf_range(0, TAU)
		var dir := Vector3(cos(angle), _rng.randf_range(0.2, 0.6), sin(angle)).normalized()
		
		var pos := Vector3(0, y, 0)
		var last_ipos := Vector3i(0, y, 0)
		
		# Растим ветку
		for step in branch_len:
			pos += dir
			last_ipos = Vector3i(pos.round())
			voxels[last_ipos] = log_type
		
		# 4. Генерируем "облако" листьев на конце каждой ветки
		var leaf_radius = _rng.randf_range(2.0, 3.5)
		_draw_leaf_sphere(voxels, last_ipos, leaf_radius)

	# Добавим пышную шапку на саму макушку
	_draw_leaf_sphere(voxels, Vector3i(0, trunk_len, 0), 3.0)

	return _build_structure(voxels)

# Вспомогательная функция для создания сфер листвы
func _draw_leaf_sphere(voxels: Dictionary, center: Vector3i, radius: float):
	var r_sq = radius * radius
	var r_int = int(radius) + 1
	
	for dx in range(-r_int, r_int + 1):
		for dy in range(-r_int, r_int + 1):
			for dz in range(-r_int, r_int + 1):
				var dist_sq = dx*dx + dy*dy + dz*dz
				# Используем детерминированный рандом для формы сферы
				if dist_sq <= r_sq * (0.8 + _rng.randf() * 0.4):
					var p = center + Vector3i(dx, dy, dz)
					if not voxels.has(p):
						voxels[p] = leaves_type

func _build_structure(voxels: Dictionary) -> Object:
	if voxels.is_empty(): return null
	
	var min_p := Vector3i(999, 999, 999)
	var max_p := Vector3i(-999, -999, -999)
	for p in voxels:
		min_p.x = min(min_p.x, p.x); min_p.y = min(min_p.y, p.y); min_p.z = min(min_p.z, p.z)
		max_p.x = max(max_p.x, p.x); max_p.y = max(max_p.y, p.y); max_p.z = max(max_p.z, p.z)
	
	var size = max_p - min_p + Vector3i(1, 1, 1)
	var structure = Structure.new()
	structure.offset = -min_p
	structure.voxels.create(size.x, size.y, size.z)
	
	for p in voxels:
		var lp = p - min_p
		structure.voxels.set_voxel(voxels[p], lp.x, lp.y, lp.z, channel)
		
	return structure
