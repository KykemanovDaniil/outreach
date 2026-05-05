@tool extends Button

var block_id: int = 0
var block_name: String = "none"

# Загружаем атлас один раз для всех слотов
static var atlas_tex := preload("res://assets/textures/block_atlas.png")

func setup_slot(id: int, b_name: String, atlas_pos: Vector2i) -> void:
	block_id = id
	block_name = b_name
	
	# Создаем AtlasTexture (это мгновенно и не тормозит)
	var atlas_sub_tex = AtlasTexture.new()
	atlas_sub_tex.atlas = atlas_tex
	# Вырезаем квадрат 16x16 (умножаем координаты на размер сетки)
	atlas_sub_tex.region = Rect2(atlas_pos.x * 16, atlas_pos.y * 16, 16, 16)
	
	# Настройки кнопки
	%icon.texture = atlas_sub_tex
	self.expand_icon = true
	self.text = "" # Текст на самой кнопке нам не нужен, у нас иконка

# ЗДЕСЬ ТВОИ ЗВУКИ И ТЕКСТ (срабатывают при клике)
func _pressed() -> void:
	# 1. Звук клика через SoundManager
	SoundManager.play_2d("click")
	
	# 2. Всплывающий текст через TextAnim
	TextAnim.call("spawn_floating_text", self, block_name)
	# 3. Выбор блока для строительства
	GlobalValues.current_block = block_id
