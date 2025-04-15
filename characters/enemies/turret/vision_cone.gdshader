shader_type spatial;
render_mode unshaded, blend_mix;

uniform float cone_angle : hint_range(0.0, 360.0) = 90.0;
uniform float min_angle : hint_range(0.0, 360.0) = 5.0;
uniform float current_angle : hint_range(0.0, 360.0) = 90.0;
uniform float turret_rotation : hint_range(0.0, 360.0) = 0.0;
uniform vec4 cone_color : source_color = vec4(1.0, 0.0, 0.0, .2); // Rotes RGBA

void fragment() {
    // Map UV origin to center of plane
    vec2 uv = UV * 2.0 - 1.0;
    float angle = degrees(atan(uv.y, uv.x));
    float dist = length(uv);

    float actual_angle = mix(min_angle, cone_angle, current_angle / cone_angle) / 2.0;

    // Compute the circular difference between the current angle and turret's rotation.
    float diff = abs(mod(angle - turret_rotation + 180.0, 360.0) - 180.0);

    // The mask is active if the diff is within the actual half-angle and within the unit circle.
    float mask = step(diff, actual_angle) * step(dist, 1.0);

    // Linear falloff from center (1.0) to edge (0.3):
    float alpha_falloff = mix(1.0, 0.3, dist);

    ALBEDO = cone_color.rgb;
    //ALBEDO = vec3(UV, 0);
    ALPHA = cone_color.a * mask * alpha_falloff;
}
