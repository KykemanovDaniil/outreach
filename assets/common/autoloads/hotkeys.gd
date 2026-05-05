extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# F7 — Скриншот в высоком качестве (4K)
	if event.is_action_pressed("F5"):
		take_high_res_screenshot()

	# F8 — выход
	if event.is_action_pressed("F8"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()


	# F11 — режим окна
	if event.is_action_pressed("F11"):
		var is_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if is_full else DisplayServer.WINDOW_MODE_FULLSCREEN)

# Функция для качественного скриншота
func take_high_res_screenshot():
	var viewport = SubViewport.new()
	viewport.size = Vector2i(1024, 1024) 
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		camera = get_viewport().get_camera_2d()
	
	if camera:
		var new_camera = camera.duplicate()
		viewport.add_child(new_camera)
	
	add_child(viewport)
	
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	var image = viewport.get_texture().get_image()
	
	var pictures_path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	var time = Time.get_datetime_dict_from_system()
	var file_name = "/Outreach_%02d%02d%02d.png" % [time.hour, time.minute, time.second]
	var final_path = pictures_path + file_name
	
	# Сначала сохраняем файл (самая тяжелая операция, на которой лагает)
	image.save_png(final_path)
	
	# Удаляем тяжелый вьюпорт из памяти
	viewport.queue_free()
	
	# Ждем один кадр, чтобы Godot успел очистить память от вьюпорта
	await get_tree().process_frame
	
	# Теперь, когда все лаги позади, проигрываем звук и выводим текст
	SoundManager.play_2d("click")
	TextAnim.spawn_top_text(self, "4K Screenshot saved to Pictures")
