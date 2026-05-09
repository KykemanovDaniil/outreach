extends Node3D

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera:
		# Плавное следование, чтобы не было рывков шума
		var target_pos = camera.global_position
		target_pos.y = 100.0 # Высота облаков
		global_position = target_pos
