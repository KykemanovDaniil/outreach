shader_type spatial;
// Ставим disabled, чтобы шейдер В ПРИНЦИПЕ мог рисовать обе стороны
render_mode cull_disabled, specular_disabled, unshaded;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001) = 0.5;

// ВОТ ТВОЙ ПЕРЕКЛЮЧАТЕЛЬ:
// Включи (1), если нужны две стороны. Выключи (0) для обычных блоков.
uniform bool double_sided = true; 

uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset = vec3(0.0);

void vertex() {
    UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
    // Если мы НЕ в режиме double_sided и смотрим на заднюю грань — выкидываем пиксель
    if (!double_sided && !FRONT_FACING) {
        discard;
    }

    vec4 albedo_tex = texture(texture_albedo, UV);
    ALBEDO = albedo.rgb * albedo_tex.rgb * COLOR.rgb;
    
    ALPHA *= albedo.a * albedo_tex.a * COLOR.a;
    ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}
