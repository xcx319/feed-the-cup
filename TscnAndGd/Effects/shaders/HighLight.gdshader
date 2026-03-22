shader_type canvas_item;


uniform vec4 shine_color : hint_color = vec4(1.0);
uniform float shine_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(0.0, 89.9, 0.1) = 45.0;

float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}
//uniform vec4 first_color = vec4(1.0,1.0,1.0,1.0);
//uniform vec4 second_color : hint_color = vec4(1.0); //= vec4(0.0, 0.0, 0.0, 1.0);
//uniform float position : hint_range(-0.5, 0.5) = 0.0;
//uniform float size : hint_range(0.5, 2) = 0.5;
//uniform float angle : hint_range(0.0, 360.0) = 90.0;

//void fragment() {
//	COLOR = texture(TEXTURE, UV);
//	float pivot = position + 0.5;
//	vec2 uv = UV - pivot;
//	float rotated = uv.x * cos(radians(angle)) - uv.y * sin(radians(angle));
//	float pos = smoothstep((1.0 - size) + position, size + 0.0001 + position, rotated + pivot);
//	COLOR = mix(first_color, second_color, pos);
//}
void fragment() {
    COLOR = texture(TEXTURE, UV);
	float slope = tan(radians(shine_angle));
	float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope);
    float shine = step(slope * UV.x - UV.y, progress + shine_size + shine_size * slope) - step(slope * UV.x - UV.y, progress);
    COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
	//float pivot = position + 0.5;
	//vec2 uv = UV - pivot;
	//float rotated = uv.x * cos(radians(angle)) - uv.y * sin(radians(angle));
	//float pos = smoothstep((1.0 - size) + position, size + 0.0001 + position, rotated + pivot);
	//COLOR = mix(COLOR,second_color,pos);
}