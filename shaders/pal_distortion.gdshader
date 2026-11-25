shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear, repeat_disable;
uniform float strength : hint_range(0.0, 1.0) = 0.2;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 p = SCREEN_UV * 2.0 - 1.0;
	float lower = 0.5 * (p.y + 1.0);
	vec2 displacement = strength * vec2(
		0.08 * p.x * lower * lower,
		0.04 * p.x * p.x * (1.0 + p.y)
	);
	vec2 source_uv = clamp(SCREEN_UV + displacement, vec2(0.001), vec2(0.999));
	ALBEDO = texture(screen_texture, source_uv).rgb;
}
