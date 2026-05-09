extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# F7 — Скриншот в высоком качестве (4K)
	if event.is_action_pressed("F5"):
		take_screenshot()

	# F8 — выход
	if event.is_action_pressed("F8"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()


	# F11 — режим окна
	if event.is_action_pressed("F11"):
		var is_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if is_full else DisplayServer.WINDOW_MODE_FULLSCREEN)

# Функция для качественного скриншота
func take_screenshot():
	# Ждем конца кадра, чтобы на скрин не попали артефакты отрисовки
	await RenderingServer.frame_post_draw
	
	# Получаем изображение напрямую из основного вьюпорта (это без багов)
	var image = get_viewport().get_texture().get_image()
	
	# Формируем путь
	var pictures_path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	var time = Time.get_datetime_dict_from_system()
	var file_name = "/outreach_screenshot_%02d-%02d-%02d.png" % [time.hour, time.minute, time.second]
	var final_path = pictures_path + file_name
	
	# Сохраняем
	var err = image.save_png(final_path)
	
	if err == OK:
		SoundManager.play_2d("click")
		TextAnim.spawn_top_text(self, "Screenshot saved to Pictures")
