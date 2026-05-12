extends CanvasLayer # Скрипт на родителе всех кнопок

func _ready() -> void:
	# Если это ПК — сносим к чертям весь этот узел со всеми потрохами
	if OS.get_name() in ["Wndows", "Linux"]:
		queue_free()
		return # Дальше код не пойдет
