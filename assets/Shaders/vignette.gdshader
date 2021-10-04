shader_type canvas_item;

uniform float vignette = 0.0;

void fragment(){
	float x = (UV.x*2.0)-1.0;
	float y = (UV.y*2.0)-1.0;
	float angle = atan(x, y);
	float sin_angle = abs(sin(TIME * 10.0 + angle * 120.0));
	
	float dist = pow((UV.x-0.5), 2) + pow((UV.y-0.5), 2);
	COLOR.a = floor(sin_angle/0.98) * (max(0, dist - 0.15) / 2.0) * vignette;
}