shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float warp_strength : hint_range(0.0, 2.0, 0.1) = 2.0;
uniform float edge_warp_boost : hint_range(0.0, 3.0) = 1.4;

varying vec2 view_center;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	vec4 projected_center = PROJECTION_MATRIX * vec4(0.0, 0.0, -1.0, 1.0);
	view_center = vec2(0.5) + (projected_center.xy / projected_center.w) * vec2(0.5, -0.5);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - view_center;
	float dist = length(from_center);
	float edge = smoothstep(0.2, 0.75, dist);

	float warp = 1.0 + warp_strength * dist * dist * (1.0 + edge * edge_warp_boost);
	vec2 warped_uv = view_center + from_center * warp;
	warped_uv += from_center * edge * warp_strength * 0.6;
	ALBEDO = texture(screen_texture, clamp(warped_uv, vec2(0.001), vec2(0.999))).rgb;
}
