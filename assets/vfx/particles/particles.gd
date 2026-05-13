extends CPUParticles3D

func _ready() -> void:
	# Гарантируем, что частицы не начнут вылетать Раньше, чем переместятся в блок
	emitting = false
	one_shot = true # Должно быть включено в инспекторе
	
	# Автоудаление через 2 секунды (безопасный таймер)
	get_tree().create_timer(2.0).timeout.connect(queue_free)

func setup(texture: Texture2D = null) -> void:
	# 1. Если есть меш и текстура — применяем (необязательно)
	if mesh and texture:
		var new_mesh : Mesh = mesh.duplicate()
		var new_mat : Mesh = new_mesh.material.duplicate()
		new_mat.albedo_texture = texture
		new_mesh.material = new_mat
		mesh = new_mesh
	
	# 2. ПЕРЕЗАПУСК — это фиксит баг, когда частицы "тянутся" шлейфом от старой позиции
	restart()
	emitting = true
