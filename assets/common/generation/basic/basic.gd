#tool extends VoxelGeneratorScript  
const Structure = preload("./structure.gd") 
const TreeGenerator = preload("./tree_generator.gd") 
const HeightmapCurve = preload("./heightmap_curve.tres")  

const AIR = 0 
const DIRT = 2 
const GRASS = 1 
const OAK = 4 
const LEAVES = 5 
const SHORT_GRASS = 12 
const BUTTER_CUP = 13 
const LITTLE_STONE = 37 
const LITTLE_STONES = 36 
const STONE = 3 
const BASALT = 25  

const dirt_depth := 3 
const _CHANNEL = VoxelBuffer.CHANNEL_TYPE  

const _moore_dirs: Array[Vector3i] = [ 	
	Vector3i(-1, 0, -1), Vector3i(0, 0, -1), Vector3i(1, 0, -1), 	
	Vector3i(-1, 0, 0),                      Vector3i(1, 0, 0), 	
	Vector3i(-1, 0, 1),  Vector3i(0, 0, 1),  Vector3i(1, 0, 1) 
]  

var _tree_structures := [] 
var _heightmap_min_y := int(HeightmapCurve.min_value) 
var _heightmap_max_y := int(HeightmapCurve.max_value) 
var _heightmap_range := 0  

var _heightmap_noise := FastNoiseLite.new() 
var _tree_noise := FastNoiseLite.new() 
var _cave_noise := FastNoiseLite.new()  

var _trees_min_y := 0 
var _trees_max_y := 0  

func _init() -> void: 	
	var tree_generator := TreeGenerator.new() 	
	tree_generator.log_type = OAK 	
	tree_generator.leaves_type = LEAVES 	
	for i in 8: 		
		var s := tree_generator.generate(i)  		
		_tree_structures.append(s)   	
		
	var tallest_tree_height := 0 	
	for structure in _tree_structures: 		
		var h := int(structure.voxels.get_size().y) 		
		if tallest_tree_height < h: 			
			tallest_tree_height = h 	
	_trees_min_y = _heightmap_min_y 	
	_trees_max_y = _heightmap_max_y + tallest_tree_height  	
	
	_tree_noise.seed = GlobalValues.tree_seed 	
	_heightmap_noise.seed = GlobalValues.world_seed 	 	
	_heightmap_noise.noise_type = FastNoiseLite.TYPE_VALUE 	
	_heightmap_noise.frequency = 0.0173 	
	_heightmap_noise.fractal_lacunarity = 2.105 	
	_heightmap_noise.fractal_gain = 0.44 	
	_heightmap_noise.fractal_weighted_strength = 0.17 	
	_heightmap_noise.domain_warp_amplitude = 2.52 	
	_heightmap_noise.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT 	 	
	
	_tree_noise.noise_type = FastNoiseLite.TYPE_PERLIN 	
	_tree_noise.frequency = 0.013 	
	_tree_noise.fractal_lacunarity = 2.155 	
	_tree_noise.fractal_gain = 0.39 	 	
	
	_cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_cave_noise.frequency = 0.02          # Делает пещеры крупнее (меньше значение — больше масштаб)
	_cave_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_cave_noise.fractal_octaves = 3       # Меньше октав — более гладкие стены (лучше для FPS)
	_cave_noise.fractal_lacunarity = 2.0
	_cave_noise.fractal_gain = 0.5
	
	
	HeightmapCurve.bake()  

func _get_used_channels_mask() -> int: 	
	return 1 << _CHANNEL  

