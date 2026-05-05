extends Node3D

func _ready() -> void:
	SoundManager.play_random_music()
	%menu.visible = true
	%world_create.visible = false
	%tutorial.visible = false
	%options.visible = false
	
	# При старте ставим случайное число в поле ввода
	%seed.text = str(randi())
	GlobalValues.world_type = str("basic")
	
	await get_tree().create_timer(1.5).timeout
	SoundManager.play_random_music()

func _on_seed_text_changed(new_text: String) -> void:
	var old_caret: int = %seed.caret_column  # Добавили : int
	var filtered: String = ""
	
	for c in new_text:
		if c in "0123456789":
			filtered += c
			
	%seed.text = filtered
	%seed.caret_column = old_caret


func _on_world_type_selected(id: int) -> void:
	SoundManager.play_2d("click")
	var item_name : String = %world_type_btn.get_popup().get_item_text(id)
	GlobalValues.world_type = item_name

func _on_button_pressed(action: String) -> void:
	SoundManager.play_2d("click")
	match action:
		"worlds":
			%menu.visible = !%menu.visible
			%worlds.visible = !%worlds.visible
		"create":
			%worlds.visible = !%worlds.visible
			%world_create.visible = !%world_create.visible
		"play":
			var input_text: String = %seed.text
			
			# Жёсткая логика определения сида
			if input_text.is_empty():
				GlobalValues.world_seed = randi()
			elif input_text.is_valid_int():
				GlobalValues.world_seed = input_text.to_int()
			else:
				GlobalValues.world_seed = input_text.hash()
			
			# Обновляем зависимые параметры
			GlobalValues.cave_seed = GlobalValues.world_seed + 10
			GlobalValues.tree_seed = GlobalValues.world_seed + 20
			GlobalValues.cloud_seed = GlobalValues.world_seed + 30
			
			# Переход в мир
			get_tree().change_scene_to_file("res://scenes/game/game.tscn")
		"exit":
			get_tree().quit()
		"tutorial":
			%menu.visible = !%menu.visible
			%tutorial.visible = !%tutorial.visible
			if %tutorial.visible == true:
				var my_track = preload("res://assets/audio/music/Only_forward.ogg")
				SoundManager.play_specific_music(my_track)
			else:
				SoundManager.play_random_music()
		"options":
			%menu.visible = !%menu.visible
			%options.visible = !%options.visible
			if %options.visible == true:
				var my_track = preload("res://assets/audio/music/Quest.ogg")
				SoundManager.play_specific_music(my_track)
			else:
				SoundManager.play_random_music()
		"tiktok", "discord":
			var links := {"tiktok": "https://www.tiktok.com/@kykemanovdaniil", "discord": "https://discord.gg/y4v2rhswrq"}
			OS.shell_open(links[action])


func _on_button_4_pressed(extra_arg_0: String) -> void:
	pass # Replace with function body.
