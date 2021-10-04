shader_type canvas_item;

void fragment() {
	float a = sin(-TIME * 5.0 + UV.x * 20.0);
	if (a < 0.8) {
		COLOR.a = 0.05;
	}
	COLOR.a *= 1.0 - UV.x;
}