shader_type canvas_item;

uniform bool outline_enabled = false;
uniform bool slow_enabled = false;
uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);
uniform float glow_width : hint_range(1.0, 8.0) = 3.0;
uniform vec4 slow_tint : source_color = vec4(0.5, 0.8, 1.0, 1.0);

uniform bool tint_enabled = false;
uniform vec4 tint_color : source_color = vec4(1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.5;

// === 受击/状态染色（Phase 0 新增）===
uniform bool hit_flash_enabled = false;
uniform vec4 hit_flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // 白闪
uniform float hit_flash_amount : hint_range(0.0, 1.0) = 0.85;

uniform bool enraged_enabled = false;
uniform vec4 enraged_tint : source_color = vec4(1.0, 0.15, 0.0, 1.0);  // 狂暴红

uniform bool blessed_enabled = false;
uniform vec4 blessed_tint : source_color = vec4(1.0, 0.84, 0.25, 1.0);  // 神圣金

// === Boss 发光（Phase 0 新增，shader fake 版）===
uniform bool boss_glow_enabled = false;
uniform vec4 boss_glow_color : source_color = vec4(0.60, 0.20, 0.90, 1.0);  // 紫
uniform float boss_pulse_speed = 3.0;

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

	// 受击白闪：tint 整体偏白，覆盖慢 tint
	if (hit_flash_enabled) {
		col.rgb = mix(col.rgb, hit_flash_color.rgb, hit_flash_amount);
	}

	// 狂暴红 tint
	if (enraged_enabled) {
		col.rgb = mix(col.rgb, enraged_tint.rgb, 0.45);
	}

	// 神圣金 tint
	if (blessed_enabled) {
		col.rgb = mix(col.rgb, blessed_tint.rgb, 0.40);
	}

	// Boss 发光（shader fake）：紫色呼吸外发光 + 整体提亮
	if (boss_glow_enabled) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float pulse = 0.70 + 0.30 * sin(TIME * boss_pulse_speed);
		float outer = 0.0;
		for (float i = 1.0; i <= 4.0; i += 1.0) {
			vec2 off = px * (glow_width * 1.5) * (i / 4.0);
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
		float outer_mask = outside * outer * pulse;
		col.rgb = col.rgb * 1.15;  // 整体提亮
		col = col + vec4(boss_glow_color.rgb * outer_mask * 0.85, outer_mask * 0.85) * (1.0 - col.a);
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
