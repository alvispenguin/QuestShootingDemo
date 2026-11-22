shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float k1 : hint_range(-1.0, 1.0) = 0.0;
uniform float k2 : hint_range(-1.0, 1.0) = 0.0;
uniform float p1 : hint_range(-0.1, 0.1) = 0.0;
uniform float p2 : hint_range(-0.1, 0.1) = 0.0;
uniform float k3 : hint_range(-1.0, 1.0) = 0.0;

varying vec2 view_center;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	vec4 projected_center = PROJECTION_MATRIX * vec4(0.0, 0.0, -1.0, 1.0);
	view_center = vec2(0.5) + (projected_center.xy / projected_center.w) * vec2(0.5, -0.5);
}

vec2 distort_point(vec2 point) {
	float radius_squared = dot(point, point);
	float radial = 1.0
		+ k1 * radius_squared
		+ k2 * radius_squared * radius_squared
		+ k3 * radius_squared * radius_squared * radius_squared;
	float distorted_x = point.x * radial
		+ 2.0 * p1 * point.x * point.y
		+ p2 * (radius_squared + 2.0 * point.x * point.x);
	float distorted_y = point.y * radial
		+ p1 * (radius_squared + 2.0 * point.y * point.y)
		+ 2.0 * p2 * point.x * point.y;
	return vec2(distorted_x, distorted_y);
}

vec4 distortion_jacobian(vec2 point) {
	float x = point.x;
	float y = point.y;
	float radius_squared = dot(point, point);
	float radius_fourth = radius_squared * radius_squared;
	float radial = 1.0
		+ k1 * radius_squared
		+ k2 * radius_fourth
		+ k3 * radius_fourth * radius_squared;
	float radial_slope = k1
		+ 2.0 * k2 * radius_squared
		+ 3.0 * k3 * radius_fourth;
	float radial_x = 2.0 * x * radial_slope;
	float radial_y = 2.0 * y * radial_slope;

	float j11 = radial + x * radial_x + 2.0 * p1 * y + 6.0 * p2 * x;
	float j12 = x * radial_y + 2.0 * p1 * x + 2.0 * p2 * y;
	float j21 = y * radial_x + 2.0 * p1 * x + 2.0 * p2 * y;
	float j22 = radial + y * radial_y + 6.0 * p1 * y + 2.0 * p2 * x;
	return vec4(j11, j12, j21, j22);
}

void fragment() {
	vec2 focal = vec2(PROJECTION_MATRIX[0][0], PROJECTION_MATRIX[1][1]);
	vec2 distorted_point = (SCREEN_UV - view_center) * vec2(2.0, -2.0) / focal;
	vec2 undistorted_point = distorted_point;

	for (int iteration = 0; iteration < 8; iteration++) {
		vec2 residual = distort_point(undistorted_point) - distorted_point;
		vec4 jacobian = distortion_jacobian(undistorted_point);
		float jacobian_determinant = jacobian.x * jacobian.w - jacobian.y * jacobian.z;
		if (abs(jacobian_determinant) > 0.000001) {
			vec2 correction = vec2(
				jacobian.w * residual.x - jacobian.y * residual.y,
				-jacobian.z * residual.x + jacobian.x * residual.y
			) / jacobian_determinant;
			undistorted_point -= correction;
		}
	}

	vec2 source_uv = view_center + undistorted_point * focal * vec2(0.5, -0.5);
	ALBEDO = texture(screen_texture, clamp(source_uv, vec2(0.001), vec2(0.999))).rgb;
}
