extends VoxelGeneratorScript

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE

@export var block_lib : VoxelBlockyLibrary
@export var grid_step: int = 2
@export var target_y: int = 0

func _get_used_channels_mask() -> int:
	return 1 << _CHANNEL

func _generate_block(buffer: VoxelBuffer, origin: Vector3i, _lod: int) -> void:
	# 1. Быстрые проверки
	if block_lib == null: return
	
	# Проверка высоты — самая дешевая операция, делаем её первой
	if target_y < origin.y or target_y >= origin.y + buffer.get_size().y:
		return

	var models_count = block_lib.models.size()
	if models_count <= 1: return

	# 2. Кэшируем константы генерации
	var row_width = int(ceil(sqrt(float(models_count))))
	var size = buffer.get_size()
	var local_y = target_y - origin.y
	
	# Предрассчитываем стартовые позиции
	var start_x = (grid_step - (origin.x % grid_step)) % grid_step
	var start_z = (grid_step - (origin.z % grid_step)) % grid_step
	
	# Оптимизация: используем float-инверсию для замены деления на умножение
	var inv_step = 1.0 / grid_step

	# 3. Оптимизированные циклы
	var z = start_z
	while z < size.z:
		# Вычисляем gz один раз для всей строки X
		var gz = int(float(origin.z + z) * inv_step)
		
		# Если вышли за пределы сетки по Z — прерываем
		if gz < 0: 
			z += grid_step
			continue
			
		var z_offset = gz * row_width
		var x = start_x
		
		while x < size.x:
			var gx = int(float(origin.x + x) * inv_step)
			
			# Проверка границ сетки
			if gx >= 0 and gx < row_width:
				var block_index = gx + z_offset
				
				if block_index < models_count:
					buffer.set_voxel(block_index + 1, x, local_y, z, _CHANNEL)
			
			x += grid_step
		z += grid_step