func _generate_block(buffer: VoxelBuffer, origin_in_voxels: Vector3i, _unused_lod: int) -> void: 	
	var block_size := int(buffer.get_size().x) 	
	var oy := origin_in_voxels.y 	 	
	var chunk_pos := Vector3i( 		
		origin_in_voxels.x >> 4, 		
		origin_in_voxels.y >> 4, 		
		origin_in_voxels.z >> 4)  	
		
	_heightmap_range = _heightmap_max_y - _heightmap_min_y 	

	if origin_in_voxels.y > _heightmap_max_y: 		
		buffer.fill(AIR, _CHANNEL) 	
	elif origin_in_voxels.y + block_size < _heightmap_min_y:
		# Оставляем проверку пещер даже глубоко под землей
		for z in block_size:
			for x in block_size:
				for y in block_size:
					var gx = origin_in_voxels.x + x
					var gy = origin_in_voxels.y + y
					var gz = origin_in_voxels.z + z
					if _cave_noise.get_noise_3d(gx, gy, gz) > 0.3:
						buffer.set_voxel(AIR, x, y, z, _CHANNEL)
					else:
						buffer.set_voxel(STONE, x, y, z, _CHANNEL)
	else: 		
		var column_rng = RandomNumberGenerator.new() 		 		
		var gz := origin_in_voxels.z 		
		for z in block_size: 			
			var gx = origin_in_voxels.x 			
			for x in block_size: 				
				column_rng.seed = _get_chunk_seed_2d(chunk_pos) ^ hash(Vector2i(gx, gz)) 				
				
				var height := _get_height_at(gx, gz) 				
				var relative_height := height - oy 				
				
				for y in block_size:
					var gy = oy + y
					# Проверка на пещеру для каждого вокселя
					if _cave_noise.get_noise_3d(gx, gy, gz) > 0.3:
						buffer.set_voxel(AIR, x, y, z, _CHANNEL)
						continue
					
					# Основная почва
					if gy < height - 1 - dirt_depth:
						buffer.set_voxel(STONE, x, y, z, _CHANNEL)
					elif gy < height - 1:
						buffer.set_voxel(DIRT, x, y, z, _CHANNEL)
					elif gy == height - 1:
						if height >= 0:
							buffer.set_voxel(GRASS, x, y, z, _CHANNEL)
						else:
							buffer.set_voxel(STONE, x, y, z, _CHANNEL)
					# Декорации: ставим только если под нами GRASS и здесь не пещера
					elif gy == height:
						if height >= 0 and column_rng.randf() < 0.2:
							var foliage = SHORT_GRASS 							
							var f_roll = column_rng.randf() 							
							if f_roll < 0.004: foliage = LITTLE_STONES 							
							elif f_roll < 0.007: foliage = LITTLE_STONE 							
							elif f_roll < 0.02: foliage = BUTTER_CUP 							
							elif f_roll < 0.03: foliage = LEAVES 							
							buffer.set_voxel(foliage, x, y, z, _CHANNEL)
				gx += 1 			
			gz += 1  	

	# Деревья 	
	if origin_in_voxels.y <= _trees_max_y and origin_in_voxels.y + block_size >= _trees_min_y: 		
		var voxel_tool := buffer.get_voxel_tool() 		
		var structure_instances := []  		
		_get_tree_instances_in_chunk(chunk_pos, origin_in_voxels, block_size, structure_instances) 		
		for dir in _moore_dirs: 			
			_get_tree_instances_in_chunk(chunk_pos + dir, origin_in_voxels, block_size, structure_instances)  		
		
		for structure_instance in structure_instances: 			
			var pos: Vector3i = structure_instance[0] 			
			var structure: Structure = structure_instance[1] 			
			var lower_corner_pos := pos - structure.offset 			
			var aabb := AABB(lower_corner_pos, structure.voxels.get_size() + Vector3i(1, 1, 1)) 			
			var block_aabb := AABB(Vector3(), buffer.get_size() + Vector3i(1, 1, 1)) 			
			if aabb.intersects(block_aabb): 				
				voxel_tool.paste_masked(lower_corner_pos, structure.voxels, 1 << _CHANNEL, _CHANNEL, AIR)  	
	
	buffer.compress_uniform_channels()  

func _get_tree_instances_in_chunk(cpos: Vector3i, offset: Vector3i, chunk_size: int, tree_instances: Array) -> void: 	
	var rng := RandomNumberGenerator.new() 	
	rng.seed = _get_chunk_seed_2d(cpos) 	 	
	
	for i in 3:  		
		var pos := Vector3i(rng.randi() % chunk_size, 0, rng.randi() % chunk_size) 		
		var gx := cpos.x * chunk_size + pos.x 		
		var gz := cpos.z * chunk_size + pos.z 		 		
		var noise_val = _tree_noise.get_noise_2d(gx, gz) 		 		
		
		if noise_val > 0.1: 			
			var gy = _get_height_at(gx, gz) 			
			# Проверка: дерево спавнится только если точка основания не внутри пещеры
			if gy > 0 and _cave_noise.get_noise_3d(gx, gy, gz) <= 0.3: 				
				tree_instances.append([ 				
					Vector3i(gx, gy, gz) - offset,  				
					_tree_structures[rng.randi() % _tree_structures.size()] 				
				])  

func _get_chunk_seed_2d(cpos: Vector3i) -> int: 	
	return int(cpos.x) ^ (31 * int(cpos.z))  

func _get_height_at(x: int, z: int) -> int: 	
	var t = 0.5 + 0.5 * _heightmap_noise.get_noise_2d(x, z) 	
	return int(HeightmapCurve.sample_baked(t))
