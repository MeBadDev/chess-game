shader_type canvas_item;

// Assign your SubViewport's ViewportTexture here in the Inspector or via code
uniform sampler2D viewport_tex : source_color, filter_linear;

// 2D shear skew in UV-relative units
uniform vec2 skew = vec2(0.0, 0.0);
uniform vec2 skew_pivot = vec2(0.5, 0.5);

// Optional 3D perspective tilt in degrees (x = pitch, y = yaw)
uniform vec2 tilt_degrees = vec2(0.0, 0.0);
uniform float perspective_depth : hint_range(0.5, 10.0) = 2.2;

// Extra breathing room so skewed/tilted corners don't clip
uniform float margin : hint_range(0.0, 0.45) = 0.12;

mat3 rotation_yx(vec2 deg) {
	vec2 r = radians(deg);
	float cx = cos(r.x);
	float sx = sin(r.x);
	float cy = cos(r.y);
	float sy = sin(r.y);

	mat3 rot_y = mat3(
		vec3(cy,  0.0, sy),
		vec3(0.0, 1.0, 0.0),
		vec3(-sy, 0.0, cy)
	);
	mat3 rot_x = mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, cx, -sx),
		vec3(0.0, sx,  cx)
	);
	return rot_x * rot_y;
}

void fragment() {
	float scale = 1.0 / max(1.0 - 2.0 * margin, 0.05);
	vec2 centered = (UV - 0.5) * scale;

	// Aspect ratio derived from the ViewportTexture itself
	ivec2 tex_size = textureSize(viewport_tex, 0);
	float aspect = 1.0;
	if (tex_size.x > 0 && tex_size.y > 0) {
		aspect = float(tex_size.y) / float(tex_size.x);
	}

	// 1. 2D shear skew around pivot
	vec2 p = centered - (skew_pivot - 0.5);
	vec2 sheared = vec2(
		p.x - skew.x * p.y,
		p.y - skew.y * p.x
	) + (skew_pivot - 0.5);

	// 2. Raycast against tilted card plane for perspective foreshortening
	vec2 ray_xy = vec2(sheared.x * aspect, sheared.y);
	mat3 rot = rotation_yx(tilt_degrees);
	vec3 normal = rot * vec3(0.0, 0.0, 1.0);
	vec3 cam_pos = vec3(0.0, 0.0, -perspective_depth);
	vec3 ray_dir = vec3(ray_xy, perspective_depth);

	float denom = dot(ray_dir, normal);
	vec2 final_uv = sheared + 0.5;
	bool valid = abs(denom) > 1e-5;

	if (valid) {
		float t = -dot(cam_pos, normal) / denom;
		if (t > 0.0) {
			vec3 hit_local = transpose(rot) * (cam_pos + t * ray_dir);
			final_uv = vec2((hit_local.x / max(aspect, 1e-5)) + 0.5, hit_local.y + 0.5);
		} else {
			valid = false;
		}
	}

	if (!valid || final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
		discard;
	}

	COLOR = texture(viewport_tex, final_uv) * COLOR;
}