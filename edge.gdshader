shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE: hint_normal_roughness_texture, filter_linear_mipmap;
uniform float threshold: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec3 line_color: source_color = vec3(0.4);
uniform vec3 background_color: source_color = vec3(0.9);

const mat3 sobel_x = mat3(
	vec3(1.0, 2.0, 1.0),
	vec3(0.0, 0.0, 0.0),
	vec3(-1.0, -2.0, -1.0)
);

const mat3 sobel_y = mat3(
	vec3(1.0, 0.0, -1.0),
	vec3(2.0, 0.0, -2.0),
	vec3(1.0, 0.0, -1.0)
);

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	vec4 pixel = texture(SCREEN_TEXTURE, screen_uv);
	vec3 normal = texture(NORMAL_TEXTURE, screen_uv).rgb;
	normal = normal * 2.0 - 1.0;
	vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
	mat3 pixels;
	for (int x = -1; x <= 1; x++) {
		vec3 row;
		for (int y = -1; y <= 1; y++) {
			vec2 offset = pixel_size * vec2(float(x), float(y));
			vec3 cell = texture(NORMAL_TEXTURE, screen_uv + offset).rgb;
			row[y + 1] = length(cell - normal);
		}
		pixels[x + 1] = row;
	}
	float gx = 0.0;
	for (int i = 0; i <= 2; i++) {
		gx += dot(sobel_x[i], pixels[i]);
	}
	float gy = 0.0;
	for (int i = 0; i <= 2; i++) {
		gy += dot(sobel_y[i], pixels[i]);
	}
	float sobel = sqrt(gx * gx + gy * gy);
	ALBEDO = sobel > threshold ? line_color : background_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
