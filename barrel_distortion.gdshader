shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// === Adjustable parameters ===
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.75;
uniform float vignette_radius : hint_range(0.5, 1.5) = 0.85;
uniform float vignette_softness : hint_range(0.1, 1.0) = 0.45;

uniform float edge_distortion : hint_range(0.0, 0.5) = 0.12;  // soft edge bend
uniform float distortion_power : hint_range(1.0, 3.0) = 1.8;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv * 2.0 - 1.0;

	// --- Soft edge distortion (subtle barrel) ---
	float dist = length(centered);
	float distort_amount = edge_distortion * pow(dist, distortion_power);
	vec2 distorted_uv = centered * (1.0 + distort_amount);
	distorted_uv = distorted_uv * 0.5 + 0.5;

	// Keep UVs inside screen
	distorted_uv = clamp(distorted_uv, 0.0, 1.0);

	vec3 color = texture(SCREEN_TEXTURE, distorted_uv).rgb;

	// --- Comfortable vignette ---
	float vignette = smoothstep(vignette_radius, vignette_radius - vignette_softness, dist);
	vignette = 1.0 - (1.0 - vignette) * vignette_strength;

	color *= vignette;

	ALBEDO = color;
}