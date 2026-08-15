shader_type canvas_item;

// PR-5 屏幕后处理：色差（RGB 径向分裂）+ 冲击波扩散环
// 挂在 layer=5 CanvasLayer 的全屏 ColorRect 上，只作用游戏内容，不遮 UI(10)/跳字(15)

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float chromatic_strength : hint_range(0.0, 0.02) = 0.0;
uniform vec2 chromatic_center = vec2(0.5, 0.5);

// 冲击波槽位（最多 4 个同时），xy = 中心 UV，z = 当前半径(UV 归一)，w = 最大半径(UV 归一)
uniform int shockwave_count = 0;
uniform vec4 shockwaves[4];

void fragment() {
	vec2 uv = UV;
	vec4 col = texture(screen_tex, uv);

	// 色差：从中心向边缘偏移 R/B 通道
	if (chromatic_strength > 0.0001) {
		vec2 dir = uv - chromatic_center;
		col.r = texture(screen_tex, uv + dir * chromatic_strength).r;
		col.b = texture(screen_tex, uv - dir * chromatic_strength).b;
	}

	// 冲击波：白色加亮扩散环（不扭曲背景）
	for (int i = 0; i < shockwave_count; i++) {
		vec4 sw = shockwaves[i];
		float dist = distance(uv, sw.xy);
		float ring_width = 0.012;
		// 环带在 [z - 2w, z] 之间，z 越接近 w（最大半径）越淡
		float ring = smoothstep(sw.z, sw.z - ring_width, dist)
		           - smoothstep(sw.z - ring_width, sw.z - ring_width * 2.0, dist);
		float fade = 1.0 - clamp(sw.z / max(sw.w, 0.0001), 0.0, 1.0);
		col.rgb += vec3(1.0) * ring * fade * 0.5;
	}

	COLOR = col;
}
