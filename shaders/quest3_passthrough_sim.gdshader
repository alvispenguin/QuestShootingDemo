shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float time = 0.0;
uniform float head_motion : hint_range(0.0, 1.0) = 0.0;
uniform float warp_strength : hint_range(0.0, 0.15) = 0.035;
uniform float swim_strength : hint_range(0.0, 0.08) = 0.018;
uniform float edge_warp_boost : hint_range(0.0, 3.0) = 1.4;
uniform float softness_pixels : hint_range(0.0, 3.0) = 0.7;
uniform float grain_strength : hint_range(0.0, 0.1) = 0.015;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.2;

varying vec2 view_center;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	vec4 projected_center = PROJECTION_MATRIX * vec4(0.0, 0.0, -1.0, 1.0);
	view_center = vec2(0.5) + (projected_center.xy / projected_center.w) * vec2(0.5, -0.5);
}

float random_noise(vec2 position) {
	return fract(sin(dot(position, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 sample_screen(vec2 uv) {
	return texture(screen_texture, clamp(uv, vec2(0.001), vec2(0.999))).rgb;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - view_center;
	float dist = length(from_center);
	float edge = smoothstep(0.2, 0.75, dist);

	float warp = 1.0 + warp_strength * dist * dist * (1.0 + edge * edge_warp_boost);
	vec2 warped_uv = view_center + from_center * warp;
	float swim_time = time * 1.7;
	float swim = swim_strength * (0.4 + head_motion * 1.6);
	warped_uv.x += sin(warped_uv.y * 12.0 + swim_time) * swim * (0.3 + edge);
	warped_uv.y += cos(warped_uv.x * 11.0 + swim_time * 0.9) * swim * (0.3 + edge * 0.8);
	warped_uv += from_center * edge * warp_strength * 0.6;

	vec2 pixel_offset = softness_pixels / VIEWPORT_SIZE;
	vec3 color = sample_screen(warped_uv) * 0.4;
	color += sample_screen(warped_uv + vec2(pixel_offset.x, 0.0)) * 0.15;
	color += sample_screen(warped_uv - vec2(pixel_offset.x, 0.0)) * 0.15;
	color += sample_screen(warped_uv + vec2(0.0, pixel_offset.y)) * 0.15;
	color += sample_screen(warped_uv - vec2(0.0, pixel_offset.y)) * 0.15;

	float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float noise = random_noise(floor(uv * VIEWPORT_SIZE) + floor(time * 24.0)) - 0.5;
	color += noise * grain_strength * (1.25 - clamp(luminance, 0.0, 1.0));
	float vignette = smoothstep(0.45, 0.71, dist);
	color *= 1.0 - vignette * vignette_strength;
	ALBEDO = clamp(color, vec3(0.0), vec3(1.0));
}
