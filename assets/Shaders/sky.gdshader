shader_type canvas_item;

uniform vec3 day_color = vec3(0.4, 0.6, 1.0);
uniform vec3 night_color = vec3(0.1, 0.05, 0.3);
uniform float time = 0.5;

void fragment() {
	vec3 c;
	float periodic_time = sin(time * 3.1415);

	vec3 day = mix(vec3(1), day_color, 1.0 - UV.y / 2.0);
	vec3 night = mix(vec3(0), night_color, 1.0 - UV.y / 2.0);
	c = mix(night, day, periodic_time);
	COLOR.rgb = c;
}