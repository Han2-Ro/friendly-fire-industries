shader_type spatial;
render_mode unshaded, blend_mix;

uniform float cone_angle : hint_range(0.0, 360.0) = 90.0;
uniform float min_angle : hint_range(0.0, 360.0) = 5.0;
uniform float current_angle : hint_range(0.0, 360.0) = 90.0;
uniform vec4 cone_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Rotes RGBA

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    float angle = degrees(atan(uv.y, uv.x));
    float dist = length(uv);
    
    float actual_angle = mix(min_angle, cone_angle, current_angle / cone_angle) / 2.0;
    // Beschränkt auf Winkel + dist <= 1.0
    float mask = step(abs(angle), actual_angle) * step(dist, 1.0);

    // Linearer Verlauf von 1.0 (Mitte) auf 0.3 (Rand):
    float alpha_falloff = mix(1.0, 0.3, dist);

    // Ohne zusätzliches smoothstep oder fade
    ALBEDO = cone_color.rgb;
    ALPHA = cone_color.a * mask * alpha_falloff;
}
