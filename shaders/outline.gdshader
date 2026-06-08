shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);
uniform float glow_width : hint_range(1.0, 8.0) = 3.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE;

	// 呼吸脉冲
	float pulse = 0.75 + 0.25 * sin(TIME * 4.0);

	// 内层：1px 硬白描边（清晰轮廓）
	vec2 px1 = px * 1.0;
	float inner = 0.0;
	inner = max(inner, texture(TEXTURE, UV + vec2( px1.x, 0.0)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2(-px1.x, 0.0)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2(0.0,  px1.y)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2(0.0, -px1.y)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2( px1.x,  px1.y)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2(-px1.x,  px1.y)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2( px1.x, -px1.y)).a);
	inner = max(inner, texture(TEXTURE, UV + vec2(-px1.x, -px1.y)).a);

	// 外层：多距离采样，亮度递减，模拟发光
	float outer = 0.0;
	for (float i = 1.0; i <= 4.0; i += 1.0) {
		vec2 off = px * glow_width * (i / 4.0);
		float s = 0.0;
		s = max(s, texture(TEXTURE, UV + vec2( off.x, 0.0)).a);
		s = max(s, texture(TEXTURE, UV + vec2(-off.x, 0.0)).a);
		s = max(s, texture(TEXTURE, UV + vec2(0.0,  off.y)).a);
		s = max(s, texture(TEXTURE, UV + vec2(0.0, -off.y)).a);
		s = max(s, texture(TEXTURE, UV + vec2( off.x,  off.y)).a);
		s = max(s, texture(TEXTURE, UV + vec2(-off.x,  off.y)).a);
		s = max(s, texture(TEXTURE, UV + vec2( off.x, -off.y)).a);
		s = max(s, texture(TEXTURE, UV + vec2(-off.x, -off.y)).a);
		float falloff = 1.0 - (i - 1.0) / 4.0;
		outer = max(outer, s * falloff);
	}

	// 去掉精灵本体区域
	float outside = step(col.a, 0.001);

	// 内描边（白色，不随脉冲变化）
	float inner_mask = outside * inner;
	// 外发光（彩色，带脉冲）
	float outer_mask = outside * outer * pulse;

	// 合成：白描边 + 彩色发光叠加
	vec3 final_glow = mix(vec3(1.0), glow_color.rgb, 0.4) * inner_mask
					+ glow_color.rgb * outer_mask * 0.7;
	float glow_alpha = max(inner_mask, outer_mask * 0.7);

	COLOR = col + vec4(final_glow, glow_alpha) * (1.0 - col.a);
}
