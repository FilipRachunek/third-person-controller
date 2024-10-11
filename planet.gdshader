shader_type sky;

uniform sampler2D sky_tex: source_color, filter_linear, hint_default_black;
uniform vec3 sun_pos = vec3(0.0);
uniform sampler2D planet_tex: source_color, filter_linear;
uniform float planet_radius = 300.0;
uniform sampler2D cloud_tex: source_color;
uniform vec4 cloud_color: source_color = vec4(1.0);
uniform float rotation_speed: hint_range(0.0, 1.0, 0.01) = 0.02;
uniform sampler2D moon_tex: source_color, filter_linear_mipmap_anisotropic;

struct RayHit {
	bool is_hit;
	vec3 normal;
	vec3 hit_point;
};

RayHit hit_sphere(vec3 ray_origin, vec3 ray_dir, vec3 sphere_center, float sphere_radius) {
	RayHit ray_hit;
	ray_hit.is_hit = false;
	vec3 oc = ray_origin - sphere_center;
	float a = dot(ray_dir, ray_dir);
	float b = 2.0 * dot(oc, ray_dir);
	float c = dot(oc, oc) - sphere_radius * sphere_radius;
	float delta = b * b - 4.0 * a * c;
	if (delta < 0.0) {
		return ray_hit;
	}
	float root = sqrt(delta);
	float t1 = (-b - root) / (2.0 * a);
	float t2 = (-b + root) / (2.0 * a);
	float t_near = min(t1, t2);
	float t_far = max(t1, t2);
	if (t_near < 0.0) {
		if (t_far >= 0.0) {
			t_near = 0.0;
		} else {
			return ray_hit;
		}
	}
	ray_hit.hit_point = fma(ray_dir, vec3(t_near), ray_origin);
	ray_hit.normal = normalize(ray_hit.hit_point - sphere_center);
	ray_hit.is_hit = true;
	return ray_hit;
}

vec2 get_spherical_uv(vec3 point_on_sphere, float rotation) {
	vec3 n = normalize(point_on_sphere);
	float theta = atan(n.z, n.x);
	float phi = acos(n.y);
	theta += rotation;
	float u = (theta + PI) / TAU;
	float v = phi / PI;
	return vec2(u, v);
}

vec3 compute_lighting(vec3 normal, vec3 light_dir) {
	return vec3(max(dot(normal, -light_dir), 0.0));
}

void sky() {
	if (AT_CUBEMAP_PASS) {
		COLOR = vec3(0.2, 0.6, 1.0);
	} else {
		vec3 planet_center = vec3(0.0, -100.0, planet_radius * 2.0);
		RayHit planet_hit = hit_sphere(POSITION, EYEDIR, planet_center, planet_radius);
		float moon_planet_dist = planet_radius * 8.0;
		float moon_angle = TIME / 10.0;
		vec3 moon_center = planet_center + vec3(sin(moon_angle) * moon_planet_dist, 0.0, cos(moon_angle) * moon_planet_dist);
		float moon_radius = planet_radius / 3.0;
		RayHit moon_hit = hit_sphere(POSITION, EYEDIR, moon_center, moon_radius);
		if (planet_hit.is_hit) {
			vec2 uv = get_spherical_uv(planet_hit.hit_point - planet_center, TIME * rotation_speed);
			vec3 color = texture(planet_tex, uv).rgb;
			vec2 cloud_uv = get_spherical_uv(planet_hit.hit_point - planet_center, TIME * rotation_speed);
			float cloud_noise = texture(cloud_tex, cloud_uv).r;
			vec2 cloud_uv2 = get_spherical_uv(planet_hit.hit_point - planet_center, (TIME * rotation_speed * 200.0 + 40.0) * 0.035);
			float cloud_noise2 = texture(cloud_tex, cloud_uv2).r;
			cloud_noise = mix(cloud_noise, cloud_noise2, 0.5);
			COLOR = mix(color, cloud_color.rgb, cloud_noise * cloud_color.a);
			vec3 sunlight_dir = normalize(planet_hit.hit_point - sun_pos);
			RayHit light_hit = hit_sphere(planet_hit.hit_point, -sunlight_dir, moon_center, moon_radius);
			vec3 lighting = compute_lighting(planet_hit.normal, sunlight_dir);
			COLOR *= lighting;
			if (light_hit.is_hit) {
				COLOR *= 0.2;
			}
		} else if (moon_hit.is_hit) {
			vec2 uv = get_spherical_uv(moon_hit.hit_point - moon_center, 0.0);
			vec3 color = texture(moon_tex, uv).rgb;
			vec3 sunlight_dir = normalize(moon_hit.hit_point - sun_pos);
			RayHit light_hit = hit_sphere(moon_hit.hit_point, -sunlight_dir, planet_center, planet_radius);
			if (light_hit.is_hit) {
				color *= 0.0;
			} else {
				vec3 lighting = compute_lighting(moon_hit.normal, sunlight_dir);
				color *= lighting;
			}
			COLOR = color;
		} else {
			COLOR = texture(sky_tex, SKY_COORDS).rgb;
			float ds = max(dot(normalize(sun_pos - POSITION), EYEDIR), 0.0);
			COLOR += pow(vec3(pow(ds, 40.0), pow(ds, 60.0), pow(ds, 100.0)), vec3(2.0));
		}
	}
}
