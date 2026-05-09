shader_type spatial;

// unshaded идеально для белых облаков, так как они не будут черными снизу
render_mode unshaded, blend_mix, cull_disabled;

uniform vec4 cloud_color : source_color = vec4(1.0);
uniform float glow_intensity : hint_range(1.0, 10.0) = 1.0; // Поставь 1.0 для просто белого

// --- ДИСТАНЦИЯ (чтобы облака плавно исчезали вдалеке) ---
uniform float fade_distance : hint_range(100.0, 5000.0) = 1000.0;
uniform float fade_start : hint_range(0.0, 4000.0) = 500.0;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Вычисляем дистанцию до камеры для плавного исчезновения на горизонте
    float dist = distance(world_pos.xz, CAMERA_POSITION_WORLD.xz);
    float fade = 1.0 - smoothstep(fade_start, fade_distance, dist);
    
    // Чистый белый цвет с множителем яркости
    ALBEDO = cloud_color.rgb * glow_intensity;
    
    // Прозрачность зависит только от дистанции
    ALPHA = cloud_color.a * fade;

    // Оптимизация: не рисовать полностью прозрачные пиксели
    if (ALPHA < 0.01) discard;
}
