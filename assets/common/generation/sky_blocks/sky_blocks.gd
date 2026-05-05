extends VoxelGeneratorScript

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE

@export var block_lib : VoxelBlockyLibrary
@export var grid_step: int = 4

func _get_used_channels_mask() -> int:
	return 1 << _CHANNEL

func _generate_block(buffer: VoxelBuffer, origin: Vector3i, _lod: int) -> void:
	if block_lib == null: return
	var models_count = block_lib.models.size() # Быстрее, чем .size() массива
	if models_count == 0: return

	var size = buffer.get_size()
	var seed_val = GlobalValues.world_seed

	# Находим стартовые смещения внутри чанка, чтобы попасть в глобальную сетку grid_step
	var start_x = (grid_step - (origin.x % grid_step)) % grid_step
	var start_y = (grid_step - (origin.y % grid_step)) % grid_step
	var start_z = (grid_step - (origin.z % grid_step)) % grid_step

	# Прямые прыжки по сетке без проверки if % grid_step
	var z = start_z
	while z < size.z:
		var gz = origin.z + z
		var y = start_y
		while y < size.y:
			var gy = origin.y + y
			var x = start_x
			while x < size.x:
				var gx = origin.x + x
				
				# Псевдорандом через битовые сдвиги (быстрее hash(Vector3i))
				var h = (gx * 73856093) ^ (gy * 19349663) ^ (gz * 83492791) ^ seed_val
				# Избегаем отрицательных чисел и берем ID
				var random_block_id = (h & 0x7FFFFFFF) % models_count + 1
				
				buffer.set_voxel(random_block_id, x, y, z, _CHANNEL)
				x += grid_step
			y += grid_step
		z += grid_step
