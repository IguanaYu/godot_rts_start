shader_type canvas_item;

uniform bool outline_enabled = false;
uniform bool slow_enabled = false;
uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);
uniform float glow_width : hint_range(1.0, 8.0) = 3.0;
uniform vec4 slow_tint : source_color = vec4(0.5, 0.8, 1.0, 1.0);

uniform bool tint_enabled = false;
uniform vec4 tint_color : source_color = vec4(1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	// 减速变色：整体向冰蓝色偏移
	if (slow_enabled) {
		col.rgb = mix(col.rgb, slow_tint.rgb, 0.35);
	}

	// 变体调色：优先于减速染色，两者不叠加
	if (tint_enabled) {
		col.rgb = mix(col.rgb, tint_color.rgb, tint_amount);
	}

	// 选中发光
	if (outline_enabled) {
		vec2 px = TEXTURE_PIXEL_SIZE;

		float pulse = 0.75 + 0.25 * sin(TIME * 4.0);

		// 内层：1px 硬白描边
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

		// 外层：多距离发光
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

		float outside = step(col.a, 0.001);
		float inner_mask = outside * inner;
		float outer_mask = outside * outer * pulse;

		vec3 final_glow = mix(vec3(1.0), glow_color.rgb, 0.4) * inner_mask
						+ glow_color.rgb * outer_mask * 0.7;
		float glow_alpha = max(inner_mask, outer_mask * 0.7);

		col = col + vec4(final_glow, glow_alpha) * (1.0 - col.a);
	}

	COLOR = col;
}
