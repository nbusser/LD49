shader_type canvas_item;

uniform float time = 0.0;
uniform float weather = 0.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec3 c = texture(TEXTURE, UV).rgb;
	c = mix(c, vec3(0), time / 3.0);
	c = mix(c, vec3(0.5), weather / 3.0 * (UV.y / 2.0 + 0.5));
	COLOR.rgb = c;
}