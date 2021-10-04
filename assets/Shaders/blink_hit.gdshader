shader_type canvas_item;

uniform bool blink = false;
uniform vec3 color = vec3(1.0, 1.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR.rgb.b > 0.5) {
		COLOR.rgb = mix(COLOR.rgb, color, 0.25);	
	}
	if(blink) {
		float factor = 1.0;
		if(sin(TIME * 15.0) < 0.0) {
			factor = 0.0;
		}
		vec3 mixed = mix(COLOR.rgb, vec3(1.0, 1.0, 1.0), factor);
		COLOR.rgb = mixed;
	}
}