shader_type canvas_item;

/* 
  Quest 3 Passthrough - Simplified
  Only mild geometric warping + swimminess
*/

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float time : hint_range(0.0, 1000.0) = 0.0;

// === Geometric warping / Swimminess ===================================
uniform float warp_strength : hint_range(0.0, 0.15) = 0.035;  // static barrel-like distortion
uniform float swim_strength : hint_range(0.0, 0.08) = 0.018;  // time + motion based wobble
uniform float edge_warp_boost : hint_range(0.0, 2.0) = 1.4;   // stronger warp toward edges

// Driven by the controller script
uniform float head_motion : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5);
	vec2 from_center = uv - center;
	float dist = length(from_center);
	float edge = smoothstep(0.2, 0.75, dist); // 0 center → 1 edge

	// Mild barrel / pincushion style warp
	float warp = 1.0 + warp_strength * (dist * dist) * (1.0 + edge * edge_warp_boost);
	vec2 warped_uv = center + from_center * warp;

	// Time + motion based "swim" (the soft jelly effect)
	float swim_time = time * 1.7;
	float swim = swim_strength * (0.4 + head_motion * 1.6);
	warped_uv.x += sin(warped_uv.y * 12.0 + swim_time) * swim * (0.3 + edge);
	warped_uv.y += cos(warped_uv.x * 11.0 + swim_time * 0.9) * swim * (0.3 + edge * 0.8);

	// Soft radial push near edges
	warped_uv += from_center * edge * warp_strength * 0.6;

	// Prevent sampling outside the screen
	warped_uv = clamp(warped_uv, vec2(0.001), vec2(0.999));

	// Sample the original image with the warped UVs
	vec3 col = texture(screen_texture, warped_uv).rgb;

	COLOR = vec4(col, 1.0);
}