shader_type canvas_item;

uniform float time = 0.0;
uniform float weather = 0.0;
uniform float lightning_threshold = 0.0;

bool gen_lightning(in float t) {
	float tmp = pow(sin(t * 1.0) / 2.0 + 0.5, 10);
	return tmp > 0.995;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec3 c = texture(TEXTURE, UV).rgb;
	c = mix(c, vec3(0), time / 3.0 + weather / 3.0);
	c = mix(c, vec3(0.5), weather / 3.0 * (UV.y / 2.0 + 0.5));
	c = mix(c, vec3(0), -0.1 * weather);
	float lightning = 0.0;
	if (weather > lightning_threshold && (gen_lightning(TIME) || gen_lightning(TIME + 0.2))) {
		lightning = 1.0;
	}
	c = mix(c, vec3(0), -lightning);
	c = mix(c, vec3(1), lightning / 3.0);
	COLOR.rgb = c;
}
