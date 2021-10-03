shader_type canvas_item;

uniform float time_factor = 4;
uniform float amplitude = 10.0;
const float PI = 3.14159;
uniform int mul = 10;
uniform float width = 1.0;
uniform float offset = 0.0;

void vertex() {
	float x = VERTEX.x / width;
	float y = VERTEX.y;
	float m_0 = -amplitude / 2.0;
	float m_1 = cos(offset + TIME * time_factor + x * PI * float(mul)) * amplitude;
	float m_2 = cos(offset + TIME * time_factor + x * PI * float(mul) * 10.0) * amplitude / 2.0;
	float m_3 = cos(offset + TIME * time_factor + x * PI * float(mul) * 50.0) * amplitude / 5.0;
	VERTEX.y += m_0 + m_1 + m_2 + m_3;
}
