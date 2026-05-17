shader_type spatial;

// unshaded — отключает тени (облака всегда яркие)
// fog_disabled — запрещает движку принудительно окрашивать облака в цвет тумана
render_mode unshaded, blend_mix, cull_disabled, fog_disabled;

uniform vec4 cloud_color : source_color = vec4(1.0);

// --- ДИСТАНЦИЯ (чтобы облака плавно исчезали вдалеке) ---
uniform float fade_distance : hint_range(100.0, 5000.0) = 1000.0;
uniform float fade_start : hint_range(0.0, 4000.0) = 500.0;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // 1. Вычисляем дистанцию до камеры для плавного растворения облаков у горизонта
    float dist = distance(world_pos.xz, CAMERA_POSITION_WORLD.xz);
    float fade = 1.0 - smoothstep(fade_start, fade_distance, dist);
    
    // 2. Устанавливаем чистый цвет облаков из инспектора (эффект глоу полностью удален)
    ALBEDO = cloud_color.rgb;
    
    // 3. Прозрачность теперь управляется исключительно альфа-каналом цвета и дистанцией
    ALPHA = cloud_color.a * fade;

    // Оптимизация: не рендерим полностью невидимые пиксели
    if (ALPHA < 0.01) discard;
}
