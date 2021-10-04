shader_type canvas_item;

void vertex() {
	if (VERTEX.y < 0.0) {
		VERTEX.y += (sin(TIME * 10.0) + 1.1) * 60.0;
	}
}