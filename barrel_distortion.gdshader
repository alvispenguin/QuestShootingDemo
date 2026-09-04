shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled;

// Required in Godot 4
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float distortion_strength : hint_range(0.0, 1.5) = 0.35;
uniform float distortion_radius : hint_range(0.5, 2.0) = 1.2;

void vertex() {
	// Make the quad cover the full view
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv * 2.0 - 1.0;

	float dist = length(centered);
	float factor = 1.0 + distortion_strength * pow(dist / distortion_radius, 2.0);

	vec2 distorted_uv = centered * factor * 0.5 + 0.5;

	// Black outside the distorted area
	if (distorted_uv.x < 0.0 || distorted_uv.x > 1.0 || distorted_uv.y < 0.0 || distorted_uv.y > 1.0) {
		ALBEDO = vec3(0.0);
	} else {
		ALBEDO = texture(SCREEN_TEXTURE, distorted_uv).rgb;
	}
}