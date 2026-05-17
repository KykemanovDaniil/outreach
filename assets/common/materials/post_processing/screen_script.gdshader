shader_type canvas_item;

// Ссылка на экран (встроенный буфер Godot 4)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

group_uniforms Retro_Settings;
uniform int pixel_size : hint_range(1, 10) = 4;        // Минимальное значение 1 во избежание деления на 0
uniform float color_levels : hint_range(2.0, 32.0) = 8.0; 
uniform float dither_strength : hint_range(0.0, 1.0) = 0.1; 

group_uniforms Liminal_Space_Effects;
uniform float grain_strength : hint_range(0.0, 0.2) = 0.04; 
uniform float vignette_intensity : hint_range(0.0, 2.0) = 1.3; 
uniform float scanline_intensity : hint_range(0.0, 0.5) = 0.1; 

// Оптимизированный математический дизеринг (без массивов в памяти)
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
	vec2 uv = SCREEN_UV;
	
	// 1. Быстрая пикселизация UV
	if (pixel_size > 1) {
		vec2 size = SCREEN_PIXEL_SIZE * float(pixel_size);
		uv = floor(uv / size) * size;
	}
	
	// 2. Чтение текстуры экрана без сдвигов цвета
	vec3 col = texture(screen_texture, uv).rgb;
	
	// 3. Дизеринг
	ivec2 pixel_pos = ivec2(FRAGCOORD.xy / float(pixel_size));
	col += get_dither_threshold(pixel_pos) * dither_strength;
	
	// 4. Постеризация
	col = floor(col * color_levels) / (color_levels - 1.0);
	
	// 5. Быстрый статический шум (зерно)
	float noise = fract(sin(dot(uv, vec2(12.9898, 78.233) + TIME)) * 43758.5453);
	col += (noise - 0.5) * grain_strength;
	
	// 6. Сканирующие линии
	float scanline = sin(uv.y * (1.0 / SCREEN_PIXEL_SIZE.y) * 0.5) * scanline_intensity;
	col -= scanline;
	
	// 7. Виньетка
	vec2 centered_uv = uv * 2.0 - 1.0;
	float dist = length(centered_uv);
	float vignette = smoothstep(vignette_intensity, vignette_intensity - 0.8, dist);
	col *= vignette;
	
	COLOR = vec4(col, 1.0);
}
