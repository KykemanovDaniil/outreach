extends RefCounted

var world_noise = VoxelGraphNodeInspectorWrapper
var cave_noise = VoxelGraphNodeInspectorWrapper

func _init() -> void:
	world_noise.name = &"world_noise"
	cave_noise.name = &"cave_noise"
	
	world_noise.ZN_FastNoiseLite.seed = GlobalValues.world_seed
	cave_noise.ZN_FastNoiseLite.seed = GlobalValues.cave_seed
	
	
	
