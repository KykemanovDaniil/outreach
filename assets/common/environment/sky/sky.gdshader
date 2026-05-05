shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D noise_tex : source_color, filter_nearest; 
uniform float threshold : hint_range(0.0, 1.0) = 0.5;
uniform float cloud_scale : hint_range(0.00002, 9999.0) = 0.00002;
uniform vec2 speed = vec2(0.05, 0.05);
uniform vec4 cloud_color : source_color = vec4(1.0);

// --- НОВЫЕ ПАРАМЕТРЫ ДЛЯ СВЕЧЕНИЯ ---
uniform float glow_intensity : hint_range(1.0, 10.0) = 2.0; // Сила яркости
uniform float soft_edge : hint_range(0.0, 0.5) = 0.1;      // Мягкость края

// --- ДИСТАНЦИЯ ---
uniform float fade_distance : hint_range(100.0, 500000.0) = 50000.0;
uniform float fade_start : hint_range(0.0, 400000.0) = 500.0;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 moving_uv = (world_pos.xz * cloud_scale) + (TIME * speed);
    float n = texture(noise_tex, moving_uv).r;
    
    // 1. Делаем плавную маску вместо жесткого step
    // Это создаст легкий ореол вокруг майнкрафт-облаков
    float mask = smoothstep(threshold - soft_edge, threshold, n);
    
    float dist = distance(world_pos.xz, CAMERA_POSITION_WORLD.xz);
    float fade = 1.0 - smoothstep(fade_start, fade_distance, dist);
    
    // 2. Умножаем RGB на интенсивность свечения. 
    // Если в настройках WorldEnvironment включен Bloom, облака "засветятся".
    ALBEDO = cloud_color.rgb * glow_intensity;
    
    ALPHA = mask * cloud_color.a * fade;

    if (ALPHA < 0.01) discard;
}
