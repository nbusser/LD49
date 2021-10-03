shader_type canvas_item;

uniform float time_factor = 4;
uniform float amplitude = 10.0;
const float PI = 3.14159;
uniform int mul = 10;
uniform float width = 1.0;

void vertex() {
	float x = VERTEX.x / width;
	float y = VERTEX.y;
	VERTEX.y += cos(TIME * time_factor + x * PI * float(mul)) * amplitude;
}
