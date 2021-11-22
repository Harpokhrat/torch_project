shader_type canvas_item;

uniform vec2 camera_offset = vec2(0.0, 0.0);
uniform float stress_amount: hint_range(0.0, 10.0) = 0.0;


void vertex()
{
	VERTEX += camera_offset;
}


void fragment()
{
	vec2 r_wave_uv = UV;
	r_wave_uv.x += stress_amount * sin(TIME * 3.3 + UV.y * 7.0) * 0.0025;
	r_wave_uv.y += stress_amount * sin(TIME * 2.5 + UV.x * 8.0) * 0.0022;
	
	vec2 g_wave_uv = UV;
	g_wave_uv.x += stress_amount * sin(TIME * 2.7 + UV.y * 5.5) * 0.0012;
	g_wave_uv.y += stress_amount * sin(TIME * 1.2 + UV.x * 9.0) * 0.0042;
	
	vec2 b_wave_uv = UV;
	b_wave_uv.x += stress_amount * sin(TIME * 4.2 + UV.y * 8.2) * 0.0033;
	b_wave_uv.y += stress_amount * sin(TIME * 1.7 + UV.x * 6.66) * 0.0018;
	
	float color_r = texture(TEXTURE, r_wave_uv).r;
	float color_g = texture(TEXTURE, g_wave_uv).g;
	float color_b = texture(TEXTURE, b_wave_uv).b;
	
	COLOR.rgb = vec3(color_r, color_g, color_b);
}