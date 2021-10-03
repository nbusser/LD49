shader_type canvas_item;

const float PI = 3.14159;

uniform vec3 day_color = vec3(0.4, 0.6, 1.0);
uniform vec3 night_color = vec3(0.1, 0.05, 0.3);
uniform vec3 sunset_color = vec3(1.0, 0.6, 0.2);
uniform vec3 bad_weather_color = vec3(0.2, 0.25, 0.4);
uniform float time = 0.0;
uniform float weather = 0.0;

float sigmoid(in float x, in float k) {
	return 1.0 / (1.0 + exp((0.5 - x) * k));
}

void fragment() {
	vec3 c;
	float time_sig = sigmoid(time, 10.0);

	float sunset_amount = pow(sin(time_sig * PI) / 2.0 + 0.5, 5.0) / 1.5;
	vec3 day = mix(vec3(1), day_color, 1.0 - UV.y / 2.0);
	vec3 night = mix(vec3(0), night_color, 1.0 - UV.y / 2.0);
	c = mix(mix(day, night, time_sig), sunset_color, sunset_amount);
	c = mix(c, bad_weather_color, weather / (2.0 * UV.y + 1.0));
	COLOR.rgb = c;
}
