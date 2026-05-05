extends PanelContainer

# Используем Unique Names % для кнопок в сцене
@onready var buttons = {
	"sky": %sky_button,
	"glow": %glow_button,
	"v_sync": %v_sync_button
}

func _ready() -> void:
	# Настройки должны работать даже когда остальная игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS
	sync_ui_with_values()

# Синхронизация: проставляем галочки на основе GlobalValues
func sync_ui_with_values():
	for key in buttons:
		if key in GlobalValues:
			buttons[key].button_pressed = GlobalValues.get(key)
	
	if "render_distance" in GlobalValues:
		%render_distance.value = GlobalValues.render_distance
	if "fov" in GlobalValues:
		%fov.value = GlobalValues.fov
	if "music_volume" in GlobalValues:
		%music_volume.value = GlobalValues.music_volume * 100.0
	if "sfx_volume" in GlobalValues:
		%sfx_volume.value = GlobalValues.sfx_volume * 100.0


# МЫ УДАЛИЛИ _input, так как теперь за закрытие отвечает WindowManager или кнопка "Назад"

func _on_button_pressed(action: String) -> void:
	match action:
		"sky":
			GlobalValues.sky = !GlobalValues.sky
			Debug._setup_sky()
		"glow":
			GlobalValues.glow = !GlobalValues.glow
			Debug._setup_environment()
		"v_sync":
			GlobalValues.v_sync = !GlobalValues.v_sync
			var mode = DisplayServer.VSYNC_ENABLED if GlobalValues.v_sync else DisplayServer.VSYNC_DISABLED
			DisplayServer.window_set_vsync_mode(mode)
	
	# Сохранение изменений
	if action in GlobalValues:
		SaveSystem.set_val("Graphics", action, GlobalValues.get(action))

func _on_render_distance_value_changed(value: float) -> void:
	GlobalValues.render_distance = int(value)
	if has_node("/root/Debug"): # Проверка на всякий случай
		Debug._setup_environment() 
		Debug._setup_render_distance()
	SaveSystem.set_val("Graphics", "render_distance", GlobalValues.render_distance)


func _on_fov_value_changed(value: float) -> void:
	GlobalValues.fov = int(value)
	SaveSystem.set_val("Graphics", "fov", GlobalValues.fov)


func _on_music_value_changed(value: float) -> void:
	# 1. Делим на 100, чтобы получить 0.0 - 1.0 (НЕ ИСПОЛЬЗУЙ int())
	GlobalValues.music_volume = value / 100.0
	
	# 2. Пинкаем AudioManager, чтобы он обновил громкость прямо сейчас
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").sync_music_volume()
		
	SaveSystem.set_val("Audio", "music_volume", GlobalValues.music_volume)

func _on_sfx_value_changed(value: float) -> void:
	# 1. Также переводим в 0.0 - 1.0
	GlobalValues.sfx_volume = value / 100.0
	
	# 2. SFX не нужно синкать, так как play_2d берет значение в момент вызова
	SaveSystem.set_val("Audio", "sfx_volume", GlobalValues.sfx_volume)
