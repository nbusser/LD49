shader_type canvas_item;

uniform float time_factor = 4;
uniform float amplitude = 10.0;
const float PI = 3.14159;
uniform int mul = 10;
uniform float width = 1.0;

void vertex() {
	float x = VERTEX.x / width;
	float y = VERTEX.y;
	float tmp = cos(TIME * time_factor + x * PI * float(mul));
	VERTEX.y += tmp * amplitude + 0.5 * amplitude * cos(TIME * time_factor + VERTEX.x * PI * float(mul));
}
