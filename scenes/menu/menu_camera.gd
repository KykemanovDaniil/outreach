extends Camera3D

func _ready() -> void:
	start_rotation_tween()

func start_rotation_tween() -> void:
	var tween = create_tween()
	
	# Настраиваем бесконечное вращение на 360 градусов (TAU)
	tween.tween_property(self, "rotation:y", rotation.y + TAU, 4.0)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# Зацикливаем
	tween.set_loops()
