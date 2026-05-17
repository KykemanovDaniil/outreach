shader_type canvas_item;

// Ссылка на экран (встроенный буфер Godot 4)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Настройки палитры
uniform float color_levels : hint_range(2.0, 999.0) = 3.0;     // Чем меньше число, тем меньше оттенков
uniform float dither_strength : hint_range(0.0, 1.0) = 0.2;  // Сила смешивания пикселей

// Математический дизеринг 4х4
float get_dither_threshold(ivec2 p) {
	int x = p.x & 3;
	int y = p.y & 3;
	int idx = (x ^ y) + (y << 1);
	int bit1 = (idx & 1);
	int bit2 = ((idx >> 1) & 1);
	int bit3 = ((idx >> 2) & 1);
	int bit4 = ((idx >> 3) & 1);
	float threshold = float((bit1 << 3) | (bit2 << 2) | (bit3 << 1) | bit4) / 16.0;
	return threshold - 0.5;
}

void fragment() {
	// 1. Получаем оригинальный цвет пикселя экрана
	vec3 col = texture(screen_texture, SCREEN_UV).rgb;
	
	// 2. Применяем сетку дизеринга по координатам экрана
	ivec2 pixel_pos = ivec2(FRAGCOORD.xy);
	col += get_dither_threshold(pixel_pos) * dither_strength;
	
	// 3. Сжимаем палитру до минимального количества оттенков
	col = floor(col * color_levels) / (color_levels - 1.0);
	
	// Выводим финальный результат
	COLOR = vec4(col, 1.0);
}
