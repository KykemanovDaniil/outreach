shader_type canvas_item;

// Ссылка на экран (то, что под ColorRect)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

group_uniforms Retro_Settings;
uniform int pixel_size : hint_range(1, 10) = 4;        // Размер пикселя
uniform float color_levels : hint_range(2.0, 32.0) = 8.0; // Глубина цвета
uniform float dither_strength : hint_range(0.0, 1.0) = 0.1; // Сила дизеринга

group_uniforms Liminal_Space_Effects;
uniform float distortion : hint_range(0.0, 0.3) = 0.05;    // Искривление линзы (рыбий глаз)
uniform float aberration : hint_range(0.0, 0.1) = 0.003;   // Хроматическая аберрация (сдвиг цвета)
uniform float grain_strength : hint_range(0.0, 0.2) = 0.04; // Зернистость (шум)
uniform float vignette_intensity : hint_range(0.0, 2.0) = 1.3; // Сила виньетки
uniform float scanline_intensity : hint_range(0.0, 0.5) = 0.1; // Полосы как на старом ТВ

// Матрица Байера для дизеринга
float get_dither_threshold(ivec2 p) {
	int x = p.x % 4;
	int y = p.y % 4;
	int index = x + y * 4;
	float table[16] = float[](
		0.0, 0.5, 0.125, 0.625,
		0.75, 0.25, 0.875, 0.375,
		0.1875, 0.6875, 0.0625, 0.5625,
		0.9375, 0.4375, 0.8125, 0.3125
	);
	return table[index] - 0.5;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// 1. Рыбий глаз (Distortion)
	vec2 centered_uv = uv * 2.0 - 1.0;
	centered_uv *= 1.0 + pow(length(centered_uv), 2.0) * distortion;
	uv = centered_uv * 0.5 + 0.5;
	
	// Проверка границ (убираем артефакты растягивания)
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// 2. Пикселизация
		if (pixel_size > 1) {
			vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
			uv = floor(uv * screen_res / float(pixel_size)) / (screen_res / float(pixel_size));
		}
		
		// 3. Хроматическая аберрация
		float r = texture(screen_texture, uv + vec2(aberration, 0.0)).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv - vec2(aberration, 0.0)).b;
		vec3 col = vec3(r, g, b);
		
		// 4. Дизеринг
		ivec2 pixel_pos = ivec2(FRAGCOORD.xy / float(pixel_size));
		float dither = get_dither_threshold(pixel_pos) * dither_strength;
		col += dither;
		
		// 5. Постеризация (ограничение цветов)
		col = floor(col * color_levels) / (color_levels - 1.0);
		
		// 6. Статический шум (Grain)
		float noise = (fract(sin(dot(uv, vec2(12.9898, 78.233) * TIME)) * 43758.5453));
		col += (noise - 0.5) * grain_strength;
		
		// 7. Сканирующие линии
		float scanline = sin(uv.y * (1.0 / SCREEN_PIXEL_SIZE.y) * 0.5) * scanline_intensity;
		col -= scanline;
		
		// 8. Виньетка
		float dist = length(centered_uv);
		float vignette = smoothstep(vignette_intensity, vignette_intensity - 0.8, dist);
		col *= vignette;
		
		COLOR = vec4(col, 1.0);
	}
}
