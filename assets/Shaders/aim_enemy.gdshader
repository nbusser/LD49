shader_type canvas_item;

void fragment() {
	float a = sin(TIME * 10.0 + SCREEN_UV.x * 60.0);
	if (a < 0.8) {
		COLOR.a = 0.05;
	}
}