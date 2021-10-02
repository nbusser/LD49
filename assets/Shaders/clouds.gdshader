shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= 0.5 - UV.y / 2.0;
}