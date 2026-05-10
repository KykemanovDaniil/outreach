extends Node

const VoxelLibraryResource = preload("res://assets/models/blocks.tres")

@export var random_tick_speed: int = 3
const RADIUS = 50
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
	if not is_instance_valid(_player_node):
		return

	var center = Vector3i(_player_node.position.floor())
	var area = AABB(
		Vector3(center) - Vector3(RADIUS, RADIUS, RADIUS), 
		Vector3(RADIUS, RADIUS, RADIUS) * 2
	)
	
	var chunk_count = (pow(RADIUS * 2, 3)) / 4096.0 # Объем области / объем чанка
	var voxels_per_frame = int(max(chunk_count * random_tick_speed, 1))

	_voxel_tool.run_blocky_random_tick(area, voxels_per_frame, _process_random_tick, 16)

func _process_random_tick(pos: Vector3i, block_id: int) -> void:
	if block_id == Block.GRASS:
		_handle_grass_tick(pos)

func _handle_grass_tick(pos: Vector3i):
	var block_above = _voxel_tool.get_voxel(pos + Vector3i.UP)
	
	if _is_block_opaque(block_above):
		_voxel_tool.set_voxel(pos, Block.DIRT)
		return

	_grass_neighbors.shuffle()
	var neighbor_pos = pos + _grass_neighbors[0]
	
	if _voxel_tool.get_voxel(neighbor_pos) == Block.DIRT:
		var neighbor_above = _voxel_tool.get_voxel(neighbor_pos + Vector3i.UP)
		if not _is_block_opaque(neighbor_above):
			_voxel_tool.set_voxel(neighbor_pos, Block.GRASS)

func _is_block_opaque(block_id: int) -> bool:
	return not (block_id == Block.AIR or block_id == _tall_grass_type or block_id in TRANSPARENT_BLOCKS)
