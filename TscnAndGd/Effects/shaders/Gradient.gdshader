shader_type canvas_item;

//float scale(float value, float inMin, float inMax, float outMin, float outMax) {
//    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
//}
//uniform sampler2D image;
uniform vec4 OnColor : hint_color = vec4(1.0); //= vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 SelfColor : hint_color = vec4(1.0); //= vec4(0.0, 0.0, 0.0, 1.0);
uniform float position : hint_range(-0.5, 0.5) = 0.0;
uniform float size : hint_range(0.5, 2) = 0.5;
uniform float angle : hint_range(0.0, 360.0) = 90.0;

void fragment() {
    //COLOR = texture(TEXTURE, UV);
	vec4 OLDColor = texture(TEXTURE, UV);
	vec4 NEWColor = texture(TEXTURE, UV);
	OLDColor.rgb = SelfColor.rgb;
	NEWColor.rgb = OnColor.rgb;
	//NEWColor.a = Color.a;
	//OLDColor.a = OnColor.a;
	float pivot = position + 0.5;
	vec2 uv = UV - pivot;
	//float pivot = UV + 0.5;
	//vec2 uv = UV - pivot;
	float rotated = uv.x * cos(radians(angle)) - uv.y * sin(radians(angle));
	float pos = smoothstep((1.0 - size) + position, size + 0.0001 + position, rotated + pivot);
	COLOR = mix(OLDColor,NEWColor,pos);
}