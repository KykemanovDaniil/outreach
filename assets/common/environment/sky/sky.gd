extends Node3D

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera:
		# Двигаем весь узел за камерой (все слои внутри сдвинутся сами)
		global_position = camera.global_position
		# Оставляем высоту 0 (или ту, что тебе нужна для горизонта)
		global_position.y = 0.0 
