shader_type canvas_item;
render_mode unshaded;

uniform float time_factor = 4;
uniform vec2 amplitude = vec2(10.0, 5.0);
uniform float anchor_threshold = -150;
uniform vec2 division = vec2(100.0, 500.0);

void vertex() {
	if (VERTEX.x > anchor_threshold) {
		VERTEX.x += sin(TIME * time_factor + VERTEX.y / division.x + VERTEX.x / division.y) * amplitude.x;
		VERTEX.y += cos(TIME * time_factor + VERTEX.y / division.x + VERTEX.x / division.y) * amplitude.y;
	}
}