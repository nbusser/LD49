shader_type canvas_item;

uniform bool blink = false;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if(blink) {
		float factor = 1.0;
		if(sin(TIME * 15.0) < 0.0) {
			factor = 0.0;
		}
		vec3 mixed = mix(COLOR.rgb, vec3(1.0, 1.0, 1.0), factor);
		COLOR.rgb = mixed;
	}
}