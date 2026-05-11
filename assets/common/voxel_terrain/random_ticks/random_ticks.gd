extends Node

const VoxelLibraryResource = preload("res://assets/models/blocks.tres")

const TRANSPARENT_BLOCKS = [5, 11, 12, 13, 14, 15, 17, 18, 32, 36, 37]

enum Block {
	AIR = 0,
	GRASS = 1,
	DIRT = 2
}

@onready var _terrain : VoxelTerrain = get_node("../VoxelTerrain")
@onready var _voxel_tool : VoxelToolTerrain = _terrain.get_voxel_tool()

var _player_node : Node3D 
var _tall_grass_type : int
var _grass_neighbors: Array[Vector3i] = []

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player_node = players[0]

	_tall_grass_type = VoxelLibraryResource.get_model_index_from_resource_name("tall_grass")
	_voxel_tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			for z in range(-1, 2):
				if x == 0 and y == 0 and z == 0: continue
				_grass_neighbors.append(Vector3i(x, y, z))

func _process(_delta: float) -> void:
	
	var center = Vector3i(_player_node.position.floor())
	
	var dist_in_voxels = GlobalValues.update_distance * GlobalValues.chunk_size
	
	var area = AABB(
		Vector3(center) - Vector3(dist_in_voxels, dist_in_voxels, dist_in_voxels), 
		Vector3(dist_in_voxels, dist_in_voxels, dist_in_voxels) * 2
	)
	
	
	var chunks_in_area = pow(GlobalValues.update_distance * 2, 3)
	var voxels_per_frame = int(max(chunks_in_area * GlobalValues.random_tick_speed, 1))
	
	_voxel_tool.run_blocky_random_tick(area, voxels_per_frame, _process_random_tick, GlobalValues.chunk_size)


func _process_random_tick(pos: Vector3i, block_id: int) -> void:
	if block_id == Block.GRASS:
		_handle_grass_tick(pos)

func _handle_grass_tick(pos: Vector3i):
	# 1. Проверка на смерть (если сверху закрыли блоком)
	var block_above = _voxel_tool.get_voxel(pos + Vector3i.UP)
	if _is_block_opaque(block_above):
		_voxel_tool.set_voxel(pos, Block.DIRT)
		return

	# 2. Распространение: перебираем ВСЕ 26 направлений за один раз
	# Это заставит траву расти агрессивно
	for offset in _grass_neighbors:
		var neighbor_pos = pos + offset
		
		# Если нашли землю
		if _voxel_tool.get_voxel(neighbor_pos) == Block.DIRT:
			# Проверяем, не накрыта ли эта земля чем-то
			var neighbor_above = _voxel_tool.get_voxel(neighbor_pos + Vector3i.UP)
			if not _is_block_opaque(neighbor_above):
				_voxel_tool.set_voxel(neighbor_pos, Block.GRASS)
				# Если хочешь, чтобы за один тик вырастала только ОДНА травинка, 
				# добавь тут 'break', но для максимальной скорости — убери его.



func _is_block_opaque(block_id: int) -> bool:
	return not (block_id == Block.AIR or block_id == _tall_grass_type or block_id in TRANSPARENT_BLOCKS)
