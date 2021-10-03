shader_type canvas_item;

uniform float time_factor = 3;
uniform vec2 amplitude = vec2(10.0, 5.0);
uniform float anchor_threshold = -150;
uniform vec2 division = vec2(100.0, 500.0);
uniform float weather = 0.0;

void vertex() {
	if (VERTEX.x > anchor_threshold) {
		VERTEX.x += sin((TIME * time_factor * (1.0 + weather * 3.0) + VERTEX.y / division.x + VERTEX.x / division.y) * (1.0 + weather * 0.5)) * amplitude.x * (1.0 + weather * 1.0);
		VERTEX.y += cos((TIME * time_factor * (1.0 + weather * 0.0) + VERTEX.y / division.x + VERTEX.x / division.y) * (1.0 + weather * 0.5)) * amplitude.y;
	}
}